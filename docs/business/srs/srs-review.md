# Tính năng: Ôn tập SRS (Leitner)

**Status:** Specified
**Phụ trách:** TBD
**Liên quan:** dòng quyết định D-002, D-003, D-004, D-005, D-011 · WBS TBD

## Mục đích

Lập lịch khi nào mỗi thẻ được ôn bằng hệ **ô Leitner**, để người học gặp thẻ đến hạn
ở khoảng cách giãn dần và thẻ mới với liều lượng kiểm soát. Xác nhận từ app tham
chiếu: cài đặt có "Ô: 7" (số ô cấu hình được).

## Mô hình

- Mỗi thẻ có **một** `SrsState` (một chiều duy nhất) với ô hiện tại `0..8`.
- `N` = `leitner_box_count`. **MemoX dùng 8 ô** (thuật toán 8-box; app gốc mặc định 7).
- Ô càng cao ⇒ khoảng cách ôn càng dài. Thẻ mới ở **ô 0** (chưa xếp lịch). Chỉ khi
  **hoàn thành đủ 5 chặng NewLearn** thẻ mới **vào ô 1**; bỏ dở giữa chừng → vẫn là thẻ mới.

## Khoảng cách ôn (đã chốt)

| Ô | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Khoảng cách | 1 ngày | 3 ngày | 7 ngày | 14 ngày | 30 ngày | 60 ngày | 120 ngày | đã thuộc |

`due_at` = lần ôn gần nhất + khoảng cách của ô hiện tại. **Ô 8 = đã thuộc**: ngừng xếp
lịch ôn (không còn vào hàng đợi đến hạn).

## Hai lối vào (tách biệt)

SRS có hai lối, dùng hai pool thẻ khác nhau, **không gộp** (xem `docs/business/study/study-flow.md`):

- **DueReview** (nút Play): ôn các thẻ `due` (`due_at <= now`) — số đến hạn = badge đỏ.
- **NewLearn** ("Học"): học các thẻ `new` (chưa xếp lịch) — số "X từ mới".

Cả hai dùng chung cách chấm và chuyển ô dưới đây.

## Chuyển ô khi ôn "Lặp lại" (DueReview)

1. Người học tự chấm mỗi thẻ **Đúng / Sai**.
2. **Đúng:** thẻ **lên một ô** (`box = min(box+1, 8)`), `due_at` theo ô mới.
3. **Sai:** thẻ **lùi một ô** (`box = max(box-1, 1)`), `due_at` theo ô mới.
4. Ghi `last_result` và `reviewed_at`; cộng dồn `DailyActivity`.

> Sai còn làm thẻ **học lại trong phiên** (quay lại hàng đợi đến khi đúng), ngoài
> việc lùi 1 ô cho lần sau. (D-015)

## Luật & ca biên

- **Trần/sàn ô:** Đúng ở ô 8 giữ nguyên ô 8 (đã thuộc); Sai ở ô 1 giữ nguyên ô 1. (D-005)
- **Thẻ ẩn** không bao giờ vào hàng đợi lẫn bị tính đến hạn. (D-006)
- **Một chiều:** mỗi thẻ có **một** `SrsState`; đổi chiều hiển thị (KO↔VI) không tạo lịch riêng. (D-011)
- **Progress %** của một nút suy ra từ vị trí ô của các thẻ trong nút.
- Chỉ DueReview/NewLearn làm đổi `SrsState`; Review/Game/Player thì không. (D-007)
- **Hạn mức thẻ mới/ngày:** NewLearn lấy tối đa `new_cards_per_day` thẻ mới mỗi ngày
  (mặc định 20, chỉnh được). (D-018)

## Ngoài phạm vi (nói rõ)

- Lập lịch theo hệ số dễ SM-2 / FSRS — v1 chỉ dùng Leitner.

## File mã nguồn

TBD (chưa hiện thực).

## Liên quan

- `docs/business/study/study-flow.md` — hai lối vào & vòng chấm
- `docs/database/schema-contract.md` — `srs_state`
- `docs/decision-tables/core-decision-table.md`
