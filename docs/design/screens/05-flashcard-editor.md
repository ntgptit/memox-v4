# 05. Flashcard editor / Tạo–Sửa thẻ

Thiết kế màn **Tạo / Sửa thẻ** của MemoX (app học từ vựng flashcard + SRS, mobile, tiếng
Việt). Dùng MemoX Design System trong project này (`Mx*`, `--memox-*`, Plus Jakarta Sans,
light + dark).

**Ngữ cảnh:** nhập/chỉnh nội dung một thẻ giàu trường (term ở ngôn ngữ đang học + nghĩa
là ô văn bản tự do + audio + giới tính + cờ ẩn).

**Bố cục:** thanh trên (Huỷ · tiêu đề "Thẻ mới"/"Sửa thẻ" · nút Lưu chính). Form: trường
**Term** (bắt buộc) · **Nghĩa (mẹ đẻ)** ô đa dòng (bắt buộc) · nút "+ Nghĩa ngôn ngữ phụ"
(tuỳ chọn) · **Giới tính** (chip tuỳ chọn) · **Audio** (nút phát, "tự sinh từ term") · công
tắc **Ẩn**.

**Thiết kế các state sau — mỗi state một frame:**

1. **Tạo mới (form rỗng)** — trường có placeholder; nút Lưu mờ tới khi đủ trường bắt buộc;
   placeholder: Term "Nhập từ…", Nghĩa "Nhập nghĩa, có thể kèm ví dụ/ghi chú…".
2. **Sửa (đã điền)** — trường đã có dữ liệu; nút Lưu sáng.
3. **Lỗi validation** (bấm Lưu khi thiếu) — viền đỏ + thông báo dưới trường: "Bắt buộc
   nhập term", "Bắt buộc nhập nghĩa"; không rời màn.
4. **Cảnh báo trùng mềm** (term trùng trong cùng bộ thẻ) — banner vàng "Đã có thẻ ‘<term>’
   trong bộ thẻ này" + nút "Vẫn thêm" / "Xem thẻ đã có"; KHÔNG chặn lưu.
5. **Có nghĩa phụ (đa ngôn ngữ)** — hai khối nghĩa (mẹ đẻ + phụ, vd VI + EN), mỗi khối có
   nhãn ngôn ngữ.
6. **Audio đang sinh / phát** — nút audio loading (sinh TTS) rồi phát được.
