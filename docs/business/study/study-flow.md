# STUDY — Luồng học & luyện tập — Đặc tả nghiệp vụ

## 0. Thông tin tài liệu

| Trường | Giá trị |
| --- | --- |
| Mã tính năng | `study/study-flow` |
| Gói công việc (WBS) | W4 |
| Trạng thái | Specified |
| Người phụ trách | TBD |
| Dòng quyết định liên quan | D-001, D-002, D-007, D-008, D-009, D-010, D-013, D-014, D-015, D-016, D-029 |
| Phiên bản | 1.0 |
| Trạng thái triển khai | Implemented (5 lối vào + Play menu + NewLearn 5 chặng + DueReview + Review/Player + result; **NewLearn chặng 1 = Xem lại, chặng 2–5 dùng game thật W5** (Ghép đôi/Đoán/Nhớ lại/Điền) lái qua `RoundActions` — `lib/presentation/features/game/round.dart`; DueReview = một lượt Nhớ lại chấm SRS) |

## 1. Mục đích & bối cảnh nghiệp vụ

Người học cần một điểm khởi đầu rõ ràng để học, ôn hoặc luyện tập từ bất kỳ bộ thẻ nào
(kể cả bộ thẻ cha gồm cả cây con). Nếu các hình thức học bị trộn lẫn, người học sẽ không hiểu hoạt động nào
ảnh hưởng tới lịch ôn của mình.

Tính năng này định nghĩa **năm lối vào** mở ra từ nút Play tại một nút, và phân định
rạch ròi: chỉ **học thẻ mới** và **ôn thẻ đến hạn** mới thay đổi lịch ôn (SRS) và được
ghi nhận thành hoạt động; còn xem lại, trò chơi và trình phát là **luyện tập** thuần,
không ảnh hưởng lịch.

## 2. Phạm vi

**Trong phạm vi:** năm lối vào; lộ trình học thẻ mới gồm 5 chặng khó dần; quy tắc
học-lại-khi-sai áp cho mọi hình thức; điều kiện hiển thị từng lối vào; điều kiện ghi
nhận hoạt động.

**Ngoài phạm vi:** cơ chế bên trong 4 trò chơi (xem `docs/business/game/game-modes.md`);
thuật toán lập lịch (xem `docs/business/srs/srs-review.md`); học trộn nhiều cặp ngôn ngữ.

## 3. Tác nhân & các bên liên quan

| Tác nhân | Vai trò |
| --- | --- |
| Người học | Chọn nút, chọn lối vào, tự chấm trong khi học/luyện. |
| Hệ thống SRS | Nhận kết quả học/ôn để cập nhật lịch. |
| Hệ thống gắn kết | Nhận hoạt động để tính mục tiêu/streak. |

## 4. Câu chuyện người dùng (User stories)

- **US-1** — Là người học, tôi muốn ôn đúng các thẻ đã đến hạn, để củng cố trước khi quên.
- **US-2** — Là người học, tôi muốn học thẻ mới theo lộ trình khó dần, để tiếp thu vững chắc.
- **US-3** — Là người học, tôi muốn luyện tự do (trò chơi, xem lại) mà không ảnh hưởng
  lịch ôn, để giải trí hoặc ôn thêm tuỳ ý.
- **US-4** — Là người học, tôi muốn nghe phát tự động, để học rảnh tay.

## 5. Luồng nghiệp vụ (Use cases)

### UC-1: Chọn nút và mở menu hành động
- **Luồng chính:** người học bấm nút Play tại một bộ thẻ (lá hoặc cha); hệ thống mở menu gồm
  các lối vào phù hợp.
- **Quy tắc hiển thị:** mục **"Lặp lại"** chỉ xuất hiện khi nút có thẻ đến hạn (badge > 0).

### UC-2: Học thẻ mới (chuỗi 5 chặng)
- **Tiền điều kiện:** nút có thẻ mới.
- **Luồng chính:** người học chọn "Học"; hệ thống dẫn qua **5 chặng khó dần**: Xem lại
  → Ghép đôi → Đoán → Nhớ lại → Điền (tiến độ tích luỹ 0→100%). Hoàn thành đủ 5 chặng,
  thẻ được đưa vào ô 1 của lịch ôn.
- **Luồng ngoại lệ:** trả lời sai ở bất kỳ chặng nào → thẻ quay lại hàng đợi, học lại
  đến khi đúng; thoát giữa chừng → thẻ vẫn là Mới.
- **Hậu điều kiện:** thẻ mới được xếp lịch; hoạt động trong ngày được cộng dồn.

### UC-3: Ôn thẻ đến hạn ("Lặp lại")
- **Tiền điều kiện:** nút có thẻ đến hạn.
- **Luồng chính:** người học chọn "Lặp lại" (nhãn "Lặp lại N từ"); hệ thống tái sử dụng
  chính màn của các hình thức học; kết thúc một hình thức thì mời học lại đúng hình thức
  đó. Tự chấm cập nhật lịch ôn.
- **Hậu điều kiện:** lịch ôn các thẻ được cập nhật; hoạt động được cộng dồn.

### UC-4: Luyện tập (Xem lại / Trò chơi / Trình phát)
- **Luồng chính:** người học chọn một trong ba; hệ thống chạy trên cùng tập thẻ nhưng
  **không** thay đổi lịch ôn và **không** cộng hoạt động.

## 6. Quy tắc nghiệp vụ (Business rules)

| Mã | Quy tắc | Lý do | Truy vết |
| --- | --- | --- | --- |
| BR-1 | Có 5 lối vào: Lặp lại, Học, Xem lại các từ, Một trò chơi, Trình phát. | Tách bạch học có lịch và luyện tập. | — |
| BR-2 | "Lặp lại" chỉ hiển thị khi nút có thẻ đến hạn. | Không mời ôn khi không có gì để ôn. | D-001, D-016 |
| BR-3 | "Học" dẫn qua chuỗi 5 chặng; thẻ vào ô 1 sau khi hoàn thành đủ 5 chặng. | Đảm bảo tiếp xúc đủ trước khi xếp lịch. | D-002 |
| BR-4 | Trả lời sai ở **bất kỳ** hình thức học nào → thẻ học lại đến khi đúng hết. | Không bỏ sót thẻ chưa nắm. | D-015 |
| BR-5 | Chỉ "Lặp lại" và "Học" thay đổi lịch ôn và cộng hoạt động ngày. | Luyện tập không nên làm sai lệch lịch/độ chuyên cần. | D-007, D-010 |
| BR-6 | Học/ôn tại một bộ thẻ cha gộp **đệ quy** toàn bộ thẻ của các bộ thẻ con. | Cho phép học theo nhóm chủ đề. | D-009 |
| BR-7 | Mỗi ván trò chơi dùng `game_words_per_round` thẻ (mặc định 5). | Giữ ván ngắn, tập trung. | D-008 |
| BR-8 | "Trình phát" phát tự động kèm âm thanh, không đổi lịch ôn. | Hỗ trợ học thụ động, rảnh tay. | D-014 |

## 7. Tiêu chí chấp nhận (Acceptance criteria)

- **AC-1** — *Cho* nút không có thẻ đến hạn, *khi* mở menu Play, *thì* không có mục "Lặp lại". ↔ D-016
- **AC-2** — *Cho* người học hoàn thành đủ 5 chặng của "Học", *thì* thẻ mới vào ô 1. ↔ D-002
- **AC-3** — *Cho* một hình thức học, *khi* trả lời sai, *thì* thẻ được đưa lại hàng đợi
  cho đến khi mọi thẻ đúng. ↔ D-015
- **AC-4** — *Cho* hình thức Xem lại / Trò chơi / Trình phát, *khi* kết thúc, *thì* lịch
  ôn không đổi. ↔ D-007

## 8. Yêu cầu phi chức năng

- Dựng hàng đợi học/ôn cho một nút lớn trong khoảng dưới 100 ms.

## 9. Giả định · Ràng buộc · Phụ thuộc (RAID)

- **Giả định:** người học tự chấm trung thực.
- **Ràng buộc:** một phiên không trộn nhiều cặp ngôn ngữ.
- **Phụ thuộc:** thuật toán SRS (srs-review); cơ chế 4 trò chơi (game-modes).

## 10. Câu hỏi mở

- Không còn câu hỏi mở ở mức nghiệp vụ; chi tiết màn "Lặp lại" sẽ chốt khi thiết kế UI.

## 11. Truy vết & liên quan

- **Quyết định:** `docs/decision-tables/core-decision-table.md` — D-001, D-002, D-007–D-010, D-013–D-016, D-029.
- **Spec liên quan:** `docs/business/srs/srs-review.md`, `docs/business/game/game-modes.md`,
  `docs/business/flashcard/flashcard-management.md`.
- **Sơ đồ luồng:** `docs/business/system/system-flow.md`.
