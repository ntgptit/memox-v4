// Completeness gate for the exported DOM specs: "did export_specs capture the WHOLE
// design kit, or silently drop screens / states / nodes?". Deterministic, no Chrome.
//
// Cross-checks the generated specs/*.md against the design source at three layers:
//   1. SCREENS  — every screen in the kit gallery (index.html SCREENS array) has a spec.
//   2. STATES   — each spec has as many state sections as the kit declares for it.
//   3. NODES    — every keyed node in the parity contract (tool/parity/contracts/<id>.gen.json,
//                 derived from the kit JSX) appears as an `id:` in that screen's spec.
//
// Exit: 0 = complete, 1 = gaps found, 2 = inputs missing (run export_specs first).

import { existsSync, readFileSync, readdirSync } from 'node:fs';
import { join, resolve, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';
import { PATHS } from '../_config.mjs';

const here = dirname(fileURLToPath(import.meta.url));
const repoRoot = resolve(here, '..', '..');
const kitHtml = join(repoRoot, PATHS.kitHtml);
const specsDir = join(repoRoot, PATHS.specsDir);
const contractsDir = join(repoRoot, 'tool', 'parity', 'contracts');

if (!existsSync(kitHtml)) { console.error(`kit index.html not found: ${kitHtml}`); process.exit(2); }
if (!existsSync(specsDir)) { console.error(`specs dir not found — run export_specs first: ${specsDir}`); process.exit(2); }

// 1. Parse the kit's SCREENS array: id + declared states (the source of truth for
//    what screen×state coverage the spec set must reach).
const html = readFileSync(kitHtml, 'utf8');
const screens = [];
const reEntry = /\{\s*id:\s*'([^']+)'[^}]*?states:\s*\[([^\]]*)\]/g;
let m;
while ((m = reEntry.exec(html))) {
  const states = m[2].split(',').map((s) => s.trim().replace(/^'|'$/g, '')).filter(Boolean);
  screens.push({ id: m[1], states });
}
if (screens.length === 0) { console.error('could not parse SCREENS from index.html'); process.exit(2); }

const errors = [];
const rows = [];

for (const sc of screens) {
  const specPath = join(specsDir, `${sc.id}.md`);
  if (!existsSync(specPath)) {
    errors.push(`SCREEN missing: no spec for "${sc.id}" (${specPath})`);
    rows.push([sc.id, '—', `${sc.states.length} exp`, 'NO SPEC']);
    continue;
  }
  const spec = readFileSync(specPath, 'utf8');

  // 2. State sections: "## Base state:" + each "## State:".
  const stateSections = (spec.match(/^## (Base state|State):/gm) || []).length;
  const stateOk = stateSections === sc.states.length;
  if (!stateOk) {
    errors.push(`STATES "${sc.id}": spec has ${stateSections} state section(s), kit declares ${sc.states.length}`);
  }

  // 3. Node ids: contract keys (mx-node:<screen>/<node>) must each appear as `id:`.
  let nodeCell = 'n/a';
  const contractPath = join(contractsDir, `${sc.id}.gen.json`);
  if (existsSync(contractPath)) {
    const contract = JSON.parse(readFileSync(contractPath, 'utf8'));
    const want = (contract.nodes || []).map((n) => n.key.replace(/^mx-node:/, ''));
    // `id:` lines appear in the base tree AND in diff sections for non-base-state
    // nodes (prefixed with +/-), so allow a leading diff marker — a node captured in
    // ANY state counts as covered.
    const haveIds = new Set([...spec.matchAll(/^[+\- ]*id:\s*(\S+)/gm)].map((x) => x[1]));
    const missing = want.filter((id) => !haveIds.has(id));
    nodeCell = `${want.length - missing.length}/${want.length}`;
    if (missing.length) {
      errors.push(`NODES "${sc.id}": ${missing.length} contract node(s) absent from spec: ${missing.join(', ')}`);
    }
  }

  rows.push([sc.id, `${stateSections}/${sc.states.length}`, nodeCell, stateOk ? 'ok' : 'STATE GAP']);
}

// Extra specs not backed by a kit screen.
const specFiles = readdirSync(specsDir).filter((f) => f.endsWith('.md') && f !== 'INDEX.md');
const screenIds = new Set(screens.map((s) => s.id));
for (const f of specFiles) {
  const id = f.replace(/\.md$/, '');
  if (!screenIds.has(id)) errors.push(`EXTRA spec "${id}" has no matching kit screen`);
}

// Report.
console.log('screen'.padEnd(22), 'states'.padEnd(10), 'nodes'.padEnd(8), 'status');
console.log('-'.repeat(54));
for (const [id, st, nd, status] of rows) {
  console.log(id.padEnd(22), String(st).padEnd(10), String(nd).padEnd(8), status);
}
console.log('-'.repeat(54));
console.log(`${screens.length} kit screens · ${specFiles.length} spec files`);

if (errors.length) {
  console.error(`\n${errors.length} completeness gap(s):`);
  for (const e of errors) console.error('  - ' + e);
  process.exit(1);
}
console.log('\nspecs COMPLETE — every screen, state, and contract node is covered.');
process.exit(0);
