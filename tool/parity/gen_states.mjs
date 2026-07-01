#!/usr/bin/env node
// tool/parity/gen_states.mjs — derive the PER-STATE node membership of each screen.
//
// `<screen>.gen.json` is state-agnostic: it dedups every node a screen can show
// across all its states. But the kit defines each screen in N states (the SCREENS
// registry) and the DOM spec records them: a full "Base state" tree plus an
// ordered `+`/`-` diff per remaining state. This tool turns that into a machine
// contract — `<screen>.states.json` = { state-id: [node ids present in that state] }
// — so a per-state parity test can assert "state X of screen Y renders exactly its
// nodes in the FE" (identity rollout, per state).
//
// State ids come from the SCREENS registry (index.html); spec sections are matched
// to them IN ORDER (section 0 = base = states[0], diff k = states[k+1]) — robust to
// the display-label munging the exporter does. Base/`full` sections list every
// `id:`; `ordered diff` sections start from the base set and apply `+ id:` / `- id:`.
//
// Usage:
//   node tool/parity/gen_states.mjs            # all screens -> <screen>.states.json
//   node tool/parity/gen_states.mjs --screen review
//   node tool/parity/gen_states.mjs --stdout --screen review

import { existsSync, mkdirSync, readFileSync, writeFileSync } from 'node:fs';
import { dirname, join, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';
import { PATHS } from '../_config.mjs';

const HERE = dirname(fileURLToPath(import.meta.url));
const REPO = resolve(HERE, '..', '..');
const KIT = join(REPO, PATHS.uiKitDir);
const SPECS = join(KIT, 'specs');
const OUT = join(HERE, 'contracts');

const args = process.argv.slice(2);
const only = args.includes('--screen') ? args[args.indexOf('--screen') + 1] : null;
const toStdout = args.includes('--stdout');
const force = args.includes('--force'); // also (re)build screens that already have a curated .states.json

// screen id -> ordered state ids, from the SCREENS registry literal in index.html.
function screenStates() {
  const html = readFileSync(join(KIT, 'index.html'), 'utf8');
  const out = {};
  const re = /\{\s*id:\s*'([^']+)'[\s\S]*?states:\s*\[([^\]]+)\]/g;
  let m;
  while ((m = re.exec(html)) !== null) {
    out[m[1]] = m[2].split(',').map((s) => s.trim().replace(/^'|'$/g, '')).filter(Boolean);
  }
  return out;
}

// Split a spec .md into ordered sections: { kind: 'base'|'diff'|'full', body }.
function sections(md) {
  const out = [];
  const re = /^## (Base state|State):.*$/gm;
  const heads = [...md.matchAll(re)];
  for (let i = 0; i < heads.length; i++) {
    const head = heads[i][0];
    const from = heads[i].index;
    const to = i + 1 < heads.length ? heads[i + 1].index : md.length;
    const chunk = md.slice(from, to);
    const fence = chunk.match(/```(?:text|diff)\n([\s\S]*?)```/);
    const body = fence ? fence[1] : '';
    const kind = head.startsWith('## Base') ? 'base' : head.includes('(full') ? 'full' : 'diff';
    out.push({ kind, body });
  }
  return out;
}

const ID_RE = /^\s*id: (.+)$/;

// Present-node set for one section, given the base set (for diffs).
function presentOf(section, base) {
  if (section.kind === 'diff') {
    const present = new Set(base);
    for (const line of section.body.split('\n')) {
      const op = line[0]; // '+', '-', or ' '
      const idM = line.slice(1).match(ID_RE);
      if (!idM) continue;
      if (op === '+') present.add(idM[1].trim());
      else if (op === '-') present.delete(idM[1].trim());
    }
    return present;
  }
  // base / full: every id: in the block.
  const present = new Set();
  for (const line of section.body.split('\n')) {
    const idM = line.match(ID_RE);
    if (idM) present.add(idM[1].trim());
  }
  return present;
}

if (!existsSync(OUT)) mkdirSync(OUT, { recursive: true });
const registry = screenStates();
const banner =
  'AUTO-PROPOSED by tool/parity/gen_states.mjs from specs/<screen>.md + the SCREENS ' +
  'registry. Per-state node membership: state id -> `mx-node:` keys present in that ' +
  'state (base tree, then the ordered +/- diff). SUPERSET — includes chrome ' +
  '(appbar/screen); curate down to the state-driven BODY nodes (see the curated ' +
  'dashboard.states.json). Then rename to <screen>.states.json and add a per-state ' +
  'test (review_parity_test.dart / dashboard_states_test.dart). Do NOT ship as-is.';

const wanted = only ? [only] : Object.keys(registry).sort();
let wrote = 0;
for (const screen of wanted) {
  // A curated <screen>.states.json is the source of truth (a per-state test reads
  // it) — never shadow it with a skeleton unless explicitly asked.
  if (!force && !toStdout && existsSync(join(OUT, `${screen}.states.json`))) {
    console.log(`skip ${screen}: curated ${screen}.states.json exists`);
    continue;
  }
  const specPath = join(SPECS, `${screen}.md`);
  if (!existsSync(specPath) || !registry[screen]) { console.warn(`skip ${screen}: no spec or registry entry`); continue; }
  const secs = sections(readFileSync(specPath, 'utf8'));
  const ids = registry[screen];
  const base = presentOf(secs[0] || { kind: 'base', body: '' }, new Set());
  // `mx-node:` prefix + drop shell/* chrome, matching the curated convention.
  const emit = (set) => [...set].filter((id) => !id.startsWith('shell/')).map((id) => `mx-node:${id}`).sort();
  const states = {};
  for (let i = 0; i < ids.length; i++) {
    const sec = secs[i] || { kind: 'diff', body: '' };
    states[ids[i]] = emit(i === 0 ? base : presentOf(sec, base));
  }
  const doc = { $skeleton: banner, screen, states };
  if (toStdout) { console.log(JSON.stringify(doc, null, 2)); continue; }
  writeFileSync(join(OUT, `${screen}.states.skeleton.json`), JSON.stringify(doc, null, 2) + '\n');
  console.log(`wrote contracts/${screen}.states.skeleton.json (${ids.length} states)`);
  wrote++;
}
if (!toStdout) console.log(`done: ${wrote} skeleton(s)`);
