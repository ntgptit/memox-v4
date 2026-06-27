# Task: Flashcard (Card) CRUD + multi-field meanings  [W2]

> Loop step 2/13 · depends on: **S0 merged** · do not start before the shell + Drift DB exist.

## Stack
Flutter / Dart 3 · Riverpod (annotation) · go_router · Drift · per `docs/stack/stack.md`.

## Scope (this iteration only)
**BE**
- Entities: `Card`, `CardMeaning` (value object: lang + free text, non-empty).
- Types (from `types-catalog`): `CardStatus` (derived from `srs_state.box` + `hidden` — do NOT store).
- Drift tables `card` + `card_meaning` (+ migration step) per `schema-contract`.
- `CardRepository` (interface + impl) + DAO. Use cases: create card, edit card, delete card (cascade
  meanings + srs), add/remove secondary meaning, toggle hidden, soft-duplicate check.
- All use cases return `Result<T>` (`core/error` + `domain/types`); map exceptions to `Failure` at the
  repository boundary.

**FE**
- Screen `05-flashcard-editor` (create/edit) with viewmodel; states: create · edit · validation ·
  duplicate · multi-meaning · audio. Reuse `Mx*` + tokens.
- Route: `flashcardEditor` (`/deck/:id/card`) via `RoutePaths`.

**OUT of scope:** deck tree/list (W6), SRS scheduling (W3), study/games.

## Required reading (read ONLY these)
- Universal: `docs/_generated/{repo-map,where-is}.md` · `docs/business/index.md` · `docs/business/glossary.md`
  · `docs/contracts/{error-contract,types-catalog,code-style}.md` · `docs/architecture/overview.md`
  · `docs/state/state-management-contract.md`
- Spec: `docs/business/flashcard/flashcard-management.md`
- Decision rows: `docs/decision-tables/core-decision-table.md` → **D-006** (hidden excluded), **D-020** (soft dup)
- Data: `docs/database/{schema-contract,migration-contract,storage-boundaries}.md` (tables `card`, `card_meaning`)
- Contracts: `docs/contracts/usecase-contracts/_template.md`, `docs/contracts/repository-contracts/_template.md`
- Design (FE): `docs/design/screens/05-flashcard-editor.md` · `docs/ui-ux/ui-ux-contract.md` · `docs/design/design-language.md`
- Route: `docs/business/navigation/navigation-flow.md`

## Drift check
Compare docs to code. If docs lag, **STOP** and report `DRIFT DETECTED`.

## Acceptance criteria (derive from spec §7 + decision rows; must include)
- [ ] **D-020:** creating/importing a card with a term already in the deck → **soft warning, still allowed** (not blocked) — test.
- [ ] **D-006:** a `hidden` card is excluded from study queues and due counts — test.
- [ ] Card with ≥1 meaning (native; optional secondary); meaning text non-empty (`ValidationFailure` otherwise).
- [ ] Delete card cascades its meanings + srs_state — test.
- [ ] Editor renders every state in `05-flashcard-editor.md`; Save disabled until valid term + meaning.
- [ ] Route via `RoutePaths`; no hardcoded copy/colors; l10n keys for all strings.

## Implement (layer order)
entity → `CardMeaning` value object → repo interface → Drift table/DAO → repo impl → use cases →
`@riverpod` editor viewmodel → screen/widgets → route. `build_runner` for codegen; never hand-edit generated.

## Dependency gate
No new deps beyond S0 (`mocktail` for tests is OK). Anything else → **STOP & ask**.

## Parity (same commit)
Update: `flashcard-management.md` status, decision-table tests for D-006/D-020, `schema`+`migration` docs,
`navigation-flow` if route detail changes, `wbs.md` W2 status + traceability, status table in
`business/system/overview.md`, `where-is` source paths, l10n copy contract keys.

## Verify
Inner `node tool/verify/run.mjs --quick` · End `node tool/verify/run.mjs --full`.

## After verify PASS, before report
Fan out `code-reviewer` + `docs-drift-detector` on the diff; fix blockers.

## Commit & report
Commit `feat(flashcard): card CRUD + multi-field meanings`. Report: files · docs updated · verify · WBS · out-of-scope.
