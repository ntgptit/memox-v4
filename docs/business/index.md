# Đặc tả nghiệp vụ — MemoX V4

Nguồn chân lý về hành vi. Mỗi miền một thư mục, mỗi tính năng một `.md`.

## Danh sách tính năng

| Miền | Tính năng | Spec | Status |
| --- | --- | --- | --- |
| flashcard | Quản lý Thẻ (giàu trường) | `docs/business/flashcard/flashcard-management.md` | Specified |
| srs | Ôn tập SRS (ô Leitner) | `docs/business/srs/srs-review.md` | Specified |
| study | Luồng học & luyện tập (4 chế độ) | `docs/business/study/study-flow.md` | Specified |
| settings | Cài đặt & sao lưu (Premium hoãn v1) | `docs/business/settings/settings.md` | Specified |
| game | 4 game luyện tập + picker "Một trò chơi" | `docs/business/game/game-modes.md` | Specified |
| import-export | Nhập / Xuất (CSV/Excel/clipboard) | `docs/business/import-export/import-export.md` | Specified |
| statistics | Thống kê học tập | `docs/business/statistics/statistics.md` | Specified |
| personalization | Cá nhân hoá giao diện (theme) | `docs/business/personalization/personalization.md` | Specified |
| folder | Quản lý Thư mục | `docs/business/folder/folder-management.md` | Specified |
| deck | Quản lý Bộ thẻ | `docs/business/deck/deck-management.md` | Specified |
| search | Tìm kiếm toàn cục / trong thư mục | `docs/business/search/global-search.md` | Specified |
| account-sync | Tài khoản & Đồng bộ (Google, alpha) | `docs/business/account-sync/account-sync.md` | Specified |
| engagement | Dashboard · hoạt động ngày · mục tiêu/streak | `docs/business/engagement/dashboard-engagement.md` | Specified |

<!-- FILL: liệt kê mọi tính năng. Khớp trạng thái triển khai với docs/business/system/overview.md. -->

## Cách thêm một spec tính năng

1. Copy `docs/business/_feature-template.md` sang `docs/business/<area>/<feature>.md`.
2. Thêm thuật ngữ miền mới vào `docs/business/glossary.md`.
3. Thêm các nhánh kiểm thử vào `docs/decision-tables/core-decision-table.md`.
4. Thêm gói công việc vào `docs/project-management/wbs.md`.

## Liên quan

- `docs/business/glossary.md` — thuật ngữ miền
- `docs/business/_feature-template.md` — khởi tạo một spec tính năng mới
- `docs/decision-tables/core-decision-table.md` — các nhánh kiểm thử
- `docs/project-management/wbs.md` — phân rã công việc
