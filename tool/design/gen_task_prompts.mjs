#!/usr/bin/env node
// @ts-check
/**
 * gen_task_prompts.mjs — emit one self-contained loop prompt per WBS task.
 *
 * For every task in the WBS (docs/project-management/wbs.md) this writes a
 * tailored `docs/agent/build/<id>-<slug>.md` that a Claude Code `/loop` can pick
 * up and execute end-to-end, plus a `README.md` queue with tick boxes. The
 * prompts tell the loop WHERE to read (kit .d.ts/.prompt.md/.jsx + component
 * CSS) and WHAT to produce + HOW to verify — the per-item tailoring happens at
 * execution time by reading the real kit source, so the prompt can't drift from
 * the kit the way a pre-baked structure would.
 *
 * Registry below is the machine source for the queue; wbs.md is the narrative.
 * Regenerate: node tool/design/gen_task_prompts.mjs
 */

import { writeFileSync, mkdirSync, readdirSync, rmSync } from 'node:fs';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';

const REPO = join(dirname(fileURLToPath(import.meta.url)), '..', '..');
const OUT = join(REPO, 'docs', 'agent', 'build');
const KIT = 'docs/design/MemoX Design System';

// ── registry (mirrors docs/project-management/wbs.md) ───────────────────────
/** @typedef {{id:string,title:string,type:'foundation'|'component'|'screen'|'verify',size:string,deps:string,goal:string,inputs:string[],outputs:string[],notes?:string[]}} Task */

const CORE = 'lib/presentation/shared/widgets/core';
const SURF = 'lib/presentation/shared/widgets/surfaces';
const NAV = 'lib/presentation/shared/widgets/navigation';
const FB = 'lib/presentation/shared/widgets/feedback';
const kc = (p) => `${KIT}/components/${p}`; // kit component path helper

/** @type {Task[]} */
const FOUNDATION = [
  { id: 'F.1', title: 'Folder layout scaffold', type: 'foundation', size: 'S', deps: '—',
    goal: 'Create the lib/ directory skeleton that mirrors the kit, with barrel files only (no logic).',
    inputs: ['docs/project-management/wbs.md §Layout'],
    outputs: [`${CORE}/`, `${SURF}/`, `${NAV}/`, `${FB}/`, 'lib/presentation/features/', 'lib/l10n/'],
    notes: ['Empty dirs need a placeholder (barrel .dart or .gitkeep). No widgets yet — just the tree + barrels.'] },
  { id: 'F.2', title: 'Font wiring (Plus Jakarta Sans)', type: 'foundation', size: 'S', deps: 'F.1',
    goal: 'Register the variable font so MxTypography.fontFamily renders real glyphs.',
    inputs: [`${KIT}/fonts/PlusJakartaSans[wght].ttf`, `${KIT}/tokens/typography.css (@font-face, weights 200–800)`, 'pubspec.yaml'],
    outputs: ['pubspec.yaml (fonts:)', 'lib/fonts/ or assets ref'],
    notes: ['Variable font: one file, weights 400–800 used. Confirm bold/extrabold render distinctly in a golden.'] },
  { id: 'F.3', title: 'Theme assembly (ThemeData + MxTheme extension)', type: 'foundation', size: 'L', deps: 'F.1,F.2',
    goal: 'Build ThemeData (light/dark) from tokens + a ThemeExtension exposing the roles Material cannot (surface tiers, semantic soft colors, state overlays, MxShadows, radii).',
    inputs: ['lib/core/theme/mx_*.dart', `${KIT}/components.css (how roles are used)`, `${KIT}/readme.md (VISUAL FOUNDATIONS)`],
    outputs: ['lib/core/theme/app_theme.dart', 'lib/core/theme/mx_theme.dart'],
    notes: ['ColorScheme.fromSeed(MxColors.seed) then override with tokens.', 'MxTheme extension must carry: surface{,Muted,Raised,Sunken}, *Soft semantic pairs, state overlays, focusRing, MxShadows light/dark, radii.', 'lerp + copyWith on the extension.'] },
  { id: 'F.4', title: 'Material component themes', type: 'foundation', size: 'M', deps: 'F.3',
    goal: 'Map tokens onto Material component themes so stock widgets inherit the kit look without per-call styling.',
    inputs: ['lib/core/theme/mx_*.dart', 'lib/core/theme/mx_theme.dart'],
    outputs: ['lib/core/theme/app_theme.dart (component themes)'],
    notes: ['FilledButton/Elevated/Outlined/Text button, Card, AppBar, NavigationBar, Chip, Switch, Dialog, InputDecoration.', 'A stock FilledButton must match the kit primary button without extra styling.'] },
  { id: 'F.5', title: 'l10n / ARB scaffold', type: 'foundation', size: 'M', deps: 'F.1',
    goal: 'Set up localization so all copy comes from ARB, never hardcoded.',
    inputs: [`${KIT}/ui_kits/memox-app/specs/*.md (placeholder copy)`, `${KIT}/readme.md (CONTENT FUNDAMENTALS)`],
    outputs: ['l10n.yaml', 'lib/l10n/app_en.arb', 'generated AppLocalizations'],
    notes: ['flutter_localizations + gen. Prove one string end-to-end. Sentence case per kit voice.'] },
  { id: 'F.6', title: 'Verification harness + gates', type: 'foundation', size: 'M', deps: 'F.2',
    goal: 'Golden-test infrastructure + wire the three gates into pre-commit/CI.',
    inputs: ['tool/design/gen_tokens.mjs --check', '.githooks/', 'test/'],
    outputs: ['test/ golden harness (font loading)', 'CI/pre-commit gate config'],
    notes: ['Gates: gen_tokens --check + dart analyze + flutter test. A failing golden must fail CI.'] },
  { id: 'F.7', title: 'Retire swatch showcase → real shell', type: 'foundation', size: 'S', deps: 'C1.11',
    goal: 'Replace the throwaway swatch demo in main.dart with the real app shell.',
    inputs: ['lib/main.dart', `${SURF}/mx_scaffold.dart`, `${NAV}/mx_bottom_nav.dart`],
    outputs: ['lib/main.dart'],
    notes: ['Boot MxScaffold + bottom nav. Keep render-confirm tests (retarget to the shell).'] },
];

/** shared reusable components: [id, Name, kitSource, outPath, size] */
const COMPONENTS = [
  ['C1.01', 'MxButton', kc('core/MxButton'), `${CORE}/mx_button.dart`, 'M'],
  ['C1.02', 'MxIconButton', kc('navigation/MxIconButton'), `${CORE}/mx_icon_button.dart`, 'S'],
  ['C1.03', 'MxAvatar', kc('core/MxAvatar'), `${CORE}/mx_avatar.dart`, 'S'],
  ['C1.04', 'MxBadge', kc('core/MxBadge'), `${CORE}/mx_badge.dart`, 'S'],
  ['C1.05', 'MxChip', kc('core/MxChip'), `${CORE}/mx_chip.dart`, 'S'],
  ['C1.06', 'MxSwitch', kc('core/MxSwitch'), `${CORE}/mx_switch.dart`, 'M'],
  ['C1.07', 'MxSegmentedControl', kc('core/MxSegmentedControl'), `${CORE}/mx_segmented_control.dart`, 'M'],
  ['C1.08', 'MxCard', kc('surfaces/MxCard'), `${SURF}/mx_card.dart`, 'M'],
  ['C1.09', 'MxIconTile', kc('surfaces/MxIconTile'), `${SURF}/mx_icon_tile.dart`, 'S'],
  ['C1.10', 'MxSectionHeader', kc('surfaces/MxSectionHeader'), `${SURF}/mx_section_header.dart`, 'S'],
  ['C1.11', 'MxScaffold', kc('surfaces/MxScaffold'), `${SURF}/mx_scaffold.dart`, 'L'],
  ['C1.12', 'MxAppBar', kc('surfaces/MxAppBar'), `${SURF}/mx_app_bar.dart`, 'M'],
  ['C1.13', 'MxBottomNav', kc('navigation/MxBottomNav'), `${NAV}/mx_bottom_nav.dart`, 'M'],
  ['C1.14', 'MxFab', kc('navigation/MxFab'), `${NAV}/mx_fab.dart`, 'S'],
  ['C1.15', 'MxSearchDock', kc('navigation/MxSearchDock'), `${NAV}/mx_search_dock.dart`, 'M'],
  ['C1.16', 'ActionCallout', `${KIT}/ui_kits/memox-app/_shared/ActionCallout`, `${FB}/action_callout.dart`, 'S'],
  ['C1.17', 'ConfirmDialog', `${KIT}/ui_kits/memox-app/_shared/ConfirmDialog`, `${FB}/confirm_dialog.dart`, 'M'],
  ['C1.18', 'StatusCardRow', `${KIT}/ui_kits/memox-app/_shared/StatusCardRow`, `${FB}/status_card_row.dart`, 'S'],
];

/** screens: [id, feature, ScreenFile, [localComponents], size, deferred?] */
const SCREENS = [
  ['S.01', 'dashboard', 'Dashboard.jsx', ['ContinueCard', 'GoalCard', 'StreakCard', 'TodaySummary'], 'L', false],
  ['S.02', 'library', 'Library.jsx', ['ContextBar', 'LibraryHeader', 'OverflowMenuSheet', 'PairPickerSheet', 'PlaySheet', 'SortSheet'], 'L', false],
  ['S.03', 'deck-detail', 'DeckDetail.jsx', ['DeckHeader', 'DeckMenu', 'DeleteConfirmDialog', 'FlashcardRow', 'SubDeckCard'], 'L', false],
  ['S.04', 'search', 'Search.jsx', ['Chips', 'ResultRow'], 'M', false],
  ['S.05', 'settings', 'Settings.jsx', ['Profile', 'ValuePickerSheet'], 'M', false],
  ['S.06', 'drawer', 'Drawer.jsx', ['DrawerItem', 'DrawerPanel', 'LangCard', 'RemoveLanguageDialog'], 'M', false],
  ['S.07', 'reminder', 'Reminder.jsx', ['TimeCol', 'TimePickerSheet'], 'M', false],
  ['S.08', 'theme', 'Theme.jsx', ['AccentPicker', 'PreviewCard'], 'M', false],
  ['S.09', 'statistics', 'Statistics.jsx', ['Bars', 'Donut', 'Heatmap'], 'L', false],
  ['S.10', 'import', 'Import.jsx', ['SourceCard', 'Table'], 'M', false],
  ['S.11', 'export', 'Export.jsx', ['ExportingCard', 'FormatList'], 'M', false],
  ['S.12', 'flashcard-editor', 'FlashcardEditor.jsx', ['DupBanner', 'Field'], 'M', false],
  ['S.13', 'game-picker', 'GamePicker.jsx', ['GameOption', 'ScopeCard', 'ScopeSheet'], 'M', false],
  ['S.14', 'game-matching', 'GameMatching.jsx', ['Tile'], 'M', false],
  ['S.15', 'game-mc', 'GameMultipleChoice.jsx', ['PromptCard'], 'M', false],
  ['S.16', 'game-recall', 'GameRecall.jsx', ['MeaningPanel', 'TermCard'], 'M', false],
  ['S.17', 'game-typing', 'GameTyping.jsx', ['CharCompare', 'InputBox'], 'M', false],
  ['S.18', 'review', 'Review.jsx', ['MeaningCard', 'TermCard'], 'M', false],
  ['S.19', 'player', 'Player.jsx', ['Dots', 'PlayerCard'], 'M', false],
  ['S.20', 'study-session', 'StudySession.jsx', ['AnswerSaveErrorDialog', 'ExitDialog', 'PromptCard', 'ResumeErrorState', 'StageChoice', 'StageMatching', 'StageRecall', 'StageReview', 'StageTyping'], 'L', false],
  ['S.21', 'study-result', 'StudyResult.jsx', ['Cta', 'FinalizingView', 'ResultHero', 'StreakGoalCard'], 'M', false],
  ['S.22', 'account-sync', 'AccountSync.jsx', ['ProfileCard', 'SignInCard', 'SyncBlock'], 'L', true],
];

/** @type {Task[]} */
const VERIFY = [
  { id: 'V.1', title: 'Golden suite (components + screen states)', type: 'verify', size: 'L', deps: 'Phase C1,S',
    goal: 'A golden per component + per screen-state, light+dark — the real parity gate at the component layer.',
    inputs: ['test/', `${KIT}/ui_kits/memox-app/shots/*.png`],
    outputs: ['test/golden/**'],
    notes: ['Verify at the ~18-component + per-state layer, NOT per-pixel-per-screen (avoids the old blind spot).'] },
  { id: 'V.2', title: 'Accessibility pass', type: 'verify', size: 'M', deps: 'Phase C1',
    goal: 'Touch targets, contrast, semantics labels to WCAG AA on interactive widgets.',
    inputs: ['MxSpacing.minTouchTarget', 'MxColors on/soft pairs'], outputs: ['a11y test coverage'],
    notes: ['Every interactive widget ≥ 48dp; semantics labels present.'] },
  { id: 'V.3', title: 'Responsive check', type: 'verify', size: 'M', deps: 'Phase C1',
    goal: 'Phone widths correct; large screens degrade gracefully.',
    inputs: [`${KIT}/readme.md (Layout rules)`], outputs: ['responsive test/notes'],
    notes: ['Phone-first: gutter 20, appbar 64/112, bottom-nav 72.'] },
  { id: 'V.4', title: 'design-sync → regenerate → gate loop', type: 'verify', size: 'S', deps: 'F.6',
    goal: 'Document + CI-wire the pull→regenerate→drift-gate flow.',
    inputs: ['.design-sync/NOTES.md', 'tool/design/gen_tokens.mjs --check'], outputs: ['CI step + docs'],
    notes: ['MSYS_NO_PATHCONV=1 claude -p "/design-sync" then gen_tokens --check.'] },
  { id: 'V.5', title: 'Prune-rule review on kit change', type: 'verify', size: 'S', deps: 'V.4',
    goal: 'When the kit changes, re-run the generator and review the pruned-token log.',
    inputs: ['tool/design/gen_tokens.mjs'], outputs: ['review notes'],
    notes: ['Re-include motion tokens if the app starts animating.'] },
];

// ── shared prose blocks ─────────────────────────────────────────────────────
const slug = (id) => id.toLowerCase().replace(/\./g, '');
const fileFor = (t) => `${slug(t.id)}-${t.title.toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/^-|-$/g, '')}.md`;
const branchFor = (t) => `build/${slug(t.id)}`;

const DOD = `## Definition of Done

- [ ] **Built** at the output path(s); tokens only — no raw \`Color(0x..)\`/px literals (use \`MxColors\`/\`MxSpacing\`/\`MxRadius\`/\`MxTypography\`/\`MxShadows\`).
- [ ] **Analyzes** — \`dart analyze lib test\` → 0 issues.
- [ ] **Tested** — widget/golden proving structure + token values reach the tree, light **and** dark where theme-varying, for every kit state.
- [ ] **Parity** — matches the kit reference (\`.jsx\` render / \`shots/*.png\`) for every state; deviations documented in \`wbs.md §Ledger\`, not silent.
- [ ] **Ledger** — row(s) added to \`docs/project-management/wbs.md §Ledger\` (kit node → Dart symbol → test).
- [ ] **Gates green** — \`node tool/design/gen_tokens.mjs --check\` + \`flutter test\` pass.`;

const VERIFY_CMDS = `## Verify (must pass before commit)

\`\`\`bash
node tool/design/gen_tokens.mjs --check
dart analyze lib test
flutter test
\`\`\``;

const STOP = `## STOP conditions (do not push through)

- The kit is **ambiguous or looks wrong** / a business or structural **drift** needs a human decision → STOP, report the exact mismatch, wait.
- A kit state is **undrivable** from the Flutter side → document as a gap in \`§Ledger\`, don't fabricate.
- **Verify fails** and you cannot fix at root cause → STOP, report the failing step + output.`;

const finish = (t) => `## Finish

1. Two commits: (a) implementation, (b) test(s). End messages with the Co-Authored-By trailer.
2. Push \`${branchFor(t)}\`; open a PR; merge to main (\`--merge --delete-branch\`); \`git checkout main && git pull\`.
   > When pushing from an agent session without a design-authorized TTY, prefix: \`MEMOX_SKIP_DESIGN_SYNC=1 git push …\`.
3. Tick \`${t.id}\` → \`[x]\` in \`docs/agent/build/README.md\`, small commit.`;

const header = (t, kind) => `# ${t.id} — ${t.title}

> **Loop task** (${kind}). Self-contained — execute fully in one iteration, then tick \`${t.id}\` in \`docs/agent/build/README.md\`. One task per iteration.
>
> Size **${t.size}** · Deps **${t.deps}** · Branch \`${branchFor(t)}\`
`;

const baseline = `1. **Baseline**: \`git checkout main && git pull\`, then \`git checkout -b ${'<branch>'}\`.`;

// ── renderers ───────────────────────────────────────────────────────────────
function renderGeneric(t) {
  const kind = t.type === 'foundation' ? 'foundation' : 'verification';
  return [
    header(t, kind),
    `## Goal\n\n${t.goal}`,
    `## Inputs — read first\n\n${t.inputs.map((i) => `- \`${i}\``).join('\n')}`,
    `## Output\n\n${t.outputs.map((o) => `- \`${o}\``).join('\n')}`,
    `## Steps\n\n1. **Baseline**: \`git checkout main && git pull\`, \`git checkout -b ${branchFor(t)}\`.\n2. Read the inputs above in full.\n3. Implement the goal. Tokens only; no hardcoded visual values.\n4. Test per the Definition of Done.\n5. Run Verify.\n6. Finish (commit → PR → merge → tick).`,
    t.notes ? `## Notes\n\n${t.notes.map((n) => `- ${n}`).join('\n')}` : '',
    DOD, VERIFY_CMDS, STOP, finish(t),
  ].filter(Boolean).join('\n\n');
}

function renderComponent([id, name, src, out, size]) {
  const t = { id, title: name, type: 'component', size, deps: 'Phase F', };
  return [
    header(t, 'reusable component'),
    `## Goal\n\nBuild the Flutter widget **${name}** mirroring the kit component, driven entirely by design tokens + the theme (Tier 1).`,
    `## Inputs — READ ALL IN FULL (do not infer)\n\n- \`${src}.d.ts\` — the typed prop contract (variants, sizes, flags).\n- \`${src}.prompt.md\` — the one-paragraph intent + JSX usage examples.\n- \`${src}.jsx\` — the class→CSS mapping (which base class + modifiers).\n- \`${KIT}/components.css\` — the base class + modifier styling for **${name}** (find its selector block).\n- \`lib/core/theme/\` — the tokens + \`MxTheme\` extension to consume.`,
    `## Output\n\n- \`${out}\` — the widget.\n- \`test/presentation/shared/widgets/${name.toLowerCase()}_test.dart\` — its test.`,
    `## Steps\n\n1. **Baseline**: \`git checkout main && git pull\`, \`git checkout -b ${branchFor(t)}\`.\n2. Read the \`.d.ts\` → derive the constructor: every prop → a param; every string-union → a Dart \`enum\`; flags → \`bool\`.\n3. Read \`.jsx\` + the \`components.css\` slice → map each variant/modifier to token-based styling (colour, radius, shadow, padding, type). Use the theme; **no raw values**.\n4. Reproduce **every variant/size/state** the contract lists (e.g. MxButton: primary/secondary/outline/ghost/contrast × sm/lg × icon/trailing/block/danger/disabled).\n5. Widget + golden test: render each variant in light+dark; assert token values reach the tree.\n6. Run Verify; add \`§Ledger\` row(s); Finish.`,
    `## Notes\n\n- The kit name + base class are **frozen contract** — keep the Dart name \`${name}\` and its variant identifiers aligned to the kit.\n- Strings come from ARB, not the widget.\n- If the \`.d.ts\` lists a variant the CSS has no styling for, note it in \`§Ledger\` — don't invent.`,
    DOD, VERIFY_CMDS, STOP, finish(t),
  ].join('\n\n');
}

function renderScreen([id, feature, screenFile, locals, size, deferred]) {
  const t = { id, title: feature, type: 'screen', size, deps: 'Phase C1' };
  const base = `${KIT}/ui_kits/memox-app/_features/${feature}`;
  const def = deferred ? `\n> ⊘ **DEFERRED (v1)** — do not build unless explicitly un-deferred. Left in the queue for completeness.\n` : '';
  return [
    header(t, 'screen') + def,
    `## Goal\n\nBuild the **${feature}** screen + its ${locals.length} feature-local component(s), composed from the Tier-1 \`Mx*\` widgets, matching the kit for every state.`,
    `## Inputs — READ ALL IN FULL\n\n- \`${base}/${screenFile}\` — the screen composition (which components, which states, the state machine).\n- Feature-local components (build these here, not in Phase C1):\n${locals.map((c) => `  - \`${base}/components/${c}.jsx\``).join('\n')}\n- \`${KIT}/ui_kits/memox-app/specs/${feature}.md\` — the contract (states, copy, behaviour).\n- \`${KIT}/ui_kits/memox-app/shots/${feature}--*--{light,dark}.png\` — the visual reference for **every** state.\n- Tier-1 widgets in \`lib/presentation/shared/widgets/\` + tokens/theme.`,
    `## Output\n\n- \`lib/presentation/features/${feature}/${feature.replace(/-/g, '_')}_screen.dart\`\n- \`lib/presentation/features/${feature}/widgets/*.dart\` — the ${locals.length} feature-local component(s).\n- \`test/presentation/features/${feature}/*_test.dart\``,
    `## Steps\n\n1. **Baseline**: \`git checkout main && git pull\`, \`git checkout -b ${branchFor(t)}\`.\n2. Read \`${screenFile}\` → enumerate the **states** (from the screen + \`specs/${feature}.md\` + the \`shots/\` filenames) and which components each state renders.\n3. Build the feature-local components (token-only, compose Tier-1 \`Mx*\`).\n4. Compose the screen; wire each state; strings from ARB.\n5. Test **every state** in light+dark (golden vs the matching \`shots/*.png\`); assert the node set / key components render per state.\n6. Run Verify; add \`§Ledger\` rows; Finish.`,
    `## Notes\n\n- Reuse Tier-1 components; only build genuinely screen-specific pieces locally.\n- Some kit states may be **undrivable** (error/loading behind a Result notifier) → document as a gap, don't fake.\n- If the FE composition genuinely diverges from the kit structure → **STOP** (possible drift), report.`,
    DOD, VERIFY_CMDS, STOP, finish(t),
  ].join('\n\n');
}

// ── build outputs ───────────────────────────────────────────────────────────
/** @type {{id:string,title:string,file:string,md:string,phase:string,deferred?:boolean}[]} */
const rows = [];
for (const t of FOUNDATION) rows.push({ id: t.id, title: t.title, file: fileFor(t), md: renderGeneric(t), phase: 'F — Foundation' });
for (const c of COMPONENTS) { const t = { id: c[0], title: c[1] }; rows.push({ id: c[0], title: c[1], file: fileFor(t), md: renderComponent(c), phase: 'C1 — Components' }); }
for (const s of SCREENS) { const t = { id: s[0], title: s[1] }; rows.push({ id: s[0], title: s[1], file: fileFor(t), md: renderScreen(s), phase: 'S — Screens', deferred: s[5] }); }
for (const t of VERIFY) rows.push({ id: t.id, title: t.title, file: fileFor(t), md: renderGeneric(t), phase: 'V — Verification' });

function renderReadme() {
  const byPhase = {};
  for (const r of rows) (byPhase[r.phase] ||= []).push(r);
  const tables = Object.entries(byPhase).map(([phase, rs]) => {
    const body = rs.map((r) => `| ${r.deferred ? '[~]' : '[ ]'} | ${r.id} | [${r.title}](${r.file}) |`).join('\n');
    return `### ${phase}\n\n| done | id | task |\n| --- | --- | --- |\n${body}`;
  }).join('\n\n');
  return `# Build queue — kit → Flutter loop prompts

Generated by \`tool/design/gen_task_prompts.mjs\` from the WBS
(\`docs/project-management/wbs.md\`). Each row links a **self-contained** loop
prompt: read the kit source it names, build, test, verify, commit, PR, tick.

## How to run (one task per iteration)

> \`/loop\` Đọc \`docs/agent/build/README.md\`, chọn task **pending** đầu tiên (\`[ ]\`)
> theo thứ tự phase (F → C1 → S → V) và theo deps. Đọc + thực thi ĐẦY ĐỦ file prompt
> của task đó (baseline → đọc kit source → build (token-only) → test light+dark mọi
> state → \`node tool/design/gen_tokens.mjs --check\` + \`dart analyze\` + \`flutter test\`
> → §Ledger → 2 commit → push → PR → merge), rồi đổi ô đó thành \`[x]\`. Mỗi vòng đúng
> 1 task. Nếu prompt bảo **STOP** (drift / ambiguity cần người quyết) → dừng, báo, chờ.
> \`[~]\` = deferred, bỏ qua. Hết pending → báo HOÀN TẤT.

**Order**: respect phases and deps — Foundation (F) unblocks everything; C1 shells
(MxScaffold/MxAppBar/MxBottomNav) unblock screens; S.01 dashboard is the pilot —
do it and pause for review before fanning out the rest of Phase S.

## Queue

${tables}

_Regenerate this queue + all prompts: \`node tool/design/gen_task_prompts.mjs\`._
`;
}

mkdirSync(OUT, { recursive: true });
// clear stale generated prompts (keep README handled below)
for (const f of readdirSync(OUT)) if (f.endsWith('.md') && f !== 'README.md') rmSync(join(OUT, f));
for (const r of rows) writeFileSync(join(OUT, r.file), r.md);
writeFileSync(join(OUT, 'README.md'), renderReadme());
console.log(`✓ ${rows.length} task prompts + README -> docs/agent/build/`);
