# Task: App shell, navigation & language pair (data + codegen foundation)  [S0]

> Loop step 1/13 · depends on: **W1 merged** · this is the prerequisite for every feature.

## Stack
Flutter / Dart 3 · Riverpod (annotation) · go_router · **Drift (SQLite)** · per `docs/stack/stack.md`.

## Scope (this iteration only)
**BE**
- Establish the **Drift database** foundation: `lib/data/datasources/local/connection/`,
  `app_database` + `onCreate` with the `language_pair` table only (other tables land with their features).
- `LanguagePair` domain entity + `LanguagePairRepository` (interface in `domain/repositories`, impl in
  `data/repositories`) + DAO. Use cases: list pairs, create pair, set active pair, swap display direction.
- DI: register the database + repositories in `lib/app/di/` (real `Override`s; no in-memory-only state).
- Wire codegen: `riverpod_generator` + `drift_dev` + `build_runner`.

**FE**
- App shell: `MxScaffold` + **bottom nav** (Today · Library · Add · Stats · Profile) + the **Drawer**
  (`docs/design/screens/23-drawer.md`) with language-pair switcher (open / add-language / remove-language).
- Routing: register the shell + the named routes from `navigation-flow.md` as a `StatefulShellRoute`
  (or equivalent). Tabs whose screens are not built yet point to a minimal placeholder that later
  features replace. Keep the W1 root `/` but make it host the shell.

**OUT of scope:** any feature content (cards, decks, study, stats…). Only the shell + DB + language pair.

## Required reading (read ONLY these)
- `docs/_generated/repo-map.md`, `docs/_generated/where-is.md`
- `docs/business/index.md`, `docs/business/glossary.md` (LanguagePair, NativeLanguage)
- `docs/contracts/error-contract.md`, `docs/contracts/types-catalog.md`, `docs/contracts/code-style.md`
- `docs/architecture/overview.md`, `docs/state/state-management-contract.md`
- `docs/business/navigation/navigation-flow.md` (routes + initial `/` = library)
- `docs/business/system/overview.md` (capability map; pair context)
- `docs/database/schema-contract.md` (`language_pair`), `migration-contract.md`, `storage-boundaries.md`
- `docs/design/screens/23-drawer.md` + `docs/ui-ux/ui-ux-contract.md` + `docs/design/design-language.md`
- `docs/contracts/repository-contracts/_template.md`, `docs/contracts/usecase-contracts/_template.md`

## Drift check
Compare those docs to current code. If docs lag code, **STOP** and report `DRIFT DETECTED`.

## Acceptance criteria (make testable; must include)
- [ ] App boots into the shell; bottom nav switches tabs; drawer opens and lists language pairs.
- [ ] `language_pair` persists in Drift (create/list/set-active survive restart — Drift in-memory test).
- [ ] Active pair + display direction are app-wide state via a `@riverpod` provider (keepAlive).
- [ ] Every route is referenced via `RoutePaths` constants — no raw path strings.
- [ ] All drawer states in `23-drawer.md` render (open · add-language · remove-language).
- [ ] No hardcoded colors/strings/durations (tokens + l10n keys); reuse `Mx*` components.

## Implement (layer order)
entity → repo interface → Drift table/DAO → repo impl → `@riverpod` viewmodel → shell/drawer UI → routes.
Run `dart run build_runner build --delete-conflicting-outputs` for Drift + Riverpod codegen.
Do **not** hand-edit `*.g.dart` / `*.drift.dart`.

## Dependency gate (in stack.md → OK to add)
`flutter_riverpod` + `riverpod_annotation` (dep) · `riverpod_generator`, `drift_dev`, `build_runner` (dev) ·
`drift` + a SQLite impl (`sqlite3_flutter_libs` / `drift_flutter`) · `path_provider`, `path`.
Anything beyond this → **STOP & ask**.

## Parity (same commit)
8-step pre-commit parity. Update: `schema-contract`/`migration-contract` (language_pair already specified —
confirm), `navigation-flow` if routes change, `stack.md` (deps added), `wbs.md` (note shell as part of the
foundation + traceability line), `state-management-contract` if a new store is added, `where-is` source paths.

## Verify
Inner: `node tool/verify/run.mjs --quick` · End: `node tool/verify/run.mjs --full` (writes marker).

## After verify PASS, before report
Fan out `code-reviewer` + `docs-drift-detector` on the working-tree diff (`docs/agent/orchestration.md`); fix blockers.

## Commit & report
Commit `feat(shell): app shell, navigation & language pair (+ Drift/codegen foundation)`. Report:
files changed · docs updated (file + reason) · verify result · WBS/traceability · out-of-scope notes.
