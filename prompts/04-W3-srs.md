# Task: SRS — 8-box Leitner engine  [W3]

> Loop step 4/13 · depends on: **W2 merged** · no own screen — this is the scheduling engine W4 consumes.

## Stack
Flutter / Dart 3 · Riverpod (annotation) · Drift · per `docs/stack/stack.md`.

## Scope (this iteration only)
**BE**
- `SrsState` entity (one row per card — single direction). Value objects: `LeitnerBox` (0..8), `BoxInterval`
  (box → days: 1·3·7·14·30·60·120; box8 = mastered, not scheduled). Type `LastResult` (correct/wrong, **stored**).
- Drift table `srs_state` (+ migration) + DAO + `SrsRepository`.
- Use cases: schedule new card (box0 → box1 **only after all 5 NewLearn stages**), grade (Đúng +1 cap 8 /
  Sai −1 floor 1), build due queue (exclude hidden; respect new-card daily cap), compute due count.

**FE:** none. (Study UI is W4.)

**OUT of scope:** study flow / NewLearn UI (W4), games (W5).

## Required reading (read ONLY these)
- Universal (see W2 list).
- Spec: `docs/business/srs/srs-review.md`.
- Decision rows: → **D-002** (new → box1 after 5 stages), **D-003** (Đúng +1), **D-004** (Sai −1, floor 1),
  **D-005** (box8 stays), **D-011** (single `SrsState` per card both directions), **D-018** (new-card cap, default 20).
- Data: `schema-contract` (`srs_state`, stored `last_result` encoding), `migration-contract`, `storage-boundaries`.
- Contracts: usecase + repository `_template.md`. `types-catalog` (LeitnerBox, BoxInterval, LastResult).

## Drift check
Compare docs to code. If docs lag, **STOP** and report `DRIFT DETECTED`.

## Acceptance criteria (one test per decision row)
- [ ] **D-002:** completing all 5 NewLearn stages moves a new card box0 → box1 with a due date; quitting mid-way keeps it new (box0).
- [ ] **D-003 / D-004:** grade Đúng → box+1 (cap 8); Sai → box−1 (floor 1); `due_at` recomputed by `BoxInterval`.
- [ ] **D-005:** box8 + Đúng stays box8 (mastered, not rescheduled).
- [ ] **D-011:** reversing display direction uses the **same** `SrsState` (one direction only).
- [ ] **D-018:** the due/new queue takes at most `new_cards_per_day` new cards (default 20).
- [ ] Hidden cards never enter the queue or due count (cross-check D-006).
- [ ] Stored `last_result` encoding matches `schema-contract` (a change = a migration).

## Implement (layer order)
entity → value objects → repo interface → Drift table/DAO → repo impl → use cases. `build_runner` for codegen.

## Dependency gate
No new deps. Else → **STOP & ask**.

## Parity (same commit)
Update: `srs-review.md` status, decision-table tests D-002..D-005/D-011/D-018, `schema`+`migration` docs,
`wbs.md` W3 status + traceability, `business/system/overview.md` status, `where-is`.

## Verify
Inner `--quick` · End `--full` (the SRS unit tests are the core proof here).

## After verify PASS, before report
Fan out `code-reviewer` + `docs-drift-detector`; fix blockers.

## Commit & report
Commit `feat(srs): 8-box Leitner scheduling engine`. Report: files · docs · verify · WBS · out-of-scope.
