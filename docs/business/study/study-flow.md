# Tính năng: Luồng học & luyện tập

**Status:** Specified
**Phụ trách:** TBD
**Liên quan:** dòng quyết định D-001, D-002, D-007, D-008, D-009, D-010, D-013, D-014 · WBS TBD

## Mục đích

Bấm nút **▶ Play** tại một nút sẽ **mở một menu hành động**. Hai mục đổi SRS ("Học",
"Lặp lại"); ba mục còn lại chỉ luyện tập. Mục **"Lặp lại" chỉ hiện khi nút có thẻ đến
hạn** (badge > 0).

## Menu hành động (bấm Play)

| Mục menu (UI) | Canonical | Đổi SRS? | Mở ra |
| --- | --- | --- | --- |
| Học · "N từ mới" | NewLearn | **có** | học thẻ **MỚI** qua chuỗi 5 chặng khó dần |
| Lặp lại · "N từ" *(chỉ khi due>0)* | DueReview | **có** | ôn **N thẻ ĐẾN HẠN** (N = badge) |
| Xem lại các từ | ReviewMode | không | duyệt thẻ (term + nghĩa) |
| Một trò chơi · "đến hạn + mới" | Game | không | **picker** chọn 1 trong 4 game (trên thẻ đến hạn và/hoặc mới) |
| Trình phát | Player | không | phát tự động (auto-play) + audio |

## Học thẻ mới (NewLearn) — chuỗi 5 chặng khó dần

Bấm "Học" (X từ mới) → app dẫn qua **5 chặng** trên cùng tập thẻ mới, tiến độ tích lũy
0→100% (~20%/chặng), khó dần:

| TT | Chặng | Canonical | ≈ Tiến độ |
| --- | --- | --- | --- |
| 1 | Xem lại | ReviewMode | 0–16% |
| 2 | Ghép đôi | MatchingGame | 20–36% |
| 3 | Đoán | MultipleChoiceGame | 40% |
| 4 | Nhớ lại | RecallGame | 60–64% |
| 5 | Điền | TypingGame | 80–88% |

Chi tiết 4 game ở chặng 2–5: `docs/business/game/game-modes.md`. Thẻ **chỉ vào ô 1**
khi **hoàn thành đủ 5 chặng**; thoát giữa chừng → vẫn là thẻ mới. NewLearn cập nhật
`SrsState` + `DailyActivity` (đây là học thật). NewLearn lấy tối đa `new_cards_per_day`
thẻ mới/ngày (mặc định 20). (D-002, D-017, D-018)

## Ôn thẻ đến hạn (DueReview)

Chọn mục **"Lặp lại"** trong menu (chỉ hiện khi due>0; nhãn "Lặp lại N từ", N = badge)
→ ôn N thẻ `due`. Cập nhật `SrsState` + `DailyActivity`. (D-001, D-016)

DueReview **không có màn riêng** — dùng lại chính màn của các mode học; khi **kết thúc
một mode** thì hiện **"học lại"** đúng mode đó. (D-029)

## Một trò chơi (picker luyện tập)

Bấm "Một trò chơi" → mở **picker chọn 1 trong 4 game** để luyện riêng (Ghép đôi, Đoán,
Nhớ lại, Điền). Game lấy từ **thẻ đến hạn và/hoặc thẻ mới** của nút (menu hiển thị cả
hai số, vd "đến hạn 45 / mới 35"), kèm dropdown "Chế độ lặp lại giãn cách". Game
**không** đổi SRS. (D-013) Chi tiết: `docs/business/game/game-modes.md`.

## Xem lại các từ (ReviewMode)

Duyệt thẻ (term + nghĩa đầy đủ), sửa inline; không đổi SRS. Cũng là **chặng 1** của
chuỗi NewLearn. (D-007)

## Trình phát (Player)

Phát **tự động** lần lượt các thẻ (hiện term + nghĩa) kèm audio, rảnh tay; tiến độ
dạng chấm; không đổi SRS. (D-014)

## Luật & ca biên

- Học/ôn ở mức thư mục gộp mọi thẻ của các deck con. (D-009)
- `DailyActivity` chỉ cộng trong DueReview và NewLearn (không phải Review/Game/Player). (D-010)
- Số thẻ mỗi ván game = `game_words_per_round` (mặc định 5). (D-008)
- **Sai → học lại (mọi chế độ học):** sai ở bất kỳ chặng/game/Lặp lại → thẻ quay lại
  hàng đợi; phiên xong khi MỌI thẻ đã đúng. (D-015)

## Ngoài phạm vi (nói rõ)

- Học chéo cặp (một phiên không bao giờ trộn các cặp ngôn ngữ).

## File mã nguồn

TBD (chưa hiện thực).

## Liên quan

- `docs/business/srs/srs-review.md` — luật Leitner
- `docs/business/game/game-modes.md` — 4 game + picker "Một trò chơi"
- `docs/business/flashcard/flashcard-management.md` — nội dung thẻ
- `docs/decision-tables/core-decision-table.md`
