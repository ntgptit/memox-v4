# 23. Drawer / Ngăn điều hướng & Cặp ngôn ngữ

Thiết kế **ngăn điều hướng (drawer)** và màn **Thêm cặp ngôn ngữ** của MemoX (app học từ
vựng flashcard + SRS, mobile, tiếng Việt). Dùng MemoX Design System trong project này
(`Mx*`, `--memox-*`, Plus Jakarta Sans, light + dark).

**Ngữ cảnh:** drawer là trung tâm điều hướng phụ và quản lý ngôn ngữ.

**Bố cục drawer:** header "Hoạt động hôm nay" (đồng hồ thời gian + số từ). Danh sách mục:
Thêm ngôn ngữ · Xóa ngôn ngữ · Nhập · Xuất · Thống kê · Chủ đề · Cài đặt · Câu hỏi thường
gặp · Gửi email · Đồng bộ (alpha).

**Thiết kế các state sau — mỗi state một frame:**

1. **Drawer mở** — header hoạt động + danh sách mục đầy đủ, icon rõ ràng.
2. **Thêm cặp ngôn ngữ** — chọn **ngôn ngữ đang học** → **tiếng mẹ đẻ**; nút "Thêm".
3. **Xóa ngôn ngữ** — danh sách cặp hiện có + xác nhận xoá (cảnh báo mất dữ liệu cặp đó).
