# Kịch bản — Study Result · screen `study-result`

Nguồn: `docs/contracts/study-result.md` [standard · goal-met · goal-missed · many-wrong ·
finalizing · retry-finalize · finalize-error] · DOM `specs/study-result.md` ·
D-010, D-021, D-029 (D-002/D-003/D-004/D-005/D-015 gián tiếp — SRS đã ghi TRƯỚC khi vào màn) ·
BR `business/study/study-flow.md` (BR-5, D-010/D-029) + `business/engagement/dashboard-engagement.md` (BR-2/BR-3, D-021) ·
DB `study_sessions`, `daily_activity`, `srs_state`, `review_logs`, `settings`(goal.*).

> Số/tên/chuỗi trong kit là MOCK ("24 cards", "88%", "6:30 min", "12 days", "14/20 min",
> "Streak +1 → 13 days", "You missed 8 cards") — assert **định dạng & nguồn dữ liệu**,
> KHÔNG assert giá trị mock. Chuỗi lấy từ ARB, không copy kit. Con số hiển thị phải suy ra
> từ DB (`study_sessions` phiên vừa xong · `daily_activity` hôm nay · `settings.goal.*` ·
> `review_logs` phiên).

## Ranh giới trách nhiệm (đọc trước)

Study-result là màn **chốt phiên (finalize) + tổng kết**, pushed/overlay sau khi phiên
"Học"/"Lặp lại" kết thúc. Việc **ghi SRS** (D-002/003/004/005) xảy ra TRONG phiên study-session
(mỗi lần chấm), KHÔNG phải ở màn này. Màn này chịu trách nhiệm **finalize**: viết `study_sessions`
+ cộng dồn `daily_activity` (D-010) rồi hiển thị tổng kết. Vì vậy assertion SRS ở đây là
**"không đổi thêm"** (đã đóng băng khi vào màn), còn assertion **ghi mới** tập trung vào
`study_sessions` / `daily_activity`.

> ⚠ **XUNG ĐỘT NGUỒN (đơn vị thời lượng) — chưa chốt, KHÔNG tự chọn bên.** D-010
> (decision-table, được trích ở header dòng 5-6) ghi "DailyActivity cộng **giây** + số từ",
> NHƯNG schema-contract ghi `study_sessions.duration_minutes` = INTEGER "Minutes" và
> `daily_activity.minutes` = INTEGER "Sum of the day's session minutes". Các assertion phút
> dưới đây (SC-STUDYRESULT-16/60/61/92) BÁM SCHEMA (nguồn canonical cho DB), nhưng đây là
> mâu thuẫn giữa hai nguồn được trích → phải chốt đơn vị canonical trước khi viết test — xem
> Open-question 5. Không được im lặng coi "phút" là đúng tuyệt đối.

## DoE — study-result (12 chiều)

| # | Chiều | TT | Scenario / N/A |
|---|---|---|---|
| 1 | States (7) | ✅ | SC-STUDYRESULT-01..07 |
| 2 | Elements (13 node tương tác/hiển thị + id skeleton/container) | ✅ | SC-STUDYRESULT-10..27 |
| 3 | Nav vào/ra | ✅ (đích + cơ chế push CHƯA chốt → Open-q 1) | SC-STUDYRESULT-30..37 (34: push/replace là suy đoán, không assert Then) |
| 4 | Nhập liệu & validation | **N/A** | study-result KHÔNG có field nhập (không input/toggle/chip/menu/tab/FAB trong DOM spec) — chỉ button + hiển thị. Xem SC-STUDYRESULT-73 cho biên hiển thị số. |
| 5 | Lượng dữ liệu + precedence đa điều kiện | ✅ | SC-STUDYRESULT-40..46 (46 = precedence, blocked-on-Q3) |
| 6 | Async & lỗi | ✅ | SC-STUDYRESULT-50..54 |
| 7 | Persistence (DB round-trip) | ✅ | SC-STUDYRESULT-60..64 |
| 8 | Định dạng & i18n | ✅ | SC-STUDYRESULT-70..75 |
| 9 | Dark mode | ✅ | SC-STUDYRESULT-80 |
| 10 | Responsive | ✅ | SC-STUDYRESULT-81 |
| 11 | A11y | ✅ | SC-STUDYRESULT-82 |
| 12 | Concurrency & edge thời gian | ✅ | SC-STUDYRESULT-90..93 |

Element inventory (từ DOM spec — mỗi cái ≥1 scenario ở mục 2):
`close` (icon-button, appbar/lead, mọi state) · `appbar__title` "Results" (hiển thị, mọi state) ·
`icon-tile` (biểu tượng theo state: task_alt/celebration/trending_up/refresh/cloud_sync/cloud_off) ·
tiêu đề + phụ đề (title/subtitle theo state) · `stat-0/1/2` (3 thẻ số: cards · correct% · min) ·
`goal` card (streak + "Today's goal" + `goal-bar`) · `continue` btn ("Keep studying"/"Keep going") ·
`library` btn ("Back to library") · `later` btn (state goal-missed) · `review-wrong` btn (state many-wrong) ·
`finalize-retry` + `finalize-later` btn (state finalize-error) · `mxg-skel` (skeleton finalizing/retry, SC-25) ·
`finalizing-stat-0/1/2` (card id skeleton finalizing/retry-finalize, SC-26) · `finalize-error` (container id state lỗi, SC-27).

> ⚠ Mọi `btn`/`icon-button` trong DOM spec đều mang `mx:?` (không có mapping component chắc chắn)
> và KHÔNG có D-xxx/business/navigation-flow định nghĩa **đích điều hướng** khi bấm. Vì vậy các
> scenario element dưới đây assert phần **spec chắc chắn** (nhãn từ ARB, trạng thái finalize, ghi DB)
> và ghi cờ ⚠ cho phần đích chưa chốt → xem "Open questions".

---

## 1. States (mỗi state ≥1 scenario dẫn tới)

### SC-STUDYRESULT-01 — standard (phiên xong, chưa xét goal/nhiều-sai)
Nguồn: contract[standard] · DOM spec base · D-010/BR-5 · D-029
Tiền điều kiện (Given):
  - DB: `settings`(goal.minutes_target &/hoặc goal.words_target đặt) · phiên "Học"/"Lặp lại" (dueReview/newLearn) vừa hoàn tất trên 1 deck có thẻ; finalize đã thành công.
  - Điều kiện phân nhánh: KHÔNG đạt goal-met, KHÔNG missed-đáng-nhắc, KHÔNG many-wrong (số sai dưới ngưỡng ⚠).
Thao tác (When): phiên kết thúc → màn Results hiển thị (sau finalize).
Kỳ vọng (Then):
  - UI: appbar "Results" + `close`; icon-tile = task_alt (bg accent-soft); tiêu đề + phụ đề "đã ôn N thẻ" (ARB, N từ phiên); 3 stat card (cards · % correct · min); goal card (streak + "Today's goal" + bar); nút `continue` ("Keep studying") + `library` ("Back to library"). KHÔNG skeleton, KHÔNG error.
  - DB: `study_sessions` có +1 dòng cho phiên (mode ∈ {due_review,new_learn}, duration_minutes, words_studied); `daily_activity`(hôm nay) đã cộng phút+từ (D-010).

### SC-STUDYRESULT-02 — goal-met (đạt mục tiêu ngày nhờ phiên này)
Nguồn: contract[goal-met] · DOM diff "goal met" · D-021/BR-2/BR-3
Given: sau finalize, `daily_activity`(hôm nay) `minutes ≥ goal.minutes_target` HOẶC `words ≥ goal.words_target` (D-021/BR-2).
When: phiên kết thúc → Results.
Then:
  - UI: icon-tile = celebration (bg success-soft, color on-success-soft); tiêu đề = "đạt mục tiêu ngày" + phụ đề nhắc streak (ARB, KHÔNG copy "Streak +1 → 13 days"); goal card: số ngày streak + phụ đề "+1 today" (ARB); nhãn tiến độ = met (mock "20/20 min" → assert **định dạng "X/Y phút"** với X≥Y); goal-bar đầy.
  - DB: `daily_activity`(hôm nay).minutes/words phản ánh đủ để met; streak (read-model `streakFromHistory`) tăng theo D-021. ⚠ Xác nhận: màn tự tính streak "+1" hiển thị realtime, hay chờ chốt-ngày (engagement: "chưa có job chốt-ngày — tính trực tiếp từ lịch sử")?

### SC-STUDYRESULT-03 — goal-missed (chưa đạt mục tiêu ngày)
Nguồn: contract[goal-missed] · DOM diff "goal missed" · D-021/BR-2
Given: sau finalize, `daily_activity`(hôm nay) chưa đạt cả hai target (minutes < target VÀ words < target).
When: Results.
Then:
  - UI: icon-tile = trending_up (bg warning-soft); tiêu đề "gần đạt" + phụ đề "còn N phút/từ nữa" (ARB — mock "6 more minutes"; assert **định dạng + nguồn = target − hiện tại**); nút chính `continue` nhãn "Keep going" (ARB), nút phụ `later` "Later" (ARB, THAY cho "Back to library" ở standard).
  - DB: `daily_activity`(hôm nay) < target; streak không tăng do phiên này (D-021).
  - ⚠ Xác nhận: "còn N" tính theo phút, theo từ, hay theo chỉ số gần đạt nhất?

### SC-STUDYRESULT-04 — many-wrong (nhiều thẻ sai trong phiên)
Nguồn: contract[many-wrong] · DOM diff "many wrong" · D-015/D-029
Given: phiên vừa xong có **số thẻ sai ≥ ngưỡng** (⚠ ngưỡng chưa có trong D-xxx/business).
When: Results.
Then:
  - UI: icon-tile = refresh (bg error-soft); tiêu đề "vài từ chưa vững" + phụ đề "đã bỏ lỡ N thẻ — ôn lại" (ARB; N = số thẻ sai, nguồn từ phiên/`review_logs` grade=fail); nút chính `review-wrong` ("Review N cards", icon replay) + nút phụ `library`.
  - DB: `review_logs` phiên có ≥ngưỡng dòng `grade='fail'` (nếu là dueReview) HOẶC đếm sai nội-phiên (nếu newLearn — newLearn ghi log? ⚠). `study_sessions`/`daily_activity` đã ghi như standard.
  - ⚠ Xác nhận: (a) ngưỡng "many wrong" = mấy thẻ / % nào? (b) newLearn có ghi `review_logs` không (schema nói log ghi mỗi lần GradeCard của DueReview) → nếu newLearn không log, "N thẻ sai" của many-wrong lấy từ đâu?

### SC-STUDYRESULT-05 — finalizing (đang chốt phiên, skeleton)
Nguồn: contract[finalizing] · DOM state "finalizing" (full)
Given: phiên kết thúc, quá trình finalize (ghi `study_sessions` + cộng `daily_activity`) đang chạy.
When: vừa vào Results, finalize chưa resolve.
Then:
  - UI: appbar "Results" + `close`; icon-tile = cloud_sync (bg accent-soft); tiêu đề "đang lưu…" + phụ đề "cập nhật lịch ôn & streak" (ARB); 3 stat card hiện `mxg-skel` (không số thật); khối skeleton lớn thay goal card. KHÔNG nút hành động chính.
  - DB: chưa assert giá trị cuối (đang ghi); không crash.

### SC-STUDYRESULT-06 — retry-finalize (đang thử lại finalize)
Nguồn: contract[retry-finalize] · DOM state "retry-finalize" (full)
Given: finalize lần trước lỗi → người dùng bấm `finalize-retry` (từ finalize-error) → đang thử lại.
When: đang retry.
Then:
  - UI: giống finalizing NHƯNG icon-tile = refresh; tiêu đề "đang thử lại…" + phụ đề "thử lại cập nhật lịch ôn & streak" (ARB); vẫn skeleton stat + khối lớn.
  - DB: chưa assert giá trị cuối; sau thành công → như standard/goal-*; sau lỗi lại → finalize-error (SC-STUDYRESULT-07).

### SC-STUDYRESULT-07 — finalize-error (chốt phiên thất bại)
Nguồn: contract[finalize-error] · DOM state "finalize-error" (full) · id `study-result/finalize-error`
Given: finalize thất bại (ghi `study_sessions`/`daily_activity` không thành công).
When: Results sau lỗi finalize.
Then:
  - UI: layout căn giữa; icon-tile = cloud_off (bg error-soft); tiêu đề "Không lưu được kết quả" + body "phiên đã xong nhưng chưa cập nhật lịch — thử lại để phiên được tính" (ARB); nút `finalize-retry` ("Retry", primary, icon refresh) + `finalize-later` ("Not now", ghost). KHÔNG hiện stat/goal card.
  - DB: `study_sessions`/`daily_activity` CHƯA có dòng của phiên (hoặc rollback nhất quán) — assert phiên chưa được tính.
  - ⚠ Xác nhận: finalize thất bại có ghi một phần không (partial)? phải đảm bảo atomic hay có thể để mồ côi?

---

## 2. Elements (mỗi phần tử tương tác/hiển thị ≥1 scenario)

### SC-STUDYRESULT-10 — `close` (icon-button appbar, mọi state)
Nguồn: DOM `study-result/close` (icon:close, mx:?, hit 48x48, mọi state kể cả finalizing/error)
When: chạm `close`.
Then:
  - UI: đóng màn Results (pop overlay). ⚠ Xác nhận đích khi đóng: về deck-detail nguồn? về Library? về Today? (không có trong navigation-flow) — assert tối thiểu: nút có semantic label (ARB), hit-area ≥48 (DOM 48x48), tap có phản hồi, không crash.
  - DB: chạm `close` KHÔNG ghi thêm/không hoàn tác finalize đã xong.
  - ⚠ Xác nhận: ở state `finalizing`/`retry-finalize` (đang ghi) mà bấm close → huỷ finalize? chờ xong? (schema: study_sessions/daily_activity có thể ghi dở).

### SC-STUDYRESULT-11 — `appbar__title` "Results" (hiển thị, mọi state)
Nguồn: DOM appbar__title "Results"
Then: hiển thị tiêu đề màn từ ARB (KHÔNG copy "Results"); hiện ở cả 7 state (base + full states đều có appbar). Text dài locale khác → không tràn (xem SC-STUDYRESULT-74).

### SC-STUDYRESULT-12 — `icon-tile` (biểu tượng đổi theo state)
Nguồn: DOM icon-tile: task_alt(standard)/celebration(goal-met)/trending_up(goal-missed)/refresh(many-wrong)/cloud_sync(finalizing)/refresh(retry-finalize)/cloud_off(finalize-error)
Then: mỗi state render đúng icon + token nền tương ứng (accent-soft/success-soft/warning-soft/error-soft) theo diff spec; assert **token nền + icon glyph theo state**, không hardcode màu.

### SC-STUDYRESULT-13 — Tiêu đề + phụ đề (title/subtitle theo state)
Nguồn: DOM div text (mock "Session complete"/"You reviewed 24 cards…" và các diff)
Then: mỗi state hiển thị **cặp tiêu đề+phụ đề đúng state** từ ARB; số trong phụ đề (thẻ đã ôn / còn N phút / bỏ lỡ N) suy từ DB/phiên, KHÔNG copy số mock. Phụ đề wrap ≤ maxw (280/220 theo spec), không tràn.

### SC-STUDYRESULT-14 — `stat-0` "cards" (số thẻ phiên)
Nguồn: DOM `study-result/stat-0` (value "24", label "cards")
Then: value = **số thẻ đã học trong phiên** (nguồn `study_sessions.words_studied` phiên vừa xong / số thẻ phiên); label plural "cards" (ARB, 1 vs N — xem SC-STUDYRESULT-72). Assert định dạng số + nguồn, không giá trị mock "24".

### SC-STUDYRESULT-15 — `stat-1` "correct" (% đúng phiên)
Nguồn: DOM `study-result/stat-1` (value "88%", label "correct")
Then: value = **% đúng của phiên** (nguồn dự kiến: pass/(pass+fail) nếu dueReview).
⚠ **Nguồn CHƯA truy được từ schema**: `review_logs` không có `session_id`/cột phiên (chỉ
`card_id, grade, reviewed_at`) → không lọc được "log của phiên" bằng khoá phiên. Cần chốt cơ
chế (bộ đếm in-memory hay lọc theo `reviewed_at` trong khoảng phiên) — Open-question 5b. ⚠
newLearn tính % từ đâu (không ghi log) — Open-question 4. Định dạng phần trăm theo locale; biên
0%/100% không tràn. Đánh dấu blocked-on-Q4/Q5b.

### SC-STUDYRESULT-16 — `stat-2` "min" (phút phiên)
Nguồn: DOM `study-result/stat-2` (value "6:30", label "min")
Then: value = **thời lượng phiên** (nguồn `study_sessions.duration_minutes` / đồng hồ phiên); định dạng "m:ss" hoặc phút theo locale. ⚠ **XUNG ĐỘT NGUỒN đơn vị (blocked-on-Q5):** schema nói cột là INTEGER **phút**, nhưng D-010 (decision-table) nói cộng **giây**, còn kit hiện "6:30" (phút:giây) → chưa chốt canonical là giây hay phút, và stat hiển thị phút:giây hay phút tròn. Assert định dạng + nguồn nhưng đánh dấu blocked-on-Q5, KHÔNG tự chốt "phút".

### SC-STUDYRESULT-17 — `goal` card + streak (states standard/goal-met/goal-missed)
Nguồn: DOM `study-result/goal` (icon local_fire_department + "12 days"/"day streak" + "Today's goal" + "14/20 min")
Then: hiển thị số streak (nguồn `streakFromHistory` từ `daily_activity`, D-021) + nhãn "day streak" plural (ARB); dòng "Today's goal" + tiến độ "X/Y phút" (X=`daily_activity`.minutes hôm nay, Y=`settings.goal.minutes_target`); goal-bar tỉ lệ X/Y. Assert nguồn + định dạng, không mock.

### SC-STUDYRESULT-18 — `goal-bar` (thanh tiến độ mục tiêu)
Nguồn: DOM `study-result/goal-bar` (track surface-sunken + fill on-primary-soft, mock 217/310)
Then: fill = tỉ lệ min(hiện tại/target, 100%); target đạt → đầy (goal-met); target chưa → một phần (standard/goal-missed). Biên: hiện tại > target → không tràn khỏi track (clamp 100%).

### SC-STUDYRESULT-19 — `continue` btn ("Keep studying"/"Keep going")
Nguồn: DOM `study-result/continue` (btn primary, icon bolt, "Keep studying"; goal-missed đổi "Keep going") · D-029 (**chỉ áp cho continue của DueReview** — newLearn không được D-029 phủ)
When: chạm nút chính.
Then:
  - UI: nhãn theo state từ ARB.
  - ⚠ **Nguồn hành vi TÁCH THEO MODE — không gán chung D-029:**
    - **continue của DueReview** ↔ D-029 áp dụng: "hiện học lại đúng mode vừa chạy" (result
      "Tiếp tục" chạy lại cùng entry). Đây là mode duy nhất D-029 phủ.
    - **continue của NewLearn** (state standard có thể là `mode=new_learn`): D-029 **KHÔNG phủ
      newLearn** (D-029 chỉ nói "kết thúc một mode trong **DueReview**"). Gán D-029 cho nút
      continue khi phiên là newLearn là **suy đoán vượt nguồn** → CHƯA có nguồn, để Open-question
      1. Assert tối thiểu: nhãn "Keep studying" (ARB), tap phản hồi, không crash.
  - DB: mở phiên mới (nếu có) KHÔNG hoàn tác finalize phiên cũ; phiên mới (nếu là due/new) sẽ tạo `study_sessions` riêng khi nó kết thúc.

### SC-STUDYRESULT-20 — `library` btn ("Back to library")
Nguồn: DOM `study-result/library` (btn ghost, "Back to library"; states standard/many-wrong)
When: chạm.
Then: rời Results về Library (theo nhãn). ⚠ Xác nhận đích chính xác (tab Library? deck-detail?) — assert: nhãn từ ARB, tap phản hồi, không crash, không ghi DB.

### SC-STUDYRESULT-21 — `later` btn (state goal-missed)
Nguồn: DOM `study-result/later` (btn ghost "Later", THAY `library` ở goal-missed)
When: chạm.
Then: rời Results (hoãn học tiếp). ⚠ Xác nhận đích. Assert: nhãn "Later" từ ARB, chỉ xuất hiện ở goal-missed, tap phản hồi, không ghi DB.

### SC-STUDYRESULT-22 — `review-wrong` btn (state many-wrong)
Nguồn: DOM `study-result/review-wrong` (btn primary, icon replay, "Review N cards")
When: chạm.
Then:
  - UI: nhãn "Review N cards" (N = số thẻ sai, ARB plural). Kỳ vọng: mở phiên ôn lại **các thẻ đã sai** trong phiên (khớp D-015 "học lại đến khi đúng" — nhưng đây là hành động sau-phiên).
  - DB: nếu ôn lại các thẻ sai là dueReview → sẽ tạo phiên `study_sessions` mới + ghi `review_logs` khi kết thúc; SRS thay đổi theo chấm mới (D-003/D-004). ⚠ Xác nhận: "Review N cards" chạy lại đúng N thẻ sai (nguồn danh sách thẻ sai từ đâu — phiên giữ trong bộ nhớ?) hay chạy lại toàn phiên?

### SC-STUDYRESULT-23 — `finalize-retry` btn (state finalize-error)
Nguồn: DOM `study-result/finalize-retry` (btn primary "Retry", icon refresh)
When: chạm khi ở finalize-error.
Then:
  - UI: chuyển sang state `retry-finalize` (skeleton) → thành công → standard/goal-*; thất bại → quay lại finalize-error.
  - DB: thử ghi lại `study_sessions` + cộng `daily_activity` (D-010); thành công ⇒ phiên được tính (dòng xuất hiện).

### SC-STUDYRESULT-24 — `finalize-later` btn (state finalize-error)
Nguồn: DOM `study-result/finalize-later` (btn ghost "Not now")
When: chạm khi ở finalize-error.
Then: rời Results mà KHÔNG finalize. ⚠ Xác nhận: bỏ "Not now" ⇒ phiên **không được tính** (không ghi `study_sessions`/`daily_activity`) — mất vĩnh viễn hay xếp hàng thử lại sau? (không có spec). Assert tối thiểu: nhãn "Not now" từ ARB; sau khi bấm, `study_sessions`/`daily_activity` phiên chưa có dòng (khớp SC-STUDYRESULT-07 Given).

### SC-STUDYRESULT-25 — `mxg-skel` (skeleton node, states finalizing/retry-finalize)
Nguồn: DOM `mxg-skel` (finalizing dòng 825/830/849/854/873/878 style bg:surface-sunken r:8 trong stat card; dòng 883 khối lớn bg:surface-sunken r:20; retry-finalize dòng 1005..1058 r:8 + dòng 1063 r:20)
When: ở state finalizing HOẶC retry-finalize.
Then:
  - UI: mỗi stat card render **2 `mxg-skel`** (dòng giá trị 44x22 + dòng nhãn 49x10) với token nền `surface-sunken` r:8 (KHÔNG hardcode màu); khối lớn thay goal card là **1 `mxg-skel`** 350x120 token `surface-sunken` r:20. Assert: đúng token nền + đúng bán kính (8 cho stat, 20 cho khối lớn) theo diff spec; skeleton là placeholder rỗng (KHÔNG chứa số/chữ thật).
  - A11y: skeleton không phát ra số rác cho screen-reader (khớp SC-STUDYRESULT-82).

### SC-STUDYRESULT-26 — id `study-result/finalizing-stat-0/1/2` render đúng (finalizing & retry-finalize)
Nguồn: DOM node id `study-result/finalizing-stat-0` (finalizing dòng 812, retry-finalize dòng 992), `finalizing-stat-1` (dòng 836/1015), `finalizing-stat-2` (dòng 860/1039) — id RIÊNG, khác `stat-0/1/2` của base
When: ở state finalizing HOẶC retry-finalize.
Then:
  - UI: 3 card skeleton mang đúng id `study-result/finalizing-stat-0`, `…-1`, `…-2` (KHÔNG phải `stat-0/1/2`); mỗi card `bg:surface-muted r:20`, layout grid 3 cột, mỗi card chứa 2 `mxg-skel` (SC-STUDYRESULT-25). Parity theo id: xác nhận id finalizing-stat-* tồn tại đúng DOM (không dùng nhầm id base `stat-*`).
  - Lưu ý: retry-finalize **TÁI DÙNG** cùng id `finalizing-stat-*` (DOM không đặt id `retry-finalize-stat-*` riêng — dòng 992/1015/1039); assert hai state dùng chung bộ id này.

### SC-STUDYRESULT-27 — id container `study-result/finalize-error` render (state finalize-error)
Nguồn: DOM `study-result/finalize-error` (dòng 1128 — `div` bọc icon-tile + title/body + 2 nút; flex:col gap:16 justify:center align:center, pad:40/16, maxw khối text 220)
When: ở state finalize-error.
Then:
  - UI: container định danh `study-result/finalize-error` render (1 `div` bọc toàn khối lỗi); bên trong đúng thứ tự: `icon-tile`(cloud_off, bg:error-soft) → khối tiêu đề+body (maxw:220) → khối 2 nút (`finalize-retry` + `finalize-later`). Căn giữa dọc/ngang (justify/align:center). KHÔNG có stat/goal card trong container này.
  - Parity theo id: assert container id `study-result/finalize-error` tồn tại (bổ sung cho SC-STUDYRESULT-07/51 vốn chỉ mô tả nội dung, chưa kiểm id container).

---

## 3. Điều hướng vào/ra

### SC-STUDYRESULT-30 — Vào: từ phiên "Học" (newLearn) hoàn tất
Nguồn: BR-5/D-010 · study-flow UC-2
Given: phiên newLearn hoàn thành đủ 5 chặng.
When: phiên kết thúc.
Then: push study-result (finalizing → standard/goal-*/many-wrong tuỳ dữ liệu). DB: newLearn đã đưa thẻ mới vào ô 1 (D-002) **trước** khi vào màn; màn finalize ghi `study_sessions`(mode=new_learn) + `daily_activity`.

### SC-STUDYRESULT-31 — Vào: từ phiên "Lặp lại" (dueReview) hoàn tất
Nguồn: BR-5/D-010 · study-flow UC-3 · D-029
Given: phiên dueReview kết thúc (mọi thẻ đã đúng, D-015).
When: kết thúc.
Then: push study-result. DB: `study_sessions`(mode=due_review) + `daily_activity` cộng; `review_logs` đã có dòng cho từng lần chấm (D-003/D-004) trước khi vào màn.

### SC-STUDYRESULT-32 — KHÔNG vào từ luyện tập (Xem lại/Game/Trình phát)
Nguồn: D-007/D-010/BR-5 · study-flow UC-4
Given: kết thúc một mode luyện tập.
Then: ⚠ Xác nhận: luyện tập có dùng CHUNG màn study-result này không? Theo BR-5, luyện tập KHÔNG cộng hoạt động ⇒ nếu có màn tổng kết riêng cho game/player thì KHÔNG phải study-result (finalize ghi study_sessions). Assert: sau luyện tập KHÔNG ghi `study_sessions`/`daily_activity`/`review_logs` (D-007/D-010). ⚠ study-result thuộc riêng due/new — cần xác nhận không tái dùng cho luyện tập.

### SC-STUDYRESULT-33 — Ra: `close` → đóng overlay
Nguồn: DOM `close` (mọi state)
Then: pop về màn nguồn. ⚠ đích (deck-detail/Library/Today) chưa chốt — xem SC-STUDYRESULT-10.

### SC-STUDYRESULT-34 — Ra: `continue`/`review-wrong` → (dự kiến) phiên học mới
Nguồn: DOM continue/review-wrong · D-029
Then: ⚠ **SUY ĐOÁN, chưa có nguồn cơ chế** — D-029 chỉ nói "hiện học lại đúng mode vừa chạy"
(và chỉ cho **DueReview**), KHÔNG nói study-result **push/replace** sang study-session. Việc
"push/replace sang study-session mới" là suy đoán hành vi điều hướng → hạ xuống Open-question 1,
KHÔNG assert như Then. Assert tối thiểu: nút có nhãn ARB, tap phản hồi, không crash, finalize
phiên cũ không bị hoàn tác. Cơ chế push (push vs replace) + back-stack (back quay lại
study-result hay bỏ qua) = chưa chốt (Open-question 1).

### SC-STUDYRESULT-35 — Ra: `library`/`later` → rời khỏi luồng học
Nguồn: DOM library/later
Then: về Library (theo nhãn). ⚠ đích chính xác chưa chốt.

### SC-STUDYRESULT-36 — Back hệ thống (Android) tại study-result
When: nhấn back hệ thống ở study-result (state đã finalize xong).
Then: ⚠ Xác nhận: back = `close` (pop) hay bị chặn ở finalizing/error? (đang ghi DB). Assert tối thiểu: không crash, không finalize hai lần.

### SC-STUDYRESULT-37 — Vào từ deep-link / khôi phục (resume)
When: app bị kill khi đang ở study-result rồi mở lại.
Then: ⚠ Xác nhận: study-result là overlay tạm — có được khôi phục không, hay app mở lại ở tab gốc và phiên đã finalize (nếu đã ghi) vẫn được tính? (xem SC-STUDYRESULT-64 round-trip).

---

## 4. Nhập liệu & validation — **N/A**

study-result KHÔNG có field nhập / toggle / chip / menu-item / tab / FAB / picker / sheet /
dialog trong DOM spec (mọi state chỉ gồm button + hiển thị). Không có gì để validate rỗng/dài/
CJK/trùng/định dạng. Biên hiển thị số (không phải input) được phủ ở SC-STUDYRESULT-73.

---

## 5. Lượng dữ liệu

### SC-STUDYRESULT-40 — Phiên 1 thẻ (biên nhỏ)
Given: phiên chỉ có 1 thẻ.
Then: stat "cards" = 1 (plural số ít, ARB); % correct = 0% hoặc 100% (một thẻ); không vỡ layout; `study_sessions.words_studied`=1.

### SC-STUDYRESULT-41 — Phiên nhiều thẻ (điển hình)
Then: stat hiển thị N thẻ; các số căn giữa trong card, không tràn.

### SC-STUDYRESULT-42 — Phiên rất nhiều thẻ (biên lớn)
Given: phiên nhiều thẻ (vd hàng trăm — do học deck cha gộp đệ quy D-009/BR-6).
Then: stat "cards" số lớn không tràn card (109px rộng); "min" lớn (nhiều phút) không tràn; xem SC-STUDYRESULT-73.

### SC-STUDYRESULT-43 — 0 thẻ đúng (all wrong) → many-wrong
Given: phiên có mọi thẻ sai ≥ ngưỡng.
Then: state many-wrong; % correct = 0%; "Review N cards" với N = tổng thẻ. Không chia-cho-0 khi tính %.

### SC-STUDYRESULT-44 — 100% đúng, chưa đạt goal
Then: standard hoặc goal-missed (nếu chưa đủ phút/từ); % correct=100%; KHÔNG rơi vào many-wrong.

### SC-STUDYRESULT-45 — Streak = 0 và streak lớn (biên goal card)
Then: streak=0 hiển thị hợp lý (ARB); streak lửa lớn (vd 9999) không tràn goal card. Nguồn `streakFromHistory`.

### SC-STUDYRESULT-46 — Đa điều kiện: goal-met AND many-wrong cùng đúng (precedence) — **BLOCKED-ON-Q3**
Nguồn: contract (7 state loại trừ lẫn nhau) · Open-question 3 — ⚠ CHƯA có nguồn thứ tự ưu tiên
Given: phiên vừa xong thoả **đồng thời** hai nhánh: `daily_activity`(hôm nay) đạt goal (minutes≥target HOẶC words≥target, D-021 → goal-met) VÀ số thẻ sai ≥ ngưỡng many-wrong (D-015/⚠ngưỡng).
When: finalize xong → Results phải chọn **một** state (contract 7 state loại trừ lẫn nhau).
Then:
  - ⚠ **BLOCKED-ON-Q3 (chốt-vai-trò):** contract không định nghĩa thứ tự ưu tiên khi nhiều nhánh
    cùng đúng → KHÔNG assert state cụ thể (goal-met? many-wrong? một state kết hợp?). Đây là
    scenario đóng vai chốt: buộc spec trả lời trước khi viết test, thay vì chỉ nằm trong
    Open-questions. Không được tự chọn một bên.
  - Assert tối thiểu (bất biến, độc lập với quyết định precedence): đúng **một** state render (mutual
    exclusion — không chồng 2 layout goal-met + many-wrong cùng lúc); finalize vẫn ghi
    `study_sessions`/`daily_activity` như thường; không crash.
  - Cùng nhóm: (goal-missed + many-wrong) cũng chưa chốt precedence — xem Open-question 3.

---

## 6. Async & lỗi

### SC-STUDYRESULT-50 — finalizing → standard (đường thành công)
Then: skeleton finalizing hiển thị trong lúc ghi; sau khi `study_sessions`+`daily_activity` ghi xong → chuyển sang standard/goal-* với số thật. Không nhấp nháy số sai.

### SC-STUDYRESULT-51 — finalize thất bại → finalize-error
Nguồn: contract[finalize-error]
Then: ghi DB lỗi → hiện finalize-error (cloud_off + Retry/Not now). DB: phiên chưa được tính (SC-STUDYRESULT-07).

### SC-STUDYRESULT-52 — finalize-error → Retry thành công
Nguồn: contract[retry-finalize]
When: bấm `finalize-retry`.
Then: retry-finalize (skeleton) → thành công → standard/goal-*. DB: phiên được tính (dòng `study_sessions`/`daily_activity` xuất hiện). Không ghi trùng (một dòng phiên).

### SC-STUDYRESULT-53 — finalize-error → Retry thất bại lại
Then: retry-finalize → lỗi → quay lại finalize-error (idempotent, không tạo phiên nửa vời).

### SC-STUDYRESULT-54 — local-first (không mạng)
Nguồn: local-first (không remote backend v1)
Then: finalize là ghi DB local (Drift), KHÔNG phụ thuộc mạng ⇒ không mạng vẫn finalize thành công. ⚠ Xác nhận: state finalize-error do đâu (ghi DB local lỗi = hiếm) — kịch bản lỗi thực tế là gì (đĩa đầy? khoá DB?)? cloud_off/"cloud" là mock ẩn dụ, KHÔNG phải sync mạng.

---

## 7. Persistence (DB round-trip)

### SC-STUDYRESULT-60 — Ghi `study_sessions` khi finalize
Nguồn: schema `study_sessions` · D-010/BR-5
Then: sau finalize thành công, `study_sessions` +1 dòng: `mode`∈{due_review,new_learn}, `deck_id`=deck đã học, `started_at` (ngày = bucket `daily_activity`), `duration_minutes`, `words_studied`. Luyện tập KHÔNG ghi (D-007).

### SC-STUDYRESULT-61 — Cộng dồn `daily_activity` (D-010)
Nguồn: schema `daily_activity` · D-010/BR-1
Then: `daily_activity`(day=hôm nay) `minutes += duration_minutes`, `words += words_studied`. Nhiều phiên trong ngày cộng dồn cùng một dòng `day`.

### SC-STUDYRESULT-62 — SRS đã đóng băng khi vào màn (không đổi ở result)
Nguồn: schema `srs_state` · D-002/D-003/D-004/D-005
Then: `srs_state` của các thẻ đã cập nhật TRONG phiên (trước màn result); ở màn result, các action hiển thị/close KHÔNG đổi thêm `srs_state`. (review-wrong/continue mở phiên MỚI mới đổi tiếp.)

### SC-STUDYRESULT-63 — `review_logs` của phiên (dueReview)
Nguồn: schema `review_logs` · D-003/D-004
Then: phiên dueReview đã ghi `review_logs` (grade pass/fail) cho mỗi lần chấm.
⚠ **LỖ HỔNG SCHEMA (chưa chốt):** `review_logs` chỉ có cột `id, card_id, grade, reviewed_at`
— KHÔNG có `session_id` hay cột nối phiên. Vì vậy khái niệm "log **của phiên**" KHÔNG truy được
trực tiếp từ schema; không thể `WHERE session_id=…`. % correct ở stat-1 (pass/(pass+fail)) do đó
KHÔNG thể assert "khớp số dòng log của phiên" cho tới khi chốt nguồn: bộ đếm in-memory trong
phiên, hay lọc `review_logs` theo khoảng `reviewed_at ∈ [started_at, finalize]`? → xem
Open-question 5b. Đánh dấu blocked. ⚠ newLearn: xác nhận có ghi log không (Open-question 4).

### SC-STUDYRESULT-64 — Kill & mở lại app sau finalize
Then: nếu finalize đã thành công trước khi kill → mở lại, `study_sessions`/`daily_activity` còn dòng; Today (dashboard) phản ánh phút/từ/streak đã cộng. Nếu kill khi đang finalizing (chưa ghi) → phiên KHÔNG được tính (không dòng). ⚠ Xác nhận hành vi khi kill giữa chừng finalize (atomic?).

---

## 8. Định dạng & i18n

### SC-STUDYRESULT-70 — Chuỗi từ ARB (mọi state)
Then: mọi tiêu đề/phụ đề/nhãn nút ("Results", "Keep studying", "Back to library", "Later",
"Review N cards", "Retry", "Not now"…) render từ ARB, KHÔNG copy chuỗi mock kit.

### SC-STUDYRESULT-71 — Số & phần trăm theo locale
Then: "% correct" và số thẻ/phút định dạng theo locale (vd dấu phân tách); phần trăm dùng ký hiệu locale.

### SC-STUDYRESULT-72 — Plural "cards" / "day streak" / "Review N cards"
Then: 1 thẻ ⇒ dạng số ít, N thẻ ⇒ số nhiều (ARB plural, không nối chuỗi); "day streak" 1 vs N; "Review N cards" theo N.

### SC-STUDYRESULT-73 — Số lớn / biên hiển thị
Then: cards/min/streak số lớn (vd 9999) không tràn card 109px; "X/Y phút" khi X>Y (goal vượt) hiển thị hợp lý (goal-met, bar clamp 100%).

### SC-STUDYRESULT-74 — Text dài (locale dài) + CJK
Given: locale có nhãn dài (vd tiếng Đức) hoặc CJK (Hàn/Nhật).
Then: appbar "Results" + nhãn nút + tiêu đề wrap/ellipsis theo maxw (280/220), KHÔNG tràn ngang; CJK render đúng glyph (không tofu).

### SC-STUDYRESULT-75 — Tên deck/số trong phụ đề CJK
Then: nếu phụ đề chèn tên deck (nếu có) hoặc số, glyph CJK đúng, không cắt sai. ⚠ Xác nhận: phụ đề có chèn tên deck không (spec chỉ show số thẻ).

---

## 9. Dark mode

### SC-STUDYRESULT-80 — Mọi state ở dark
Then: cả 7 state render đúng ở light + dark (token remap `--memox-*`, không hardcode);
icon-tile nền soft (accent/success/warning/error-soft) + on-*-soft contrast đạt; goal card
primary-soft + on-primary-soft đọc được; nút primary/ghost đúng token.

---

## 10. Responsive

### SC-STUDYRESULT-81 — 320px → tablet + xoay
Then: ở 320px, grid 3 stat card + goal card + nút không overflow (co giãn); nội dung dài
cuộn được (body layout_hint:scroll, pad-bottom 96); xoay ngang cuộn được; safe-area/notch OK;
finalize-error căn giữa vẫn cân ở màn cao/thấp.

---

## 11. A11y

### SC-STUDYRESULT-82 — Semantics & thứ tự đọc
Then: `close` có semantic label (ARB) + hit-area ≥48 (DOM 48x48); mỗi nút (continue/library/
later/review-wrong/finalize-retry/finalize-later) có label đọc được; 3 stat đọc thành câu có
nghĩa ("N thẻ", "X% đúng", "M phút") không đọc rời số + đơn vị; goal/streak đọc thành câu; thứ
tự đọc: appbar → icon-tile/tiêu đề → stat → goal → nút; skeleton (finalizing/retry) không gây
đọc số rác; contrast on-*-soft đạt.

---

## 12. Concurrency & edge thời gian

### SC-STUDYRESULT-90 — Double-tap nút chính
Then: chạm nhanh 2 lần `continue`/`review-wrong`/`finalize-retry` → chỉ 1 hành động (một push
phiên / một lần retry), KHÔNG mở 2 màn / KHÔNG ghi 2 dòng `study_sessions`.

### SC-STUDYRESULT-91 — Bấm close/back khi đang finalizing
Then: đóng khi finalize chưa xong → ⚠ Xác nhận: huỷ finalize (phiên không tính) hay chờ xong
rồi mới pop? Assert: không ghi `study_sessions`/`daily_activity` **hai lần**, không crash.

### SC-STUDYRESULT-92 — Đổi ngày lúc nửa đêm khi đang ở result
Nguồn: D-021/BR-3 · engagement UC-1
Given: phiên xong lúc 23:59, finalize đúng lúc qua 00:00.
Then: ⚠ Xác nhận: `daily_activity` cộng vào **ngày bắt đầu phiên** (`started_at` day, schema:
"its calendar day is the daily_activity bucket") hay ngày finalize? Streak "+1" ở goal-met dựa
ngày nào? (engagement: chưa có job chốt-ngày). Assert theo schema: bucket = `started_at` day.

### SC-STUDYRESULT-93 — finalize idempotent (retry không nhân đôi)
Nguồn: SC-STUDYRESULT-52/53
Then: nhiều lần Retry cho cùng một phiên chỉ tạo **một** dòng `study_sessions` và cộng
`daily_activity` **một** lần (không nhân đôi phút/từ). ⚠ Xác nhận cơ chế chống ghi trùng
(session id ổn định / upsert).

---

## Open questions (⚠ cần chốt spec trước khi viết test — KHÔNG bịa)

1. **Đích + cơ chế điều hướng các nút** (`close`, `continue`, `library`, `later`,
   `review-wrong`, `finalize-later`): navigation-flow/D-029 chưa nhắc study-result → đóng về đâu
   (deck-detail/Library/Today)? `continue` = chạy lại phiên (D-029, chỉ DueReview) hay phiên
   mới? **Cơ chế push vs replace sang study-session** cho continue/review-wrong CHƯA có nguồn
   (D-029 chỉ nói "hiện học lại đúng mode", không nói study-result push study-session) — không
   assert như Then (xem SC-34). Back-stack sau khi mở phiên mới (back quay lại study-result hay
   bỏ qua)? `review-wrong` chạy lại đúng N thẻ sai (nguồn danh sách từ đâu) hay toàn phiên?
2. **Ngưỡng many-wrong**: số/% thẻ sai để rơi vào state `many-wrong` là bao nhiêu? (không có
   trong D-xxx/business).
3. **Điều kiện phân nhánh state (precedence)**: thứ tự ưu tiên khi vừa goal-met vừa many-wrong
   (hoặc goal-missed + many-wrong)? Một phiên rơi vào state nào khi nhiều điều kiện đúng?
   → SC-STUDYRESULT-46 là scenario đóng-vai-chốt (blocked-on-Q3): buộc chốt precedence trước
   khi viết test, chỉ assert bất biến mutual-exclusion.
4. **Nguồn % correct & "N thẻ sai" cho newLearn**: schema chỉ nói `review_logs` ghi mỗi lần
   GradeCard của **DueReview**. NewLearn (5 chặng game) tính % đúng và đếm thẻ sai từ đâu? có
   ghi log không?
5b. **`review_logs` không có `session_id` → không truy được "log-per-session"**: cột của
   `review_logs` chỉ gồm `id, card_id, grade, reviewed_at` (schema-contract) — KHÔNG có khoá nối
   phiên. Vậy % correct/"N thẻ sai" **của một phiên** (stat-1 SC-15/63, phụ đề many-wrong SC-04)
   lấy từ đâu: (a) bộ đếm in-memory giữ trong phiên study-session rồi truyền qua result, hay
   (b) lọc `review_logs WHERE reviewed_at ∈ [session.started_at, finalize_at]`? Cách (b) rủi ro
   khi chạy nhiều deck/nhiều phiên chồng lấn thời gian. Chốt nguồn trước khi viết assertion
   "khớp log của phiên".
5. **Đơn vị thời lượng — XUNG ĐỘT NGUỒN D-010 ↔ schema (chốt canonical trước khi test)**:
   D-010 (decision-table) nói `DailyActivity` cộng **GIÂY** + số từ; schema-contract nói
   `study_sessions.duration_minutes` / `daily_activity.minutes` là INTEGER **PHÚT**. Hai nguồn
   được trích mâu thuẫn về đơn vị lưu. Thêm nữa kit hiển thị "6:30" (phút:giây) trong khi cột
   là phút tròn. Cần chốt: (a) đơn vị canonical lưu DB = giây hay phút? (b) stat "min" hiển thị
   phút:giây hay phút tròn, nguồn giây lấy từ đâu nếu cột chỉ có phút? Mọi assertion "phút"
   trong file này (SC-16/60/61/92) tạm bám schema và ĐÁNH DẤU blocked-on-Q5.
6. **Streak "+1 today" realtime**: goal-met hiện "+1" ngay tại result, nhưng engagement nói
   "chưa có job chốt-ngày — tính trực tiếp từ lịch sử" và reset ở **nửa đêm**. Streak hiển thị
   ở result là dự đoán realtime hay giá trị đã chốt? có nguy cơ lệch khi chưa qua nửa đêm?
7. **"còn N phút/từ" (goal-missed)**: tính theo phút, theo từ, hay chỉ số gần đạt nhất?
8. **Bản chất lỗi finalize**: local-first (ghi Drift) thì `finalize-error`/`cloud_off`/"cloud"
   ứng với lỗi thực nào (đĩa đầy? DB lock?)? Ghi có atomic không (partial write khi lỗi)?
9. **Bấm close/back khi đang finalizing/retry**: huỷ (phiên không tính) hay chờ xong? Kill giữa
   chừng finalize → phiên có được tính không?
10. **`finalize-later` ("Not now")**: bỏ qua finalize ⇒ phiên mất vĩnh viễn hay xếp hàng thử
    lại lần sau? có ghi phần nào không?
11. **Chống ghi trùng khi Retry**: cơ chế idempotent (session id ổn định / upsert `daily_activity`)?
12. **study-result có tái dùng cho luyện tập không**: theo BR-5 chỉ due/new finalize — cần xác
    nhận game/player có màn tổng kết khác (không phải screen này).
13. **Phụ đề có chèn tên deck không** (cho i18n/CJK) hay chỉ số thẻ?
