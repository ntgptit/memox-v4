# Tổng quan hệ thống & trạng thái — MemoX V4

Bảng trạng thái duy nhất. Bước 7 của Pre-commit parity check cập nhật bảng này khi
một mục chuyển Specified ↔ Implemented.

| Tính năng | Spec | Status | Kiểm chứng bởi |
| --- | --- | --- | --- |
| Quản lý Thẻ | `docs/business/flashcard/flashcard-management.md` | Specified | TBD |
| Ôn tập SRS (8-box Leitner) | `docs/business/srs/srs-review.md` | Specified | TBD |
| Luồng học & luyện tập | `docs/business/study/study-flow.md` | Specified | TBD |
| Trò chơi (4 game) | `docs/business/game/game-modes.md` | Specified | TBD |
| Quản lý Thư mục | `docs/business/folder/folder-management.md` | Specified | TBD |
| Quản lý Bộ thẻ | `docs/business/deck/deck-management.md` | Specified | TBD |
| Tìm kiếm | `docs/business/search/global-search.md` | Specified | TBD |
| Nhập / Xuất | `docs/business/import-export/import-export.md` | Specified | TBD |
| Thống kê | `docs/business/statistics/statistics.md` | Specified | TBD |
| Dashboard & streak | `docs/business/engagement/dashboard-engagement.md` | Specified | TBD |
| Tài khoản & Đồng bộ | `docs/business/account-sync/account-sync.md` | Specified | TBD |
| Cài đặt & sao lưu | `docs/business/settings/settings.md` | Specified | TBD |
| Cá nhân hoá (theme) | `docs/business/personalization/personalization.md` | Specified | TBD |

<!-- FILL: giữ trạng thái trung thực — chỉ "Implemented" khi đã có code + test (CLAUDE.md hard rule). -->

## Luồng tổng thể

Nội dung thuộc về một **LanguagePair**. Người học duyệt cây nút **Folder**/**Deck**
(mỗi nút hiện số từ hiển thị + số ẩn, % tiến độ, số đến hạn), chọn một nút bất kỳ, rồi chọn lối vào:

```
LanguagePair ─▶ Cây thư viện ─▶ Nút ─▶ bấm Play → menu
                                         ├─ Lặp lại (khi due>0) ─▶ ôn thẻ ĐẾN HẠN ─┐
                                         ├─ Học ─▶ học thẻ MỚI (5 chặng) ───────────┼─▶ tự chấm ─▶ Leitner (8 ô) ─▶ DailyActivity++
                                         └─ Xem lại / Trò chơi / Trình phát ─▶ chỉ luyện tập (không đổi SRS)
```

Chỉ **DueReview ("Lặp lại")** và **NewLearn ("Học")** làm đổi `SrsState` và `DailyActivity`.
Hệ thống nền: Cài đặt, Nhập/Xuất, Thống kê, **Backup** cục bộ (≠ **Sync** đám mây),
và thông báo **Reminder**. (Premium: hoãn v1.)

**Sơ đồ luồng đầy đủ (5 vùng, Mermaid):** `docs/business/system/system-flow.md`.

## Liên quan

- `docs/business/system/system-flow.md` — sơ đồ luồng toàn hệ thống (Mermaid)
- `docs/business/index.md` — danh sách tính năng
- `docs/project-management/wbs.md` — trạng thái bàn giao
