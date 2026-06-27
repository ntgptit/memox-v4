# Task: Deck — self-nesting tree (library home + deck detail)  [W6]

> Loop step 3/13 · depends on: **W2 merged** · this builds the library home screen.

## Stack
Flutter / Dart 3 · Riverpod (annotation) · go_router · Drift · per `docs/stack/stack.md`.

## Scope (this iteration only)
**BE**
- `Deck` entity that **self-nests** via `parent_deck_id` (a deck is a mixed node: holds cards AND sub-decks).
- Drift table `deck` (`parent_deck_id` nullable self-FK) + migration; index `(pair_id, parent_deck_id, order_index)`.
- `DeckRepository` (interface + impl) + DAO. Use cases: create deck (at root or under a deck), rename, move
  (reject cycles), delete (cascade subtree), sort children, **recursive aggregate stats** (count / progress /
  due / hidden over the subtree), watch library tree.
- Types: `SortBy`, `SortDirection` (`types-catalog`).

**FE**
- Screen `01-library` (home / Library tab — list of root decks) and `04-deck-detail` (a node: SUB-DECKS
  section + CARDS section, mixed). Viewmodels per `state-management-contract` (`LibraryNotifier`,
  `DeckDetailNotifier`). Reuse `DeckRow`/`Mx*` + tokens.
- Routes: `library` (`/`) replaces the S0 placeholder; `deckDetail` (`/deck/:id`) via `RoutePaths`.

**OUT of scope:** card editor internals (W2 done), SRS scheduling (W3), study/games, import/export.

## Required reading (read ONLY these)
- Universal (see W2 list).
- Spec: `docs/business/deck/deck-management.md` (unified nested deck — folder removed).
- Decision rows: → **D-023** (sort), **D-024** (delete = cascade whole subtree). (Recursive *study* is D-009 in W4.)
- Data: `docs/database/{schema-contract,migration-contract,storage-boundaries}.md` (table `deck`).
- Contracts: usecase + repository `_template.md`.
- Design (FE): `docs/design/screens/01-library.md`, `docs/design/screens/04-deck-detail.md`
  · `docs/ui-ux/ui-ux-contract.md` · `docs/design/design-language.md`
- Route: `docs/business/navigation/navigation-flow.md`.

## Drift check
Compare docs to code. If docs lag, **STOP** and report `DRIFT DETECTED`.

## Acceptance criteria (must include)
- [ ] **D-024:** delete a deck → confirm → cascades the **whole subtree** (sub-decks + cards + meanings + srs) — test.
- [ ] **D-023:** sort by alphabet / created / last-studied with asc/desc — test on the read model.
- [ ] Move rejects creating a cycle (cannot move a deck into its own subtree) — test.
- [ ] A deck shows BOTH its sub-decks and its direct cards (mixed node); root list = decks with no parent.
- [ ] Aggregate counts (words / due / hidden / %) are computed **recursively** over the subtree — test.
- [ ] `01-library` + `04-deck-detail` render every design state (loading/empty/loaded/error + node menus/move).
- [ ] Routes via `RoutePaths`; no hardcoded copy/colors; l10n keys.

## Implement (layer order)
entity → repo interface → Drift table/DAO (self-FK) → repo impl → use cases → `@riverpod` `LibraryNotifier`
+ `DeckDetailNotifier` → screens/widgets → routes. `build_runner` for codegen; never hand-edit generated.

## Dependency gate
No new deps beyond S0/W2. Else → **STOP & ask**.

## Parity (same commit)
Update: `deck-management.md` status, decision-table tests D-023/D-024, `schema`+`migration` docs,
`navigation-flow` (library/deckDetail), `state-management-contract` (Library/DeckDetail notifiers),
`wbs.md` W6 status + traceability, `business/system/overview.md` status, `where-is`.

## Verify
Inner `--quick` · End `--full`.

## After verify PASS, before report
Fan out `code-reviewer` + `docs-drift-detector` on the diff; fix blockers.

## Commit & report
Commit `feat(deck): self-nesting deck tree (library + deck detail)`. Report: files · docs · verify · WBS · out-of-scope.
