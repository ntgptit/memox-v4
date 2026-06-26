# Work breakdown structure — MemoX V4

> Baseline reviewed: 4879608 (2026-06-26)

Source of truth for task breakdown and allocation. Any task that creates, renames,
splits, merges, re-scopes, defers, or completes a work package updates this file in
the same commit (CLAUDE.md WBS rule).

## 1. Work packages

| WBS ID | Work package | Depends on | Status | Spec |
| --- | --- | --- | --- | --- |
| W1 | Nền: kiến trúc + core (error/types/router/theme/DI) | — | Planned | `docs/architecture/overview.md` |
| W2 | Thẻ (Card) CRUD + nghĩa đa trường | W1 | Planned | `docs/business/flashcard/flashcard-management.md` |
| W3 | SRS 8-box Leitner | W2 | Planned | `docs/business/srs/srs-review.md` |
| W4 | Học & 5 lối vào (NewLearn 5 chặng) | W3, W5 | Planned | `docs/business/study/study-flow.md` |
| W5 | 4 game luyện | W2 | Planned | `docs/business/game/game-modes.md` |
| W6 | Thư mục | W1 | Planned | `docs/business/folder/folder-management.md` |
| W7 | Bộ thẻ | W6, W2 | Planned | `docs/business/deck/deck-management.md` |
| W8 | Tìm kiếm | W2 | Planned | `docs/business/search/global-search.md` |
| W9 | Nhập / Xuất | W7 | Planned | `docs/business/import-export/import-export.md` |
| W10 | Thống kê | W3, W12 | Planned | `docs/business/statistics/statistics.md` |
| W11 | Tài khoản & Đồng bộ Google | W1 | Planned | `docs/business/account-sync/account-sync.md` |
| W12 | Gắn kết / streak | W4 | Planned | `docs/business/engagement/dashboard-engagement.md` |
| W13 | Cài đặt & Backup cục bộ | W1 | Planned | `docs/business/settings/settings.md` |
| W14 | Theme (personalization) | W13 | Planned | `docs/business/personalization/personalization.md` |

Status ∈ Planned / In-progress / Blocked / Done. Tất cả đang **Planned** (spec xong, chưa code).

## 2. Map sang dòng quyết định

| WBS | Dòng quyết định (core-decision-table) |
| --- | --- |
| W2 | D-006, D-020 |
| W3 | D-002, D-003, D-004, D-005, D-011, D-018 |
| W4 | D-001, D-007, D-009, D-010, D-016, D-029 |
| W5 | D-008, D-013, D-015 |
| W8 | D-019, D-028 |
| W9 | D-025, D-026 |
| W11 | D-027 |
| W12 | D-010, D-021 |
| W13 | D-012 (Premium — hoãn v1) |

## 10. Commit Traceability Log

Append-only, newest first. One line per commit that touches a WBS work package:
`<8-char hash> · <YYYY-MM-DD> · <WBS IDs> · <summary>`.

- TBD · 2026-06-27 · W1–W14 · populate WBS; fill contract/architecture/index stubs (AI-agent readiness)
- 4879608 · 2026-06-26 · — · initial business specs + skeleton import

## Related

- `docs/business/index.md` — features being tracked
- `docs/business/system/overview.md` — implementation status
