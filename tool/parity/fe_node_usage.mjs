#!/usr/bin/env node
// tool/parity/fe_node_usage.mjs — bidirectional FE↔kit identity gate for
// data-mx-node (deterministic, no AI, no Flutter). Catches BOTH directions, the
// way the rollout wants it:
//
//   MISSING  a kit node-key (from contracts/<screen>.gen.json) that NO
//            ValueKey('mx-node:<id>') in lib/** consumes → FE must add the key.
//   ORPHAN   a ValueKey('mx-node:<id>') in lib/** that NO kit contract declares
//            → FE keyed something the kit never designed (the "thừa"/excess case).
//
// Phase 1 (keys still rolling out): MISSING dominates — add the keys until the FE
// covers every kit node. Phase 2 (keys complete): ORPHAN is what remains — FE excess
// vs the kit. Both block --check, so the gate ratchets MISSING→0 then ORPHAN→0.
//
// Kit source = tool/parity/contracts/*.gen.json (gen_parity_contract.mjs, static
// kit-JSX parse, fresh for every screen, no Chrome). Shell chrome (shell/*) is not
// emitted there, so it is out of scope by construction.
//
// Identity is SET-LEVEL: a shared id (study-session/*) rendered by one widget counts
// as consumed if it appears ANYWHERE in lib/**. The orthogonal "right key on the
// right STATE" — e.g. a card that must be ABSENT in the empty state — is NOT visible
// here (a keyed kit-node is "consumed" regardless of which state renders it); that
// state-composition check is the per-state parity widget test's job. This gate is the
// cheap always-on key-level layer; the widget test is the state-level layer.
//
// Documented FE↔kit divergences live in intent-ledger.json `exceptions`.
//
// Usage:
//   node tool/parity/fe_node_usage.mjs            # missing / orphan / exempt
//   node tool/parity/fe_node_usage.mjs --screen dashboard
//   node tool/parity/fe_node_usage.mjs --check    # exit 1 on any blocking item
//   node tool/parity/fe_node_usage.mjs --json
//
// Exit: 0 ok, 1 gate fail (--check), 2 IO error.

import { existsSync, readFileSync, readdirSync } from 'node:fs';
import { dirname, join, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';
import { PATHS } from '../_config.mjs';

const HERE = dirname(fileURLToPath(import.meta.url));
const REPO = resolve(HERE, '..', '..');
const CONTRACTS_DIR = join(HERE, 'contracts');
const LIB = join(REPO, PATHS.srcDir);

const args = process.argv.slice(2);
const opt = (n, d) => { const i = args.indexOf(n); return i >= 0 && args[i + 1] ? args[i + 1] : d; };
const onlyScreen = opt('--screen', null);
const check = args.includes('--check');
const asJson = args.includes('--json');

// --- Layer 1: kit node-keys from contracts/*.gen.json (id -> owning screens) --
const genFiles = existsSync(CONTRACTS_DIR)
  ? readdirSync(CONTRACTS_DIR).filter((f) => f.endsWith('.gen.json'))
  : [];
if (!genFiles.length) {
  console.error('fe_node_usage: no contracts/*.gen.json — run `node tool/parity/gen_parity_contract.mjs` first.');
  process.exit(2);
}
const idScreens = new Map(); // id -> Set(screen)
for (const f of genFiles) {
  const data = JSON.parse(readFileSync(join(CONTRACTS_DIR, f), 'utf8'));
  const screen = data.screen ?? f.replace(/\.gen\.json$/, '');
  for (const n of data.nodes ?? []) {
    const id = String(n.key).replace(/^mx-node:/, '');
    (idScreens.get(id) ?? idScreens.set(id, new Set()).get(id)).add(screen);
  }
}
const contractIds = new Set(idScreens.keys());

// --- Layer 2: FE consumption (id -> source files) ----------------------------
const FE_RE = /mx-node:([A-Za-z0-9][\w/-]*)/g;
function walk(dir) {
  let out = [];
  for (const d of readdirSync(dir, { withFileTypes: true })) {
    const p = join(dir, d.name);
    if (d.isDirectory()) out = out.concat(walk(p));
    else if (d.name.endsWith('.dart')) out.push(p);
  }
  return out;
}
const feLoc = new Map(); // id -> Set(relPath)
if (existsSync(LIB)) {
  for (const f of walk(LIB)) {
    const rel = f.slice(REPO.length + 1).split('\\').join('/');
    const text = readFileSync(f, 'utf8');
    let m;
    while ((m = FE_RE.exec(text))) {
      (feLoc.get(m[1]) ?? feLoc.set(m[1], new Set()).get(m[1])).add(rel);
    }
  }
}
const feIds = new Set(feLoc.keys());

// --- Documented FE↔kit exceptions (reuse the parity ledger) ------------------
// Match an id to an `exceptions` entry by node-segment (the id's last path segment,
// what the ledger's `node` names) + screen. A MISSING id needs every owning screen
// excepted (so a still-required screen keeps it blocking); an ORPHAN has no contract
// screen, so a node-segment documented as an intentional FE addition exempts it.
const LEDGER = (() => {
  try { return JSON.parse(readFileSync(join(HERE, 'intent-ledger.json'), 'utf8')); }
  catch { return {}; }
})();
const EXC = Array.isArray(LEDGER.exceptions) ? LEDGER.exceptions : [];
const seg = (id) => id.slice(id.lastIndexOf('/') + 1);
const excMatch = (screen, id) => EXC.filter(
  (e) => (!screen || e.screen === screen) && seg(id).startsWith(e.node),
);
function missingExemption(id) {
  const screens = [...(idScreens.get(id) ?? [])];
  if (!screens.length) return null;
  const hits = screens.map((s) => excMatch(s, id)[0]).filter(Boolean);
  return hits.length === screens.length ? hits[0] : null; // every owning screen excepted
}
const orphanExemption = (id) => excMatch(null, id)[0] ?? null;

// --- Classify ----------------------------------------------------------------
const missing = []; // {id, screens, exempt?}
for (const id of [...contractIds].sort()) {
  if (feIds.has(id)) continue;
  if (onlyScreen && !(idScreens.get(id) ?? new Set()).has(onlyScreen)) continue;
  missing.push({ id, screens: [...(idScreens.get(id) ?? [])].sort(), exempt: missingExemption(id) });
}
const orphan = []; // {id, files, exempt?}
for (const id of [...feIds].sort()) {
  if (contractIds.has(id)) continue;
  orphan.push({ id, files: [...(feLoc.get(id) ?? [])].sort(), exempt: orphanExemption(id) });
}

const missingBlock = missing.filter((r) => !r.exempt);
const missingExempt = missing.filter((r) => r.exempt);
const orphanBlock = orphan.filter((r) => !r.exempt);
const orphanExempt = orphan.filter((r) => r.exempt);
const blocking = missingBlock.length + orphanBlock.length;

if (asJson) {
  console.log(JSON.stringify({
    totals: {
      contractIds: contractIds.size,
      feIds: feIds.size,
      missingBlock: missingBlock.length,
      orphanBlock: orphanBlock.length,
      exempt: missingExempt.length + orphanExempt.length,
    },
    missing, orphan,
  }, null, 2));
  process.exit(check && blocking ? 1 : 0);
}

// --- Report ------------------------------------------------------------------
console.log('# data-mx-node FE↔kit usage (bidirectional, deterministic — no AI)\n');
const list = (rows, render) => rows.length ? rows.map((r) => `  - ${render(r)}`).join('\n') : '  (none)';

console.log(`## MISSING — kit node-key with no ValueKey in lib/** (${missingBlock.length})`);
console.log(list(missingBlock, (r) => `${r.id}  [${r.screens.join(', ')}]`));
console.log('');
if (!onlyScreen) {
  console.log(`## ORPHAN — ValueKey in lib/** with no kit contract node (${orphanBlock.length})`);
  console.log(list(orphanBlock, (r) => `${r.id}  @ ${r.files.join(', ')}`));
  console.log('');
}
console.log(`## EXEMPT — documented FE↔kit divergence in intent-ledger.json (${missingExempt.length + orphanExempt.length})`);
console.log(list([...missingExempt, ...orphanExempt], (r) => `${r.id}  (${r.exempt.exceptionKind}) — ${r.exempt.source}`));
console.log('');

console.log(`Summary: ${contractIds.size} kit node(s) · ${feIds.size} keyed in FE · `
  + `${missingBlock.length} missing · ${orphanBlock.length} orphan · `
  + `${missingExempt.length + orphanExempt.length} exempt.`);
console.log('Identity is set-level; per-state "right key, right state" stays with test/**/*_parity_test.dart.');

if (check && blocking) {
  console.error(`\nfe_node_usage: FAIL — ${blocking} blocking item(s) (${missingBlock.length} missing, ${orphanBlock.length} orphan). `
    + 'Key the widget in lib/**, or add a documented exception to tool/parity/intent-ledger.json.');
  process.exit(1);
}
process.exit(0);
