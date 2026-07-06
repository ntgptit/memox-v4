#!/usr/bin/env node
// @ts-check
/**
 * kit_guard.mjs — K.6: no-raw-values guard for the design kit.
 *
 * After K.1 tokenized every dimension/color/duration in `components.css`,
 * this guard keeps it that way: any CSS declaration carrying a raw px / hex
 * color / duration that is not `0`, not a `var(--memox-*)` reference, and not
 * explicitly whitelisted with a `raw-ok: <reason>` comment on the same line
 * FAILS the gate. New magic values cannot silently re-enter the kit.
 *
 * Usage:  node tool/design/kit_guard.mjs        (exit 1 on violations)
 */

import { readFileSync } from 'node:fs';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';

const REPO = join(dirname(fileURLToPath(import.meta.url)), '..', '..');
const CSS = join(REPO, 'docs', 'design', 'MemoX Design System', 'components.css');

const src = readFileSync(CSS, 'utf8');
const lines = src.split('\n');

/** Values that are structural, not design decisions. */
const BENIGN = [
  /^0$/, // zero needs no token
  /^100%$/, /^50%$/, // full/half extents
  /^1$/, /^-1$/, // z-index steps / opacity 1
];

const violations = [];
let inComment = false;
for (let i = 0; i < lines.length; i++) {
  const raw = lines[i];
  // Track /* ... */ block comments so commented-out CSS never trips the guard.
  let line = raw;
  if (inComment) {
    const end = line.indexOf('*/');
    if (end === -1) continue;
    line = line.slice(end + 2);
    inComment = false;
  }
  // Strip inline comments (keeping raw-ok detection from the ORIGINAL line).
  const rawOk = /raw-ok:/.test(raw);
  line = line.replace(/\/\*[\s\S]*?\*\//g, '');
  if (/\/\*/.test(line)) {
    inComment = true;
    line = line.slice(0, line.indexOf('/*'));
  }
  // Only declarations (prop: value;) matter.
  const decl = line.match(/^\s*[a-z-]+\s*:\s*(.+);?\s*$/);
  if (!decl || rawOk) continue;
  const value = decl[1];
  // Remove sanctioned var() references, then hunt for leftovers.
  const residue = value.replace(/var\(--memox-[a-z0-9-]+\)/g, '');
  const offenders = [];
  for (const m of residue.matchAll(/-?\d*\.?\d+(px|ms|s\b)|#[0-9a-fA-F]{3,8}\b|rgba?\([^)]*\)|cubic-bezier\([^)]*\)/g)) {
    const v = m[0];
    if (BENIGN.some((re) => re.test(v))) continue;
    // `0px`-style zeros and percentage-free numbers are fine; anything else isn't.
    if (/^-?0(px|ms|s)?$/.test(v)) continue;
    offenders.push(v);
  }
  if (offenders.length) {
    violations.push(`components.css:${i + 1}  ${raw.trim()}  ->  [${offenders.join(', ')}]`);
  }
}

if (violations.length) {
  console.error(`✗ kit_guard: ${violations.length} raw value(s) in components.css — use a token or annotate \`/* raw-ok: reason */\` on the line:`);
  for (const v of violations) console.error('  ' + v);
  process.exit(1);
}
console.log('✓ kit_guard: components.css is fully token-driven (raw-ok whitelist respected)');
