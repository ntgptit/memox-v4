# FLASHCARD — Quản lý Thẻ học — Đặc tả nghiệp vụ

## 0. Thông tin tài liệu

| Trường | Giá trị |
| --- | --- |
| Mã tính năng | `flashcard/flashcard-management` |
| Gói công việc (WBS) | W2 |
| Trạng thái | Specified |
| Người phụ trách | TBD |
| Dòng quyết định liên quan | D-006, D-011, D-020 |
| Phiên bản | 1.0 |

## 1. Mục đích & bối cảnh nghiệp vụ

Thẻ học là đơn vị kiến thức nhỏ nhất và là tài sản trung tâm của MemoX: mọi hoạt động
học, ôn tập, luyện và thống kê đều quy chiếu về thẻ. Vì vậy chất lượng mô hình thẻ
quyết định trải nghiệm của toàn sản phẩm.

Quan sát từ thực tế người học cho thấy một mục từ vựng hiếm khi chỉ là cặp "mặt
trước – mặt sau". Người học thường ghi kèm bản dịch, từ loại, định nghĩa và chú thích
(ví dụ âm Hán Việt) để gợi nhớ tốt hơn. Do đó tính năng này định nghĩa thẻ là một bản
ghi **nhiều trường**: một *term* (mặt ngôn ngữ đang học) cùng một hoặc nhiều khối
*nghĩa* theo ngôn ngữ, kèm âm thanh phát âm và các cờ trạng thái. Tính năng cũng cho
phép người học chỉnh sửa, ẩn hoặc xoá thẻ khi nội dung thay đổi, để bộ sưu tập luôn
phản ánh đúng nhu cầu học hiện tại.

## 2. Phạm vi

**Trong phạm vi:** tạo, xem, chỉnh sửa, sắp xếp, ẩn và xoá thẻ; cấu trúc trường của
thẻ; phát âm term qua tổng hợp giọng nói; và điểm tích hợp nạp thẻ hàng loạt (chi tiết
ở tính năng Nhập/Xuất).

**Ngoài phạm vi (v1):** media ngoài âm thanh (ảnh, video); âm thanh riêng cho từng
nghĩa; gắn thẻ phân loại (tag). Những hạng mục này được ghi nhận để cân nhắc ở phiên
bản sau, không triển khai ở v1.

## 3. Tác nhân & các bên liên quan

| Tác nhân | Vai trò trong tính năng |
| --- | --- |
| Người học | Tạo, sửa, ẩn, xoá và tra cứu thẻ; là người thụ hưởng chính. |
| Dịch vụ tổng hợp giọng nói (TTS) | Sinh âm thanh phát âm cho term. |
| Hệ thống SRS | Tiêu thụ thẻ để lập lịch ôn (phụ thuộc trạng thái ẩn). |

## 4. Câu chuyện người dùng (User stories)

- **US-1** — Là người học, tôi muốn tạo một thẻ gồm term và nghĩa, để lưu lại từ mới
  vừa gặp.
- **US-2** — Là người học, tôi muốn ghi kèm bản dịch phụ (ví dụ tiếng Anh) và chú
  thích, để hiểu sâu và nhớ lâu hơn.
- **US-3** — Là người học, tôi muốn chỉnh sửa nhanh một thẻ ngay trong lúc đang ôn,
  để sửa lỗi mà không gián đoạn việc học.
- **US-4** — Là người học, tôi muốn ẩn những thẻ đã thuộc hoặc không muốn học, để
  chúng không làm nhiễu hàng đợi ôn tập.
- **US-5** — Là người học, tôi muốn nghe phát âm của term, để học đúng cách đọc.

## 5. Luồng nghiệp vụ (Use cases)

### UC-1: Tạo thẻ mới
- **Tiền điều kiện:** người học đang ở trong một bộ thẻ.
- **Luồng chính:**
  1. Người học chọn "Thêm từ".
  2. Người học nhập *term* (bắt buộc) và *nghĩa* tiếng mẹ đẻ (bắt buộc); tuỳ chọn thêm
     bản dịch phụ, giới tính ngữ pháp.
  3. Hệ thống sinh âm thanh phát âm cho term.
  4. Hệ thống lưu thẻ ở trạng thái **Mới** trong bộ thẻ hiện hành.
- **Luồng thay thế / ngoại lệ:**
  - *Thiếu trường bắt buộc:* hệ thống chặn lưu và chỉ rõ trường còn thiếu.
  - *Trùng term trong cùng bộ thẻ:* hệ thống hiển thị cảnh báo nhưng vẫn cho phép thêm
    (xem BR-5).
- **Hậu điều kiện:** thẻ mới hiện trong bộ thẻ, được tính vào số thẻ hiển thị, sẵn
  sàng cho việc học.

### UC-2: Chỉnh sửa thẻ
- **Tiền điều kiện:** thẻ đã tồn tại.
- **Luồng chính:** người học mở thẻ (kể cả inline khi đang duyệt/ôn), thay đổi nội
  dung, lưu lại; hệ thống cập nhật và sinh lại âm thanh nếu term đổi.
- **Hậu điều kiện:** nội dung thẻ được cập nhật; lịch ôn (SRS) không thay đổi.

### UC-3: Ẩn / hiện thẻ
- **Luồng chính:** người học bật cờ ẩn cho thẻ.
- **Hậu điều kiện:** thẻ bị loại khỏi hàng đợi học và khỏi số "đến hạn", nhưng dữ liệu
  vẫn được giữ; có thể hiện lại (xem BR-4).

### UC-4: Xoá thẻ
- **Luồng chính:** người học xoá thẻ; hệ thống yêu cầu xác nhận.
- **Hậu điều kiện:** thẻ và toàn bộ dữ liệu liên quan (nghĩa, trạng thái ôn) bị xoá.

## 6. Quy tắc nghiệp vụ (Business rules)

| Mã | Quy tắc | Lý do | Truy vết |
| --- | --- | --- | --- |
| BR-1 | Mỗi thẻ thuộc về đúng một bộ thẻ. | Bảo đảm tính sở hữu rõ ràng và xoá lan nhất quán. | — |
| BR-2 | Term và ít nhất một nghĩa (tiếng mẹ đẻ) là bắt buộc. | Một thẻ không có hai mặt thì không học được. | — |
| BR-3 | Nghĩa là một ô văn bản tự do; một thẻ có thể có nhiều nghĩa theo ngôn ngữ. | Phản ánh cách người học thực sự ghi chú; không ép cấu trúc cứng. | — |
| BR-4 | Thẻ ẩn bị loại khỏi hàng đợi học và khỏi số "đến hạn", nhưng dữ liệu được giữ. | Cho phép tạm gác thẻ mà không mất công sức đã nhập. | D-006 |
| BR-5 | Thẻ trùng term trong cùng bộ thẻ chỉ bị **cảnh báo mềm**, vẫn cho thêm. | Trùng đôi khi là chủ ý (đồng âm khác nghĩa); không nên chặn cứng. | D-020 |
| BR-6 | Số "X từ" hiển thị của một nút là số thẻ đang hiển thị, **không** gồm thẻ ẩn (đếm riêng). | Tránh hiểu nhầm khối lượng học còn lại. | — |

## 7. Tiêu chí chấp nhận (Acceptance criteria)

- **AC-1** — *Cho* một thẻ đang bị ẩn, *khi* hệ thống dựng hàng đợi học hoặc đếm số
  đến hạn, *thì* thẻ đó bị loại khỏi cả hai. ↔ D-006
- **AC-2** — *Cho* người học nhập một thẻ trùng term trong cùng bộ thẻ, *khi* lưu,
  *thì* hệ thống cảnh báo nhưng vẫn cho phép lưu. ↔ D-020
- **AC-3** — *Cho* một thẻ thiếu term hoặc thiếu nghĩa bắt buộc, *khi* lưu, *thì* hệ
  thống chặn và nêu rõ trường còn thiếu. ↔ BR-2

## 8. Yêu cầu phi chức năng

- Phát âm phản hồi trong khoảng dưới 1 giây sau thao tác.
- Chỉnh sửa inline phản hồi tức thì, không rời màn đang học.

## 9. Giả định · Ràng buộc · Phụ thuộc (RAID)

- **Giả định:** người học tự chịu trách nhiệm về nội dung thẻ.
- **Ràng buộc:** v1 chỉ hỗ trợ âm thanh ở cấp term, không ở cấp từng nghĩa.
- **Phụ thuộc:** dịch vụ TTS của thiết bị; cấu trúc lưu trữ `card` và `card_meaning`.

## 10. Câu hỏi mở

- Chính sách chống trùng nâng cao (gộp/đánh dấu) — cân nhắc khi có dữ liệu thực tế.

## 11. Truy vết & liên quan

- **Dữ liệu:** `docs/database/schema-contract.md` — bảng `card`, `card_meaning`.
- **Quyết định:** `docs/decision-tables/core-decision-table.md` — D-006, D-011, D-020.
- **Spec liên quan:** `docs/business/srs/srs-review.md`, `docs/business/deck/deck-management.md`,
  `docs/business/import-export/import-export.md`.
