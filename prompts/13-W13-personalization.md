# Task: Personalization — theme (mode · accent · font size)  [W13]

> Loop step 13/13 · depends on: **W12 merged** (theme prefs live in settings).

## Stack
Flutter / Dart 3 · Riverpod (annotation) · go_router · per `docs/stack/stack.md`.

## Scope (this iteration only)
**BE**
- Type `ThemeMode` (light · dark · system). Use cases: read/update theme mode, accent color, font scale —
  persisted via the W12 `settings` store. `PersonalizationNotifier`/extend `SettingsNotifier` (keepAlive).
- Wire the choices into the W1 `core/theme` (`AppTheme` / `MxColors` seed + accent + `MediaQuery.textScaler`).

**FE**
- Screen `20-theme` (light · dark · accent-size). Live preview of the selected theme. Reuse `Mx*` + tokens.
- Apply app-wide: `MaterialApp.themeMode` + accent + text scale react to the provider (no full restart).

**OUT of scope:** new color tokens (use existing token system); other settings (W12).

## Required reading (read ONLY these)
- Universal (see W2 list).
- Spec: `docs/business/personalization/personalization.md`.
- Decision rows: none specific — assert persistence + live apply.
- Design (FE): `docs/design/screens/20-theme.md` · `docs/ui-ux/ui-ux-contract.md` · `docs/design/design-language.md`.
- Theme code: `lib/core/theme/` (`app_theme.dart`, `mx_colors.dart` from W1). Data: `schema-contract`
  (`settings`: theme keys). `types-catalog` (`ThemeMode`). Contracts: usecase `_template.md`.

## Drift check
Compare docs to code. If docs lag, **STOP** and report `DRIFT DETECTED`.

## Acceptance criteria
- [ ] Theme mode (light/dark/system), accent, and font scale persist (via W12 settings) — test.
- [ ] Changing any of them updates the app **live** (no restart): `themeMode`, `ColorScheme` seed/accent,
      `MediaQuery.textScaler` honored; light + dark both readable (a11y contrast).
- [ ] `20-theme` renders all states with a live preview; no hardcoded colors (tokens only); l10n keys.

## Implement (layer order)
type → use cases (read/update over settings) → `@riverpod` provider → screen → wire into `MemoXApp`/`AppTheme`.
`build_runner` for codegen; do not hand-edit generated.

## Dependency gate
No new deps. Else → **STOP & ask**.

## Parity (same commit)
Update: `personalization.md` status, `ui-ux-contract`/`design-language` if theme behavior changes,
`schema` (theme settings keys), `wbs.md` W13 status + traceability, `business/system/overview.md` status,
`where-is`, l10n keys.

## Verify
Inner `--quick` · End `--full`.

## After verify PASS, before report
Fan out `code-reviewer` + `docs-drift-detector`; fix blockers.

## Commit & report
Commit `feat(personalization): theme mode, accent & font size`. Report: files · docs · verify · WBS · out-of-scope.

---
> **Last step.** After this merges, W2–W13 are complete and every design-kit screen is built. Do a final
> pass: WBS all `Done`, `business/system/overview.md` status all `Implemented`, full `node tool/verify/run.mjs --full` green.
