# Tính năng: 4 game luyện tập & picker "Một trò chơi"

**Status:** Specified
**Phụ trách:** TBD
**Liên quan:** dòng quyết định D-008, D-013 · WBS TBD

## Mục đích

Có **4 loại game** luyện từ vựng. Chúng được dùng ở **hai nơi**:

1. Là **chặng 2–5** của chuỗi học thẻ mới (NewLearn) — xem `docs/business/study/study-flow.md`.
2. Chọn **chạy riêng** qua menu "Một trò chơi" (picker).

Khi chơi riêng qua "Một trò chơi", game **không đổi SRS** (chỉ luyện tập). Khi là chặng
của NewLearn, game cũng **không map riêng** vào SRS — chỉ hoàn thành đủ 5 chặng mới đưa
thẻ vào ô 1 (D-002).

## 4 loại game

| Loại (UI) | Canonical | Cách chơi | Chiều |
| --- | --- | --- | --- |
| Ghép đôi | MatchingGame | 2 cột (term ↔ nghĩa); ghép đúng cặp, cặp ghép biến mất | cả hai |
| Đoán | MultipleChoiceGame | 1 prompt (term) + N lựa chọn nghĩa; chọn đúng | term→nghĩa |
| Nhớ lại | RecallGame | hiện term → "Hiển thị" lộ nghĩa → tự chấm: "Đã quên" → **lặp lại thẻ trong ván**, "Nhớ được" → qua thẻ | term→nghĩa |
| Điền | TypingGame | hiện nghĩa → gõ term; "Kiểm tra" chấm, "Trợ giúp" gợi ý; sai thì "Thử lại", tự nhận "Đúng" | nghĩa→term |

## "Một trò chơi" (picker)

1. Bấm "Một trò chơi" tại một nút → mở menu chọn **1 trong 4 game** ở trên.
2. Kèm dropdown **"Chế độ lặp lại giãn cách"** — chọn cách lấy từ cho ván (tôi quyết):
   - **Theo giãn cách** (mặc định): ưu tiên thẻ đến hạn + thẻ mới theo lịch 8-box.
   - **Tất cả**: mọi thẻ trong nút, ngẫu nhiên.
   - **Chỉ thẻ chưa thuộc**: loại thẻ đã ở ô 8.
3. Chạy game đã chọn trên tập (mặc định `game_words_per_round` = 5; ngẫu nhiên khi
   `game_random`). (D-008)
4. **Không** đổi `SrsState`, **không** cộng `DailyActivity`.

## Luật & ca biên

- **Sai thì học lại (mọi chế độ):** trả lời sai ở **bất kỳ** game/chặng (không chỉ
  Nhớ lại/Điền) → thẻ **quay lại hàng đợi**, học lại; ván/phiên chỉ xong khi MỌI thẻ
  đã đúng. (D-015)
- "Điền" có gợi ý ("Trợ giúp") và cho người dùng **tự nhận đúng** ("Đúng") khi gõ lệch
  nhẹ — chấp nhận dung sai.

## Ngoài phạm vi (nói rõ)

- Tính điểm/xếp hạng (leaderboard) — không mô hình ở v1.

## File mã nguồn

TBD (chưa hiện thực).

## Liên quan

- `docs/business/study/study-flow.md` — 5 lối vào; chuỗi 5 chặng của NewLearn
- `docs/business/settings/settings.md` — cụm cài đặt Trò chơi
- `docs/decision-tables/core-decision-table.md` — D-008, D-013
