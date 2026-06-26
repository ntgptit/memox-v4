# FOLDER — Quản lý Thư mục — Đặc tả nghiệp vụ

## 0. Thông tin tài liệu

| Trường | Giá trị |
| --- | --- |
| Mã tính năng | `folder/folder-management` |
| Gói công việc (WBS) | W6 |
| Trạng thái | Specified |
| Người phụ trách | TBD |
| Dòng quyết định liên quan | D-022, D-023 |
| Phiên bản | 1.0 |

## 1. Mục đích & bối cảnh nghiệp vụ

Khi số lượng thẻ tăng, người học cần sắp xếp nội dung theo chủ đề để dễ tìm và học theo
nhóm. Thư mục cung cấp một cây phân cấp lồng nhiều cấp, chứa thư mục con và bộ thẻ, đồng
thời tổng hợp số liệu (số thẻ, tiến độ, số đến hạn) của toàn bộ cây con để người học nắm
nhanh khối lượng học.

## 2. Phạm vi

**Trong phạm vi:** tạo, đổi tên, di chuyển, xoá và sắp xếp thư mục; tổng hợp số liệu cây con.
**Ngoài phạm vi (v1):** chia sẻ/đồng sở hữu thư mục.

## 3. Tác nhân & các bên liên quan

| Tác nhân | Vai trò |
| --- | --- |
| Người học | Tổ chức nội dung học của mình. |

## 4. Câu chuyện người dùng (User stories)

- **US-1** — Là người học, tôi muốn nhóm các bộ thẻ theo chủ đề, để tìm và học có tổ chức.
- **US-2** — Là người học, tôi muốn sắp xếp danh sách theo nhiều tiêu chí, để ưu tiên nội
  dung phù hợp.
- **US-3** — Là người học, tôi muốn xoá một thư mục không dùng, để giữ thư viện gọn gàng.

## 5. Luồng nghiệp vụ (Use cases)

### UC-1: Tạo / đổi tên / di chuyển thư mục
- **Luồng chính:** người học tạo thư mục (tên bắt buộc) ở gốc hoặc trong thư mục cha; có
  thể đổi tên hoặc di chuyển sang thư mục khác.
- **Luồng ngoại lệ:** không cho di chuyển một thư mục vào chính cây con của nó (tránh chu trình).

### UC-2: Xoá thư mục
- **Luồng chính:** người học xoá thư mục; hệ thống yêu cầu xác nhận và **xoá lan** toàn
  bộ cây con (thư mục con, bộ thẻ, thẻ và dữ liệu liên quan).

### UC-3: Sắp xếp danh sách
- **Luồng chính:** người học chọn tiêu chí sắp xếp; hệ thống sắp lại danh sách.

## 6. Quy tắc nghiệp vụ (Business rules)

| Mã | Quy tắc | Lý do | Truy vết |
| --- | --- | --- | --- |
| BR-1 | Tên thư mục bắt buộc, không rỗng; có thể trùng tên giữa các thư mục khác cha. | Đảm bảo nhận diện được nhưng không quá cứng nhắc. | — |
| BR-2 | Di chuyển thư mục không được tạo chu trình. | Giữ cây phân cấp hợp lệ. | — |
| BR-3 | Xoá thư mục là xoá lan toàn bộ cây con, sau khi xác nhận. | Tránh để lại dữ liệu mồ côi. | D-022 |
| BR-4 | Sắp xếp theo: bảng chữ cái, ngày tạo, ngày học gần nhất — mỗi tiêu chí có chiều tăng/giảm. | Phù hợp nhiều thói quen học. | D-023 |
| BR-5 | Số liệu của thư mục (số thẻ, tiến độ, số đến hạn, số ẩn) tổng hợp đệ quy từ cây con. | Cho cái nhìn tổng quan tức thì. | — |

## 7. Tiêu chí chấp nhận (Acceptance criteria)

- **AC-1** — *Cho* một thư mục có nội dung con, *khi* xoá và xác nhận, *thì* toàn bộ cây
  con bị xoá. ↔ D-022
- **AC-2** — *Cho* danh sách thư mục, *khi* chọn một tiêu chí sắp xếp, *thì* danh sách
  được sắp đúng theo tiêu chí và chiều đã chọn. ↔ D-023
- **AC-3** — *Cho* thao tác di chuyển tạo chu trình, *khi* thực hiện, *thì* hệ thống từ chối. ↔ BR-2

## 8. Yêu cầu phi chức năng

- Tổng hợp số liệu cây con không gây giật khi mở thư mục lớn.

## 9. Giả định · Ràng buộc · Phụ thuộc (RAID)

- **Phụ thuộc:** bộ thẻ (`deck`), thẻ (`card`); cấu trúc `folder` trong schema.

## 10. Câu hỏi mở

- Không.

## 11. Truy vết & liên quan

- **Quyết định:** `docs/decision-tables/core-decision-table.md` — D-022, D-023.
- **Spec liên quan:** `docs/business/deck/deck-management.md`, `docs/business/flashcard/flashcard-management.md`.
- **Dữ liệu:** `docs/database/schema-contract.md` — bảng `folder`.
