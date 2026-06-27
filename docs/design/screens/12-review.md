# 12. Review / Xem lại các từ

Thiết kế màn **Xem lại** của MemoX (app học từ vựng flashcard + SRS, mobile, tiếng Việt).
Dùng MemoX Design System trong project này (`Mx*`, `--memox-*`, Plus Jakarta Sans, light +
dark).

**Ngữ cảnh:** duyệt thẻ để làm quen/ôn nhanh — hiện term + nghĩa đầy đủ, sửa inline; KHÔNG
đổi lịch ôn.

**Bố cục:** thanh trên (back · "Xem lại" · nút cỡ chữ T · loa · ⋮) + thanh tiến độ (vị trí
trong danh sách). Hai vùng: **nghĩa** (trên, có nút bút chì sửa inline) · **term** (dưới,
có loa). Vuốt ngang hoặc nút để qua thẻ kế/trước.

**Thiết kế các state sau — mỗi state một frame:**

> Gồm cả **trạng thái tương tác** của mọi control trên màn (ô nhập/tìm khi đang gõ, dropdown · bộ chọn · menu ⋮ khi mở, mục đang chọn, bottom sheet · drawer khi mở) — mỗi cái một frame; đừng để control nào ở dạng tĩnh chưa nối hành vi.

1. **Đang duyệt** — nghĩa đầy đủ + term; tiến độ phản ánh vị trí.
2. **Đang sửa inline** (chạm bút chì) — vùng nghĩa/term thành ô nhập + nút Lưu/Huỷ; không
   rời màn.
3. **Phát audio** — nút loa ở trạng thái đang phát.
4. **Thẻ cuối (kết thúc)** — "Đã xem hết" + CTA "Về bộ thẻ" / "Học ngay".
