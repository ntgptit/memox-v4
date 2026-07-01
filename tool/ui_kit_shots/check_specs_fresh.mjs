// Fails when any UI-kit SOURCE input (index.html, screen *.jsx, kit-helpers.jsx,
// components.css, styles.css, tokens/**, components/**) changed but the DOM specs
// were not re-exported — so generated specs never silently lag the source they
// describe. Pure file-hash compare (see source_hash.mjs): needs neither Chrome
// nor network, so it is safe to run in every `tool/verify/run.mjs` chain.
// Regenerating the specs is what needs Chrome (see export_specs.mjs).
//
// Exit: 0 = fresh (or no baseline yet — first export pending), 1 = STALE.

import { existsSync, readFileSync } from 'node:fs';
import { join, resolve, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';
import { PATHS } from '../_config.mjs';
import { computeUiKitSourceHash } from './source_hash.mjs';

const here = dirname(fileURLToPath(import.meta.url));
const repoRoot = resolve(here, '..', '..');
const kitDir = join(repoRoot, PATHS.uiKitDir);
const kitHtml = join(kitDir, 'index.html');
const hashFile = join(kitDir, 'specs', '.source-hash');

if (!existsSync(kitHtml)) {
  console.log('ui-kit: index.html not found — skip');
  process.exit(0);
}
if (!existsSync(hashFile)) {
  console.warn('ui-kit specs: no .source-hash baseline yet — run `cd tool/ui_kit_shots && npm run export:specs`');
  process.exit(0);
}

const current = computeUiKitSourceHash();
const stored = readFileSync(hashFile, 'utf8').trim();

if (current !== stored) {
  console.error('ui-kit specs STALE: UI-kit source changed since the last export.');
  console.error('Re-export so specs (and shots) match the source:');
  console.error('  cd tool/ui_kit_shots && npm run export:all');
  process.exit(1);
}

console.log('ui-kit specs: fresh');
process.exit(0);
