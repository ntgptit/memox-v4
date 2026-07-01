#!/usr/bin/env node
// tool/parity/gen_slots.mjs — auto-PROPOSE the slot layer of the parity contract.
//
// `<screen>.gen.json` (gen_parity_contract.mjs) covers IDENTITY (data-mx-node) +
// STYLING (component + variant). The SLOT layer — which text node is which
// MxTextRole and which ARB key / data binding — is the piece NOT derivable from
// static JSX, so today it is hand-curated in `<screen>.slots.json` (only dashboard
// exists). Converting the other 21 screens to Flutter means guessing those roles
// and l10n keys per node.
//
// This tool bootstraps that: it parses the rendered DOM spec (specs/<screen>.md,
// which already resolves `font:<size>/<weight>`), groups every text node under its
// nearest keyed (`id:`) ancestor, and writes a `<screen>.slots.skeleton.json` with:
//   - role  : PROPOSED from font size+weight (a heuristic — VERIFY, esp. label vs body)
//   - font  : the raw spec value, kept so a human can correct the role
//   - text  : the mock copy (never shipped)
//   - l10n / bind : "TODO" — the curation a human/agent still fills (ARB key or
//                   domain binding). Numeric-looking copy is proposed as `bind`.
// It is a SUPERSET of the gated nodes and NEVER writes the curated `.slots.json`.
//
// Usage:
//   node tool/parity/gen_slots.mjs            # all screens -> *.slots.skeleton.json
//   node tool/parity/gen_slots.mjs --screen deck-detail
//   node tool/parity/gen_slots.mjs --stdout --screen dashboard   # print, write nothing

import { existsSync, mkdirSync, readdirSync, readFileSync, writeFileSync } from 'node:fs';
import { dirname, join, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';
import { PATHS } from '../_config.mjs';

const HERE = dirname(fileURLToPath(import.meta.url));
const REPO = resolve(HERE, '..', '..');
const SPECS = join(REPO, PATHS.uiKitDir, 'specs');
const OUT = join(HERE, 'contracts');

const args = process.argv.slice(2);
const only = args.includes('--screen') ? args[args.indexOf('--screen') + 1] : null;
const toStdout = args.includes('--stdout');
const force = args.includes('--force'); // also (re)build screens that already have a curated .slots.json
const check = args.includes('--check'); // gate: curated .slots.json must only bind nodes the spec still has

// Proposed MxTextRole from the rendered font. Size drives it; at 13px the
// weight splits label (bold caption) from body (regular). Boundaries mirror the
// MxTypography scale (xs12 sm13 base15 md17 lg20 xl24 2xl30 3xl38 4xl48).
function roleFor(size, weight) {
  if (size >= 34) return 'displayLarge';
  if (size >= 28) return 'displaySmall';
  if (size >= 20) return 'titleLarge';
  if (size >= 16) return 'titleMedium';
  if (size >= 14) return 'bodyMedium';
  if (size >= 13) return weight >= 600 ? 'labelMedium' : 'bodySmall';
  return 'labelSmall';
}

const slug = (s) =>
  s.toLowerCase().replace(/[^a-z0-9]+/g, ' ').trim().split(' ')
    .map((w, i) => (i === 0 ? w : w[0].toUpperCase() + w.slice(1))).join('').slice(0, 40);

// Copy that is all digits / punctuation / units is almost always a bound value
// (12:30, 24, 55%, 3 decks) rather than static UI copy → propose `bind` not `l10n`.
const looksDynamic = (t) => /^[\d\s:%.,+/·×–-]+$/.test(t) || /^\d/.test(t);

// Parse the base-state `text` block of a spec into flat nodes with depth, id,
// text and font. Fields (`id:`, `text:`, `style:`) attach to the last `- node:`.
function parseSpec(md) {
  const start = md.indexOf('```text');
  if (start < 0) return [];
  const block = md.slice(start + 7, md.indexOf('```', start + 7));
  const nodes = [];
  let cur = null;
  for (const raw of block.split('\n')) {
    const nodeM = raw.match(/^(\s*)- node: (.+)$/);
    if (nodeM) {
      cur = { depth: nodeM[1].length, name: nodeM[2].trim(), id: null, text: null, font: null };
      nodes.push(cur);
      continue;
    }
    if (!cur) continue;
    const fieldM = raw.match(/^\s*(id|text|style): (.+)$/);
    if (!fieldM) continue;
    if (fieldM[1] === 'id') cur.id = fieldM[2].trim();
    else if (fieldM[1] === 'text') cur.text = fieldM[2].trim();
    else if (fieldM[1] === 'style') {
      const f = fieldM[2].match(/font:(\d+(?:\.\d+)?)\/(\d+)/);
      if (f) cur.font = { size: parseFloat(f[1]), weight: parseInt(f[2], 10), raw: `${f[1]}/${f[2]}` };
    }
  }
  return nodes;
}

// Each text node's owner = nearest ancestor (incl. self) carrying an `id:`.
// Ancestors are the running stack of shallower-depth nodes.
function buildSlots(nodes) {
  const stack = [];
  const byOwner = new Map();
  for (const n of nodes) {
    while (stack.length && stack[stack.length - 1].depth >= n.depth) stack.pop();
    // owner = self if keyed, else the nearest keyed ancestor still on the stack.
    let owner = n.id;
    if (!owner) for (let i = stack.length - 1; i >= 0; i--) if (stack[i].id) { owner = stack[i].id; break; }
    stack.push(n);
    if (!n.text || !n.font || !owner) continue;
    if (n.name && n.name.startsWith('icon:')) continue; // material-symbol glyph, not a text slot
    const key = 'mx-node:' + owner;
    if (!byOwner.has(key)) byOwner.set(key, []);
    const slot = { name: slug(n.text) || `slot${byOwner.get(key).length}`, role: roleFor(n.font.size, n.font.weight), font: n.font.raw, text: n.text };
    if (looksDynamic(n.text)) slot.bind = 'TODO'; else slot.l10n = 'TODO';
    byOwner.get(key).push(slot);
  }
  return Object.fromEntries(byOwner);
}

function screensToDo() {
  const files = readdirSync(SPECS).filter((f) => f.endsWith('.md') && f !== 'INDEX.md');
  const ids = files.map((f) => f.replace(/\.md$/, ''));
  return only ? ids.filter((s) => s === only) : ids;
}

// Every `mx-node:<id>` that appears anywhere in a screen's spec (base + diffs).
function specNodeKeys(md) {
  const keys = new Set();
  for (const m of md.matchAll(/^\s*id: (.+)$/gm)) keys.add('mx-node:' + m[1].trim());
  return keys;
}

// --check: each curated <screen>.slots.json may only bind nodes the spec still has.
// Catches a slot left dangling after the kit renamed/removed a node.
if (check) {
  let stale = 0;
  for (const screen of screensToDo()) {
    const curated = join(OUT, `${screen}.slots.json`);
    if (!existsSync(curated)) continue;
    const keys = specNodeKeys(readFileSync(join(SPECS, `${screen}.md`), 'utf8'));
    for (const key of Object.keys(JSON.parse(readFileSync(curated, 'utf8')).slots || {})) {
      if (!keys.has(key)) {
        console.error(`STALE ${screen}.slots.json: binds ${key} — not in specs/${screen}.md (kit renamed/removed it?)`);
        stale++;
      }
    }
  }
  if (stale) { console.error(`slots: ${stale} dangling binding(s). Re-curate the .slots.json.`); process.exit(1); }
  console.log('slots: curated bindings fresh');
  process.exit(0);
}

if (!existsSync(OUT)) mkdirSync(OUT, { recursive: true });
const banner =
  'AUTO-PROPOSED by tool/parity/gen_slots.mjs from specs/<screen>.md. role = heuristic ' +
  'from font size+weight — VERIFY (esp. label vs body at 13px). l10n/bind = TODO: curate ' +
  '(ARB key or domain binding). Superset of gated nodes — trim to what the FE keys. ' +
  'Do NOT ship as the curated <screen>.slots.json; hand-curate from this skeleton.';

let wrote = 0;
for (const screen of screensToDo()) {
  // A curated <screen>.slots.json is the source of truth — don't shadow it with a
  // skeleton unless explicitly asked (--force, e.g. to re-validate the heuristic).
  if (!force && !toStdout && existsSync(join(OUT, `${screen}.slots.json`))) {
    console.log(`skip ${screen}: curated ${screen}.slots.json exists`);
    continue;
  }
  const md = readFileSync(join(SPECS, `${screen}.md`), 'utf8');
  const slots = buildSlots(parseSpec(md));
  const out = { $skeleton: banner, screen, slots };
  if (toStdout) { console.log(JSON.stringify(out, null, 2)); continue; }
  const file = join(OUT, `${screen}.slots.skeleton.json`);
  writeFileSync(file, JSON.stringify(out, null, 2) + '\n');
  const n = Object.values(slots).reduce((a, s) => a + s.length, 0);
  console.log(`wrote contracts/${screen}.slots.skeleton.json (${Object.keys(slots).length} nodes · ${n} slots)`);
  wrote++;
}
if (!toStdout) console.log(`done: ${wrote} skeleton(s)`);
