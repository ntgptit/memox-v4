# Task: Engagement — Today dashboard · daily goal · streak  [W11]

> Loop step 9/13 · depends on: **W4 merged** (study writes DailyActivity).

## Stack
Flutter / Dart 3 · Riverpod (annotation) · go_router · Drift · per `docs/stack/stack.md`.

## Scope (this iteration only)
**BE**
- Value objects `DailyGoal` (minutes? / words?), `Streak`. `daily_activity` table (if not already created in
  W4) + DAO + repository. Use cases: watch today's activity, compute goal-met (minutes OR words), compute
  streak (consecutive days meeting goal; reset on a miss at local midnight; no streak-saver).
- `EngagementNotifier` (keepAlive) per `state-management-contract`.

**FE**
- Screen `02-dashboard` (Today tab): time studied · words · daily goal ring · streak · due summary · deck
  shortcuts. States: loaded · goal-met · streak-reset · empty · loading. Replaces the S0 Today placeholder.

**OUT of scope:** full statistics (W9), settings for goals (W12 owns the setting; here just read it).

## Required reading (read ONLY these)
- Universal (see W2 list).
- Spec: `docs/business/engagement/dashboard-engagement.md`.
- Decision rows: → **D-021** (streak +1 when ≥1 goal met; reset 0 on miss at local midnight), **D-010**
  (DailyActivity source = DueReview/NewLearn only — already enforced in W4).
- Design (FE): `docs/design/screens/02-dashboard.md` · `docs/ui-ux/ui-ux-contract.md` · `design-language.md`.
- Data: `schema-contract` (`daily_activity`, settings `daily_goal_*`). Contracts: usecase `_template.md`.

## Drift check
Compare docs to code. If docs lag, **STOP** and report `DRIFT DETECTED`.

## Acceptance criteria
- [ ] **D-021:** a day meeting ≥1 goal (minutes OR words) → streak +1; a missed day → streak resets to 0 at
      local midnight — test (no streak-saver).
- [ ] Today dashboard reflects real `DailyActivity` (seconds + words) and goal progress.
- [ ] All `02-dashboard` states render; route via the Today tab; no hardcoded copy/colors; l10n keys.

## Implement (layer order)
value objects → repo interface → Drift table/DAO (if new) → repo impl → use cases → `@riverpod`
`EngagementNotifier` → dashboard screen/widgets. `build_runner` for codegen.

## Dependency gate
No new deps. Else → **STOP & ask**.

## Parity (same commit)
Update: `dashboard-engagement.md` status, decision-table test D-021, `schema`+`migration` if table added,
`state-management-contract`, `wbs.md` W11 status + traceability, `business/system/overview.md`, `where-is`, l10n keys.

## Verify
Inner `--quick` · End `--full`.

## After verify PASS, before report
Fan out `code-reviewer` + `docs-drift-detector`; fix blockers.

## Commit & report
Commit `feat(engagement): today dashboard, daily goal & streak`. Report: files · docs · verify · WBS · out-of-scope.
