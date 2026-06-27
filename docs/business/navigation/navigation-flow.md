# Navigation flow — MemoX V4

Source of truth for routes. A new route requires updating BOTH this file and the
route constants in the SAME commit (CLAUDE.md hard rule).

## Route table

| Name | Path | Params | Push / replace | Notes |
| --- | --- | --- | --- | --- |
| `library` | `/` | — | root | màn chính (cây bộ thẻ gốc) |
| `deckDetail` | `/deck/:id` | deckId | push | node cây: bộ thẻ con + thẻ |
| `flashcardEditor` | `/deck/:id/card` | deckId, cardId? | push | tạo/sửa thẻ |
| `study` | `/study/:nodeId` | nodeId, entry | push | entry = newLearn / dueReview |
| `game` | `/game/:nodeId` | nodeId, gameType | push | |
| `review` | `/review/:nodeId` | nodeId | push | |
| `player` | `/player/:nodeId` | nodeId | push | auto-play |
| `search` | `/search` | query? | push | |
| `settings` | `/settings` | — | push | |
| `account` | `/settings/account` | — | push | Google sync |
| `statistics` | `/statistics` | — | push | |

Hằng route đặt ở `lib/app/router/` (`route_paths.dart` / `app_router.dart`). W1 đã dựng
router với route gốc `RoutePaths.root` (`/`) trỏ vào một **foundation placeholder**
(`FoundationScreen`); màn `library` thật thay placeholder ở W6. Các route còn lại là dự
kiến, thêm cùng feature (route + doc cập nhật chung commit).

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
