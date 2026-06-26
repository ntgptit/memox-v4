# Hợp đồng schema — MemoX V4

Nguồn chân lý cho cấu trúc dữ liệu lưu trữ. Một thay đổi schema bắt buộc đi kèm file
này + `docs/database/migration-contract.md` + một test, **trong cùng một commit** (hard rule).

**Status:** Specified — *đề xuất v1, rút từ phân tích app tham chiếu; chưa có code.*

## Phiên bản hiện tại

`schema_version = 1`

## Bảng / collection / key

> Tên bảng và cột để tiếng Anh (khớp code). Cột "Ghi chú" mô tả bằng tiếng Việt.

### language_pair

| Cột | Kiểu | Null | Mặc định | Ghi chú |
| --- | --- | --- | --- | --- |
| id | int | no | | khoá chính |
| source_lang | text | no | | mã ngôn ngữ đang học (vd `ko`) |
| target_lang | text | no | | mã ngôn ngữ phía người học (vd `vi`) |
| order_index | int | no | 0 | thứ tự hiển thị |

### folder

| Cột | Kiểu | Null | Mặc định | Ghi chú |
| --- | --- | --- | --- | --- |
| id | int | no | | khoá chính |
| pair_id | int | no | | → `language_pair.id` |
| parent_id | int | yes | null | → `folder.id`; null = gốc |
| name | text | no | | |
| order_index | int | no | 0 | thứ tự giữa các anh em |

### deck

| Cột | Kiểu | Null | Mặc định | Ghi chú |
| --- | --- | --- | --- | --- |
| id | int | no | | khoá chính |
| pair_id | int | no | | → `language_pair.id` |
| folder_id | int | yes | null | → `folder.id`; null = deck ở gốc |
| name | text | no | | |
| order_index | int | no | 0 | thứ tự giữa các anh em |

### card

| Cột | Kiểu | Null | Mặc định | Ghi chú |
| --- | --- | --- | --- | --- |
| id | int | no | | khoá chính |
| deck_id | int | no | | → `deck.id` |
| term | text | no | | mặt ngôn ngữ-đang-học (mặt hỏi) |
| gender | text | yes | null | giới tính ngữ pháp (ngôn ngữ có giống) |
| audio_ref | text | yes | null | con trỏ TTS/audio |
| hidden | bool | no | false | loại khỏi hàng đợi & số đến hạn |
| order_index | int | no | 0 | thứ tự trong deck |
| created_at | int | no | | epoch ms |
| last_studied_at | int | yes | null | epoch ms |

### card_meaning

Mỗi dòng là phần nghĩa theo một ngôn ngữ (mẹ đẻ + tuỳ chọn trung gian, vd EN). Nội
dung là **một ô văn bản tự do** — người dùng gõ chung dịch + từ loại + định nghĩa +
từ nguyên vào một ô (xác nhận: màn tạo/sửa thẻ dùng một ô văn bản, không phải nhiều cột).

| Cột | Kiểu | Null | Mặc định | Ghi chú |
| --- | --- | --- | --- | --- |
| id | int | no | | khoá chính |
| card_id | int | no | | → `card.id` |
| lang | text | no | | mã ngôn ngữ của phần nghĩa này |
| text | text | no | | nội dung nghĩa (văn bản tự do) |

### srs_state

Một thẻ có **một** dòng (một chiều duy nhất) — lập lịch Leitner.

| Cột | Kiểu | Null | Mặc định | Ghi chú |
| --- | --- | --- | --- | --- |
| card_id | int | no | | khoá chính, → `card.id` |
| box | int | no | 0 | 0 = thẻ mới (chưa xếp lịch); 1..8 sau khi hoàn thành NewLearn |
| due_at | int | yes | null | epoch ms; null = mới, chưa xếp lịch |
| last_result | text | yes | null | `correct` / `wrong` |
| reviewed_at | int | yes | null | epoch ms |

### daily_activity

| Cột | Kiểu | Null | Mặc định | Ghi chú |
| --- | --- | --- | --- | --- |
| day | text | no | | `YYYY-MM-DD` (giờ máy) |
| pair_id | int | no | | → `language_pair.id` |
| seconds | int | no | 0 | thời gian học |
| words | int | no | 0 | số thẻ đã học |

### settings (key-value)

| Key | Kiểu | Mặc định | Ghi chú |
| --- | --- | --- | --- |
| native_language | text | locale máy | UI: "Tiếng mẹ đẻ" |
| ui_language | text | locale máy | ngôn ngữ giao diện |
| leitner_box_count | int | 8 | UI: "Ô". MemoX dùng thuật toán 8 ô (app gốc mặc định 7) |
| game_words_per_round | int | 5 | UI: "Số từ trong các trò chơi" |
| game_random | bool | true | chọn thẻ ngẫu nhiên |
| reminder_time | text | null | `HH:mm` |
| reminder_weekdays | text | null | bitmask/CSV các thứ trong tuần |
| auto_backup | bool | true | |
| backup_path | text | null | đường dẫn file cục bộ |
| premium_active | bool | false | suy ra từ thuê bao của store (Premium hoãn v1) |
| new_cards_per_day | int | 20 | NewLearn: hạn mức thẻ mới/ngày (chỉnh được) |
| daily_goal_minutes | int | null | mục tiêu thời gian học/ngày |
| daily_goal_words | int | null | mục tiêu số từ học/ngày |

## Index

| Bảng | Cột | Lý do |
| --- | --- | --- |
| card | (deck_id, order_index) | liệt kê một deck theo thứ tự |
| srs_state | (due_at) | dựng hàng đợi đến hạn nhanh |
| folder | (pair_id, parent_id, order_index) | render cây |
| deck | (pair_id, folder_id, order_index) | render cây |
| card_meaning | (card_id) | nạp các nghĩa của một thẻ |

## Bất biến (invariants)

- Một `card` thuộc đúng một `deck`; một `deck` thuộc tối đa một `folder`; một
  `folder` thuộc tối đa một `folder` cha — không có chu trình.
- `srs_state.box` ∈ [0, 8]: `0` = thẻ mới (chưa xếp lịch); vào `1` khi hoàn thành đủ
  5 chặng NewLearn; sau đó Đúng +1 (trần 8), Sai −1 (sàn 1).
- Thẻ `hidden = true` không bao giờ xuất hiện trong hàng đợi học lẫn `DueCount`.
- Xoá một `deck` xoá lan các `card`, `card_meaning` và `srs_state` của nó.
- Xoá một `folder` xoá lan toàn bộ cây con (thư mục con + deck + thẻ + meaning + srs).
- `daily_activity` chỉ được cộng bởi DueReview/NewLearn (không phải Review/Game/Player).
- **Hiển thị (xác nhận):** số "X từ" trên mỗi nút là số thẻ ĐANG HIỂN THỊ (KHÔNG gồm
  thẻ ẩn); biểu tượng 👁 + số = số thẻ ẩn (tính thêm; tổng = X + ẩn).

## Liên quan

- `docs/database/migration-contract.md` — migration theo phiên bản
- `docs/database/storage-boundaries.md` — cái gì lưu ở đâu
- `docs/contracts/types-catalog.md` — enum lưu trữ (`last_result`, `CardStatus`)
- `docs/business/flashcard/flashcard-management.md` — Card dưới góc người dùng
- `docs/business/srs/srs-review.md` — cách `srs_state` biến đổi
