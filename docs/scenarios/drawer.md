# Kịch bản — Drawer & Languages · screen `drawer`

Nguồn: `docs/contracts/drawer.md` [open · add-language · remove-language] ·
DOM `specs/drawer.md` · D-030 (validate cặp ngôn ngữ), D-024 (cascade xoá subtree), D-011 (một `srs_state` cho mọi chiều),
D-010/D-021 gián tiếp (header "Today's activity"), D-006 gián tiếp ("N cards" đếm thẻ) ·
BR `docs/business/glossary.md` (Cặp ngôn ngữ / Tiếng mẹ đẻ / DueCount) ·
DB `language_pairs`, `decks`, `cards`, `card_meanings`, `srs_state`, `review_logs`, `study_sessions`, `daily_activity`.

> Số/tên/cờ trong kit là MOCK ("한국어 → English", "1240 cards", "12:45", "24 words", "430 cards") — assert **định dạng & nguồn**,
> KHÔNG assert giá trị mock. Chuỗi lấy từ ARB (`lib/l10n/`, khoá `drawer*`), không copy kit.
> Contract kit chỉ khai báo **3 state** (`open` · `add-language` · `remove-language`). ARB có sẵn khoá cho **error** (`drawerErrorTitle/Text`)
> và **empty** (`drawerRemoveEmptyTitle/Text`) nhưng kit **chưa** vẽ 2 state này ⇒ xem Open questions ⚠ (state chưa có trong contract, đừng bịa flow).
> ⚠ **ARB có khoá không map với DOM**: `drawerBackup` ("Backup", @desc "Drawer item: backup") tồn tại trong `app_en.arb` nhưng **không** item nào trong DOM `open` (item-0..9) dùng — item-9 là "Sync (alpha)" (icon `cloud_sync`). Hoặc `drawerBackup` là khoá **định dùng cho item-9** (mismatch "Backup" vs "Sync (alpha)" — divergence kit↔ARB) hoặc là **orphan key** cho item DOM chưa vẽ ⇒ Open questions #15. Ngoài ra `drawerTitle` ("Menu", @desc "Title of the drawer menu") tồn tại nhưng DOM `open` **không** có node tiêu đề (header là `drawerActivityLabel`) ⇒ khả năng là title a11y/route/AppBar chưa có surface trong kit ⇒ Open questions #16.

## DoE — drawer (12 chiều)

| # | Chiều | TT | Scenario / N/A |
|---|---|---|---|
| 1 | States (3 kit + overlay remove-dialog) | ✅ | SC-DRAWER-01..04 |
| 2 | Elements (12 loại tương tác trong DOM spec + sheet picker) | ✅ | SC-DRAWER-10..27, 47..49 |
| 3 | Nav vào/ra | ✅ | SC-DRAWER-30..37 |
| 4 | Nhập liệu & validation (picker + confirm) | ⚠ **under-driven** (sheet picker mới phủ tối thiểu SC-DRAWER-47..49; state search/loading/empty của sheet chưa có nguồn kit) | SC-DRAWER-40..49 |
| 5 | Lượng dữ liệu (0/1/nhiều cặp; N cards biên) | ✅ | SC-DRAWER-50..54 |
| 6 | Async & lỗi | ✅ / ⚠ (state error ngoài contract) | SC-DRAWER-60..63 |
| 7 | Persistence (DB round-trip + cascade, gồm `study_sessions`) | ✅ | SC-DRAWER-70..74 |
| 8 | Định dạng & i18n (CJK · plural words/cards · text dài) | ✅ | SC-DRAWER-80..84 |
| 9 | Dark mode | ✅ | SC-DRAWER-90 |
| 10 | Responsive (320px → tablet, xoay) | ✅ | SC-DRAWER-91 |
| 11 | A11y | ✅ | SC-DRAWER-92 |
| 12 | Concurrency & edge thời gian | ✅ | SC-DRAWER-95..98 |

Element inventory (từ DOM spec — mỗi cái ≥1 scenario ở mục 2):
**open**: header "TODAY'S ACTIVITY" (icon `schedule` + "12:45" + "·" + "24 words") · 10 `drawer/item-0..9` (button: Add language·Remove language·Import·Export·Stats·Theme·Settings·FAQ·Email us·Sync(alpha)) · vùng `overlay` (scrim đóng) ·
list `layout_hint:scroll`.
**add-language**: `drawer/add-back` (icon-button arrow_back) · appbar title "Add language" · section "LEARNING" · card `drawer/learn-lang` (icon language + tên + phụ đề + expand_more) · icon `arrow_downward` · section "NATIVE" · card `drawer/native-lang` (icon translate + tên + "Meaning language" + expand_more) · `drawer/add-confirm` (btn "Add language pair") · **picker sheet `drawerLanguagePicker` "Language"** (⚠ kit chưa vẽ nội dung — element/state coverage tối thiểu ở SC-DRAWER-47..49).
**remove-language**: `drawer/remove-back` (icon-button arrow_back) · appbar title "Remove language" · list `drawer/pair-0..n` (icon-tile translate + "A → B" + "N cards" + `drawer/pair-i-del` icon-button delete) · overlay `drawer/remove-scrim` + dialog `drawer/remove-dialog` (icon delete + title + text + `drawer/remove-cancel` + `drawer/remove-ok`).

---

## 1. States

### SC-DRAWER-01 — open (drawer bật từ avatar)
Nguồn: contract[open] · spec base "open" · nav-flow ("avatar → mở Drawer")
Tiền điều kiện (Given):
  - DB: `language_pairs`(≥1, có 1 `is_active=1`); `daily_activity`(hôm nay: minutes>0, words>0)
Thao tác (When):
  1. Ở shell (tab bất kỳ có avatar) → chạm avatar
Kỳ vọng (Then):
  - UI: panel trượt từ trái (bg `surface`, shadow), phần còn lại phủ scrim `overlay`.
  - UI: header khoá `drawerActivityLabel` ("Today's activity") + icon đồng hồ + thời lượng + "·" + số từ (khoá plural `drawerActivityWords`).
  - UI: danh sách 10 item cuộn được; **KHÔNG** skeleton, **KHÔNG** dialog.
  - DB: không ghi gì (chỉ đọc).

### SC-DRAWER-02 — add-language (màn thêm cặp)
Nguồn: contract[add-language] · spec "add language" · D-030
Given: đang mở drawer[open]
When: chạm item "Add language" (`drawer/item-0`)
Then:
  - UI: mở màn `add-language` — appbar (back + title khoá `drawerAddLanguage`) · section `drawerSectionLearning` + card learning · icon `arrow_downward` · section `drawerSectionNative` + card native (phụ đề `drawerNativeHint`) · nút xác nhận khoá `drawerAddPair`.
  - UI: 2 card ban đầu hiển thị placeholder `drawerChooseLanguage` khi chưa chọn (⚠ xác nhận: mở từ trạng thái rỗng hay điền sẵn cặp active).
  - DB: chưa ghi (chỉ ghi khi bấm xác nhận — SC-DRAWER-44).

### SC-DRAWER-03 — remove-language (danh sách cặp để xoá)
Nguồn: contract[remove-language] · spec "remove language" · D-024
Given: đang mở drawer[open]; DB có ≥1 cặp ngôn ngữ, mỗi cặp có thẻ
When: chạm item "Remove language" (`drawer/item-1`)
Then:
  - UI: mở màn `remove-language` — appbar (back + title `drawerRemoveLanguage`) · list cặp, mỗi dòng: icon-tile translate + "learning → native" + "N cards" (khoá đếm thẻ) + nút xoá (label `drawerRemovePairLabel`).
  - UI: chưa có dialog (chỉ hiện khi chạm nút xoá — SC-DRAWER-04).
  - DB: chỉ đọc `language_pairs` + đếm `cards` theo pair.

### SC-DRAWER-04 — remove-dialog (overlay xác nhận xoá)
Nguồn: spec `drawer/remove-scrim` + `drawer/remove-dialog` (overlay z:60) · D-024
Given: đang ở remove-language, có cặp "A → B"
When: chạm nút xoá của cặp đó (`drawer/pair-0-del`)
Then:
  - UI: scrim phủ + dialog center: icon delete (nền `error-soft`) · tiêu đề khoá `drawerRemovePairTitle` (chèn tên cặp) · thân khoá `drawerRemovePairText` · nút `drawerRemoveAction`/"Remove" (nền `error`) + nút Cancel (khoá — dùng chung, ⚠ xác nhận khoá Cancel).
  - DB: chưa xoá gì cho tới khi xác nhận (SC-DRAWER-24).

---

## 2. Elements (mỗi phần tử ≥1 scenario)

### SC-DRAWER-10 — Header "Today's activity"
Nguồn: spec `drawer/panel` header (icon schedule + "12:45" + "·" + "24 words") · D-010/D-021
Given: `daily_activity`(hôm nay: minutes=M, words=W)
Then: UI hiện nhãn `drawerActivityLabel`; thời lượng hiển thị theo **định dạng phút** (nguồn = `daily_activity.minutes`, KHÔNG assert "12:45"); số từ dùng plural `drawerActivityWords` (nguồn = `daily_activity.words`). ⚠ Xác nhận: "12:45" là mm:ss hay hh:mm — định dạng thời lượng chưa nêu trong business.

### SC-DRAWER-11 — Item "Add language" (`drawer/item-0`)
Nguồn: spec `drawer/item-0` (icon add + "Add language")
When: chạm → mở màn add-language (xem SC-DRAWER-02). Then: item có label `drawerAddLanguage`, icon `add`, hit-area ≥48.

### SC-DRAWER-12 — Item "Remove language" (`drawer/item-1`)
Nguồn: spec `drawer/item-1` (icon delete + "Remove language")
When: chạm → mở màn remove-language (SC-DRAWER-03). Then: label `drawerRemoveLanguage`.

### SC-DRAWER-13 — Item "Import" (`drawer/item-2`)
Nguồn: spec `drawer/item-2` (icon upload_file + "Import") · D-025
When: chạm → mở luồng Import (route `deckImport`). ⚠ Xác nhận: Import mở từ drawer cần **deck đích** (route `deckImport` cần `:id`) — từ drawer chưa có deck context ⇒ đích thực tế? (chọn deck trước? no-op?). Assert tối thiểu: label `drawerImport`, tap có phản hồi.

### SC-DRAWER-14 — Item "Export" (`drawer/item-3`)
Nguồn: spec `drawer/item-3` (icon download + "Export") · D-026
When: chạm → mở luồng Export (route `deckExport`). ⚠ Xác nhận: tương tự Import — cần deck đích. Assert: label `drawerExport`.

### SC-DRAWER-15 — Item "Stats" (`drawer/item-4`)
Nguồn: spec `drawer/item-4` (icon insights + "Stats") · nav-flow ("statistics ... cùng route mở từ drawer")
When: chạm → điều hướng tab/route `statistics`. Then: label `drawerStats`; drawer đóng; hiện màn Thống kê.

### SC-DRAWER-16 — Item "Theme" (`drawer/item-5`)
Nguồn: spec `drawer/item-5` (icon palette + "Theme") · nav-flow (route `theme`)
When: chạm → push route `theme` (Cá nhân hoá). Then: label `drawerTheme`.

### SC-DRAWER-17 — Item "Settings" (`drawer/item-6`)
Nguồn: spec `drawer/item-6` (icon settings + "Settings") · nav-flow ("settings ... mở từ drawer")
When: chạm → push route `settings`. Then: label `drawerSettings`.

### SC-DRAWER-18 — Item "FAQ" (`drawer/item-7`)
Nguồn: spec `drawer/item-7` (icon help + "FAQ")
When: chạm → ⚠ **KHÔNG có** khoá ARB `drawerFaq`, **KHÔNG có** route, **KHÔNG có** D-xxx/business cho FAQ. Assert tối thiểu: nút tồn tại + hit-area ≥48; đích để ngỏ (Open questions).

### SC-DRAWER-19 — Item "Email us" (`drawer/item-8`)
Nguồn: spec `drawer/item-8` (icon mail + "Email us")
When: chạm → ⚠ **KHÔNG có** khoá ARB/route/D-xxx cho "Email us" (mở mail client?). Assert tối thiểu: nút tồn tại; đích để ngỏ.

### SC-DRAWER-20 — Item "Sync (alpha)" (`drawer/item-9`)
Nguồn: spec `drawer/item-9` (icon cloud_sync + "Sync (alpha)") · D-027 (sync hoãn v1) · ARB `drawerBackup` (mismatch)
When: chạm → ⚠ **KHÔNG có** khoá ARB `drawerSync`; D-027 ghi sync **hoãn** ở v1 (snapshot LWW, per-record hoãn). Assert: nút tồn tại; hành vi v1 để ngỏ (placeholder? Open questions).
⚠ **Divergence cần chốt**: ARB có `drawerBackup` ("Backup", @desc "Drawer item: backup") — item-level, đúng cấp với các item khác — nhưng DOM item-9 dán nhãn "Sync (alpha)". Nếu `drawerBackup` là khoá dự kiến cho item-9 thì text kit ("Sync (alpha)") **lệch** với ARB ("Backup"); nếu không, `drawerBackup` là orphan key. ⇒ Câu "items 7-9 zero ARB coverage" (SC-DRAWER-18..20) phải kèm ngoại lệ này: item-9 **có thể** đã có khoá (`drawerBackup`) — Open questions #15.

### SC-DRAWER-21 — Vùng scrim `overlay` đóng drawer
Nguồn: spec `drawer/overlay` child cuối (`bg:overlay`, phần 38px bên phải panel)
When: chạm ra ngoài panel (vùng scrim)
Then: UI drawer đóng, về màn nền; DB không đổi. ⚠ Xác nhận: scrim-tap đóng (mặc định Material) — kit vẽ vùng overlay nhưng không nêu hành vi.

### SC-DRAWER-22 — Nút back màn add-language (`drawer/add-back`)
Nguồn: spec `drawer/add-back` (icon-button arrow_back)
When: ở add-language → chạm back
Then: UI quay lại drawer[open] (hoặc màn nền — ⚠ xác nhận đích back); DB không ghi (huỷ thêm cặp — không tạo `language_pairs`). Label a11y `drawerBack`.

### SC-DRAWER-23 — Nút back màn remove-language (`drawer/remove-back`)
Nguồn: spec `drawer/remove-back` (icon-button arrow_back)
When: ở remove-language → chạm back
Then: UI quay lại drawer[open]/màn nền; DB không đổi (chưa xoá). Label a11y `drawerBack`.

### SC-DRAWER-24 — Nút "Remove" xác nhận trong dialog (`drawer/remove-ok`)
Nguồn: spec `drawer/remove-ok` ("Remove", `bg:error`) · D-024
Given: dialog xoá cặp "A → B" đang mở; cặp có decks + cards + meanings + srs_state
When: chạm "Remove" (khoá `drawerRemoveAction`)
Then:
  - DB: **cascade xoá** cặp (D-024): `language_pairs` mất dòng cặp; **mọi** `decks` (subtree), `cards`, `card_meanings`, `srs_state`, `review_logs`, **và `study_sessions`** thuộc cặp bị xoá theo `ON DELETE CASCADE`. (`study_sessions.deck_id`→`decks.id` `ON DELETE CASCADE`, schema-contract §study_sessions dòng 194; cây xoá dòng 304-306 + hợp đồng "no write / xoá theo cây" dòng 331.)
  - UI: dialog đóng; danh sách remove-language bớt 1 cặp. ⚠ Xác nhận: nếu xoá cặp `is_active` thì active chuyển sang cặp nào (settings `libraryPairNone` khi không còn cặp?).

### SC-DRAWER-25 — Nút "Cancel" trong dialog (`drawer/remove-cancel`)
Nguồn: spec `drawer/remove-cancel` ("Cancel", color `primary-strong`)
When: chạm "Cancel"
Then: UI dialog đóng, quay lại remove-language còn nguyên cặp; DB **không** xoá gì. ⚠ Xác nhận khoá ARB cho "Cancel" (không thấy `drawerCancel`; ứng viên khoá dùng chung — Open questions).

### SC-DRAWER-26 — Card learning + expand_more mở picker (`drawer/learn-lang`)
Nguồn: spec `drawer/learn-lang` (icon language + tên + phụ đề + expand_more) · D-030
When: chạm card learning
Then: mở picker chọn ngôn ngữ học (tiêu đề khoá `drawerLanguagePicker`; state sheet ở SC-DRAWER-47..49). Chọn 1 ngôn ngữ → card cập nhật tên + phụ đề. ⚠ Xác nhận: nguồn danh sách ngôn ngữ (cố định? nhập tự do?).

### SC-DRAWER-27 — Card native + expand_more mở picker (`drawer/native-lang`)
Nguồn: spec `drawer/native-lang` (icon translate + tên + `drawerNativeHint` + expand_more) · D-030
When: chạm card native → mở picker
Then: chọn ngôn ngữ mẹ đẻ (nghĩa) → card cập nhật; phụ đề giữ khoá `drawerNativeHint`.

---

## 3. Điều hướng vào/ra

### SC-DRAWER-30 — Vào drawer từ avatar
Nguồn: nav-flow ("avatar ... mở Drawer khi chạm, thay cho nút ☰ cũ")
When: chạm avatar ở app bar shell → drawer[open] mở. Then: panel hiện; nền giữ nguyên state (StatefulShellRoute).

### SC-DRAWER-31 — Vào drawer từ nhiều tab
Given: đang ở Today / Library / Stats / Profile (tab có avatar)
Then: avatar mở cùng drawer, header "Today's activity" đọc từ cùng `daily_activity` bất kể tab. ⚠ Xác nhận: avatar hiện ở mọi tab hay chỉ vài tab (nav-flow: "các tab còn lại chỉ có ... avatar").

### SC-DRAWER-32 — Ra: item điều hướng đóng drawer
Given: drawer[open]
When: chạm 1 item điều hướng (Stats/Theme/Settings)
Then: drawer đóng + push/switch tới đích tương ứng; back từ đích → về màn nền (không tự mở lại drawer). ⚠ Xác nhận: back từ Settings/Theme quay về nền hay về drawer.

### SC-DRAWER-33 — Back cứng (Android) khi drawer mở
When: drawer[open] → nhấn back hệ thống
Then: drawer đóng (không thoát app). ⚠ Xác nhận hành vi back cứng khi drawer mở.

### SC-DRAWER-34 — Back trong sub-screen add/remove
When: ở add-language/remove-language → back hệ thống HOẶC nút `drawer/*-back`
Then: quay lại drawer[open] (hoặc màn nền — ⚠ xác nhận). Không ghi DB.

### SC-DRAWER-35 — Giữ vị trí cuộn danh sách 10 item
Given: cuộn list drawer xuống, vào 1 sub-screen, back
Then: ⚠ Xác nhận: list drawer giữ vị trí cuộn hay reset (kit không nêu; mặc định drawer đóng-mở lại thường reset).

### SC-DRAWER-36 — Cuộn danh sách cặp dài (remove-language)
Given: nhiều cặp ngôn ngữ (> chiều cao viewport)
Then: list remove-language cuộn được (`layout_hint:scroll`); appbar giữ cố định.

### SC-DRAWER-37 — Deep-link
Nguồn: nav-flow ("Không deep-link ngoài v1")
Then: **N/A** — v1 không hỗ trợ deep-link vào drawer/sub-screen.

---

## 4. Nhập liệu & validation

> Drawer không có text-field tự do trong DOM spec — chọn ngôn ngữ qua **picker** (`expand_more`).
> Validation cặp ngôn ngữ (D-030) áp ở tầng domain khi bấm `drawerAddPair`.
> ⚠ **Chiều này under-driven thật (không chỉ là Open question)**: text-entry surrogate duy nhất là **language picker** (SC-DRAWER-26/27), nhưng chỉ có scenario cho **tap mở trigger** — bản thân sheet picker (`drawerLanguagePicker` "Language") **không** có element/state coverage nào: các state open/loading/empty/**search** (nếu có ô tìm), selected-vs-unselected, và dismiss đều **chưa** có scenario. Thêm SC-DRAWER-47..49 dưới đây để phủ tối thiểu; phần còn thiếu nguồn (kit chưa vẽ sheet picker) ⇒ Open questions #4/#17.

### SC-DRAWER-40 — Chưa chọn learning (rỗng)
Nguồn: spec card `drawer/learn-lang` placeholder · D-030
Given: add-language, learning chưa chọn (hiện `drawerChooseLanguage`)
When: chạm `drawerAddPair`
Then: ⚠ Xác nhận: nút xác nhận **disabled** khi thiếu learning/native, hay bấm được rồi báo lỗi? (kit không vẽ state disabled/lỗi inline). DB: không tạo cặp.

### SC-DRAWER-41 — Chưa chọn native (rỗng)
Given: learning đã chọn, native chưa chọn
Then: như SC-DRAWER-40 — không tạo `language_pairs`; ⚠ thông báo lỗi/disabled chưa có trong kit.

### SC-DRAWER-42 — learning == native (D-030)
Nguồn: D-030 (source == target → `ValidationFailure`, không tạo)
Given: chọn learning và native **cùng một** ngôn ngữ
When: chạm `drawerAddPair`
Then: DB: **không** thêm `language_pairs`. UI: ⚠ hiện lỗi gì? (kit không có surface lỗi; cần copy ARB — Open questions). Assert cốt lõi: không có dòng cặp mới.

### SC-DRAWER-43 — Mã ngôn ngữ rỗng (D-030)
Nguồn: D-030 (mã rỗng → `ValidationFailure`) · schema `language_pairs.learning_language/native_language` trimmed non-empty
Then: không tạo cặp khi giá trị rỗng/chỉ khoảng trắng. ⚠ Phụ thuộc picker cho phép giá trị rỗng không — nếu picker chỉ liệt kê hợp lệ thì nhánh này không đạt tới từ UI (ghi rõ là gap picker).

### SC-DRAWER-44 — Thêm cặp hợp lệ (happy path)
Nguồn: D-030 · schema `language_pairs`
Given: learning="한국어"(Korean), native="English", khác nhau, không rỗng
When: chạm `drawerAddPair`
Then:
  - DB: `language_pairs` +1 dòng: `learning_language`/`native_language` đã trim, `is_active` (⚠ cặp mới có tự active?), `created_at` set.
  - UI: quay lại (⚠ về drawer[open] hay remove-language?); cặp mới xuất hiện khi mở remove-language.

### SC-DRAWER-45 — Ký tự đặc biệt / CJK trong tên hiển thị cặp
Nguồn: schema (giá trị non-empty) · i18n
Given: cặp có tên CJK ("한국어 → English", "日本語 → English")
Then: hiển thị đúng glyph (không tofu) ở remove-language + dialog xoá (tiêu đề `drawerRemovePairTitle` chèn tên cặp). Xem SC-DRAWER-80.

### SC-DRAWER-46 — Trùng cặp ngôn ngữ
Nguồn: ⚠ chưa có rule cho cặp **trùng** (D-020 chỉ nói soft-dup cho **thẻ**, không cho cặp)
Given: đã tồn tại cặp "A → B", thêm lại "A → B"
Then: ⚠ Xác nhận: chặn / cảnh báo mềm / cho phép trùng? — chưa có D-xxx/business. Không đoán (Open questions).

### SC-DRAWER-47 — Picker sheet: state mở + tiêu đề + danh sách
Nguồn: ARB `drawerLanguagePicker` ("Language") · spec `drawer/learn-lang`/`native-lang` expand_more · D-030
Given: ở add-language, chạm card learning HOẶC native (SC-DRAWER-26/27)
Then:
  - UI: mở sheet/picker với tiêu đề khoá `drawerLanguagePicker`; danh sách ngôn ngữ cuộn được.
  - ⚠ Xác nhận (kit **chưa** vẽ nội dung sheet): danh sách ngôn ngữ nguồn từ đâu (cố định/asset/tự do)? có ô **search** không? có trạng thái **loading/empty** không? — Open questions #4/#17. Assert tối thiểu: sheet mở có tiêu đề đúng khoá + đóng lại được.

### SC-DRAWER-48 — Picker: chọn 1 mục (selected vs unselected) + đóng
Nguồn: spec card cập nhật sau chọn (SC-DRAWER-26/27)
Given: picker đang mở
When: chạm 1 ngôn ngữ trong danh sách
Then:
  - UI: sheet đóng; card tương ứng (learning/native) cập nhật tên + phụ đề; mục vừa chọn nếu mở lại picker hiển thị trạng thái **selected** (⚠ xác nhận có dấu chọn/tick — kit chưa vẽ).
  - DB: **chưa** ghi (chỉ ghi khi bấm `drawerAddPair` — SC-DRAWER-44).

### SC-DRAWER-49 — Picker: dismiss không chọn (scrim/back)
Nguồn: hành vi sheet mặc định · ⚠ kit chưa vẽ
Given: picker đang mở
When: chạm ngoài sheet (scrim) HOẶC back hệ thống, không chọn mục nào
Then: sheet đóng; card giữ nguyên giá trị trước đó (không đổi); DB không ghi. ⚠ Xác nhận hành vi dismiss (kit chưa nêu) — Open questions #17.

---

## 5. Lượng dữ liệu

### SC-DRAWER-50 — 0 cặp (remove-language rỗng)
Nguồn: ARB `drawerRemoveEmptyTitle`/`drawerRemoveEmptyText` · ⚠ contract kit **không** vẽ state empty
Given: `language_pairs` rỗng
When: mở remove-language
Then: UI hiện empty (khoá `drawerRemoveEmptyTitle` + `drawerRemoveEmptyText`); không dòng cặp. ⚠ Xác nhận: state empty này chưa có trong contract 3-state — cần thêm vào kit hay đây là gap.

### SC-DRAWER-51 — 1 cặp
Then: remove-language hiện đúng 1 dòng cặp + nút xoá.

### SC-DRAWER-52 — Nhiều cặp
Then: hiện N dòng; mỗi dòng "learning → native" + "M cards" + nút xoá; cuộn (SC-DRAWER-36).

### SC-DRAWER-53 — "N cards" biên: 0 / 1 / rất lớn
Nguồn: spec "1240 cards" / "430 cards" (đếm thẻ theo cặp) · D-006 (⚠ có tính thẻ ẩn không?)
Then: cặp 0 thẻ → "0 cards"; 1 thẻ → plural "1 card"; số lớn (9999+) → không tràn dòng (ellipsis/wrap). ⚠ Xác nhận: khoá ARB đếm "N cards" ở remove-language (không thấy `drawerPairCards`) + có gồm thẻ ẩn (D-006) không.

### SC-DRAWER-54 — Header words biên: 0 / 1 / nhiều
Nguồn: `drawerActivityWords` plural
Then: words=0 → "0 words"; words=1 → "1 word"; words=N → "N words" (dùng plural ARB, không nối chuỗi).

---

## 6. Async & lỗi

### SC-DRAWER-60 — loading danh sách cặp
Given: provider language-pairs chưa resolve khi mở remove-language
Then: ⚠ Xác nhận: hiện skeleton/spinner gì? — kit **không** vẽ state loading cho drawer (contract 3-state). Assert tối thiểu: không crash, không hiện số rác.

### SC-DRAWER-61 — Lỗi đọc `language_pairs` + retry
Nguồn: ARB `drawerErrorTitle`/`drawerErrorText` + `actionRetry` ("Try again") · ⚠ contract kit **không** có state error
Given: đọc `language_pairs` thất bại (`Failure` → `AsyncValue.error`)
Then: UI hiện lỗi (khoá `drawerErrorTitle` + `drawerErrorText`) + nút thử lại (`actionRetry`); chạm retry → tải lại. ⚠ state error chưa có trong contract 3-state — gap kit.

### SC-DRAWER-62 — Xoá cặp thất bại + retry
Given: chạm "Remove" nhưng thao tác cascade thất bại
Then: ⚠ Xác nhận: hiện lỗi gì? (kit dialog không có state lỗi/retry). Assert cốt lõi: cặp **vẫn còn** trong DB nếu xoá fail — cả cây (`decks`/`cards`/`card_meanings`/`srs_state`/`review_logs`/`study_sessions`) phải **nguyên vẹn** (xoá cascade phải nguyên tử trong 1 transaction; không mất một phần subtree hay mất `study_sessions` mà giữ deck).

### SC-DRAWER-63 — Local-first (không mạng)
Then: drawer + add/remove chạy hoàn toàn từ DB local (không phụ thuộc mạng); chỉ item "Sync (alpha)" mới liên quan mạng (hoãn v1, SC-DRAWER-20).

---

## 7. Persistence (DB round-trip)

### SC-DRAWER-70 — Thêm cặp → còn sau kill/relaunch
Nguồn: schema `language_pairs`
Given: SC-DRAWER-44 thêm cặp thành công
When: kill app → mở lại → mở remove-language
Then: cặp mới vẫn hiển thị (đọc lại từ `language_pairs`); `created_at` giữ nguyên.

### SC-DRAWER-71 — Xoá cặp → cascade + còn sau relaunch
Nguồn: D-024 · schema (cascade `decks`→`cards`→`card_meanings`/`srs_state`/`review_logs`, và `decks`→`study_sessions`)
Given: SC-DRAWER-24 xoá cặp có subtree (kèm ≥1 `study_sessions` đã hoàn tất trên deck của cặp)
When: kill → relaunch
Then: DB: cặp + toàn bộ `decks`/`cards`/`card_meanings`/`srs_state` thuộc cặp **vẫn mất** (không "sống lại"); `review_logs` của các thẻ đó cũng mất (cascade theo card); **`study_sessions` có `deck_id` thuộc cây decks của cặp cũng mất** (cascade theo deck, schema dòng 194/304). ⚠ `daily_activity` **không** cascade (bucket theo ngày, không có FK tới deck/pair) — số liệu ngày đã roll-up giữ nguyên; xác nhận đây là hành vi mong muốn.

### SC-DRAWER-72 — Header "Today's activity" đọc từ `daily_activity`
Nguồn: D-010 · schema `daily_activity(minutes,words)`
Given: hoàn tất phiên Học/Ôn → `daily_activity` cộng phút/từ
Then: mở drawer, header hiện đúng minutes/words theo DB; sau kill/relaunch (cùng ngày) giữ giá trị.

### SC-DRAWER-73 — Chọn cặp active (nếu drawer đổi active)
Nguồn: schema `language_pairs.is_active` (đúng 1 dòng active) · D-011
Then: ⚠ Xác nhận: drawer có cho **đổi cặp active** không (kit chỉ vẽ Add/Remove, không thấy "switch")? Nếu có, assert đúng 1 `is_active=1`. Nếu không → nhánh N/A (không có switch trong kit).

### SC-DRAWER-74 — Xoá cặp active → chuyển active
Nguồn: schema (unique partial index `is_active=1`) · D-024
Given: xoá cặp đang `is_active=1`, còn cặp khác
Then: ⚠ Xác nhận: active tự chuyển sang cặp còn lại nào? nếu xoá cặp cuối → không còn active (`libraryPairNone` "Select language pair")? Không đoán — Open questions.

---

## 8. Định dạng & i18n

### SC-DRAWER-80 — Nhãn cặp CJK render đúng
Nguồn: spec "한국어 → English" / "日本語 → English" · i18n
Then: remove-language + tiêu đề dialog `drawerRemovePairTitle` render đúng glyph Hàn/Nhật (không tofu); mũi tên "→" đúng hướng; không cắt sai giữa ký tự.

### SC-DRAWER-81 — Plural "N words" (header)
Nguồn: `drawerActivityWords`
Then: 1 → "1 word"; N → "N words" theo ARB plural; đổi locale → dùng dạng plural của locale đó.

### SC-DRAWER-82 — Plural "N cards" (dòng cặp)
Nguồn: spec "1240 cards" / "430 cards"
Then: ⚠ Xác nhận khoá ARB đếm thẻ ở remove-language (chưa thấy `drawerPairCards`) — 1 thẻ ⇒ "1 card"? Không đoán khoá; assert khi khoá được chốt.

### SC-DRAWER-83 — Item labels theo locale
Nguồn: ARB `drawerAddLanguage`/`drawerRemoveLanguage`/`drawerImport`/`drawerExport`/`drawerStats`/`drawerTheme`/`drawerSettings`
Then: đổi locale (vi/en/ja) → 7 item có khoá ARB đổi chữ tương ứng; item **FAQ/Email us/Sync** hiện chưa có khoá ARB (⚠ SC-DRAWER-18..20) → không đổi được cho tới khi thêm khoá.

### SC-DRAWER-84 — Text dài không vỡ layout
Then: tên cặp rất dài / tên ngôn ngữ dài → dòng cặp + tiêu đề dialog ellipsis/wrap (`clip` trên nhãn cặp), không đẩy nút xoá ra ngoài; item label dài → không tràn panel 320px.

---

## 9. Dark mode

### SC-DRAWER-90 — Mọi state ở dark
Nguồn: kit dark remap `--memox-*` (contract yêu cầu light+dark)
Then: 3 state (open/add-language/remove-language) + dialog xoá render đúng ở dark bằng token (không hardcode màu): panel `surface`, scrim `overlay`, nút Remove `error`/on-error, icon-tile `primary-soft`/`error-soft` đủ tương phản.

---

## 10. Responsive

### SC-DRAWER-91 — 320px → tablet + xoay
Then: panel drawer maxw 320 không tràn ở màn 320px; card add-language co giãn; list cuộn khi cao; xoay ngang: dialog xoá vẫn center + đọc được; safe-area/notch không che appbar back.

---

## 11. A11y

### SC-DRAWER-92 — Semantics & hit-area
Nguồn: ARB `drawerClose`/`drawerBack`/`drawerRemovePairLabel` · DoE #11
Then:
  - Mỗi item drawer + back + nút xoá cặp có semantic label (nút xoá dùng `drawerRemovePairLabel` chèn tên cặp — đọc "Remove 한국어 → English", không đọc rời "delete").
  - Hit-area icon-button ≥48 (spec back/delete 48x48 ✓).
  - Focus/tab order: header → 10 item theo thứ tự; trong dialog: tiêu đề → Cancel → Remove.
  - Scrim có label đóng (`drawerClose`) hoặc dismiss được bằng screen-reader. ⚠ Xác nhận label cho scrim-tap.

---

## 12. Concurrency & edge thời gian

### SC-DRAWER-95 — Double-tap item điều hướng
Given: drawer[open]
When: chạm nhanh 2 lần 1 item (vd Settings)
Then: chỉ push/switch **một** lần (không mở 2 màn / không chồng route).

### SC-DRAWER-96 — Double-tap "Remove" trong dialog
Given: dialog xoá mở
When: chạm "Remove" 2 lần nhanh
Then: cặp bị xoá **một** lần (không lỗi khi cascade lần 2 trên dòng đã mất); dialog đóng 1 lần.

### SC-DRAWER-97 — Đổi ngày lúc nửa đêm khi drawer mở
Nguồn: D-021 · `daily_activity` (bucket theo ngày máy)
Given: drawer[open] lúc 23:59 (header hiện activity hôm nay); đồng hồ qua 00:00
Then: ⚠ Xác nhận: header "Today's activity" tự đổi sang ngày mới (reset 0) hay giữ tới khi mở lại? (engagement: "tính trực tiếp từ lịch sử, chưa có job chốt ngày").

### SC-DRAWER-98 — Xoá cặp trong khi phiên học của cặp đó đang chạy
Nguồn: D-024 (cascade) · schema `study_sessions.deck_id ON DELETE CASCADE` (dòng 194) · edge concurrency
Given: đang có phiên học thuộc cặp X (màn khác), mở remove-language xoá cặp X
Then: ⚠ Xác nhận: xoá bị chặn khi cặp đang được học? hoặc phiên đang chạy xử lý ra sao khi thẻ nguồn bị cascade xoá? — chưa có rule (Open questions #14). Không đoán.
  - DB (khi xoá **được** phép chạy): các `study_sessions` **đã hoàn tất** có `deck_id` thuộc cây decks của cặp X bị xoá theo cascade (SC-DRAWER-24/71). ⚠ **Phiên đang chạy** (`study_sessions` chưa ghi — chỉ ghi khi kết thúc, schema §study_sessions "A finished counting session") thì chưa có dòng để cascade; xác nhận: khi phiên kết thúc **sau** khi deck đã bị xoá thì write `study_sessions.deck_id` trỏ tới deck không còn tồn tại sẽ **fail FK** hay bị nuốt? — chưa có rule.

---

## Open questions (⚠ cần chốt spec trước khi viết test — KHÔNG bịa)

1. **Contract thiếu state**: kit khai báo 3 state (open/add-language/remove-language) nhưng ARB có sẵn **error** (`drawerErrorTitle/Text`) và **empty** (`drawerRemoveEmptyTitle/Text`) + `actionRetry`. Cần thêm 2 state này vào kit contract, hay chúng là gap? (SC-DRAWER-50, 60, 61).
2. **FAQ / Email us / Sync (alpha)** (`drawer/item-7..9`): **không** có khoá ARB (`drawerFaq`/`drawerEmail`/`drawerSync`), không route, không D-xxx. Đích khi tap là gì? Sync alpha = placeholder do D-027 hoãn? (SC-DRAWER-18..20).
3. **Import / Export từ drawer**: route `deckImport`/`deckExport` cần `:id` (deck đích) — từ drawer chưa có deck context. Tap dẫn đâu? (SC-DRAWER-13, 14).
4. **Language picker**: nguồn danh sách ngôn ngữ (cố định / nhập tự do)? cho phép giá trị rỗng không? (SC-DRAWER-26, 27, 43).
5. **Add-language khởi tạo**: mở từ trạng thái rỗng (`drawerChooseLanguage`) hay điền sẵn cặp active? Sau khi thêm thành công quay về đâu? Cặp mới có tự `is_active`? (SC-DRAWER-02, 44).
6. **Validation surface**: khi learning==native / rỗng (D-030) — nút `drawerAddPair` disabled hay báo lỗi inline? khoá ARB thông báo lỗi? (SC-DRAWER-40..43).
7. **Trùng cặp**: thêm lại cặp "A → B" đã có — chặn / cảnh báo mềm / cho phép? (chưa có rule; D-020 chỉ cho thẻ) (SC-DRAWER-46).
8. **Đổi cặp active**: drawer có cho switch cặp active không (kit chỉ Add/Remove)? xoá cặp active thì active chuyển sang đâu? xoá cặp cuối → không còn active? (SC-DRAWER-73, 74).
9. **Nút Cancel dialog**: khoá ARB nào (không thấy `drawerCancel`)? (SC-DRAWER-25).
10. **Đếm "N cards" ở remove-language**: khoá ARB đếm thẻ (chưa thấy `drawerPairCards`)? có gồm thẻ ẩn (D-006) không? (SC-DRAWER-53, 82).
11. **Định dạng thời lượng header** "12:45": mm:ss hay hh:mm? nguồn `daily_activity.minutes` (phút) hiển thị sao? (SC-DRAWER-10).
12. **Điều hướng vào/ra**: avatar hiện ở tab nào? scrim-tap + back cứng đóng drawer? back từ add/remove về drawel[open] hay màn nền? giữ vị trí cuộn list? (SC-DRAWER-21, 31, 33, 34, 35).
13. **Nửa đêm**: header "Today's activity" chốt ngày realtime hay lazy khi mở lại? (SC-DRAWER-97).
14. **Xoá cặp khi đang học cặp đó**: chặn hay để cascade? phiên kết thúc **sau** khi deck bị xoá thì write `study_sessions.deck_id` (FK→deck đã mất) fail hay nuốt? (SC-DRAWER-98).
15. **Khoá ARB `drawerBackup` ("Backup", @desc "Drawer item: backup")**: đây là khoá **định dùng cho item-9** (DOM dán nhãn "Sync (alpha)" — vậy text kit lệch ARB, cần chốt "Backup" hay "Sync (alpha)") hay là **orphan key** cho một item drawer DOM chưa vẽ? Nếu là item-9 thì SC-DRAWER-18..20 phải sửa lại claim "items 7-9 zero ARB coverage". (Header note · SC-DRAWER-20).
16. **Khoá ARB `drawerTitle` ("Menu", @desc "Title of the drawer menu")**: DOM `open` không có node tiêu đề (header là `drawerActivityLabel`) — `drawerTitle` là title a11y/route/AppBar (chưa có surface trong kit) hay orphan? Cần một scenario/assertion khi surface được chốt. (Header note).
17. **Sheet language picker (`drawerLanguagePicker`)**: kit **chưa** vẽ nội dung sheet — nguồn danh sách ngôn ngữ, có ô search không, các state open/loading/empty/selected/dismiss ra sao? (SC-DRAWER-47..49; liên quan #4).

> Các mục ⚠ ở trên là **danh sách phải hỏi BA/spec**, không được đoán. Khi có câu trả lời → cập nhật
> scenario tương ứng + xoá cờ ⚠. Đây chính là "không bỏ sót": phần chưa rõ được **liệt kê ra**, không lờ đi.
