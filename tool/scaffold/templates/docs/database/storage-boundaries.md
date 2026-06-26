# Storage boundaries — {{PROJECT_NAME}}

What lives where, so nothing important survives only in memory (hard rule).

| Data | Store | Why | Lifetime |
| --- | --- | --- | --- |
| <domain entities> | <DB> | queryable, durable | persistent |
| <user preferences> | <key-value> | small, flat | persistent |
| <ephemeral UI state> | <in-memory/state> | derived, recomputable | session |
| <secrets/tokens> | <secure store> | must not be plain text | persistent |

<!-- FILL: map each kind of data to exactly one owning store. -->

## Rules

- Persistent data goes to durable storage, never only a provider/in-memory cache.
- Secrets never go to plain storage or logs.
- Each store has exactly one owner module; others go through its repository.

## Related

- `docs/database/schema-contract.md` — DB structure
- `docs/database/migration-contract.md` — migrations
