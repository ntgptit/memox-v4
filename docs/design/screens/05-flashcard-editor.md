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

> Gồm cả **trạng thái tương tác** của mọi control trên màn (ô nhập/tìm khi đang gõ, dropdown · bộ chọn · menu ⋮ khi mở, mục đang chọn, bottom sheet · drawer khi mở) — mỗi cái một frame; đừng để control nào ở dạng tĩnh chưa nối hành vi.

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

## Hiện thực (W2)

`lib/presentation/features/flashcard-editor/screens/flashcard_editor_screen.dart`. Mọi copy qua
l10n key (`lib/l10n/*.arb`: `editor*`, `gender*`, `commonCancel`, `comingSoon`); màu/giãn
cách qua token (`MxSpacing`, `MxTheme`, `MxRadius`). Nút **Lưu** tắt tới khi đủ term +
nghĩa mẹ đẻ; trường thiếu hiện lỗi inline (state 3). Trùng term → banner vàng "Vẫn thêm /
Xem thẻ đã có" (state 4, **không chặn** lưu — D-020). Nghĩa mẹ đẻ lấy ngôn ngữ từ cặp đang
chọn (S0); thêm nghĩa phụ kèm bộ chọn ngôn ngữ (endonym, `supported_languages.dart`).
**Audio (state 6) hoãn:** sinh TTS cần dependency ngoài `pubspec.yaml (deps — WBS I.1)` — nút hiện báo
"sắp ra mắt". "Xem thẻ đã có" cũng hoãn tới khi có màn danh sách thẻ (W6).
