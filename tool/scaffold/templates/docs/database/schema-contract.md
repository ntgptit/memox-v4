# Schema contract — {{PROJECT_NAME}}

Source of truth for persisted structure. A schema change requires this file +
`docs/database/migration-contract.md` + a test, all in the same commit (hard rule).

## Current version

`schema_version = <n>`

## Tables / collections / keys

### <table_name>

| Column | Type | Null | Default | Notes |
| --- | --- | --- | --- | --- |
| id | | no | | primary key |

<!-- FILL: every table/collection. For key-value/preferences storage, list each key,
     its type, and its default. Persisted enums reference docs/contracts/types-catalog.md. -->

## Indexes

| Table | Columns | Why |
| --- | --- | --- |

## Invariants

- <!-- FILL: foreign keys, uniqueness, cascade rules. -->

## Related

- `docs/database/migration-contract.md` — version migrations
- `docs/database/storage-boundaries.md` — what lives where
- `docs/contracts/types-catalog.md` — persisted enums
