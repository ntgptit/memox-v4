# 21. Import / Nhập dữ liệu

Thiết kế màn **Nhập thẻ** của MemoX (app học từ vựng flashcard + SRS, mobile, tiếng Việt).
Dùng MemoX Design System trong project này (`Mx*`, `--memox-*`, Plus Jakarta Sans, light +
dark).

**Ngữ cảnh:** nạp thẻ hàng loạt vào một bộ thẻ từ file hoặc văn bản dán.

**Bố cục:** chọn **nguồn** (CSV / Excel / dán văn bản) · chọn **dấu phân tách** (Tab /
phẩy / chấm phẩy / …) · **ánh xạ cột** (cột nào là term, cột nào là nghĩa) · **bước xem
trước** bảng thẻ sẽ nhập · nút "Nhập".

**Thiết kế các state sau — mỗi state một frame:**

> Gồm cả **trạng thái tương tác** của mọi control trên màn (ô nhập/tìm khi đang gõ, dropdown · bộ chọn · menu ⋮ khi mở, mục đang chọn, bottom sheet · drawer khi mở) — mỗi cái một frame; đừng để control nào ở dạng tĩnh chưa nối hành vi.

1. **Chọn nguồn** — ba lựa chọn nguồn; nếu dán văn bản thì có ô dán lớn.
2. **Cấu hình tách cột** — chọn dấu phân tách + ánh xạ cột; bảng mẫu cập nhật theo.
3. **Xem trước** — bảng các thẻ sẽ nhập (term | nghĩa), số lượng; nút "Nhập".
4. **Cảnh báo trùng mềm** — banner "Có N thẻ trùng — vẫn nhập?"; không chặn.
5. **Hoàn tất** — "Đã nhập N thẻ" + CTA về bộ thẻ.
