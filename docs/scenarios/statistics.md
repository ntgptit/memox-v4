# Kịch bản — Thống kê (Stats) · screen `statistics`

Nguồn: `docs/contracts/statistics.md` [loaded · scope-switch · insufficient · loading] ·
DOM `specs/statistics.md` · D-010, D-021 (D-003/D-005/D-006 gián tiếp qua Leitner & mastered · D-011 một chiều SRS) ·
BR `business/statistics/statistics.md` [BR-1 scope · BR-2 nguồn phút/từ · BR-3 giờ máy] ·
**Schema `docs/database/schema-contract.md`** (khoá `daily_activity.day` = midnight-UTC-của-ngày-local · `study_sessions.started_at`→bucket · `srs_state.due_at` `isDue`/box8-NULL · `daily_activity.minutes` phút) ·
DB `daily_activity`, `srs_state`, `review_logs`, `study_sessions`, `cards`, `card_meanings`, `decks`, `language_pairs`, `settings`.

> Số/tên trong kit là MOCK ("12", "28", "88%", "1240", "680", "96", "min/day", "last 14 weeks", "30 days") —
> assert **định dạng & nguồn**, KHÔNG assert giá trị mock. Chuỗi lấy từ ARB, không copy kit.
> Biểu đồ dựng từ primitive/token (không thư viện chart) — assert **số cột/ô + nguồn dữ liệu + token**, không assert chiều cao px mock.

## DoE — statistics (12 chiều)

| # | Chiều | TT | Scenario / N/A |
|---|---|---|---|
| 1 | States (4) | ✅ | SC-STATISTICS-01..04 |
| 2 | Elements (tương tác/hiển thị) | ✅ | SC-STATISTICS-10..24 |
| 3 | Nav vào/ra | ✅ | SC-STATISTICS-30..35 |
| 4 | Nhập liệu & validation | **N/A*** | không có field nhập tự do; chỉ segmented 2 lựa chọn (phủ ở mục 2/6). **\*Điều kiện**: N/A chỉ đúng **nếu scope KHÔNG persist**; nếu scope là input bền (round-trip qua kill-relaunch) thì lượt chọn segmented = input trạng thái cần assert persist → xem SC-STATISTICS-62 + Open-Q #2. Không N/A tuyệt đối. |
| 5 | Lượng dữ liệu | ✅ | SC-STATISTICS-40..46 |
| 6 | Async & lỗi | ✅ | SC-STATISTICS-50..53 |
| 7 | Persistence (DB round-trip) | ✅ | SC-STATISTICS-60..63 |
| 8 | Định dạng & i18n | ✅ | SC-STATISTICS-70..75 |
| 9 | Dark mode | ✅ | SC-STATISTICS-80 |
| 10 | Responsive | ✅ | SC-STATISTICS-81 |
| 11 | A11y | ✅ | SC-STATISTICS-82 |
| 12 | Concurrency & edge thời gian | ✅ | SC-STATISTICS-90..94 |

Element inventory (từ DOM spec — mỗi cái ≥1 scenario ở mục 2):
`segmented__seg "This pair"` (tab/toggle, mx:?) · `segmented__seg "All"` (tab/toggle, mx:?) ·
`statistics/streak-current` (card "12" + "current streak") · `statistics/streak-longest` (card "28" + "longest") ·
`statistics/heatmap` (Study calendar, "last 14 weeks", 14 cột × 7 ô) · `statistics/weekly` (Time per week, "min/day", 7 cột M-T-W-T-F-S-S) ·
`statistics/leitner` (Leitner box distribution, "cards in boxes 1–8", 8 cột nhãn 1..8) · `statistics/accuracy` (Accuracy, "30 days", donut "88%"/"accuracy") ·
`statistics/overview` (Library overview — `ov-0` "total" · `ov-1` "mastered" · `ov-2` "due") ·
`bottom-nav` ×5 (Today · Library · Add · Stats[active] · Profile) · appbar `Stats` (tĩnh) ·
`statistics/insufficient` (icon-tile bar_chart + "Not enough data" + phụ đề — state insufficient).

> Ghi chú nguồn: kit `loaded` render 6 khối dữ liệu (streak · calendar · weekly · leitner · accuracy · overview).
> Business doc còn nhắc "dự báo đến hạn N ngày" nhưng **DOM spec `loaded` KHÔNG có khối forecast** → xem Open-Q #1 (không bịa khối này).
> ⚠ **Xung đột nguồn heatmap 12-vs-14**: business doc §0 ghi "heatmap 12 tuần" nhưng kit chốt **14** (caption + grid) → Open-Q #20 (kit-first quyết, không lặng lẽ chọn 14).
> ⚠ **Xung đột đơn vị D-010 (giây) vs schema (phút)**: D-010 ghi `DailyActivity` cộng **giây**; schema `daily_activity.minutes` + `study_sessions.duration_minutes` dùng **phút** → Open-Q #21 (không im).

---

## 1. States

### SC-STATISTICS-01 — loaded (đủ dữ liệu)
Nguồn: contract[loaded] · spec base · BR-1/BR-2
Tiền điều kiện (Given):
  - DB: `language_pairs`(1 active) · `decks`+`cards`(nhiều, không hidden) · `srs_state`(trải các box 1..8) ·
    `daily_activity`(≥ ngưỡng "đủ dữ liệu", nhiều ngày có minutes/words) · `review_logs`(có `pass`/`fail` trong 30 ngày)
When: mở tab **Stats**
Then:
  - UI: appbar "Stats" (ARB) · segmented [This pair | All] với "This pair" active (bg:surface + shadow, primary-strong) ·
    2 card streak (current + longest) · "Study calendar" (heatmap 14 cột) · "Time per week" (7 cột) ·
    "Leitner box distribution" (8 cột nhãn 1..8) · "Accuracy" (donut) · "Library overview" (total/mastered/due) ·
    bottom-nav[Stats active]. KHÔNG skeleton, KHÔNG khối "Not enough data".
  - DB: không ghi (màn chỉ đọc — assert không phát sinh dòng mới ở bất kỳ bảng nào sau khi mở).

### SC-STATISTICS-02 — scope-switch (đổi phạm vi cặp ↔ toàn app)
Nguồn: contract[scope-switch] · spec "scope switch" diff · BR-1
Given: như SC-STATISTICS-01; đang ở [This pair] active
When: chạm segmented "All"
Then:
  - UI: theo diff kit → "All" thành active (bg:surface + shadow:2/3, primary-strong), "This pair" về text-secondary (mất bg/shadow) ·
    các khối dữ liệu render lại theo phạm vi toàn app (không còn giới hạn theo cặp active).
  - DB: không ghi. ⚠ Open-Q #2: lựa chọn scope có **persist** vào `settings` không? (schema `settings` không liệt kê key scope thống kê) → đừng bịa key.

### SC-STATISTICS-03 — insufficient (chưa đủ dữ liệu)
Nguồn: contract[insufficient] · spec "insufficient" full
Given: DB gần trống — chưa đủ phiên học để dựng biểu đồ (⚠ Open-Q #3: **ngưỡng "đủ"** là gì? số phiên/ngày/thẻ tối thiểu — chưa có trong business/D-xxx)
When: mở tab Stats
Then:
  - UI: vẫn có appbar "Stats" + segmented [This pair | All] + bottom-nav · thân hiện khối `statistics/insufficient`:
    icon-tile `bar_chart` (bg:primary-soft, on-primary-soft) + tiêu đề "Not enough data" (ARB) + phụ đề hướng dẫn học thêm (ARB, text-center) ·
    **KHÔNG** render streak/heatmap/weekly/leitner/accuracy/overview.
  - DB: không ghi.

### SC-STATISTICS-04 — loading (đang tải)
Nguồn: contract[loading] · spec "loading" full
Given: provider thống kê chưa resolve
When: mở tab Stats
Then:
  - UI: appbar "Stats" + bottom-nav[Stats active] cố định · thân hiện `mxg-skel` (1 skel segmented dạng pill r:999 + 3 card skel: mỗi card 1 skel dòng tiêu đề + 1 skel khối biểu đồ) ·
    KHÔNG số thật, KHÔNG khối "Not enough data", không crash.
  - DB: không ghi.

---

## 2. Elements (mỗi phần tử ≥1 scenario)

### SC-STATISTICS-10 — Segmented "This pair" (mặc định active)
Nguồn: spec `statistics/scope` → `segmented__seg "This pair"` (mx:?) · BR-1
Given: loaded, "All" đang active (đến từ SC-STATISTICS-02)
When: chạm "This pair"
Then: UI "This pair" thành active (bg:surface + shadow:2/3, primary-strong), "All" về text-secondary · các khối lọc lại **chỉ trong cặp `is_active=1`** (BR-1: cặp đang chọn là mặc định). DB: không ghi.

### SC-STATISTICS-11 — Segmented "All" (toàn app)
Nguồn: spec `segmented__seg "All"` (mx:?) · BR-1
When: chạm "All"
Then: xem SC-STATISTICS-02 (chỉ số gộp toàn app, không giới hạn cặp).

### SC-STATISTICS-12 — Card "current streak"
Nguồn: spec `statistics/streak-current` ("12" + "current streak", on-primary-soft) · D-021
Given: `daily_activity` có chuỗi ngày liên tiếp đạt mục tiêu (đọc `settings` goal.minutes_target / goal.words_target)
Then: UI hiển thị **số streak hiện tại** (nguồn = `streakFromHistory` trên `daily_activity`, D-021) + nhãn "current streak" (ARB). Biến thể streak=0 ⇒ hiển thị 0. ⚠ Open-Q #4: streak hiện tại trên Stats tính theo scope (cặp) hay toàn app? (streak vốn là chỉ số toàn app trên `daily_activity`, không có cột pair).

### SC-STATISTICS-13 — Card "longest"
Nguồn: spec `statistics/streak-longest` ("28" + "longest", color:text) · engagement "streak dài nhất"
Then: UI hiển thị **streak dài nhất** (max chuỗi liên tiếp đạt mục tiêu trong lịch sử `daily_activity`) + nhãn "longest" (ARB). Biến thể: current > longest không xảy ra (longest ≥ current theo định nghĩa) — assert longest ≥ current.

### SC-STATISTICS-14 — Heatmap "Study calendar / last 14 weeks"
Nguồn: spec `statistics/heatmap` (section-head "Study calendar" + caption "last 14 weeks"; grid 14 cột × 7 ô, bg:primary với op biến thiên, r:6) · AC-1/D-010 · BR-3
Given: `daily_activity` có các ngày minutes/words khác nhau
Then:
  - UI: lưới **14 cột × 7 ô** (98 ô ngày) **theo kit** (DOM spec caption "last 14 weeks" + đếm được đúng 14 cột × 7 ô), mỗi ô tô đậm/nhạt theo mức hoạt động của ngày (op = hàm cường độ) · nhãn "last 14 weeks" (ARB) · container cuộn ngang (`layout_hint:scroll`).
  - ⚠ Open-Q #20 (**XUNG ĐỘT NGUỒN 12-vs-14 — kit-first quyết**): business doc `docs/business/statistics/statistics.md` §0 ghi "**heatmap hoạt động 12 tuần**", nhưng DOM spec (caption "last 14 weeks" + grid **14** cột × 7 ô) mâu thuẫn với "12 tuần". Scenario này chốt **14 theo kit** (kit là source-of-truth cho visual) NHƯNG đây là xung đột nguồn phải BA/kit-first xác nhận: sửa business doc về 14, hay kit về 12? → chưa chốt thì test cửa sổ heatmap có thể phải đổi 14↔12.
  - Nguồn: mỗi ô ↔ 1 ngày `daily_activity` (D-010 ghi minutes/words); ngày không hoạt động = ô mức thấp nhất (op:0.08). Ranh giới ngày theo **giờ máy** (BR-3); khoá bucket ngày = `daily_activity.day` (INTEGER µs = **midnight-UTC của ngày local**, schema `daily_activity`) — xem SC-STATISTICS-94.
  - ⚠ Open-Q #5: bậc cường độ (số mức op) map theo minutes hay words hay max? — kit cho op {0.08,0.25,0.45,0.7,1.0} nhưng business chưa định nghĩa ngưỡng → assert "có phân bậc theo cường độ", không assert ngưỡng cụ thể.

### SC-STATISTICS-15 — "Time per week" (bar 7 ngày)
Nguồn: spec `statistics/weekly` (section-head "Time per week" + caption "min / day"; 7 cột nhãn M·T·W·T·F·S·S, bar bg:primary r:6) · BR-2/D-010
Then:
  - UI: **7 cột** (thứ Hai→Chủ nhật), chiều cao mỗi cột ∝ phút học ngày đó; nhãn trục = ký tự thứ (M/T/W/T/F/S/S theo locale); caption "min / day" (ARB).
  - Nguồn: phút/ngày = `daily_activity.minutes` (BR-2: chỉ hoạt động do "Học"/"Lặp lại" ghi, D-010). ⚠ Open-Q #21 (**XUNG ĐỘT ĐƠN VỊ giây↔phút**): decision-table D-010 ghi "`DailyActivity` cộng **giây** + số từ", nhưng schema `daily_activity.minutes` (INTEGER, "Sum of the day's session minutes") + `study_sessions.duration_minutes` (INTEGER phút) + caption kit "min / day" đều là **phút**. Đơn vị nguồn chênh nhau (giây vs phút) → phải BA/D-010 chốt (sửa D-010 về "phút"? hay cột đổi tên `seconds`?). Chưa chốt thì assert theo schema (`minutes`, phút) và đánh dấu rủi ro roll-up sai hệ số 60. ⚠ Open-Q #6: "tuần" là 7 ngày gần nhất hay tuần lịch (bắt đầu thứ Hai/CN)? nhãn thứ theo locale nào?

### SC-STATISTICS-16 — "Leitner box distribution" (8 bar)
Nguồn: spec `statistics/leitner` (section-head "Leitner box distribution" + caption "cards in boxes 1–8"; 8 cột nhãn 1..8, bar bg:accent r:6) · D-003/D-005 (box 8 = mastered) · schema `srs_state.box`
Then:
  - UI: **8 cột** nhãn "1".."8", chiều cao ∝ **số thẻ ở mỗi box**; caption "cards in boxes 1–8" (ARB).
  - Nguồn (có dẫn): đếm `srs_state.box` nhóm theo box 1..8; **box 8 = đã thuộc** (D-005/BR-5 + schema `srs_state.box`: "8 = mastered"). Thẻ box 0 (mới/chưa xếp lịch) KHÔNG nằm trong 1..8 (schema: "0 = new/unscheduled"). Phạm vi lọc theo scope (BR-1).
  - ⚠ Open-Q #7: box 0 (new) có được đếm/hiển thị đâu không, hay Leitner chỉ 1..8?
  - ⚠ Open-Q #23 (**KHÔNG BỊA — Leitner có loại `hidden` không?**): schema D-006/BR-8 chỉ nói thẻ `hidden` bị loại khỏi **due queue / new queue / due counts** — KHÔNG nói gì về **biểu đồ phân bố Leitner**; business/statistics doc cũng không đề cập. Việc áp D-006 (loại hidden) vào cột Leitner là **suy luận chưa có nguồn trực tiếp cho màn statistics** → chưa chốt thì đừng assert loại/không-loại hidden; hỏi BA. (Open-Q #7 cũ chỉ hỏi box 0.)

### SC-STATISTICS-17 — "Accuracy" (donut 30 ngày)
Nguồn: spec `statistics/accuracy` (section-head "Accuracy" + caption "30 days"; donut "88%" + "accuracy") · BR statistics §Độ chính xác · `review_logs.grade`(review_outcome)
Then:
  - UI: vòng donut + nhãn **phần trăm** ở giữa + "accuracy" (ARB); caption "30 days" (ARB).
  - Nguồn: tỉ lệ = count(`review_logs.grade='pass'`) / count(tất cả log) trong cửa sổ 30 ngày (`review_logs.reviewed_at`); **chỉ lượt DueReview** ghi log (D-007: Game/Review/Player không ghi) → statistics doc "v1 chỉ tính lượt DueReview". Không có log ⇒ xem SC-STATISTICS-44.
  - ⚠ Open-Q #8: cửa sổ chính xác 30 ngày (kit caption) hay khác? có lọc theo scope cặp không (review_logs không có cột pair — cần join card→deck→pair)?

### SC-STATISTICS-18 — "Library overview" — total (ov-0)
Nguồn: spec `statistics/ov-0` ("1240" + "total", surface-muted)
Then: UI thẻ hiển thị **tổng số thẻ** + nhãn "total" (ARB). Nguồn: count `cards` trong scope (BR-1). ⚠ Open-Q #9: "total" gồm cả thẻ `hidden` không? (D-006 loại hidden khỏi queue/count study — nhưng "total library" có thể là tổng tuyệt đối) → đừng bịa.

### SC-STATISTICS-19 — "Library overview" — mastered (ov-1)
Nguồn: spec `statistics/ov-1` ("680" + "mastered") · D-005
Then: UI thẻ hiển thị **số thẻ đã thuộc** + nhãn "mastered" (ARB). Nguồn: count `srs_state.box=8` (D-005 mastered) trong scope, loại hidden (D-006). ⚠ Open-Q #10: "mastered" = box 8 hay ngưỡng khác? (kit dashboard mastered % để ngỏ) → thống nhất với dashboard trước khi test.

### SC-STATISTICS-20 — "Library overview" — due (ov-2)
Nguồn: spec `statistics/ov-2` ("96" + "due") · D-001/D-006 · **schema `srs_state.due_at`** (dòng định nghĩa `isDue`)
Then: UI thẻ hiển thị **số thẻ đến hạn** + nhãn "due" (ARB). Nguồn: count `srs_state` có `due_at != NULL AND due_at <= now` — công thức `isDue(now)` **dẫn từ schema-contract §`srs_state.due_at`**: "`isDue(now) = due_at != NULL AND due_at <= now`" (không suy đoán). Join thẻ **không hidden** (D-006/BR-8: hidden loại khỏi due counts), trong scope. Giờ "now" so sánh theo `Clock` máy (BR-3).

### SC-STATISTICS-21..24 — Bottom nav (Today/Library/Add/Profile từ Stats)
Nguồn: spec `bottom-nav` ×5 (Stats item[4] active, bg:primary-soft + primary-strong) · navigation-flow (4 nhánh tab + Add action)
When: chạm từng mục từ tab Stats
Then: Today→nhánh Today · Library→nhánh Library · **Add**→action mở luồng thêm (không phải nhánh, Stats vẫn giữ trạng thái nhánh) · Profile→nhánh Profile · Stats(active)→no-op/scroll-top. Pill active + primary-strong đúng tab đích.

---

## 3. Điều hướng vào/ra

### SC-STATISTICS-30 — Vào qua bottom-nav tab Stats
Given: đang ở tab khác
When: chạm "Stats" ở bottom-nav
Then: chuyển sang nhánh `/statistics`; Stats item active (bg:primary-soft). Lần đầu vào có thể qua loading→loaded (SC-STATISTICS-50).

### SC-STATISTICS-31 — Vào qua drawer (cùng route)
Nguồn: navigation-flow "cùng route mở từ drawer"
When: mở statistics từ drawer/entry phụ
Then: cùng đích `/statistics`, cùng state như tab. ⚠ Open-Q #11: drawer có tồn tại ở build hiện tại không? (nav-flow nhắc "cùng route mở từ drawer") → xác nhận entry point.

### SC-STATISTICS-32 — Back hệ thống tại tab Stats (tab gốc)
When: nhấn back (Android) tại Stats
Then: ⚠ Open-Q #12: về tab Today (initial) hay thoát app? (hành vi back tại tab gốc chưa chốt — cùng câu hỏi với dashboard).

### SC-STATISTICS-33 — Giữ vị trí cuộn khi rời & quay lại
Given: cuộn Stats xuống (thân scrollh ~1390 > viewport), chuyển tab Library rồi quay lại Stats
Then: nhánh Stats giữ vị trí cuộn + scope đang chọn (StatefulShellRoute giữ nhánh).

### SC-STATISTICS-34 — Ra Add từ Stats không rời nhánh
When: chạm Add
Then: mở luồng thêm (bottom-sheet/route push), Stats vẫn là nhánh nền; đóng luồng thêm → về Stats nguyên trạng.

### SC-STATISTICS-35 — Đổi cặp active ở nơi khác → quay lại Stats
Given: đổi `language_pairs.is_active` (qua glossary/settings) → quay lại Stats với scope "This pair"
Then: các khối "This pair" tính lại theo cặp active mới (BR-1). "All" không đổi theo cặp. DB: chỉ `language_pairs.is_active` đổi ở nguồn khác — Stats chỉ đọc.

---

## 5. Lượng dữ liệu

### SC-STATISTICS-40 — 0 hoạt động / 0 thẻ (rỗng hoàn toàn)
Then: rơi vào state `insufficient` (SC-STATISTICS-03) — không dựng biểu đồ. (⚠ ngưỡng: Open-Q #3.)

### SC-STATISTICS-41 — 1 thẻ / 1 ngày hoạt động (tối thiểu)
Then: ⚠ ranh giới "đủ vs chưa đủ" (Open-Q #3): nếu ≥ ngưỡng → loaded với biểu đồ 1 điểm; nếu < ngưỡng → insufficient. Heatmap tô 1 ô, weekly 1 cột > 0, overview total=1.

### SC-STATISTICS-42 — Nhiều thẻ trải đều box 1..8
Nguồn: D-003/D-005
Then: Leitner 8 cột đều > 0; mastered (ov-1) = số box 8; total (ov-0) = tổng.

### SC-STATISTICS-43 — Toàn bộ thẻ box 8 (đã thuộc hết)
Nguồn: D-005/BR-5 (box 8 = mastered, off-schedule) · **schema `srs_state.due_at`**
Then: Leitner chỉ cột "8" cao, cột 1..7 = 0 (min-height r:6); mastered = total; due (ov-2) = 0. Cơ sở "box 8 ⇒ due=0" **dẫn từ schema-contract §`srs_state.due_at`**: "`NULL` … for a **mastered** card (box 8) that leaves the schedule (BR-5)" + "box 0 and box 8 are off-schedule (`due_at = NULL`)" (không phải giả định — có nguồn schema; srs-review.md BR-5 cũng ghi "ô 8 = đã thuộc, ngừng xếp lịch").

### SC-STATISTICS-44 — Chưa có `review_logs` (chưa DueReview lần nào)
Then: Accuracy donut ⚠ Open-Q #13: hiển thị "0%" / "—" / hay ẩn khối? (chia 0 log) — business chưa định nghĩa → không bịa; assert không crash + không NaN.

### SC-STATISTICS-45 — Rất nhiều ngày hoạt động (heatmap tràn cửa sổ)
Then: heatmap cuộn ngang trong card (`layout_hint:scroll`), chỉ giữ **cửa sổ 14 tuần gần nhất theo kit** (14 cột × 7 ô); ngày cũ hơn không hiện. Không overflow layout.
⚠ Open-Q #20: cửa sổ = 14 tuần (kit) hay 12 tuần (business doc §0) — xung đột nguồn chưa chốt (xem SC-STATISTICS-14). Test đếm cột phải đổi theo quyết định kit-first.

### SC-STATISTICS-46 — Biên số lớn (total/streak/mastered)
Then: số lớn (vd total 99999, streak 999) không tràn card (font 22/800 · 12) — ellipsis/wrap hoặc rút gọn; assert không vỡ grid 2 cột / 3 cột.

---

## 6. Async & lỗi

### SC-STATISTICS-50 — loading → loaded
Given: provider resolve chậm
Then: state `loading` (skel) → khi có dữ liệu chuyển `loaded` (SC-STATISTICS-01); appbar + bottom-nav không nhấp nháy.

### SC-STATISTICS-51 — loading → insufficient
Then: nếu dữ liệu < ngưỡng, sau loading chuyển `insufficient` (không phải loaded).

### SC-STATISTICS-52 — Đọc DB lỗi
Then: ⚠ Open-Q #14: kit **không có state `error`** cho statistics → hiện gì khi query `daily_activity`/`srs_state`/`review_logs` thất bại? (inline error? giữ loading? insufficient?) — cần spec. Assert tối thiểu: không crash, không màn trắng.

### SC-STATISTICS-53 — Local-first (không mạng)
Then: Stats render đầy đủ từ DB local; không phụ thuộc mạng (không có backend v1).

---

## 7. Persistence (DB round-trip)

### SC-STATISTICS-60 — Phiên "Học"/"Lặp lại" phản ánh lên Stats
Nguồn: D-010/BR-2 · schema `study_sessions` / `daily_activity`
Given: hoàn tất phiên DueReview/NewLearn → `study_sessions` +1 dòng + `daily_activity` cộng minutes/words (D-010)
When: mở Stats
Then:
  - UI: heatmap ô hôm nay đậm thêm · weekly cột hôm nay cao thêm · streak cập nhật · Leitner/overview đổi theo box mới.
  - DB assert (**khoá roll-up cụ thể, không chỉ "cùng ngày"**): dòng `daily_activity` được cộng vào là dòng có `day` = **calendar-day của `study_sessions.started_at`** — schema §`study_sessions`: "its calendar day is the `daily_activity` bucket"; §sơ đồ quan hệ: `study_sessions ──▶ daily_activity (roll-up by started_at day, D-010)`. Công thức khoá: `day = midnight-UTC-của-ngày-local(started_at)` (schema `daily_activity.day`), không phải midnight-local thô (xem SC-STATISTICS-94).
  - DB assert (tổng): `daily_activity(day).minutes` = Σ `study_sessions.duration_minutes` của các session có cùng calendar-day; `daily_activity(day).words` = Σ `study_sessions.words_studied` cùng ngày.
  - ⚠ Open-Q #21 (đơn vị): assert tổng theo **phút** (schema `duration_minutes`/`minutes`); nếu D-010 "giây" là đúng thì công thức cộng phải chia/nhân 60 — chốt trước khi khoá con số.

### SC-STATISTICS-61 — Chấm Đúng/Sai (DueReview) phản ánh Accuracy + Leitner
Nguồn: D-003/D-004/D-005 · `review_logs`
Given: chấm 1 lượt DueReview (pass/fail) → `review_logs` +1 dòng · `srs_state.box` đổi (pass→k+1, fail→k−1 sàn 1, box8 giữ)
When: quay lại Stats
Then: UI Accuracy đổi theo tỉ lệ pass/total mới · Leitner cột nguồn/đích đổi. DB assert: `review_logs` có dòng mới với `grade` ∈ {pass,fail}; `srs_state.box` khớp D-003/004/005.

### SC-STATISTICS-62 — Kill & mở lại app
Then: mở lại → Stats hiển thị lại đúng heatmap/streak/leitner/accuracy/overview từ DB (không mất, không sai). Scope mặc định về "This pair" (⚠ Open-Q #2: scope có nhớ không).

### SC-STATISTICS-63 — Xoá deck (cascade) phản ánh Stats
Nguồn: D-024 · cascade `decks→cards→srs_state/review_logs/card_meanings`
Given: xoá 1 deck có thẻ (ở màn khác) → cascade xoá cards + srs_state + review_logs của subtree
When: quay lại Stats
Then: UI Leitner/overview (total/mastered/due) giảm tương ứng; Accuracy tính lại (log đã xoá). DB assert: các dòng con đã bị xoá theo D-024. (daily_activity/study_sessions của session cũ vẫn còn — session_sessions.deck_id cascade nhưng daily_activity là roll-up theo ngày, không FK theo deck → ⚠ Open-Q #15: xoá deck có làm sai daily_activity roll-up cũ không?)

---

## 8. Định dạng & i18n

### SC-STATISTICS-70 — Nhãn thứ trong tuần theo locale
Given: đổi locale (vi/en/ja)
Then: nhãn cột weekly (M/T/W…) đổi theo locale; caption "min / day", "last 14 weeks", "30 days", "cards in boxes 1–8" từ ARB đổi ngôn ngữ; không vỡ layout.

### SC-STATISTICS-71 — Phần trăm accuracy theo locale
Then: "88%" định dạng số phần trăm theo locale (dấu %/vị trí); không hardcode chuỗi kit.

### SC-STATISTICS-72 — Plural streak
Then: streak=1 vs N dùng ARB plural cho nhãn "current streak"/"longest" nếu ngôn ngữ cần số nhiều (không nối chuỗi thủ công). ⚠ Open-Q #16: nhãn có kèm đơn vị "day(s)" không? (kit chỉ "current streak"/"longest", không "day").

### SC-STATISTICS-73 — CJK & scope tên cặp
Then: khi cặp active là ngôn ngữ CJK (Hàn/Nhật), UI không có tên cặp hiển thị trực tiếp trên Stats (segmented chỉ "This pair"/"All") → CJK render ở đâu? assert: caption/nhãn ARB (nếu dịch sang ja) render đúng glyph, không tofu.

### SC-STATISTICS-74 — Số lớn & định dạng nhóm nghìn
Then: total/mastered/due số lớn (1240 → "1,240" hay "1.240" theo locale) dùng NumberFormat, không nối chuỗi; không tràn card.

### SC-STATISTICS-75 — Text dài (caption dịch dài)
Then: caption section-head dịch dài (vd tiếng Đức/Việt) → wrap/ellipsis trong section-head__caption, không đẩy vỡ bố cục 2 dòng (title + caption).

---

## 9. Dark mode

### SC-STATISTICS-80 — Mọi state ở dark
Then: 4 state (loaded/scope-switch/insufficient/loading) render đúng ở dark: bar bg:primary/accent, card bg:surface/surface-muted, heatmap op-primary, skel surface-sunken — tất cả qua token remap (không hardcode màu); contrast on-primary-soft/text-secondary đạt.

## 10. Responsive

### SC-STATISTICS-81 — 320px → tablet + xoay
Then: ở 320px không overflow — grid streak 2 cột + overview 3 cột co lại; heatmap/weekly/leitner cuộn/co bar; thân dài cuộn dọc được; xoay ngang giữ cuộn; safe-area/notch OK; bottom-nav 5 mục không chồng.

## 11. A11y

### SC-STATISTICS-82 — Semantics
Then: segmented [This pair | All] có role tab/toggle + label + trạng thái selected; hit-area ≥48 (kit minh:38 → ⚠ Open-Q #17: cần tăng hit-area lên ≥48 ở Flutter dù kit 38); mỗi khối biểu đồ có semantic label tóm tắt số liệu (heatmap/weekly/leitner/accuracy/overview đọc thành câu, không đọc rời từng ô/bar); thứ tự đọc: appbar → scope → streak → calendar → weekly → leitner → accuracy → overview → nav; số streak/accuracy đọc có nghĩa.

## 12. Concurrency & edge thời gian

### SC-STATISTICS-90 — Double-tap segmented
When: chạm nhanh 2 lần "All" rồi "This pair"
Then: state cuối cùng đúng lựa chọn cuối (không kẹt trạng thái trung gian, không double-load gây nhấp nháy).

### SC-STATISTICS-91 — Đổi ngày lúc nửa đêm khi đang mở Stats
Nguồn: BR-3 (giờ máy) · D-021 · schema `daily_activity.day`
Given: đang ở Stats lúc 23:59 (giờ local); đồng hồ qua 00:00
Then:
  - Assert khoá bucket theo **công thức schema**, không chỉ "giờ máy chung chung": ô/ngày mới nếu có phải khoá vào `daily_activity.day` = **midnight-UTC của ngày-local mới** (schema: `day` = INTEGER µs, "midnight UTC of the local day"). Một hoạt động lúc 00:05 local rơi vào bucket ngày-local mới, không phải bucket 23:59.
  - ⚠ Open-Q #18: heatmap/weekly/streak tự chốt sang ngày mới (thêm ô ngày mới, streak tính lại) hay chờ mở lại? (engagement: "chưa có job chốt-ngày — tính trực tiếp từ lịch sử") → assert nhất quán với dashboard SC-DASH-90.

### SC-STATISTICS-94 — Biên ngày = midnight-UTC-của-ngày-local (bucket key)
Nguồn: schema `daily_activity.day` (INTEGER µs, "midnight UTC of the local day" PK) · `study_sessions.started_at` ("its calendar day is the daily_activity bucket") · BR-3
Given: máy ở timezone lệch UTC (vd UTC+7); phiên học có `started_at` gần biên ngày-local (23:30 và 00:30 local)
When: roll-up vào `daily_activity` + render heatmap/weekly
Then:
  - Assert khoá bucket: mỗi session gom vào `daily_activity.day` = **midnight-UTC của ngày-local** (không phải midnight-UTC thuần, cũng không phải midnight-local thô). Hai session 23:30 và 00:30 local rơi vào **hai** bucket ngày-local khác nhau dù chỉ cách 1 giờ.
  - Assert heatmap/weekly: ô/cột map theo bucket key này (cùng công thức) — không lệch 1 ô do nhầm UTC-thuần ↔ local.
  - Nhất quán với SC-STATISTICS-60 (roll-up key) và SC-STATISTICS-14/91. ⚠ Open-Q #22: xác nhận hàm chuyển `started_at`(µs UTC) → `day`(midnight-UTC-của-ngày-local) đã có ở domain (Clock + local offset) — nếu chưa, roll-up có thể lệch bucket ở timezone ≠ UTC.

### SC-STATISTICS-92 — Chuyển scope khi đang loading
When: đổi "All" ngay khi khối đang tải
Then: huỷ/thay yêu cầu cũ, dựng theo scope mới; không hiển thị dữ liệu scope cũ lẫn mới.

### SC-STATISTICS-93 — Học ở tab khác rồi quay lại Stats (không reload thủ công)
Given: hoàn tất phiên ở nhánh khác → dữ liệu đổi
When: quay lại nhánh Stats (đã cached)
Then: ⚠ Open-Q #19: Stats tự cập nhật (watch stream `daily_activity`/`srs_state`) hay giữ số cũ tới khi rời-vào lại? — assert theo cơ chế watch nếu spec yêu cầu reactive.

---

## Open questions (⚠ cần chốt spec trước khi viết test — KHÔNG bịa)

1. **Khối "dự báo đến hạn N ngày"**: business doc liệt kê "dự báo đến hạn 7 ngày" nhưng **DOM spec `loaded` KHÔNG render khối forecast** (chỉ streak/calendar/weekly/leitner/accuracy/overview). Kit thiếu hay doc thừa? → cần kit-first quyết trước khi test (đừng dựng khối không có trong kit).
2. **Persist scope**: lựa chọn "This pair"/"All" có lưu vào `settings` (round-trip qua kill-relaunch) không? `settings` không có key scope thống kê.
3. **Ngưỡng "đủ dữ liệu"** phân biệt `loaded` vs `insufficient`: số phiên/ngày/thẻ tối thiểu là bao nhiêu? (chưa có trong business/D-xxx).
4. **Streak trên Stats theo scope?**: current/longest streak tính toàn app hay theo cặp? (`daily_activity` không có cột pair).
5. **Bậc cường độ heatmap**: op {0.08…1.0} map theo minutes / words / max? ngưỡng mỗi bậc?
6. **Định nghĩa "tuần" & nhãn thứ** trong "Time per week": 7 ngày gần nhất hay tuần lịch? bắt đầu thứ Hai/CN? nhãn theo locale nào?
7. **Box 0 (new)** có được đếm/hiển thị đâu đó không, hay Leitner chỉ 1..8?
8. **Accuracy cửa sổ & scope**: đúng 30 ngày? có lọc theo cặp (join card→deck→pair) không?
9. **"total"** ở overview có gồm thẻ `hidden` không? (D-006 loại hidden khỏi count study).
10. **"mastered"** = box 8 hay ngưỡng khác? phải khớp định nghĩa mastered của dashboard.
11. **Entry drawer**: nav-flow nhắc "cùng route mở từ drawer" — drawer có thật ở build hiện tại?
12. **Android back** tại tab gốc Stats: về Today hay thoát app?
13. **Accuracy khi 0 log**: hiển thị 0% / "—" / ẩn khối? (chia 0).
14. **State error**: statistics không có `error` trong kit — hiện gì khi đọc DB lỗi?
15. **Cascade xoá deck vs `daily_activity`**: xoá deck cascade cards/srs/logs, nhưng `daily_activity` là roll-up theo ngày (không FK deck) — số cũ có bị sai/không đồng bộ không?
16. **Nhãn đơn vị streak**: "current streak"/"longest" có kèm "day(s)" không (plural)?
17. **Hit-area segmented**: kit minh:38 < 48 — Flutter có phải tăng lên ≥48 cho a11y không?
18. **Nửa đêm realtime vs lazy**: Stats chốt ngày mới ngay hay chờ mở lại?
19. **Reactive update**: Stats watch stream tự cập nhật khi dữ liệu đổi ở tab khác, hay chỉ đọc 1 lần?
20. **XUNG ĐỘT NGUỒN heatmap 12-vs-14 tuần** (kit-first quyết): business doc `docs/business/statistics/statistics.md` §0 ghi "heatmap hoạt động **12 tuần**", nhưng DOM spec chốt **14** (caption "last 14 weeks" + grid 14 cột × 7 ô). Sửa business doc về 14 hay kit về 12? Cửa sổ heatmap + test đếm cột phụ thuộc câu trả lời (SC-STATISTICS-14/45). **Không lặng lẽ chọn 14.**
21. **XUNG ĐỘT ĐƠN VỊ thời gian giây↔phút**: decision-table D-010 ghi "`DailyActivity` cộng **giây** + số từ", nhưng schema `daily_activity.minutes` ("Sum of the day's session minutes") + `study_sessions.duration_minutes` + caption kit "min / day" đều là **phút**. Nguồn chênh đơn vị (hệ số 60) → chốt: sửa D-010 về "phút", hay cột thực chất là giây? Ảnh hưởng weekly bar + roll-up assert (SC-STATISTICS-15/60). **Không im.**
22. **Hàm biên ngày = midnight-UTC-của-ngày-local**: xác nhận domain có hàm chuyển `study_sessions.started_at`(µs UTC) → `daily_activity.day`(midnight-UTC-của-ngày-local, theo schema) — ở timezone ≠ UTC dễ lệch bucket nếu nhầm midnight-UTC-thuần ↔ midnight-local (SC-STATISTICS-91/94).
23. **Leitner có loại `hidden` không?** (chưa có nguồn cho màn statistics): D-006/BR-8 chỉ loại hidden khỏi **due/new queue + due counts**; KHÔNG nói về **biểu đồ phân bố Leitner**; business/statistics doc im lặng. Cột Leitner đếm `srs_state.box` có trừ thẻ hidden hay không? → hỏi BA, đừng suy từ D-006 (SC-STATISTICS-16). (Khác Open-Q #7 chỉ hỏi box 0.)

> Các mục ⚠ ở trên là **danh sách phải hỏi BA/spec/kit**, không được đoán. Khi có câu trả lời → cập nhật
> scenario tương ứng + xoá cờ ⚠. Đây chính là "không bỏ sót": phần chưa rõ được **liệt kê ra**, không lờ đi.
