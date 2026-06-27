# Task: Settings & local backup + Reminders  [W12]

> Loop step 12/13 · depends on: **S0 merged**.

## Stack
Flutter / Dart 3 · Riverpod (annotation) · go_router · Drift · per `docs/stack/stack.md`.

## Scope (this iteration only)
**BE**
- `settings` key-value store (Drift) per `schema-contract` (native_language, ui_language, leitner_box_count,
  game_words_per_round, game_random, reminder_*, auto_backup, backup_path, new_cards_per_day, daily_goal_*).
  `SettingsRepository` + DAO. `SettingsNotifier` (keepAlive). Value object `Reminder` (time + weekdays).
- Use cases: read settings, update a setting, schedule/cancel reminders, local backup (snapshot to a file) +
  restore. Premium is **deferred** (D-012) — no locked features.

**FE**
- Screens: `17-settings` (loaded · group-expanded · value-picker), `18-reminder` (on · off · time-picker).
  Reuse `Mx*` + tokens.

**OUT of scope:** Google sync (W10), theme picker (W13 — Settings links to it).

## Required reading (read ONLY these)
- Universal (see W2 list).
- Spec: `docs/business/settings/settings.md`.
- Decision rows: → **D-012** (Premium deferred — nothing locked), **D-008** (game_words_per_round setting feeds W5).
- Design (FE): `docs/design/screens/17-settings.md`, `18-reminder.md` · `docs/ui-ux/ui-ux-contract.md` · `design-language.md`.
- Data: `schema-contract` (`settings` keys), `migration-contract`, `storage-boundaries` (backup = local file).
  `types-catalog` (`Reminder`, `DailyGoal`). Contracts: usecase + repository `_template.md`.

## Drift check
Compare docs to code. If docs lag, **STOP** and report `DRIFT DETECTED`.

## ⚠ Dependency gate (reminders → STOP & ask before adding)
Local reminders likely need `flutter_local_notifications` + `timezone`. **Not in `docs/stack/stack.md`.**
STOP, get approval, then add to `pubspec.yaml` + `stack.md` in the same commit. Backup file I/O can use the
existing `path_provider` from S0.

## Acceptance criteria
- [ ] Settings read/write persist via the `settings` key-value table (survive restart) — test.
- [ ] **D-008:** changing `game_words_per_round` changes the game round size (cross-feature with W5).
- [ ] **D-012:** no Premium-locked feature exists in v1.
- [ ] Reminder schedule (time + weekdays) persists and (with approved dep) schedules a local notification.
- [ ] Local backup writes a restorable snapshot file (≠ Google sync).
- [ ] All `17-settings` / `18-reminder` states render; no hardcoded copy/colors; l10n keys.

## Implement (layer order)
value objects → settings repo + DAO → use cases → `@riverpod` `SettingsNotifier` → screens/widgets. `build_runner`.

## Parity (same commit)
Update: `settings.md` status, decision-table tests D-008/D-012, `schema`+`migration`, `storage-boundaries`
(backup), `stack.md` (deps), `state-management-contract`, `wbs.md` W12 status + traceability,
`business/system/overview.md`, `where-is`, l10n keys.

## Verify
Inner `--quick` · End `--full`.

## After verify PASS, before report
Fan out `code-reviewer` + `docs-drift-detector`; fix blockers.

## Commit & report
Commit `feat(settings): settings, local backup & reminders`. Report: files · docs · verify · WBS · deps added · out-of-scope.
