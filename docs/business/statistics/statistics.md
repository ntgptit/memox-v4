# Tính năng: Thống kê học tập (Statistics)

**Status:** Specified
**Phụ trách:** TBD
**Liên quan:** dòng quyết định D-010, D-021 · WBS TBD

## Mục đích

Cho người học thấy tiến độ & thói quen học bằng các chỉ số trực quan, hiện đại.
*(Spec định nghĩa CHỈ SỐ; bố cục/đồ thị do thiết kế UI quyết định.)*

## Chỉ số đề xuất (tôi quyết)

- **Lịch học (heatmap)** kiểu đóng góp: mức độ học theo từng ngày.
- **Streak** hiện tại & dài nhất (xem `docs/business/engagement/dashboard-engagement.md`).
- **Thời gian học** theo ngày / tuần / tháng (từ `daily_activity.seconds`).
- **Số từ đã học** theo thời gian.
- **Phân bố theo ô Leitner** (bao nhiêu thẻ ở ô 1..8) → đo độ thành thạo.
- **Dự báo đến hạn** (forecast): số thẻ sẽ đến hạn ôn trong N ngày tới.
- **Độ chính xác** (accuracy): tỉ lệ Đúng khi ôn/học.
- **Tổng quan thư viện:** số cặp ngôn ngữ, thư mục, bộ thẻ, thẻ; % đã thuộc.

## Luật & ca biên

- Có bộ chọn phạm vi: **cặp đang chọn (mặc định)** hoặc toàn app.
- Heatmap/forecast tính theo giờ máy.

## File mã nguồn

TBD (chưa hiện thực).

## Liên quan

- `docs/business/engagement/dashboard-engagement.md` — hoạt động ngày & streak
- `docs/database/schema-contract.md` — `daily_activity`, `srs_state`
- `docs/decision-tables/core-decision-table.md`
