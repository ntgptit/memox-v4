# Storage boundaries — MemoX V4

What lives where, so nothing important survives only in memory (hard rule).

| Data | Store | Why | Lifetime |
| --- | --- | --- | --- |
| Entity (deck/card/card_meaning/srs_state/daily_activity/review_outcome) | Drift SQLite | truy vấn, bền | persistent |
| Cài đặt (theme, SRS, game, nhắc, mục tiêu) + ngữ cảnh cặp (`active_pair_id`, `display_swapped`) | Drift `settings` (key-value) | nhỏ, phẳng | persistent |
| State UI tạm (hàng đợi học, tiến độ ván) | Riverpod (in-memory) | dẫn xuất, tính lại được | session |
| Token Google / phiên đăng nhập | secure storage | không để plaintext | persistent |
| Backup | file cục bộ (Documents) | snapshot khôi phục | persistent |

## Rules

- Persistent data goes to durable storage, never only a provider/in-memory cache.
- Secrets never go to plain storage or logs.
- Each store has exactly one owner module; others go through its repository.

## Related

- `docs/database/schema-contract.md` — DB structure
- `docs/database/migration-contract.md` — migrations
