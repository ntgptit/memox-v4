# IMPORT/EXPORT — Nhập & Xuất dữ liệu — Đặc tả nghiệp vụ

## 0. Thông tin tài liệu

| Trường | Giá trị |
| --- | --- |
| Mã tính năng | `import-export/import-export` |
| Gói công việc (WBS) | W8 |
| Trạng thái | Specified |
| Người phụ trách | TBD |
| Dòng quyết định liên quan | D-020, D-025, D-026 |
| Phiên bản | 1.0 |

## 1. Mục đích & bối cảnh nghiệp vụ

Người học thường đã có sẵn danh sách từ trong file hoặc muốn mang dữ liệu sang nơi khác.
Tính năng Nhập/Xuất cho phép đưa thẻ vào và ra ngoài MemoX qua file (CSV, Excel) hoặc qua
văn bản dán từ clipboard, giảm công nhập tay và tránh khoá người học vào một ứng dụng.

## 2. Phạm vi

**Trong phạm vi:** nhập từ CSV/Excel/clipboard với dấu phân tách cấu hình được; xem trước
trước khi ghi; xuất ra CSV/Excel/clipboard, tuỳ chọn kèm trạng thái ôn.
**Ngoài phạm vi (v1):** đồng bộ hai chiều với dịch vụ ngoài.

## 3. Tác nhân & các bên liên quan

| Tác nhân | Vai trò |
| --- | --- |
| Người học | Chọn nguồn/định dạng, ánh xạ cột, xác nhận nhập/xuất. |

## 4. Câu chuyện người dùng (User stories)

- **US-1** — Là người học, tôi muốn nhập danh sách từ từ file CSV/Excel, để khỏi gõ lại.
- **US-2** — Là người học, tôi muốn dán văn bản và chọn dấu phân tách, để nhập nhanh từ
  nguồn bất kỳ.
- **US-3** — Là người học, tôi muốn xuất bộ thẻ ra file để sao lưu hoặc chia sẻ.

## 5. Luồng nghiệp vụ (Use cases)

### UC-1: Nhập thẻ
- **Tiền điều kiện:** có bộ thẻ đích.
- **Luồng chính:** người học chọn nguồn (file CSV/Excel hoặc dán văn bản) và dấu phân
  tách (Tab / phẩy / chấm phẩy / …); hệ thống tách cột, hiển thị **bước xem trước**;
  người học xác nhận; hệ thống ghi thẻ vào bộ thẻ ở trạng thái Mới.
- **Luồng ngoại lệ:** thẻ trùng được **cảnh báo mềm** nhưng vẫn cho thêm.

### UC-2: Xuất thẻ
- **Luồng chính:** người học chọn phạm vi (một bộ thẻ, gồm cả cây con) và định dạng
  (CSV / Excel / sao chép văn bản); chọn **có kèm trạng thái ôn hay không**; hệ thống tạo
  kết quả.

## 6. Quy tắc nghiệp vụ (Business rules)

| Mã | Quy tắc | Lý do | Truy vết |
| --- | --- | --- | --- |
| BR-1 | Nhập hỗ trợ CSV, Excel và văn bản dán; dấu phân tách cấu hình được (Tab/phẩy/chấm phẩy/…). | Phù hợp mọi nguồn dữ liệu phổ biến. | D-025 |
| BR-2 | Có bước xem trước trước khi ghi; áp chính sách trùng = cảnh báo mềm. | Tránh ghi nhầm; tôn trọng quyền quyết định của người học. | D-020, D-025 |
| BR-3 | Xuất hỗ trợ CSV, Excel, sao chép văn bản; cho chọn **kèm hoặc không kèm** trạng thái ôn. | Cân bằng giữa chia sẻ gọn và sao lưu đầy đủ. | D-026 |
| BR-4 | Dùng mã hoá UTF-8; ô chứa dấu phân tách/xuống dòng được bọc trích dẫn theo chuẩn CSV. | Bảo toàn dữ liệu tiếng Hàn/Việt và nội dung phức tạp. | — |

## 7. Tiêu chí chấp nhận (Acceptance criteria)

- **AC-1** — *Cho* một file CSV với dấu phân tách đã chọn, *khi* nhập, *thì* các cột được
  tách đúng và hiển thị ở bước xem trước. ↔ D-025
- **AC-2** — *Cho* dữ liệu nhập có thẻ trùng, *khi* xác nhận, *thì* hệ thống cảnh báo
  nhưng vẫn thêm. ↔ D-020
- **AC-3** — *Cho* lệnh xuất có chọn "kèm trạng thái ôn", *khi* xuất, *thì* kết quả chứa
  ô/hạn ôn của thẻ. ↔ D-026

## 8. Yêu cầu phi chức năng

- Nhập/xuất vài nghìn thẻ không treo giao diện (xử lý nền nếu cần).

## 9. Giả định · Ràng buộc · Phụ thuộc (RAID)

- **Phụ thuộc:** cấu trúc thẻ và nghĩa; tính năng Bộ thẻ.

## 10. Câu hỏi mở

- Không.

## 11. Truy vết & liên quan

- **Quyết định:** `docs/decision-tables/core-decision-table.md` — D-020, D-025, D-026.
- **Spec liên quan:** `docs/business/flashcard/flashcard-management.md`, `docs/business/deck/deck-management.md`.
