// Generates the UI-doc set FROM the UI kit (the source of truth), so it can never
// drift: MANIFEST.yaml (repo root) + docs/wireframes/ + docs/contracts/. Regenerate
// after any kit change:  node tool/design/gen_ui_docs.mjs   (--check verifies fresh)
//
// v1 note: the kit designs `account-sync` (Cloud sync / Account & Sync) but v1 DEFERS
// it (no remote backend) — the manifest/contracts mark it deferred, and the kit's
// settings "Cloud sync" tile renders as local Backup/Restore (or is omitted).

import { readFileSync, writeFileSync, readdirSync, mkdirSync, existsSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import path from 'node:path';

const HERE = path.dirname(fileURLToPath(import.meta.url));
const ROOT = path.resolve(HERE, '..', '..');
const KIT = path.join(ROOT, 'docs/design/MemoX Design System/ui_kits/memox-app');
const SHOTS = path.join(KIT, 'shots');
const CHECK = process.argv.includes('--check');

// Screens the kit designs but v1 defers (no remote backend). Docs mark them deferred.
const V1_DEFERRED = new Set(['account-sync']);
// Extra v1 reconciliation notes keyed by screen id.
const V1_NOTES = {
  'account-sync': 'Kit thiết kế màn Account & Sync, nhưng **v1 HOÃN** (không backend từ xa). Giữ spec để tham khảo; không build ở v1.',
  settings: 'Tile kit **Cloud sync** render ở v1 thành **Backup / Restore cục bộ** (hoặc bỏ) — account-sync hoãn.',
};

// The four bottom-nav tab screens + the center Add action (rest are pushed/overlay).
const TABS = { dashboard: 'Today', library: 'Library', statistics: 'Stats', settings: 'Profile' };

function parseIndex() {
  const md = readFileSync(path.join(KIT, 'specs/INDEX.md'), 'utf8');
  const rows = [];
  for (const ln of md.split('\n')) {
    const m = ln.match(/^\|\s*([\w-]+)\s*\|\s*(.+?)\s*\|\s*`([\w-]+)\.md`\s*\|\s*(\d+)\s*\|/);
    if (m) rows.push({ id: m[1], name: m[2], spec: m[3], stateCount: +m[4] });
  }
  return rows;
}

function statesOf(id) {
  return readdirSync(SHOTS)
    .filter((f) => f.startsWith(`${id}--`) && f.endsWith('--light.png'))
    .map((f) => f.slice(id.length + 2, -'--light.png'.length))
    .sort();
}

const hash = readFileSync(path.join(KIT, 'specs/.source-hash'), 'utf8').trim();
const screens = parseIndex().map((s) => ({ ...s, states: statesOf(s.id) }));
const totalStates = screens.reduce((n, s) => n + s.states.length, 0);

// Relative hrefs (from docs/wireframes|contracts) into the kit tree.
const shotHref = (n) => `../design/MemoX%20Design%20System/ui_kits/memox-app/shots/${n}.png`;
const specHref = (id) => `../design/MemoX%20Design%20System/ui_kits/memox-app/specs/${id}.md`;
const specPath = (id) => `docs/design/MemoX Design System/ui_kits/memox-app/specs/${id}.md`;

// ── MANIFEST.yaml ───────────────────────────────────────────────────────────────
function manifestYaml() {
  const L = [];
  L.push('# MemoX UI manifest — GENERATED from the UI kit (source of truth).');
  L.push('# Regenerate: node tool/design/gen_ui_docs.mjs   (--check gates freshness)');
  L.push('# Do NOT hand-edit — edit the kit + re-export specs, then re-run this.');
  L.push('meta:');
  L.push('  source: docs/design/MemoX Design System/ui_kits/memox-app');
  L.push(`  source_hash: ${hash}`);
  L.push(`  screens: ${screens.length}`);
  L.push(`  states: ${totalStates}`);
  L.push(`  v1_deferred: [${[...V1_DEFERRED].join(', ')}]  # kit designs it; v1 has no remote backend`);
  L.push('screens:');
  for (const s of screens) {
    L.push(`  - id: ${s.id}`);
    L.push(`    name: ${JSON.stringify(s.name)}`);
    if (TABS[s.id]) L.push(`    nav_tab: ${TABS[s.id]}`);
    if (V1_DEFERRED.has(s.id)) L.push('    v1: deferred');
    L.push(`    spec: ${JSON.stringify(specPath(s.id))}`);
    L.push(`    wireframe: docs/wireframes/${s.id}.md`);
    L.push(`    contract: docs/contracts/${s.id}.md`);
    L.push(`    states: [${s.states.join(', ')}]`);
  }
  return L.join('\n') + '\n';
}

// ── docs/wireframes/<id>.md ─────────────────────────────────────────────────────
function wireframe(s) {
  const L = [];
  L.push(`# ${s.name} — wireframe (kit)`);
  L.push('');
  L.push(`> **GENERATED** từ UI kit (nguồn chuẩn) bởi \`tool/design/gen_ui_docs.mjs\` — KHÔNG sửa tay.`);
  L.push(`> Screen \`${s.id}\` · ${s.states.length} state${TABS[s.id] ? ` · tab **${TABS[s.id]}**` : ''}.`);
  if (V1_DEFERRED.has(s.id)) L.push(`> ⊘ **v1 HOÃN** — ${V1_NOTES[s.id]}`);
  L.push(`> DOM spec chi tiết: [\`specs/${s.id}.md\`](${specHref(s.id)}).`);
  if (V1_NOTES[s.id] && !V1_DEFERRED.has(s.id)) L.push(`> ⓘ ${V1_NOTES[s.id]}`);
  L.push('');
  L.push('| state | light | dark |');
  L.push('|---|---|---|');
  for (const st of s.states) {
    const l = `<img src="${shotHref(`${s.id}--${st}--light`)}" width="200">`;
    const d = `<img src="${shotHref(`${s.id}--${st}--dark`)}" width="200">`;
    L.push(`| \`${st}\` | ${l} | ${d} |`);
  }
  return L.join('\n') + '\n';
}

// ── docs/contracts/<id>.md ──────────────────────────────────────────────────────
function contract(s) {
  const L = [];
  L.push(`# ${s.name} — UI contract (kit)`);
  L.push('');
  L.push(`> **GENERATED** từ UI kit (nguồn chuẩn). Flutter PHẢI render đủ & khớp các state dưới đây.`);
  L.push(`> Screen \`${s.id}\`${TABS[s.id] ? ` · bottom-nav tab **${TABS[s.id]}**` : ' · pushed/overlay'} · ${s.states.length} state.`);
  L.push('');
  if (V1_DEFERRED.has(s.id)) {
    L.push(`## ⊘ v1: HOÃN`);
    L.push('');
    L.push(V1_NOTES[s.id]);
    L.push('');
  } else if (V1_NOTES[s.id]) {
    L.push(`## ⓘ Ghi chú v1`);
    L.push('');
    L.push(V1_NOTES[s.id]);
    L.push('');
  }
  L.push('## States (bắt buộc khớp kit)');
  L.push('');
  for (const st of s.states) L.push(`- \`${st}\``);
  L.push('');
  L.push('## Nguồn chuẩn');
  L.push('');
  L.push(`- DOM spec (authoritative): [\`specs/${s.id}.md\`](${specHref(s.id)})`);
  L.push(`- Wireframe (ảnh từng state): [\`../wireframes/${s.id}.md\`](../wireframes/${s.id}.md)`);
  L.push(`- Shots: \`docs/design/MemoX Design System/ui_kits/memox-app/shots/${s.id}--*.png\``);
  return L.join('\n') + '\n';
}

function indexMd(kind) {
  const L = [];
  const title = kind === 'wireframes' ? 'Wireframes' : 'UI Contracts';
  L.push(`# ${title} — GENERATED từ UI kit`);
  L.push('');
  L.push(`> Nguồn chuẩn: UI kit. Regenerate: \`node tool/design/gen_ui_docs.mjs\`.`);
  L.push(`> ${screens.length} screens · ${totalStates} states. \`⊘\` = v1 hoãn.`);
  L.push('');
  L.push('| screen | name | states | doc |');
  L.push('|---|---|--:|---|');
  for (const s of screens) {
    const flag = V1_DEFERRED.has(s.id) ? ' ⊘' : '';
    L.push(`| \`${s.id}\`${flag} | ${s.name} | ${s.states.length} | [${s.id}.md](${s.id}.md) |`);
  }
  return L.join('\n') + '\n';
}

// ── Emit (or check) ─────────────────────────────────────────────────────────────
const files = { 'MANIFEST.yaml': manifestYaml() };
files['docs/wireframes/index.md'] = indexMd('wireframes');
files['docs/contracts/index.md'] = indexMd('contracts');
for (const s of screens) {
  files[`docs/wireframes/${s.id}.md`] = wireframe(s);
  files[`docs/contracts/${s.id}.md`] = contract(s);
}

if (CHECK) {
  const stale = [];
  for (const [rel, content] of Object.entries(files)) {
    const p = path.join(ROOT, rel);
    if (!existsSync(p) || readFileSync(p, 'utf8') !== content) stale.push(rel);
  }
  if (stale.length) {
    console.error(`ui-docs stale (${stale.length}): ${stale.slice(0, 5).join(', ')}${stale.length > 5 ? ' …' : ''}`);
    console.error('run: node tool/design/gen_ui_docs.mjs');
    process.exit(1);
  }
  console.log(`ui-docs fresh — ${screens.length} screens, ${totalStates} states.`);
} else {
  mkdirSync(path.join(ROOT, 'docs/wireframes'), { recursive: true });
  mkdirSync(path.join(ROOT, 'docs/contracts'), { recursive: true });
  for (const [rel, content] of Object.entries(files)) writeFileSync(path.join(ROOT, rel), content);
  console.log(`wrote ${Object.keys(files).length} files — MANIFEST.yaml + docs/wireframes/ + docs/contracts/ (${screens.length} screens, ${totalStates} states).`);
}
