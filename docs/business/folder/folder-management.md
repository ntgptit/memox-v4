# Tính năng: Quản lý Thư mục (Folder)

**Status:** Specified
**Phụ trách:** TBD
**Liên quan:** dòng quyết định D-022, D-023 · WBS TBD

## Mục đích

Tổ chức nội dung theo cây thư mục lồng nhiều cấp; mỗi thư mục chứa thư mục con và/hoặc bộ thẻ.

## Hành vi người dùng thấy

1. **Tạo** thư mục (tên bắt buộc, không rỗng) trong một thư mục cha hoặc ở gốc.
2. **Đổi tên**.
3. **Di chuyển** (đổi `parent_id`) sang thư mục khác hoặc ra gốc.
4. **Xoá** — hỏi xác nhận; **xoá lan** toàn bộ con (thư mục con + bộ thẻ + thẻ + `srs_state`). (D-022)
5. **Sắp xếp** danh sách theo: bảng chữ cái, ngày tạo, ngày học gần nhất — mỗi tiêu chí có tăng/giảm. (D-023)

## Luật & ca biên

- Tên không rỗng; có thể trùng tên giữa các thư mục khác cha.
- **Di chuyển không tạo chu trình** (không đưa thư mục vào chính cây con của nó).
- Số liệu của thư mục (số từ, %, đến hạn, ẩn) tổng hợp đệ quy từ cây con.

## Out of scope (v1)

- Chia sẻ/đồng sở hữu thư mục.

## File mã nguồn

TBD (chưa hiện thực).

## Liên quan

- `docs/business/deck/deck-management.md` — bộ thẻ trong thư mục
- `docs/database/schema-contract.md` — `folder`
- `docs/decision-tables/core-decision-table.md`
