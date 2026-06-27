# Task: Study flow — 5 entries (NewLearn 5 stages · DueReview · Review · Player · Result)  [W4]

> Loop step 6/13 · depends on: **W3 + W5 + W6 merged** · ties SRS + games + deck tree into the learning loop.

## Stack
Flutter / Dart 3 · Riverpod (annotation) · go_router · per `docs/stack/stack.md`.

## Scope (this iteration only)
**BE**
- Type `StudyEntry` (dueReview · newLearn · review · game · player). Use cases: build the Play menu for a
  node (entries available; "Lặp lại" only when due>0), build NewLearn queue (5-stage chain), build DueReview
  queue (recursive over the deck subtree), grade → drive SRS (W3), finalize session (DailyActivity ++ for
  DueReview/NewLearn only), Review/Player read-only.
- Reuses `SrsRepository` (W3), game round logic (W5), deck/card repos (W6/W2). No new table except writing
  `daily_activity` rows on finalize (table is fully built in W11 — here create only what finalize needs, or
  coordinate: if `daily_activity` not yet present, add its Drift table + migration here and reuse in W11).

**FE**
- Screens: `06-study-session` (5 stages + relearn + due-review + exit + error states), `12-review`,
  `13-player` (auto-play), `14-study-result`. `StudySessionNotifier` per `state-management-contract`.
- Routes: `study` (`/study/:nodeId`, entry), `review` (`/review/:nodeId`), `player` (`/player/:nodeId`) via `RoutePaths`.

**OUT of scope:** the games themselves (W5 done — just invoke), Today dashboard (W11), stats (W9).

## Required reading (read ONLY these)
- Universal (see W2 list).
- Spec: `docs/business/study/study-flow.md` (+ `srs-review.md` for grading, `game-modes.md` for game entry).
- Decision rows: → **D-001** (Lặp lại ôn due), **D-009** (study at a parent deck = recursive over subtree),
  **D-010** (DailyActivity only from DueReview/NewLearn), **D-014** (Player no SRS change), **D-015** (relearn),
  **D-016** (due=0 hides Lặp lại), **D-017** (quit NewLearn mid-way → stays new), **D-029** (finish a DueReview
  mode → "học lại" same mode), **D-007** (Review/Game/Player don't change SRS).
- Design (FE): `docs/design/screens/06-study-session.md`, `12-review.md`, `13-player.md`, `14-study-result.md`
  · `docs/ui-ux/ui-ux-contract.md` · `docs/design/design-language.md`.
- Contracts: usecase `_template.md`. Data: `schema-contract` (`daily_activity`, `srs_state`). Route: `navigation-flow.md`.

## Drift check
Compare docs to code. If docs lag, **STOP** and report `DRIFT DETECTED`.

## Acceptance criteria (one test per decision row)
- [ ] **D-001 / D-016:** Play menu shows "Lặp lại" with the due count only when due>0; hidden when due=0.
- [ ] **D-002 / D-017:** NewLearn completes all 5 stages → card box0→box1 (via W3); quitting mid-way keeps it new.
- [ ] **D-009:** starting study at a parent deck builds a queue over **all descendant** cards (recursive).
- [ ] **D-010:** only DueReview/NewLearn add to `DailyActivity` (seconds + words); Review/Game/Player do not.
- [ ] **D-014 / D-007:** Player and Review change no `SrsState`.
- [ ] **D-015 / D-029:** wrong → relearn; finishing a DueReview mode offers "học lại" the same mode.
- [ ] All states of the 4 screens render; routes via `RoutePaths`; no hardcoded copy/colors; l10n keys.

## Implement (layer order)
type → use cases (queue builders + finalize) → `@riverpod` `StudySessionNotifier` → 4 screens/widgets → routes.
Grade path calls the W3 SRS use cases (don't re-implement scheduling). `build_runner` for codegen.

## Dependency gate
No new deps (TTS/audio for Player is a placeholder/`audio_ref`; real TTS later → STOP & ask if attempted).

## Parity (same commit)
Update: `study-flow.md` status, decision-table tests for all rows above, `schema`+`migration` (if
`daily_activity` added here), `navigation-flow` (study/review/player), `state-management-contract`,
`wbs.md` W4 status + traceability, `business/system/overview.md` status, `where-is`, l10n keys.

## Verify
Inner `--quick` · End `--full`.

## After verify PASS, before report
Fan out `code-reviewer` + `docs-drift-detector`; fix blockers.

## Commit & report
Commit `feat(study): five study entries + NewLearn/DueReview/review/player/result`. Report: files · docs · verify · WBS · out-of-scope.
