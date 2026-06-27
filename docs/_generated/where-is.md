# Where-is: feature → docs / source / tests / WBS

Đọc dòng liên quan TRƯỚC khi grep. Một dòng / feature; cập nhật cùng commit khi
thêm/di chuyển feature. (File tay — không bị `doc_guard generate` ghi đè.)

Cột Source là **đường dẫn dự kiến** (lib/ chưa hiện thực, chỉ có `lib/main.dart`).

| Feature | Business doc | Source (dự kiến) | Tests | WBS |
| --- | --- | --- | --- | --- |
| Thẻ (Card) | `docs/business/flashcard/flashcard-management.md` | `lib/domain/usecases/flashcard/` · `lib/presentation/features/flashcard/` | TBD | W2 |
| SRS 8-box | `docs/business/srs/srs-review.md` | `lib/domain/usecases/srs/` · `lib/data/datasources/local/` | TBD | W3 |
| Học & luyện | `docs/business/study/study-flow.md` | `lib/domain/usecases/study/` · `lib/presentation/features/study/` | TBD | W4 |
| 4 game | `docs/business/game/game-modes.md` | `lib/presentation/features/game/` | TBD | W5 |
| Bộ thẻ (cây lồng nhau) | `docs/business/deck/deck-management.md` | `lib/domain/usecases/deck/` · `lib/presentation/features/deck/` | TBD | W6 |
| Tìm kiếm | `docs/business/search/global-search.md` | `lib/domain/usecases/search/` · `lib/presentation/features/search/` | TBD | W7 |
| Nhập/Xuất | `docs/business/import-export/import-export.md` | `lib/domain/usecases/import_export/` | TBD | W8 |
| Thống kê | `docs/business/statistics/statistics.md` | `lib/presentation/features/statistics/` | TBD | W9 |
| Tài khoản/Sync | `docs/business/account-sync/account-sync.md` | `lib/data/datasources/remote/` | TBD | W10 |
| Gắn kết/streak | `docs/business/engagement/dashboard-engagement.md` | `lib/domain/usecases/engagement/` | TBD | W11 |
| Cài đặt/Backup | `docs/business/settings/settings.md` | `lib/presentation/features/settings/` | TBD | W12 |
| Theme | `docs/business/personalization/personalization.md` | `lib/core/theme/` | TBD | W13 |

Cơ sở dữ liệu: `docs/database/schema-contract.md` → `lib/data/datasources/local/` (Drift).
Điều hướng: `docs/business/navigation/navigation-flow.md` → `lib/app/router/`.
Sơ đồ luồng toàn hệ thống: `docs/business/system/system-flow.md`.
