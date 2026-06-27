# 19. Account & Sync / Tài khoản & Đồng bộ

Thiết kế màn **Tài khoản & Đồng bộ** của MemoX (app học từ vựng flashcard + SRS, mobile,
tiếng Việt). Dùng MemoX Design System trong project này (`Mx*`, `--memox-*`, Plus Jakarta
Sans, light + dark).

**Ngữ cảnh:** đăng nhập và đồng bộ dữ liệu đa thiết bị qua tài khoản Google; app vẫn chạy
offline. (Tính năng mức alpha.)

**Bố cục:** khối tài khoản (avatar/email hoặc nút đăng nhập) · khối đồng bộ (trạng thái +
nút "Đồng bộ ngay") · nút đăng xuất.

**Thiết kế các state sau — mỗi state một frame:**

1. **Chưa đăng nhập** — nút "Đăng nhập bằng Google" + mô tả lợi ích đồng bộ.
2. **Đã đăng nhập** — email + "Đồng bộ lần cuối: …" + nút "Đồng bộ ngay" + "Đăng xuất";
   nhãn "alpha".
3. **Đang đồng bộ** — tiến trình/spinner + "Đang đồng bộ…".
4. **Xung đột** — thông báo nhẹ "Đã hợp nhất theo bản mới nhất" (last-write-wins).
5. **Offline** — badge "Ngoại tuyến" + "Sẽ đồng bộ khi có mạng".
