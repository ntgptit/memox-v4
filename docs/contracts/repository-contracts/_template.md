# Repository contract: <Entity>Repository

> Copy to `docs/contracts/repository-contracts/<entity>-repository.md`. Delete this line.

The interface lives in the domain layer; the implementation in data. Use cases
depend only on this interface.

## Methods

| Method | Input | Output | Failure | Notes |
| --- | --- | --- | --- | --- |
| <get/list/save/delete> | | | from error-contract | |

<!-- FILL: every method. Outputs/failures reference docs/contracts/error-contract.md. -->

## Guarantees

- <!-- FILL: ordering, uniqueness, transactionality, what is persisted vs cached. -->
- No persistent data lives only in memory (CLAUDE.md hard rule).

## Backing storage

<!-- FILL: which tables/keys/files in docs/database/schema-contract.md this maps to. -->

## Related

- `docs/contracts/usecase-contracts/_template.md` — the use cases that consume it
- `docs/contracts/error-contract.md` — failures returned
- `docs/database/schema-contract.md` — backing tables/keys
- `docs/database/storage-boundaries.md` — what it persists
