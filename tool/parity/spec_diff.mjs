// spec_diff — compare design-kit-intended style vs FE-rendered style, per mx-node.
//
// Token-aware, NO pixels: the kit `specs/<screen>.md` carries each node's intended
// style (bg:<token> font:<size>/<weight> color:<token> r:<radius>); the FE exporter
// (test/parity/fe_spec_export_test.dart) writes the SAME fields measured from the
// real Flutter render tree to `fe-specs/<screen>.json`. We align by mx-node id and
// diff only the fields the kit declares for that node — so colours/sizes are
// compared as TOKEN NAMES + numbers (renderer-independent), not raw pixels.
//
// Usage:  node tool/parity/spec_diff.mjs <screen> [--check]
//   --check : exit 1 on any blocking mismatch (gate mode)
//
// Exit: 0 ok, 1 mismatch (with --check), 2 IO error.
import { readFileSync, existsSync } from 'node:fs';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';

const HERE = dirname(fileURLToPath(import.meta.url));
const KIT_SPECS = join(HERE, '..', '..', 'docs', 'design', 'MemoX Design System', 'ui_kits', 'memox-app', 'specs');
const FE_SPECS = join(HERE, 'fe-specs');

const args = process.argv.slice(2);
const check = args.includes('--check');
const screen = args.find((a) => !a.startsWith('--'));
if (!screen) {
  console.error('usage: node tool/parity/spec_diff.mjs <screen> [--check]');
  process.exit(2);
}

// --- parse the kit spec: per mx-node id, aggregate the style bits in its block ---
// A node "block" = the `id:` line plus the following lines until the NEXT `id:`
// line (captures the node's own `style:` and its immediate text children's bits,
// matching the FE's flat per-node aggregation).
function parseKit(file) {
  const text = readFileSync(file, 'utf8');
  const lines = text.split(/\r?\n/);
  const out = new Map(); // id -> {bg,color,font,r}
  let cur = null;
  const STYLE = /\b(bg|color):([\w-]+|#[0-9a-fA-F]+)|\bfont:([\d.]+)\/(\d+)?|\br:(\d+)/g;
  for (const line of lines) {
    const idm = line.match(/\bid:\s*([\w-]+\/[\w-]+)/);
    if (idm) {
      cur = idm[1];
      if (!out.has(cur)) out.set(cur, { bg: null, color: null, font: null, r: null });
      continue;
    }
    if (!cur) continue;
    let m;
    const rec = out.get(cur);
    while ((m = STYLE.exec(line)) !== null) {
      if (m[1] === 'bg' && rec.bg === null) rec.bg = m[2];
      else if (m[1] === 'color' && rec.color === null) rec.color = m[2];
      else if (m[3] && rec.font === null) rec.font = `${Math.round(parseFloat(m[3]))}/${m[4] ?? ''}`;
      else if (m[5] && rec.r === null) rec.r = m[5];
    }
  }
  return out;
}

function loadFe(file) {
  const arr = JSON.parse(readFileSync(file, 'utf8'));
  const out = new Map();
  for (const n of arr) out.set(n.id, n);
  return out;
}

const kitFile = join(KIT_SPECS, `${screen}.md`);
const feFile = join(FE_SPECS, `${screen}.json`);
if (!existsSync(kitFile)) { console.error(`no kit spec: ${kitFile}`); process.exit(2); }
if (!existsSync(feFile)) { console.error(`no FE spec: ${feFile} — run test/parity/fe_spec_export_test.dart first`); process.exit(2); }

const kit = parseKit(kitFile);
const fe = loadFe(feFile);

// documented per-node style divergences (intent-ledger.json → styleExempt)
let styleExempt = [];
try {
  const ledger = JSON.parse(readFileSync(join(HERE, 'intent-ledger.json'), 'utf8'));
  styleExempt = ledger.styleExempt ?? [];
} catch { /* no ledger */ }
const seg = (id) => id.slice(id.indexOf('/') + 1);
function exemptField(id, field) {
  return styleExempt.some(
    (e) => e.screen === screen
      && (e.node === '*' || seg(id).startsWith(e.node))
      && (e.field === '*' || e.field === field),
  );
}

// Compare font/icon SIZE only (weight is illustrative in the FE when inherited),
// with a ±2 tolerance that absorbs glyph-metric / kit token-vs-render deviation
// (e.g. the icon-size-md token is 22 but the kit render measures 24).
function fontEq(kf, ff) {
  if (!kf || !ff) return kf === ff || !kf;
  const ks = parseFloat(kf.split('/')[0]);
  const fs = parseFloat(ff.split('/')[0]);
  return Math.abs(ks - fs) <= 2;
}

console.log(`# spec_diff — ${screen} (kit intended vs FE rendered, per mx-node)\n`);
let mismatches = 0;
let compared = 0;
const ids = [...fe.keys()].filter((id) => kit.has(id)).sort();
for (const id of ids) {
  const k = kit.get(id);
  const f = fe.get(id);
  const diffs = [];
  // only compare a field when the kit declares it for this node.
  // kit bg:bg = the page background; a node that doesn't paint its own fill (FE ∅)
  // correctly inherits it — not a divergence.
  const bgInherits = k.bg === 'bg' && (f.bg === null || f.bg === undefined);
  if (k.bg && k.bg !== f.bg && !bgInherits && !exemptField(id, 'bg')) diffs.push(`bg: kit ${k.bg} vs FE ${f.bg ?? '∅'}`);
  if (k.color && k.color !== f.color && !exemptField(id, 'color')) diffs.push(`color: kit ${k.color} vs FE ${f.color ?? '∅'}`);
  if (k.font && !fontEq(k.font, f.font) && !exemptField(id, 'font')) diffs.push(`font: kit ${k.font} vs FE ${f.font ?? '∅'}`);
  // radii >= 999 are both "fully rounded" (pill) — treat as equivalent.
  const rEq = k.r === f.r || (parseInt(k.r, 10) >= 999 && parseInt(f.r ?? '0', 10) >= 999);
  if (k.r && !rEq && !exemptField(id, 'r')) diffs.push(`r: kit ${k.r} vs FE ${f.r ?? '∅'}`);
  compared++;
  const exemptNode = exemptField(id, '*');
  if (diffs.length === 0 && exemptNode && (k.bg !== f.bg || k.color !== f.color)) {
    console.log(`  EXEMPT ${id}  (documented style divergence)`);
  } else if (diffs.length === 0) {
    const got = [k.bg && `bg:${f.bg}`, k.color && `color:${f.color}`, k.font && `font:${f.font}`, k.r && `r:${f.r}`].filter(Boolean).join(' ');
    console.log(`  OK    ${id}  ${got || '(no style fields declared)'}`);
  } else {
    mismatches++;
    console.log(`  DIFF  ${id}`);
    for (const d of diffs) console.log(`          - ${d}`);
  }
}

const kitOnly = [...kit.keys()].filter((id) => !fe.has(id) && id.startsWith(`${screen}/`));
console.log(`\nSummary: ${compared} node(s) compared · ${mismatches} mismatch · ${kitOnly.length} kit node(s) not in FE spec (state not exported).`);
if (check && mismatches > 0) process.exit(1);
