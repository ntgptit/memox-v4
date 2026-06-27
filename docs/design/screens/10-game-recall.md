# 10. Game — Nhớ lại (Recall)

Thiết kế trò chơi **Nhớ lại** của MemoX (app học từ vựng flashcard + SRS, mobile, tiếng
Việt). Dùng MemoX Design System trong project này (`Mx*`, `--memox-*`, Plus Jakarta Sans,
light + dark).

**Ngữ cảnh:** luyện gợi nhớ — hiện **term**, người học tự nhớ nghĩa, bấm "Hiển thị" để lộ
nghĩa, rồi tự chấm "Đã quên" / "Nhớ được".

**Bố cục:** thanh trên + thanh tiến độ. Thẻ term (trên, có bút chì + loa). Vùng nghĩa
(dưới, ẩn ban đầu). Nút: ban đầu "Hiển thị" (chính, lớn ở đáy); sau khi lộ nghĩa: "Đã
quên" / "Nhớ được".

**Thiết kế các state sau — mỗi state một frame:**

1. **Trước khi hiển thị** — term + vùng nghĩa mờ/ẩn + nút "Hiển thị" lớn ở đáy.
2. **Sau khi hiển thị (chờ tự chấm)** — nghĩa đầy đủ hiện ra; đáy đổi thành 2 nút "Đã
   quên" (trung tính) / "Nhớ được" (chính).
3. **Chấm "Đã quên" → học lại** — chỉ báo "Sẽ học lại từ này"; thẻ quay lại hàng đợi của ván.
4. **Chấm "Nhớ được" → qua thẻ** — chuyển thẻ kế; tiến độ tăng.
5. **Hoàn thành ván** — thông báo hoàn thành.
