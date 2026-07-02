# 02. Dashboard / Hoạt động hôm nay

Thiết kế màn **Dashboard** của MemoX (app học từ vựng flashcard + SRS, mobile, tiếng
Việt). Dùng MemoX Design System trong project này (`Mx*`, `--memox-*`, Plus Jakarta Sans,
light + dark).

**Ngữ cảnh:** cho người học thấy nhanh nỗ lực hôm nay và động lực (mục tiêu + chuỗi
streak), cùng lối tắt vào việc cần làm. Nỗ lực chỉ tính từ "Lặp lại" và "Học".

**Bố cục:** lời chào + ngày. Khối "Hoạt động hôm nay": thời gian học (mm:ss) + số từ học.
Khối "Mục tiêu ngày": vòng/thanh tiến độ tới mục tiêu (phút/từ), nhãn "đạt khi hoàn thành
phút HOẶC số từ". Khối "Streak": số ngày liên tiếp + biểu tượng lửa. Hàng lối tắt: "Tiếp
tục học" · "Thẻ đến hạn (N)". Mini-stat: % đã thuộc của thư viện.

**Shell mapping:** app dùng shell chung ở `docs/business/navigation/navigation-flow.md`:
bottom nav **5 mục** (Today · Library · **Add** ở giữa · Stats · Profile) theo UI kit —
`Add` là action ở giữa, không trở thành route/tab riêng và không bao giờ active. Tab Today
mang thêm **Review FAB** (icon `bolt`, ôn nhanh) đúng `MxFabReview` của kit. Visual Dashboard
lấy token/component/state từ UI kit
`docs/design/MemoX Design System/ui_kits/memox-app/_features/dashboard/Dashboard.jsx`.

**Thiết kế các state sau — mỗi state một frame:**

> Gồm cả **trạng thái tương tác** của mọi control trên màn (ô nhập/tìm khi đang gõ, dropdown · bộ chọn · menu ⋮ khi mở, mục đang chọn, bottom sheet · drawer khi mở) — mỗi cái một frame; đừng để control nào ở dạng tĩnh chưa nối hành vi.

1. **Loading** — skeleton 3 khối card.
2. **Rỗng (hôm nay chưa học)** — Hoạt động = 0 phút / 0 từ; mục tiêu 0%; CTA chính "Bắt
   đầu học"; copy "Hôm nay chưa học — bắt đầu để giữ streak!".
3. **Đang tiến triển** — số liệu thực; vòng mục tiêu chưa đầy; streak hiện tại; lối tắt
   có số thẻ đến hạn.
4. **Đạt mục tiêu ngày** — vòng mục tiêu đầy + dấu tích; streak +1 có hiệu ứng (lửa sáng,
   micro-animation); banner "Đã đạt mục tiêu hôm nay 🎉 — streak N ngày".
5. **Streak vừa reset** — streak hiển thị 0 + nhắc nhẹ "Bắt đầu lại chuỗi".

## Flutter mapping

| Mock element | Flutter component | Source |
| --- | --- | --- |
| Shell / top area | `MxAppBar` large trong `AppShell` khi ở tab Today | `lib/presentation/shared/navigation/app_shell.dart` |
| Bottom navigation | `MxBottomNav` (5 mục, `Add` ở giữa) | `lib/presentation/shared/navigation/app_shell.dart` |
| Review FAB (tab Today) | `MxFab(icon: bolt, label: Review)` | `lib/presentation/shared/navigation/app_shell.dart` |
| Today activity card | `MxCard(variant: primary)` | `lib/presentation/features/engagement/screens/dashboard_screen.dart` |
| Empty note / goal-met note / reset note | token-backed local note surface | `lib/presentation/features/engagement/screens/dashboard_screen.dart` |
| Goal card + ring | `MxCard` + progress ring (% in centre); rows: goal title, minutes/words progress (`· complete` when met), met-rule hint | `lib/presentation/features/engagement/screens/dashboard_screen.dart` |
| Streak / mastered mini-stat | `MxCard(primarySoft/muted)` | `lib/presentation/features/engagement/screens/dashboard_screen.dart` |
| Due deck rows | `MxCard(interactive)` + `MxIconTile` + `MxBadge` | `lib/presentation/features/engagement/screens/dashboard_screen.dart` |

`streak-reset` hiện được suy ra ở UI khi có hoạt động, chưa đạt mục tiêu, và streak hiện tại
bằng 0; domain chưa có cờ riêng cho "vừa reset".

`empty` (chưa học hôm nay) hiển thị **tối giản theo kit** — chỉ note + Today/Start card; goal,
streak/mastered và "Continue studying" chỉ xuất hiện khi đã có hoạt động.

## Copy keys

`dashboardEmptyHint`, `dashboardStartStudying`, `dashboardGoalMetBanner`,
`dashboardGoalHint`, `dashboardGoalProgressMinutes`, `dashboardGoalProgressWords`,
`dashboardStreakResetHint`, `notificationsTooltip`, `dashboardQuickReview`, `tabAdd`.

Tông khích lệ, hiện đại, hợp xu thế.
