# Kịch bản — Reminders (Nhắc học) · screen `reminder`

Nguồn: `docs/contracts/reminder.md` [off · on · time-picker] ·
DOM `specs/reminder.md` · **KHÔNG có D-xxx trực tiếp** cho `reminder` (D-012 Premium = HOÃN, không liên quan) ·
BR `business/settings/settings.md` [US-3, BR-4] (dòng 9: Trạng thái **Implemented** — NotificationService, timezone) + `business/navigation/navigation-flow.md` (dòng 25: route `/settings/reminder`, *"lên lịch OS hoặc … hoãn (gated)"*) — **hai nguồn xung đột về OS notification, xem Open questions #15** ·
DB `settings` (k/v): `reminder.hour` · `reminder.minute` · `reminder.weekdays` (JSON int set; **rỗng = tắt**).

> Số/tên trong kit là MOCK ("13:00", "REMINDER TIME", các thứ "Mon..Sun", giá trị cuộn "11..15"/"00..45") —
> assert **định dạng & nguồn** (đọc từ `settings`, chuỗi từ ARB), KHÔNG assert giá trị mock.
> Chuỗi lấy từ ARB, không copy kit. State phải có thật trong contract (`off`/`on`/`time-picker`).

> ⚠ **Cảnh báo phạm vi v1 — NGUỒN MÂU THUẪN (chưa hoà giải):** `business/navigation/navigation-flow.md` (dòng 25)
> ghi route `reminder` = *"lên lịch OS hoặc … hoãn (gated)"* ⇒ ngụ ý hành vi bắn thông báo OS **có thể chưa build**.
> NHƯNG `business/settings/settings.md` (dòng 9) ghi Trạng thái = **Implemented** và nói rõ *"nhắc học lên lịch thông báo OS
> qua `NotificationService` (flutter_local_notifications + timezone), 1 thông báo/ngày-trong-tuần đã chọn"* ⇒ **ĐÃ build**.
> Hai nguồn nghiệp vụ **xung đột** (navigation-flow "gated" vs settings.md "Implemented"). Xung đột này **để ngỏ** ở
> Open questions #15 — KHÔNG tự chọn bên "gated". Điểm chắc chắn ở mọi trạng thái: **UI + persistence vào `settings` phải chạy**;
> assert **ghi settings đúng**. Với "notification OS nổ thật": đánh cờ ⚠ và assert theo nhánh spec được chốt, KHÔNG tự khẳng định.
> (`s07-reminder.md` KHÔNG chứa chữ "gated"/"notification"/"NotificationService" — grep = 0; không trích s07 cho phần này.)

## DoE — reminder (12 chiều)

| # | Chiều | TT | Scenario / N/A |
|---|---|---|---|
| 1 | States (3) | ✅ | SC-REMINDER-01..03 |
| 2 | Elements (7 tương tác + 5 hiển thị) | ✅ | SC-REMINDER-10..24 (icon-tile token base-state → SC-11; handle-bar + ':' separator + sheet `r:28`/`shadow` + title token → SC-03) |
| 3 | Nav vào/ra | ✅ | SC-REMINDER-30..35 |
| 4 | Nhập liệu & validation | ✅ / **một phần N/A** | SC-REMINDER-40..46 (không có free-text field; input = picker cuộn giờ/phút + chip thứ ⇒ validate biên/tập rỗng thay cho rỗng/dài/CJK/trùng) |
| 5 | Lượng dữ liệu | ✅ | SC-REMINDER-50..54 (số thứ được chọn: 0/1/7 ; biên giờ/phút) |
| 6 | Async & lỗi | ⚠ **yếu — flagged** | SC-REMINDER-60..63 (contract KHÔNG có state `loading`/`error`; hình dạng surface lỗi + có/không retry = Open questions #7; hành vi OS notification phụ thuộc nguồn xung đột #15) |
| 7 | Persistence (DB round-trip) | ✅ | SC-REMINDER-70..75 |
| 8 | Định dạng & i18n | ✅ | SC-REMINDER-80..84 |
| 9 | Dark mode | ✅ | SC-REMINDER-85 |
| 10 | Responsive | ✅ | SC-REMINDER-86 |
| 11 | A11y | ✅ | SC-REMINDER-87 |
| 12 | Concurrency & edge thời gian | ✅ | SC-REMINDER-90..94 |

Element inventory (từ DOM spec — mỗi cái ≥1 scenario ở mục 2):
`reminder/back` (icon-button arrow_back) · `reminder/toggle` (row Study reminders — icon-tile + tiêu đề + phụ đề) ·
`reminder/toggle-switch` (switch bật/tắt) · `reminder/time` (card giờ: eyebrow "REMINDER TIME" + số giờ lớn) ·
`reminder/time-edit` (icon-button schedule → mở picker) · `reminder/days` (nhãn "REPEAT" + 7 chip thứ) ·
`reminder/day-0..6` (7 chip Mon..Sun, toggle chọn/bỏ) · `reminder/picker-scrim` (overlay nền) ·
`reminder/picker-sheet` (bottom sheet) · handle-bar · tiêu đề "Pick reminder time" · cột giờ (scroll) ·
cột phút (scroll) · dấu ":" · `reminder/picker-done` (nút "Done" đóng picker & áp giờ).

---

## 1. States

### SC-REMINDER-01 — off (nhắc học tắt)
Nguồn: contract[off] · spec "off" diff (switch → `surface-sunken`/thumb `text-tertiary`; card `reminder/time` op:0.5; `reminder/days` op:0.5; chip → `bg:surface`/`text-secondary`) · BR-4
Tiền điều kiện (Given):
  - DB `settings`: `reminder.weekdays` = `[]` (rỗng ⇒ **tắt** theo schema-contract). (biến thể: 3 khóa reminder chưa từng ghi)
Thao tác (When):
  1. Mở Settings → chạm "Nhắc học" → push `reminder`
Kỳ vọng (Then):
  - UI: appbar "Reminders" (ARB) + back · card toggle "Study reminders" với switch **off** (thumb trái, màu `text-tertiary`/`surface-sunken`) ·
    card giờ (`reminder/time`) hiển thị **mờ** (op ~0.5) · khối `reminder/days` mờ (op ~0.5); 7 chip ở trạng thái không-chọn (`bg:surface`, `text-secondary`) ·
    KHÔNG mở picker.
  - DB: không ghi gì khi chỉ mở màn (đọc thuần).
  - Card giờ + chip khi off phải là **disabled thật** (không nhận tap), không chỉ dimmed — theo `s07-reminder.md` dòng 58:
    *"Disabled = a real disabled state … the control must not fire when disabled"* (đây là chỉ dẫn build, không phải BR/spec kit;
    trích chính xác dòng 58, không quy về "a11y note" chung).

### SC-REMINDER-02 — on (nhắc học bật)
Nguồn: contract[on] · spec base state "on" · BR-4
Given:
  - DB `settings`: `reminder.weekdays` = tập không rỗng (vd một số thứ); `reminder.hour`/`reminder.minute` đã có giá trị.
When:
  1. Mở `reminder`
Then:
  - UI: switch **on** (thumb phải, `bg:primary`) · card giờ `reminder/time` **rõ** (không mờ), hiện eyebrow "REMINDER TIME" (ARB) + số giờ lớn định dạng theo giờ đã lưu ·
    khối "REPEAT" rõ; các chip **được chọn** hiển thị `bg:primary-soft`/`on-primary-soft`, chip không chọn `bg:surface`/`text-secondary`.
  - DB: không ghi khi chỉ mở (đọc thuần); giá trị hiển thị **đọc từ** `reminder.hour`/`minute`/`weekdays`.

### SC-REMINDER-03 — time-picker (đang chọn giờ)
Nguồn: contract[time-picker] · spec "time picker" diff (thêm `reminder/picker-scrim` z:60 `bg:overlay` + `reminder/picker-sheet` bottom `r:28` — handle-bar, tiêu đề "Pick reminder time", cột giờ scroll, dấu ":", cột phút scroll, nút `reminder/picker-done` "Done")
Given: đang ở `reminder` state on
When:
  1. Chạm `reminder/time-edit` (icon schedule) HOẶC chạm vùng số giờ (⚠ xác nhận vùng nào mở picker — xem SC-REMINDER-14/16)
Then:
  - UI: overlay `reminder/picker-scrim` phủ toàn màn (`bg:overlay`, z:60) + bottom sheet `reminder/picker-sheet` trượt lên.
  - **Sheet chrome (token, spec):** sheet nền `surface`, bo góc **`r:28`** + đổ bóng **`shadow:-2/14`** (spec dòng 587-588).
  - **Handle-bar (assert hiện diện + token):** thanh kéo trên đỉnh sheet — `bg:divider`, `r:999`, kích thước 40x4 (spec dòng ~591-597). Hiển thị làm affordance vuốt-đóng.
  - **Tiêu đề "Pick reminder time" (ARB):** token `font:13/700 color:text-tertiary tracking:0.5` (spec dòng ~599-603); chuỗi lấy từ ARB, không copy kit.
  - cột **giờ** cuộn được (giá trị đang chọn nổi bật `font:17/800 color:primary`, còn lại `font:17/500 color:text-tertiary`).
  - **Dấu ":" (assert node + token):** ký tự phân cách giữa hai cột — `font:24/800 color:text` (spec dòng ~663-665). Là node DOM riêng, phải hiển thị.
  - cột **phút** cuộn được (giá trị chọn `color:primary`) · nút "Done" (`reminder/picker-done`, `bg:primary`).
  - DB: **chưa** ghi khi mới mở picker (giờ chỉ áp khi bấm Done — xem SC-REMINDER-23/72).
  - ⚠ Xác nhận: bước phút là mọi phút 0..59 hay chỉ mốc 00/15/30/45 (kit MOCK chỉ liệt kê 4 mốc)? — xem Open questions.

---

## 2. Elements (mỗi phần tử ≥1 scenario)

### SC-REMINDER-10 — Nút back (`reminder/back`)
Nguồn: spec `reminder/back` (icon-button arrow_back, mx:?)
When: chạm back
Then: UI pop về màn trước (`settings`), giữ vị trí cuộn của Settings. Nút có semantic label "Back" (ARB), hit-area ≥48. DB: không ghi.

### SC-REMINDER-11 — Row toggle "Study reminders" (`reminder/toggle`)
Nguồn: spec `reminder/toggle` — icon-tile (spec dòng 109-121: `bg:warning-soft r:16` + `icon:notifications color:on-warning-soft`) + tiêu đề "Study reminders" + phụ đề "Remind you to review every day"
When: hiển thị (state on, base)
Then:
  - **Token (base state, assert rõ):** icon-tile nền **`warning-soft`** (`r:16`); glyph `notifications` màu **`on-warning-soft`** (spec dòng 115/121).
    Đây là assertion token ở trạng thái base — độ tương phản `on-warning-soft` ở dark chỉ được kiểm ở SC-REMINDER-85, ở đây chốt token nền/icon ở light.
  - tiêu đề "Study reminders" (ARB) + phụ đề "Remind you to review every day" (ARB).
⚠ Xác nhận: chạm vào cả row có toggle switch không, hay chỉ chạm đúng switch? (kit không nêu onClick cho row).

### SC-REMINDER-12 — Switch bật nhắc học (`reminder/toggle-switch`, off→on)
Nguồn: spec `reminder/toggle-switch` (switch, mx:?) · schema `reminder.weekdays` rỗng=tắt · BR-4
Given: DB `reminder.weekdays` = `[]` (state off)
When: gạt switch sang **on**
Then:
  - UI: chuyển sang state on (card giờ + REPEAT hết mờ; switch thumb phải `bg:primary`).
  - DB: `reminder.weekdays` ghi thành tập **không rỗng** (⚠ Xác nhận: bật thì set mặc định tập thứ nào? tất cả 7? hay giữ tập trước đó? — Open questions #3).
  - ⚠ Xác nhận: bật lần đầu có xin **quyền thông báo OS** (BR-4) không? — nguồn xung đột (navigation-flow "gated" vs settings.md "Implemented",
    xem banner phạm vi + Open questions #15). Assert tối thiểu: **ghi settings đúng**; không tự khẳng định notification build hay chưa.

### SC-REMINDER-13 — Switch tắt nhắc học (`reminder/toggle-switch`, on→off)
Nguồn: spec `reminder/toggle-switch` · schema `reminder.weekdays` rỗng=tắt
Given: state on (weekdays không rỗng)
When: gạt switch sang **off**
Then:
  - UI: về state off (card giờ + chip mờ).
  - DB: `reminder.weekdays` ghi thành `[]` (rỗng ⇒ tắt).
  - ⚠ Xác nhận: tắt có **giữ lại** `reminder.hour`/`minute` để bật lại dùng tiếp không? (khả năng cao có — chỉ weekdays biểu diễn on/off). — Open questions #3.

### SC-REMINDER-14 — Card giờ (`reminder/time`) — hiển thị
Nguồn: spec `reminder/time` (eyebrow "REMINDER TIME" + số giờ font 38/800)
Given: `reminder.hour`=H, `reminder.minute`=M
Then: eyebrow "REMINDER TIME" (ARB) + số giờ hiển thị **định dạng theo `reminder.hour`/`minute`** và theo locale (24h/12h — xem SC-REMINDER-80); KHÔNG assert giá trị mock "13:00".

### SC-REMINDER-15 — Card giờ khi off (mờ / disabled)
Nguồn: spec "off" diff (card `reminder/time` `op:0.5`)
Given: state off
When: chạm card giờ / vùng số giờ
Then: card hiển thị mờ; tap **không** mở picker (disabled thật) — theo `s07-reminder.md` dòng 58 *"Disabled = a real disabled state … must not fire when disabled"* (chỉ dẫn build, không chỉ dimmed).

### SC-REMINDER-16 — Nút mở picker (`reminder/time-edit`)
Nguồn: spec `reminder/time-edit` (icon-button schedule, mx:?)
Given: state on
When: chạm icon schedule
Then: UI mở state time-picker (scrim + sheet). Nút có label "Edit reminder time"/tương đương (ARB), hit-area ≥48. DB: chưa ghi.

### SC-REMINDER-17 — Nhãn REPEAT + khối ngày (`reminder/days`)
Nguồn: spec `reminder/days` (nhãn "REPEAT" + 7 chip)
Then: hiển thị nhãn "REPEAT" (ARB) + 7 chip thứ theo thứ tự Mon..Sun (⚠ Xác nhận thứ tự đầu tuần theo locale: Mon-first hay Sun-first? — Open questions #5). Chip nhãn thứ lấy từ ARB, không copy "Mon".

### SC-REMINDER-18 — Chip thứ: chọn (day off→on)
Nguồn: spec `reminder/day-0..6` (chip, mx:?) · schema `reminder.weekdays` JSON int set
Given: state on; `reminder.weekdays` không chứa thứ X
When: chạm chip thứ X
Then:
  - UI: chip X chuyển sang trạng thái chọn (`bg:primary-soft`/`on-primary-soft`).
  - DB: `reminder.weekdays` thêm chỉ số của X (assert đúng khóa `reminder.weekdays`, giá trị là JSON int set chứa X). ⚠ Xác nhận: index quy ước (0=Mon? 1=Mon? theo ISO 1..7?) — Open questions #4.

### SC-REMINDER-19 — Chip thứ: bỏ chọn (day on→off)
Nguồn: spec `reminder/day-0..6`
Given: state on; `reminder.weekdays` chứa X (và còn ≥2 thứ)
When: chạm chip X đang chọn
Then: UI chip X về không-chọn (`bg:surface`/`text-secondary`); DB: `reminder.weekdays` bỏ X.

### SC-REMINDER-20 — Bỏ chọn thứ CUỐI cùng (weekdays → rỗng)
Nguồn: schema `reminder.weekdays` **rỗng = tắt**
Given: state on; `reminder.weekdays` = đúng 1 thứ X
When: chạm bỏ X
Then:
  - DB: `reminder.weekdays` = `[]`.
  - UI: ⚠ Xác nhận — bỏ hết thứ có tự động **tắt** nhắc (switch off, card mờ) không (vì rỗng=tắt)? hay cho phép on-nhưng-không-thứ (không hợp lệ)? — Open questions #6. Assert tối thiểu: DB rỗng.

### SC-REMINDER-21 — Cột giờ trong picker (cuộn chọn)
Nguồn: spec picker cột giờ (scroll, item nổi bật `color:primary`)
Given: state time-picker
When: cuộn cột giờ tới giá trị H'
Then: UI H' trở thành item nổi bật (`primary`), các item khác `text-tertiary`. DB: **chưa** ghi (chỉ áp khi Done).

### SC-REMINDER-22 — Cột phút trong picker (cuộn chọn)
Nguồn: spec picker cột phút (scroll)
Given: state time-picker
When: cuộn cột phút tới M'
Then: UI M' nổi bật. DB: chưa ghi. ⚠ Xác nhận bước phút (1 hay 15) — Open questions #2.

### SC-REMINDER-23 — Nút "Done" trong picker (`reminder/picker-done`)
Nguồn: spec `reminder/picker-done` (btn "Done", mx:?)
Given: state time-picker, đã cuộn tới giờ H':M'
When: chạm "Done"
Then:
  - UI: đóng sheet + scrim → về state on; card giờ hiển thị H':M' mới.
  - DB: ghi `reminder.hour`=H', `reminder.minute`=M' (assert đúng 2 khóa). ⚠ Hành vi "OS lên lịch lại theo giờ mới": nguồn xung đột
    (navigation-flow "gated" vs settings.md "Implemented" — Open questions #15). Assert **ghi settings đúng**; không tự khẳng định OS re-schedule.

### SC-REMINDER-24 — Đóng picker KHÔNG chọn (scrim / back / swipe-down)
Nguồn: spec `reminder/picker-scrim` (overlay) — bottom-sheet chuẩn
Given: state time-picker
When: chạm scrim ngoài sheet HOẶC vuốt sheet xuống HOẶC back hệ thống
Then: UI đóng picker về state on **không áp** giờ mới; DB: `reminder.hour`/`minute` giữ nguyên.
⚠ Xác nhận: sheet có nút Cancel/close riêng không (kit chỉ có "Done"); dismiss = huỷ (không lưu) là mặc định bottom-sheet — cần chốt.

---

## 3. Điều hướng vào/ra

### SC-REMINDER-30 — Vào từ Settings
Nguồn: navigation-flow route `reminder` = `/settings/reminder`, `push`, "mở từ settings"
Given: đang ở `settings`
When: chạm tile "Nhắc học"
Then: push `reminder`; back quay lại `settings` đúng vị trí.

### SC-REMINDER-31 — Deep-link `/settings/reminder`
Nguồn: navigation-flow path `/settings/reminder`
When: điều hướng trực tiếp tới path
Then: mở `reminder` (state theo DB: off nếu weekdays rỗng, on nếu không). ⚠ Xác nhận: deep-link có dựng lại back-stack qua `settings` không (để back về đúng chỗ)?

### SC-REMINDER-32 — Back từ appbar
Nguồn: spec `reminder/back`
When: chạm back trên appbar
Then: pop về `settings`. (trùng SC-REMINDER-10 — ở đây là góc điều hướng)

### SC-REMINDER-33 — Back hệ thống (Android) tại `reminder`
When: nhấn back hệ thống khi đang ở `reminder` (không có picker mở)
Then: pop về `settings`.

### SC-REMINDER-34 — Back hệ thống khi picker đang mở
Given: state time-picker
When: nhấn back hệ thống
Then: **đóng picker trước** (về state on), KHÔNG pop khỏi màn `reminder` (một cấp back = một overlay). Back lần nữa mới pop về settings.

### SC-REMINDER-35 — Giữ trạng thái khi rời & quay lại
Given: bật switch + chọn vài thứ → rời sang màn khác → quay lại `reminder`
Then: UI phản ánh đúng state đã lưu (đọc lại từ `settings`), không mất lựa chọn.

---

## 4. Nhập liệu & validation

> Màn `reminder` **KHÔNG có free-text field** ⇒ các nhánh rỗng/khoảng-trắng/quá-dài/CJK/emoji/trùng (D-020)/sai-định-dạng
> **N/A** (không có ô nhập chữ). Input duy nhất = **picker cuộn (giờ/phút)** + **chip thứ**. Validation ở đây là biên số + tập thứ.

### SC-REMINDER-40 — Giờ biên (0 và 23)
Nguồn: `reminder.hour` INTEGER
When: cuộn cột giờ tới min (0) rồi max (23) → Done
Then: DB `reminder.hour` = 0 / 23 hợp lệ; card giờ hiển thị đúng (00:MM / 23:MM theo format). ⚠ Xác nhận cột giờ 24h (0..23) hay 12h+AM/PM (kit MOCK "11..15" mơ hồ) — Open questions #2.

### SC-REMINDER-41 — Phút biên (0 và 59)
Nguồn: `reminder.minute` INTEGER
When: cuộn phút tới 0 và (max) → Done
Then: DB `reminder.minute` = 0 / max hợp lệ. ⚠ max = 59 (bước 1) hay 45 (bước 15)? — Open questions #2.

### SC-REMINDER-42 — Giá trị giờ/phút không hợp lệ không thể nhập
Nguồn: picker cuộn = tập rời rạc
Then: picker chỉ cho chọn trong danh sách hợp lệ (không có ô gõ số tự do) ⇒ không tồn tại nhánh "sai định dạng"/"quá dài" — **N/A theo thiết kế** (assert: không có TextField).

### SC-REMINDER-43 — Rỗng-tương-đương: bật nhắc nhưng chưa chọn thứ
Nguồn: schema `reminder.weekdays` rỗng = tắt
Then: xem SC-REMINDER-20 — trạng thái weekdays rỗng là "tắt", KHÔNG phải lỗi. ⚠ Xác nhận có chặn "on mà 0 thứ" không.

### SC-REMINDER-44 — Chọn trùng thứ (idempotent)
When: chạm nhanh 1 chip 2 lần (chọn rồi bỏ)
Then: DB `reminder.weekdays` trở về trạng thái ban đầu (không nhân đôi index; set không có phần tử trùng). (Assert JSON là **set**, không phải list có lặp.)

### SC-REMINDER-45 — Chọn toàn bộ 7 thứ
When: chọn cả 7 chip
Then: DB `reminder.weekdays` chứa đủ 7 index (assert độ dài 7, không trùng). UI 7 chip đều `bg:primary-soft`.

### SC-REMINDER-46 — Trim/định dạng lưu weekdays
Nguồn: schema `reminder.weekdays` = "JSON int set"
Then: giá trị lưu là JSON hợp lệ (mảng số nguyên, không trùng, ⚠ thứ tự chuẩn hoá? — Open questions #4); đọc lại parse đúng.

---

## 5. Lượng dữ liệu

### SC-REMINDER-50 — 0 thứ (weekdays rỗng) → off
Then: state off; card giờ + chip mờ. (khớp SC-REMINDER-01)

### SC-REMINDER-51 — 1 thứ
Then: state on; đúng 1 chip chọn; DB set 1 phần tử.

### SC-REMINDER-52 — nhiều thứ (vd 5)
Then: 5 chip chọn; DB set 5 phần tử.

### SC-REMINDER-53 — đủ 7 thứ (biên trên)
Then: 7 chip chọn (khớp SC-REMINDER-45).

### SC-REMINDER-54 — Biên giờ/phút (00:00 và giờ lớn nhất)
Then: card giờ hiển thị đúng ở biên (00:00, 23:59 hoặc 23:45 tuỳ bước) không vỡ layout, số không tràn card (font 38 lớn).

---

## 6. Async & lỗi

### SC-REMINDER-60 — Đọc settings (loading → resolved)
Nguồn: s07 "render AsyncValue.when"
Given: provider reminder chưa resolve
Then: ⚠ contract `reminder` KHÔNG có state `loading`/`error` trong kit (chỉ off/on/time-picker). Assert: trong lúc đọc `settings`, màn không crash; khi resolve hiển thị off/on đúng DB. ⚠ Xác nhận: hiện gì trong khi loading (skeleton? off tạm?) — Open questions #7.

### SC-REMINDER-61 — Ghi settings thất bại
Nguồn: `s07-reminder.md` dòng 43 — *"the error branch shows a localized user surface (inline/empty-error per the kit) AND the cause is logged/reported. Errors never swallowed."*
Given: ghi `reminder.*` vào `settings` lỗi (giả lập persistence fail)
Then: UI hiện thông báo lỗi **cục bộ (local persistence)** (ARB — không dùng từ "cloud/offline sync", theo s07 v1-scope dòng 45); lỗi được **log/report**, không nuốt. DB: giá trị cũ không đổi khi ghi hỏng.
  - ⚠ contract `reminder` KHÔNG có state `error` ⇒ hình dạng surface lỗi (snackbar? inline? empty-error?) cần chốt — Open questions #7.
  - ⚠ **"cho retry" KHÔNG có nguồn**: s07 dòng 43 chỉ nói "localized surface + logged", KHÔNG nói retry. Có nút/cử chỉ retry hay không ⇒ Open questions #7 (không assert cho tới khi spec chốt).

### SC-REMINDER-62 — Local-first (không mạng)
Then: toàn bộ đọc/ghi `reminder.*` chạy trên `settings` local, không phụ thuộc mạng (v1 local-first).

### SC-REMINDER-63 — Quyền thông báo OS bị từ chối (BR-4)
Nguồn: BR-4 "nhắc học phụ thuộc quyền thông báo + tối ưu pin OS"
Given: bật switch nhưng OS **từ chối** quyền notification
Then: ⚠ Xác nhận: UI hiển thị gì (banner "cần cấp quyền"? mở system settings?) — không có trong kit ⇒ Open questions #1. Assert tối thiểu: settings vẫn ghi được.
  ⚠ Hành vi OS notification khi thiếu quyền: nguồn xung đột navigation-flow "gated" vs settings.md "Implemented" (Open questions #15) — không tự khẳng định.

---

## 7. Persistence (DB round-trip)

### SC-REMINDER-70 — Bật nhắc → ghi `reminder.weekdays`
Given: state off
When: gạt switch on (+ chọn thứ)
Then: DB `settings` có `reminder.weekdays` = tập không rỗng (assert đúng khóa + là JSON int set).

### SC-REMINDER-71 — Tắt nhắc → `reminder.weekdays` = `[]`
Then: DB `reminder.weekdays` = rỗng.

### SC-REMINDER-72 — Chọn giờ (Done) → ghi `reminder.hour` + `reminder.minute`
When: picker → cuộn H':M' → Done
Then: DB `reminder.hour`=H' và `reminder.minute`=M' (assert **cả hai** khóa; giá trị INTEGER).

### SC-REMINDER-73 — Toggle chip → cập nhật `reminder.weekdays` từng bước
Then: mỗi lần chọn/bỏ 1 chip, `reminder.weekdays` được ghi lại phản ánh tập hiện tại (assert nội dung set khớp UI).

### SC-REMINDER-74 — Kill & mở lại app (round-trip đầy đủ)
Given: đặt giờ H:M + chọn tập thứ S, tắt app
When: mở lại app → vào `reminder`
Then: UI khôi phục đúng H:M + S + trạng thái on/off từ `settings` (không mất). DB 3 khóa còn nguyên.

### SC-REMINDER-75 — Không có cascade
Nguồn: schema `settings` standalone (không FK)
Then: thay đổi `reminder.*` KHÔNG động tới bảng khác (decks/cards/srs_state…); D-024 cascade **N/A** cho settings.

---

## 8. Định dạng & i18n

### SC-REMINDER-80 — Định dạng giờ theo locale (24h vs 12h)
Given: đổi locale/định dạng giờ hệ máy
Then: card giờ + picker hiển thị theo quy ước giờ của locale (24h "13:00" hoặc 12h "1:00 PM"); không hardcode "13:00". ⚠ Xác nhận: app theo định dạng OS hay luôn 24h — Open questions #8.

### SC-REMINDER-81 — Nhãn thứ theo locale (Mon/Thứ 2/月)
Given: locale vi/en/ja
Then: 7 chip hiển thị tên thứ theo locale (ARB/định dạng), CJK (ja "月火水…") render đúng glyph, không tofu; không copy "Mon".

### SC-REMINDER-82 — Đầu tuần theo locale
Then: thứ tự chip (Mon-first vs Sun-first) theo quy ước locale. ⚠ Open questions #5.

### SC-REMINDER-83 — Text dài (chuỗi ARB dài / eyebrow dịch dài)
Then: tiêu đề "Study reminders"/phụ đề/"REMINDER TIME"/"Pick reminder time" khi dịch dài → wrap/ellipsis, không tràn card, không đẩy switch.

### SC-REMINDER-84 — Plural / số nhiều (nếu copy có "N ngày")
Then: ⚠ Xác nhận: có chuỗi nào phụ thuộc plural (vd "nhắc N ngày/tuần") không? kit không nêu ⇒ nếu có phải dùng ARB plural. Open questions #9.

---

## 9. Dark mode

### SC-REMINDER-85 — Mọi state ở dark
Nguồn: wireframe có cột dark cho cả 3 state
Then: 3 state (off/on/time-picker) render đúng ở dark (token remap `--memox-*`, không hardcode màu); switch on `primary`, off `surface-sunken`; chip chọn `primary-soft`; scrim `overlay`; contrast on-primary-soft/on-warning-soft đạt.

---

## 10. Responsive

### SC-REMINDER-86 — 320px → tablet + xoay
Then: ở 320px không overflow — 7 chip **wrap** đúng (spec: `flex:row wrap gap:8`, đã xuống 2 hàng ở 390px) · card giờ số 38px không tràn · picker sheet chiếm đáy, cột giờ/phút cuộn được · xoay ngang: sheet + nội dung cuộn được, safe-area/notch OK · tablet: card không giãn quá rộng gây xấu (⚠ maxWidth?).

---

## 11. A11y

### SC-REMINDER-87 — Semantics & touch target
Nguồn: s07 §Accessibility
Then:
  - back / icon schedule / "Done" có label ARB (không đọc tên icon "arrow_back"/"schedule"); hit-area ≥48.
  - switch có semantic **switch** (đọc "Study reminders, on/off"), toggle bằng bàn phím/screen-reader.
  - 7 chip thứ: mỗi chip addressable, semantic **toggle/selected** (đọc "Mon, selected"); nhóm REPEAT đọc có nghĩa.
  - picker: cột giờ/phút đọc được giá trị đang chọn; "Done" là button.
  - khi off: card giờ/chip là **disabled thật** (screen-reader báo disabled), không kích hoạt — theo `s07-reminder.md` dòng 58
    *"Disabled = a real disabled state … the control must not fire when disabled"* (chỉ dẫn build; khớp SC-REMINDER-01/15).
  - thứ tự đọc: appbar → toggle → giờ → REPEAT → (picker khi mở).

---

## 12. Concurrency & edge thời gian

### SC-REMINDER-90 — Double-tap switch
When: gạt switch nhanh 2 lần (on→off→on)
Then: trạng thái cuối nhất quán với UI; DB `reminder.weekdays` khớp trạng thái cuối (không kẹt nửa chừng, không ghi 2 lần mâu thuẫn).

### SC-REMINDER-91 — Double-tap "Done" trong picker
When: chạm "Done" 2 lần nhanh
Then: picker đóng **một** lần; DB ghi `reminder.hour`/`minute` một lần (không double-write / không pop 2 lớp).

### SC-REMINDER-92 — Mở picker khi đang lưu (race)
When: bấm Done (đang ghi settings) rồi lập tức mở lại picker
Then: không mất/ghi đè sai; giá trị cuối cùng nhất quán với thao tác cuối (⚠ xác nhận có khoá tương tác khi đang ghi không).

### SC-REMINDER-93 — Đổi ngày lúc nửa đêm khi đang mở `reminder`
Nguồn: reminder theo lịch tuần, không theo streak
Then: đổi ngày (00:00) KHÔNG ảnh hưởng cài đặt reminder (weekdays/giờ giữ nguyên). D-021 streak-reset **N/A** cho màn này (reminder không phải activity). ⚠ Hành vi OS "bắn hôm sau" khi đã lên lịch: nguồn xung đột (Open questions #15) + ngoài phạm vi assert UI.

### SC-REMINDER-94 — Đổi giờ hệ thống / múi giờ
Nguồn: `business/settings/settings.md` dòng 9 nêu `NotificationService` dùng `timezone` (flutter_local_notifications + timezone)
Given: đổi timezone máy sau khi đặt giờ nhắc
Then: giá trị `reminder.hour`/`minute` **không đổi** (là giờ địa phương do user đặt); ⚠ Xác nhận hành vi lịch OS khi đổi TZ — nguồn xung đột về việc OS-schedule đã build hay chưa (Open questions #10 + #15).

---

## Open questions (⚠ cần chốt spec trước khi viết test — KHÔNG bịa)

1. **Quyền OS (BR-4)**: bật nhắc lần đầu có xin quyền notification? Khi bị từ chối / bị tối ưu pin — UI hiển thị gì (không có trong kit)? Có route "mở cài đặt hệ thống"?
2. **Bước & phạm vi picker**: cột giờ 24h (0..23) hay 12h + AM/PM? cột phút bước 1 (0..59) hay bước 15 (00/15/30/45 như kit MOCK)?
3. **Ngữ nghĩa bật/tắt switch**: bật thì set tập thứ mặc định nào (tất cả 7? tập trước đó?)? tắt có giữ `reminder.hour`/`minute`/tập thứ để bật lại không? (schema: rỗng weekdays = tắt.)
4. **Chỉ số weekday**: quy ước index trong `reminder.weekdays` (0=Mon? ISO 1..7? 0=Sun?) + có chuẩn hoá thứ tự khi lưu không?
5. **Đầu tuần**: thứ tự chip theo locale (Mon-first vs Sun-first) hay cố định?
6. **on-nhưng-0-thứ**: bỏ hết thứ khi đang on → tự tắt switch, hay giữ on nhưng vô hiệu? (rỗng=tắt gợi ý tự tắt.)
7. **Async surface + retry**: contract không có state `loading`/`error`. Trong lúc đọc settings hiển thị gì? Khi ghi settings lỗi surface lỗi kiểu gì (snackbar/inline) và ở đâu? **Có cơ chế retry không?** (s07 dòng 43 chỉ nói "localized surface + logged", KHÔNG nói retry — "cho retry" là suy diễn, phải chốt spec trước khi assert.)
8. **Định dạng giờ**: theo định dạng OS (12/24h) hay luôn 24h trong app?
9. **Plural**: có chuỗi phụ thuộc số nhiều nào không (kit không nêu)?
10. **Timezone/DST**: đổi TZ/DST sau khi đặt giờ — lịch OS bắn theo giờ tường nào? (phụ thuộc #15: OS-schedule đã build hay chưa.)
11. **Vùng mở picker**: chỉ icon `reminder/time-edit` mở picker, hay chạm cả vùng số giờ cũng mở?
12. **Dismiss picker**: đóng bằng scrim/swipe/back = **huỷ không lưu** (chỉ "Done" mới áp) — xác nhận đúng mặc định; có nút Cancel riêng không?
13. **Card giờ khi off**: disabled thật (không tap được) hay chỉ dimmed?
14. **`mx:?` mapping**: back/switch/time-edit/chip/picker-done đều `mx:?` (kit chưa map component chuẩn) — chốt component `Mx*` khi build (không ảnh hưởng scenario, ghi nhận để parity).
15. **⚠ NGUỒN NGHIỆP VỤ XUNG ĐỘT — OS notification đã build hay chưa?** `business/navigation/navigation-flow.md` (dòng 25) ghi route `reminder` = *"lên lịch OS hoặc … hoãn (gated)"* ⇒ hàm ý **chưa build / gated**. NHƯNG `business/settings/settings.md` (dòng 9) ghi Trạng thái = **Implemented** và mô tả *"nhắc học lên lịch thông báo OS qua `NotificationService` (flutter_local_notifications + timezone), 1 thông báo/ngày-trong-tuần đã chọn"* ⇒ **ĐÃ build**. Hai spec nghiệp vụ mâu thuẫn trực tiếp. Phải hỏi BA chốt: notification OS có nổ thật ở v1 hiện tại không? Trước khi chốt: mọi scenario chạm "OS bắn notification / OS re-schedule / OS xin quyền" chỉ assert **ghi settings đúng**, KHÔNG khẳng định OS behavior. (Chi phối SC-12/23/63/93/94 + banner phạm vi.)

> Các mục ⚠ ở trên là **danh sách phải hỏi BA/spec**, KHÔNG được đoán. Khi có câu trả lời → cập nhật scenario tương ứng
> + xoá cờ ⚠. Đây chính là "không bỏ sót": phần chưa rõ được **liệt kê ra**, không lờ đi.
