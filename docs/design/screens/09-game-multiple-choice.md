# 09. Game — Đoán (Multiple choice)

Thiết kế trò chơi **Đoán** của MemoX (app học từ vựng flashcard + SRS, mobile, tiếng
Việt). Dùng MemoX Design System trong project này (`Mx*`, `--memox-*`, Plus Jakarta Sans,
light + dark).

**Ngữ cảnh:** luyện nhận diện — hiện một **term**, chọn **nghĩa đúng** trong N lựa chọn.

**Bố cục:** thanh trên + thanh tiến độ. Khối prompt: thẻ term lớn (có loa, nút bút chì sửa
inline). Danh sách 4–5 nút nghĩa.

**Thiết kế các state sau — mỗi state một frame:**

> Gồm cả **trạng thái tương tác** của mọi control trên màn (ô nhập/tìm khi đang gõ, dropdown · bộ chọn · menu ⋮ khi mở, mục đang chọn, bottom sheet · drawer khi mở) — mỗi cái một frame; đừng để control nào ở dạng tĩnh chưa nối hành vi.

1. **Chờ chọn** — term + các lựa chọn trung tính.
2. **Chọn đúng** — lựa chọn được chọn xanh + tick; tự chuyển thẻ kế sau khoảnh khắc.
3. **Chọn sai** — lựa chọn sai đỏ + đồng thời làm nổi đáp án đúng (xanh); thẻ học lại trong ván.
4. **Hoàn thành ván** — thông báo hoàn thành.
