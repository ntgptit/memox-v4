# 01. Library / Thư viện

Thiết kế màn **Thư viện** — màn chính của MemoX (app học từ vựng bằng flashcard + lặp
lại giãn cách, mobile, giao diện tiếng Việt). Dùng đúng MemoX Design System trong project
này: component `Mx*`, token `--memox-*`, font Plus Jakarta Sans, hỗ trợ light + dark.

**Ngữ cảnh:** người học chọn cặp ngôn ngữ (vd 한국어 → Tiếng Việt), duyệt cây thư mục/bộ
thẻ, nắm nhanh khối lượng học và mở một hình thức học từ một nút.

**Bố cục:** AppBar (nút mở drawer · tên app · nút ⋮). Thanh ngữ cảnh: nút tìm kiếm · bộ
chọn cặp ngôn ngữ (한국어 ⌄ ⇄ Tiếng… ⌄ + nút đảo chiều) · nút sắp xếp. Thân: danh sách
cây, mỗi dòng = tên · "N từ" · icon mắt-gạch + số thẻ ẩn (nếu có) · vòng tròn % bao quanh
nút Play · badge đỏ số thẻ đến hạn. Đáy: nút "Thêm từ" (trái) + FAB "+" (tạo thư mục/bộ thẻ).

**Thiết kế các state sau — mỗi state là một frame riêng:**

1. **Loading** — 4–6 dòng skeleton shimmer thay danh sách; header + thanh ngữ cảnh vẫn hiện.
2. **Rỗng** — minh hoạ + tiêu đề "Chưa có gì để học" + phụ đề ngắn; hai nút "Tạo bộ thẻ"
   (chính) và "Thêm từ".
3. **Có dữ liệu** — danh sách đầy đủ, đa dạng: dòng có badge đỏ ("45", "99+"), dòng 0%
   không badge, dòng có "👁 41" (thẻ ẩn, hiển thị mờ hơn). Số "N từ" KHÔNG tính thẻ ẩn.
4. **Ô tìm kiếm active** — chạm nút tìm → ô tìm bung rộng + bàn phím + con trỏ; bên dưới
   gợi ý "Tìm theo từ hoặc nghĩa" và danh sách tìm gần đây.
5. **Bộ chọn cặp ngôn ngữ mở** — dropdown danh sách các cặp ngôn ngữ (mục đang chọn được
   tô) + mục "Thêm ngôn ngữ"; minh hoạ cả thao tác **đảo chiều** (한국어→Việt ⇄ Việt→한국어).
6. **Menu Sắp xếp mở** — danh sách: Bảng chữ cái ↑/↓ · Ngày tạo ↑/↓ · Ngày học ↑/↓; mục
   đang chọn được tô nền.
7. **Menu ⋮ (overflow) mở** — sheet/menu các hành động cấp màn: Nhập · Xuất · Chọn nhiều · …
8. **Bottom sheet menu Play** (chạm nút Play của một nút) — các mục kèm số: **Học** ·
   "N từ mới"; **Lặp lại** · "N từ" (CHỈ hiện khi có thẻ đến hạn); **Xem lại các từ**;
   **Một trò chơi** · "đến hạn N / mới M"; **Trình phát**.
9. **Drawer mở** — chạm nút menu → ngăn điều hướng trượt ra (header "Hoạt động hôm nay" +
   danh sách mục).
10. **Lỗi** — thông báo lỗi tải + nút "Thử lại".

**Đầy đủ state tương tác:** thiết kế trạng thái active/mở cho MỌI control trên màn (ô tìm,
bộ chọn cặp, sắp xếp, ⋮, Play, drawer) thành frame riêng như trên — KHÔNG để control nào ở
dạng tĩnh chưa nối hành vi.
