# Migration contract — MemoX V4

Every schema version bump gets a migration entry here and a migration test. Never
mutate persisted shape without a forward migration.

## Migrations

| From → To | Change | Migration step | Test |
| --- | --- | --- | --- |
| 0 → 1 | tạo schema ban đầu (language_pair, deck [tự lồng qua `parent_deck_id`], card, card_meaning, srs_state, daily_activity, settings) | `onCreate` của Drift | `test/data/datasources/local/app_database_test.dart` |
| 1 → 2 | thêm bảng `review_outcome` (+ index `idx_review_outcome_pair_ts`) cho thống kê độ chính xác (W9) | `onUpgrade` (from < 2): `m.createTable(reviewOutcome)` + tạo index | `test/data/datasources/local/drift/migration_v2_test.dart` |

Mỗi dòng = một lần tăng `schema_version` trong `docs/database/schema-contract.md`.
Hiện ở **v2**. Bảng append-only thêm mới không đụng dữ liệu cũ (chỉ tạo bảng).

> **Khoá `settings` mới không cần migration:** store `settings` là key-value; thêm một
> khoá (vd `active_pair_id`, `display_swapped` ở S0) chỉ là dữ liệu, không đổi hình dạng
> bảng → không tăng `schema_version`. Khoá vắng mặt mặc định null và repository tự xử lý.

## Rules

- Forward-only; migrations are idempotent where the platform allows.
- A migration that drops/renames data must state how existing rows are preserved or transformed.
- The migration test must exercise upgrade from the previous version with real data.

## Related

- `docs/database/schema-contract.md` — the current schema
- `docs/database/storage-boundaries.md` — ownership of stores
