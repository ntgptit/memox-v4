# 03. Folder detail / Chi tiết thư mục

Thiết kế màn **Chi tiết thư mục** của MemoX (app học từ vựng flashcard + SRS, mobile,
tiếng Việt). Dùng MemoX Design System trong project này (`Mx*`, `--memox-*`, Plus Jakarta
Sans, light + dark).

**Ngữ cảnh:** duyệt nội dung bên trong một thư mục (thư mục con + bộ thẻ), tổ chức lại, và
bắt đầu học ở mức thư mục.

**Bố cục:** AppBar (back · tên thư mục · nút loa phát audio · nút sửa). Thanh: ô tìm trong
thư mục · chỉ báo chiều "KO > VI" · sort. Thân: danh sách thư mục con + bộ thẻ (mỗi dòng:
tên · số từ · vòng % + Play · badge đỏ đến hạn). Đáy: nút "📁 +" + FAB "+".

**Thiết kế các state sau — mỗi state một frame:**

> Gồm cả **trạng thái tương tác** của mọi control trên màn (ô nhập/tìm khi đang gõ, dropdown · bộ chọn · menu ⋮ khi mở, mục đang chọn, bottom sheet · drawer khi mở) — mỗi cái một frame; đừng để control nào ở dạng tĩnh chưa nối hành vi.

1. **Loading** — skeleton danh sách.
2. **Rỗng (thư mục trống)** — minh hoạ + "Thư mục trống" + CTA "Tạo bộ thẻ" / "Tạo thư mục con".
3. **Có dữ liệu** — danh sách con với số liệu tổng hợp (số từ · % · badge đến hạn).
4. **Menu sửa thư mục** (chạm nút sửa) — sheet: Đổi tên · Di chuyển · Xoá (đỏ).
5. **Dialog xác nhận xoá lan** — "Xoá thư mục sẽ xoá toàn bộ thư mục con, bộ thẻ và thẻ
   bên trong. Không thể hoàn tác." + nút Xoá (đỏ) / Huỷ.
6. **Chọn đích di chuyển** — cây chọn thư mục đích; vô hiệu hoá các nút thuộc cây con của
   chính nó (chống chu trình).
7. **Lỗi** — thông báo lỗi + "Thử lại".
