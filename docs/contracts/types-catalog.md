# Types catalog — MemoX V4

Shared enums and value objects used across layers. Define once; reference by name.

## Enums

| Enum | Values | Used by |
| --- | --- | --- |
| <Enum> | <a, b, c> | <features> |

<!-- FILL: every enum that crosses a layer boundary. Persisted enums also need a
     stable encoding documented in docs/database/schema-contract.md. -->

## Value objects

| Type | Shape | Invariants |
| --- | --- | --- |
| <Type> | <fields> | <what must always hold> |

## Rules

- A persisted enum's stored representation never changes silently — that's a migration.
- Prefer a value object over a primitive when there are invariants to protect.

## Related

- `docs/contracts/error-contract.md` — failure types
- `docs/database/schema-contract.md` — persisted enum encodings
