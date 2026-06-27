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
| `study` | `/study/:nodeId` | nodeId, entry | push | entry = newLearn / dueReview |
| `game` | `/game/:nodeId` | nodeId | push | picker chọn 1/4 game (W5) |
| `gamePlay` | `/game/:nodeId/play` | nodeId, type, scope, random | push | ván đang chơi (W5) |
| `review` | `/review/:nodeId` | nodeId | push | |
| `player` | `/player/:nodeId` | nodeId | push | auto-play |
| `search` | `/search` | query? | push | |
| `settings` | `/settings` | — | push | Cài đặt (W12): game/SRS/mục tiêu/sao lưu; mở từ drawer |
| `reminder` | `/settings/reminder` | — | push | Nhắc học (W12): giờ + thứ; lên lịch OS hoãn (gated) |
| `theme` | `/settings/theme` | — | push | Cá nhân hoá (W13): chế độ màu + màu nhấn + cỡ chữ, áp dụng live |
| `account` | `/settings/account` | — | push | Google sync |

Hằng route đặt ở `lib/app/router/` (`route_paths.dart` / `app_router.dart`). S0 dựng
**app shell** bằng `StatefulShellRoute.indexedStack`: 4 tab (Today · Library · Stats ·
Profile) + nút **Add** ở giữa (action, chưa phải route) + **Drawer** quản lý cặp ngôn ngữ
(`docs/design/screens/23-drawer.md`). Route gốc `RoutePaths.root` (`/`) là tab Library,
hiển thị **cây bộ thẻ thật** (`LibraryScreen`, W6); mở một nút push sang `deckDetail`
(`/deck/:id`, `DeckDetailScreen`) — node hỗn hợp gồm bộ thẻ con + thẻ. Các route push còn
lại là dự kiến, thêm cùng feature (route + doc cập nhật chung commit).

## Flow

App mở vào `library` (`/`). Điều hướng push sang chi tiết; phiên học/chơi/phát đẩy lên
trên và pop về nút nguồn. Không deep-link ngoài v1.

```
library (/) ─▶ deckDetail (lồng nhau) ─▶ flashcardEditor
   ├─▶ study | game | review | player   (mở từ menu Play tại 1 nút)
   └─▶ search · settings ─▶ account · statistics
```

## Rules

- No hardcoded path strings in features — reference the route constants.
- Redirect/guard logic documented here, not buried in widgets.

## Related

- `docs/architecture/overview.md` — where routing sits
- `docs/business/index.md` — screens these routes reach
