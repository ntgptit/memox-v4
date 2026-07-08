# Kịch bản — Theme (Cá nhân hoá giao diện) · screen `theme`

Nguồn: `docs/contracts/theme.md` [light · dark · accent-size] ·
DOM `specs/theme.md` · **không có D-xxx nào gắn màn `theme`** (decision-table không có dòng theme; personalization D-liên-quan = "—") ·
BR `business/personalization/personalization.md` [BR-1 · BR-2 · BR-3 · AC-1 · AC-2 · §10 "Câu hỏi mở: Không"] ·
nav `business/navigation/navigation-flow.md` (`theme` = `/settings/theme`, push từ Settings; **line 48 "Không deep-link ngoài v1"**) ·
**gaps `docs/agent/gaps/QUESTIONS.md` G.08** (accent single-token — nguồn quyết định accent behavior) ·
DB schema `docs/database/schema-contract.md` §settings (enum + hàng key) ·
impl `lib/data/services/drift_settings_service.dart` (default mỗi key + saveTheme atomic + Result-based) ·
DB `settings` (k–v): keys `theme.mode` · `theme.accent` · `theme.font_scale`.

> Số/tên/chuỗi trong kit là MOCK ("Theme", "학교", "school", "Study now", "Light/Dark/System",
> "Small/Medium/Large", "Color mode", "Accent color", "Text size", "PREVIEW") — assert **định dạng &
> nguồn (ARB)**, KHÔNG assert giá trị mock. Số swatch/label là minh hoạ kit, không phải hợp đồng hệ thống.
> State `light`/`dark` trong kit contract là **hai render-view của cùng một màn ở 2 theme-brightness**
> (không phải 2 state logic), state `accent-size` là view có accent thứ 2 + size Large được chọn.

## DoE — theme (12 chiều)

| # | Chiều | TT | Scenario / N/A |
|---|---|---|---|
| 1 | States (3) | ✅ | SC-THEME-01..03 |
| 2 | Elements (14 tương tác/hiển thị) | ✅ | SC-THEME-10..25 |
| 3 | Nav vào/ra | ✅ | SC-THEME-30..34 (SC-THEME-33 = **N/A**, deep-link ngoài v1 per nav-flow line 48) |
| 4 | Nhập liệu & validation | **N/A** | màn `theme` không có field nhập text — chỉ 2 segmented + 1 nhóm swatch (chọn 1 trong tập cố định). Không rỗng/dài/CJK/trùng/định-dạng. Xem SC-THEME-26 cho biên "giá trị lưu không hợp lệ / thiếu". |
| 5 | Lượng dữ liệu | **N/A một phần** | không có list động do người dùng tạo; số option là cố định theo kit. Phủ biên **tập chọn** (mỗi option = 1 lần chọn) ở mục 2 + biên giá trị lưu ở SC-THEME-26. |
| 6 | Async & lỗi | ⚠ GAP | SC-THEME-40..42 — loading = default-rồi-settle (không skeleton); **nhánh error-UI là GAP**: `saveTheme` Result-based (`guardAsync`), lỗi ra `AsyncValue.error` (không nuốt) nhưng kit **không có view lỗi** và notifier khó throw ⇒ `error` state **không drive được** (memory: kit→flutter error state unreachable). Không có assertable Then cho error-UI; chỉ còn câu hỏi sản phẩm "có localized error/retry?" (Open q #6). |
| 7 | Persistence (DB round-trip) | ✅ | SC-THEME-50..55 (SC-THEME-55 = saveTheme atomic 3-key transaction) |
| 8 | Định dạng & i18n | ✅ | SC-THEME-60..63 |
| 9 | Dark mode | ✅ | SC-THEME-70..71 |
| 10 | Responsive | ✅ | SC-THEME-80 |
| 11 | A11y | ✅ | SC-THEME-81 |
| 12 | Concurrency & edge thời gian | ✅ | SC-THEME-90..93 |

Element inventory (từ DOM spec — mỗi cái ≥1 scenario ở mục 2):
`theme/back` (icon-button arrow_back) · `theme/appbar` title "Theme" · `theme/preview` card (label "PREVIEW" · term "학교" · gloss "school" · chip "Study now") ·
`theme/mode-head` "Color mode" · `theme/mode-control` segmented ×3 (`Light` · `Dark` · `System`) ·
`theme/accent-head` "Accent color" · nhóm swatch `theme/accent-0..5` (indigo · violet · green · coral · amber · cyan; ô đang chọn có icon `check`) ·
`theme/size-head` "Text size" · `theme/size-control` segmented ×3 (`Small` · `Medium` · `Large`).

> **Accent = single-token có chủ đích (G.08), KHÔNG phải "chờ BA chốt"**: DOM có **6 swatch accent**,
> schema `theme.accent` chỉ enum **3 giá trị** (`brand`/`warm`/`cool`). Nguồn quyết định là
> `docs/agent/gaps/QUESTIONS.md` G.08: hệ token là **single-accent** — chỉ `brand` có color-token sinh ra;
> `warm`/`cool` **chỉ được lưu + preview**, accent **KHÔNG re-theme toàn app trong v1** (deferral thiết kế
> có chủ đích, cần kit định nghĩa bộ token warm/cool + regenerate `mx_*.dart` mới bật được). Vì vậy:
> (a) khoảng cách 6 swatch DOM vs 3 enum là **kit-single-accent deferral đã biết**, không phải câu hỏi BA mở;
> (b) mapping từng swatch→giá trị lưu vẫn chưa được nêu rõ (còn là gap về nhãn/giá trị — xem Open questions #1),
> nên chỉ assert "1 row, value ∈ enum", KHÔNG assert swatch#N==`warm` cho tới khi kit chốt mapping.

---

## 1. States

### SC-THEME-01 — light (mở màn ở theme sáng, giá trị đã lưu)
Nguồn: contract[light] · spec base · BR-1/BR-2 · settings keys
Given (DB): `settings` có `theme.mode`=`light`, `theme.accent`= (giá trị đã lưu), `theme.font_scale`=`medium`
When: mở `/settings/theme`
Then (UI): appbar back + title "Theme" (ARB) · preview card (PREVIEW/학교/school/Study now) · 3 section-head "Color mode"/"Accent color"/"Text size" (ARB) · segmented mode với **Light** ở trạng thái selected (bg surface + shadow + màu primary-strong) · nhóm 6 swatch với **1** swatch mang icon `check` (ô đang chọn) · segmented size với **Medium** selected. Không skeleton, không banner lỗi.
Then (DB): không ghi gì khi chỉ mở màn (read-only).
> Lưu ý: state `light` này giả định DB **đã có** `theme.mode=light` (giá trị đã lưu). Đây KHÔNG phải mặc định người dùng mới — default là `system` (SC-THEME-26), nên đừng coi "mở ở sáng" là base mặc định.

### SC-THEME-02 — dark (mở màn ở theme tối)
Nguồn: contract[dark] · spec "dark" diff · BR-1 · AC-1
Given (DB): `settings.theme.mode`=`dark`
When: mở `/settings/theme`
Then (UI): toàn màn render bằng token dark (bg/surface/text remap `--memox-*`) — theo diff kit, segmented mode: **Dark** trở thành ô selected (bg surface + shadow), **Light** mất selected. Preview card, swatch, size vẫn đủ node. Không hardcode màu.
Then (DB): read-only.
> Lưu ý: state `dark` trong kit = cùng DOM light nhưng ô selected của mode-control dịch từ Light→Dark; assert bằng **selected-index của segmented mode**, không so pixel.

### SC-THEME-03 — accent-size (accent thứ 2 + size Large được chọn)
Nguồn: contract[accent-size] · spec "accent size" diff
Given (DB): `settings` với accent = swatch #2 (violet theo diff) và `theme.font_scale`=`large`
When: mở `/settings/theme`
Then (UI) theo diff kit:
  - preview: term "학교" phóng to (font 30→38, line 45→57) và chip "Study now" đổi nền `palette-indigo`→`palette-violet` (phản ánh accent đã chọn); scrollh 749→761.
  - nhóm swatch: icon `check` **chuyển** từ `accent-0` (indigo) sang `accent-1` (violet) — đúng 1 ô có check.
  - segmented size: **Large** thành ô selected (bg surface + shadow), **Medium** mất selected.
Then (DB): read-only (state phản ánh giá trị đã lưu trước đó).
> Preview đổi màu chip theo accent, và cỡ chữ term theo size — assert **liên kết live preview ↔ lựa chọn**, nhưng mapping accent→token cụ thể (violet) là MOCK kit; xem Open questions #1.
> **Phạm vi accent (G.08)**: đổi accent chỉ ảnh hưởng **preview** (và giá trị lưu) — v1 **KHÔNG** re-theme toàn app theo accent (chỉ `brand` render); trái với font_scale/mode (áp toàn app). Assert: chọn accent ≠ brand → preview đổi + DB ghi, nhưng theming toàn app không đổi.

---

## 2. Elements (mỗi phần tử ≥1 scenario)

### SC-THEME-10 — Nút back (`theme/back`)
Nguồn: spec `theme/back` (icon-button arrow_back, mx:?)
When: chạm back
Then (UI): pop về màn trước (Settings). ⚠ Xác nhận đích pop (Settings) — nav ghi push từ Settings nên back = Settings. Assert: nút có semantic label, hit-area ≥48, tap có phản hồi.
Then (DB): không ghi.

### SC-THEME-11 — Appbar title "Theme"
Nguồn: spec `theme/appbar` title "Theme"
Then (UI): hiển thị tiêu đề màn lấy từ **ARB** (không copy "Theme" mock); text dài → ellipsis (node có `clip`), không tràn.

### SC-THEME-12 — Preview label "PREVIEW"
Nguồn: spec `theme/preview` > div "PREVIEW"
Then (UI): hiển thị nhãn preview (nguồn ARB), style tracking dương (0.5), màu text-tertiary — chỉ hiển thị, không tương tác.

### SC-THEME-13 — Preview term "학교" (CJK)
Nguồn: spec `theme/preview` > div "학교"
Then (UI): render mẫu chữ CJK (Hàn) đúng glyph (không tofu), căn giữa. ⚠ Nguồn text mẫu = MOCK kit; xác nhận preview dùng **chuỗi cố định demo** hay lấy từ thẻ thật? (Open questions #2). Cỡ chữ term phản ứng theo Text size đã chọn (SC-THEME-22).

### SC-THEME-14 — Preview gloss "school"
Nguồn: spec `theme/preview` > div "school"
Then (UI): hiển thị nghĩa mẫu (text-secondary, căn giữa) — chỉ hiển thị.

### SC-THEME-15 — Preview chip "Study now"
Nguồn: spec `theme/preview` > div "Study now" (bg `palette-indigo`, r:999)
Then (UI): chip demo dùng **màu nhấn đang chọn** làm nền (diff accent-size đổi indigo→violet), **nhưng chỉ trong preview** — đổi accent KHÔNG làm chip/nút thật ngoài preview đổi màu ở v1 (accent single-token, G.08). Chuỗi từ ARB. ⚠ Xác nhận chip có tương tác không (kit vẽ như nút nhưng nằm trong preview) — mặc định coi là **trang trí, không tap** cho tới khi chốt (Open questions #3).

### SC-THEME-16 — Section-head "Color mode"
Nguồn: spec `theme/mode-head` title "Color mode"
Then (UI): tiêu đề mục lấy ARB; đứng trên segmented mode.

### SC-THEME-17 — Segmented mode: chọn **Light**
Nguồn: spec `theme/mode-control` seg "Light" (mx:?) · BR-1/BR-3 · AC-1 · key `theme.mode`
Given: mode hiện = `dark`
When: chạm "Light"
Then (UI): ô "Light" thành selected (bg surface + shadow + primary-strong); **toàn app đổi sang sáng ngay, không restart** (AC-1/BR-3); preview card cập nhật theo.
Then (DB): `settings` row `key='theme.mode'` → `value='light'` (ghi/UPSERT).

### SC-THEME-18 — Segmented mode: chọn **Dark**
Nguồn: spec seg "Dark" · BR-1/BR-3 · AC-1
When: chạm "Dark"
Then (UI): ô "Dark" selected; app đổi tối ngay lập tức, không restart.
Then (DB): `theme.mode`=`dark`.

### SC-THEME-19 — Segmented mode: chọn **System**
Nguồn: spec seg "System" · BR-1 · AC-2 · key `theme.mode`=`system`
When: chạm "System"
Then (UI): ô "System" selected; app theo brightness của OS (AC-2). Given OS=dark ⇒ app tối; đổi OS sang sáng ⇒ app đổi sáng theo (AC-2, xem SC-THEME-92).
Then (DB): `theme.mode`=`system`.

### SC-THEME-20 — Section-head "Accent color"
Nguồn: spec `theme/accent-head` title "Accent color"
Then (UI): tiêu đề mục accent (ARB), trên card swatch.

### SC-THEME-21 — Nhóm swatch accent (`theme/accent-0..5`) — chọn 1 màu
Nguồn: spec card swatch, 6 ô (`palette-indigo/violet/green/coral/amber/cyan`), ô chọn mang icon `check` · BR-2/BR-3 · key `theme.accent`
Given: accent hiện = swatch #0 (có check)
When: chạm 1 swatch khác (vd swatch #1 violet)
Then (UI): icon `check` **di chuyển** sang ô vừa chọn — luôn đúng **1** ô có check; live preview chip "Study now" đổi sang màu vừa chọn. **Chỉ preview đổi** — theming toàn app KHÔNG đổi theo accent ở v1 (chỉ `brand` render; accent single-token, G.08).
Then (DB): `settings.theme.accent` cập nhật.
> **Phạm vi (G.08)**: accent v1 = **preview-only + persist** (không re-theme toàn app), khác mode/font_scale. Assert: sau khi chọn accent, các màn khác KHÔNG đổi tông màu.
> Giá trị lưu (`brand`/`warm`/`cool`) cho từng swatch **chưa được nêu mapping** (6 swatch DOM ≠ 3 enum schema — gap nhãn/giá trị, xem Open questions #1). Assert: (a) đúng 1 ô selected, (b) preview đổi màu, (c) có **1 dòng `theme.accent`** được ghi & giá trị nằm trong enum hợp lệ — KHÔNG assert swatch#1==`warm` tới khi kit chốt mapping.
> Sub-cases để phủ **mọi swatch** (mỗi ô ≥1 tap): SC-THEME-21a..f cho accent-0..5 — mỗi lần: đúng 1 check, preview đổi, 1 ghi DB.

### SC-THEME-22 — Section-head "Text size"
Nguồn: spec `theme/size-head` title "Text size"
Then (UI): tiêu đề mục cỡ chữ (ARB), trên segmented size.

### SC-THEME-23 — Segmented size: chọn **Small**
Nguồn: spec `theme/size-control` seg "Small" · BR-2/BR-3 · key `theme.font_scale`=`small`
When: chạm "Small"
Then (UI): ô "Small" selected; cỡ chữ toàn app + preview term co lại ngay (không restart).
Then (DB): `theme.font_scale`=`small`.

### SC-THEME-24 — Segmented size: chọn **Medium**
Nguồn: spec seg "Medium" · key `theme.font_scale`=`medium`
When: chạm "Medium"
Then (UI): ô "Medium" selected; cỡ chữ về mức vừa. Then (DB): `theme.font_scale`=`medium`.

### SC-THEME-25 — Segmented size: chọn **Large**
Nguồn: spec seg "Large" (accent-size diff: Large selected) · key `theme.font_scale`=`large`
When: chạm "Large"
Then (UI): ô "Large" selected; term "학교" phóng to (font 30→38 theo diff kit) — assert **preview phản ứng**, không assert px cụ thể. Then (DB): `theme.font_scale`=`large`.

### SC-THEME-26 — Biên: giá trị lưu thiếu / ngoài enum khi mở màn → default cụ thể
Nguồn: schema `settings` (enum `theme.mode`∈{light,dark,system} · `theme.accent`∈{brand,warm,cool} · `theme.font_scale`∈{small,medium,large}) · **impl `drift_settings_service.dart:31-36`** (fallback `_enumByName(...) ?? default` khi thiếu/ngoài-enum)
Given (biến thể): (a) chưa có row `theme.*` (người dùng mới); (b) row có `value` ngoài enum.
Then (UI): (a) và (b) đều fallback về **default cố định** cho mỗi mục — KHÔNG crash:
  - `theme.mode` → **`system`** (`?? ColorMode.system`)
  - `theme.accent` → **`brand`** (`?? AccentColor.brand`)
  - `theme.font_scale` → **`medium`** (`?? FontScale.medium`)
Then: đúng **1** ô selected mỗi mục theo default trên; segmented mode default = **System** selected (không phải Light).
> **Default là CỤ THỂ, không phải câu hỏi BA** — cố định bởi `watchTheme()` (impl trên), không cần chốt spec.
> ⚠ **Mâu thuẫn nguồn cần lưu**: default `mode=system` **trái với** ngụ ý của SC-THEME-01 (coi light là base khi mở màn). Base thật khi chưa có settings = **System** (theo OS brightness), không phải Light cứng. SC-THEME-01 chỉ đúng khi DB đã có `theme.mode=light` (giá trị đã lưu), không phải trạng thái mặc định của người dùng mới.

---

## 3. Điều hướng vào/ra

### SC-THEME-30 — Vào từ Settings (push)
Nguồn: nav-flow (`theme`=`/settings/theme`, transition=push)
Given: đang ở màn Settings
When: chạm mục dẫn tới Theme
Then (UI): push `/settings/theme`, appbar có back; màn Settings vẫn trong stack.

### SC-THEME-31 — Back bằng nút appbar → Settings
Nguồn: SC-THEME-10 · nav push
When: chạm `theme/back`
Then (UI): pop về Settings, giữ nguyên vị trí Settings.

### SC-THEME-32 — Back hệ thống (Android) / swipe-dismiss (iOS)
When: nhấn back OS / vuốt cạnh
Then (UI): pop về Settings (như SC-THEME-31). Thay đổi đã lưu vẫn giữ (persistence độc lập với điều hướng).

### SC-THEME-33 — Deep-link tới `/settings/theme` — **N/A (ngoài v1)**
Nguồn: **nav-flow line 48 "Không deep-link ngoài v1"**
Then: **N/A** — deep-link ngoài phạm vi v1 theo nav-flow (loại trừ tường minh). KHÔNG phải câu hỏi mở về back-stack: nguồn đã chốt deep-link external không hỗ trợ trong v1. Không viết test back-stack cho deep-link tới route con; nếu v2 bật deep-link mới cần định nghĩa back-stack (chèn Settings) — ghi vào backlog, không phải gap của màn theme v1.

### SC-THEME-34 — Giữ trạng thái cuộn khi rời & quay lại
Given: cuộn màn theme (nội dung cao hơn viewport — scrollh 749>716), rời sang màn khác rồi quay lại
Then (UI): ⚠ theme là màn push (không phải tab shell) — quay lại thường là **mở lại từ đầu** (không giữ scroll). Assert: mở lại hiển thị đúng giá trị đã lưu; nếu spec yêu cầu giữ scroll thì bổ sung (Open questions #5).

---

## 6. Async & lỗi

### SC-THEME-40 — loading giá trị settings
Nguồn: settings đọc từ DB (local-first) · `watchTheme()` stream
Given: provider settings chưa resolve
Then (UI): contract theme **không có** state `loading`/`error` riêng. Vì `watchTheme()` luôn map ra `ThemeSettings` với **default** khi key thiếu (SC-THEME-26: mode=system/accent=brand/font_scale=medium), khung đầu tiên đã có giá trị default hợp lệ — **không có màn skeleton riêng** cho theme. Assert: không crash, không "flash" selected nhầm rồi nhảy; nếu có 1 khung default→giá trị-đã-lưu thì đó là default→persisted, **đúng 1 selected/mục** ở mọi khung.
> **GAP (đã xác định, không phải ⚠ mở)**: kit không định nghĩa loading-view; do stream có default nên loading là "default rồi settle". Không viết test skeleton — assert tính nhất-quán-selected là đủ.

### SC-THEME-41 — Ghi settings thất bại (Result-based, không surface lỗi trong spec)
Nguồn: BR-3 (thay đổi áp dụng ngay + được lưu) · personalization **§10 "Câu hỏi mở: Không"** · impl **`drift_settings_service.dart:41`** (`saveTheme` = `guardAsync` → `Result<void>`)
Given: thao tác chọn mode/accent/size nhưng ghi DB lỗi
Then (UI): áp dụng live vẫn xảy ra (UI đổi ngay); giá trị **không bền** vì ghi lỗi.
Then (đường lỗi thực tế — KHÔNG "im lặng nuốt lỗi"): `saveTheme` bọc trong `guardAsync` → trả **`Result<void>`** (Failure), lỗi **flow qua `AsyncValue.error`** ở notifier — **không throw, không nuốt** (đúng layer-contract error handling). Đây là đường lỗi đã có, **không phải câu hỏi BA**.
> **GAP (không phải câu hỏi mở):** spec + personalization §10 ("Câu hỏi mở: Không") + BR-3 **không định nghĩa surface lỗi/retry** cho ghi theme thất bại. Kết hợp với memory note *"kit→flutter error state unreachable"* (notifier Result-based hiếm khi throw ⇒ `error` state của theme **thường không drive được**): nhánh `error` của màn theme là **GAP chưa có UI**, **không** là ⚠ chờ chốt. Framing cũ "im lặng? / surface lỗi + retry?" đã được trả lời **một phần** bởi layer-contract (lỗi ra `AsyncValue.error`, không nuốt); phần **còn thiếu** chỉ là *có hiển thị localized error/retry cho người dùng hay không* — đó mới là hạng mục sản phẩm cần bổ sung spec, ghi ở Open questions #6.
Then (DB): không có partial-write (SC-THEME-55 rollback); nếu về sau ghi lại thành công ⇒ 3 row có giá trị mới.
> **Không có assertable Then cho nhánh error-UI** vì kit chưa có view lỗi + notifier khó throw. Chiều 6 (Async & lỗi) do đó chứa **GAP tường minh**, không phải branch có Then kiểm được — xem ghi chú DoE #6.

### SC-THEME-42 — local-first (không mạng)
Nguồn: personalization = lưu cục bộ (settings), không backend
Then (UI+DB): toàn bộ chọn mode/accent/size hoạt động **offline** đầy đủ; không phụ thuộc mạng.

---

## 7. Persistence (DB round-trip)

> **saveTheme là 1 giao dịch 3-key nguyên tử** (`drift_settings_service.dart:41-46`): mỗi lần lưu theme ghi **cả 3** key (`theme.mode` + `theme.accent` + `theme.font_scale`) trong **một** `_db.transaction` (all-or-nothing). SC-THEME-50/51/52 dưới đây kiểm chứng **kết quả từng key**, nhưng lưu ý đây KHÔNG phải 3 lần UPSERT độc lập — xem SC-THEME-55 cho tính nguyên tử.

### SC-THEME-50 — Ghi `theme.mode`
Nguồn: key `theme.mode` ∈ {light,dark,system}
When: chọn từng option (SC-THEME-17..19)
Then (DB): `settings` có **đúng 1** row `key='theme.mode'`, `value` = option đã chọn (UPSERT, không sinh dòng trùng key). Ghi này nằm trong giao dịch 3-key của `saveTheme` (SC-THEME-55), không phải single-key UPSERT rời.

### SC-THEME-51 — Ghi `theme.accent`
Nguồn: key `theme.accent` ∈ {brand,warm,cool}
When: chọn 1 swatch (SC-THEME-21)
Then (DB): 1 row `key='theme.accent'`, `value` ∈ enum hợp lệ (ghi cùng giao dịch 3-key). ⚠ giá trị-theo-swatch chưa có mapping (Open questions #1).

### SC-THEME-52 — Ghi `theme.font_scale`
Nguồn: key `theme.font_scale` ∈ {small,medium,large}
When: chọn size (SC-THEME-23..25)
Then (DB): 1 row `key='theme.font_scale'`, `value` = size đã chọn (ghi cùng giao dịch 3-key).

### SC-THEME-53 — Kill & mở lại app → giữ 3 lựa chọn
Nguồn: BR-3 (bền vững) · settings persistence
Given: đã đặt mode=dark, accent=#2, font=large
When: kill app rồi mở lại (round-trip)
Then (UI): app khởi động **thẳng vào theme tối + accent + size đã lưu** (áp từ settings lúc boot); mở lại màn theme → đúng 3 ô selected khớp DB.
Then (DB): 3 row `theme.*` giữ nguyên giá trị.

### SC-THEME-54 — Không sinh dòng rác khi đổi qua lại
When: chọn Light→Dark→System→Light nhiều lần
Then (DB): vẫn **đúng 1** row `key='theme.mode'` (UPSERT theo PK `key`), value = lần chọn cuối; không tích luỹ N dòng.

### SC-THEME-55 — saveTheme nguyên tử (3-key transaction, all-or-nothing)
Nguồn: **impl `drift_settings_service.dart:41-46`** (`guardAsync` → `_db.transaction` bọc 3 `_put`)
When: 1 lần lưu theme (chọn 1 mục bất kỳ → notifier gọi `saveTheme(settings)` với đủ 3 field)
Then (DB): **cả 3** row `theme.mode`/`theme.accent`/`theme.font_scale` được ghi trong **một** giao dịch — không có trạng thái nửa-vời (ví dụ mode đổi nhưng font_scale chưa).
Then (biên rollback): nếu giao dịch **thất bại** giữa chừng ⇒ **không** key nào bị ghi dở (transaction rollback) — DB giữ nguyên 3 giá trị cũ, không lẫn 1 key mới + 2 key cũ. (Liên quan SC-THEME-41 "ghi thất bại": lỗi ghi = rollback toàn bộ, không partial-write.)

---

## 8. Định dạng & i18n

### SC-THEME-60 — Nhãn theo locale (ARB)
Given: đổi locale (vi/en/ja)
Then (UI): "Theme"/"Color mode"/"Accent color"/"Text size" + nhãn segmented (Light/Dark/System, Small/Medium/Large) đổi theo ARB, không copy chuỗi mock kit; không vỡ layout.

### SC-THEME-61 — Nhãn dài (locale dài) không vỡ segmented
Given: locale có nhãn dài hơn (vd tiếng Việt "Theo hệ thống")
Then (UI): 3 seg chia đều (grow:1 basis:0) — nhãn dài → ellipsis/wrap trong ô, không đẩy tràn ngang; segmented không overflow.

### SC-THEME-62 — Preview CJK render đúng
Nguồn: preview term "학교" (CJK)
Then (UI): glyph Hàn/Nhật render đúng ở mọi size (Small/Medium/Large) và cả light/dark, không tofu, không cắt chân chữ khi Large.

### SC-THEME-63 — N/A: plural / ngày-giờ / số
Nguồn: màn theme không có count/ngày/plural
Then: N/A — màn chỉ có nhãn tĩnh + preview; không có đại lượng đếm được. (Ghi rõ để không sót.)

---

## 9. Dark mode

### SC-THEME-70 — Mọi mục ở dark đạt tương phản
Nguồn: contract[dark] · NFR personalization (tương phản đọc được)
Then (UI): appbar, preview card, section-head, segmented (ô selected/unselected), swatch, icon check — tất cả dùng token, remap đúng ở dark; text/surface đạt contrast; không hardcode màu.

### SC-THEME-71 — Live-switch light↔dark ngay trên màn theme
Nguồn: AC-1
When: đang ở màn theme, chọn Dark
Then (UI): chính màn theme (đang mở) đổi tối **ngay** — appbar/card/segmented remap, không cần rời màn/restart.

---

## 10. Responsive

### SC-THEME-80 — 320px → tablet + xoay
Then (UI): ở 320px không overflow — card 350-wide co theo bề ngang; 3 seg vẫn chia đều; 6 swatch wrap (kit: `flex row wrap`, 5 ô hàng 1 + 1 ô hàng 2) giữ đúng khi hẹp; nội dung cao hơn viewport → cuộn được (scroll container); xoay ngang cuộn OK; safe-area/notch không che appbar/nút back.

---

## 11. A11y

### SC-THEME-81 — Semantics & hit-area
Then (UI):
  - back, mỗi seg mode (×3), mỗi swatch (×6), mỗi seg size (×3) có **semantic label** (nói rõ tên + trạng thái selected/không) và **hit-area ≥48** (swatch vẽ 40×40 → cần vùng chạm nới ≥48).
  - trạng thái selected đọc được cho screen-reader (vd "Dark, selected"); swatch chỉ khác nhau bởi **màu** phải có nhãn tên-màu (không chỉ dựa màu — a11y không phụ thuộc màu).
  - thứ tự focus/đọc: back → title → preview → Color mode(3) → Accent(6) → Text size(3).
  ⚠ Tên đọc cho từng swatch (nếu accent value = brand/warm/cool) — cần chuỗi ARB tương ứng (Open questions #1).

---

## 12. Concurrency & edge thời gian

### SC-THEME-90 — Double-tap 1 option
When: chạm nhanh 2 lần cùng 1 seg/swatch
Then (UI+DB): idempotent — chỉ 1 lần áp dụng, **1** row (UPSERT), không double-write, không nhấp nháy 2 lần.

### SC-THEME-91 — Chọn liên tiếp nhiều option nhanh
When: bấm Light→Dark→System rất nhanh
Then (DB): value = **lần bấm cuối** (không race để lại giá trị giữa chừng); UI selected = lần cuối.

### SC-THEME-92 — Mode=System, OS đổi brightness giữa chừng
Nguồn: AC-2
Given: `theme.mode`=`system`, app đang mở màn theme, OS đổi sáng→tối
Then (UI): app (và màn theme đang mở) đổi tối theo OS ngay; **không** ghi lại `theme.mode` (vẫn `system`, không tự đổi thành `dark`).
Then (DB): `theme.mode` giữ `system`.

### SC-THEME-93 — Back khi ghi đang diễn ra
When: chọn 1 option rồi lập tức back trước khi ghi DB xong
Then (UI+DB): `saveTheme` chạy trong `guardAsync`/transaction độc lập với điều hướng — back không huỷ ghi đang chạy; giao dịch hoàn tất bền vững (SC-THEME-55). Nếu ghi lỗi ⇒ rollback (không partial), lỗi ra `AsyncValue.error` (SC-THEME-41). Assert: mở lại màn theme → khớp lựa chọn cuối (nếu ghi thành công) hoặc giá trị cũ (nếu rollback), KHÔNG nửa-vời.

---

## Open questions (⚠ cần chốt spec trước khi viết test — KHÔNG bịa)

> Đã **giải quyết** (chuyển từ ⚠ sang có nguồn) — giữ lại để truy vết, KHÔNG còn chặn test:
> - **~~#4 Default mỗi mục~~ → ĐÃ CHỐT (impl)**: `watchTheme()` (`drift_settings_service.dart:31-36`) cố định default `mode=system` · `accent=brand` · `font_scale=medium` (fallback `?? default`). Không cần hỏi BA. Xem SC-THEME-26.
> - **~~#7 Deep-link~~ → N/A**: nav-flow line 48 "Không deep-link ngoài v1" — deep-link external ngoài phạm vi v1. SC-THEME-33 = N/A.
> - **~~#8 Accent scope~~ → ĐÃ CHỐT (G.08)**: accent v1 = **preview-only + persist**, KHÔNG re-theme toàn app (chỉ `brand` có token; single-accent, deferral thiết kế). Font_scale/mode thì áp toàn app. Xem SC-THEME-03/15/21.
> - **#6 Error-UI → GAP (không còn thuần ⚠)**: đường lỗi thực = `saveTheme` Result-based (`guardAsync`→`AsyncValue.error`, không nuốt); kit **không có** view lỗi và notifier khó throw ⇒ `error` state không drive được (memory: kit→flutter error state unreachable). Phần còn thiếu **duy nhất**: sản phẩm có muốn hiển thị localized error + retry không (BR-3/§10 chưa nêu). Xem SC-THEME-40/41.

**Còn mở (thực sự cần chốt spec, KHÔNG bịa):**

1. **Accent: mapping 6 swatch DOM → 3 enum** (`theme.accent`∈{brand,warm,cool}). *Behavior đã rõ (G.08: single-accent, preview-only)* — điều **còn thiếu** chỉ là mapping từng swatch (indigo/violet/…) → giá trị lưu nào + nhãn tên-màu a11y, và 3 swatch "thừa" trong v1 là gì (disabled? placeholder cho khi kit thêm token?). Đây là gap **kit/thiết kế** (kit phải định nghĩa), KHÔNG phải "chờ BA chốt hành vi". Tới khi kit chốt: chỉ assert "1 row, value ∈ enum".
2. **Preview content**: term "학교"/gloss "school"/label "PREVIEW" là chuỗi demo cố định hay lấy từ dữ liệu thật? Nguồn ARB cho preview?
3. **Chip "Study now" trong preview**: trang trí hay có tap? Nếu tap thì đi đâu?
5. **Giữ scroll/state** khi rời & quay lại màn theme (màn push, không tab shell) — mở lại từ đầu hay giữ vị trí?
6. **Error-UI cho ghi thất bại** (chỉ phần sản phẩm còn thiếu, xem ghi chú trên): BR-3/§10 không định nghĩa **có hiển thị localized error + retry** cho người dùng hay không. Đường lỗi kỹ thuật đã có (Result/AsyncValue.error, không nuốt) — chỉ thiếu quyết định UX surface.

> Các mục còn mở là **danh sách phải hỏi BA/spec hoặc chờ kit**, không đoán. Có câu trả lời → cập nhật scenario + xoá cờ.
> #1 chỉ chặn việc assert **giá trị/nhãn** `theme.accent` theo từng swatch (mapping) — hành vi (preview-only) đã chốt qua G.08; tới khi kit chốt mapping chỉ assert "1 row, value ∈ enum".
