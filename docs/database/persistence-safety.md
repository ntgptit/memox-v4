# Persistence safety policy (v1)

> **Locks the DB-safety patterns DT.1–DT.4 must follow**, authored before any Drift
> code. For a local-first SRS app the database is the single source of truth with
> **no server to recover from** — a persistence bug (a half-applied grade, a lost
> cascade, a wall-clock query) silently corrupts the learner's schedule. This doc
> defines the mandatory patterns and pairs each with a **test skeleton** under
> [`test/data/_skeletons/`](../../test/data/_skeletons) that DT.1–DT.4 must fill in
> (the skeletons are skipped until then, so the gate stays green). It builds on the
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

**Skeleton.** [`transaction_rollback_test.dart`](../../test/data/_skeletons/transaction_rollback_test.dart)
— a multi-table write whose second step throws leaves **zero** rows from the first
step (full rollback).

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

**Skeleton.** [`cascade_delete_test.dart`](../../test/data/_skeletons/cascade_delete_test.dart)
— seeding a parent→child deck with cards + meanings + srs, then deleting the parent,
leaves **no** orphaned child deck / card / meaning / srs / review-log rows (D-024).

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

**Skeleton.** [`deterministic_ordering_test.dart`](../../test/data/_skeletons/deterministic_ordering_test.dart)
— the same query over the same data returns rows in the **same order** twice, and
ties on the sort key fall back to `id` (D-023).

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

**Skeleton.** [`clock_injection_test.dart`](../../test/data/_skeletons/clock_injection_test.dart)
— the due query uses the injected `asOf` (a card due at T is due at T+1s but not at
T−1s), and the day bucket is the injected-clock local day (D-010/D-021).

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

**Skeleton.** [`migration_test.dart`](../../test/data/_skeletons/migration_test.dart)
— migrating a populated vN database to the current version keeps every row and
re-enables foreign keys.

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

Policies map to the DT.0.1 Notes: **transaction/rollback** (Policy 1 + skeleton),
**migration test** (Policy 5 + skeleton), **deterministic ordering** (Policy 3 +
skeleton), **clock/local-day injection** (Policy 4 + skeleton), **soft-delete/cascade
D-024** (Policy 2 + skeleton). Every skeleton is `skip`-marked until its DT task
(DT.1 tables/pragma, DT.2 migrations, DT.3 DAOs/ordering, DT.4 repo impls/transactions)
fills it in — so this task keeps the gate green while locking the contract those tasks
must satisfy.
