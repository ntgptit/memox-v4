# WBS — MemoX kit → Flutter build

Work Breakdown Structure for turning the frozen **MemoX Design System** kit into
the Flutter app, following the 4-tier plan: **Token → Component → Screen →
Verify**. Grounded in the kit audit (2026-07-03): 116 used tokens, 18 reusable
components (15 shared + 3 cross-feature), 22 screens, 65 feature-local
components.

> **Loop execution.** Every task below has a self-contained loop prompt under
> [`docs/agent/build/`](../agent/build/README.md) (one `.md` per task, generated
> by `tool/design/gen_task_prompts.mjs`). Run them with `/loop` — the queue
> README picks the next pending task by phase + deps.

## Conventions

- **ID**: `<phase>.<n>` (e.g. `F.3`, `C1.04`, `S.07`). Sub-steps `a/b/c`.
- **Status**: ☐ todo · ◐ in progress · ☑ done · ⊘ deferred.
- **Size**: S (≤½ day) · M (~1 day) · L (multi-day).
- **Source of truth**: the kit is frozen; Dart mirrors it. Never edit the kit to
  fit Flutter — if the kit is wrong, fix it in Claude Design and `/design-sync`.
- **Kit paths** are relative to `docs/design/MemoX Design System/`.
- **Strings** come from ARB (l10n), never hardcoded — even in the kit the copy is
  placeholder; real copy lives in ARB. [[kit-is-source-of-truth]]

### Definition of Done (applies to every Component & Screen task)

A task is ☑ only when ALL hold:

1. **Built** — Dart file(s) at the mapped path; no raw `Color(0x..)`/px literals —
   only `MxColors`/`MxSpacing`/`MxRadius`/`MxTypography`/`MxShadows` tokens.
2. **Analyzes** — `dart analyze lib test` → 0 issues.
3. **Tested** — widget/golden test proving structure + that token values reach
   the tree (both light & dark where the component is theme-varying).
4. **Parity** — visually matches the kit reference (`.jsx` render / `shots/*.png`)
   for every state the kit defines; deviations documented, not silent.
5. **Ledger** — an entry in §Ledger mapping kit node(s) → Dart symbol(s) →
   test(s). Reviewer blocks on incomplete ledgers. [[kit-to-flutter-ledger-completeness]]
6. **Gates green** — `node tool/design/gen_tokens.mjs --check` + `flutter test` pass.

### Verification commands

```bash
node tool/design/gen_tokens.mjs --check   # token drift gate
dart analyze lib test                     # static
flutter test                              # widget + golden
```

---

## Phase 0 — Tokens (Tier 0) ☑ DONE

| ID | Task | Status | Ref |
|----|------|--------|-----|
| P0.1 | `gen_tokens.mjs` — parse kit CSS → Dart mirrors | ☑ | [#33](https://github.com/ntgptit/memox-v4/pull/33) |
| P0.2 | Generated `lib/core/theme/mx_*.dart` (colors/type/spacing/radius/elevation/sizes) | ☑ | #33 |
| P0.3 | `--check` gate line-ending-agnostic (Windows CRLF) + `.gitattributes` | ☑ | [#34](https://github.com/ntgptit/memox-v4/pull/34) |
| P0.4 | Prune defined-but-unused tokens (135→116); drop `mx_motion.dart` | ☑ | [#36](https://github.com/ntgptit/memox-v4/pull/36) |
| P0.5 | Wire tokens into `main.dart` + render-confirm widget tests | ☑ | [#35](https://github.com/ntgptit/memox-v4/pull/35) |

---

## Phase F — Foundation (Tier 1 prerequisites)

Everything below must land before component work; screens depend on all of F.

| ID | Task | Size | Deps | Acceptance |
|----|------|------|------|-----------|
| **F.1** | **Folder layout scaffold** — establish `lib/` mirror of the kit (see §Layout). Create dirs + barrel files; no logic. | S | — | Dirs exist; `dart analyze` clean; documented in this file. |
| **F.2** | **Font wiring** — register `Plus Jakarta Sans` variable TTF (`fonts/PlusJakartaSans[wght].ttf`) in `pubspec.yaml`; confirm weights 400–800 render. | S | F.1 | `MxTypography.fontFamily` renders real glyphs (golden). |
| **F.3** | **Theme assembly** — `app_theme.dart` (`ThemeData` light/dark from tokens) + `mx_theme.dart` (`ThemeExtension` for roles Material can't express: surface tiers, semantic soft colors, state overlays, `MxShadows`, radii). | L | F.1, F.2 | `Theme.of(context).extension<MxTheme>()` exposes all non-Material roles; light+dark golden of a sample surface. |
| **F.4** | **Material component themes** — map tokens onto `ElevatedButtonTheme`, `CardTheme`, `AppBarTheme`, `NavigationBarTheme`, `ChipTheme`, `SwitchTheme`, `DialogTheme`, `InputDecorationTheme` so stock widgets inherit kit look. | M | F.3 | Stock `FilledButton`/`Card` match kit without per-call styling. |
| **F.5** | **l10n / ARB scaffold** — `flutter_localizations` + `l10n.yaml` + `app_en.arb`; a `Strings.of(context)` accessor. Placeholder copy from kit specs. | M | F.1 | Generated `AppLocalizations`; one string proven end-to-end. |
| **F.6** | **Verification harness** — golden-test setup (`golden_toolkit` or built-in), fonts loaded in tests; `flutter test` + `gen_tokens --check` + `dart analyze` wired into `pre-commit` / CI. | M | F.2, P0.3 | A failing golden fails CI; `--check` fails CI on token drift. |
| **F.7** | **Retire the swatch showcase** — replace `main.dart` demo with a real app shell (`MxScaffold` + bottom nav) once F.3/Phase-1 shells exist; keep render-confirm tests. | S | C1.11 | `main.dart` boots the real shell, not the swatch page. |

---

## Phase C1 — Reusable components (Tier 1) — 18 widgets

**Per-task inputs** (for every `Cn`): the component's `.d.ts` (typed contract) +
`.prompt.md` (intent) + `.jsx` (class→CSS mapping) + its slice of
`components.css` (or `_shared/*.md` for the helpers). **Per-task output**: the
mapped Dart file + its test. All follow the §Definition of Done.

> Build order respects dependency: **atoms → surfaces → shells → helpers**.
> Shells (`MxScaffold`, `MxAppBar`, `MxBottomNav`) unblock every screen, so the
> critical path runs C1.01→…→C1.13 before Phase S can start in earnest.

### 1A — Atoms (`lib/presentation/shared/widgets/core/`)

| ID | Component | Kit source | Output | Size |
|----|-----------|-----------|--------|------|
| C1.01 | MxButton | `components/core/MxButton.*` | `core/mx_button.dart` | M |
| C1.02 | MxIconButton | `components/navigation/MxIconButton.*` | `core/mx_icon_button.dart` | S |
| C1.03 | MxAvatar | `components/core/MxAvatar.*` | `core/mx_avatar.dart` | S |
| C1.04 | MxBadge | `components/core/MxBadge.*` | `core/mx_badge.dart` | S |
| C1.05 | MxChip | `components/core/MxChip.*` | `core/mx_chip.dart` | S |
| C1.06 | MxSwitch | `components/core/MxSwitch.*` | `core/mx_switch.dart` | M |
| C1.07 | MxSegmentedControl | `components/core/MxSegmentedControl.*` | `core/mx_segmented_control.dart` | M |

### 1B — Surfaces (`lib/presentation/shared/widgets/surfaces/`)

| ID | Component | Kit source | Output | Size |
|----|-----------|-----------|--------|------|
| C1.08 | MxCard (variants: flat/muted/primary/primary-soft; padding sm) | `components/surfaces/MxCard.*` | `surfaces/mx_card.dart` | M |
| C1.09 | MxIconTile | `components/surfaces/MxIconTile.*` | `surfaces/mx_icon_tile.dart` | S |
| C1.10 | MxSectionHeader (title/caption/action) | `components/surfaces/MxSectionHeader.*` | `surfaces/mx_section_header.dart` | S |

### 1C — Shells & navigation (`lib/presentation/shared/widgets/{surfaces,navigation}/`)

| ID | Component | Kit source | Output | Size |
|----|-----------|-----------|--------|------|
| C1.11 | MxScaffold (appBar + scroll body + bottomNav + fab slots) | `components/surfaces/MxScaffold.*` | `surfaces/mx_scaffold.dart` | L |
| C1.12 | MxAppBar (compact + large/hero: eyebrow/title/trailing) | `components/surfaces/MxAppBar.*` | `surfaces/mx_app_bar.dart` | M |
| C1.13 | MxBottomNav (5 items, active pill slide) | `components/navigation/MxBottomNav.*` | `navigation/mx_bottom_nav.dart` | M |
| C1.14 | MxFab (extended: icon + label) | `components/navigation/MxFab.*` | `navigation/mx_fab.dart` | S |
| C1.15 | MxSearchDock | `components/navigation/MxSearchDock.*` | `navigation/mx_search_dock.dart` | M |

### 1D — Cross-feature helpers (`lib/presentation/shared/widgets/feedback/`)

| ID | Component | Kit source | Output | Size |
|----|-----------|-----------|--------|------|
| C1.16 | ActionCallout (a.k.a. `Note` — icon + tone + text) | `ui_kits/memox-app/_shared/ActionCallout.*` | `feedback/action_callout.dart` | S |
| C1.17 | ConfirmDialog | `ui_kits/memox-app/_shared/ConfirmDialog.*` | `feedback/confirm_dialog.dart` | M |
| C1.18 | StatusCardRow | `ui_kits/memox-app/_shared/StatusCardRow.*` | `feedback/status_card_row.dart` | S |

**Phase C1 exit criteria**: a component gallery screen (mirrors kit `guidelines/`)
renders all 18 in light+dark; each has a passing golden.

---

## Phase S — Screens (Tier 2) — 22 features

**Per-task inputs**: `_features/<f>/<Screen>.jsx` + `_features/<f>/components/*.jsx`
(feature-local) + `specs/<f>.md` (contract) + `shots/<f>--*--{light,dark}.png`
(every state). **Output**: `lib/presentation/features/<f>/<f>_screen.dart` +
`.../widgets/*.dart` (feature-local) + tests. Feature-local components are built
**within** their screen task (not Phase C1).

> **Pilot first**: S.01 Dashboard is the reference implementation — it exercises
> the most shells (Scaffold/AppBar/BottomNav/Fab/Card/SectionHeader) and proves
> the Tier-1→Tier-2 seam before fanning out. Do it, review, then parallelize.

| ID | Feature | Local comps | States (from shots) | Size | Deps |
|----|---------|:-----------:|--------------------|------|------|
| S.01 | **dashboard** (pilot) | 4 | empty·loaded·loading·goal-met·streak-reset | L | Phase C1 |
| S.02 | library | 6 | per spec | L | C1 |
| S.03 | deck-detail | 5 | per spec | L | C1 |
| S.04 | search | 2 | per spec | M | C1 |
| S.05 | settings | 2 | per spec | M | C1 |
| S.06 | drawer | 4 | per spec | M | C1 |
| S.07 | reminder | 2 | per spec | M | C1 |
| S.08 | theme | 2 | per spec | M | C1 |
| S.09 | statistics | 3 | per spec | L | C1 |
| S.10 | import | 2 | per spec | M | C1 |
| S.11 | export | 2 | per spec | M | C1 |
| S.12 | flashcard-editor | 2 | per spec | M | C1 |
| S.13 | game-picker | 3 | per spec | M | C1 |
| S.14 | game-matching | 1 | per spec | M | C1, S.13 |
| S.15 | game-mc | 1 | per spec | M | C1, S.13 |
| S.16 | game-recall | 2 | per spec | M | C1, S.13 |
| S.17 | game-typing | 2 | per spec | M | C1, S.13 |
| S.18 | review | 2 | per spec | M | C1 |
| S.19 | player | 2 | per spec | M | C1 |
| S.20 | study-session | 9 | per spec | L | C1, S.18 |
| S.21 | study-result | 4 | per spec | M | C1, S.20 |
| S.22 | account-sync | 3 | signed-out·signed-in·syncing·offline·conflict | L | ⊘ DEFERRED (v1) |

**Phase S exit criteria**: every non-deferred screen renders every kit state in
light+dark with a passing golden; nav wires screens into the app shell.

---

## Phase V — Verification & hardening (cross-cutting)

| ID | Task | Size | Notes |
|----|------|------|-------|
| V.1 | Golden suite for all components + screen states (light+dark) | L | The real parity gate — at component layer, not per-pixel-per-screen. [[style-parity-blind-spots]] |
| V.2 | Accessibility pass — touch targets (`MxSpacing.minTouchTarget`), contrast, semantics labels | M | WCAG AA on interactive widgets. |
| V.3 | Responsive check — phone widths; large-screen graceful | M | Kit is phone-first (gutter 20, appbar 64/112). |
| V.4 | `/design-sync` → regenerate → drift-gate loop documented + in CI | S | Ties Tier 0 gate to the pull flow. [[design-sync-headless-invocation]] |
| V.5 | Prune-rule review when kit changes (motion re-included if app animates) | S | Re-run generator; log pruned set. [[tier0-token-generator]] |

---

## Layout (target `lib/`) — decided in F.1

```
lib/
├── core/
│   └── theme/
│       ├── mx_colors.dart mx_typography.dart mx_spacing.dart      # Tier 0 (generated)
│       ├── mx_radius.dart mx_elevation.dart mx_sizes.dart         # Tier 0 (generated)
│       ├── mx_theme.dart          # ThemeExtension: non-Material roles (F.3)
│       └── app_theme.dart         # ThemeData light/dark assembly (F.3)
├── l10n/                          # ARB + generated AppLocalizations (F.5)
├── presentation/
│   ├── shared/widgets/
│   │   ├── core/         # atoms  — MxButton, MxChip, MxAvatar, …      (C1.01–07)
│   │   ├── surfaces/     # MxCard, MxScaffold, MxAppBar, …             (C1.08–12)
│   │   ├── navigation/   # MxBottomNav, MxFab, MxSearchDock            (C1.13–15)
│   │   └── feedback/     # ActionCallout, ConfirmDialog, StatusCardRow (C1.16–18)
│   └── features/
│       └── <feature>/
│           ├── <feature>_screen.dart
│           └── widgets/            # feature-local components (Phase S)
└── main.dart                      # app shell (F.7)
```

Mirrors the kit 1-1: `tokens/`→`core/theme`, `components/{core,navigation,surfaces}`
→ `shared/widgets/…`, `_shared/`→`shared/widgets/feedback`, `_features/<f>/`
→ `presentation/features/<f>/`.

---

## Critical path

```
F.1 → F.2 → F.3 → F.4/F.6 ─┐
                           ├─→ C1.01…C1.15 (shells last) → C1.16–18 → C1 gallery
F.5 (l10n) ────────────────┘                                    │
                                                                 ▼
                                              S.01 dashboard (pilot) → review
                                                                 │
                                              S.02…S.21 (parallelizable) → V.*
```

Bottleneck = **F.3 theme assembly** (all components need it) and **C1 shells**
(all screens need them). Everything after the pilot fans out.

---

## Ledger (kit node → Dart symbol → test)

_One row per delivered component/screen node. Populated as tasks land._

| Kit node | Dart symbol | Test | Task | PR |
|----------|-------------|------|------|----|
| _(tokens)_ | `lib/core/theme/mx_*.dart` | `widget_test.dart` | P0.* | #33–36 |

---

## Risks

- **R1 — Golden brittleness across platforms/fonts.** Mitigate: load the kit
  font in tests (F.6); tolerance thresholds; run goldens on one canonical host.
- **R2 — Feature-local scope creep.** 65 local components; some (game stages,
  library sheets) are heavy. Mitigate: pilot dashboard first, size-check per
  screen before committing.
- **R3 — Undrivable states.** Some kit states (error/loading) may not be
  reachable from a Result-based notifier — document as gaps, don't fight.
  [[kit-to-flutter-error-state-unreachable]]
- **R4 — Kit drift mid-build.** A `/design-sync` pull can change tokens/comps.
  Mitigate: `--check` gate (V.4) surfaces it; regenerate + re-golden.
