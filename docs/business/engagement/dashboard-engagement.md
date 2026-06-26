# Tính năng: Dashboard, hoạt động ngày & streak

**Status:** Specified
**Phụ trách:** TBD
**Liên quan:** dòng quyết định D-010, D-021 · WBS TBD

## Mục đích

Theo dõi nỗ lực học theo ngày và duy trì động lực bằng **mục tiêu ngày + chuỗi streak**.

## Khái niệm

- **Hoạt động hôm nay** (`DailyActivity`): số giây học + số từ học trong ngày — chỉ
  DueReview/NewLearn cộng (Review/Game/Player không). (D-010)
- **DailyGoal**: mục tiêu mỗi ngày — số phút và/hoặc số từ (`daily_goal_minutes`,
  `daily_goal_words`).
- **Streak**: số ngày **liên tiếp** đạt DailyGoal.

## Hành vi người dùng thấy

1. Hiển thị hoạt động hôm nay (thời gian + số từ).
2. **Đạt** = đạt **ít nhất một** trong hai mục tiêu (phút HOẶC từ). Ngày đạt → `streak +1`;
   ngày không đạt → streak reset 0. Mốc reset ngày: **nửa đêm giờ máy**. (D-021)
3. (Dashboard) tổng quan tiến độ — chi tiết màn TBD (cần ảnh).

## Ngoài phạm vi (v1)

- Cơ chế freeze / streak-saver — chưa làm.

## File mã nguồn

TBD (chưa hiện thực).

## Liên quan

- `docs/business/study/study-flow.md` — nguồn của `DailyActivity`
- `docs/database/schema-contract.md` — `daily_activity` + settings mục tiêu
- `docs/decision-tables/core-decision-table.md`
