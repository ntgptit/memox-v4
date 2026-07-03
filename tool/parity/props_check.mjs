#!/usr/bin/env node
// props_check (F.1) — diff each kit component's .d.ts prop contract against the
// matching Flutter widget constructor. Advisory through P0/P1 (always exit 0);
// flipped to blocking in P2/Z.0. Config + schema: tool/parity/props_map.json +
// tool/parity/README.md. Scope: API surface only (names / enum value space /
// optionality) — NOT visual fidelity.
//
// Usage:
//   node tool/parity/props_check.mjs                # every discoverable component
//   node tool/parity/props_check.mjs --only dashboard   # one feature unit
//   node tool/parity/props_check.mjs --shared           # the 15 core/nav/surfaces
//   node tool/parity/props_check.mjs --json             # machine output
//   node tool/parity/props_check.mjs --strict           # exit 1 on undeclared drift

import fs from 'node:fs';
import path from 'node:path';
import process from 'node:process';
import { fileURLToPath } from 'node:url';

const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..', '..');
const MAP = readJson(path.join(ROOT, 'tool/parity/props_map.json'));
const EXC_PATH = path.join(ROOT, 'props-parity.exceptions.json');
const EXCEPTIONS = fs.existsSync(EXC_PATH) ? readJson(EXC_PATH) : [];

const args = process.argv.slice(2);
const only = argValue('--only');
const onlyShared = args.includes('--shared');
const asJson = args.includes('--json');
const strict = args.includes('--strict');

// ---------------------------------------------------------------- discovery ---

/** All Flutter `class X` → absolute file path, across lib/presentation. */
const flutterClassIndex = indexFlutterClasses(path.join(ROOT, 'lib/presentation'));

/** Discover every kit component that currently has a .d.ts. */
const components = discoverComponents();

const selected = components.filter((c) => {
  if (onlyShared) return c.shared;
  if (!only) return true;
  return (
    c.unit === only ||
    c.category === only ||
    c.name === only ||
    c.key.includes(only)
  );
});

// ------------------------------------------------------------------- run ------

const report = [];
for (const comp of selected) {
  report.push(analyze(comp));
}

if (asJson) {
  process.stdout.write(JSON.stringify(report, null, 2) + '\n');
} else {
  printReport(report);
}

const undeclared = report.reduce((n, r) => n + r.drift.filter((d) => !d.excused).length, 0);
process.exit(strict && undeclared > 0 ? 1 : 0);

// =============================================================== functions ===

function analyze(comp) {
  const kit = parseDts(comp.dtsPath, comp.name);
  const flutterClass = comp.aliasClass || comp.name;
  const flutterFile = flutterClassIndex[flutterClass];
  const drift = [];

  if (!flutterFile) {
    const excused = excuseFor(comp.key, '*', ['deferred-screen', 'flutter-only']);
    drift.push(mark({ kind: 'NO_FLUTTER_COUNTERPART', prop: '*', detail: `no class ${flutterClass} under lib/presentation` }, comp, excused));
    return { component: comp.key, flutterClass, flutterFile: null, kitProps: kit.props.map((p) => p.name), drift };
  }

  const ft = parseFlutterCtor(flutterFile, flutterClass);
  const consumed = new Set(['key']); // super.key is never a kit prop

  for (const prop of kit.props) {
    if (MAP.propDrop.names.includes(prop.name)) continue; // web-only
    // identity first, then declared aliases — a Flutter param with the same name
    // as the kit prop always satisfies it (e.g. MxScaffold children → children).
    const targets = [prop.name, ...(MAP.propNameAlias[prop.name] || [])];
    const paramName = targets.find((t) => ft.params[t]);
    if (!paramName) {
      const excused = excuseFor(comp.key, prop.name, ['web-only', 'flutter-idiom', 'deferred-screen']);
      drift.push(mark({ kind: 'MISSING_IN_FLUTTER', prop: prop.name, detail: `no param in {${Object.keys(ft.params).join(', ')}}` }, comp, excused));
      continue;
    }
    consumed.add(paramName);
    const param = ft.params[paramName];

    // optionality — direction matters. kit REQUIRED but Flutter optional means the
    // Flutter API is LOOSER than the contract (a required prop can be omitted) →
    // real drift. kit OPTIONAL but Flutter required is a safe *tightening* the app
    // chose (a content prop the widget can't render without) → INFO, not drift.
    if (!prop.optional && !param.required && !prop.hasDefault) {
      const excused = excuseFor(comp.key, prop.name, ['flutter-idiom', 'enum-base-expansion']);
      drift.push(mark({ kind: 'OPTIONALITY_MISMATCH', prop: prop.name, detail: `kit required → Flutter optional (${paramName})` }, comp, excused));
    } else if (prop.optional && param.required) {
      drift.push({ kind: 'OPTIONALITY_TIGHTENED', prop: prop.name, detail: `kit optional → Flutter required (${paramName})`, excused: true, info: true });
    }

    // enum value space
    if (prop.union) {
      const enumType = stripNull(param.type);
      const flutterVals = ft.enums[enumType];
      if (flutterVals) {
        const wanted = prop.union.map(aliasEnumValue);
        const missing = wanted.filter((v) => !flutterVals.includes(v));
        const extra = flutterVals.filter((v) => !wanted.includes(v));
        if (missing.length) {
          drift.push(mark({ kind: 'ENUM_MISMATCH', prop: prop.name, detail: `kit values missing from ${enumType}: ${missing.join(', ')}` }, comp, false));
        }
        if (extra.length) {
          const excused = excuseFor(comp.key, prop.name, ['enum-base-expansion', 'flutter-idiom']);
          drift.push(mark({ kind: 'ENUM_EXTRA_IN_FLUTTER', prop: prop.name, detail: `${enumType} adds: ${extra.join(', ')}`, hint: 'base value the kit omits → record enum-base-expansion' }, comp, excused));
        }
      }
    }
  }

  // extra Flutter params with no kit prop (advisory; skip idiomatic slots)
  const IDIOMATIC = new Set(['key', 'child', 'children', 'builder']);
  for (const name of Object.keys(ft.params)) {
    if (consumed.has(name) || IDIOMATIC.has(name)) continue;
    const excused = excuseFor(comp.key, name, ['flutter-only', 'flutter-idiom', 'enum-base-expansion']);
    drift.push(mark({ kind: 'EXTRA_IN_FLUTTER', prop: name, detail: 'Flutter param has no kit prop' }, comp, excused));
  }

  return { component: comp.key, flutterClass, flutterFile: path.relative(ROOT, flutterFile), kitProps: kit.props.map((p) => p.name), drift };
}

// ------------------------------------------------------------- .d.ts parse ---

function parseDts(file, name) {
  const raw = stripComments(fs.readFileSync(file, 'utf8'));
  const re = new RegExp(`interface\\s+${name}Props\\s*\\{([\\s\\S]*?)\\n\\}`);
  const m = raw.match(re);
  if (!m) return { props: [] };
  const body = m[1];
  const props = [];
  // join wrapped lines so a multi-line union collapses to one statement
  const statements = body.split(';').map((s) => s.trim()).filter(Boolean);
  for (const stmt of statements) {
    const pm = stmt.match(/^([A-Za-z_][A-Za-z0-9_]*)(\??)\s*:\s*([\s\S]+)$/);
    if (!pm) continue;
    const [, pname, opt, rawType] = pm;
    const type = rawType.trim();
    const union = parseUnion(type);
    props.push({
      name: pname,
      optional: opt === '?',
      type,
      union,
      hasDefault: /@default/.test(stmt),
    });
  }
  return { props };
}

/** Return the string-literal members of a union type, or null. */
function parseUnion(type) {
  if (!type.includes('|') || !type.includes("'")) return null;
  const vals = [...type.matchAll(/'([^']+)'/g)].map((x) => x[1]);
  return vals.length ? vals : null;
}

// ----------------------------------------------------------- Flutter parse ---

function parseFlutterCtor(file, className) {
  const src = fs.readFileSync(file, 'utf8');
  const enums = {};
  for (const em of src.matchAll(/enum\s+([A-Za-z0-9_]+)\s*\{([^}]*)\}/g)) {
    enums[em[1]] = em[2]
      .split(',')
      .map((v) => v.replace(/\/\/.*$/gm, '').trim())
      .filter((v) => v && /^[A-Za-z_]/.test(v));
  }

  // final field types in the class body
  const fieldTypes = {};
  for (const fm of src.matchAll(/\bfinal\s+([A-Za-z0-9_<>,?\s]+?)\s+([A-Za-z_][A-Za-z0-9_]*)\s*;/g)) {
    fieldTypes[fm[2]] = fm[1].replace(/\s+/g, ' ').trim();
  }

  // named-param block of the primary const constructor
  const params = {};
  const ctorRe = new RegExp(`const\\s+${className}\\s*\\(([\\s\\S]*?)\\)\\s*;`);
  const cm = src.match(ctorRe);
  if (cm) {
    const inner = cm[1];
    const braceStart = inner.indexOf('{');
    const namedBlock = braceStart >= 0 ? inner.slice(braceStart + 1, inner.lastIndexOf('}')) : '';
    for (const part of splitTopLevel(namedBlock)) {
      const token = part.trim();
      if (!token) continue;
      const required = /\brequired\b/.test(token);
      const eq = token.indexOf('=');
      const hasDefault = eq >= 0;
      const decl = (hasDefault ? token.slice(0, eq) : token).trim();
      const nm = decl.match(/(?:this\.|super\.)?([A-Za-z_][A-Za-z0-9_]*)\s*$/);
      if (!nm) continue;
      const pname = nm[1];
      params[pname] = {
        name: pname,
        required,
        hasDefault,
        type: fieldTypes[pname] || 'dynamic',
      };
    }
  }
  return { params, enums };
}

// --------------------------------------------------------------- utilities ---

function aliasEnumValue(v) {
  if (MAP.enumValueAlias.map[v]) return MAP.enumValueAlias.map[v];
  if (MAP.enumValueAlias.kebabToCamel && v.includes('-')) {
    return v.replace(/-([a-z])/g, (_, c) => c.toUpperCase());
  }
  return v;
}

function excuseFor(componentKey, prop, allowedReasons) {
  return EXCEPTIONS.some(
    (e) =>
      e.component === componentKey &&
      (e.prop === prop || e.prop === '*') &&
      allowedReasons.includes(e.reason),
  );
}

function mark(drift, comp, excused) {
  return { ...drift, excused: !!excused };
}

function discoverComponents() {
  const out = [];
  const compRoot = path.join(ROOT, MAP.componentsRoot);
  for (const cat of ['core', 'navigation', 'surfaces']) {
    const dir = path.join(compRoot, cat);
    if (!fs.existsSync(dir)) continue;
    for (const f of fs.readdirSync(dir).filter((f) => f.endsWith('.d.ts'))) {
      const name = f.replace(/\.d\.ts$/, '');
      out.push(makeComp(`${cat}/${name}`, name, 'shared', cat, path.join(dir, f), true));
    }
  }
  addLocal(out, path.join(ROOT, MAP.featuresRoot), true);
  const sharedDir = path.join(ROOT, MAP.sharedRoot);
  if (fs.existsSync(sharedDir)) {
    for (const f of fs.readdirSync(sharedDir).filter((f) => f.endsWith('.d.ts'))) {
      const name = f.replace(/\.d\.ts$/, '');
      out.push(makeComp(`_shared/${name}`, name, '_shared', null, path.join(sharedDir, f), false));
    }
  }
  return out;
}

function addLocal(out, featuresRoot, perFeature) {
  if (!fs.existsSync(featuresRoot)) return;
  for (const feat of fs.readdirSync(featuresRoot)) {
    const compDir = path.join(featuresRoot, feat, 'components');
    if (!fs.existsSync(compDir)) continue;
    for (const f of fs.readdirSync(compDir).filter((f) => f.endsWith('.d.ts'))) {
      const name = f.replace(/\.d\.ts$/, '');
      out.push(makeComp(`${feat}/${name}`, name, feat, null, path.join(compDir, f), false));
    }
  }
}

function makeComp(key, name, unit, category, dtsPath, shared) {
  const alias = MAP.fileAlias[key];
  return { key, name, unit, category, dtsPath, shared, aliasClass: alias?.class };
}

function indexFlutterClasses(dir) {
  const index = {};
  walk(dir, (file) => {
    if (!file.endsWith('.dart')) return;
    const src = fs.readFileSync(file, 'utf8');
    for (const m of src.matchAll(/\bclass\s+([A-Za-z0-9_]+)\s+extends\s+/g)) {
      if (!index[m[1]]) index[m[1]] = file;
    }
  });
  return index;
}

function walk(dir, fn) {
  if (!fs.existsSync(dir)) return;
  for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
    const full = path.join(dir, entry.name);
    if (entry.isDirectory()) walk(full, fn);
    else fn(full);
  }
}

function splitTopLevel(s) {
  const out = [];
  let depth = 0;
  let cur = '';
  for (const ch of s) {
    if ('([<{'.includes(ch)) depth++;
    else if (')]>}'.includes(ch)) depth--;
    if (ch === ',' && depth === 0) {
      out.push(cur);
      cur = '';
    } else {
      cur += ch;
    }
  }
  if (cur.trim()) out.push(cur);
  return out;
}

function stripComments(s) {
  return s.replace(/\/\*[\s\S]*?\*\//g, '').replace(/^\s*\/\/.*$/gm, '');
}

function stripNull(t) {
  return t.replace(/\?$/, '').trim();
}

function argValue(flag) {
  const i = args.indexOf(flag);
  return i >= 0 && args[i + 1] ? args[i + 1] : null;
}

function readJson(p) {
  return JSON.parse(fs.readFileSync(p, 'utf8'));
}

function printReport(report) {
  let total = 0;
  let excused = 0;
  for (const r of report) {
    const real = r.drift.filter((d) => !d.excused);
    excused += r.drift.length - real.length;
    if (r.drift.length === 0) {
      console.log(`\x1b[32m✓\x1b[0m ${r.component} → ${r.flutterClass} (${r.kitProps.length} props)`);
      continue;
    }
    const tag = real.length ? '\x1b[33m●\x1b[0m' : '\x1b[36m○\x1b[0m';
    console.log(`${tag} ${r.component} → ${r.flutterClass}`);
    for (const d of r.drift) {
      const mk = d.info
        ? '\x1b[36m  ○ (ok: tightened)\x1b[0m'
        : d.excused
          ? '\x1b[36m  · (excused)\x1b[0m'
          : '\x1b[33m  ✗\x1b[0m';
      console.log(`${mk} ${d.kind} [${d.prop}] — ${d.detail}${d.hint ? ` (${d.hint})` : ''}`);
      if (!d.excused) total++;
    }
  }
  console.log('');
  console.log(`props_check: ${report.length} components · ${total} undeclared drift · ${excused} excused`);
  console.log(strict ? (total ? '\x1b[31mFAIL (strict)\x1b[0m' : '\x1b[32mPASS\x1b[0m') : 'advisory (exit 0)');
}
