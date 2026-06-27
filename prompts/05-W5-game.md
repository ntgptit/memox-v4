# Task: Practice games (4) + picker  [W5]

> Loop step 5/13 · depends on: **W2 merged** · games are practice-only (never change SRS).

## Stack
Flutter / Dart 3 · Riverpod (annotation) · go_router · per `docs/stack/stack.md`.

## Scope (this iteration only)
**BE**
- Types `GameType` (matching · multipleChoice · recall · typing), `GameScope` (spaced · all · notMastered).
- Use cases: build a game round (N cards, default 5, random when enabled), evaluate answer, relearn-on-wrong
  within the round. **No SRS mutation** (practice only). Reads cards via the card/deck repos (no new table).

**FE**
- Screens: `07-game-picker` (+ scope dropdown / not-enough), `08-game-matching`, `09-game-multiple-choice`,
  `10-game-recall`, `11-game-typing`. `GameSessionNotifier` per `state-management-contract`. Reuse `Mx*` + tokens.
- Routes: `game` (`/game/:nodeId`, gameType) via `RoutePaths`.

**OUT of scope:** NewLearn/DueReview SRS flow (W4), study result screen (W4).

## Required reading (read ONLY these)
- Universal (see W2 list).
- Spec: `docs/business/game/game-modes.md` (+ `docs/business/study/study-flow.md` for the menu entry).
- Decision rows: → **D-008** (5 words/round), **D-013** (picker = 1 of 4 games), **D-015** (wrong → relearn,
  round ends when all correct), **D-007** (Game does NOT change `SrsState`).
- Design (FE): `docs/design/screens/07-game-picker.md` … `11-game-typing.md`
  · `docs/ui-ux/ui-ux-contract.md` · `docs/design/design-language.md`.
- Contracts: usecase `_template.md`. Route: `navigation-flow.md`.

## Drift check
Compare docs to code. If docs lag, **STOP** and report `DRIFT DETECTED`.

## Acceptance criteria (one test per decision row)
- [ ] **D-008:** a round uses `game_words_per_round` cards (default 5; random when `game_random`).
- [ ] **D-013:** picker offers exactly the 4 games; the chosen one runs standalone.
- [ ] **D-015:** a wrong answer re-queues the card; the round completes only when every card is correct.
- [ ] **D-007:** finishing any game leaves `SrsState` unchanged — test.
- [ ] All states of each of the 5 game screens render (playing/selected/correct/wrong/complete etc.).
- [ ] Routes via `RoutePaths`; no hardcoded copy/colors; l10n keys.

## Implement (layer order)
types → use cases (round builder + evaluator) → `@riverpod` `GameSessionNotifier` → 5 screens/widgets → route.
Keep each game screen lean; share round/scoring logic. `build_runner` for codegen.

## Dependency gate
No new deps (audio is `audio_ref` placeholder; real TTS is later). Else → **STOP & ask**.

## Parity (same commit)
Update: `game-modes.md` status, decision-table tests D-007/D-008/D-013/D-015, `navigation-flow` (game route),
`state-management-contract` (GameSessionNotifier), `wbs.md` W5 status + traceability,
`business/system/overview.md` status, `where-is`, l10n keys.

## Verify
Inner `--quick` · End `--full`.

## After verify PASS, before report
Fan out `code-reviewer` + `docs-drift-detector`; fix blockers.

## Commit & report
Commit `feat(game): four practice games + picker`. Report: files · docs · verify · WBS · out-of-scope.
