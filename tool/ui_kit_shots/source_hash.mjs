// Deterministic, OS-stable sha256 over every UI-kit SOURCE input — so the
// freshness guard covers JSX / helpers / CSS / tokens / components, not just
// index.html. Shared by export_specs.mjs (writes the baseline) and
// check_specs_fresh.mjs (compares against it) so both sides hash identically.
//
// Inputs (generated outputs are intentionally excluded):
//   <uiKitDir>/index.html
//   <uiKitDir>/*.jsx            (screens + kit-helpers.jsx; top-level only)
//   <designSystemDir>/components.css
//   <designSystemDir>/styles.css
//   <designSystemDir>/tokens/**       (recursive)
//   <designSystemDir>/components/**    (recursive)
// Excluded: <uiKitDir>/specs/** and <uiKitDir>/shots/** (generated), plus
// anything not in the list above (fonts, uploads, screenshots, the bundle…).
//
// Determinism: repo-relative paths normalised to "/" separators, sorted
// lexicographically, then path + content folded into one hash. Node built-ins
// only — no dependency, so it is safe in every verify chain.

import { createHash } from 'node:crypto';
import { existsSync, readFileSync, readdirSync, statSync } from 'node:fs';
import { join, resolve, relative } from 'node:path';
import { PATHS, repoRoot } from '../_config.mjs';

const kitDir = join(repoRoot, PATHS.uiKitDir);
// <designSystemDir> is two levels up from the kit dir (…/ui_kits/<kit>).
const designRoot = resolve(kitDir, '..', '..');

function walk(dir, acc) {
  if (!existsSync(dir)) return acc;
  for (const name of readdirSync(dir)) {
    const full = join(dir, name);
    if (statSync(full).isDirectory()) walk(full, acc);
    else acc.push(full);
  }
  return acc;
}

function topLevelFiles(dir, ext) {
  if (!existsSync(dir)) return [];
  return readdirSync(dir)
    .map((name) => join(dir, name))
    .filter((p) => statSync(p).isFile() && p.endsWith(ext));
}

const toRel = (abs) => relative(repoRoot, abs).split(/[\\/]/).join('/');

/** The sorted, de-duplicated list of UI-kit source files ({ rel, abs }). */
export function uiKitSourceFiles() {
  const candidates = [
    join(kitDir, 'index.html'),
    ...topLevelFiles(kitDir, '.jsx'), // every screen module + kit-helpers.jsx
    join(designRoot, 'components.css'),
    join(designRoot, 'styles.css'),
    ...walk(join(designRoot, 'tokens'), []),
    ...walk(join(designRoot, 'components'), []),
  ];

  const seen = new Set();
  const out = [];
  for (const abs of candidates) {
    if (!existsSync(abs)) continue;
    const rel = toRel(abs);
    if (seen.has(rel)) continue;
    seen.add(rel);
    out.push({ rel, abs });
  }
  out.sort((a, b) => (a.rel < b.rel ? -1 : a.rel > b.rel ? 1 : 0));
  return out;
}

/** Deterministic sha256 hex of all UI-kit source inputs. */
export function computeUiKitSourceHash() {
  const hash = createHash('sha256');
  for (const { rel, abs } of uiKitSourceFiles()) {
    hash.update(rel);
    hash.update('\0');
    hash.update(readFileSync(abs));
    hash.update('\0');
  }
  return hash.digest('hex');
}
