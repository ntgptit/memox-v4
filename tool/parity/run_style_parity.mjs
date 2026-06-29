// run_style_parity — regenerate FE style specs then diff each DONE screen against
// the kit spec (tool/parity/spec_diff.mjs). Wraps the env + per-screen --check so
// verify can gate STYLE parity (colour/size/radius), not just node identity.
//
// Add a screen here once its export harness exists in
// test/parity/fe_spec_export_test.dart AND `spec_diff <screen> --check` is clean.
//
// Usage: node tool/parity/run_style_parity.mjs        (gate: exit 1 on any diff)
import { spawnSync } from 'node:child_process';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

const HERE = dirname(fileURLToPath(import.meta.url));
const repoRoot = join(HERE, '..', '..');

// Screens with a render harness + clean style parity. Append as the loop advances.
const SCREENS = ['library', 'search', 'reminder', 'theme', 'settings', 'statistics', 'flashcard-editor', 'export', 'import', 'deck-detail', 'study-session', 'review', 'player', 'study-result', 'game-picker', 'game-matching', 'game-mc', 'game-recall', 'game-typing'];

function sh(cmd, args, env) {
  const r = spawnSync(cmd, args, { cwd: repoRoot, shell: true, stdio: 'inherit', env: { ...process.env, ...env } });
  return r.status === 0;
}

// 1) regenerate fe-specs/<screen>.json for every harness in the export test
if (!sh('flutter', ['test', 'test/parity/fe_spec_export_test.dart'], { MEMOX_EXPORT_SPEC: '1' })) {
  console.error('style_parity: FE spec export failed');
  process.exit(1);
}

// 2) diff each done screen (gate)
let ok = true;
for (const screen of SCREENS) {
  if (!sh('node', ['tool/parity/spec_diff.mjs', screen, '--check'])) ok = false;
}
process.exit(ok ? 0 : 1);
