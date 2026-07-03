# Persistence safety policy (v1)

> **Locks the DB-safety patterns DT.1–DT.4 must follow**, authored before any Drift
> code. For a local-first SRS app the database is the single source of truth with
> **no server to recover from** — a persistence bug (a half-applied grade, a lost
> cascade, a wall-clock query) silently corrupts the learner's schedule. This doc
> defines the mandatory patterns and pairs each with its **realizing test** (the
> DT.1–DT.4 suites listed per policy below; the original skipped skeletons were
> removed once these landed). It builds on the
> [schema contract](schema-contract.md) (DT.0) and `docs/decision-tables/
> core-decision-table.md` (esp. **D-024** cascade).

## Why this gate exists

- **No remote backup in v1** — the on-device DB is authoritative; a corrupt row is
  not recoverable from a server.
- **The schedule is invisible state** — a wrong `srs_state.box` / `due_at` surfaces
  days later as cards reviewed at the wrong time; there is no user-visible signal at
  write time.
- **Errors must never be swallowed** (AGENTS.md) — every failed write returns a
  `Failure` → surfaced localized to the user **and** logged for devs; a caught-and-
  ignored DB error is the exact failure this policy forbids.

---

## Policy 1 — Atomic multi-table writes (transaction + rollback)

**Rule.** Any operation that writes **more than one row across more than one table**
runs inside a single Drift `transaction`. If any step fails, the whole unit rolls
back — the DB never persists a partial write.

**Applies to** (from the [schema contract](schema-contract.md)):

| Operation | Tables touched | Rule |
| --- | --- | --- |
| Save a card | `cards` + `card_meanings` (+ initial `srs_state`) | BR-2 (a card always has ≥1 meaning — never a card row without its meanings). |
| Grade a due card (`GradeCard`) | `srs_state` (box/due) + `review_logs` | D-003/4/5 — the schedule move and its history log must agree; the two writes share one instant and one transaction. |
| Graduate a new card (`GraduateCard`) | `srs_state` | D-002 — box 1 + due date atomically. |
| Delete a deck | `decks` + subtree `decks`/`cards`/`card_meanings`/`srs_state` | **D-024** — the whole subtree drops or nothing does. |
| Import a batch | `cards` + `card_meanings` (× N) | D-025 — a batch import is all-or-nothing (a failed row rolls back the batch). |
| Record a session | `study_sessions` + `daily_activity` roll-up | D-010 — the session and its day-total increment commit together. |

**Pattern.** DAOs expose write methods that either take a `transaction`-scoped
executor or wrap their body in `db.transaction(() async { … })`. Repository impls
(DT.4) return `Result<T>` via `guardAsync` — a thrown DB error becomes a
`PersistenceFailure`, never an uncaught exception. **No** repository method performs
two awaited writes outside a transaction.

**Test.** [`persistence_safety_test.dart`](../../test/data/persistence_safety_test.dart)
(Policy 1) — a card save whose second `card_meanings` insert throws (a PK clash)
leaves **zero** rows from the first step, and the `db.transaction` primitive rolls
back a thrown body. The transactional card write is also exercised in
[`drift_repositories_test.dart`](../../test/data/repositories/drift_repositories_test.dart).

---

## Policy 2 — Cascade delete (D-024)

**Rule.** Deleting a deck removes its **entire subtree**: descendant decks, their
cards, each card's meanings, and each card's `srs_state` and `review_logs`. This is
declared with `ON DELETE CASCADE` foreign keys **and** requires
`PRAGMA foreign_keys = ON` at every connection open (SQLite defaults it **off**).

**Applies to.** `decks.parent_id` (self-FK), `cards.deck_id`, `card_meanings.card_id`,
`srs_state.card_id`, `review_logs.card_id`, `study_sessions.deck_id` — all `ON DELETE
CASCADE` per the [schema contract](schema-contract.md).

**Pattern.** The Drift `QueryExecutor` sets `PRAGMA foreign_keys = ON` in its
`beforeOpen`/setup hook; a migration test asserts the pragma is enabled. Deleting a
subtree is a single delete of the root deck row — the FKs do the rest inside one
transaction (Policy 1).

**Test.** [`app_database_test.dart`](../../test/data/datasources/local/app_database_test.dart)
(cascade delete + `PRAGMA foreign_keys`) and
[`data_integration_test.dart`](../../test/data/integration/data_integration_test.dart)
(delete cascades through every read path) — deleting a parent deck leaves **no**
orphaned child deck / card / meaning / srs / review-log rows (D-024).

---

## Policy 3 — Deterministic ordering

**Rule.** Every list query declares an **explicit, total `ORDER BY`** — it never
relies on insertion order, rowid, or "whatever SQLite returns". A tie on the primary
sort key is broken by a stable secondary key (usually `id`) so results are
reproducible across runs and platforms (golden/stat tests depend on this).

**Applies to.** Deck children (D-023 sort: name / created / last-studied, with
`sort_index` then `id` as the stable tail), the due queue (`due_at ASC, id ASC`), the
new queue (`created_at ASC, id ASC`), search results (D-019/D-028), card lists, and
the stats history.

**Pattern.** DAO queries carry the `ORDER BY` in the `*.drift` SQL (SQL only in
`*.drift`, AGENTS.md); the sort **criterion** (D-023) is a bound parameter/variant,
not string-built SQL. No query returns rows for display without an `ORDER BY`.

**Test.** [`persistence_safety_test.dart`](../../test/data/persistence_safety_test.dart)
(Policy 3) — the same query over the same data returns rows in the **same order**
twice, and ties on the sort key fall back to `id` (D-023); per-query ordering is
also asserted in [`dao_test.dart`](../../test/data/datasources/local/dao_test.dart).

---

## Policy 4 — Clock injection (no wall-clock in the data layer)

**Rule.** No query, DAO, or repository reads `DateTime.now()`. "Now" (for the due
filter, `due_at` stamps, session `started_at`, and the `daily_activity` **local-day**
bucket) is supplied by the caller from the injected [`Clock`](../../lib/core/utils/clock.dart)
(DM.9) — the only place `DateTime.now()` is allowed is `SystemClock`.

**Why.** The due queue (`due_at <= now`), the streak/day roll-up (`D-021`, `D-010`),
and any "today" bucketing must be deterministic under test (a fixed `FakeClock`) and
must not drift with query latency. A wall-clock read inside a query is a silent
determinism bug.

**Local-day rule.** Day bucketing (`daily_activity.day`) uses the **machine-local**
calendar day derived from the injected now (midnight of that day), consistent across
the dashboard, streak (`streakFromHistory`), and stats — never a raw timestamp
compare, never a UTC/local mismatch.

**Pattern.** Repository/DAO methods that need time take an `asOf`/`now` parameter (as
`ReviewRepository.dueQueue(asOf:)` already does) sourced from `ref.read(clockProvider)`
at the call site; the data layer contains **no** `DateTime.now()`.

**Test.** [`dao_test.dart`](../../test/data/datasources/local/dao_test.dart) (the due
query honours the passed `asOf`) and
[`service_adapters_test.dart`](../../test/data/services/service_adapters_test.dart)
(daily-activity day bucket) — plus the scheduler's
[`srs_invariants_test.dart`](../../test/domain/usecases/srs/srs_invariants_test.dart)
"due time tracks the injected clock" (D-010/D-021).

---

## Policy 5 — Migration safety (versioning)

**Rule.** Every schema change bumps the Drift `schemaVersion` and ships a migration
that **preserves existing data** and re-runs `PRAGMA foreign_keys = ON`. Migrations
are covered by a schema/migration test (DT.2) before release; a destructive migration
is never silent — a restore across an incompatible `backup_metadata.schema_version`
is rejected, not applied blindly.

**Pattern.** DT.2 uses Drift's migration test harness (verify a vN DB migrates to
vN+1 with rows intact). New columns are nullable or defaulted so old rows remain
valid; column drops/renames go through Drift's stepwise migration, never a silent
`DROP`.

**Test.** [`schema_migration_test.dart`](../../test/data/migration/schema_migration_test.dart)
(DT.2) — the runtime schema matches its versioned snapshot, and a populated database
survives a close + reopen with foreign keys re-enabled.

---

## Cross-cutting rules

- **`Result`, never throw across the boundary.** Repository impls wrap DAO calls in
  `guardAsync`; a DB error → `PersistenceFailure` → `AsyncValue.error` at the screen,
  localized for the user and logged via `AppLogger`. Errors are never swallowed.
- **SQL only in `*.drift`.** No inline/string-built SQL in Dart (AGENTS.md); the sort
  criterion and search tokens are bound parameters, not concatenated SQL (injection +
  determinism).
- **One writer invariant.** A single-process on-device DB — writes are serialized
  through Drift; no cross-isolate write races assumed in v1.

## Coverage self-check

Every policy is now backed by a **live** test (the DT.0.1 skeletons were removed once
these landed): **transaction/rollback** (Policy 1 — `persistence_safety_test.dart` +
`drift_repositories_test.dart`), **cascade D-024** (Policy 2 — `app_database_test.dart`
+ `data_integration_test.dart`), **deterministic ordering** (Policy 3 —
`persistence_safety_test.dart` + `dao_test.dart`), **clock/local-day injection**
(Policy 4 — `dao_test.dart` + `service_adapters_test.dart` + `srs_invariants_test.dart`),
and **migration** (Policy 5 — `schema_migration_test.dart`). Wired across DT.1
(tables/pragma), DT.2 (migrations), DT.3 (DAOs/ordering), DT.4 (repos/transactions),
and this cleanup — the contract is enforced by running tests, not skipped stubs.
