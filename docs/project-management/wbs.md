# Work breakdown structure — MemoX V4

> Baseline reviewed: 4879608 (2026-06-26)

Source of truth for task breakdown and allocation. Any task that creates, renames,
splits, merges, re-scopes, defers, or completes a work package updates this file in
the same commit (CLAUDE.md WBS rule).

## 1. Work packages

| WBS ID | Work package | Depends on | Status | Spec |
| --- | --- | --- | --- | --- |
| W1 | Nền: kiến trúc + core (error/types/router/theme/DI) | — | Done | `docs/architecture/overview.md` |
| W2 | Thẻ (Card) CRUD + nghĩa đa trường | W1 | Done | `docs/business/flashcard/flashcard-management.md` |
| W3 | SRS 8-box Leitner | W2 | Done | `docs/business/srs/srs-review.md` |
| W4 | Học & 5 lối vào (NewLearn 5 chặng) | W3, W5 | Done | `docs/business/study/study-flow.md` |
| W5 | 4 game luyện | W2 | Done | `docs/business/game/game-modes.md` |
| W6 | Bộ thẻ (cây lồng nhau) | W2 | Done | `docs/business/deck/deck-management.md` |
| W7 | Tìm kiếm | W2 | Done | `docs/business/search/global-search.md` |
| W8 | Nhập / Xuất | W6 | Planned | `docs/business/import-export/import-export.md` |
| W9 | Thống kê | W3, W11 | Planned | `docs/business/statistics/statistics.md` |
| W10 | Tài khoản & Đồng bộ Google | W1 | Planned | `docs/business/account-sync/account-sync.md` |
| W11 | Gắn kết / streak | W4 | Done | `docs/business/engagement/dashboard-engagement.md` |
| W12 | Cài đặt & Backup cục bộ | W1 | Planned | `docs/business/settings/settings.md` |
| W13 | Theme (personalization) | W12 | Planned | `docs/business/personalization/personalization.md` |

Status ∈ Planned / In-progress / Blocked / Done. **W1 Done** (nền kiến trúc + core:
error/types/router/theme/DI đã code & test); **W2 Done** (Card CRUD + nghĩa đa trường +
editor; audio TTS hoãn); **W6 Done** (cây bộ thẻ tự lồng + library home + deck detail +
tổng hợp đệ quy); **W3 Done** (engine SRS 8 ô Leitner — scheduler + queue + cap, BE-only);
**W5 Done** (4 game + picker, luyện thuần không đổi SRS); **W4 Done** (5 lối vào + Play menu +
NewLearn/DueReview/Review/Player/result + daily_activity); **W7 Done** (tìm kiếm term+nghĩa +
lọc trạng thái); **W11 Done** (dashboard Today: hoạt động + mục tiêu + streak D-021);
**W9/W12/W13 Planned**, **W8/W10 BLOCKED** (gated dep — xem §10 + NIGHT-LOG).

**S0 (nền tiếp theo, tiền đề mọi feature) Done:** app shell (`StatefulShellRoute` +
bottom nav 4 tab + Drawer cặp ngôn ngữ) + Drift `language_pair` (DAO/repo/usecases:
list·create·remove·setActive·swapDisplay) + ngữ cảnh cặp keepAlive + l10n (vi/en) +
DI. Codegen Riverpod hoãn (xung đột `drift_dev`, xem `docs/stack/stack.md`).

> **Pivot v1 (2026-06-28):** bỏ khái niệm **Thư mục** — bộ thẻ **tự lồng nhau** (cây) đảm
> nhiệm việc tổ chức. W6 (Thư mục) cũ bị xoá; **W7–W14 cũ dồn xuống W6–W13**. Phụ thuộc đã
> remap. Chi tiết: `docs/business/deck/deck-management.md`.

## 2. Map sang dòng quyết định

| WBS | Dòng quyết định (core-decision-table) |
| --- | --- |
| W2 | D-006, D-020 |
| W3 | D-002, D-003, D-004, D-005, D-011, D-018 |
| W4 | D-001, D-007, D-009, D-010, D-016, D-029 |
| W5 | D-008, D-013, D-015 |
| W6 | D-023, D-024 |
| W7 | D-019, D-028 |
| W8 | D-025, D-026 |
| W10 | D-027 |
| W11 | D-010, D-021 |
| W12 | D-012 (Premium — hoãn v1) |

## 10. Commit Traceability Log

Append-only, newest first. One line per commit that touches a WBS work package:
`<8-char hash> · <YYYY-MM-DD> · <WBS IDs> · <summary>`.

- ca16842e · 2026-06-28 · W7 · tìm kiếm thẻ theo term + nghĩa (D-019), gồm thẻ ẩn + lọc trạng thái (D-028) có test; DAO card⨝deck⨝srs (meaning qua EXISTS); v1 LIKE (FTS/index hoãn); route /search + nút 🔍 thư viện
- b63ec88c · 2026-06-28 · W4 · 5 lối vào học (Play menu + NewLearn 5 chặng + DueReview + Review + Player + result); tích hợp SRS(W3)+game(W5)+deck subtree(W6) + daily_activity; D-001/009/010/016/017/002/007 có test; chặng game NewLearn dùng self-grade gộp (follow-up)
- 41c0f0f5 · 2026-06-28 · W5 · 4 game (Ghép đôi/Đoán/Nhớ lại/Điền) + picker; luyện thuần KHÔNG đổi SrsState (D-007); round ≤5 thẻ (D-008), sai→học lại (D-015), picker 4 game (D-013) có test; không bảng mới
- 9412f488 · 2026-06-28 · W3 · engine SRS 8 ô Leitner (scheduler + grade + due/new queue + cap D-018); D-002..D-005/D-011/D-018 có test; `srs_state` đã có ở v1 (không migration); BE-only (UI học = W4)
- 1f891c7e · 2026-06-28 · W6 · cây bộ thẻ tự lồng + library home + deck detail; tổng hợp đệ quy (words/hidden/due/mastered/%); D-023/D-024/BR-3 có test; `deck` + index đã có ở v1 (không migration); sort created/last-studied dùng proxy (id / max ngày-học cây con)
- 081ffc74 · 2026-06-28 · W2 · Card CRUD + nghĩa đa trường + editor (D-006/D-020/BR-2 có test); `card`/`card_meaning` đã có ở schema v1 (không migration); audio TTS hoãn (dep ngoài stack)
- 8d715f83 · 2026-06-28 · S0 (nền) · app shell (StatefulShellRoute + bottom nav + Drawer) + `language_pair` (Drift DAO/repo/usecases) + ngữ cảnh cặp keepAlive + l10n vi/en; Riverpod codegen hoãn (xung đột `drift_dev`)
- 36f9b503 · 2026-06-28 · W1 · base code nền: design token + theme M3 đầy đủ + responsive (MxScreenSize/breakpoints) + utils chung (Result/Clock/logger) + hạ tầng Drift (schema v1 viết SQL `.drift`)
- f63a2855 · 2026-06-28 · W6 (W7–W14 cũ→W6–W13) · pivot: bỏ Thư mục; bộ thẻ tự lồng (nested deck); xoá folder spec; renumber WBS + remap deps
- ead20623 · 2026-06-28 · W1 · scaffold foundation (error/types/router/theme/DI); align overview.md to tool/flutter_arch; W1 → Done
- adfb86aa · 2026-06-27 · W1–W14 · populate WBS; fill contract/architecture/index stubs (AI-agent readiness)
- 4879608 · 2026-06-26 · — · initial business specs + skeleton import

## Related

- `docs/business/index.md` — features being tracked
- `docs/business/system/overview.md` — implementation status
