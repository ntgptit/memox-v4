// verify — THE single verification entry for {{PROJECT_NAME}}.
//
// Do NOT run analyzers / linters / tests / doc_guard directly. Every step goes
// through this tool, including the inner dev loop (`--quick`). Why: a successful
// docs/code run writes a pass-marker bound to the exact content state of the
// working tree, and `.githooks/pre-commit` (via `--check-marker`) rejects
// commits whose state has no matching marker. Piecemeal runs produce no marker,
// so they cannot be committed — that is what keeps "verified" honest.
//
// The actual command chain is data, not code: edit tool/verify/verify.config.json.
// This script just sequences it, applies the marker rules, and prints one table.
//
// Usage:
//   node tool/verify/run.mjs                  # auto-detect scope from git status
//   node tool/verify/run.mjs --quick          # inner loop: fast subset, writes NO marker
//   node tool/verify/run.mjs --docs           # docs chain        -> writes docs marker
//   node tool/verify/run.mjs --code           # code chain (no slow tests) -> code marker
//   node tool/verify/run.mjs --full           # code chain + all tests     -> code marker
//   node tool/verify/run.mjs --test <a> <b>   # full chain (targeted intent recorded)
//   node tool/verify/run.mjs --check-marker   # pre-commit hook: exit 0 if tree has valid marker
//
// Exit code: 0 = every executed step passed, 1 = at least one failed/marker invalid.

import { createHash } from 'node:crypto';
import { existsSync, readFileSync, writeFileSync } from 'node:fs';
import { join, resolve, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';
import { execSync, spawnSync } from 'node:child_process';

const repoRoot = resolve(dirname(fileURLToPath(import.meta.url)), '..', '..');
const markerPath = join(repoRoot, 'tool', 'verify', '.last-pass.json');
const configPath = join(repoRoot, 'tool', 'verify', 'verify.config.json');
const args = process.argv.slice(2);
const has = (f) => args.includes(f);

if (!existsSync(configPath)) {
  console.error('verify: missing tool/verify/verify.config.json');
  process.exit(2);
}
const config = JSON.parse(readFileSync(configPath, 'utf8'));

// ── content-state hash ───────────────────────────────────────────────────────
// Identifies the exact uncommitted content of the tree, independent of staging.
// `git add` does not change it; any edit does. The marker file is excluded.
function stateHash() {
  let out = '';
  try {
    out = execSync('git status --porcelain -uall', { cwd: repoRoot, stdio: ['ignore', 'pipe', 'ignore'] }).toString();
  } catch {
    return 'no-git';
  }
  const entries = [];
  for (const line of out.split('\n').filter(Boolean)) {
    let path = line.slice(3).trim().replace(/^"|"$/g, '');
    if (path.includes(' -> ')) path = path.split(' -> ')[1];
    if (path === 'tool/verify/.last-pass.json') continue;
    const abs = join(repoRoot, path);
    let body = '';
    try { body = existsSync(abs) ? readFileSync(abs, 'utf8') : '\0deleted'; } catch { body = '\0unreadable'; }
    entries.push(path + '\0' + body);
  }
  entries.sort();
  return createHash('sha256').update(entries.join('\0\0')).digest('hex');
}

function stagedPaths() {
  try {
    return execSync('git diff --cached --name-only', { cwd: repoRoot, stdio: ['ignore', 'pipe', 'ignore'] })
      .toString().split('\n').filter(Boolean);
  } catch {
    return [];
  }
}

const isCodePath = (p) => !p.startsWith('docs/') && !p.endsWith('.md');

// ── marker handling ──────────────────────────────────────────────────────────
function readMarker() {
  try { return JSON.parse(readFileSync(markerPath, 'utf8')); } catch { return null; }
}
function writeMarker(scope) {
  writeFileSync(markerPath, JSON.stringify({ hash: stateHash(), scope, ts: new Date().toISOString() }, null, 2) + '\n');
}

if (has('--check-marker')) {
  const m = readMarker();
  const staged = stagedPaths();
  const needsCode = staged.some(isCodePath);
  if (!m) { console.error('verify: no pass-marker. Run `node tool/verify/run.mjs` before committing.'); process.exit(1); }
  if (m.hash !== stateHash()) { console.error('verify: tree changed since last PASS. Re-run verify.'); process.exit(1); }
  if (needsCode && m.scope !== 'code') { console.error('verify: staged code needs a CODE-chain PASS (got scope=' + m.scope + ').'); process.exit(1); }
  process.exit(0);
}

// ── scope resolution ─────────────────────────────────────────────────────────
let scope;
if (has('--quick')) scope = 'quick';
else if (has('--docs')) scope = 'docs';
else if (has('--full') || has('--test')) scope = 'full';
else if (has('--code')) scope = 'code';
else {
  // auto-detect: any code change -> code, else docs
  let changed = [];
  try { changed = execSync('git status --porcelain -uall', { cwd: repoRoot, stdio: ['ignore', 'pipe', 'ignore'] }).toString().split('\n').filter(Boolean).map((l) => l.slice(3).trim()); } catch {}
  scope = changed.some(isCodePath) ? 'code' : 'docs';
}

const chainName = scope === 'quick' ? 'quick' : scope === 'docs' ? 'docs' : scope === 'full' ? 'full' : 'code';
const chain = (config.chains && config.chains[chainName]) || [];

// ── run ──────────────────────────────────────────────────────────────────────
const results = [];
function run(label, cmd) {
  process.stdout.write(`▶ ${label}: ${cmd}\n`);
  const r = spawnSync(cmd, { cwd: repoRoot, shell: true, stdio: 'inherit' });
  const ok = r.status === 0;
  results.push({ label, ok });
  return ok;
}

let allOk = true;
for (const stepName of chain) {
  if (stepName === 'doc_guard') {
    allOk = run('doc_guard', config.docGuard || 'node tool/doc_guard/run.mjs check') && allOk;
    continue;
  }
  const step = config.steps && config.steps[stepName];
  if (!step) { results.push({ label: stepName, ok: false, note: 'undefined step in verify.config.json' }); allOk = false; continue; }
  allOk = run(stepName, step.cmd) && allOk;
}

if (chain.length === 0) {
  console.log(`\nverify: chain "${chainName}" is empty — fill tool/verify/verify.config.json.`);
}

// ── summary + marker ─────────────────────────────────────────────────────────
console.log('\n── verify summary ──');
for (const r of results) console.log(`  ${r.ok ? 'PASS' : 'FAIL'}  ${r.label}${r.note ? '  (' + r.note + ')' : ''}`);
console.log(`  scope=${scope} chain=${chainName}`);

if (allOk && (scope === 'docs' || scope === 'code' || scope === 'full')) {
  writeMarker(scope === 'docs' ? 'docs' : 'code');
  console.log('  marker: written');
} else if (scope === 'quick') {
  console.log('  marker: not written (quick)');
}

process.exit(allOk ? 0 : 1);
