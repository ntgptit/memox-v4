// _config.mjs — the single loader for project-specific paths used across tool/.
//
// Reads tool/tool.config.json and derives the full set of repo-root-relative
// paths (forward slashes). Every tool imports PATHS from here instead of
// hardcoding `lib/...` or `docs/system-design/MemoX Design System/...`, so
// retargeting the toolchain to a new project layout is a one-file edit.
//
// Usage from a tool at tool/<group>/foo.mjs:
//   import { PATHS, abs, repoRoot } from '../_config.mjs';
//   const specs = abs(PATHS.specsDir);   // absolute path for fs ops
//   walk(join(repoRoot, PATHS.srcDir));  // PATHS.* are rel strings

import { readFileSync } from 'node:fs';
import { resolve, dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

// tool/_config.mjs -> repo root is one level up from tool/.
export const repoRoot = resolve(dirname(fileURLToPath(import.meta.url)), '..');

// Strip a leading UTF-8 BOM — Windows editors (and PowerShell `-Encoding utf8`)
// often add one, and JSON.parse rejects it.
const raw = JSON.parse(readFileSync(join(repoRoot, 'tool', 'tool.config.json'), 'utf8').replace(/^﻿/, ''));

const srcDir = raw.srcDir ?? 'lib';
const docsDir = raw.docsDir ?? 'docs';
const designSystemDir = raw.designSystemDir ?? 'docs/system-design/Design System';
const themeDir = `${srcDir}/${raw.themeSubdir ?? 'core/theme'}`;
const uiKitDir = `${designSystemDir}/${raw.uiKitSubdir ?? 'ui_kits/mobile'}`;

// All values are repo-root-relative with forward slashes; join(repoRoot, x) or
// abs(x) turns them into OS-correct absolute paths.
export const PATHS = Object.freeze({
  srcDir,
  docsDir,
  designSystemDir,
  themeDir,
  colorsDart: `${themeDir}/mx_colors.dart`,
  tokensCss: `${designSystemDir}/colors_and_type.css`,
  uiKitDir,
  kitHtml: `${uiKitDir}/index.html`,
  shotsDir: `${uiKitDir}/shots`,
  specsDir: `${uiKitDir}/specs`,
});

// Absolute path from a repo-root-relative one (or a PATHS value).
export const abs = (rel) => join(repoRoot, rel);
