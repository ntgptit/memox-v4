# Task: Import / Export (CSV · Excel · clipboard)  [W8]

> Loop step 8/13 · depends on: **W6 merged** (imports land into a deck).

## Stack
Flutter / Dart 3 · Riverpod (annotation) · go_router · per `docs/stack/stack.md`.

## Scope (this iteration only)
**BE**
- Types `ImportFormat` (csv · excel · clipboard), `Separator` (tab · comma · semicolon · custom).
  Failure `ImportFailure` (row-level → maps to `ValidationFailure`) per `error-contract`.
- Use cases: parse source → preview rows → map columns → import into a target deck (apply soft-dup D-020);
  export a deck (optionally its subtree) to CSV/Excel/clipboard, with optional SRS state included.

**FE**
- Screens: `21-import` (source · mapping · preview · dup-warning · done), `22-export`
  (config · exporting · done; scope = This deck / Incl. sub-decks). Viewmodels. Reuse `Mx*` + tokens.
- Routes: reachable from Library overflow (no new top-level route unless `navigation-flow` says so).

**OUT of scope:** Google Drive sync (W10).

## Required reading (read ONLY these)
- Universal (see W2 list).
- Spec: `docs/business/import-export/import-export.md`.
- Decision rows: → **D-025** (import: separator, preview, dup-warn reuse D-020), **D-026** (export: format +
  optional SRS).
- Design (FE): `docs/design/screens/21-import.md`, `22-export.md` · `docs/ui-ux/ui-ux-contract.md` · `design-language.md`.
- Contracts: usecase `_template.md`. Data: `schema-contract` (card/meaning/srs for export payload).

## Drift check
Compare docs to code. If docs lag, **STOP** and report `DRIFT DETECTED`.

## ⚠ Dependency gate (NOT in stack.md → STOP & ask before adding)
File parsing/picking likely needs `file_picker`, `csv`, `excel`. These are **not** in `docs/stack/stack.md`.
**STOP and ask for approval**, then add them to `pubspec.yaml` + `stack.md` in the same commit. Do not add silently.

## Acceptance criteria
- [ ] **D-025:** import splits columns by the chosen separator, shows a preview, applies the soft-duplicate warning.
- [ ] **D-026:** export produces CSV / Excel / clipboard text with the configured separator and an optional
      "include review state" toggle.
- [ ] Import targets a specific deck; malformed rows surface as row-level `ValidationFailure` (not a crash).
- [ ] All `21-import` / `22-export` states render; no hardcoded copy/colors; l10n keys.

## Implement (layer order)
types/failures → parse + import/export use cases → `@riverpod` viewmodels → screens/widgets. `build_runner`.

## Parity (same commit)
Update: `import-export.md` status, decision-table tests D-025/D-026, `stack.md` (deps),
`wbs.md` W8 status + traceability, `business/system/overview.md`, `where-is`, l10n keys.

## Verify
Inner `--quick` · End `--full`.

## After verify PASS, before report
Fan out `code-reviewer` + `docs-drift-detector`; fix blockers.

## Commit & report
Commit `feat(import-export): CSV/Excel/clipboard import & export`. Report: files · docs · verify · WBS · deps added · out-of-scope.
