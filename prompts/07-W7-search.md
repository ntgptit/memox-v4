# Task: Search — term + meaning  [W7]

> Loop step 7/13 · depends on: **W2 merged** (W6 helps for in-node scope).

## Stack
Flutter / Dart 3 · Riverpod (annotation) · go_router · Drift · per `docs/stack/stack.md`.

## Scope (this iteration only)
**BE**
- Use cases: search cards by `term` + `card_meaning.text` (global or within a node), with status filter
  (new/due/mastered) and **including hidden cards**. Read model over existing `card`/`card_meaning` tables
  (add an index/FTS only if the perf contract requires — document it).

**FE**
- Screen `15-search` (empty-recent · results · filtered · no-results · loading). Viewmodel. Reuse `Mx*` + tokens.
- Route: `search` (`/search`, query?) via `RoutePaths`.

**OUT of scope:** editing from results (link to W2 editor), study from results.

## Required reading (read ONLY these)
- Universal (see W2 list).
- Spec: `docs/business/search/global-search.md`.
- Decision rows: → **D-019** (match term + meaning), **D-028** (include hidden + status filter).
- Design (FE): `docs/design/screens/15-search.md` · `docs/ui-ux/ui-ux-contract.md` · `docs/design/design-language.md`.
- Data: `schema-contract` (`card`, `card_meaning`; any index added). `docs/quality/performance-contract.md`.
- Contracts: usecase `_template.md`. Route: `navigation-flow.md`.

## Drift check
Compare docs to code. If docs lag, **STOP** and report `DRIFT DETECTED`.

## Acceptance criteria
- [ ] **D-019:** a query matches on both `term` and meaning text — test on the read model.
- [ ] **D-028:** results include hidden cards (visually marked) and the status filter narrows them — test.
- [ ] Search can be global or scoped to a node; recent searches shown on empty.
- [ ] All `15-search` states render; route via `RoutePaths`; no hardcoded copy/colors; l10n keys.

## Implement (layer order)
read-model use case → `@riverpod` search viewmodel → screen/widgets → route. `build_runner` for codegen.
If adding an index/FTS table, write the migration + schema-doc update in the same commit.

## Dependency gate
No new deps. Else → **STOP & ask**.

## Parity (same commit)
Update: `global-search.md` status, decision-table tests D-019/D-028, `schema`+`migration` if index added,
`navigation-flow` (search), `wbs.md` W7 status + traceability, `business/system/overview.md`, `where-is`, l10n keys.

## Verify
Inner `--quick` · End `--full`.

## After verify PASS, before report
Fan out `code-reviewer` + `docs-drift-detector`; fix blockers.

## Commit & report
Commit `feat(search): term + meaning search with filters`. Report: files · docs · verify · WBS · out-of-scope.
