# SEARCH — Tìm kiếm thẻ — Đặc tả nghiệp vụ

## 0. Thông tin tài liệu

| Trường | Giá trị |
| --- | --- |
| Mã tính năng | `search/global-search` |
| Gói công việc (WBS) | W7 |
| Trạng thái | Specified |
| Người phụ trách | TBD |
| Dòng quyết định liên quan | D-019, D-028 |
| Phiên bản | 1.0 |

## 1. Mục đích & bối cảnh nghiệp vụ

Trong một thư viện lớn, người học cần tìm nhanh một thẻ mà không phải duyệt từng bộ thẻ.
Tìm kiếm khớp trên cả mặt ngôn ngữ đang học (term) lẫn nghĩa, cho phép tìm bằng bất kỳ
mặt nào người học nhớ.

## 2. Phạm vi

**Trong phạm vi:** tìm theo từ khoá trên term và nghĩa; tìm toàn cục và tìm trong một
nút; bộ lọc theo trạng thái thẻ.
**Ngoài phạm vi (v1):** tìm theo tag/ghi chú (v1 chưa có tag).

## 3. Tác nhân & các bên liên quan

| Tác nhân | Vai trò |
| --- | --- |
| Người học | Nhập từ khoá, lọc và mở thẻ trong kết quả. |

## 4. Câu chuyện người dùng (User stories)

- **US-1** — Là người học, tôi muốn tìm một thẻ bằng term hoặc nghĩa, để truy cập nhanh.
- **US-2** — Là người học, tôi muốn lọc kết quả theo trạng thái (mới/đến hạn/đã thuộc),
  để khoanh vùng việc cần làm.

## 5. Luồng nghiệp vụ (Use cases)

### UC-1: Tìm kiếm
- **Tiền điều kiện:** đang ở một cặp ngôn ngữ.
- **Luồng chính:** người học nhập từ khoá vào ô tìm kiếm (toàn cục ở thanh trên, hoặc
  trong một nút); hệ thống trả về danh sách thẻ khớp trên term hoặc nghĩa, gồm cả thẻ ẩn;
  người học có thể lọc theo trạng thái.
- **Hậu điều kiện:** người học mở một thẻ từ kết quả.

## 6. Quy tắc nghiệp vụ (Business rules)

| Mã | Quy tắc | Lý do | Truy vết |
| --- | --- | --- | --- |
| BR-1 | Từ khoá khớp trên cả `term` và nội dung nghĩa. | Tìm được bằng mặt người học nhớ. | D-019 |
| BR-2 | Kết quả bao gồm cả thẻ ẩn; có bộ lọc theo trạng thái (mới / đến hạn / đã thuộc). | Người học vẫn cần tìm thấy thẻ đã ẩn. | D-028 |
| BR-3 | Chỉ tìm trong cặp ngôn ngữ đang chọn; phạm vi là toàn thư viện hoặc trong nút đang mở. | Kết quả đúng ngữ cảnh. | — |

## 7. Tiêu chí chấp nhận (Acceptance criteria)

- **AC-1** — *Cho* một từ khoá khớp nghĩa của một thẻ, *khi* tìm, *thì* thẻ đó xuất hiện
  trong kết quả. ↔ D-019
- **AC-2** — *Cho* một thẻ đang ẩn khớp từ khoá, *khi* tìm, *thì* thẻ vẫn xuất hiện. ↔ D-028
- **AC-3** — *Cho* bộ lọc trạng thái "đến hạn", *khi* áp dụng, *thì* chỉ còn thẻ đến hạn
  trong kết quả. ↔ D-028

## 8. Yêu cầu phi chức năng

- Trả kết quả trong khoảng dưới 200 ms trên thư viện lớn.

## 9. Giả định · Ràng buộc · Phụ thuộc (RAID)

- **Phụ thuộc:** nội dung thẻ (term, nghĩa); trạng thái SRS để lọc.

## 10. Câu hỏi mở

- Không.

## 11. Truy vết & liên quan

- **Quyết định:** `docs/decision-tables/core-decision-table.md` — D-019, D-028.
- **Spec liên quan:** `docs/business/flashcard/flashcard-management.md`.
