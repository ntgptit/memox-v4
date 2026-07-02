# 08. Game — Ghép đôi (Matching)

Thiết kế trò chơi **Ghép đôi** của MemoX (app học từ vựng flashcard + SRS, mobile, tiếng
Việt). Dùng MemoX Design System trong project này (`Mx*`, `--memox-*`, Plus Jakarta Sans,
light + dark).

**Ngữ cảnh:** luyện nhận diện bằng cách ghép cặp **term ↔ nghĩa** ở hai cột; cặp đúng biến mất.

**Bố cục:** thanh trên (back · "Ghép đôi" · cỡ chữ T · loa · ⋮) + thanh tiến độ. Thân: hai
cột thẻ — cột trái = nghĩa, cột phải = term (~5 cặp).

**Thiết kế các state sau — mỗi state một frame:**

> Gồm cả **trạng thái tương tác** của mọi control trên màn (ô nhập/tìm khi đang gõ, dropdown · bộ chọn · menu ⋮ khi mở, mục đang chọn, bottom sheet · drawer khi mở) — mỗi cái một frame; đừng để control nào ở dạng tĩnh chưa nối hành vi.

1. **Đang chơi (chưa ghép)** — các thẻ hai cột ở trạng thái trung tính.
2. **Chọn một thẻ** — thẻ được chọn nổi bật (viền màu nhấn), chờ chọn thẻ đối diện.
3. **Ghép đúng** — cặp khớp lóe xanh rồi biến mất; tiến độ tăng.
4. **Ghép sai** — hai thẻ rung + đỏ ngắn rồi trở lại; thẻ vẫn ở lại (học lại trong ván).
5. **Còn 1 cặp / sắp xong** — chỉ còn vài thẻ; bố cục co lại.
6. **Hoàn thành ván** — thông báo hoàn thành.
