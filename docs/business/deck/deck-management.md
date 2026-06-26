# DECK — Quản lý Bộ thẻ — Đặc tả nghiệp vụ

## 0. Thông tin tài liệu

| Trường | Giá trị |
| --- | --- |
| Mã tính năng | `deck/deck-management` |
| Gói công việc (WBS) | W7 |
| Trạng thái | Specified |
| Người phụ trách | TBD |
| Dòng quyết định liên quan | D-024 |
| Phiên bản | 1.0 |

## 1. Mục đích & bối cảnh nghiệp vụ

Bộ thẻ là tập hợp thẻ học theo một chủ đề và là đơn vị mà người học thực sự "học" hằng
ngày. Người học cần tạo, đặt tên, di chuyển và xoá bộ thẻ, cũng như nạp thẻ vào đó (thủ
công hoặc nhập hàng loạt). Bộ thẻ nằm ở gốc thư viện hoặc bên trong một thư mục.

## 2. Phạm vi

**Trong phạm vi:** tạo, đổi tên, di chuyển, xoá và sắp xếp bộ thẻ; điểm vào để thêm/nhập thẻ.
**Ngoài phạm vi (v1):** tự động trộn/gộp hai bộ thẻ.

## 3. Tác nhân & các bên liên quan

| Tác nhân | Vai trò |
| --- | --- |
| Người học | Tạo và quản lý bộ thẻ; thêm thẻ. |

## 4. Câu chuyện người dùng (User stories)

- **US-1** — Là người học, tôi muốn tạo một bộ thẻ theo chủ đề, để gom các từ liên quan.
- **US-2** — Là người học, tôi muốn di chuyển bộ thẻ vào thư mục, để tổ chức lại thư viện.
- **US-3** — Là người học, tôi muốn xoá một bộ thẻ không còn cần, để dọn dẹp.

## 5. Luồng nghiệp vụ (Use cases)

### UC-1: Tạo / đổi tên / di chuyển bộ thẻ
- **Luồng chính:** người học tạo bộ thẻ (tên bắt buộc) ở gốc hoặc trong thư mục; có thể
  đổi tên hoặc đổi thư mục chứa.

### UC-2: Xoá bộ thẻ
- **Luồng chính:** người học xoá bộ thẻ; hệ thống yêu cầu xác nhận và xoá lan toàn bộ thẻ
  cùng dữ liệu liên quan (nghĩa, trạng thái ôn).

### UC-3: Thêm thẻ vào bộ thẻ
- **Luồng chính:** người học thêm thẻ thủ công ("Thêm từ") hoặc nạp hàng loạt qua Nhập.

## 6. Quy tắc nghiệp vụ (Business rules)

| Mã | Quy tắc | Lý do | Truy vết |
| --- | --- | --- | --- |
| BR-1 | Tên bộ thẻ bắt buộc, không rỗng. | Nhận diện được bộ thẻ. | — |
| BR-2 | Xoá bộ thẻ là xoá lan mọi thẻ, nghĩa và trạng thái ôn của bộ thẻ, sau xác nhận. | Tránh dữ liệu mồ côi. | D-024 |
| BR-3 | Sắp xếp bộ thẻ dùng chung tiêu chí với thư mục (bảng chữ cái / ngày tạo / ngày học). | Trải nghiệm nhất quán. | D-023 |

## 7. Tiêu chí chấp nhận (Acceptance criteria)

- **AC-1** — *Cho* một bộ thẻ có thẻ, *khi* xoá và xác nhận, *thì* toàn bộ thẻ và dữ liệu
  liên quan bị xoá. ↔ D-024
- **AC-2** — *Cho* tạo bộ thẻ với tên rỗng, *khi* lưu, *thì* hệ thống chặn. ↔ BR-1

## 8. Yêu cầu phi chức năng

- Mở bộ thẻ lớn (hàng nghìn thẻ) vẫn cuộn mượt (xem `docs/quality/performance-contract.md`).

## 9. Giả định · Ràng buộc · Phụ thuộc (RAID)

- **Phụ thuộc:** thư mục (`folder`), thẻ (`card`); tính năng Nhập/Xuất.

## 10. Câu hỏi mở

- Không.

## 11. Truy vết & liên quan

- **Quyết định:** `docs/decision-tables/core-decision-table.md` — D-024, D-023.
- **Spec liên quan:** `docs/business/folder/folder-management.md`,
  `docs/business/flashcard/flashcard-management.md`, `docs/business/import-export/import-export.md`.
- **Dữ liệu:** `docs/database/schema-contract.md` — bảng `deck`.
