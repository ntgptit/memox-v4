# 20. Theme / Chủ đề (Cá nhân hoá)

Thiết kế màn **Chủ đề** của MemoX (app học từ vựng flashcard + SRS, mobile, tiếng Việt).
Dùng MemoX Design System trong project này (`Mx*`, `--memox-*`, Plus Jakarta Sans, light +
dark).

**Ngữ cảnh:** cá nhân hoá giao diện cho thoải mái khi học.

**Bố cục:** chọn **chế độ màu** (Sáng / Tối / Theo hệ thống) · chọn **màu nhấn** (dải
swatch) · chọn **cỡ chữ** (Nhỏ / Vừa / Lớn). Kèm **xem trước trực tiếp** một thẻ mẫu phản
ánh lựa chọn.

**Thiết kế các state sau — mỗi state một frame:**

> Gồm cả **trạng thái tương tác** của mọi control trên màn (ô nhập/tìm khi đang gõ, dropdown · bộ chọn · menu ⋮ khi mở, mục đang chọn, bottom sheet · drawer khi mở) — mỗi cái một frame; đừng để control nào ở dạng tĩnh chưa nối hành vi.

1. **Chế độ Sáng** — thẻ mẫu sáng; lựa chọn hiện tại được tô.
2. **Chế độ Tối** — thẻ mẫu tối.
3. **Đổi màu nhấn / cỡ chữ** — xem trước cập nhật ngay theo lựa chọn.
