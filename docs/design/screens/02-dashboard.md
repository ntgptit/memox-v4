# 02. Dashboard / Hoạt động hôm nay

Thiết kế màn **Dashboard** của MemoX (app học từ vựng flashcard + SRS, mobile, tiếng
Việt). Dùng MemoX Design System trong project này (`Mx*`, `--memox-*`, Plus Jakarta Sans,
light + dark).

**Ngữ cảnh:** cho người học thấy nhanh nỗ lực hôm nay và động lực (mục tiêu + chuỗi
streak), cùng lối tắt vào việc cần làm. Nỗ lực chỉ tính từ "Lặp lại" và "Học".

**Bố cục:** lời chào + ngày. Khối "Hoạt động hôm nay": thời gian học (mm:ss) + số từ học.
Khối "Mục tiêu ngày": vòng/thanh tiến độ tới mục tiêu (phút/từ), nhãn "đạt khi hoàn thành
phút HOẶC số từ". Khối "Streak": số ngày liên tiếp + biểu tượng lửa. Hàng lối tắt: "Tiếp
tục học" · "Thẻ đến hạn (N)". Mini-stat: % đã thuộc của thư viện.

**Thiết kế các state sau — mỗi state một frame:**

1. **Loading** — skeleton 3 khối card.
2. **Rỗng (hôm nay chưa học)** — Hoạt động = 0 phút / 0 từ; mục tiêu 0%; CTA chính "Bắt
   đầu học"; copy "Hôm nay chưa học — bắt đầu để giữ streak!".
3. **Đang tiến triển** — số liệu thực; vòng mục tiêu chưa đầy; streak hiện tại; lối tắt
   có số thẻ đến hạn.
4. **Đạt mục tiêu ngày** — vòng mục tiêu đầy + dấu tích; streak +1 có hiệu ứng (lửa sáng,
   micro-animation); banner "Đã đạt mục tiêu hôm nay 🎉 — streak N ngày".
5. **Streak vừa reset** — streak hiển thị 0 + nhắc nhẹ "Bắt đầu lại chuỗi".

Tông khích lệ, hiện đại, hợp xu thế.
