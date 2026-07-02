#!/usr/bin/env node
// @ts-check
/**
 * gen_task_prompts.mjs — emit one self-contained loop prompt per WBS task.
 *
 * Covers the full MemoX v1 WBS (docs/project-management/wbs.md): infra, theme,
 * domain (BE core), data (Drift), primitives, composites, screens, verification.
 * Each task -> a tailored `docs/agent/build/<id>-<slug>.md` a Claude Code /loop
 * can execute end-to-end, plus a queue README with tick boxes.
 *
 * Prompts name the exact source to read (kit .d.ts/.prompt.md/.jsx for UI;
 * product-decision memories + reference-app domain for BE) and tell the loop to
 * read it at execution time, so they can't drift from the source of truth.
 *
 * Regenerate: node tool/design/gen_task_prompts.mjs
 */

import { writeFileSync, mkdirSync, readdirSync, rmSync } from 'node:fs';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';

const REPO = join(dirname(fileURLToPath(import.meta.url)), '..', '..');
const OUT = join(REPO, 'docs', 'agent', 'build');
const KIT = 'docs/design/MemoX Design System';
const PRIM = 'lib/presentation/shared/primitives';
const COMP = 'lib/presentation/shared/composites';
const kc = (p) => `${KIT}/components/${p}`;

/** @typedef {{id:string,title:string,size:string,deps:string,goal:string,inputs:string[],outputs:string[],steps?:string[],notes?:string[]}} T */

// ── Phase I — infrastructure ────────────────────────────────────────────────
/** @type {T[]} */
const INFRA = [
  { id: 'I.1', title: 'Dependencies', size: 'S', deps: '—',
    goal: 'Add and pin the v1 stack dependencies.',
    inputs: ['pubspec.yaml', 'docs/project-management/wbs.md (Architecture)'],
    outputs: ['pubspec.yaml'],
    notes: ['flutter_riverpod + riverpod_annotation + riverpod_generator', 'drift + drift_flutter + sqlite3_flutter_libs', 'go_router', 'equatable or freezed', 'build_runner + custom_lint + riverpod_lint', 'flutter_localizations + intl. Pin versions; run pub get.'] },
  { id: 'I.2', title: 'Lint and format config', size: 'S', deps: 'I.1',
    goal: 'Strict analyzer config enforcing the layer contracts.',
    inputs: ['analysis_options.yaml', 'flutter-full-app architecture rules'],
    outputs: ['analysis_options.yaml'],
    notes: ['flutter_lints + riverpod_lint/custom_lint.', 'Where feasible, forbid feature UI importing data/ or dart:io.'] },
  { id: 'I.3', title: 'Folder architecture scaffold', size: 'S', deps: '—',
    goal: 'Create the full lib/ tree (barrels/placeholders only, no logic).',
    inputs: ['docs/project-management/wbs.md §Architecture'],
    outputs: ['lib/app/', 'lib/core/{constants,error,logging,routes,theme,utils}/', 'lib/domain/{entities,repositories,usecases}/', 'lib/data/{datasources/local,models,repositories}/', 'lib/presentation/shared/{primitives,composites,layouts,screens}/', 'lib/presentation/features/', 'lib/l10n/'],
    notes: ['Mirror the skill structure exactly. Placeholder barrels so dirs are tracked; no widgets/logic yet.'] },
  { id: 'I.4', title: 'App bootstrap', size: 'M', deps: 'I.1,I.3',
    goal: 'App entrypoint: ProviderScope + MaterialApp.router + env/flavor + guarded error zone.',
    inputs: ['lib/main.dart', 'lib/app/', 'core/theme (F/T)'],
    outputs: ['lib/app/*.dart', 'lib/main.dart'],
    notes: ['runApp inside a guarded zone; ProviderScope at root; MaterialApp.router wired to core/routes.', 'Replaces the Tier-0 swatch showcase.'] },
  { id: 'I.5', title: 'Routing skeleton', size: 'M', deps: 'I.4',
    goal: 'go_router with a shell route (bottom nav) + typed route stubs for all 22 features.',
    inputs: ['core/routes/', 'the 22 feature list (wbs.md Phase S)'],
    outputs: ['lib/core/routes/*.dart'],
    notes: ['ShellRoute hosting the bottom-nav destinations (Today/Library/Add/Stats/Profile).', 'Typed routes; placeholder screens until Phase S.'] },
  { id: 'I.6', title: 'Error and Result type', size: 'S', deps: 'I.3',
    goal: 'Failure hierarchy + Result<T> + guard helpers used across domain/data.',
    inputs: ['core/error/'],
    outputs: ['lib/core/error/*.dart'],
    notes: ['Sealed Failure types; Result/Either; a runGuarded that maps exceptions -> Failure.'] },
  { id: 'I.7', title: 'Logging, utils, constants', size: 'S', deps: 'I.3',
    goal: 'Cross-cutting core: logger, utils, app constants.',
    inputs: ['core/logging/', 'core/utils/', 'core/constants/'],
    outputs: ['lib/core/{logging,utils,constants}/*.dart'], notes: ['Keep tiny; no feature logic.'] },
  { id: 'I.8', title: 'CI/CD, hooks, codegen gate', size: 'M', deps: 'I.1',
    goal: 'Gate every push: analyze, test, gen_tokens --check, and build_runner freshness.',
    inputs: ['.githooks/', 'tool/design/gen_tokens.mjs'],
    outputs: ['.github/workflows/*', '.githooks/pre-push'],
    notes: ['Codegen freshness: run build_runner then fail if git is dirty.', 'Compose with the existing design-sync pre-push step.'] },
];

// ── Phase T — theme / UI foundation ─────────────────────────────────────────
/** @type {T[]} */
const THEME = [
  { id: 'T.1', title: 'Theme assembly (ThemeData + MxTheme extension)', size: 'L', deps: 'I.3',
    goal: 'ThemeData light/dark from tokens + a ThemeExtension for roles Material cannot express.',
    inputs: ['lib/core/theme/mx_*.dart', `${KIT}/components.css`, `${KIT}/readme.md (VISUAL FOUNDATIONS)`],
    outputs: ['lib/core/theme/app_theme.dart', 'lib/core/theme/mx_theme.dart'],
    notes: ['ColorScheme.fromSeed(MxColors.seed) then override with tokens.', 'MxTheme carries: surface{,Muted,Raised,Sunken}, *Soft semantic pairs, state overlays, focusRing, MxShadows, radii; lerp + copyWith.'] },
  { id: 'T.2', title: 'Font wiring (Plus Jakarta Sans)', size: 'S', deps: 'I.1',
    goal: 'Register the variable font so MxTypography.fontFamily renders real glyphs.',
    inputs: [`${KIT}/fonts/PlusJakartaSans[wght].ttf`, `${KIT}/tokens/typography.css`],
    outputs: ['pubspec.yaml'], notes: ['Confirm 400–800 render distinctly (golden).'] },
  { id: 'T.3', title: 'Material component themes', size: 'M', deps: 'T.1',
    goal: 'Map tokens onto Material component themes so stock widgets inherit the kit look.',
    inputs: ['lib/core/theme/*.dart'], outputs: ['lib/core/theme/app_theme.dart'],
    notes: ['Button/Card/AppBar/NavigationBar/Chip/Switch/Dialog/Input. Stock FilledButton must match kit primary.'] },
  { id: 'T.4', title: 'l10n / ARB scaffold', size: 'M', deps: 'I.1',
    goal: 'Localization so all copy comes from ARB.',
    inputs: [`${KIT}/ui_kits/memox-app/specs/*.md`, `${KIT}/readme.md (CONTENT FUNDAMENTALS)`],
    outputs: ['l10n.yaml', 'lib/l10n/app_en.arb'], notes: ['Prove one string end-to-end; sentence case.'] },
  { id: 'T.5', title: 'Verification harness (goldens)', size: 'M', deps: 'T.2',
    goal: 'Golden-test infra (font loading) + gate wiring.',
    inputs: ['test/', 'tool/design/gen_tokens.mjs --check'], outputs: ['test/ harness'],
    notes: ['A failing golden must fail CI.'] },
  { id: 'T.6', title: 'Responsive foundation', size: 'M', deps: 'T.1',
    goal: 'Centralized adaptive sizing; no per-feature responsive hacks.',
    inputs: [`${KIT}/readme.md (Layout rules)`, 'flutter-app-development responsive-rule'],
    outputs: ['lib/core/theme/responsive*.dart'], notes: ['Phone-first: gutter 20, appbar 64/112, bottom-nav 72.'] },
];

// ── Phase DM — domain (BE core) ─────────────────────────────────────────────
const DOMAIN_STEPS = [
  '**Baseline**: `git checkout main && git pull`, branch.',
'Read the authoritative v1 product rules in `docs/business/` (start at `index.md`; this task names its specific spec) + the relevant kit `specs/*.md` for UI shape. If a rule is not stated in-repo, **STOP and ask** — do not invent domain behaviour.',
  'Model as **pure Dart** — no Flutter, no Drift imports. Immutable, `Result`-returning.',
  'Exhaustive **unit tests** (deterministic, edge cases). This is BE core — correctness first.',
  'Run Verify; add §Ledger rows; Finish.',
];
/** @type {T[]} */
const DOMAIN = [
  { id: 'DM.1', title: 'Value types & IDs', size: 'S', deps: 'I.6',
    goal: 'Foundational domain value types: BoxLevel (0–7), CardId/DeckId, ReviewGrade, enums.',
    inputs: ['docs/business/glossary.md', 'docs/business/srs/srs-review.md', 'lib/core/error/'], outputs: ['lib/domain/entities/*.dart'], steps: DOMAIN_STEPS },
  { id: 'DM.2', title: 'Entities', size: 'M', deps: 'DM.1',
    goal: 'Immutable entities: Deck (nested), Card, LanguagePair, ReviewLog, StudySession, Goal, Streak, DeckStats.',
    inputs: ['docs/business/glossary.md', 'docs/business/deck/deck-management.md', 'docs/business/flashcard/flashcard-management.md'], outputs: ['lib/domain/entities/*.dart'], steps: DOMAIN_STEPS,
    notes: ['Deck nesting = parent/children. Keep domain entities separate from Drift row models.'] },
  { id: 'DM.3', title: 'Repository interfaces', size: 'S', deps: 'DM.2',
    goal: 'Abstract DeckRepository / CardRepository / ReviewRepository / SettingsRepository — the FE/BE contract.',
    inputs: ['lib/domain/entities/'], outputs: ['lib/domain/repositories/*.dart'], steps: DOMAIN_STEPS,
    notes: ['Explicit read source / write policy. Treat this as a FROZEN contract once screens code against it (R4).'] },
  { id: 'DM.4', title: 'SRS engine (8-box single-direction)', size: 'L', deps: 'DM.2',
    goal: 'The scheduler: 8-box single-direction progression + 20-new-cards/day intake + due calculation + grade→box transition.',
    inputs: ['docs/business/srs/srs-review.md (the 8-box Leitner spec)', 'docs/business/study/study-flow.md'], outputs: ['lib/domain/usecases/srs/*.dart'], steps: DOMAIN_STEPS,
    notes: ['This is the product core — a bug is silent data damage. Property/exhaustive tests before any screen consumes it. Pure & deterministic (no Date.now — inject a clock).'] },
  { id: 'DM.5', title: 'Study use cases', size: 'M', deps: 'DM.3,DM.4',
    goal: 'Due queue, start/resume session, grade card, finish session, goal+streak update.',
    inputs: ['docs/business/study/study-flow.md', 'docs/business/game/game-modes.md', 'docs/business/engagement/dashboard-engagement.md', 'lib/domain/usecases/srs/'], outputs: ['lib/domain/usecases/study/*.dart'], steps: DOMAIN_STEPS },
  { id: 'DM.6', title: 'Library use cases', size: 'M', deps: 'DM.3',
    goal: 'Deck CRUD (nested move/rename/delete), card CRUD, soft-dup detection, term+meaning search.',
    inputs: ['docs/business/deck/deck-management.md', 'docs/business/flashcard/flashcard-management.md', 'docs/business/search/global-search.md'], outputs: ['lib/domain/usecases/library/*.dart'], steps: DOMAIN_STEPS },
  { id: 'DM.7', title: 'Import/export + stats use cases', size: 'M', deps: 'DM.3',
    goal: 'Parse/emit deck formats; compute statistics + heatmap.',
    inputs: ['docs/business/import-export/import-export.md', 'docs/business/statistics/statistics.md'], outputs: ['lib/domain/usecases/{io,stats}/*.dart'], steps: DOMAIN_STEPS },
];

// ── Phase DT — data (Drift) ─────────────────────────────────────────────────
const DATA_STEPS = [
  '**Baseline**: `git checkout main && git pull`, branch.',
  'Read the domain entities/repositories (DM.2/DM.3) this implements against.',
  'Implement in the **data layer only**; keep Drift row models separate from domain entities (map at the boundary).',
  'Run `dart run build_runner build --delete-conflicting-outputs` for Drift codegen.',
  '**Integration test** against an in-memory Drift DB.',
  'Run Verify; add §Ledger rows; Finish.',
];
/** @type {T[]} */
const DATA = [
  { id: 'DT.1', title: 'Drift schema & tables', size: 'L', deps: 'DM.2',
    goal: 'DB class + tables (decks, cards, review_logs, sessions, settings) + indices for due/search.',
    inputs: ['lib/domain/entities/'], outputs: ['lib/data/datasources/local/*.dart', 'lib/data/models/*.dart'], steps: DATA_STEPS },
  { id: 'DT.2', title: 'Migrations & versioning', size: 'M', deps: 'DT.1',
    goal: 'Schema versioning + migration strategy + schema round-trip tests.',
    inputs: ['lib/data/datasources/local/'], outputs: ['migrations', 'test/data/migration/*'], steps: DATA_STEPS,
    notes: ['Never edit a shipped schema in place — migrate forward (R3).'] },
  { id: 'DT.3', title: 'DAOs', size: 'M', deps: 'DT.1',
    goal: 'Queries: due-cards, term+meaning search, deck tree, stats aggregations.',
    inputs: ['lib/data/datasources/local/'], outputs: ['lib/data/datasources/local/dao/*.dart'], steps: DATA_STEPS },
  { id: 'DT.4', title: 'Repository impls + mappers', size: 'L', deps: 'DT.3,DM.3',
    goal: 'Implement the DM.3 interfaces over the DAOs; row↔entity mappers.',
    inputs: ['lib/domain/repositories/', 'lib/data/datasources/local/dao/'], outputs: ['lib/data/repositories/*.dart', 'lib/data/models/mappers/*.dart'], steps: DATA_STEPS },
  { id: 'DT.5', title: 'DI wiring (providers)', size: 'M', deps: 'DT.4',
    goal: '@riverpod providers exposing repositories + use cases; swap in-memory fakes for Drift.',
    inputs: ['lib/data/repositories/', 'lib/domain/usecases/'], outputs: ['**/providers/*.dart'], steps: DATA_STEPS,
    notes: ['This is the seam that flips screens from fakes to real data.'] },
  { id: 'DT.6', title: 'Seed / sample data', size: 'S', deps: 'DT.4',
    goal: 'Realistic dev decks/cards + a clean first-run empty state.',
    inputs: ['lib/data/repositories/'], outputs: ['lib/data/seed/*.dart'], steps: DATA_STEPS },
];

// ── Phase P — primitives / K — composites ───────────────────────────────────
/** [id, Name, kitSrcNoExt, outPath] */
const PRIMITIVES = [
  ['P.01', 'MxButton', kc('core/MxButton'), `${PRIM}/mx_button.dart`],
  ['P.02', 'MxIconButton', kc('navigation/MxIconButton'), `${PRIM}/mx_icon_button.dart`],
  ['P.03', 'MxAvatar', kc('core/MxAvatar'), `${PRIM}/mx_avatar.dart`],
  ['P.04', 'MxBadge', kc('core/MxBadge'), `${PRIM}/mx_badge.dart`],
  ['P.05', 'MxChip', kc('core/MxChip'), `${PRIM}/mx_chip.dart`],
  ['P.06', 'MxSwitch', kc('core/MxSwitch'), `${PRIM}/mx_switch.dart`],
  ['P.07', 'MxSegmentedControl', kc('core/MxSegmentedControl'), `${PRIM}/mx_segmented_control.dart`],
];
const COMPOSITES = [
  ['K.01', 'MxCard', kc('surfaces/MxCard'), `${COMP}/mx_card.dart`],
  ['K.02', 'MxIconTile', kc('surfaces/MxIconTile'), `${COMP}/mx_icon_tile.dart`],
  ['K.03', 'MxSectionHeader', kc('surfaces/MxSectionHeader'), `${COMP}/mx_section_header.dart`],
  ['K.04', 'MxScaffold', kc('surfaces/MxScaffold'), `${COMP}/mx_scaffold.dart`],
  ['K.05', 'MxAppBar', kc('surfaces/MxAppBar'), `${COMP}/mx_app_bar.dart`],
  ['K.06', 'MxBottomNav', kc('navigation/MxBottomNav'), `${COMP}/mx_bottom_nav.dart`],
  ['K.07', 'MxFab', kc('navigation/MxFab'), `${COMP}/mx_fab.dart`],
  ['K.08', 'MxSearchDock', kc('navigation/MxSearchDock'), `${COMP}/mx_search_dock.dart`],
  ['K.09', 'ActionCallout', `${KIT}/ui_kits/memox-app/_shared/ActionCallout`, `${COMP}/action_callout.dart`],
  ['K.10', 'ConfirmDialog', `${KIT}/ui_kits/memox-app/_shared/ConfirmDialog`, `${COMP}/confirm_dialog.dart`],
  ['K.11', 'StatusCardRow', `${KIT}/ui_kits/memox-app/_shared/StatusCardRow`, `${COMP}/status_card_row.dart`],
];

/** [id, feature, ScreenFile, [locals], size, deferred, domainDep] */
const SCREENS = [
  ['S.01', 'dashboard', 'Dashboard.jsx', ['ContinueCard', 'GoalCard', 'StreakCard', 'TodaySummary'], 'L', false, 'DM.5'],
  ['S.02', 'library', 'Library.jsx', ['ContextBar', 'LibraryHeader', 'OverflowMenuSheet', 'PairPickerSheet', 'PlaySheet', 'SortSheet'], 'L', false, 'DM.6'],
  ['S.03', 'deck-detail', 'DeckDetail.jsx', ['DeckHeader', 'DeckMenu', 'DeleteConfirmDialog', 'FlashcardRow', 'SubDeckCard'], 'L', false, 'DM.6'],
  ['S.04', 'search', 'Search.jsx', ['Chips', 'ResultRow'], 'M', false, 'DM.6'],
  ['S.05', 'settings', 'Settings.jsx', ['Profile', 'ValuePickerSheet'], 'M', false, '—'],
  ['S.06', 'drawer', 'Drawer.jsx', ['DrawerItem', 'DrawerPanel', 'LangCard', 'RemoveLanguageDialog'], 'M', false, '—'],
  ['S.07', 'reminder', 'Reminder.jsx', ['TimeCol', 'TimePickerSheet'], 'M', false, '—'],
  ['S.08', 'theme', 'Theme.jsx', ['AccentPicker', 'PreviewCard'], 'M', false, '—'],
  ['S.09', 'statistics', 'Statistics.jsx', ['Bars', 'Donut', 'Heatmap'], 'L', false, 'DM.7'],
  ['S.10', 'import', 'Import.jsx', ['SourceCard', 'Table'], 'M', false, 'DM.7'],
  ['S.11', 'export', 'Export.jsx', ['ExportingCard', 'FormatList'], 'M', false, 'DM.7'],
  ['S.12', 'flashcard-editor', 'FlashcardEditor.jsx', ['DupBanner', 'Field'], 'M', false, 'DM.6'],
  ['S.13', 'game-picker', 'GamePicker.jsx', ['GameOption', 'ScopeCard', 'ScopeSheet'], 'M', false, 'DM.5'],
  ['S.14', 'game-matching', 'GameMatching.jsx', ['Tile'], 'M', false, 'DM.5'],
  ['S.15', 'game-mc', 'GameMultipleChoice.jsx', ['PromptCard'], 'M', false, 'DM.5'],
  ['S.16', 'game-recall', 'GameRecall.jsx', ['MeaningPanel', 'TermCard'], 'M', false, 'DM.5'],
  ['S.17', 'game-typing', 'GameTyping.jsx', ['CharCompare', 'InputBox'], 'M', false, 'DM.5'],
  ['S.18', 'review', 'Review.jsx', ['MeaningCard', 'TermCard'], 'M', false, 'DM.5'],
  ['S.19', 'player', 'Player.jsx', ['Dots', 'PlayerCard'], 'M', false, 'DM.5'],
  ['S.20', 'study-session', 'StudySession.jsx', ['AnswerSaveErrorDialog', 'ExitDialog', 'PromptCard', 'ResumeErrorState', 'StageChoice', 'StageMatching', 'StageRecall', 'StageReview', 'StageTyping'], 'L', false, 'DM.5'],
  ['S.21', 'study-result', 'StudyResult.jsx', ['Cta', 'FinalizingView', 'ResultHero', 'StreakGoalCard'], 'M', false, 'DM.5'],
  ['S.22', 'account-sync', 'AccountSync.jsx', ['ProfileCard', 'SignInCard', 'SyncBlock'], 'L', true, '—'],
];

/** @type {T[]} */
const VERIFY = [
  { id: 'V.1', title: 'Golden suite (components + screen states)', size: 'L', deps: 'Phase P,K,S',
    goal: 'A golden per component + per screen-state (light+dark) — parity gate at the component layer.',
    inputs: ['test/', `${KIT}/ui_kits/memox-app/shots/*.png`], outputs: ['test/golden/**'],
    notes: ['Verify at the ~18-component + per-state layer, not per-pixel-per-screen.'] },
  { id: 'V.2', title: 'Domain test sweep (SRS invariants)', size: 'M', deps: 'DM.4',
    goal: 'Edge cases + scheduler invariants for the SRS engine and study use cases.',
    inputs: ['lib/domain/usecases/'], outputs: ['test/domain/**'], notes: ['Property-style where useful.'] },
  { id: 'V.3', title: 'Data integration (Drift)', size: 'M', deps: 'DT.4',
    goal: 'Query correctness, migration round-trips, seed load against an in-memory DB.',
    inputs: ['lib/data/'], outputs: ['test/data/**'] },
  { id: 'V.4', title: 'End-to-end study flow', size: 'L', deps: 'S.20,DT.5',
    goal: 'due → grade → box move → goal/streak over a real Drift DB, through providers.',
    inputs: ['lib/domain/', 'lib/data/', 'lib/presentation/features/study-session/'], outputs: ['test/e2e/**'], notes: ['Ties FE + BE.'] },
  { id: 'V.5', title: 'Accessibility pass', size: 'M', deps: 'Phase P,K',
    goal: 'Touch targets, contrast, semantics labels to WCAG AA.',
    inputs: ['MxSpacing.minTouchTarget'], outputs: ['a11y coverage'] },
  { id: 'V.6', title: 'Responsive check', size: 'M', deps: 'T.6',
    goal: 'Phone widths correct; large screens graceful.',
    inputs: [`${KIT}/readme.md (Layout rules)`], outputs: ['responsive tests/notes'] },
  { id: 'V.7', title: 'design-sync → regenerate → gate loop', size: 'S', deps: 'I.8',
    goal: 'Document + CI-wire the kit pull → regenerate → drift-gate flow.',
    inputs: ['.design-sync/NOTES.md', 'tool/design/gen_tokens.mjs --check'], outputs: ['CI step + docs'],
    notes: ['MSYS_NO_PATHCONV=1 claude -p "/design-sync" then gen_tokens --check.'] },
];

// ── shared prose ────────────────────────────────────────────────────────────
const slug = (id) => id.toLowerCase().replace(/\./g, '');
const kebab = (s) => s.toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/^-|-$/g, '');
const snake = (s) => s.replace(/-/g, '_');
const testFor = (out) => `test/${out.replace(/^lib\//, '').replace(/\.dart$/, '_test.dart')}`;
const branchFor = (id) => `build/${slug(id)}`;

const DOD = `## Definition of Done

- [ ] **Built** at the output path(s), respecting the layer contracts (foundation token-only · primitives no business logic · feature UI no data/ imports).
- [ ] **Analyzes** — \`dart analyze lib test\` → 0 issues; codegen (build_runner) up to date.
- [ ] **Tested** at the right level — domain = pure unit · data = Drift integration · primitives/composites = widget+golden (light+dark) · screens = provider-state widget tests + golden vs \`shots/*.png\`.
- [ ] **Parity / correctness** — UI matches the kit for every state; domain matches the v1 rules in \`docs/business/\` with edge cases.
- [ ] **Ledger** — row(s) added to \`docs/project-management/wbs.md §Ledger\`.
- [ ] **Gates green** — \`gen_tokens --check\` + \`dart analyze\` + \`flutter test\` + codegen check.`;

const VERIFY_CMDS = `## Verify (must pass before commit)

\`\`\`bash
dart run build_runner build --delete-conflicting-outputs
node tool/design/gen_tokens.mjs --check
dart analyze lib test
flutter test
\`\`\``;

const STOP = `## STOP conditions (do not push through)

- Source is **ambiguous or looks wrong** / a business or structural **drift** needs a human decision → STOP, report the exact mismatch, wait.
- A kit state / product rule is **undrivable or underspecified** → document as a gap in §Ledger, don't fabricate.
- **Verify fails** and you cannot fix at root cause → STOP, report the failing step + output.`;

const finish = (id) => `## Finish

1. Commit(s): implementation + test(s). End messages with the Co-Authored-By trailer.
2. Push \`${branchFor(id)}\`; open a PR; merge to main; \`git checkout main && git pull\`.
   > From an agent session without a design-authorized TTY, prefix: \`MEMOX_SKIP_DESIGN_SYNC=1 git push …\`.
3. Tick \`${id}\` → \`[x]\` in \`docs/agent/build/README.md\`, small commit.`;

const header = (id, title, size, deps, kind) => `# ${id} — ${title}

> **Loop task** (${kind}). Self-contained — execute fully in one iteration, then tick \`${id}\` in \`docs/agent/build/README.md\`. One task per iteration.
>
> Size **${size}** · Deps **${deps}** · Branch \`${branchFor(id)}\`
`;

// ── renderers ───────────────────────────────────────────────────────────────
function renderGeneric(t, kind) {
  const steps = t.steps || [
    `**Baseline**: \`git checkout main && git pull\`, \`git checkout -b ${branchFor(t.id)}\`.`,
    'Read the inputs above in full.',
    'Implement the goal, respecting layer contracts; tokens only for any visual value.',
    'Test per the Definition of Done.',
    'Run Verify.',
    'Finish (commit → PR → merge → tick).',
  ];
  return [
    header(t.id, t.title, t.size, t.deps, kind),
    `## Goal\n\n${t.goal}`,
    `## Inputs — read first\n\n${t.inputs.map((i) => `- \`${i}\``).join('\n')}`,
    `## Output\n\n${t.outputs.map((o) => `- \`${o}\``).join('\n')}`,
    `## Steps\n\n${steps.map((s, i) => `${i + 1}. ${s}`).join('\n')}`,
    t.notes ? `## Notes\n\n${t.notes.map((n) => `- ${n}`).join('\n')}` : '',
    DOD, VERIFY_CMDS, STOP, finish(t.id),
  ].filter(Boolean).join('\n\n');
}

function renderComponent([id, name, src, out], layer) {
  return [
    header(id, name, layer === 'primitive' ? 'S–M' : 'S–L', 'Phase T', `${layer} component`),
    `## Goal\n\nBuild the Flutter widget **${name}** mirroring the kit component, driven entirely by design tokens + \`MxTheme\` (${layer} layer).`,
    `## Inputs — READ ALL IN FULL (do not infer)\n\n- \`${src}.d.ts\` — typed prop contract (variants, sizes, flags).\n- \`${src}.prompt.md\` — intent + JSX usage examples.\n- \`${src}.jsx\` — class→CSS mapping.\n- \`${KIT}/components.css\` — the base class + modifier styling for **${name}**.\n- \`lib/core/theme/\` — tokens + \`MxTheme\` extension.`,
    `## Output\n\n- \`${out}\`\n- \`${testFor(out)}\``,
    `## Steps\n\n1. **Baseline**: \`git checkout main && git pull\`, \`git checkout -b ${branchFor(id)}\`.\n2. Read the \`.d.ts\` → constructor: each prop → param; string-union → Dart \`enum\`; flags → \`bool\`.\n3. Read \`.jsx\` + the \`components.css\` slice → map each variant/modifier to token styling via the theme. **No raw \`Color(0x..)\`/px.**\n4. Reproduce **every** variant/size/state the contract lists.\n5. Widget + golden test: each variant in light+dark; assert token values reach the tree.\n6. Run Verify; add §Ledger row(s); Finish.`,
    `## Notes\n\n- ${layer === 'primitive' ? 'Primitive: wrap Material, **no** business logic / provider / feature imports.' : 'Composite: compose primitives; feature-independent; no provider usage.'}\n- Kit name + base class are **frozen contract** — keep \`${name}\` + variant identifiers aligned.\n- Strings from ARB. If \`.d.ts\` lists a variant the CSS never styles, note it in §Ledger — don't invent.`,
    DOD, VERIFY_CMDS, STOP, finish(id),
  ].join('\n\n');
}

function renderScreen([id, feature, screenFile, locals, size, deferred, dm]) {
  const base = `${KIT}/ui_kits/memox-app/_features/${feature}`;
  const feat = `lib/presentation/features/${feature}`;
  const def = deferred ? `\n> ⊘ **DEFERRED (v1)** — do not build unless explicitly un-deferred.\n` : '';
  const deps = deferred ? '⊘' : `Phase K${dm !== '—' ? ` + ${dm}` : ''}`;
  return [
    header(id, feature, size, deps, 'screen') + def,
    `## Goal\n\nBuild the **${feature}** screen + its ${locals.length} feature-local component(s), composed from the shared \`Mx*\` widgets, rendering ${dm !== '—' ? `**${dm}** use-case state via \`@riverpod\` providers` : 'local UI state'}, matching the kit for every state.`,
    `## Inputs — READ ALL IN FULL\n\n- \`${base}/${screenFile}\` — screen composition (components, states, state machine).\n- Feature-local components (build here):\n${locals.map((c) => `  - \`${base}/components/${c}.jsx\``).join('\n')}\n- \`${KIT}/ui_kits/memox-app/specs/${feature}.md\` — contract (states, copy, behaviour).\n- \`${KIT}/ui_kits/memox-app/shots/${feature}--*--{light,dark}.png\` — visual reference per state.\n- Shared widgets in \`lib/presentation/shared/{primitives,composites}/\`${dm !== '—' ? `\n- Domain use cases: \`lib/domain/usecases/\` (**${dm}**)` : ''}`,
    `## Output\n\n- \`${feat}/screens/${snake(feature)}_screen.dart\`\n- \`${feat}/providers/*.dart\` — \`@riverpod\` notifier(s) (own mutation; call use cases)\n- \`${feat}/widgets/*.dart\` — the ${locals.length} feature-local component(s)\n- \`test/presentation/features/${feature}/*_test.dart\``,
    `## Steps\n\n1. **Baseline**: \`git checkout main && git pull\`, \`git checkout -b ${branchFor(id)}\`.\n2. Read \`${screenFile}\` → enumerate **states** (screen + \`specs/${feature}.md\` + \`shots/\` filenames) and the components each renders.\n3. Build feature-local components (token-only; compose shared \`Mx*\`).\n4. ${dm !== '—' ? `Build the \`@riverpod\` provider(s) calling **${dm}** use cases (use in-memory fakes until DT.5 lands); render with \`AsyncValue.when\`.` : 'Wire local UI state via a provider/notifier — no logic in build().'}\n5. Compose the screen; strings from ARB.\n6. Test **every state** (light+dark golden vs \`shots/*.png\`; provider-state widget tests).\n7. Run Verify; add §Ledger rows; Finish.`,
    `## Notes\n\n- Reuse shared components; build only genuinely screen-specific pieces locally.\n- Feature UI must **not** import \`data/\` or \`dart:io\` — go through providers → use cases.\n- Undrivable kit states → document as a gap; if FE structure diverges from the kit → **STOP** (possible drift).`,
    DOD, VERIFY_CMDS, STOP, finish(id),
  ].join('\n\n');
}

// ── assemble ────────────────────────────────────────────────────────────────
/** @type {{id:string,title:string,file:string,md:string,phase:string,deferred?:boolean}[]} */
const rows = [];
const add = (id, title, md, phase, deferred) => rows.push({ id, title, file: `${slug(id)}-${kebab(title)}.md`, md, phase, deferred });

for (const t of INFRA) add(t.id, t.title, renderGeneric(t, 'infrastructure'), 'I — Infrastructure');
for (const t of THEME) add(t.id, t.title, renderGeneric(t, 'theme / UI foundation'), 'T — Theme foundation');
for (const t of DOMAIN) add(t.id, t.title, renderGeneric(t, 'domain (BE core)'), 'DM — Domain (BE core)');
for (const t of DATA) add(t.id, t.title, renderGeneric(t, 'data (Drift)'), 'DT — Data (BE impl)');
for (const c of PRIMITIVES) add(c[0], c[1], renderComponent(c, 'primitive'), 'P — Primitives');
for (const c of COMPOSITES) add(c[0], c[1], renderComponent(c, 'composite'), 'K — Composites');
for (const s of SCREENS) add(s[0], s[1], renderScreen(s), 'S — Screens', s[5]);
for (const t of VERIFY) add(t.id, t.title, renderGeneric(t, 'verification'), 'V — Verification');

function renderReadme() {
  const byPhase = {};
  for (const r of rows) (byPhase[r.phase] ||= []).push(r);
  const tables = Object.entries(byPhase).map(([phase, rs]) => {
    const body = rs.map((r) => `| ${r.deferred ? '[~]' : '[ ]'} | ${r.id} | [${r.title}](${r.file}) |`).join('\n');
    return `### ${phase}\n\n| done | id | task |\n| --- | --- | --- |\n${body}`;
  }).join('\n\n');
  return `# Build queue — MemoX v1 loop prompts

Generated by \`tool/design/gen_task_prompts.mjs\` from the WBS
(\`docs/project-management/wbs.md\`). Each row links a **self-contained** loop
prompt. Local-first app: **FE track** (P → K → S) and **BE track** (DM → DT) run
in parallel once the shared foundation (I, T, DM contracts) lands.

## How to run (one task per iteration)

> \`/loop\` Đọc \`docs/agent/build/README.md\`, chọn task **pending** đầu tiên (\`[ ]\`)
> tôn trọng thứ tự phase + deps (I → T/DM → {FE: P→K→S | BE: DM→DT} → V). Đọc + thực
> thi ĐẦY ĐỦ file prompt của task đó (baseline → đọc source → build đúng layer →
> test đúng tầng (domain unit / data integration / widget+golden) → \`build_runner\`
> + \`gen_tokens --check\` + \`dart analyze\` + \`flutter test\` → §Ledger → commit →
> push → PR → merge), rồi đổi ô đó thành \`[x]\`. Mỗi vòng đúng 1 task. Nếu prompt bảo
> **STOP** (drift / ambiguity cần người quyết) → dừng, báo, chờ. \`[~]\` = deferred,
> bỏ qua. Hết pending → báo HOÀN TẤT.

**Order & parallelism**: Phase **I** unblocks everything. Then **T** (theme) and
**DM** (domain contracts) open the two tracks. FE: **P → K → S** (K shells unblock
screens). BE: **DM.4 SRS → DT** (Drift). Screens use in-memory fakes until **DT.5**
wires real repositories. **S.01 dashboard is the pilot** — do it, pause for review,
then fan out.

## Queue

${tables}

_Regenerate: \`node tool/design/gen_task_prompts.mjs\`._
`;
}

mkdirSync(OUT, { recursive: true });
for (const f of readdirSync(OUT)) if (f.endsWith('.md') && f !== 'README.md') rmSync(join(OUT, f));
for (const r of rows) writeFileSync(join(OUT, r.file), r.md);
writeFileSync(join(OUT, 'README.md'), renderReadme());
console.log(`✓ ${rows.length} task prompts + README -> docs/agent/build/`);
