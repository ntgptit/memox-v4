# GAME — Bốn trò chơi luyện tập — Đặc tả nghiệp vụ

## 0. Thông tin tài liệu

| Trường | Giá trị |
| --- | --- |
| Mã tính năng | `game/game-modes` |
| Gói công việc (WBS) | W5 |
| Trạng thái | Implemented (4 game + picker; luyện thuần, không đổi SRS — vào học từ menu Play là W4) |
| Người phụ trách | TBD |
| Dòng quyết định liên quan | D-008, D-013, D-015 |
| Phiên bản | 1.0 |

## 1. Mục đích & bối cảnh nghiệp vụ

Lặp lại đơn điệu khiến người học mất hứng và ghi nhớ kém. MemoX cung cấp **bốn trò chơi**
luyện từ vựng với mức độ chủ động tăng dần (nhận diện → gợi nhớ → tái tạo), giúp người
học củng cố cùng một tập thẻ qua nhiều góc độ.

Bốn trò chơi này được dùng ở **hai bối cảnh**: là các chặng 2–5 trong lộ trình học thẻ
mới, và được chọn chạy riêng qua mục "Một trò chơi". Khi chạy riêng, chúng là luyện tập
thuần, không ảnh hưởng lịch ôn.

## 2. Phạm vi

**Trong phạm vi:** bốn loại trò chơi và cách chơi; bộ chọn "Một trò chơi"; tuỳ chọn
phạm vi lấy từ; quy tắc học-lại-khi-sai trong ván.

**Ngoài phạm vi:** chuỗi 5 chặng học mới (xem `docs/business/study/study-flow.md`); tính
điểm/xếp hạng; biến thể trò chơi nghe/nói.

## 3. Tác nhân & các bên liên quan

| Tác nhân | Vai trò |
| --- | --- |
| Người học | Chọn và chơi trò chơi; tự chấm trong các trò có yếu tố gợi nhớ. |

## 4. Câu chuyện người dùng (User stories)

- **US-1** — Là người học, tôi muốn luyện từ qua trò chơi đa dạng, để học đỡ nhàm.
- **US-2** — Là người học, tôi muốn chọn riêng một trò chơi, để tập trung vào kiểu luyện
  mình thích.
- **US-3** — Là người học, tôi muốn trò chơi ưu tiên những thẻ đang đến hạn hoặc còn
  yếu, để luyện đúng chỗ cần.

## 5. Luồng nghiệp vụ (Use cases)

### UC-1: Chọn và chơi một trò chơi
- **Luồng chính:** người học chọn "Một trò chơi" tại một nút; hệ thống mở bộ chọn 1
  trong 4 trò chơi, kèm tuỳ chọn "Chế độ lặp lại giãn cách"; hệ thống lấy một tập thẻ
  (mặc định 5) và chạy trò chơi đã chọn.
- **Hậu điều kiện:** kết thúc ván; lịch ôn và hoạt động ngày **không** đổi.

### UC-2: Trả lời trong ván
- **Luồng chính:** với mỗi thẻ, người học thao tác theo kiểu trò chơi.
- **Luồng ngoại lệ (sai):** trả lời sai đưa thẻ quay lại hàng đợi của ván; ván chỉ kết
  thúc khi mọi thẻ đã đúng.

## 6. Bốn loại trò chơi

| Trò chơi | Cách chơi | Chiều kiểm tra |
| --- | --- | --- |
| Ghép đôi | Ghép cặp term ↔ nghĩa ở hai cột; cặp đúng biến mất. | cả hai |
| Đoán | Hiện một term, chọn nghĩa đúng trong N lựa chọn. | term → nghĩa |
| Nhớ lại | Hiện term, bấm "Hiển thị" lộ nghĩa, rồi tự chấm "Đã quên"/"Nhớ được". | term → nghĩa |
| Điền | Hiện nghĩa, gõ lại term; có "Kiểm tra"/"Trợ giúp", chấp nhận dung sai. | nghĩa → term |

**Ghi chú giao diện (parity — divergence có chủ đích):** bốn game widget dùng chung một
tầng render bằng **widget Material thô** (`Card`, `OutlinedButton`, `FilledButton`) thay vì
các primitive của design system (`MxCard`, `MxButton`). Ví dụ ở game Điền: ô nghĩa là
`Card` (không `MxCard`), các nút Trợ giúp/Kiểm tra/Thử lại/Chấp nhận là `OutlinedButton`/
`FilledButton` (không `MxButton`) — tất cả vẫn giữ đúng `mx-node:` identity key. Việc chuyển
tầng game sang `MxCard`/`MxButton` (kit-fit) là **task riêng** đụng cả bốn game, **hoãn
post-v1**; đến khi đó parity chỉ gate theo composition (node present/absent), KHÔNG assert
`MxCard` variant hay `MxButton` variant. Khác biệt FE↔kit này được ghi tại
`tool/parity/intent-ledger.json` (`game-typing/meaning`, `/check`, `/retry`, `/accept` =
`exceptionKind: component`).

## 7. Quy tắc nghiệp vụ (Business rules)

| Mã | Quy tắc | Lý do | Truy vết |
| --- | --- | --- | --- |
| BR-1 | "Một trò chơi" mở bộ chọn 1 trong 4 trò chơi để chạy riêng. | Người học chủ động chọn kiểu luyện. | D-013 |
| BR-2 | Mỗi ván dùng `game_words_per_round` thẻ (mặc định 5). | Giữ ván ngắn, tập trung. | D-008 |
| BR-3 | Trả lời sai trong bất kỳ trò chơi nào → thẻ lặp lại trong ván cho đến khi đúng. | Đảm bảo nắm được mọi thẻ trong ván. | D-015 |
| BR-4 | Trò chơi chạy riêng **không** đổi lịch ôn, **không** cộng hoạt động ngày. | Đây là luyện tập, không phải ôn theo lịch. | — |
| BR-5 | Tuỳ chọn "Chế độ lặp lại giãn cách": *Theo giãn cách* (ưu tiên đến hạn + mới), *Tất cả*, *Chỉ thẻ chưa thuộc*. | Cho người học hướng việc luyện vào nhóm thẻ mong muốn. | — |

## 8. Yêu cầu phi chức năng

- Phản hồi thao tác trong ván tức thì (cảm giác mượt).

## 9. Giả định · Ràng buộc · Phụ thuộc (RAID)

- **Giả định:** trong "Nhớ lại", người học tự chấm trung thực.
- **Ràng buộc:** chỉ bốn trò chơi; không có biến thể nghe/nói ở v1.
- **Phụ thuộc:** nội dung thẻ (term, nghĩa, audio).

## 10. Câu hỏi mở

- Không còn câu hỏi mở ở mức nghiệp vụ.

## 11. Truy vết & liên quan

- **Quyết định:** `docs/decision-tables/core-decision-table.md` — D-008, D-013, D-015.
- **Spec liên quan:** `docs/business/study/study-flow.md`, `docs/business/flashcard/flashcard-management.md`.
