# MemoX V4 — Build prompt pack (loop queue)

Self-contained task prompts to build the whole app (**BE + FE**) feature-by-feature
per the design kit. **Run ONE file per loop iteration.** Each file is scoped so the
agent reads only what that feature needs — this keeps context small and stops the
UI/spec from overflowing the window or being implemented wrong.

> Built on W1 (foundation: `core/theme`, `core/error`, `domain/types`, router, DI).
> Folder concept is removed — decks self-nest (`deck.parent_deck_id`).

> **Copy-paste driver:** see `prompts/RUN-LOOP.md` for the ready-to-run loop prompt
> (paste into a fresh session each iteration — it auto-detects the next step).

## How to run (one iteration = one file)
1. Open the next file in the order below.
2. Paste its **full content** into a **fresh** Claude Code session: `/loop <file content>`
   (or hand it to an agent). Each file is standalone — no memory of prior iterations.
3. The agent follows the file: read → drift-check → implement (BE→FE) → `verify --full`
   → review fan-out → commit.
4. Start step N+1 only after step N is merged (see Depends-on).

Do **not** run two steps in one session (context bleed). One file → one fresh loop.

## Loop order (dependency-topological)
| # | File | WBS | Builds | Depends on |
|---|------|-----|--------|------------|
| 1 | `01-S0-app-shell-language-pair.md` | foundation+ | Drift DB + codegen setup · `language_pair` · app shell (bottom nav + drawer) · nav wiring | W1 |
| 2 | `02-W2-flashcard.md` | W2 | Card + meanings CRUD · hide · soft-duplicate | S0 |
| 3 | `03-W6-deck-tree.md` | W6 | Deck self-nesting tree — **library home** + deck detail (node) | W2 |
| 4 | `04-W3-srs.md` | W3 | 8-box Leitner engine (no own screen) | W2 |
| 5 | `05-W5-game.md` | W5 | 4 games + picker | W2 |
| 6 | `06-W4-study.md` | W4 | 5 entries · NewLearn 5 stages · review · player · result | W3, W5, W6 |
| 7 | `07-W7-search.md` | W7 | term+meaning search | W2 |
| 8 | `08-W8-import-export.md` | W8 | CSV / Excel / clipboard | W6 |
| 9 | `09-W11-engagement.md` | W11 | Today dashboard · daily goal · streak | W4 |
| 10 | `10-W9-statistics.md` | W9 | learning stats | W3, W11 |
| 11 | `11-W10-account-sync.md` | W10 | Google sign-in + Drive sync | S0 |
| 12 | `12-W12-settings.md` | W12 | settings + reminders | S0 |
| 13 | `13-W13-personalization.md` | W13 | theme picker | W12 |

## Conventions every file enforces (so the loop never drifts)
- **Architecture:** Clean — domain imports nothing outward, presentation→domain (never data),
  data implements domain. Layer order: entity → contract → use case → `@riverpod` state → UI.
- **Stack:** Riverpod annotation + go_router + Drift (`docs/stack/stack.md`). A new dependency
  needs approval — **STOP & ask** if it is not already in `stack.md`.
- **Source of truth = `docs/`.** Every code change updates its docs in the **SAME commit**
  (CLAUDE.md parity check). Decision-table row touched → a test asserts its *Then*.
- **Verify ONLY** via `node tool/verify/run.mjs` (`--quick` inner loop, `--full` at end — writes
  the marker the pre-commit hook requires). Never run analyze/test/format loose.
- **No hardcoded** routes/colors/strings/durations. Reuse `Mx*` components + design tokens;
  user-facing copy via l10n keys.
- **Generated files** (`*.g.dart`, `*.drift.dart`, `lib/l10n/generated/**`) via `build_runner`
  — never hand-edit.
- After `verify --full` PASS, before the report: fan out `code-reviewer` + `docs-drift-detector`
  on the working-tree diff (`docs/agent/orchestration.md`); fix blockers.

## New-dependency gates (each flagged in its file — need your approval)
| Step | Packages | In stack.md? |
|---|---|---|
| S0 / W2 | drift · drift_dev · build_runner · riverpod_annotation · riverpod_generator | **Yes → OK** |
| tests (all) | mocktail | Yes (testing row) → OK |
| W8 | file_picker · csv · excel | **No → STOP & ask** |
| W10 | google_sign_in · googleapis (Drive) · extension_google_sign_in | **No → STOP & ask** |
| W12 | flutter_local_notifications · timezone | **No → STOP & ask** |

## Per-file shape
Each file = the project task envelope (`docs/agent/agent-task-template.md`): Scope (BE+FE) ·
Required reading (exact list) · Drift check · Acceptance criteria · Implement (layer order) ·
Dependency gate · Parity · Verify · Review fan-out · Commit & report.
