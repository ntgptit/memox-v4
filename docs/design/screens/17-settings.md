# 17. Settings / Cài đặt

Thiết kế màn **Cài đặt** của MemoX (app học từ vựng flashcard + SRS, mobile, tiếng Việt).
Dùng MemoX Design System trong project này (`Mx*`, `--memox-*`, Plus Jakarta Sans, light +
dark).

**Ngữ cảnh:** điều chỉnh trải nghiệm và bảo vệ dữ liệu. (Không có mục Premium ở v1.)

**Bố cục:** danh sách nhóm cài đặt dạng hàng, mỗi hàng có nhãn + giá trị tóm tắt + mũi tên:
- **Tiếng mẹ đẻ** · **Ngôn ngữ giao diện**
- **Hình thức từ ngữ** (hiện trường mẹ đẻ; tô màu theo giới tính; đánh dấu Cyrillic)
- **Lặp lại giãn cách** (Ô: 8; Thông báo)
- **Cài đặt trò chơi** (số từ/ván; ngẫu nhiên; bàn phím)
- **Giọng nói** (TTS/STT)
- **Nhắc học** (giờ + thứ)
- **Sao lưu/Khôi phục** (đường dẫn; tự động; lần cuối)
- **Đồng bộ đám mây** (email; alpha)
- **Chủ đề**

**Thiết kế các state sau — mỗi state một frame:**

> Gồm cả **trạng thái tương tác** của mọi control trên màn (ô nhập/tìm khi đang gõ, dropdown · bộ chọn · menu ⋮ khi mở, mục đang chọn, bottom sheet · drawer khi mở) — mỗi cái một frame; đừng để control nào ở dạng tĩnh chưa nối hành vi.

1. **Có dữ liệu** — mọi nhóm với giá trị tóm tắt hiện tại (vd "Ô: 8", "13:00 [T2–CN]").
2. **Nhóm mở rộng** — một nhóm (vd "Lặp lại giãn cách") hiển thị các tuỳ chọn con.
3. **Đổi giá trị** — picker/stepper cho một mục (vd số ô, số từ/ván).
