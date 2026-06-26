# Tính năng: Cá nhân hoá giao diện (Personalization / Theme)

**Status:** Specified
**Phụ trách:** TBD
**Liên quan:** WBS TBD

## Mục đích

Cho người dùng tuỳ biến giao diện. *(Tôi quyết bộ tối thiểu hợp lý.)*

## Hành vi người dùng thấy

1. **Chế độ màu:** Sáng / Tối / Theo hệ thống.
2. **Màu nhấn (accent):** chọn từ một bảng màu định sẵn.
3. **Cỡ chữ:** nhỏ / vừa / lớn (ảnh hưởng thẻ học & danh sách).

## Luật & ca biên

- Lưu vào `settings`; áp ngay không cần khởi động lại.
- Tôn trọng cài đặt hệ thống khi chọn "Theo hệ thống".

## Out of scope (v1)

- Theme tải về / tuỳ biến từng màn; phông chữ tuỳ ý.

## File mã nguồn

TBD (chưa hiện thực).

## Liên quan

- `docs/ui-ux/ui-ux-contract.md` — token thiết kế
- `docs/database/schema-contract.md` — `settings`
