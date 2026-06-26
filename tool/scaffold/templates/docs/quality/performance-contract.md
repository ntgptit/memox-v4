# Performance contract — {{PROJECT_NAME}}

Read before a perf-sensitive change. Budgets are explicit so "fast enough" is testable.

## Budgets

| Operation | Budget | Measured how |
| --- | --- | --- |
| <screen first paint> | <ms> | |
| <list scroll> | 60fps / no jank | |
| <query> | <ms / bounded rows> | |

<!-- FILL: set real numbers for your hot paths. -->

## Rules

- No N+1 queries; batch or join.
- No unbounded queries/loops over user data — paginate.
- No blocking I/O on the UI/main thread.
- Avoid needless re-renders/rebuilds; memoize derived data.
- Cache only with a documented invalidation rule.

## Related

- `docs/quality/observability-contract.md` — logging in hot paths
- `docs/state/state-management-contract.md` — rebuild/recompute cost
