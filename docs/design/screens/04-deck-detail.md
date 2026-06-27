# 04. Deck detail / Danh sách thẻ

Thiết kế màn **Danh sách thẻ** của một bộ thẻ trong MemoX (app học từ vựng flashcard +
SRS, mobile, tiếng Việt). Dùng MemoX Design System trong project này (`Mx*`, `--memox-*`,
Plus Jakarta Sans, light + dark).

**Ngữ cảnh:** xem và quản lý các thẻ trong một bộ thẻ (duyệt, tìm, sửa, ẩn, xoá) và bắt
đầu học.

**Bố cục:** AppBar (back · tên bộ thẻ · loa · sửa). Thanh: ô tìm trong bộ thẻ · chiều
"KO > VI" · sort. Thân: danh sách dòng thẻ — **term** (đậm) · **nghĩa** (rút gọn 1 dòng) ·
badge trạng thái (mới / đến hạn / đã thuộc). Đáy: thanh hành động (nút reload đặt lại tiến
độ · xuất · xoá) + nút "Thêm từ".

**Thiết kế các state sau — mỗi state một frame:**

1. **Loading** — skeleton danh sách thẻ.
2. **Rỗng (chưa có thẻ)** — "Chưa có thẻ" + CTA "Thêm từ" và "Nhập từ file".
3. **Có dữ liệu** — danh sách thẻ; badge trạng thái phân biệt màu (mới / đến hạn đỏ / đã
   thuộc xanh); thẻ ẩn hiển thị mờ + icon mắt-gạch.
4. **Tìm trong bộ thẻ — có kết quả** — lọc theo từ khoá (khớp term hoặc nghĩa, gồm cả thẻ
   ẩn) + hàng chip lọc trạng thái (Tất cả / Mới / Đến hạn / Đã thuộc).
5. **Tìm — không có kết quả** — "Không tìm thấy thẻ nào".
6. **Sheet thao tác trên một thẻ** (chạm-giữ hoặc nút ⋮) — Sửa · Ẩn/Hiện · Xoá (đỏ).
7. **Dialog xác nhận xoá** — xoá một thẻ, hoặc xoá bộ thẻ (cảnh báo xoá lan mọi thẻ).
8. **Dialog xác nhận đặt lại tiến độ** — "Đặt lại tiến độ tất cả thẻ về Mới?".
