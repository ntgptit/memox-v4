# State management contract — MemoX V4

How UI state is produced, scoped, and disposed. Keep providers/stores thin: they
orchestrate use cases, they don't hold business logic or the only copy of data.

## Choice

<!-- FILL: the state solution for Flutter / Dart 3 and the standard pattern (e.g. one
     notifier per screen, async state for loads). -->

## Per-store contract

| Store / notifier | Owns | Reads (use cases) | Lifetime |
| --- | --- | --- | --- |
| <name> | <screen state> | <use cases> | autoDispose / kept-alive |

<!-- FILL: one row per stateful unit. -->

## Rules

- State stores call use cases; they never touch repositories/data sources directly.
- Persistent data is never held only here — it has a home in `docs/database/storage-boundaries.md`.
- No side effects in build/render; no watching reactive state inside callbacks.
- Loading/error/empty are explicit states, not implicit nulls.

## Related

- `docs/architecture/overview.md` — where state sits
- `docs/contracts/error-contract.md` — loading/error states
- `docs/database/storage-boundaries.md` — data not held only in memory
