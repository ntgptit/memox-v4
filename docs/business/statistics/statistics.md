# STATISTICS — Thống kê học tập — Đặc tả nghiệp vụ

## 0. Thông tin tài liệu

| Trường | Giá trị |
| --- | --- |
| Mã tính năng | `statistics/statistics` |
| Gói công việc (WBS) | W9 |
| Trạng thái | Implemented (tổng quan thư viện + phân bố ô Leitner + dự báo đến hạn 7 ngày + hoạt động 14 ngày, bộ chọn phạm vi cặp↔toàn app; biểu đồ dựng từ primitive/token, không thêm thư viện chart. Hoãn: heatmap đầy đủ, độ chính xác (chưa lưu kết quả đúng/sai), streak dài nhất) |
| Người phụ trách | TBD |
| Dòng quyết định liên quan | D-010, D-021 |
| Phiên bản | 1.0 |

## 1. Mục đích & bối cảnh nghiệp vụ

Để duy trì động lực và điều chỉnh kế hoạch học, người học cần thấy tiến độ và thói quen
học của mình một cách trực quan. Thống kê tổng hợp dữ liệu học thành các chỉ số dễ đọc,
hiện đại. Tài liệu này định nghĩa **các chỉ số nghiệp vụ**; bố cục và kiểu đồ thị do thiết
kế giao diện quyết định.

## 2. Phạm vi

**Trong phạm vi:** danh mục chỉ số và ý nghĩa; phạm vi tính (cặp đang chọn hoặc toàn app).
**Ngoài phạm vi:** bố cục màn hình và lựa chọn biểu đồ cụ thể.

## 3. Tác nhân & các bên liên quan

| Tác nhân | Vai trò |
| --- | --- |
| Người học | Xem thống kê để theo dõi tiến độ. |

## 4. Câu chuyện người dùng (User stories)

- **US-1** — Là người học, tôi muốn thấy mình đã học bao nhiêu và đều đặn ra sao, để giữ
  động lực.
- **US-2** — Là người học, tôi muốn biết số thẻ sắp đến hạn, để chuẩn bị thời gian ôn.

## 5. Danh mục chỉ số

| Chỉ số | Ý nghĩa nghiệp vụ |
| --- | --- |
| Lịch học (heatmap) | Mức độ học theo từng ngày, cho thấy sự đều đặn. |
| Chuỗi streak | Streak hiện tại và dài nhất (xem `docs/business/engagement/dashboard-engagement.md`). |
| Thời gian học | Theo ngày/tuần/tháng, từ hoạt động đã ghi. |
| Số từ đã học | Tích luỹ theo thời gian. |
| Phân bố theo ô Leitner | Số thẻ ở mỗi ô 1..8, phản ánh độ thành thạo. |
| Dự báo đến hạn | Số thẻ sẽ đến hạn ôn trong N ngày tới. |
| Độ chính xác | Tỉ lệ trả lời đúng khi học/ôn. |
| Tổng quan thư viện | Số cặp ngôn ngữ, bộ thẻ, thẻ; tỉ lệ đã thuộc. |

## 6. Quy tắc nghiệp vụ (Business rules)

| Mã | Quy tắc | Lý do | Truy vết |
| --- | --- | --- | --- |
| BR-1 | Thống kê có bộ chọn phạm vi: **cặp đang chọn (mặc định)** hoặc toàn app. | Người học thường quan tâm một ngôn ngữ tại một thời điểm. | — |
| BR-2 | Thời gian/số từ lấy từ hoạt động do "Lặp lại" và "Học" ghi nhận. | Chỉ tính nỗ lực học thực sự, không tính luyện tập. | D-010 |
| BR-3 | Heatmap và dự báo tính theo giờ máy. | Phản ánh đúng "ngày" của người học. | — |

## 7. Tiêu chí chấp nhận (Acceptance criteria)

- **AC-1** — *Cho* một ngày có hoạt động học, *khi* xem heatmap, *thì* ngày đó hiển thị
  mức độ tương ứng. ↔ D-010
- **AC-2** — *Cho* phạm vi "cặp đang chọn", *khi* xem, *thì* chỉ số chỉ tính trong cặp đó. ↔ BR-1

## 8. Yêu cầu phi chức năng

- Tính toán thống kê không làm chậm các luồng học chính.

## 9. Giả định · Ràng buộc · Phụ thuộc (RAID)

- **Phụ thuộc:** hoạt động ngày (`daily_activity`), trạng thái SRS (`srs_state`).

## 10. Câu hỏi mở

- Không.

## 11. Truy vết & liên quan

- **Quyết định:** `docs/decision-tables/core-decision-table.md` — D-010, D-021.
- **Spec liên quan:** `docs/business/engagement/dashboard-engagement.md`, `docs/business/srs/srs-review.md`.
