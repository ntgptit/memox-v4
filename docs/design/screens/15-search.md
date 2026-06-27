# 15. Search / Tìm kiếm

Thiết kế màn **Tìm kiếm** thẻ của MemoX (app học từ vựng flashcard + SRS, mobile, tiếng
Việt). Dùng MemoX Design System trong project này (`Mx*`, `--memox-*`, Plus Jakarta Sans,
light + dark).

**Ngữ cảnh:** tìm nhanh một thẻ trong thư viện theo **term hoặc nghĩa**; lọc theo trạng
thái; gồm cả thẻ ẩn.

**Bố cục:** ô tìm kiếm trên cùng + nút xoá. Hàng chip lọc trạng thái: Tất cả · Mới · Đến
hạn · Đã thuộc. Danh sách kết quả: dòng thẻ (term + nghĩa + tên bộ thẻ chứa + badge trạng
thái).

**Thiết kế các state sau — mỗi state một frame:**

> Gồm cả **trạng thái tương tác** của mọi control trên màn (ô nhập/tìm khi đang gõ, dropdown · bộ chọn · menu ⋮ khi mở, mục đang chọn, bottom sheet · drawer khi mở) — mỗi cái một frame; đừng để control nào ở dạng tĩnh chưa nối hành vi.

1. **Rỗng (chưa nhập)** — ô tìm trống + gợi ý "Tìm theo từ hoặc nghĩa" + danh sách "tìm
   gần đây" (nếu có).
2. **Có kết quả** — danh sách thẻ khớp (term **hoặc** nghĩa), gồm cả thẻ ẩn (mờ + icon
   mắt-gạch); chip lọc trạng thái áp dụng được.
3. **Lọc theo trạng thái** — chọn một chip → danh sách thu hẹp theo trạng thái.
4. **Không có kết quả** — "Không tìm thấy thẻ nào cho ‘<từ khoá>’".
5. **Đang tìm (loading)** — spinner/skeleton ngắn.
