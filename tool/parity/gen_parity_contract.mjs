#!/usr/bin/env node
// tool/parity/gen_parity_contract.mjs — generate the structural parity contract
// (key + component + variant) by STATICALLY parsing the kit JSX. No Chrome, no
// network, no AI: the kit's `<Mx* node="…" variant="…">` attributes are literal,
// so identity + the variant-driven styling layer can be derived directly.
//
// WHY this exists alongside gen_contract/gen_bindings: those read specs/*.md, which
// only exist after export_specs (Chrome) renders the kit — a step never run for the
// active layout (see tool.config.json $pointsAt). This tool de-inerts the identity
// + styling layers of the gate from the SAME design source, without that Chrome
// dependency. It deliberately does NOT emit slots: slot `role`/layout need the
// renderer's computed styles (export_specs) + a curated font→role map, and slot
// `l10n` keys do not exist in the design at all (the kit carries literal strings).
// Slots live in `<screen>.slots.json` (curated) until export_specs can fill them.
//
// Variant is the source of truth for bg/radius/border (MxCard maps variant→paint),
// so emitting `variant` gives the styling gate for free — no decorations needed.
//
// Usage:
//   node tool/parity/gen_parity_contract.mjs            # write contracts/<screen>.gen.json
//   node tool/parity/gen_parity_contract.mjs --check    # exit 1 if any .gen.json is stale
//   node tool/parity/gen_parity_contract.mjs --json     # print, write nothing

import { existsSync, mkdirSync, readFileSync, readdirSync, writeFileSync } from 'node:fs';
import { dirname, join, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';
import { PATHS } from '../_config.mjs';

const HERE = dirname(fileURLToPath(import.meta.url));
const REPO = resolve(HERE, '..', '..');
const KIT = join(REPO, PATHS.uiKitDir);
const OUT = join(HERE, 'contracts');

const args = process.argv.slice(2);
const check = args.includes('--check');
const asJson = args.includes('--json');

// kebab kit variant → Dart MxCardVariant name (`primary-soft` → `primarySoft`);
// an absent `variant=` means the component's default, which for MxCard is elevated.
const camel = (s) => s.replace(/-(\w)/g, (_, c) => c.toUpperCase());
const DEFAULT_VARIANT = { MxCard: 'elevated' };

/** Parse one screen JSX into ordered, deduped {key, component, variant} nodes. */
function parseScreen(jsx) {
  // Drop inline `style={{ … }}` so a '>' inside a style can't end a tag early.
  const src = jsx.replace(/style=\{\{[^{}]*\}\}/g, '');
  const nodes = [];
  const seen = new Map();
  // Opening tags of Mx* components that carry a LITERAL node="…" attribute.
  const tag = /<Mx(\w+)\b([^>]*?)\bnode="([^"]+)"([^>]*?)\/?>/g;
  let m;
  while ((m = tag.exec(src)) !== null) {
    const component = `Mx${m[1]}`;
    const node = m[3];
    const attrs = `${m[2]} ${m[4]}`;
    const vm = /\bvariant="([^"]+)"/.exec(attrs);
    const variant = vm ? camel(vm[1]) : DEFAULT_VARIANT[component] ?? null;
    const key = `mx-node:${node}`;
    if (seen.has(key)) {
      // Same node may recur across states; flag a real variant disagreement.
      const prev = seen.get(key);
      if (prev.variant !== variant) {
        prev.conflict = [prev.variant, variant];
      }
      continue;
    }
    const entry = { key, component, variant };
    seen.set(key, entry);
    nodes.push(entry);
  }
  return nodes;
}

// `shell/*` nodes (app bar, bottom nav) are shared chrome that appears on every
// screen JSX — owned by a shell contract, not the screen's. Ignore for detection.
const SHARED_PREFIXES = new Set(['shell']);
const prefixOf = (n) => n.key.replace('mx-node:', '').split('/')[0];

/** Screen id = the single non-shared `node=` prefix (dashboard/today → "dashboard"). */
function screenOf(nodes) {
  const prefixes = new Set(
    nodes.map(prefixOf).filter((p) => !SHARED_PREFIXES.has(p)),
  );
  return prefixes.size === 1 ? [...prefixes][0] : null;
}

// A screen's nodes are spread across its entry (_features/<screen>/<Name>.jsx) AND
// its feature-local components (_features/<screen>/components/*.jsx), so we walk the
// kit recursively and GROUP by screen before emitting one contract per screen.
// Excluded: kit-helpers.jsx, _shared/** (cross-screen composites — not screen-owned),
// and the generated specs/ + shots/ dirs.
const SKIP_DIRS = new Set(['specs', 'shots', '_shared', 'node_modules']);
function collectKitJsx(dir, acc = []) {
  if (!existsSync(dir)) return acc;
  for (const d of readdirSync(dir, { withFileTypes: true })) {
    if (d.isDirectory()) {
      if (!SKIP_DIRS.has(d.name)) collectKitJsx(join(dir, d.name), acc);
    } else if (d.name.endsWith('.jsx') && d.name !== 'kit-helpers.jsx') {
      acc.push(join(dir, d.name));
    }
  }
  return acc;
}

// screen -> Map(node-key -> {key, component, variant[, conflict]}), merged across
// the screen's entry + component files. A node id lives in exactly one file, but we
// still flag any cross-file variant disagreement the same way parseScreen does.
const byScreen = new Map();
for (const abs of collectKitJsx(KIT)) {
  const nodes = parseScreen(readFileSync(abs, 'utf8'));
  if (!nodes.length) continue;
  const screen = screenOf(nodes);
  if (!screen) continue; // file mixes prefixes (a shared helper/composite)
  // Scope to this screen's own nodes; shared chrome (shell/*) lives elsewhere.
  const scoped = nodes.filter((n) => prefixOf(n) === screen);
  if (!scoped.length) continue;
  const seen = byScreen.get(screen) || new Map();
  for (const n of scoped) {
    const prev = seen.get(n.key);
    if (prev) {
      if (prev.variant !== n.variant) prev.conflict = [prev.variant, n.variant];
      continue;
    }
    seen.set(n.key, { ...n });
  }
  byScreen.set(screen, seen);
}

// One contract per screen; screens and nodes sorted by key for deterministic output
// (nodes now come from multiple files, so source order is not stable — sort instead).
const built = [];
for (const [screen, seen] of [...byScreen].sort((a, b) => (a[0] < b[0] ? -1 : 1))) {
  const nodes = [...seen.values()].sort((a, b) => (a.key < b.key ? -1 : a.key > b.key ? 1 : 0));
  const conflicts = nodes.filter((n) => n.conflict);
  built.push({ screen, source: `${PATHS.uiKitDir}/_features/${screen}`, nodes, conflicts });
}

if (asJson) {
  console.log(JSON.stringify(built, null, 2));
  process.exit(0);
}

const banner =
  'tool/parity/gen_parity_contract.mjs — static kit-JSX parse (no Chrome). ' +
  'key+component+variant only; slots are curated in <screen>.slots.json until export_specs fills role/layout.';

if (!existsSync(OUT)) mkdirSync(OUT, { recursive: true });

let stale = 0;
let conflictCount = 0;
for (const b of built) {
  for (const c of b.conflicts) {
    conflictCount++;
    console.error(`CONFLICT ${b.screen}: ${c.key} variant ${c.conflict.join(' vs ')}`);
  }
  const nodes = b.nodes.map(({ key, component, variant }) => ({ key, component, variant }));
  const next = `${JSON.stringify({ $generated: banner, screen: b.screen, source: b.source, nodes }, null, 2)}\n`;
  const outFile = join(OUT, `${b.screen}.gen.json`);
  const prev = existsSync(outFile) ? readFileSync(outFile, 'utf8') : '';
  if (prev !== next) {
    stale++;
    if (check) {
      console.error(`STALE ${b.screen}.gen.json — run \`node tool/parity/gen_parity_contract.mjs\``);
    } else {
      writeFileSync(outFile, next);
      console.log(`${prev ? 'updated' : 'wrote'} contracts/${b.screen}.gen.json (${nodes.length} nodes)`);
    }
  }
}

if (conflictCount) process.exit(1);
if (check && stale) process.exit(1);
if (!check && !stale) console.log('all .gen.json up to date');
process.exit(0);
