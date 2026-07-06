#!/usr/bin/env node
// @ts-check
/**
 * tool/verify/run.mjs — the single build-loop gate.
 *
 * Every WBS task runs this instead of scattered raw commands (WBS I.0). It runs
 * the strongest available checks and exits non-zero on the FIRST failure, naming
 * the step that failed.
 *
 *   node tool/verify/run.mjs           # FULL: codegen + tokens + analyze + code guard + test
 *   node tool/verify/run.mjs --quick   # analyze + test only (fast, while iterating)
 *   node tool/verify/run.mjs --docs    # doc/token freshness only (gen_tokens --check)
 *
 * Steps degrade gracefully: the codegen step is skipped until `build_runner` is a
 * dependency (added in WBS I.1), so this gate is usable from I.0 onward.
 */

import { spawnSync } from 'node:child_process';
import { existsSync, readFileSync } from 'node:fs';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';

const REPO = join(dirname(fileURLToPath(import.meta.url)), '..', '..');
const argv = new Set(process.argv.slice(2));
const mode = argv.has('--quick') ? 'quick' : argv.has('--docs') ? 'docs' : 'full';

/** Run a command; on non-zero exit, fail the gate naming the step. */
function step(name, cmd, args) {
  process.stdout.write(`▶ ${name}: ${cmd} ${args.join(' ')}\n`);
  const res = spawnSync(cmd, args, { cwd: REPO, stdio: 'inherit', shell: process.platform === 'win32' });
  if (res.status === 0) return;
  fail(name, res.status == null ? `could not run \`${cmd}\` (${res.error?.message || 'not found'})` : `exit ${res.status}`);
}

function fail(name, why) {
  console.error(`\n✗ verify failed at: ${name} — ${why}`);
  process.exit(1);
}

function pubspecHasBuildRunner() {
  try {
    return /(^|\n)\s*build_runner\s*:/.test(readFileSync(join(REPO, 'pubspec.yaml'), 'utf8'));
  } catch {
    return false;
  }
}

// Generated files (*.g.dart / *.drift.dart / *.freezed.dart) are gitignored, so
// they must be (re)built before analyze/test can see them. Running build_runner
// here also fails the gate if codegen itself breaks. Skipped until build_runner
// is a dependency (pre-I.1).
function codegen() {
  if (!pubspecHasBuildRunner()) {
    process.stdout.write('• codegen: build_runner not a dependency yet — skipping (pre-I.1)\n');
    return;
  }
  step('codegen (build_runner)', 'dart', ['run', 'build_runner', 'build', '--delete-conflicting-outputs']);
}

// Generated localizations (AppLocalizations) are gitignored, so regenerate them
// from the ARB before analyze/test can see them. Skipped until l10n.yaml exists.
function l10n() {
  if (!existsSync(join(REPO, 'l10n.yaml'))) return;
  step('l10n (flutter gen-l10n)', 'flutter', ['gen-l10n']);
}

// code-verification-guard-v2 is a separate, gitignored tooling repo. When it is
// checked out beside the app (local dev, the loop, and CI once it clones the repo),
// run its memox-v4 ruleset as a blocking gate (its `local`/`ci` profiles fail on
// warnings too); when it or Python is absent, skip with a notice so the rest of the
// gate still runs everywhere. The ruleset must be memox-v4 (the V4 app), not memox.
// Pick the interpreter that can actually load the guard (its deps — typer +
// pyyaml — importable), not merely one that exists: a machine may have several
// pythons with the deps installed in only one. Probe with `run.py --help`, which
// exits 0 iff the imports succeed (and, unlike `-c "import …"`, has no spaces in
// its args, so it survives shell:true arg-flattening on Windows). `python` first
// (CI's setup-python provides it; the deps are pip-installed there).
function guardPython() {
  for (const c of ['python', 'python3']) {
    const r = spawnSync(c, ['code-verification-guard-v2/guard/run.py', '--help'], {
      cwd: REPO,
      stdio: 'ignore',
      shell: process.platform === 'win32',
    });
    if (r.status === 0) return c;
  }
  return null;
}

function guard() {
  if (!existsSync(join(REPO, 'code-verification-guard-v2', 'guard', 'run.py'))) {
    process.stdout.write('• code guard: code-verification-guard-v2 not checked out — skipping\n');
    return;
  }
  const py = guardPython();
  if (!py) {
    process.stdout.write('• code guard: no python with typer+pyyaml — skipping (pip install -r code-verification-guard-v2/requirements.txt)\n');
    return;
  }
  step('code guard (memox-v4)', py, [
    'code-verification-guard-v2/guard/run.py',
    'check', '--project', '.', '--ruleset', 'memox-v4',
  ]);
}

const tokens = () => step('design tokens --check', 'node', ['tool/design/gen_tokens.mjs', '--check']);
// K.6: components.css must stay fully token-driven (raw px/hex/duration need a
// `raw-ok:` annotation) — new magic values cannot silently re-enter the kit.
const kitGuard = () => step('kit guard (no raw values)', 'node', ['tool/design/kit_guard.mjs']);
// golden-parity coverage: every screen-state-matrix state must have a fixture
// stub (scaffolder), and no orphans. Cheap; keeps the golden skeleton complete.
const goldenScaffold = () => step('golden scaffold --check', 'node', ['tool/golden/scaffold.mjs', '--check']);
// props parity: each kit component's .d.ts contract vs its Flutter constructor.
// --strict exits non-zero on any undeclared drift (every intentional divergence
// must be a typed exception in props-parity.exceptions.json). Blocking as of Z.0.
const propsParity = () => step('props parity --strict', 'node', ['tool/parity/props_check.mjs', '--strict']);
const analyze = () => step('dart analyze', 'dart', ['analyze', 'lib', 'test']);
// The golden-parity screen goldens are tagged and excluded here during build-out
// (fail-by-default fixture stubs shouldn't block the gate; a dedicated CI job owns
// their baselines — golden-parity WBS Đ-G-5). Coverage stays enforced by the
// scaffold --check step above.
const test = () => step('flutter test', 'flutter', ['test', '--exclude-tags', 'golden-parity']);

if (mode === 'docs') {
  tokens();
  kitGuard();
  goldenScaffold();
  propsParity();
} else if (mode === 'quick') {
  analyze();
  test();
} else {
  codegen();
  l10n();
  tokens();
  kitGuard();
  goldenScaffold();
  propsParity();
  analyze();
  guard();
  test();
}

process.stdout.write(`\n✓ verify passed (${mode})\n`);
