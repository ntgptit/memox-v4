# Navigation flow — MemoX V4

Source of truth for routes. A new route requires updating BOTH this file and the
route constants in the SAME commit (CLAUDE.md hard rule).

## Route table

| Name | Path | Params | Push / replace | Notes |
| --- | --- | --- | --- | --- |
| `today` | `/today` | — | tab (shell) | Hôm nay — dashboard gắn kết (W11): hoạt động + mục tiêu + streak; "Tiếp tục học" → tab Library (`/`) |
| `library` | `/` | — | tab · root (shell) | màn chính (cây bộ thẻ gốc); placeholder ở S0, W6 thay |
| `statistics` (tab) | `/statistics` | — | tab (shell) | Thống kê (W9): tổng quan + ô Leitner + dự báo + hoạt động, bộ chọn phạm vi cặp↔toàn app; cùng route mở từ drawer |
| `profile` | `/profile` | — | tab (shell) | Cá nhân — tài khoản & cài đặt (W10/W12); placeholder ở S0 |
| `deckDetail` | `/deck/:id` | deckId | push | node cây: bộ thẻ con + thẻ |
| `flashcardEditor` | `/deck/:id/card` | deckId, cardId? | push | tạo/sửa thẻ |
| `deckImport` | `/deck/:id/import` | deckId | push | Nhập CSV/Excel/clipboard (W8), mở từ deck-detail |
| `deckExport` | `/deck/:id/export` | deckId | push | Xuất CSV/Excel/clipboard (W8), mở từ deck-detail |
| `study` | `/study/:nodeId` | nodeId, entry | push | entry = newLearn / dueReview |
| `game` | `/game/:nodeId` | nodeId | push | picker chọn 1/4 game (W5) |
| `gamePlay` | `/game/:nodeId/play` | nodeId, type, scope, random | push | ván đang chơi (W5) |
| `review` | `/review/:nodeId` | nodeId | push | |
| `player` | `/player/:nodeId` | nodeId | push | auto-play |
| `search` | `/search` | query? | push | |
| `settings` | `/settings` | — | push | Cài đặt (W12): game/SRS/mục tiêu/sao lưu; mở từ drawer |
| `reminder` | `/settings/reminder` | — | push | Nhắc học (W12): giờ + thứ; lên lịch OS hoãn (gated) |
| `theme` | `/settings/theme` | — | push | Cá nhân hoá (W13): chế độ màu + màu nhấn + cỡ chữ, áp dụng live |
| (settings tile) | — | — | inline | Đồng bộ Google (W10 alpha): tile trong `/settings`, không route riêng |

Hằng route đặt ở `lib/core/routes/` (`route_paths.dart` / `app_router.dart`) — theo
kiến trúc hiện hành (AGENTS.md + WBS §Architecture). S0 dựng
**app shell** bằng `StatefulShellRoute.indexedStack` với **4 nhánh tab** (Today · Library ·
Stats · Profile). Bottom nav theo design kit có **5 mục**: Today · Library · **Add** (mục
giữa) · Stats · Profile — `Add` là **action** (không phải route/nhánh), chạm mở luồng thêm
(S0: placeholder `comingSoon`), nên không bao giờ ở trạng thái active. Tab **Today** có thêm
**Review FAB** (ôn nhanh, S0: placeholder `comingSoon`); các tab khác không có FAB.
Kèm **Drawer** quản lý cặp ngôn ngữ
(`docs/design/screens/23-drawer.md`). App bar shell theo design kit: **không có tiêu đề
thương hiệu** — tab Today dùng large app bar để hiện ngày + lời chào; các tab còn lại chỉ có
hành động chuông (placeholder) + **avatar** (mở Drawer khi chạm, thay cho nút ☰ cũ).
Route gốc `RoutePaths.root` (`/`) là tab Library,
hiển thị **cây bộ thẻ thật** (`LibraryScreen`, W6); mở một nút push sang `deckDetail`
(`/deck/:id`, `DeckDetailScreen`) — node hỗn hợp gồm bộ thẻ con + thẻ. Các route push còn
lại là dự kiến, thêm cùng feature (route + doc cập nhật chung commit).

## Flow

App mở vào `library` (`/`). Điều hướng push sang chi tiết; phiên học/chơi/phát đẩy lên
trên và pop về nút nguồn. Không deep-link ngoài v1.

```
library (/) ─▶ deckDetail (lồng nhau) ─▶ flashcardEditor
   ├─▶ study | game | review | player   (mở từ menu Play tại 1 nút)
   └─▶ search · settings (tile đồng bộ Google) · statistics
```

## Rules

- No hardcoded path strings in features — reference the route constants.
- Redirect/guard logic documented here, not buried in widgets.

## Related

- `AGENTS.md §Architecture + docs/project-management/wbs.md §Architecture` — where routing sits
- `docs/business/index.md` — screens these routes reach
