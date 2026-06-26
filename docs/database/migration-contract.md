# Migration contract — MemoX V4

Every schema version bump gets a migration entry here and a migration test. Never
mutate persisted shape without a forward migration.

## Migrations

| From → To | Change | Migration step | Test |
| --- | --- | --- | --- |
| <n-1> → <n> | <add column / table / index> | <how existing data is migrated> | `test/...` |

<!-- FILL: append-only. Each row corresponds to one schema_version increment in
     docs/database/schema-contract.md. -->

## Rules

- Forward-only; migrations are idempotent where the platform allows.
- A migration that drops/renames data must state how existing rows are preserved or transformed.
- The migration test must exercise upgrade from the previous version with real data.

## Related

- `docs/database/schema-contract.md` — the current schema
- `docs/database/storage-boundaries.md` — ownership of stores
