# Kịch bản — Dashboard (Today) · screen `dashboard`

Nguồn: `docs/contracts/dashboard.md` [loaded · goal-met · streak-reset · empty · loading] ·
DOM `specs/dashboard.md` · D-010, D-021 (D-001/D-016 gián tiếp khi chạm continue-deck) ·
BR `business/engagement/dashboard-engagement.md` · DB `daily_activity`, `daily_goal`, `decks`, `srs_state`.

> Số/tên trong kit là MOCK ("Linh", "TOPIK I", "12", "14/20") — assert **định dạng & nguồn**,
> KHÔNG assert giá trị mock. Chuỗi lấy từ ARB, không copy kit.

## DoE — dashboard (12 chiều)

| # | Chiều | TT | Scenario / N/A |
|---|---|---|---|
| 1 | States (5) | ✅ | SC-DASH-01..05 |
| 2 | Elements (13 tương tác/hiển thị) | ✅ | SC-DASH-10..24 |
| 3 | Nav vào/ra | ✅ | SC-DASH-30..36 |
| 4 | Nhập liệu & validation | **N/A** | dashboard không có field nhập trực tiếp |
| 5 | Lượng dữ liệu | ✅ | SC-DASH-40..43 |
| 6 | Async & lỗi | ✅ | SC-DASH-50..52 |
| 7 | Persistence (DB round-trip) | ✅ | SC-DASH-60..62 |
| 8 | Định dạng & i18n | ✅ | SC-DASH-70..74 |
| 9 | Dark mode | ✅ | SC-DASH-80 |
| 10 | Responsive | ✅ | SC-DASH-81 |
| 11 | A11y | ✅ | SC-DASH-82 |
| 12 | Concurrency & edge thời gian | ✅ | SC-DASH-90..92 |

Element inventory (từ DOM spec — mỗi cái ≥1 scenario ở mục 2):
`notifications` (icon-button) · `avatar` · eyebrow ngày · title greeting · `goal` (ring % + "N/M min" +
phụ đề) · `streak` (lửa + số + "day streak") · `mastered` (verified + % + "mastered") · `decks-head`
("Continue studying" + "See all") · `deck-0/1/2` (thẻ tiếp tục) · `quick-review` (FAB Review) ·
bottom-nav ×5 (Today·Library·Add·Stats·Profile).

---

## 1. States

### SC-DASH-01 — loaded (có hoạt động hôm nay)
Nguồn: contract[loaded] · spec base
Given: DB `daily_activity`(hôm nay: minutes>0), `daily_goal`(15/20), decks có thẻ due, streak=12
When: mở tab Today
Then: UI hiện app bar (ngày + greeting + notifications + avatar) · today card (goal ring, streak, mastered) ·
"Continue studying" + ≥1 deck · Review FAB · bottom-nav[Today active]. Không skeleton, không banner.

### SC-DASH-02 — goal-met (đạt mục tiêu hôm nay)
Nguồn: contract[goal-met] · spec "goal met" diff · D-021/BR-2
Given: hoạt động hôm nay đạt ≥1 mục tiêu (phút HOẶC từ)
When: mở Today
Then: UI hiện banner "Daily goal reached! Streak +1." (ARB) · goal ring = met (100%/full) ·
streak hiển thị giá trị đã +1. DB: streak(hôm nay) = streak(hôm qua)+1.

### SC-DASH-03 — streak-reset (bỏ ngày → mất streak)
Nguồn: contract[streak-reset] · spec "streak reset" diff · D-021/BR-3
Given: hôm qua không đạt mục tiêu; streak trước >0
When: mở Today
Then: UI banner "Streak reset — study today to start again." · streak = 0.

### SC-DASH-04 — empty (chưa học hôm nay / người dùng mới)
Nguồn: contract[empty] · spec "empty" diff
Given: DB `daily_activity`(hôm nay trống); (biến thể: chưa có deck nào)
When: mở Today
Then: UI banner "You haven't studied today — start to keep your streak!" · **KHÔNG** hiện
goal/streak/mastered/decks-head (bị loại theo diff spec) · vẫn có Review FAB + bottom-nav.
⚠ Xác nhận: empty = "chưa học hôm nay" hay "người dùng chưa có deck"? (spec gộp; cần tách rõ).

### SC-DASH-05 — loading
Nguồn: contract[loading] · spec "loading" diff
Given: provider dashboard chưa resolve
When: mở Today
Then: UI hiện skeleton (app bar + card khung xám), không có số thật, không banner; không crash.

---

## 2. Elements (mỗi phần tử ≥1 scenario)

### SC-DASH-10 — Nút notifications
Nguồn: spec `dashboard/notifications` (icon-button, mx:?)
When: chạm chuông
Then: ⚠ Xác nhận đích (mở màn thông báo? panel?) — hiện chưa có trong D-xxx/business. Assert tối thiểu:
nút có semantic label, hit-area ≥48, không crash.

### SC-DASH-11 — Avatar
Nguồn: spec `avatar` (chữ tắt "LT")
When: chạm avatar
Then: ⚠ Xác nhận đích (→ Profile?). Assert: hiển thị chữ tắt tên (nguồn tên = ?), tap có phản hồi.

### SC-DASH-12 — Eyebrow ngày
Nguồn: spec eyebrow "Saturday · 27 Jun"
Then: hiển thị **thứ + ngày** theo locale hiện tại (không hardcode "27 Jun"); đổi locale → đổi format (xem SC-DASH-70).

### SC-DASH-13 — Title greeting
Nguồn: spec title "Good evening, Linh"
Then: hiển thị **lời chào theo buổi + tên**. ⚠ Xác nhận: ngưỡng sáng/chiều/tối? nguồn tên (profile/settings)?
Assert cấu trúc: "<chào theo giờ>, <tên>"; tên rỗng ⇒ fallback (cần xác nhận copy).

### SC-DASH-14 — Goal ring + "N/M min"
Nguồn: spec `dashboard/goal` (ring 70%, "14/20 min", "Daily goal", "Met when minutes OR words reached") · D-021
Given: `daily_activity`(minutes=14), `daily_goal`(minutes=20)
Then: UI ring = 14/20 (=70%); nhãn "14/20 min"; phụ đề "Met when minutes OR words reached".
Biến thể: minutes≥goal HOẶC words≥goal ⇒ ring full/met (BR-2). ⚠ Xác nhận: ring hiển thị theo phút,
theo từ, hay theo max(tiến độ hai chỉ số)?

### SC-DASH-15 — Streak (lửa + số + "day streak")
Nguồn: spec `dashboard/streak` (icon local_fire_department, "12", "day streak") · D-021
Given: streak=12
Then: hiển thị số 12 + nhãn plural "day streak" (1 ⇒ "1 day streak"? — xem SC-DASH-71).
Biến thể streak=0 ⇒ hiển thị 0 (hoặc trạng thái reset).

### SC-DASH-16 — Mastered (verified + %)
Nguồn: spec `dashboard/mastered` ("55%", "mastered")
Then: hiển thị % đã thuộc. ⚠ Xác nhận công thức: (thẻ box 8 / tổng thẻ visible toàn app)? phạm vi (toàn app
hay theo cặp ngôn ngữ đang chọn)?

### SC-DASH-17 — "Continue studying" head + "See all"
Nguồn: spec `dashboard/decks-head` ("Continue studying" + "See all")
When: chạm "See all"
Then: điều hướng sang **Library** (navigation-flow: "Tiếp tục học" → tab Library). Tiêu đề section hiển thị.

### SC-DASH-18..20 — Thẻ continue deck 0/1/2
Nguồn: spec `dashboard/deck-0..2` ("TOPIK I — Vocabulary" · "320 cards · 48 due" · progress)
Given: có ≥1 deck (đã học gần đây / có due)
Then: mỗi thẻ hiển thị tên + meta ("N cards · N due") + progress; chạm → `deck-detail[loaded]` của deck đó (push).
⚠ Xác nhận: tiêu chí & thứ tự "continue" (học gần nhất? có due? tối đa 3?).

### SC-DASH-21 — Review FAB
Nguồn: spec `dashboard/quick-review` (FAB "Review", mx:?) · D-001
When: chạm Review
Then: mở ôn nhanh **thẻ due toàn app** (D-001). ⚠ Xác nhận build hiện tại: navigation-flow ghi S0 =
placeholder `comingSoon` → nếu chưa build, scenario này là **spec đích** (test sẽ đỏ tới khi build).

### SC-DASH-22..24 — Bottom nav (Today/Library/Add/Stats/Profile)
Nguồn: spec bottom-nav ×5 · MANIFEST nav_tab
When: chạm từng mục
Then: Today(active, no-op/scroll-top) · Library→tab Library · **Add**→action (mở luồng thêm, không phải tab,
không active) · Stats→tab Stats · Profile→tab Profile. Pill active + màu primary-strong đúng tab.

---

## 3. Điều hướng vào/ra

### SC-DASH-30 — Vào Today là màn khởi động
Given: mở app lạnh
Then: app vào tab Today (initialLocation). ⚠ Xác nhận: initial = today hay library? (router: `Routes.today`).

### SC-DASH-31..34 — Ra: continue-deck→deck-detail · See all→Library · Review→review · nav tabs
(gộp từ SC-DASH-17..24; mỗi đích là 1 push/switch-branch riêng, back quay lại Today giữ vị trí cuộn).

### SC-DASH-35 — Back tại Today (tab gốc)
When: nhấn back hệ thống tại Today
Then: ⚠ Xác nhận: thoát app hay no-op? (Android back tại tab gốc).

### SC-DASH-36 — Giữ vị trí cuộn khi quay lại
Given: cuộn Today xuống, push deck-detail, back
Then: Today giữ nguyên vị trí cuộn + state (StatefulShellRoute giữ nhánh).

---

## 5. Lượng dữ liệu

### SC-DASH-40 — 0 deck để "continue"
Then: section "Continue studying" ẩn hoặc hiện empty; không thẻ deck. (khớp state empty)
### SC-DASH-41 — 1 deck · SC-DASH-42 — 3 deck (đủ) · SC-DASH-43 — >3 deck
Then: hiển thị tối đa N thẻ (⚠ xác nhận N=3?); "See all" mở toàn bộ ở Library.

## 6. Async & lỗi

### SC-DASH-50 — loading → loaded
### SC-DASH-51 — provider lỗi (đọc daily_activity/decks thất bại)
Then: ⚠ dashboard KHÔNG có state `error` trong kit → xác nhận: hiện gì khi lỗi? (inline error? empty? — cần spec).
### SC-DASH-52 — local-first (không mạng)
Then: dashboard vẫn render đầy đủ từ DB local (không phụ thuộc mạng).

## 7. Persistence (DB round-trip)

### SC-DASH-60 — Hoạt động ghi từ phiên học phản ánh lên Today
Given: hoàn tất phiên "Học"/"Lặp lại" (SC-STUDY-11) → `daily_activity` cộng phút/từ (D-010/BR-1)
Then: quay lại Today, goal ring + số phút/từ cập nhật đúng giá trị DB.
### SC-DASH-61 — Streak đọc từ lịch sử `daily_activity`
Then: streak = số ngày liên tiếp đạt mục tiêu tính từ `daily_activity` (engagement: "tính trực tiếp từ lịch sử").
### SC-DASH-62 — Kill & mở lại app
Then: Today hiển thị lại đúng activity/streak/mục tiêu từ DB (không mất).

## 8. Định dạng & i18n

### SC-DASH-70 — Ngày theo locale
Given: đổi locale máy (vd vi/en/ja)
Then: eyebrow đổi format thứ+ngày tương ứng; không vỡ layout (text dài → không tràn).
### SC-DASH-71 — Plural "day streak"
Then: streak=1 ⇒ "1 day streak"; streak=N ⇒ "N day streak" (dùng ARB plural, không nối chuỗi).
### SC-DASH-72 — Tên/greeting CJK
Given: tên người dùng chứa Hàn/Nhật (vd "린" / "太郎")
Then: greeting render đúng glyph CJK (không tofu); không cắt sai.
### SC-DASH-73 — Số lớn / biên
Then: streak/thẻ số lớn (vd 9999) không tràn card; "N/M min" khi minutes>goal (vd 30/20) hiển thị hợp lý.
### SC-DASH-74 — Tên dài
Then: greeting tên rất dài → ellipsis/wrap, không đẩy layout.

## 9. Dark mode
### SC-DASH-80 — Mọi state ở dark
Then: 5 state render đúng ở dark (token, không hardcode); today card primary + on-primary contrast đạt.

## 10. Responsive
### SC-DASH-81 — 320px → tablet + xoay
Then: không overflow ở 320px; card co giãn; xoay ngang cuộn được; safe-area/notch OK.

## 11. A11y
### SC-DASH-82 — Semantics
Then: notifications/avatar/Review/nav có label; hit-area ≥48; thứ tự đọc: greeting → today card → decks → nav;
số streak/goal đọc thành câu có nghĩa (không đọc rời "12", "day streak").

## 12. Concurrency & edge thời gian

### SC-DASH-90 — Nửa đêm đổi ngày khi đang mở Today
Given: đang ở Today lúc 23:59, đạt mục tiêu; đồng hồ qua 00:00
Then: ⚠ Xác nhận: Today tự chốt ngày (streak+1, activity hôm nay reset về 0) hay chờ mở lại? (engagement: "chưa
có job chốt-ngày — tính trực tiếp từ lịch sử").
### SC-DASH-91 — Double-tap continue-deck
Then: chạm nhanh 2 lần 1 thẻ → chỉ push deck-detail **một** lần (không mở 2 màn).
### SC-DASH-92 — Đổi mục tiêu ở Settings rồi quay lại
Given: đổi `daily_goal` ở Settings (W12) → quay lại Today
Then: goal ring + trạng thái met cập nhật theo mục tiêu mới (đọc từ settings).

---

## Open questions (⚠ cần chốt spec trước khi viết test — KHÔNG bịa)

1. **Greeting**: ngưỡng buổi (sáng/chiều/tối) theo giờ nào? nguồn **tên** người dùng (profile/settings)? fallback khi rỗng?
2. **Continue-decks**: tiêu chí chọn (học gần nhất / có due / ...)? thứ tự? tối đa mấy thẻ (N=3?)?
3. **Mastered %**: công thức + phạm vi (toàn app / theo cặp ngôn ngữ đang chọn)?
4. **Goal ring**: hiển thị theo phút, theo từ, hay max(tiến độ)?
5. **Review FAB**: v1 là `comingSoon` (navigation-flow S0) hay ôn due thật (D-001)? — quyết định assert nào.
6. **Notifications / avatar**: đích khi tap?
7. **State empty**: gộp "chưa học hôm nay" và "chưa có deck" — cần tách?
8. **State error**: dashboard không có `error` trong kit — hiện gì khi đọc DB lỗi?
9. **Initial route** + **Android back** tại tab gốc.
10. **Nửa đêm**: chốt ngày realtime hay lazy khi mở lại?

> Các mục ⚠ ở trên là **danh sách phải hỏi BA/spec**, không được đoán. Khi có câu trả lời → cập nhật
> scenario tương ứng + xoá cờ ⚠. Đây chính là "không bỏ sót": phần chưa rõ được **liệt kê ra**, không lờ đi.
