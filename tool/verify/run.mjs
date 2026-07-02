#!/usr/bin/env node
// @ts-check
/**
 * tool/verify/run.mjs — the single build-loop gate.
 *
 * Every WBS task runs this instead of scattered raw commands (WBS I.0). It runs
 * the strongest available checks and exits non-zero on the FIRST failure, naming
 * the step that failed.
 *
 *   node tool/verify/run.mjs           # FULL: codegen freshness + tokens + analyze + test
 *   node tool/verify/run.mjs --quick   # analyze + test only (fast, while iterating)
 *   node tool/verify/run.mjs --docs    # doc/token freshness only (gen_tokens --check)
 *
 * Steps degrade gracefully: the codegen step is skipped until `build_runner` is a
 * dependency (added in WBS I.1), so this gate is usable from I.0 onward.
 */

import { spawnSync } from 'node:child_process';
import { readFileSync } from 'node:fs';
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

const tokens = () => step('design tokens --check', 'node', ['tool/design/gen_tokens.mjs', '--check']);
const analyze = () => step('dart analyze', 'dart', ['analyze', 'lib', 'test']);
const test = () => step('flutter test', 'flutter', ['test']);

if (mode === 'docs') {
  tokens();
} else if (mode === 'quick') {
  analyze();
  test();
} else {
  codegen();
  tokens();
  analyze();
  test();
}

process.stdout.write(`\n✓ verify passed (${mode})\n`);
