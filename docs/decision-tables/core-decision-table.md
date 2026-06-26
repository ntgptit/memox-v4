# Bảng quyết định lõi — MemoX V4

Mỗi dòng là một nhánh hành vi kiểm thử được. Đây là cầu nối giữa spec và test: mỗi
dòng nên có một test, và mỗi test hành vi nên truy ngược về một dòng.

| ID | Tình huống (Given) | Hành động (When) | Kết quả mong đợi (Then) | Spec | Test |
| --- | --- | --- | --- | --- | --- |
| D-001 | nút có thẻ đến hạn (badge>0) | bấm Play → chọn "Lặp lại" | ôn N thẻ `due` (N = badge); mục "Lặp lại" chỉ hiện khi due>0 | `docs/business/study/study-flow.md` | TBD |
| D-002 | nút có thẻ mới | bấm "Học", hoàn thành đủ 5 chặng | thẻ `new` **vào ô 1** (xếp lịch); đổi `SrsState` | `docs/business/study/study-flow.md` | TBD |
| D-003 | thẻ ở ô k (<N), chấm Đúng | áp chuyển ô Leitner | thẻ → ô k+1; `due_at` theo khoảng cách mới | `docs/business/srs/srs-review.md` | TBD |
| D-004 | thẻ ở ô k (>1) khi "Lặp lại", chấm Sai | áp chuyển ô Leitner | thẻ → ô k-1 (lùi 1 ô; sàn ô 1) | `docs/business/srs/srs-review.md` | TBD |
| D-005 | thẻ ở ô 8, chấm Đúng | áp chuyển ô Leitner | giữ ở ô 8 (đã thuộc) | `docs/business/srs/srs-review.md` | TBD |
| D-006 | thẻ bị ẩn (`hidden`) | dựng hàng đợi / tính số đến hạn | loại thẻ khỏi cả hai | `docs/business/flashcard/flashcard-management.md` | TBD |
| D-007 | chạy Review / Game / Player | kết thúc hoạt động | `SrsState` không đổi | `docs/business/study/study-flow.md` | TBD |
| D-008 | `game_words_per_round` = 5 | bắt đầu một ván Game | ván dùng 5 thẻ (ngẫu nhiên nếu `game_random` bật) | `docs/business/study/study-flow.md` | TBD |
| D-009 | bắt đầu học tại một thư mục | dựng hàng đợi | gộp thẻ của mọi deck con | `docs/business/study/study-flow.md` | TBD |
| D-010 | kết thúc phiên DueReview/NewLearn | chốt phiên | `DailyActivity` cộng giây + số từ (chỉ DueReview/NewLearn; Game/Review/Player không) | `docs/business/study/study-flow.md` | TBD |
| D-011 | đảo chiều hiển thị (KO↔VI) | lập lịch một thẻ | dùng **cùng một** `SrsState` (một chiều duy nhất) | `docs/business/srs/srs-review.md` | TBD |
| D-012 | (HOÃN v1) Premium | — | Premium chưa phát triển ở v1 — chưa có tính năng bị khoá | `docs/business/settings/settings.md` | — |
| D-013 | bấm "Một trò chơi" tại một nút | mở picker | hiện menu chọn 1 trong 4 game (Ghép đôi/Đoán/Nhớ lại/Điền); game đã chọn chạy riêng, không đổi `SrsState` | `docs/business/game/game-modes.md` | TBD |
| D-014 | mở "Trình phát" tại một nút | phát tự động | lần lượt hiện term + nghĩa + audio, tự chuyển thẻ; không đổi `SrsState` | `docs/business/study/study-flow.md` | TBD |
| D-015 | **bất kỳ chế độ học** (NewLearn / 4 game / Lặp lại) | trả lời sai | thẻ **học lại** (quay lại hàng đợi); phiên xong khi MỌI thẻ đã đúng | `docs/business/study/study-flow.md` | TBD |
| D-016 | nút có due=0 | bấm Play mở menu | menu KHÔNG có mục "Lặp lại" (chỉ Học/Xem lại/Trò chơi/Trình phát) | `docs/business/study/study-flow.md` | TBD |
| D-017 | NewLearn chưa xong đủ 5 chặng | thoát giữa chừng | thẻ **vẫn là mới** (chưa vào ô 1) | `docs/business/study/study-flow.md` | TBD |
| D-018 | NewLearn, có thẻ mới | dựng hàng đợi học mới | lấy tối đa `new_cards_per_day` thẻ mới/ngày (mặc định 20) | `docs/business/srs/srs-review.md` | TBD |
| D-019 | nhập từ khoá tìm kiếm | tìm | khớp trên cả `term` và nghĩa (`card_meaning.text`) | `docs/business/search/global-search.md` | TBD |
| D-020 | tạo/nhập thẻ cùng term trong deck | lưu | **cảnh báo mềm**, vẫn cho thêm (không chặn) | `docs/business/flashcard/flashcard-management.md` | TBD |
| D-021 | ngày đạt ≥1 mục tiêu (phút HOẶC từ) | chốt ngày (nửa đêm giờ máy) | `streak +1`; ngày không đạt → streak reset 0 | `docs/business/engagement/dashboard-engagement.md` | TBD |
| D-022 | xoá một thư mục | xác nhận xoá | xoá lan toàn bộ cây con (thư mục con + deck + thẻ + meaning + srs) | `docs/business/folder/folder-management.md` | TBD |
| D-023 | đổi tiêu chí sắp xếp | sắp xếp danh sách | theo bảng chữ cái / ngày tạo / ngày học (tăng-giảm) | `docs/business/folder/folder-management.md` | TBD |
| D-024 | xoá một bộ thẻ | xác nhận xoá | xoá lan mọi thẻ + meaning + srs_state | `docs/business/deck/deck-management.md` | TBD |
| D-025 | import từ CSV/Excel/clipboard | chọn separator (tab/,/;) | tách cột đúng; preview; áp cảnh báo trùng (D-020) | `docs/business/import-export/import-export.md` | TBD |
| D-026 | export | chọn định dạng + có/không kèm SRS | CSV / Excel / copy text (separator cấu hình); cho chọn kèm ô/hạn ôn | `docs/business/import-export/import-export.md` | TBD |
| D-027 | sync gặp xung đột | hợp nhất | last-write-wins theo `updated_at` mức bản ghi | `docs/business/account-sync/account-sync.md` | TBD |
| D-028 | tìm kiếm | hiển thị kết quả | khớp term+nghĩa; **gồm cả thẻ ẩn**; có bộ lọc trạng thái (mới/đến hạn/đã thuộc) | `docs/business/search/global-search.md` | TBD |
| D-029 | kết thúc một mode trong DueReview | chốt mode | hiện "học lại" đúng mode vừa chạy (DueReview không có UI riêng) | `docs/business/study/study-flow.md` | TBD |

<!-- FILL: thêm một dòng mỗi khi thêm/đổi một nhánh (CLAUDE.md parity bước 6).
     Giữ ID ổn định và chỉ thêm mới để test trích dẫn được. -->

## Quy ước

- ID ổn định, chỉ thêm mới (`D-NNN`). Không đánh số lại.
- Một dòng được "phủ" chỉ khi có test khẳng định đúng Then cho Given/When của nó.
- Gỡ một hành vi: đánh dấu dòng `REMOVED` kèm commit, đừng xoá.

## Liên quan

- `docs/business/_feature-template.md` — hành vi tính năng
- `docs/testing/test-strategy.md` — test phủ các dòng
- `docs/acceptance-criteria/_template.md` — tiêu chí cho từng dòng
