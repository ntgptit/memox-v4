# Task: Account & Google Drive sync (alpha)  [W10]

> Loop step 11/13 · depends on: **S0 merged** · independent of feature screens; can run after the core is stable.

## Stack
Flutter / Dart 3 · Riverpod (annotation) · go_router · Drift · per `docs/stack/stack.md`.

## Scope (this iteration only)
**BE**
- Remote data source under `data/datasources/` (sync service in `data/services/`). Failure `SyncFailure`
  (network/conflict → `NetworkFailure`/`ConflictFailure`) per `error-contract`. Tokens in **secure storage**
  (never plaintext/logs) per `storage-boundaries`.
- Use cases: sign in / out with Google, push/pull a snapshot to Drive `appDataFolder`, merge with
  **last-write-wins by `updated_at`** at record level, tombstones for deletes. Requires an `updated_at`
  column path — if entities lack it, add it (schema + migration) here.

**FE**
- Screen `19-account-sync` (signed-out · signed-in · syncing · conflict · offline). Viewmodel. `Mx*` + tokens.
- Route: `account` (`/settings/account`) via `RoutePaths`.

**OUT of scope:** local backup file (that's settings/backup, W12), non-Google providers.

## Required reading (read ONLY these)
- Universal (see W2 list).
- Spec: `docs/business/account-sync/account-sync.md`.
- Decision rows: → **D-027** (conflict = last-write-wins by `updated_at`, record level).
- Design (FE): `docs/design/screens/19-account-sync.md` · `docs/ui-ux/ui-ux-contract.md` · `design-language.md`.
- Data: `schema-contract` (sync fields / `updated_at` / tombstones), `migration-contract`, `storage-boundaries`
  (secrets in secure storage). Contracts: usecase + repository `_template.md`. Route: `navigation-flow.md`.

## Drift check
Compare docs to code. If docs lag, **STOP** and report `DRIFT DETECTED`.

## ⚠ Dependency gate (NOT in stack.md → STOP & ask before adding)
Likely needs `google_sign_in`, `googleapis` (Drive v3) + `extension_google_sign_in_as_googleapis_auth`, and a
secure-storage package (`flutter_secure_storage`). **None are in `docs/stack/stack.md`.** STOP, get approval,
then add to `pubspec.yaml` + `stack.md` in the same commit. Also needs platform OAuth config (note it, don't commit secrets).

## Acceptance criteria
- [ ] **D-027:** on conflict, the record with the newer `updated_at` wins; deletes propagate via tombstones — test the merge.
- [ ] Sign-in/out flow; sync is offline-tolerant (queues, retries) and shows the right states.
- [ ] Tokens stored only in secure storage; never logged.
- [ ] All `19-account-sync` states render; route via `RoutePaths`; l10n keys; no hardcoded copy.

## Implement (layer order)
failure types → remote datasource + sync service → repo → use cases → `@riverpod` viewmodel → screen → route.
Schema change (updated_at/tombstones) ships with migration + test in the same commit. `build_runner`.

## Parity (same commit)
Update: `account-sync.md` status, decision-table test D-027, `schema`+`migration`+`storage-boundaries`,
`stack.md` (deps), `navigation-flow` (account), `wbs.md` W10 status + traceability,
`business/system/overview.md`, `where-is`, l10n keys.

## Verify
Inner `--quick` · End `--full`.

## After verify PASS, before report
Fan out `code-reviewer` + `docs-drift-detector` + `security-auditor` (secrets/auth) on the diff; fix blockers.

## Commit & report
Commit `feat(account-sync): Google sign-in + Drive sync (LWW)`. Report: files · docs · verify · WBS · deps added · out-of-scope.
