# MemoX — Bộ prompt thiết kế màn hình (Claude Design)

Mỗi màn hình có **một file prompt tự-chứa** trong `docs/design/screens/`. File **đã có đủ
ngữ cảnh + mọi state inline**, không tham chiếu file khác — dùng trực tiếp với Claude Design.

## Cách dùng

1. Mở project **MemoX Design System** trên Claude Design (web) — project đã chứa design
   system (component `Mx*`, token `--memox-*`, Plus Jakarta Sans, light/dark).
2. Mở một file màn (vd `docs/design/screens/01-library.md`), **copy toàn bộ nội dung**, dán
   vào khung chat của Claude Design.
3. Claude Design sẽ thiết kế màn đó + **mỗi state một frame** như mô tả trong prompt.

## Danh mục màn → spec nghiệp vụ (truy vết repo)

| File prompt | Màn | Spec nghiệp vụ |
| --- | --- | --- |
| `docs/design/screens/01-library.md` | Thư viện | `docs/business/deck/deck-management.md` |
| `docs/design/screens/02-dashboard.md` | Dashboard / Hoạt động | `docs/business/engagement/dashboard-engagement.md` |
| `docs/design/screens/04-deck-detail.md` | Chi tiết bộ thẻ (cây con + thẻ) | `docs/business/deck/deck-management.md` |
| `docs/design/screens/05-flashcard-editor.md` | Tạo/Sửa thẻ | `docs/business/flashcard/flashcard-management.md` |
| `docs/design/screens/06-study-session.md` | Phiên học (5 chặng) | `docs/business/study/study-flow.md` |
| `docs/design/screens/07-game-picker.md` | Chọn trò chơi | `docs/business/game/game-modes.md` |
| `docs/design/screens/08-game-matching.md` | Ghép đôi | `docs/business/game/game-modes.md` |
| `docs/design/screens/09-game-multiple-choice.md` | Đoán | `docs/business/game/game-modes.md` |
| `docs/design/screens/10-game-recall.md` | Nhớ lại | `docs/business/game/game-modes.md` |
| `docs/design/screens/11-game-typing.md` | Điền | `docs/business/game/game-modes.md` |
| `docs/design/screens/12-review.md` | Xem lại | `docs/business/study/study-flow.md` |
| `docs/design/screens/13-player.md` | Trình phát | `docs/business/study/study-flow.md` |
| `docs/design/screens/14-study-result.md` | Kết quả phiên học | `docs/business/study/study-flow.md` |
| `docs/design/screens/15-search.md` | Tìm kiếm | `docs/business/search/global-search.md` |
| `docs/design/screens/16-statistics.md` | Thống kê | `docs/business/statistics/statistics.md` |
| `docs/design/screens/17-settings.md` | Cài đặt | `docs/business/settings/settings.md` |
| `docs/design/screens/18-reminder.md` | Nhắc học | `docs/business/settings/settings.md` |
| `docs/design/screens/19-account-sync.md` | Tài khoản & Đồng bộ | `docs/business/account-sync/account-sync.md` |
| `docs/design/screens/20-theme.md` | Chủ đề | `docs/business/personalization/personalization.md` |
| `docs/design/screens/21-import.md` | Nhập dữ liệu | `docs/business/import-export/import-export.md` |
| `docs/design/screens/22-export.md` | Xuất dữ liệu | `docs/business/import-export/import-export.md` |
| `docs/design/screens/23-drawer.md` | Drawer & Cặp ngôn ngữ | `docs/business/system/overview.md` |

## Liên quan

- `docs/business/system/system-flow.md` — sơ đồ luồng toàn hệ thống
- `docs/business/navigation/navigation-flow.md` — route & điều hướng
