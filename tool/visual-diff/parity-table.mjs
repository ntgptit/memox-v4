// Regenerates docs/agent/golden-parity/PARITY-BY-STATE.md from the live kit↔golden
// diff, so the table never drifts from reality. Numbers are pulled fresh; the
// curated prose (header + per-screen notes) lives in THIS file — the single
// source. Edit NOTES/HEADER here, then re-run.
//
//   1. Regenerate goldens first (they feed the diff):
//        flutter test --tags golden-parity --update-goldens
//   2. node tool/visual-diff/parity-table.mjs   # rewrites the .md
//
// Local (Windows) renders differ a few tenths from CI ubuntu (cross-renderer AA);
// the doc says so. Run in CI or reseed baseline.json for canonical numbers.

import { execFileSync } from 'node:child_process';
import { writeFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import path from 'node:path';

const HERE = path.dirname(fileURLToPath(import.meta.url));
const ROOT = path.resolve(HERE, '..', '..');
const OUT = path.join(ROOT, 'docs', 'agent', 'golden-parity', 'PARITY-BY-STATE.md');
const THRESHOLD = '0.2';

// ── Curated prose (single source — edit here, not in the .md) ───────────────────
const HEADER = `# Visual parity — matching & lệch theo từng state

> **Tự động sinh** bởi \`node tool/visual-diff/parity-table.mjs\` từ diff kit↔golden
> (\`--threshold ${THRESHOLD}\`). **KHÔNG sửa tay** phần bảng — sửa số ⇒ regen goldens
> rồi chạy lại script; sửa prose ⇒ sửa HEADER/NOTES trong script.
> Nguồn số: render cục bộ (Windows) — CI ubuntu lệch vài phần mười (AA cross-renderer),
> chốt khi reseed \`baseline.json\`. % matching = 100 − mismatch (perceptual YIQ).
> Quy ước: \`light ≪ dark\` ⇒ overlay/scrim; \`light ≈ dark\` mà thấp ⇒ content/seed;
> \`≥ 96%\` ⇒ chỉ nhiễu AA cross-renderer (bất khả kháng).

## Đòn bẩy đã áp dụng

- **Bottom nav (shell)** — kit \`MxBottomNav\` wired vào \`_ShellScaffold\`; golden 4 tab
  render trong shell (#251). Đòn bẩy lớn nhất — kéo cả dashboard/library/statistics/settings.
- **Heatmap statistics** — seed theo công thức kit \`[0.08,0.25,0.45,0.7,1][(w*7+d*3)%5]\` (#250).
- **Move picker (deck-detail)** — kit \`Move to\` radio list + Move button; sibling/current/sub-deck
  rows (#253) → move·light 47%→88%.
- **Hạ tầng inject stats** \`FakeStore.deckStats\` — chỉ giúp khi lệch là *con số*.

## Gap còn lại đáng làm (kit-first UI, không seed được)

1. **\`SubDeckCard\` ≠ kit DeckRow**: meta "N decks · N words", badge pill due/✓, icon folder → gap chính deck-detail·loaded.
2. **drawer**: kit có FAQ/Email/Sync — v1 không backend (quyết định scope).
3. **dashboard greeting**: tên "Linh"/avatar/ngày/streak seed khác (content).
4. **statistics streak 12/28 + weekly-bars**: sample kit tự mâu thuẫn / có thể seed weekly như heatmap.
`;

// Per-screen analysis line (shown under each table). Omit ⇒ auto heuristic note.
const NOTES = {
  drawer: '**Lệch:** `remove-language` scrim; `open`/`add-language` content. **Lý do:** kit có FAQ/Email/Sync mà v1 bỏ (không backend) + scrim + AA. **Phương án:** quyết định scope v1; nền overlay có thể mask.',
  dashboard: '**Lệch:** khối nội dung (greeting/tên/ngày/streak/continue-deck). **Lý do:** seed khác kit ("Linh"/avatar/số). `empty` = onboarding hero. **Phương án:** contentMask greeting+ngày hoặc seed cố định.',
  'deck-detail': '**Lệch:** overlay confirm (`*-confirm` scrim); `loaded` = **`SubDeckCard` ≠ kit DeckRow** (meta/badge/icon). Move đã fix (#253). **Phương án:** kit-first rework `SubDeckCard` — đòn bẩy chính còn lại.',
  'study-session': '**Lệch:** `exit`/`answer-save-error` scrim; stage = content giữa phiên (từ Hàn đã render). **Phương án:** chấp nhận (content).',
  statistics: '**Lệch:** `loaded`/`scope-switch` light < dark → weekly-bars + streak + overview. **Lý do:** heatmap đã khớp; streak 12/28 không seed đồng thời (sample kit mâu thuẫn). **Phương án:** seed weekly-bars theo pattern kit.',
  library: '**Lệch:** menu/sheet scrim; `loaded`/`empty` = danh sách deck + language pair seed khác. **Phương án:** seed danh sách khớp / mask nền.',
  settings: '**Lệch:** row seed + nhóm v1 khác kit + AA. **Phương án:** align seed / quyết định mục v1.',
  'game-picker': '**Lệch:** dropdown scrim + danh sách deck/scope seed khác. **Phương án:** seed khớp / chấp nhận.',
  theme: '**Lệch:** preview card content + AA (6 accent đã khớp). **Phương án:** chấp nhận.',
  reminder: '**Lệch:** nhãn giờ seed khác nhẹ + AA (chips ngày đã fix). **Phương án:** chấp nhận.',
  search: '**Lệch:** chỉ AA (query/kết quả seed khác nhẹ). **Phương án:** không cần.',
};

// ── Pull live numbers ───────────────────────────────────────────────────────────
function runDiff() {
  const out = execFileSync(
    'node',
    ['tool/visual-diff/diff.mjs', '--threshold', THRESHOLD, '--limit', '500'],
    { cwd: ROOT, encoding: 'utf8' },
  );
  const data = {}; // screen -> state -> {light, dark}
  for (const line of out.split('\n')) {
    const m = line.match(/([0-9.]+)%.*?([\w-]+)--(light|dark)\.png\s*$/);
    if (!m) continue;
    const match = 100 - parseFloat(m[1]);
    const full = m[2];
    const i = full.indexOf('--');
    if (i < 0) continue;
    const screen = full.slice(0, i);
    const state = full.slice(i + 2);
    ((data[screen] ??= {})[state] ??= {})[m[3]] = match;
  }
  return data;
}

// Auto note when a screen has no curated NOTES entry.
function heuristicNote(states) {
  const vals = Object.values(states).flatMap((s) => [s.light, s.dark].filter((v) => v != null));
  const min = Math.min(...vals);
  if (min >= 96) return '**Lệch:** chỉ nhiễu AA cross-renderer. **Phương án:** không cần.';
  const scrim = Object.values(states).some((s) => s.light != null && s.dark != null && s.dark - s.light > 20);
  if (scrim) return '**Lệch:** overlay/scrim phủ nền + content seed khác. **Phương án:** seed khớp kit / mask nền overlay.';
  return '**Lệch:** content/seed khác kit + AA. **Phương án:** align seed hoặc chấp nhận (content).';
}

function build(data) {
  const screens = Object.entries(data).map(([screen, states]) => {
    const vals = Object.values(states).flatMap((s) => [s.light, s.dark].filter((v) => v != null));
    const avg = vals.reduce((a, b) => a + b, 0) / vals.length;
    return { screen, states, avg };
  });
  screens.sort((a, b) => a.avg - b.avg);

  const all = screens.flatMap((s) => Object.values(s.states)).flatMap((s) => [s.light, s.dark].filter((v) => v != null));
  const mean = all.reduce((a, b) => a + b, 0) / all.length;
  const stateCount = screens.reduce((n, s) => n + Object.keys(s.states).length, 0);

  const parts = [HEADER.trimEnd()];
  parts.push(`\n**Tổng thể: mean ${mean.toFixed(1)}% match** · ${screens.length} screens · ${stateCount} states (× light/dark).\n\n---`);

  for (const { screen, states, avg } of screens) {
    parts.push(`\n## \`${screen}\` — avg ${avg.toFixed(1)}%\n`);
    parts.push('| state | light | dark |');
    parts.push('|---|--:|--:|');
    const sorted = Object.entries(states).sort((a, b) => (a[1].light ?? 100) - (b[1].light ?? 100));
    for (const [state, t] of sorted) {
      const f = (v) => (v == null ? '—' : `${v.toFixed(1)}%`);
      parts.push(`| \`${state}\` | ${f(t.light)} | ${f(t.dark)} |`);
    }
    parts.push('');
    parts.push(NOTES[screen] ?? heuristicNote(states));
  }
  return parts.join('\n') + '\n';
}

const data = runDiff();
writeFileSync(OUT, build(data));
const n = Object.values(data).reduce((a, s) => a + Object.keys(s).length, 0);
console.log(`Wrote ${path.relative(ROOT, OUT)} — ${Object.keys(data).length} screens, ${n} states.`);
