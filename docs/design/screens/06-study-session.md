# 06. Study session / Phiên học (NewLearn & DueReview)

Thiết kế **khung phiên học** của MemoX (app học từ vựng flashcard + SRS, mobile, tiếng
Việt). Dùng MemoX Design System trong project này (`Mx*`, `--memox-*`, Plus Jakarta Sans,
light + dark).

**Ngữ cảnh:** khung điều phối một phiên học có lập lịch (SRS). "Học thẻ mới" dẫn qua **chuỗi
5 chặng khó dần**; "Ôn đến hạn" ("Lặp lại") tái dùng chính các màn của hình thức học. Khung
này sở hữu thanh tiến độ, chuyển chặng, và vòng học-lại-khi-sai.

**Bố cục:** thanh trên (back · nhãn chặng · nút cỡ chữ T · loa · ⋮) + **thanh tiến độ tích
luỹ 0→100%**; thân nhúng màn chặng hiện tại.

**Thiết kế các state/frame sau cho chuỗi học thẻ mới (5 chặng khó dần):**

1. **Chặng 1 — Xem lại** (tiến độ ~0–16%): hai vùng term (có loa) + nghĩa đầy đủ; nút "Tiếp".
2. **Chặng 2 — Ghép đôi** (~20–36%): hai cột thẻ (nghĩa | term ~5 cặp); cặp đúng biến mất.
3. **Chặng 3 — Đoán** (~40%): một term + 4 lựa chọn nghĩa; chọn đúng/sai có phản hồi màu.
4. **Chặng 4 — Nhớ lại** (~60–64%): hiện term, nút "Hiển thị" lộ nghĩa, rồi 2 nút "Đã quên"
   / "Nhớ được".
5. **Chặng 5 — Điền** (~80–88%): hiện nghĩa, ô gõ term, nút "Trợ giúp"/"Kiểm tra".

**Thêm các state:**

6. **Trả lời sai → học lại** (mọi chặng): chỉ báo nhẹ "Học lại từ này"; thẻ quay lại hàng
   đợi; thanh tiến độ KHÔNG tăng cho thẻ đó. Phiên chỉ xong khi mọi thẻ đúng.
7. **Ôn đến hạn ("Lặp lại")**: giống các chặng nhưng trên thẻ đến hạn; kết thúc một hình
   thức thì hiện nút "Học lại" đúng hình thức đó.
8. **Dialog thoát giữa chừng**: "Thoát? Thẻ chưa hoàn thành 5 chặng sẽ vẫn là Mới."

Mỗi frame một bố cục riêng; thanh tiến độ luôn ở trên.

> Gồm cả **trạng thái tương tác** của mọi control (menu ⋮, chỉnh cỡ chữ, loa, dialog thoát) — đừng để control nào ở dạng tĩnh chưa nối hành vi.
