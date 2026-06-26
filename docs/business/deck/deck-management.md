# Tính năng: Quản lý Bộ thẻ (Deck)

**Status:** Specified
**Phụ trách:** TBD
**Liên quan:** dòng quyết định D-024 · WBS TBD

## Mục đích

Bộ thẻ là nút trực tiếp chứa các thẻ; nằm ở gốc hoặc trong một thư mục.

## Hành vi người dùng thấy

1. **Tạo** bộ thẻ (tên bắt buộc) ở gốc hoặc trong thư mục.
2. **Đổi tên**.
3. **Di chuyển** (đổi `folder_id`) sang thư mục khác hoặc ra gốc.
4. **Xoá** — hỏi xác nhận; **xoá lan** mọi thẻ + `card_meaning` + `srs_state`. (D-024)
5. **Sắp xếp** giống thư mục (bảng chữ cái / ngày tạo / ngày học, tăng-giảm). (D-023)

## Luật & ca biên

- Tên không rỗng.
- Thêm thẻ thủ công ("Thêm từ") hoặc nạp hàng loạt qua Import.

## Out of scope (v1)

- Trộn/gộp hai bộ thẻ tự động.

## File mã nguồn

TBD (chưa hiện thực).

## Liên quan

- `docs/business/folder/folder-management.md` — thư mục chứa bộ thẻ
- `docs/business/flashcard/flashcard-management.md` — thẻ trong bộ thẻ
- `docs/database/schema-contract.md` — `deck`
- `docs/decision-tables/core-decision-table.md`
