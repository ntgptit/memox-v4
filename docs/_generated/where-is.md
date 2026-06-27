# Where-is: feature → docs / source / tests / WBS

Đọc dòng liên quan TRƯỚC khi grep. Một dòng / feature; cập nhật cùng commit khi
thêm/di chuyển feature. (File tay — không bị `doc_guard generate` ghi đè.)

Cột Source là **đường dẫn dự kiến** cho các feature chưa code. Nền (W1) + app shell &
cặp ngôn ngữ (S0) đã hiện thực — xem các dòng cuối.

| Feature | Business doc | Source (dự kiến) | Tests | WBS |
| --- | --- | --- | --- | --- |
| Thẻ (Card) | `docs/business/flashcard/flashcard-management.md` | `lib/domain/{entities,usecases/flashcard}/` · `lib/data/{datasources/local/daos,repositories}/` · `lib/presentation/features/flashcard/` | `test/data/repositories/card_repository_impl_test.dart` · `test/presentation/features/flashcard/` | W2 |
| SRS 8-box | `docs/business/srs/srs-review.md` | `lib/domain/{entities,services,types,usecases/srs}/` · `lib/data/{datasources/local/daos,repositories}/` | `test/domain/services/srs_scheduler_test.dart` · `test/domain/usecases/srs/` | W3 |
| Học & luyện | `docs/business/study/study-flow.md` | `lib/domain/{entities,models,types,usecases/study}/` · `lib/data/{datasources/local/daos,repositories}/` (daily_activity) · `lib/presentation/features/study/` | `test/domain/usecases/study/` · `test/presentation/features/study/` | W4 |
| 4 game | `docs/business/game/game-modes.md` | `lib/domain/{models,types,usecases/game}/` · `lib/presentation/features/game/` | `test/domain/usecases/game/` · `test/presentation/features/game/` | W5 |
| Bộ thẻ (cây lồng nhau) | `docs/business/deck/deck-management.md` | `lib/domain/{entities,models,usecases/deck}/` · `lib/data/{datasources/local/daos,repositories}/` · `lib/presentation/features/deck/` | `test/data/repositories/deck_repository_impl_test.dart` · `test/domain/usecases/deck/` | W6 |
| Tìm kiếm | `docs/business/search/global-search.md` | `lib/domain/{models,usecases/search}/` · `lib/data/{datasources/local/daos,repositories}/` · `lib/presentation/features/search/` | `test/data/repositories/search_repository_impl_test.dart` · `test/presentation/features/search/` | W7 |
| Nhập/Xuất | `docs/business/import-export/import-export.md` | `lib/domain/usecases/import_export/` | TBD | W8 |
| Thống kê | `docs/business/statistics/statistics.md` | `lib/domain/{models/statistics_summary,usecases/statistics}` · `lib/data/{datasources/local/daos/stats_dao,repositories/statistics_repository_impl}` · `lib/presentation/features/statistics/` | `test/domain/usecases/statistics/get_statistics_test.dart` · `test/presentation/features/statistics/` | W9 |
| Tài khoản/Sync | `docs/business/account-sync/account-sync.md` | `lib/data/datasources/remote/` | TBD | W10 |
| Gắn kết/streak | `docs/business/engagement/dashboard-engagement.md` | `lib/domain/{types,models,usecases/engagement}` · `lib/presentation/features/engagement/` | `test/domain/usecases/engagement/compute_streak_test.dart` · `test/presentation/features/engagement/` | W11 |
| Cài đặt/Backup | `docs/business/settings/settings.md` | `lib/presentation/features/settings/` | TBD | W12 |
| Theme | `docs/business/personalization/personalization.md` | `lib/core/theme/` | TBD | W13 |

Cơ sở dữ liệu: `docs/database/schema-contract.md` → `lib/data/datasources/local/` (Drift).
Điều hướng: `docs/business/navigation/navigation-flow.md` → `lib/app/router/`.
App shell & Drawer (S0): `docs/design/screens/23-drawer.md` → `lib/presentation/shared/navigation/`.
Cặp ngôn ngữ (S0): `docs/business/glossary.md` (LanguagePair) → `lib/domain/{entities,usecases/language_pair}/`
· `lib/data/{datasources/local/daos,repositories}/` · `lib/presentation/features/language_pair/`.
Sơ đồ luồng toàn hệ thống: `docs/business/system/system-flow.md`.
