# MemoX V4 — Tóm tắt yêu cầu nghiệp vụ (BRD-lite)

Tài liệu đầu vào cho phần đặc tả nghiệp vụ: tầm nhìn, người dùng, phạm vi và danh mục
tính năng. Mỗi tính năng có một đặc tả nghiệp vụ riêng theo chuẩn BA
(`docs/business/_feature-template.md`).

## 1. Tầm nhìn & mục tiêu

MemoX là ứng dụng học từ vựng bằng thẻ và lặp lại giãn cách (SRS), giúp người học **ghi
nhớ lâu dài với ít công sức nhất**. Mục tiêu sản phẩm:

- Học đúng thẻ vào đúng thời điểm (SRS), giảm ôn thừa và quên sót.
- Giữ người học quay lại đều đặn (mục tiêu ngày + streak).
- Cho người học toàn quyền tổ chức và sở hữu nội dung học của mình.

## 2. Vấn đề & cơ hội

Người học từ vựng thường quên do ôn không đúng nhịp, mất động lực do thiếu phản hồi tiến
độ, và ngại nhập liệu thủ công. MemoX giải quyết bằng lập lịch tự động, gamification nhẹ,
và nhập/xuất linh hoạt.

## 3. Người dùng mục tiêu

Người tự học ngoại ngữ (ví dụ tiếng Hàn cho người Việt), dùng đa thiết bị, muốn kiểm soát
nội dung học và duy trì thói quen hằng ngày.

## 4. Phạm vi sản phẩm (v1)

**Trong phạm vi:** quản lý nội dung (bộ thẻ lồng nhau/thẻ), SRS 8 ô, các hình thức học &
luyện, tìm kiếm, nhập/xuất, thống kê & gắn kết, đồng bộ Google (alpha), cài đặt & cá nhân hoá.
**Ngoài phạm vi (v1):** kiếm tiền Premium; chia sẻ nội dung giữa người dùng; media ngoài âm thanh.

## 5. Danh mục tính năng

| Miền | Tính năng | Đặc tả | WBS | Trạng thái |
| --- | --- | --- | --- | --- |
| flashcard | Quản lý Thẻ học | `docs/business/flashcard/flashcard-management.md` | W2 | Implemented |
| srs | Ôn tập SRS (8 ô Leitner) | `docs/business/srs/srs-review.md` | W3 | Implemented |
| study | Luồng học & luyện tập | `docs/business/study/study-flow.md` | W4 | Implemented |
| game | Bốn trò chơi luyện tập | `docs/business/game/game-modes.md` | W5 | Implemented |
| deck | Quản lý Bộ thẻ (cây lồng nhau) | `docs/business/deck/deck-management.md` | W6 | Implemented |
| search | Tìm kiếm thẻ | `docs/business/search/global-search.md` | W7 | Implemented |
| import-export | Nhập & Xuất dữ liệu | `docs/business/import-export/import-export.md` | W8 | Implemented |
| statistics | Thống kê học tập | `docs/business/statistics/statistics.md` | W9 | Implemented |
| account-sync | Tài khoản & Đồng bộ | `docs/business/account-sync/account-sync.md` | W10 | Implemented (alpha) |
| engagement | Hoạt động, mục tiêu & streak | `docs/business/engagement/dashboard-engagement.md` | W11 | Implemented |
| settings | Cài đặt, sao lưu & kiếm tiền | `docs/business/settings/settings.md` | W12 | Implemented |
| personalization | Cá nhân hoá giao diện | `docs/business/personalization/personalization.md` | W13 | Implemented |

## 6. Cách thêm một đặc tả tính năng

1. Sao chép `docs/business/_feature-template.md` sang `docs/business/<area>/<feature>.md`.
2. Thêm thuật ngữ mới vào `docs/business/glossary.md`.
3. Thêm các nhánh kiểm thử vào `docs/decision-tables/core-decision-table.md`.
4. Thêm gói công việc vào `docs/project-management/wbs.md`.

## Liên quan

- `docs/business/system/overview.md` — tài liệu bối cảnh nghiệp vụ
- `docs/business/system/system-flow.md` — sơ đồ luồng toàn hệ thống
- `docs/business/glossary.md` — thuật ngữ nghiệp vụ
- `docs/decision-tables/core-decision-table.md` — quy tắc & tiêu chí kiểm thử
- `docs/project-management/wbs.md` — phân rã công việc
