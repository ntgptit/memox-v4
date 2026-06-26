# Performance contract — MemoX V4

Read before a perf-sensitive change. Budgets are explicit so "fast enough" is testable.

## Budgets

| Operation | Budget | Measured how |
| --- | --- | --- |
| Mở màn (first paint) | < 300 ms | DevTools timeline |
| Cuộn danh sách thẻ/nút | 60fps, không jank | profile mode |
| Truy vấn thư viện / hàng đợi | < 50 ms, có giới hạn (paginate) | log `ms` + test |
| Dựng hàng đợi due/new (deck lớn) | < 100 ms | benchmark |

Số là **mục tiêu ban đầu**, tinh chỉnh khi đo trên máy thật.

## Rules

- No N+1 queries; batch or join.
- No unbounded queries/loops over user data — paginate.
- No blocking I/O on the UI/main thread.
- Avoid needless re-renders/rebuilds; memoize derived data.
- Cache only with a documented invalidation rule.

## Related

- `docs/quality/observability-contract.md` — logging in hot paths
- `docs/state/state-management-contract.md` — rebuild/recompute cost
