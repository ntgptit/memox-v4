# Task: Statistics  [W9]

> Loop step 10/13 · depends on: **W3 + W11 merged** (reads SRS + engagement data).

## Stack
Flutter / Dart 3 · Riverpod (annotation) · go_router · Drift · per `docs/stack/stack.md`.

## Scope (this iteration only)
**BE**
- Read-model use cases over existing tables: library overview (pairs / decks / cards; % mastered),
  accuracy, activity over time, box distribution. Scope = current pair (default) with a toggle to all-app.
  No new persisted entity — derive from `card`/`srs_state`/`daily_activity`.

**FE**
- Screen `16-statistics` (loaded · scope-switch · insufficient · loading). Viewmodel. Reuse `Mx*` + tokens
  (charts built from primitives/tokens — no raw values).

**OUT of scope:** engagement streak logic (W11), settings.

## Required reading (read ONLY these)
- Universal (see W2 list).
- Spec: `docs/business/statistics/statistics.md`.
- Decision rows: none specific — assert the read models against `srs-review` + `dashboard-engagement` rules.
- Design (FE): `docs/design/screens/16-statistics.md` · `docs/ui-ux/ui-ux-contract.md` · `design-language.md`.
- Data: `schema-contract` (`card`, `srs_state`, `daily_activity`). `docs/quality/performance-contract.md`.
- Contracts: usecase `_template.md`.

## Drift check
Compare docs to code. If docs lag, **STOP** and report `DRIFT DETECTED`.

## Acceptance criteria
- [ ] Library overview counts (pairs / decks / cards / % mastered) match the underlying data — test on read model.
- [ ] Scope toggle switches current-pair ↔ all-app; "insufficient data" state when too little history.
- [ ] All `16-statistics` states render; no hardcoded colors/strings; tokens + l10n keys.

## Implement (layer order)
read-model use cases → `@riverpod` stats viewmodel → screen/charts (from `Mx*` + tokens). `build_runner`.

## Dependency gate
Prefer building charts from existing primitives/tokens. A charting package is **not** in `stack.md` →
if you truly need one, **STOP & ask** before adding.

## Parity (same commit)
Update: `statistics.md` status, any decision rows added, `wbs.md` W9 status + traceability,
`business/system/overview.md`, `where-is`, l10n keys.

## Verify
Inner `--quick` · End `--full`.

## After verify PASS, before report
Fan out `code-reviewer` + `docs-drift-detector`; fix blockers.

## Commit & report
Commit `feat(statistics): learning stats with scope toggle`. Report: files · docs · verify · WBS · out-of-scope.
