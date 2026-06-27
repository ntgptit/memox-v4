# 14. Study result / Kết quả phiên học

Thiết kế màn **Kết quả phiên học** của MemoX (app học từ vựng flashcard + SRS, mobile,
tiếng Việt). Dùng MemoX Design System trong project này (`Mx*`, `--memox-*`, Plus Jakarta
Sans, light + dark).

**Ngữ cảnh:** tổng kết một phiên Học/Ôn và phản hồi tiến độ (số thẻ, độ chính xác, thời
gian, cập nhật streak).

**Bố cục:** khối tổng kết (số thẻ đã học/ôn · tỉ lệ đúng/sai · thời gian). Khối streak/mục
tiêu (cập nhật streak + tiến độ mục tiêu ngày). CTA: "Tiếp tục" / "Về thư viện".

**Thiết kế các state sau — mỗi state một frame:**

1. **Kết quả chuẩn** — số liệu phiên; streak/mục tiêu cập nhật.
2. **Đạt mục tiêu ngày** — hiệu ứng chúc mừng + streak +1 nổi bật; copy "Đạt mục tiêu hôm
   nay 🎉".
3. **Chưa đạt mục tiêu** — còn thiếu bao nhiêu để đạt + CTA "Học tiếp".
4. **Phiên có nhiều thẻ sai** — gợi ý "Ôn lại N thẻ chưa chắc" + CTA.
