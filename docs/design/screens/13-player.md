# 13. Player / Trình phát

Thiết kế màn **Trình phát** (auto-play) của MemoX (app học từ vựng flashcard + SRS, mobile,
tiếng Việt). Dùng MemoX Design System trong project này (`Mx*`, `--memox-*`, Plus Jakarta
Sans, light + dark).

**Ngữ cảnh:** phát tự động lần lượt các thẻ kèm âm thanh, rảnh tay; KHÔNG đổi lịch ôn.

**Bố cục:** thanh trên (back · tên nút · cỡ chữ T · loa · ⋮). Chỉ báo tiến độ **dạng chấm**
(vị trí trong danh sách). Thẻ hiện tại: term + nghĩa. Điều khiển: play/pause · thẻ
trước/sau · tốc độ.

**Thiết kế các state sau — mỗi state một frame:**

> Gồm cả **trạng thái tương tác** của mọi control trên màn (ô nhập/tìm khi đang gõ, dropdown · bộ chọn · menu ⋮ khi mở, mục đang chọn, bottom sheet · drawer khi mở) — mỗi cái một frame; đừng để control nào ở dạng tĩnh chưa nối hành vi.

1. **Đang phát** — thẻ hiện tại + chấm tiến độ + nút tạm dừng; tự chuyển thẻ kế theo nhịp.
2. **Tạm dừng** — nút phát; thẻ đứng yên.
3. **Đổi tốc độ** — điều khiển tốc độ (vd ×0.75 / ×1 / ×1.5).
4. **Hết danh sách** — "Đã phát hết" + CTA "Phát lại" / "Đóng".
