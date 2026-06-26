# Architecture overview — {{PROJECT_NAME}}

## Layering

<!-- FILL: name your layers and the dependency direction. Default Clean-ish: -->

```
presentation ─▶ domain ◀─ data
                 ▲
            (domain has no outward imports)
```

- **domain** — entities, use case contracts, repository interfaces. Imports nothing outward.
- **data** — repository implementations, data sources. Implements domain interfaces.
- **presentation** — UI + state. Depends on domain only; never imports data directly.

Dependencies point inward. Any reverse import is a hard-rule violation (CLAUDE.md).

## Module boundaries

<!-- FILL: list top-level modules/features and what each owns. -->

| Module | Owns | Depends on |
| --- | --- | --- |
| <feature> | <responsibility> | <modules> |

## Cross-cutting

- Error handling: see `docs/contracts/error-contract.md`.
- State management: see `docs/state/state-management-contract.md`.
- Persistence boundary: see `docs/database/storage-boundaries.md`.

## Non-negotiables

- One responsibility per class/file.
- No business logic in controllers/UI.
- No invented layers/factories beyond what this doc declares.

## Related

- `docs/business/index.md` — features that live in these layers
- `docs/state/state-management-contract.md` — how presentation state is produced
- `docs/database/storage-boundaries.md` — what persists where
- `docs/contracts/error-contract.md` — cross-cutting failures
