# 18. Reminder / Nhắc học

Thiết kế màn **Nhắc học** của MemoX (app học từ vựng flashcard + SRS, mobile, tiếng Việt).
Dùng MemoX Design System trong project này (`Mx*`, `--memox-*`, Plus Jakarta Sans, light +
dark).

**Ngữ cảnh:** đặt lịch nhắc học hằng ngày gồm một giờ trong ngày và các thứ trong tuần.

**Bố cục:** công tắc bật/tắt nhắc học. Bộ chọn **giờ** (time picker). Hàng **thứ trong
tuần** dạng chip chọn nhiều: T2 · T3 · T4 · T5 · T6 · T7 · CN.

**Thiết kế các state sau — mỗi state một frame:**

> Gồm cả **trạng thái tương tác** của mọi control trên màn (ô nhập/tìm khi đang gõ, dropdown · bộ chọn · menu ⋮ khi mở, mục đang chọn, bottom sheet · drawer khi mở) — mỗi cái một frame; đừng để control nào ở dạng tĩnh chưa nối hành vi.

1. **Bật** — công tắc bật; giờ đã chọn (vd 13:00); các thứ đã chọn được tô (vd cả tuần).
2. **Tắt** — công tắc tắt; phần giờ + thứ mờ/vô hiệu.
3. **Đang chọn giờ** — time picker mở.
