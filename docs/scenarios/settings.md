# Kịch bản — Settings (Cài đặt) · screen `settings`

Nguồn: `docs/contracts/settings.md` [loaded · group-expanded · value-picker] ·
DOM `specs/settings.md` · D-008, D-012, **D-018** (SC-SETTINGS-28, gap tile) · D-021 (`goal.*` — ngoài phạm vi settings hub, SC-93) ·
(D-023/D-025/D-026/D-028 gián tiếp qua các tile mở màn khác) ·
BR `business/settings/settings.md` (BR-1..BR-5, AC-1/AC-2; **Trạng thái = Implemented dòng 9 → Reminders/backup/goal/game ĐÃ CÓ**)
+ `business/personalization/personalization.md` (BR-1..BR-3; **Trạng thái = Implemented dòng 9 → Theme W13 mode+accent+font_scale ĐÃ CÓ**) ·
DB `settings` (k-v: theme.mode/accent/**font_scale**, goal.*, srs.new_cards_per_day, game.*, reminder.*), `backup_metadata`, `daily_activity` (chỉ đọc), `language_pairs` (chỉ đọc).

> Số/tên trong kit là MOCK ("Linh Tran", "linh@memox.app", "LT", "한국어 → English", "Boxes: 8",
> "5 words/round", "13:00 · Mon–Sun", "1 · 3 · 7 · 14 · 30 · 60 · 120", "55%") — assert **định dạng & nguồn**,
> KHÔNG assert giá trị mock. Chuỗi lấy từ ARB, không copy kit. Cột DB phải có thật trong schema-contract.
>
> ⓘ Ghi chú v1 (contract): tile **Cloud sync** render thành **Backup / Restore cục bộ** (account-sync hoãn);
> **Premium hoãn** (D-012 — không có tính năng bị khoá); **Voice (TTS/STT)** và **Word display** ghi trạng thái
> **Hoãn** trong business doc W12 → tile hiển thị nhưng đích/hành vi chưa chốt ⇒ liệt kê ở Open questions, KHÔNG bịa.
> ⚠ NGƯỢC LẠI — **Reminders** (business dòng 9 = Implemented, NotificationService) và **Theme/Personalization**
> (personalization dòng 9 = Implemented, W13) là tính năng **ĐÃ CÓ** ⇒ assert như đã build (SC-16, SC-19/33/63), **KHÔNG**
> treo "spec đích/chưa làm". Với Reminders chỉ còn mâu thuẫn business-vs-navigation về **lịch OS** (OQ#16), không phải cả tính năng.

## DoE — settings (12 chiều)

| # | Chiều | TT | Scenario / N/A |
|---|---|---|---|
| 1 | States (3: loaded · group-expanded · value-picker) | ✅ | SC-SETTINGS-01..03 |
| 2 | Elements (profile-card · 9 tile · switch · picker-sheet ×3 button · bottom-nav ×5) | ✅ | SC-SETTINGS-10..28 (SC-28 = gap: `new_cards_per_day` D-018 không có tile) |
| 3 | Nav vào/ra | ✅ | SC-SETTINGS-30..37 |
| 4 | Nhập liệu & validation | **N/A (field tự do) + edge input rời rạc** | màn settings hub KHÔNG có field nhập tự do; nhưng switch + picker LÀ input rời rạc cần validate **trạng thái nguồn** → SC-SETTINGS-46 (giá trị DB ngoài tập kit). Field nhập tự do nằm ở màn con (reminder/theme) — ngoài phạm vi. Ngưỡng số (new/day, words/round) → SC-SETTINGS-45 + Open q. |
| 5 | Lượng dữ liệu | ✅ | SC-SETTINGS-40..46 |
| 6 | Async & lỗi | ⚠ gap nguồn | SC-SETTINGS-50..53 (contract chỉ 3 state — loading/error để OQ#11, không assert cứng) |
| 7 | Persistence (DB round-trip) | ✅ | SC-SETTINGS-60..64 |
| 8 | Định dạng & i18n | ✅ | SC-SETTINGS-70..74 |
| 9 | Dark mode | ✅ | SC-SETTINGS-80 |
| 10 | Responsive | ✅ | SC-SETTINGS-81 |
| 11 | A11y | ✅ | SC-SETTINGS-82 |
| 12 | Concurrency & edge thời gian | ✅ | SC-SETTINGS-90..93 |

Element inventory (từ DOM spec — mỗi cái ≥1 scenario ở mục 2):
`settings/profile` (card avatar "LT" + tên + email) · nhóm **STUDYING**: `g-0` Language (icon translate, giá trị "한국어 → English") ·
`g-1` Word display · `g-2` Spaced repetition (icon schedule) · `g-3` Game settings (icon sports_esports, hiện số "5") ·
`g-4` Voice · nhóm **APP**: `g-5` Reminders (icon notifications) · `g-6` Backup / Restore (icon backup) ·
`g-7` Cloud sync (icon cloud_sync → v1 = Backup/Restore cục bộ) · `g-8` Theme (icon palette).
State **group-expanded** (SRS mở): `srs-boxes` (Leitner boxes, số "8") · `srs-intervals` (Intervals days) ·
`srs-notif` (icon **`notifications_active`** ≠ tile g-5 `notifications`) + `srs-notif-switch` (Due notifications — **switch**, mx:?) ·
regroup **OTHER**: `games` + `theme`. **KHÔNG có hàng "New cards/day"** (D-018 không có tile — gap SC-28).
State **value-picker** (sheet): `picker-scrim` (overlay tap-dismiss) · handle · title · button `words-5` (đang chọn:
**icon:check leading** text-secondary + **icon:check trailing** primary) · `words-10` · `words-20` (chưa chọn:
**icon:circle leading**, **KHÔNG trailing** — bất đối xứng leading selected=check/unselected=circle).
Bottom-nav ×5 (Today·Library·Add·Stats·**Profile active** — "active" phụ thuộc OQ#1 entry-point).

---

## 1. States

### SC-SETTINGS-01 — loaded (danh sách nhóm cài đặt)
Nguồn: contract[loaded] · spec base · BR settings §5 (nhóm cài đặt)
Given (DB): `settings` có các key mặc định (`theme.mode`, `theme.accent`, `theme.font_scale`, `game.words_per_round`,
`srs.new_cards_per_day`, `reminder.*`…); `language_pairs`(1 hàng active); profile info nguồn (⚠ nguồn tên/email — Open q.).
When: mở tab **Profile** (bottom-nav) → màn settings.
Then:
- UI: app bar tiêu đề "Settings" (ARB) · card profile (avatar chữ tắt + tên + email) · nhóm **STUDYING** (5 tile) ·
  nhóm **APP** (4 tile) · bottom-nav[Profile active, màu primary-strong]. Mỗi tile hiển thị icon-tile + tiêu đề + phụ đề
  tóm tắt giá trị hiện tại + chevron. Không sheet, không skeleton, không crash.
- DB: không ghi (chỉ đọc settings/language_pairs).

### SC-SETTINGS-02 — group-expanded (mở nhóm Spaced repetition)
Nguồn: contract[group-expanded] · spec "group expanded" diff · BR settings §5 (SRS: số ô 8 · thông báo) · D-018
Given: đang ở loaded; `settings`(`srs.new_cards_per_day`, `reminder.*` có giá trị).
When: chạm tile **Spaced repetition** (`g-2`).
Then:
- UI: section đổi tiêu đề nhóm thành "SPACED REPETITION" (ARB) · card mở ra 3 hàng con: `srs-boxes` (Leitner boxes +
  số ô hiện tại), `srs-intervals` (Intervals days — chuỗi khoảng cách), `srs-notif` (Due notifications + **switch**) ·
  các nhóm còn lại gom về "OTHER" (games + theme). scrollh giảm (kit 1154→782) ⇒ layout thu gọn.
- DB: chỉ mở/thu UI, không ghi (tới khi bật switch/đổi giá trị — xem SC-SETTINGS-21/22).
⚠ Xác nhận: group-expanded là **inline accordion** trong màn settings hay **push** sang màn SRS con? (kit dựng như diff nội trang;
navigation-flow không liệt kê route `/settings/srs`) — cần chốt trước khi assert push vs inline.

### SC-SETTINGS-03 — value-picker (chọn số từ/ván)
Nguồn: contract[value-picker] · spec "value picker" diff · D-008 · BR settings BR-2/AC-1
Given: `settings`(`game.words_per_round` = giá trị hiện tại, mặc định 5).
When: chạm tile **Game settings** (`g-3`) → chọn mục "Words per round".
Then:
- UI: bottom-sheet trồi lên (`picker-sheet`) trên scrim (`picker-scrim`) · handle · title "Words per round" (ARB) ·
  3 lựa chọn: "5 words" (đang chọn → icon check ở đầu + check màu primary ở cuối), "10 words", "20 words"
  (icon:circle = chưa chọn). Lựa chọn khớp giá trị DB hiện tại được đánh dấu.
- DB: chưa ghi cho tới khi người dùng chọn một mục khác (xem SC-SETTINGS-23).
⚠ Xác nhận: danh sách giá trị words/round (kit chỉ mock 5/10/20) — tập giá trị hợp lệ đầy đủ do đâu định nghĩa? business doc chỉ nói mặc định 5.
⚠ Edge input: scenario này giả định giá trị DB **luôn khớp** một option {5,10,20}. Nếu giá trị đã lưu **ngoài tập kit**
(vd `words_per_round=15` do import/backup cũ hoặc key ghi tay) → picker render thế nào (đánh dấu mục nào? thêm option động? không mục nào check?)
chưa có nguồn ⇒ xem SC-SETTINGS-46 + Open q.#19.

---

## 2. Elements (mỗi phần tử ≥1 scenario)

### SC-SETTINGS-10 — Card profile
Nguồn: spec `settings/profile` (avatar "LT" + "Linh Tran" + "linh@memox.app")
Then: hiển thị avatar chữ tắt + tên + email. ⚠ Xác nhận **nguồn** tên/email (không có bảng user trong schema-contract;
`settings` không có key profile; `language_pairs` không giữ tên) → hiện chưa có nguồn DB ⇒ Open question. Chạm card:
⚠ đích chưa có trong D-xxx/business (edit profile? account?) — assert tối thiểu: hiển thị, có semantic label.

### SC-SETTINGS-11 — Tile Language (`g-0`)
Nguồn: spec `settings/g-0` (icon translate, phụ đề "한국어 → English") · BR settings BR-1 (tiếng mẹ đẻ ≠ giao diện ≠ cặp học)
When: chạm tile Language.
Then: UI phụ đề hiển thị **cặp/ngôn ngữ hiện tại** đọc từ `language_pairs`(active) (định dạng "source → target", CJK render đúng).
Chạm → ⚠ đích (màn chọn ngôn ngữ giao diện / tiếng mẹ đẻ) chưa có route trong navigation-flow ⇒ Open question. Assert tối thiểu:
tile có chevron + semantic label; phụ đề không phải chuỗi hardcode kit.

### SC-SETTINGS-12 — Tile Word display (`g-1`)
Nguồn: spec `settings/g-1` (icon format_shapes, phụ đề "Native meaning · color by gender") · BR settings §5 (Hiển thị từ)
Then: tile hiển thị. ⚠ business doc W12 ghi **Hiển thị-từ HOÃN v1** → hành vi/đích khi chạm chưa chốt ⇒ Open question.
Assert tối thiểu: tile hiển thị đúng cấu trúc; nếu build hoãn ⇒ scenario là spec đích (test đỏ tới khi làm).

### SC-SETTINGS-13 — Tile Spaced repetition (`g-2`)
Nguồn: spec `settings/g-2` (icon schedule, phụ đề "Boxes: 8 · Notifications on") → dẫn tới SC-SETTINGS-02 (group-expanded)
Then: phụ đề tóm tắt số ô (nguồn: hằng SRS = 8 ô, xem srs-review) + trạng thái thông báo (nguồn `reminder.weekdays` rỗng/không).
Chạm → mở group-expanded (SC-SETTINGS-02). Số "8" là **định dạng plural/format**, không assert giá trị mock.

### SC-SETTINGS-14 — Tile Game settings (`g-3`)
Nguồn: spec `settings/g-3` (icon sports_esports, phụ đề "5 words/round · shuffle", hiện số "5" cạnh chevron) · D-008 · BR-2
When: chạm tile.
Then: UI phụ đề tóm tắt `game.words_per_round` + `game.random` (shuffle on/off); số cạnh chevron = words/round hiện tại (đọc DB).
Chạm mở picker/màn game settings → SC-SETTINGS-03 (value-picker words/round). DB: đọc `settings.game.words_per_round`,
`settings.game.random`.

### SC-SETTINGS-15 — Tile Voice (`g-4`)
Nguồn: spec `settings/g-4` (icon record_voice_over, phụ đề "TTS on · STT off") · BR settings §5 (Giọng nói)
Then: tile hiển thị. ⚠ business doc W12 ghi **TTS/STT HOÃN v1** → đích/hành vi chưa chốt ⇒ Open question.
Assert tối thiểu: tile hiển thị; nếu hoãn ⇒ spec đích.

### SC-SETTINGS-16 — Tile Reminders (`g-5`)
Nguồn: spec `settings/g-5` (icon notifications, phụ đề "13:00 · Mon–Sun") · BR settings BR-4 ·
navigation-flow `/settings/reminder` · **business/settings/settings.md dòng 9 (Trạng thái = Implemented)**
When: chạm tile.
Then: UI phụ đề hiển thị giờ nhắc + tập thứ (đọc `settings.reminder.hour/minute/weekdays`; weekdays rỗng ⇒ "off"/không nhắc).
Chạm → **push** màn `reminder` (`/settings/reminder`). DB: đọc `settings.reminder.*`.
Reminder là tính năng **ĐÃ CÓ** (business doc: "nhắc học lên lịch thông báo OS qua `NotificationService`
[flutter_local_notifications + timezone], 1 thông báo/ngày-trong-tuần đã chọn") ⇒ assert như tính năng đã build,
**KHÔNG** treo "spec đích/chưa làm".
⚠ Mâu thuẫn NGUỒN (không phải "chưa build"): navigation-flow dòng 25 ghi phần **lên lịch OS** là "hoãn (gated)",
trong khi business dòng 9 ghi lên-lịch-OS là Implemented. Ưu tiên business doc (Implemented) cho hành vi lõi;
chỉ cờ mâu thuẫn business-vs-navigation về lịch OS ⇒ Open q.#16. KHÔNG mặc định coi Reminders là chưa làm.

### SC-SETTINGS-17 — Tile Backup / Restore (`g-6`)
Nguồn: spec `settings/g-6` (icon backup, phụ đề "Auto · last today") · BR settings BR-3 (sao lưu ≠ đồng bộ)
When: chạm tile.
Then: UI phụ đề tóm tắt trạng thái sao lưu (tự động on/off + lần cuối) đọc từ `backup_metadata` (last = `created_at` gần nhất /
`last_restored_at`). Chạm → màn/sheet Backup/Restore. DB: đọc `backup_metadata`. Ngày "last today" phải theo **định dạng locale**,
không hardcode.
⚠ Xác nhận: "Auto" (tự động sao lưu) là toggle lưu ở đâu? `settings` k-v không có key backup — cần thêm key hoặc bỏ "Auto".

### SC-SETTINGS-18 — Tile Cloud sync (`g-7`) → v1 Backup/Restore cục bộ
Nguồn: spec `settings/g-7` (icon cloud_sync, phụ đề "linh@memox.app · alpha") · contract ⓘ v1 · BR settings BR-3/BR-5 · D-027 (hoãn)
Then: theo contract ⓘ, tile này ở **v1 render thành Backup/Restore cục bộ (hoặc bỏ)** — account-sync hoãn.
⚠ Xác nhận: v1 hiển thị tile Cloud-sync (disabled/alpha) hay **bỏ hẳn** (vì đã có `g-6` Backup/Restore)? Không được để 2 tile trùng chức năng.
Assert (theo lựa chọn đã chốt): nếu bỏ ⇒ tile không render; nếu giữ ⇒ trạng thái "alpha"/hoãn, không thao tác đăng nhập được.

### SC-SETTINGS-19 — Tile Theme (`g-8`)
Nguồn: spec `settings/g-8` (icon palette, phụ đề "Light · default accent") · personalization BR-1..BR-3 ·
navigation-flow `/settings/theme` · **business/personalization/personalization.md dòng 9 (Trạng thái = Implemented, W13)**
When: chạm tile.
Then: Theme là tính năng **ĐÃ CÓ** (business doc W13: "chế độ màu sáng/tối/hệ thống + màu nhấn brand/warm/cool +
cỡ chữ nhỏ/vừa/lớn; áp dụng live qua MemoXApp, lưu trong settings W12") ⇒ assert như tính năng đã build, **KHÔNG** treo "spec đích".
UI phụ đề tóm tắt **cả 3 chiều** personalization: chế độ màu (`settings.theme.mode` → "Light/Dark/System") + màu nhấn
(`settings.theme.accent` → brand/warm/cool) + **cỡ chữ** (`settings.theme.font_scale` → small/medium/large, schema-contract dòng 245).
Chạm → **push** màn `theme` (`/settings/theme`). DB: đọc `settings.theme.mode` + `settings.theme.accent` + `settings.theme.font_scale`.
⚠ Định dạng phụ đề khi gộp 3 chiều (kit mock chỉ hiện "Light · default accent" = mode+accent) — cỡ chữ hiển thị trong
phụ đề hay chỉ trong màn con? ⇒ Open q.#17 (không bịa layout phụ đề).

### SC-SETTINGS-20 — Hàng con Leitner boxes (`srs-boxes`, trong group-expanded)
Nguồn: spec group-expanded `settings/srs-boxes` (icon grid_view, "Leitner boxes" + "Number of review boxes", số "8")
Then: hiển thị số ô hiện tại (nguồn = hằng SRS = 8, srs-review §Leitner). ⚠ Xác nhận: số ô có **cho đổi** không?
srs-review chốt 8 ô cố định v1; nếu cố định ⇒ chạm không mở picker (read-only) — assert read-only, KHÔNG bịa picker.

### SC-SETTINGS-21 — Hàng con Intervals (`srs-intervals`, trong group-expanded)
Nguồn: spec group-expanded `settings/srs-intervals` (icon timeline, phụ đề "1 · 3 · 7 · 14 · 30 · 60 · 120") · srs-review §interval · schema `srs_state`
Then: phụ đề hiển thị **chuỗi khoảng cách ngày** cho ô 1..7 (nguồn: `SrsScheduler.intervalDays` = 1·3·7·14·30·60·120,
schema-contract §srs_state). ⚠ Xác nhận: intervals **cho đổi** hay read-only? schema chốt cứng dãy này ⇒ nếu cố định, assert read-only.

### SC-SETTINGS-22 — Switch Due notifications (`srs-notif-switch`, trong group-expanded)
Nguồn: spec group-expanded `settings/srs-notif` (icon **`notifications_active`**, color:on-primary-soft — DOM dòng 1083-1088)
+ `settings/srs-notif-switch` (switch, mx:?) · BR settings BR-4 · schema `settings.reminder.*`
Then (element): hàng "Due notifications" dùng icon-tile **`notifications_active`** — **khác** icon tile g-5 Reminders
(`notifications`, SC-SETTINGS-16). Assert đúng icon semantic ở từng chỗ (hai chỗ "notifications" nhưng glyph khác).
When: bật/tắt switch "Due notifications".
Then:
- UI: switch đổi trạng thái (thumb dịch), tức thời (không cần khởi động lại).
- DB: ghi trạng thái thông báo đến-hạn vào `settings` (⚠ **key nào?** schema-contract có `reminder.weekdays` (rỗng=off) nhưng
  KHÔNG có key riêng "srs due-notifications on/off" → cần chốt: dùng `reminder.weekdays` hay thêm key mới. KHÔNG bịa key.).
- Kill & mở lại app → switch giữ nguyên trạng thái (round-trip) — xem SC-SETTINGS-62.

### SC-SETTINGS-23 — Chọn giá trị trong value-picker (words/round)
Nguồn: spec value-picker `settings/words-5|10|20` (button, mx:?) · D-008 · BR-2 · AC-1 · schema `settings.game.words_per_round`
Given: `game.words_per_round` = 5 (đang chọn); sheet đang mở.
When: chạm "10 words".
Then:
- UI: dấu check chuyển sang "10 words" (mục được chọn có **icon:check leading** color:text-secondary + **icon:check trailing**
  color:primary — DOM dòng 1457-1475); "5 words" trở về **chưa chọn** = **icon:circle leading** + **KHÔNG có trailing icon**;
  sheet đóng (⚠ xác nhận: chọn xong tự đóng hay có nút xác nhận?). Phụ đề tile Game settings + số cạnh chevron cập nhật thành 10.
- DB: `settings` UPDATE key `game.words_per_round` = 10 (INTEGER). Không đổi bảng khác.
- Hệ quả (AC-1/D-008): ván Game kế tiếp dùng đúng 10 thẻ (kiểm ở scenario game riêng — trích D-008; ở đây chỉ assert ghi settings).
- Cấu trúc icon **bất đối xứng leading** (assert cả hai phía): selected = check(leading, text-secondary) + check(trailing, primary);
  unselected = circle(leading) + không trailing. KHÔNG mô tả mờ "icon check" — nêu rõ leading/trailing của cả selected lẫn unselected.

### SC-SETTINGS-24 — Scrim đóng value-picker (huỷ chọn)
Nguồn: spec value-picker `settings/picker-scrim` (overlay z:60, bg:overlay)
When: chạm scrim (vùng tối ngoài sheet) hoặc swipe-down sheet.
Then: UI sheet đóng, KHÔNG đổi giá trị; DB `settings.game.words_per_round` giữ nguyên. (huỷ = no-op ghi).

### SC-SETTINGS-25 — Bottom-nav: Profile (tab hiện tại)
Nguồn: spec bottom-nav item[5] "Profile" (icon person, màu primary-strong = active)
Then: tab Profile active. Chạm lại Profile khi đang ở settings ⇒ **hành vi chưa xác định** (OQ#13) — KHÔNG assert
no-op/scroll-top (chưa có nguồn, không liệt kê phỏng đoán trong Then).
⚠ Phụ thuộc OQ#1 (entry-point): nếu settings là **push** (navigation-flow dòng 24 "mở từ drawer") thì Profile không phải
nhánh shell → không có "tab active" cố định. Assert cứng "tab Profile active" chỉ đúng nếu entry = tab (DOM spec). Chờ chốt OQ#1.

### SC-SETTINGS-26 — Bottom-nav: các tab khác (Today/Library/Add/Stats)
Nguồn: spec bottom-nav item[1..4] · navigation-flow (shell 5 mục, Add = action)
When: chạm từng mục.
Then: Today→tab Today · Library→tab Library · **Add**→action (mở luồng thêm, không phải tab, không active) · Stats→tab Stats.
⚠ "Giữ vị trí cuộn khi quay lại (StatefulShellRoute giữ nhánh)" **phụ thuộc OQ#1**: navigation-flow dòng 24 ghi settings là
**push** (không phải nhánh shell) → nếu là push thì KHÔNG có StatefulShellRoute giữ nhánh cho settings. KHÔNG assert cứng
cơ chế shell khi entry-point chưa chốt (xem SC-SETTINGS-37 + OQ#1).

### SC-SETTINGS-27 — Cuộn danh sách settings (scroll body)
Nguồn: spec app__body layout_hint:scroll scrollh:1154 (> viewport 668)
Then: body cuộn được để chạm tới nhóm APP (Theme ở cuối); không overflow ngang; bottom-nav pinned (pos:absolute z:10) không cuộn theo.

### SC-SETTINGS-28 — new_cards_per_day (D-018) — KHÔNG có UI đổi trong settings hub
Nguồn: schema-contract dòng 248 `srs.new_cards_per_day` (default **20**, D-018) · DOM group-expanded (`srs-boxes` + `srs-intervals` + `srs-notif`)
Then: DOM group-expanded của Spaced repetition chỉ có **3 hàng con**: `srs-boxes`, `srs-intervals`, `srs-notif` — **KHÔNG có hàng
"New cards / day"**. Không có tile/hàng/picker nào trong màn settings hub cho `srs.new_cards_per_day`.
⚠ **Gap thật** (không bịa hàng): `new_cards_per_day` (D-018) hiện **không có UI để đổi** trong settings ⇒ hoặc (a) thiếu element
trong kit → phải **kit-first** bổ sung hàng "New cards/day" vào group-expanded rồi `/design-sync`, hoặc (b) mặc định 20 cố định v1
(read-only, không cho đổi). Cần chốt (a) vs (b) ⇒ Open q.#18. KHÔNG assert picker/hàng chưa tồn tại trong DOM.

---

## 3. Điều hướng vào/ra

### SC-SETTINGS-30 — Vào từ bottom-nav Profile
Given: đang ở tab bất kỳ. When: chạm Profile. Then: hiển thị màn settings (tab Profile active).
⚠ navigation-flow: `profile` (`/profile`) là **tab shell** "placeholder ở S0", còn `settings` (`/settings`) là **push** "mở từ drawer".
Cần chốt: v1 màn settings **là tab Profile** (như DOM spec bottom-nav Profile active) hay **push riêng từ drawer**? — quyết định entry point.

### SC-SETTINGS-31 — Vào bằng push `/settings` (nếu là push từ drawer)
Nguồn: navigation-flow `/settings` push
Then: nếu entry = push, có nút back (app bar) quay về màn trước; giữ state màn trước.
⚠ DOM spec app bar KHÔNG có nút back (chỉ title "Settings") ⇒ mâu thuẫn với "push". Cần chốt entry (tab vs push) — Open question.

### SC-SETTINGS-32 — Ra: tile Reminders → màn reminder
Nguồn: navigation-flow `/settings/reminder` (push). Then: push reminder; back về settings giữ vị trí cuộn.

### SC-SETTINGS-33 — Ra: tile Theme → màn theme
Nguồn: navigation-flow `/settings/theme` (push). Then: push theme; back về settings; đổi theme áp live (personalization BR-3) rồi back ⇒ settings render theo theme mới.

### SC-SETTINGS-34 — Ra: tile Backup/Restore
Then: mở màn/sheet backup; back/close về settings. (đích chi tiết ⚠ nếu chưa build — spec đích).

### SC-SETTINGS-35 — Back / swipe-dismiss value-picker
Nguồn: state value-picker
When: nhấn back hệ thống khi sheet mở. Then: đóng sheet trước (không rời màn settings); back lần nữa mới rời màn (nếu là push).

### SC-SETTINGS-36 — Back tại settings (tab gốc)
When: nhấn back hệ thống khi settings là tab.
Then: **hành vi chưa xác định** (OQ#13) — KHÔNG liệt kê phỏng đoán (về Today / thoát app / no-op) trong Then; chờ chốt spec.
⚠ Cũng phụ thuộc OQ#1: nếu settings là **push** thì back = quay về màn trước (không phải "tab gốc") ⇒ scenario này chỉ áp dụng khi entry = tab.

### SC-SETTINGS-37 — Giữ vị trí cuộn & group-expanded khi quay lại
Given: mở group-expanded SRS, cuộn xuống, push theme, back.
Then: kỳ vọng settings giữ vị trí cuộn + trạng thái nhóm đang mở.
⚠ **Cơ chế giữ nhánh phụ thuộc OQ#1**: navigation-flow dòng 24 ghi settings là **push** (không phải nhánh StatefulShellRoute)
→ nếu là push, việc giữ state khi rời-quay lại KHÔNG do shell branch mà do cách push/pop giữ màn dưới. KHÔNG assert cứng
"StatefulShellRoute giữ nhánh" khi entry chưa chốt. Ngoài ra group-expanded có thể là ephemeral UI-state ⇒ xác nhận có giữ khi rời-quay lại không.

---

## 5. Lượng dữ liệu

### SC-SETTINGS-40 — Settings trống hoàn toàn (người dùng mới / chưa ghi key nào)
Given: bảng `settings` chưa có hàng nào.
Then: mọi tile hiển thị **giá trị mặc định** (theme.mode=?, `srs.new_cards_per_day`=20, `game.words_per_round`=5,
`game.random`=?, reminder off) — nguồn mặc định = schema-contract §settings (default 20, default 5). Không crash, không phụ đề rỗng.
⚠ Xác nhận default cho `theme.mode`/`theme.accent`/`theme.font_scale`/`game.random`/goal targets (schema không ghi default) — Open question.

### SC-SETTINGS-41 — Profile trống (không có tên/email)
Then: nếu nguồn profile rỗng ⇒ avatar/tên/email fallback (⚠ copy fallback chưa có trong ARB/spec) — không hiển thị chuỗi kit mock.

### SC-SETTINGS-42 — language_pairs = 1 (đơn cặp v1)
Then: tile Language phụ đề = cặp active duy nhất. (schema: đúng 1 hàng is_active=1).

### SC-SETTINGS-43 — Biên số hiển thị trong phụ đề
Then: số ô (8), words/round (5/10/20), new/day (20) hiển thị đúng plural/format; giá trị biên (vd words/round = 20 = max của picker) không tràn tile.

### SC-SETTINGS-44 — backup_metadata rỗng (chưa từng sao lưu)
Then: tile Backup/Restore phụ đề = trạng thái "chưa sao lưu" (⚠ copy ARB) thay vì "last today"; `last_restored_at` NULL ⇒ không hiển thị "last restored".

### SC-SETTINGS-45 — Biên giá trị số (new/day, words/round)
Nguồn: schema `settings.srs.new_cards_per_day` (default 20), `game.words_per_round` (default 5) · D-018/D-008
Then: nếu có màn con cho đổi `new_cards_per_day` ⇒ ràng buộc min/max (⚠ ngưỡng chưa có trong business/D-xxx) ⇒ Open question;
words/round chỉ nhận tập định sẵn (5/10/20 theo picker) — giá trị ngoài tập không thể **chọn** qua UI (không có field tự do ⇒ không cần validate rỗng/dài/CJK).

### SC-SETTINGS-46 — Giá trị đã lưu nằm NGOÀI tập option kit (edge input rời rạc)
Nguồn: schema `settings.game.words_per_round` (INTEGER, không ràng buộc enum ở DB) · picker kit chỉ có {5,10,20}
Given: DB `game.words_per_round` = 15 (ngoài tập kit — do import/backup cũ, migration, hoặc ghi tay k-v).
Then:
- Phụ đề tile Game settings + số cạnh chevron: hiển thị **giá trị thật đã lưu (15)** đọc từ DB (không ép về option gần nhất, không crash).
- Mở value-picker: ⚠ **chưa có nguồn** cho hành vi khi giá trị hiện tại không khớp {5,10,20} — mục nào được đánh dấu? có thêm
  option động "15 words" không? hay không option nào check (unselected toàn bộ)? ⇒ Open q.#19. KHÔNG bịa (không tự chọn "đánh dấu option gần nhất").
- Đây là input rời rạc thật cần chốt (switch + picker là input, dù không phải field tự do) — DoE #4 KHÔNG hoàn toàn N/A cho nhánh này.

---

## 6. Async & lỗi

### SC-SETTINGS-50 — loading → loaded
Given: provider settings/`SettingsRepository.watch*` chưa resolve.
Then: ⚠ **Gap NGUỒN** — contract settings KHÔNG có state `loading` (chỉ 3 state) ⇒ hiện gì trước khi settings load (skeleton?
giá trị mặc định tức thời? local-first đọc k-v thường tức thời) **chưa chốt** ⇒ OQ#11. KHÔNG assert hình thức loading cụ thể.
Chỉ assert bất biến an toàn: không crash, không nhấp nháy chuỗi mock.

### SC-SETTINGS-51 — Ghi settings thất bại + retry
Given: bật switch / chọn picker nhưng ghi `settings` lỗi (DB write fail).
Then: ⚠ **Gap NGUỒN thật** — contract KHÔNG có state `error` (chỉ 3 state) ⇒ cơ chế surface lỗi **chưa chốt** (OQ#11).
KHÔNG assert cứng cơ chế cụ thể (snackbar ARB / revert UI về DB thật) như thể đã chốt — đó là ĐOÁN chưa có nguồn.
Chỉ giữ **nguyên tắc lỗi** (đã có trong repo contract, không phải đoán): lỗi không được **nuốt** — phải flow
`Failure`→`AsyncValue.error`, có localized surface cho end-user + logging/report cho dev. Còn **hình thức** surface
(snackbar? revert? banner?) và có revert hay không ⇒ để OQ#11, KHÔNG viết assertion revert cứng.

### SC-SETTINGS-52 — local-first (không mạng)
Then: settings đọc/ghi hoàn toàn từ DB local; không mạng vẫn render + đổi giá trị được (không có backend v1).

### SC-SETTINGS-53 — Backup/Restore đang chạy (async dài) + huỷ/lỗi
Given: chạy sao lưu/khôi phục (thao tác file).
Then: ⚠ **Gap NGUỒN** — kit không có state loading/error cho backup/restore ⇒ hình thức hiện tiến trình + kết quả thành công/thất bại
+ retry **chưa chốt** ⇒ OQ#11. KHÔNG assert UI cụ thể (progress bar/snackbar) như spec đã chốt.
Chỉ giữ bất biến an toàn dữ liệu (đã có trong D-027/backup contract, không phải đoán): Restore lỗi ⇒ **không phá DB hiện tại** (atomic/rollback).

---

## 7. Persistence (DB round-trip)

### SC-SETTINGS-60 — Đổi words/round ghi bền vững
Nguồn: SC-SETTINGS-23 · schema `settings.game.words_per_round`
Given: `game.words_per_round`=5. When: chọn "20 words". Then: DB row `key='game.words_per_round'` value='20'; đọc lại watch stream phát 20.

### SC-SETTINGS-61 — Bật switch Due notifications ghi bền vững
Nguồn: SC-SETTINGS-22 · schema `settings.reminder.*`
Then: DB ghi trạng thái thông báo vào `settings` (⚠ key — xem SC-SETTINGS-22). Round-trip đọc lại đúng.

### SC-SETTINGS-62 — Kill & mở lại app → mọi cài đặt còn nguyên
Given: đổi words/round + toggle switch + (nếu có) đổi theme.
Then: kill app, mở lại → tile hiển thị đúng giá trị đã lưu từ `settings` (không reset về mặc định). Round-trip toàn màn.

### SC-SETTINGS-63 — Đổi theme ở màn con phản chiếu lên phụ đề tile Theme
Nguồn: personalization BR-3 · schema `settings.theme.*`
Given: vào Theme (SC-SETTINGS-33), đổi mode Light→Dark, back.
Then: phụ đề tile Theme cập nhật "Dark · <accent>"; DB `settings.theme.mode`='dark'; giao diện settings áp dark tức thời (không restart).

### SC-SETTINGS-64 — Sao lưu ghi `backup_metadata`
Nguồn: SC-SETTINGS-17 · schema `backup_metadata`
When: thực hiện sao lưu cục bộ. Then: DB `backup_metadata` +1 hàng (`id`, `schema_version`, `created_at`); phụ đề tile cập nhật "last <ngày>".
Khôi phục ⇒ set `last_restored_at`. ⚠ nếu build hoãn ⇒ spec đích.

---

## 8. Định dạng & i18n

### SC-SETTINGS-70 — Phụ đề ngày theo locale (Backup "last …", Reminders giờ)
Given: đổi locale (vi/en/ja). Then: "last <ngày>" + giờ nhắc "13:00" đổi format thứ/ngày/giờ theo locale; không hardcode "today"/"13:00".

### SC-SETTINGS-71 — Plural trong phụ đề (words/round, số ô)
Then: "5 words/round" dùng ARB plural (1 ⇒ "1 word/round"? N ⇒ "N words/round"); số ô "8 boxes" theo plural, không nối chuỗi.

### SC-SETTINGS-72 — CJK trong phụ đề Language + tên profile
Given: cặp học Hàn/Nhật ("한국어 → English"), tên profile CJK ("린 트란").
Then: render đúng glyph CJK (không tofu); mũi tên "→" hiển thị đúng; không cắt sai giữa ký tự.

### SC-SETTINGS-73 — Text dài (tên/email/phụ đề dài)
Then: tên/email dài, phụ đề ngôn ngữ dài, intervals dài ("1 · 3 · 7 · 14 · 30 · 60 · 120") → ellipsis/wrap, không tràn tile/đẩy chevron ra ngoài.

### SC-SETTINGS-74 — Tiêu đề nhóm & tile đều từ ARB
Then: "STUDYING"/"APP"/"OTHER"/"SPACED REPETITION", tiêu đề tile, title picker "Words per round" đều từ ARB (không copy kit mock);
đổi ngôn ngữ giao diện ⇒ đổi theo.

---

## 9. Dark mode

### SC-SETTINGS-80 — Mọi state ở dark
Then: 3 state (loaded · group-expanded · value-picker) render đúng ở **light + dark** bằng token (không hardcode màu);
switch on = bg:primary, thumb bg:surface; scrim bg:overlay; icon-tile bg:primary-soft — contrast đạt ở cả hai theme.

---

## 10. Responsive

### SC-SETTINGS-81 — 320px → tablet + xoay
Then: ở 320px card + tile không overflow ngang (tiêu đề/phụ đề wrap, chevron giữ mép phải); body cuộn tới Theme; picker-sheet
neo đáy (pinned) full-width; xoay ngang cuộn được; safe-area/notch OK; ở tablet card giãn hợp lý (không kéo dài vô hạn — ⚠ maxWidth?).

---

## 11. A11y

### SC-SETTINGS-82 — Semantics
Then: mỗi tile có semantic label (tiêu đề + giá trị hiện tại đọc thành câu có nghĩa, không đọc rời "Language" / "한국어 → English");
switch Due notifications có role switch + trạng thái on/off + label; button picker có label + trạng thái selected; hit-area mỗi tile/switch/nút picker ≥48;
thứ tự đọc: profile → nhóm STUDYING (tile theo thứ tự) → nhóm APP → bottom-nav; chevron không cần đọc riêng.

---

## 12. Concurrency & edge thời gian

### SC-SETTINGS-90 — Double-tap tile
When: chạm nhanh 2 lần tile Theme/Reminders. Then: chỉ push **một** lần (không mở 2 màn). Double-tap tile Game settings ⇒ chỉ 1 sheet.

### SC-SETTINGS-91 — Double-tap / spam switch Due notifications
When: bật/tắt switch nhanh nhiều lần. Then: trạng thái cuối UI = trạng thái cuối ghi DB (không lệch UI↔DB); không ghi chồng gây hàng rác.

### SC-SETTINGS-92 — Đổi giá trị ở picker rồi back nhanh trước khi ghi xong
When: chọn "20 words" rồi lập tức back/kill. Then: hoặc ghi trọn vẹn (value='20') hoặc giữ nguyên value cũ — KHÔNG để giá trị dở/nửa vời;
mở lại app đọc đúng một trong hai (atomic).

### SC-SETTINGS-93 — Đổi mục tiêu/settings ở đây phản ánh sang màn khác
Given: (nếu có) đổi `goal.*` hoặc `game.words_per_round` ở settings/màn con.
Then: Dashboard goal ring (đọc `goal.*`) + ván Game (đọc `game.words_per_round`, D-008) cập nhật theo giá trị mới ở lần vào kế tiếp
(watch stream / đọc lại settings). Không cần restart.
ⓘ Phạm vi tile: `goal.minutes_target` / `goal.words_target` (schema-contract dòng 246-247, D-021) **KHÔNG có tile trong màn
settings hub** (DOM spec không có hàng "Daily goal" trong 9 tile / group-expanded) — mục tiêu ngày đặt ở dashboard/màn khác.
Vì vậy round-trip DB cho `goal.*` **không thuộc file này** (không hiểu nhầm là thiếu tile settings); chỉ assert **hệ quả đọc-lại**
ở SC-93 (dashboard phản chiếu), còn assertion round-trip ghi `goal.minutes_target`/`goal.words_target` nằm ở scenario dashboard/goal.
⚠ Nơi đặt `goal.*` (dashboard tile? màn goal riêng?) — ngoài phạm vi settings, thuộc scenario dashboard (D-021).

---

## Open questions (⚠ cần chốt spec trước khi viết test — KHÔNG bịa)

1. **Entry point màn settings**: là **tab Profile** (DOM spec bottom-nav Profile active, app bar không có back) hay **push `/settings` từ drawer**
   (navigation-flow)? Hai nguồn mâu thuẫn (SC-SETTINGS-30/31/36).
2. **Nguồn Profile (tên/email/avatar)**: không có bảng user trong schema-contract, `settings` k-v không có key profile, `language_pairs` không giữ tên.
   Lấy từ đâu? Có màn edit không? (SC-SETTINGS-10/41).
3. **group-expanded = inline accordion hay push màn SRS con?** navigation-flow không có route `/settings/srs`; kit dựng như diff nội trang (SC-SETTINGS-02).
4. **Số ô Leitner (8) & Intervals (1·3·7·14·30·60·120)**: read-only (chốt cứng theo srs-review/schema) hay cho đổi? Nếu cho đổi thì picker/validation nào? (SC-SETTINGS-20/21).
5. **Switch "Due notifications" ghi vào key nào?** schema có `reminder.weekdays` (rỗng=off) nhưng không có key riêng cho toggle thông báo đến-hạn (SC-SETTINGS-22/61).
6. **Tile Cloud sync (`g-7`)** ở v1: **bỏ hẳn** hay **giữ trạng thái alpha/disabled**? Tránh trùng chức năng với `g-6` Backup/Restore (SC-SETTINGS-18).
7. **Word display (`g-1`)** và **Voice (`g-4`)**: business doc W12 ghi **HOÃN v1** — tile vẫn render? đích khi chạm? (SC-SETTINGS-12/15).
8. **Tập giá trị hợp lệ words/round**: kit mock 5/10/20; business chỉ nói mặc định 5. Danh sách đầy đủ + ngưỡng do đâu định nghĩa? (SC-SETTINGS-03/23).
9. **Default values thiếu trong schema**: `theme.mode`/`theme.accent`/`theme.font_scale`/`game.random`/`goal.minutes_target`/`goal.words_target` không ghi default (SC-SETTINGS-40).
10. **Backup "Auto"**: toggle tự-động-sao-lưu lưu ở đâu? `settings` k-v không có key backup (SC-SETTINGS-17).
11. **State loading/error cho settings**: contract chỉ 3 state (không loading/error). Hiện gì khi đang load / khi ghi lỗi? (SC-SETTINGS-50/51/53).
12. **Value-picker đóng**: chọn xong tự đóng ngay hay có nút xác nhận? Scrim/swipe-down có huỷ không? (SC-SETTINGS-23/24).
13. **Tap lại tab Profile đang active** + **Android back tại tab gốc** (SC-SETTINGS-25/36).
14. **maxWidth ở tablet** cho card settings (SC-SETTINGS-81).
15. **`new_cards_per_day` min/max**: D-018 mặc định 20 nhưng không có ngưỡng biên khi cho đổi (SC-SETTINGS-45).
16. **Reminders — mâu thuẫn business-vs-navigation về lịch OS**: business dòng 9 = Implemented (NotificationService lên lịch OS);
    navigation-flow dòng 25 = "lên lịch OS hoãn (gated)". Nguồn nào đúng cho phần **lên lịch OS**? (bản thân tính năng Reminders ĐÃ CÓ) (SC-SETTINGS-16).
17. **Phụ đề tile Theme gộp 3 chiều**: cỡ chữ (`theme.font_scale`) có hiển thị trong phụ đề tile (cùng mode+accent) hay chỉ trong màn con?
    kit mock chỉ hiện "Light · default accent" (mode+accent) (SC-SETTINGS-19).
18. **`new_cards_per_day` (D-018) không có UI đổi trong settings**: thiếu element trong kit → **kit-first** bổ sung hàng "New cards/day"
    vào group-expanded, hay mặc định 20 cố định read-only v1? (SC-SETTINGS-28).
19. **Giá trị đã lưu ngoài tập option kit** (vd `words_per_round=15` do import/backup/migration): picker đánh dấu mục nào?
    thêm option động? không option nào check? (SC-SETTINGS-46).

> Các mục ⚠ ở trên là **danh sách phải hỏi BA/spec**, không được đoán. Khi có câu trả lời → cập nhật scenario tương ứng + xoá cờ ⚠.
> Đây chính là "không bỏ sót": phần chưa rõ được **liệt kê ra**, không lờ đi.
