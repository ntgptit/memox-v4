# 16. Statistics / Thống kê

Thiết kế màn **Thống kê** hiện đại của MemoX (app học từ vựng flashcard + SRS, mobile,
tiếng Việt). Dùng MemoX Design System trong project này (`Mx*`, `--memox-*`, Plus Jakarta
Sans, light + dark).

**Ngữ cảnh:** cho người học thấy tiến độ & thói quen học bằng chỉ số trực quan.

**Bố cục:** bộ chọn phạm vi (cặp đang chọn / toàn app). Các khối: **heatmap lịch học** ·
**streak** (hiện tại + dài nhất) · **thời gian học theo tuần** (cột) · **phân bố theo ô
Leitner 1..8** (cột) · **dự báo đến hạn N ngày** (đường) · **độ chính xác** (donut) ·
**tổng quan thư viện**.

**Thiết kế các state sau — mỗi state một frame:**

> Gồm cả **trạng thái tương tác** của mọi control trên màn (ô nhập/tìm khi đang gõ, dropdown · bộ chọn · menu ⋮ khi mở, mục đang chọn, bottom sheet · drawer khi mở) — mỗi cái một frame; đừng để control nào ở dạng tĩnh chưa nối hành vi.

1. **Loading** — skeleton các khối biểu đồ.
2. **Có dữ liệu** — mọi khối có dữ liệu thực; biểu đồ rõ ràng, có nhãn/giá trị.
3. **Chưa đủ dữ liệu** — khối hiển thị placeholder + gợi ý "Học thêm để xem thống kê".
4. **Đổi phạm vi** — chuyển giữa cặp đang chọn ↔ toàn app, số liệu cập nhật.

Tông biểu đồ hiện đại, hợp xu thế.
