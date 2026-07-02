# 11. Game — Điền (Typing)

Thiết kế trò chơi **Điền** của MemoX (app học từ vựng flashcard + SRS, mobile, tiếng
Việt). Dùng MemoX Design System trong project này (`Mx*`, `--memox-*`, Plus Jakarta Sans,
light + dark).

**Ngữ cảnh:** luyện tái tạo — hiện **nghĩa**, người học **gõ lại term**; có gợi ý và chấp
nhận dung sai.

**Bố cục:** thanh trên + thanh tiến độ. Thẻ nghĩa (trên). Ô nhập term (dưới) + bàn phím.
Nút: "Trợ giúp" (gợi ý) · "Kiểm tra" (chính); sau kiểm tra: "Đúng" / "Thử lại".

**Thiết kế các state sau — mỗi state một frame:**

> Gồm cả **trạng thái tương tác** của mọi control trên màn (ô nhập/tìm khi đang gõ, dropdown · bộ chọn · menu ⋮ khi mở, mục đang chọn, bottom sheet · drawer khi mở) — mỗi cái một frame; đừng để control nào ở dạng tĩnh chưa nối hành vi.

1. **Chờ gõ** — nghĩa + ô nhập rỗng + nút "Trợ giúp" / "Kiểm tra".
2. **Đang gõ** — ký tự người dùng nhập; nút "Kiểm tra" sáng.
3. **Dùng "Trợ giúp"** — lộ một phần gợi ý (vd ký tự đầu / số ký tự).
4. **Kiểm tra — đúng** — ô nhập viền xanh + tick; qua thẻ kế.
5. **Kiểm tra — sai** — so khớp ký tự đúng/sai (đúng xanh, sai đỏ, thiếu gạch); đáp án
   đúng hiện bên dưới; đáy đổi thành "Đúng" (tự nhận đúng khi chỉ lệch nhẹ) / "Thử lại"
   (học lại trong ván).
6. **Hoàn thành ván** — thông báo hoàn thành.
