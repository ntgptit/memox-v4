# Tính năng: Nhập / Xuất dữ liệu (Import / Export)

**Status:** Specified
**Phụ trách:** TBD
**Liên quan:** dòng quyết định D-020, D-025, D-026 · WBS TBD

## Mục đích

Đưa thẻ vào / ra ngoài app qua file hoặc clipboard, theo guidance: CSV, Excel, hoặc dán text.

## Nhập (Import)

1. **Nguồn:** file **CSV** / **Excel (.xlsx)**, hoặc **dán text** từ clipboard vào ô nhập.
2. **Dấu phân tách (separator):** chọn được **Tab / phẩy (,) / chấm phẩy (;) / …** (cho text & CSV). (D-025)
3. **Cột tối thiểu:** term + nghĩa (ánh xạ cột do người dùng/định dạng quy định).
4. **Bước xem trước (preview)** trước khi ghi; áp **chính sách trùng = cảnh báo mềm** (D-020).
5. Thẻ nhập vào một bộ thẻ đích, ở trạng thái **mới** (ô 0).

## Xuất (Export)

1. **Định dạng:** **CSV** / **Excel (.xlsx)** / **copy text ra clipboard**. (D-026)
2. Separator cấu hình được (Tab / , / ; / …) cho CSV & text.
3. Phạm vi xuất: một bộ thẻ (hoặc một thư mục — gộp con).
4. **Kèm trạng thái SRS:** cho người dùng **chọn** — kèm ô/hạn ôn hay chỉ term+nghĩa. (D-026)

## Luật & ca biên

- Encoding UTF-8 cho CSV/text (hỗ trợ Hàn/Việt).
- Ô chứa separator/xuống dòng → bọc trích dẫn theo chuẩn CSV.

## File mã nguồn

TBD (chưa hiện thực).

## Liên quan

- `docs/business/flashcard/flashcard-management.md` — thẻ & nghĩa
- `docs/decision-tables/core-decision-table.md`
