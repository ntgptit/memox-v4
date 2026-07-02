# ENGAGEMENT — Hoạt động ngày, mục tiêu & streak — Đặc tả nghiệp vụ

## 0. Thông tin tài liệu

| Trường | Giá trị |
| --- | --- |
| Mã tính năng | `engagement/dashboard-engagement` |
| Gói công việc (WBS) | W11 |
| Trạng thái | Implemented (dashboard Today: hoạt động + mục tiêu + streak hiện tại **+ streak dài nhất**; mục tiêu đọc từ settings do W12 ghi; chưa có job chốt-ngày — streak tính trực tiếp từ lịch sử `daily_activity`) |
| Người phụ trách | TBD |
| Dòng quyết định liên quan | D-010, D-021 |
| Phiên bản | 1.0 |

## 1. Mục đích & bối cảnh nghiệp vụ

Học ngôn ngữ thành công phụ thuộc vào sự đều đặn hơn là cường độ. Để nuôi thói quen, MemoX
theo dõi nỗ lực học theo ngày và khuyến khích người học bằng mục tiêu hằng ngày cùng chuỗi
ngày liên tiếp đạt mục tiêu (streak).

## 2. Phạm vi

**Trong phạm vi:** đo hoạt động trong ngày; mục tiêu ngày; tính và reset streak.
**Ngoài phạm vi (v1):** cơ chế "đóng băng" (freeze) hay cứu streak.

## 3. Tác nhân & các bên liên quan

| Tác nhân | Vai trò |
| --- | --- |
| Người học | Đặt mục tiêu; học để duy trì streak. |

## 4. Câu chuyện người dùng (User stories)

- **US-1** — Là người học, tôi muốn thấy hôm nay đã học bao lâu / bao nhiêu từ, để biết
  mình đã đạt mục tiêu chưa.
- **US-2** — Là người học, tôi muốn duy trì chuỗi ngày học liên tiếp, để có động lực đều đặn.

## 5. Khái niệm

- **Hoạt động hôm nay:** số phút học + số từ học trong ngày, chỉ tính từ "Lặp lại" và "Học".
- **Mục tiêu ngày (DailyGoal):** số phút và/hoặc số từ.
- **Streak:** số ngày liên tiếp đạt mục tiêu.

## 6. Luồng nghiệp vụ (Use cases)

### UC-1: Ghi nhận và chốt ngày
- **Luồng chính:** trong ngày, hệ thống cộng dồn phút và số từ từ các phiên "Lặp lại"/"Học";
  vào nửa đêm (giờ máy), hệ thống chốt ngày: nếu **đạt ≥ một** trong hai mục tiêu thì tăng
  streak; nếu không đạt thì reset streak về 0.

## 7. Quy tắc nghiệp vụ (Business rules)

| Mã | Quy tắc | Lý do | Truy vết |
| --- | --- | --- | --- |
| BR-1 | Hoạt động ngày chỉ cộng từ "Lặp lại" và "Học" (không từ luyện tập). | Đo nỗ lực học thực sự. | D-010 |
| BR-2 | "Đạt mục tiêu" = đạt **ít nhất một** trong hai (phút **hoặc** từ). | Linh hoạt với nhiều kiểu học. | D-021 |
| BR-3 | Đạt mục tiêu → streak +1; không đạt → streak reset 0. Mốc reset: nửa đêm giờ máy. | Khuyến khích đều đặn. | D-021 |

## 8. Tiêu chí chấp nhận (Acceptance criteria)

- **AC-1** — *Cho* một ngày đạt ít nhất một mục tiêu, *khi* chốt ngày, *thì* streak tăng 1. ↔ D-021
- **AC-2** — *Cho* một ngày không đạt mục tiêu nào, *khi* chốt ngày, *thì* streak về 0. ↔ D-021
- **AC-3** — *Cho* một phiên luyện tập (trò chơi/xem lại/trình phát), *khi* kết thúc, *thì*
  hoạt động ngày không tăng. ↔ D-010

## 9. Giả định · Ràng buộc · Phụ thuộc (RAID)

- **Ràng buộc:** không có cơ chế cứu streak ở v1.
- **Phụ thuộc:** hoạt động do luồng học ghi nhận; cài đặt mục tiêu.

## 10. Câu hỏi mở

- Không.

## 11. Truy vết & liên quan

- **Quyết định:** `docs/decision-tables/core-decision-table.md` — D-010, D-021.
- **Spec liên quan:** `docs/business/study/study-flow.md`, `docs/business/statistics/statistics.md`.
- **Dữ liệu:** `docs/database/schema-contract.md` — bảng `daily_activity`.
