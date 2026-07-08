# Kịch bản — Library (thư viện bộ thẻ) · screen `library`

Nguồn: `docs/contracts/library.md` [drawer · empty · error · loaded · loading · overflow-menu ·
pair-picker · play-sheet · search-active · sort-menu] · DOM `specs/library.md` ·
D-001, D-006, D-009, D-010, D-016, D-019, D-021, D-023, D-024, D-025, D-026, D-028, D-030 (D-002/D-013/D-014
gián tiếp khi chạm play-sheet) · BR `business/deck/deck-management.md` (BR-1..BR-6), `business/search/global-search.md`
(BR-1..BR-3), `business/glossary.md` (Cặp ngôn ngữ, Bộ thẻ, Số đến hạn, Tiến độ) ·
DB `decks`, `cards`, `card_meanings`, `srs_state`, `language_pairs`, `settings`, `study_sessions`, `daily_activity`.

> **D-010 (drawer "TODAY'S ACTIVITY")**: con số phút/từ trong drawer CHỈ cộng từ phiên **DueReview** và
> **NewLearn**; Game / Review (Browse) / Player **KHÔNG** đóng góp (schema-contract §`study_sessions`/`daily_activity`).
> **D-021**: bucket ngày = ngày **máy local** (`daily_activity.day` = nửa đêm UTC của ngày local, PK); cột đọc là
> `minutes` + `words`. Assert nguồn/định dạng theo hai ràng buộc này, không chỉ nêu tên bảng.

> Số/tên trong kit là MOCK ("Korean Basics", "3 decks · 412 words", "28", "한국어 English", "Learn · 20 new",
> "12:45 · 24 words") — assert **định dạng & nguồn**, KHÔNG assert giá trị mock. Chuỗi lấy từ ARB, không copy kit.
>
> **Divergence FE↔kit đã ghi nhận** (BR-6 §Ghi chú giao diện + `tool/parity/intent-ledger.json`): toolbar
> search / sort / create (nút tạo bộ thẻ) render ở **mọi state** (loaded/empty/error/loading), trong khi kit
> đặt search+sort trong `library/context` (chỉ khi có body) và FAB `library/create` chỉ ở `loaded`. Gate
> state-composition **loại 3 node này khỏi universe**. Scenario assert theo hành vi FE (luôn hiển thị), có
> chú thích khác biệt.

## DoE — library (12 chiều)

| # | Chiều | TT | Scenario / N/A |
|---|---|---|---|
| 1 | States (10) | ✅ | SC-LIBRARY-01..10 |
| 2 | Elements (DOM spec) | ✅ | SC-LIBRARY-20..48 |
| 3 | Nav vào/ra | ✅ | SC-LIBRARY-50..57 |
| 4 | Nhập liệu & validation | ✅ | SC-LIBRARY-60..67 (search field; SC-67 = truy vấn hợp lệ 0-match ⚠) · N/A cho tạo-tên-deck (field ở màn editor, không thuộc `library`) |
| 5 | Lượng dữ liệu | ✅ | SC-LIBRARY-70..75 |
| 6 | Async & lỗi | ✅ | SC-LIBRARY-80..84 |
| 7 | Persistence (DB round-trip) | ✅ | SC-LIBRARY-90..96 (SC-96 = `search.status_filter` round-trip) |
| 8 | Định dạng & i18n | ✅ | SC-LIBRARY-100..106 |
| 9 | Dark mode | ✅ | SC-LIBRARY-110 |
| 10 | Responsive | ✅ | SC-LIBRARY-111 |
| 11 | A11y | ✅ | SC-LIBRARY-112 |
| 12 | Concurrency & edge thời gian | ✅ | SC-LIBRARY-120..123 |

Element inventory (từ DOM spec — mỗi cái ≥1 scenario ở mục 2):
**appbar** `library/menu-open` (icon-button menu) · `library/overflow` (icon-button more_vert) ·
**toolbar/context** `library/search-btn` · `library/pair` (button 한국어 English, swap_horiz + expand_more) ·
`library/sort-btn` (icon-button swap_vert) · **node list** `library/node-0..4` (card: icon-tile + tên +
"N decks · N words" / "N words · N due" / "N words · N hidden" / "N words · mastered" + progress-bar +
badge số due / ✓) · **fab** `library/create` (New) · **bottom-nav** ×5 (Today·Library·Add·Stats·Profile) ·
**search-active** `library/search-dock` (search icon + `search-dock__input` + `library/search-clear`) +
"RECENT" head + `library/recent-0..N` (history icon + term) · **pair-picker** `library/scrim` +
`library/pair-sheet` (grabber + "Language pair" head + `library/pair-ko-en` [check] + `library/pair-ja-en`
[translate] + `library/pair-add` [add]) · **sort-menu** `library/sort-sheet` (`library/sort-0` A→Z +
`library/sort-1` Z→A + `library/sort-2` date-created + `library/sort-3` last-studied) · **overflow-menu**
`library/overflow-sheet` (`library/of-import` + `library/of-export` + `library/of-select` +
`library/of-settings`) · **play-sheet** `library/play-sheet` (`library/play-learn` + `library/play-review` +
`library/play-browse` + `library/play-game` + `library/play-player`) · **drawer** `drawer/panel`
(TODAY'S ACTIVITY block "12:45 · 24 words" + `drawer/item-0..9`: Add language · Remove language · Import ·
Export · Stats · Theme · FAQ · Settings · Email us · Sync alpha) · **empty** `library/empty-deck` (Create deck)
+ `library/empty-add` (Add words) · **error** `library/retry` · **loading** `mxg-skel` (toolbar-skel pill 350x48 r:999
+ card icon-tile-skel + 2 text-line skel, `bg:surface-sunken` — node kit riêng của state loading; scenario phần tử SC-LIBRARY-19).

⚠ **play-sheet không có trigger trong DOM spec `loaded`**: kit `library/node-*` không có id/nút "Play"; play-sheet
là state có thật trong contract nhưng cách mở nó (chạm card? long-press? nút Play riêng?) chưa có trong DOM spec →
liệt kê Open questions. Scenario play-sheet assert nội dung sheet, cờ ⚠ ở trigger.

---

## 1. States (mỗi state ≥1 scenario dẫn tới nó)

### SC-LIBRARY-01 — loaded (có bộ thẻ)
Nguồn: contract[loaded] · spec base · BR-5 (tổng hợp đệ quy)
Given: DB `language_pairs`(1 active), `decks`(≥1 root deck thuộc pair active), `cards`(mỗi deck ≥1 thẻ không ẩn).
When: mở tab Library.
Then:
- UI: appbar (menu + "Library" + overflow) · toolbar (search-btn + pair button hiện tên cặp active + sort-btn) ·
  danh sách card bộ thẻ (mỗi card: icon-tile, tên deck, dòng meta "N decks · N words" hoặc "N words · N due"/"N hidden"/"mastered",
  progress-bar, badge) · FAB "New" · bottom-nav[Library active, màu primary-strong]. Không skeleton, không empty/error.
- DB: đọc-only; số trên card khớp tổng hợp đệ quy từ `decks`/`cards` (BR-5) — assert **nguồn** (query DB), không assert giá trị mock.

### SC-LIBRARY-02 — empty (chưa có bộ thẻ nào)
Nguồn: contract[empty] · spec "empty" diff · BR-1
Given: DB `decks` không có row nào thuộc pair active (thư viện rỗng).
When: mở Library.
Then:
- UI: hiện `library/empty` — icon-tile (style), tiêu đề "Your library is empty" (ARB), **phụ đề mô tả (ARB)** — kit MOCK
  chuỗi "Decks and words you add will show up here. Start with a deck or import a CSV." ⇒ chuỗi này phải từ ARB, không copy
  kit (assert ở SC-LIBRARY-105), 2 nút `library/empty-deck` ("Create deck") + `library/empty-add` ("Add words"). **KHÔNG** hiện card list.
- UI (divergence FE): toolbar search/sort/create vẫn hiển thị (BR-6 §Ghi chú) — kit ẩn body-context ở empty nhưng FE giữ toolbar.
- DB: `decks` count(pair active) = 0.

### SC-LIBRARY-03 — loading (provider chưa resolve)
Nguồn: contract[loading] · spec "loading" diff
Given: provider library chưa resolve (đọc `decks` đang chờ).
When: mở Library.
Then:
- UI: hiện `mxg-skel` (skeleton) thay toolbar + 4 card khung (icon-tile skel + 2 dòng text skel), **không** số/tên thật,
  **không** badge, **không** banner, không crash. Skeleton dùng `bg:surface-sunken` (token).
- DB: chưa assert (đang chờ).

### SC-LIBRARY-04 — error (đọc thư viện thất bại)
Nguồn: contract[error] · spec "error" diff
Given: nguồn đọc `decks` thất bại (Failure → AsyncValue.error).
When: mở Library.
Then:
- UI: hiện `library/error` — icon-tile (cloud_off, error-soft), tiêu đề "Couldn't load your library" (ARB), **phụ đề (ARB)**
  — kit MOCK chuỗi "Something went wrong loading data. Check your connection and try again." ⇒ chuỗi này phải từ ARB, không
  copy kit (assert ở SC-LIBRARY-105), nút `library/retry` ("Retry", icon refresh). **KHÔNG** hiện card list.
- UI (divergence FE): toolbar vẫn hiển thị.

### SC-LIBRARY-05 — search-active (mở tìm kiếm)
Nguồn: contract[search-active] · spec "search active" diff · D-019/D-028/BR-1..2
Given: state loaded (SC-LIBRARY-01).
When: chạm `library/search-btn`.
Then:
- UI: toolbar/context bị thay bằng `library/search-dock` (icon search + input focus + `library/search-clear`);
  bên dưới hiện "RECENT" head + danh sách `library/recent-*` (mỗi item icon history + từ khoá gần đây). Bàn phím bật.
- DB: chưa ghi; danh sách recent đọc từ nguồn recent-search (⚠ nguồn lưu recent chưa có bảng/cột trong schema-contract → Open questions).
- ⚠ **DOM spec `search-active` CHỈ vẽ**: `search-dock` + "RECENT" head + `library/recent-*`. **KHÔNG có** node danh sách
  kết quả (results-list) và **KHÔNG có** node "no results / empty results". Vì vậy state này assert được RECENT/dock;
  **cách render kết quả tìm kiếm + trạng thái 0-match KHÔNG có trong DOM** → xem Open questions #5 (không assert như đã biết).

### SC-LIBRARY-06 — pair-picker (chọn cặp ngôn ngữ)
Nguồn: contract[pair-picker] · spec "pair picker" diff · D-030 · glossary "Cặp ngôn ngữ"
Given: loaded; DB `language_pairs`(≥1 row).
When: chạm `library/pair` button.
Then:
- UI: scrim `library/scrim` (bg:overlay) + bottom-sheet `library/pair-sheet` — grabber, head "Language pair" (ARB),
  các nút cặp `library/pair-ko-en` / `library/pair-ja-en` (mỗi nút icon + tên cặp + icon check ở cặp active),
  nút `library/pair-add` ("Add language").
- DB: danh sách cặp đọc từ `language_pairs`; cặp có check = row `is_active=1`. Assert **nguồn**, không assert tên mock.

### SC-LIBRARY-07 — sort-menu (chọn tiêu chí sắp xếp)
Nguồn: contract[sort-menu] · spec "sort menu" diff · D-023/BR-6
Given: loaded.
When: chạm `library/sort-btn`.
Then:
- UI: scrim + `library/sort-sheet` — grabber, head "Sort by" (ARB), 4 nút: `library/sort-0` "Alphabetical A → Z",
  `library/sort-1` "Alphabetical Z → A", `library/sort-2` "Date created (newest)", `library/sort-3` "Last studied";
  tiêu chí đang chọn có icon check.
- DB: tiêu chí đang chọn đọc từ `settings` key `deck.sort_criteria` + `deck.sort_dir`.

### SC-LIBRARY-08 — overflow-menu (menu 3-chấm)
Nguồn: contract[overflow-menu] · spec "overflow menu" diff · D-025/D-026
Given: loaded.
When: chạm `library/overflow`.
Then:
- UI: scrim + `library/overflow-sheet` — grabber, head "Library" (ARB), 4 nút: `library/of-import` ("Import cards"),
  `library/of-export` ("Export cards"), `library/of-select` ("Select multiple"), `library/of-settings` ("Settings").

### SC-LIBRARY-09 — play-sheet (menu chế độ học của một bộ thẻ)
Nguồn: contract[play-sheet] · spec "play sheet" diff · D-001/D-002/D-013/D-014/D-016
Given: loaded; một bộ thẻ có due>0 và có thẻ mới.
When: ⚠ mở play-sheet của bộ thẻ (trigger chưa xác định trong DOM spec — xem Open questions).
Then:
- UI: scrim + `library/play-sheet` — grabber, head = tên bộ thẻ (ARB/nguồn deck), 5 nút: `library/play-learn`
  ("Learn · N new"), `library/play-review` ("Review · N due"), `library/play-browse` ("Browse cards"),
  `library/play-game` ("Single game · due N / new N"), `library/play-player` ("Player").
- D-016: nếu due=0 ⇒ mục "Review" (Lặp lại) **không** hiện (chỉ Learn/Browse/Game/Player). ⚠ Xác nhận kit chỉ vẽ 1
  biến thể (due>0) → biến thể due=0 là spec đích, test đỏ tới khi build.
- DB: "N new" ≤ `settings` key `srs.new_cards_per_day` (D-018, mặc định 20); "N due" = số thẻ không ẩn due của cây con (D-001/D-006/D-009).

### SC-LIBRARY-10 — drawer (ngăn menu bên trái)
Nguồn: contract[drawer] · spec "drawer" diff
Given: loaded.
When: chạm `library/menu-open`.
Then:
- UI: overlay `drawer/overlay` + panel `drawer/panel` (maxw:320) — block "TODAY'S ACTIVITY" (icon schedule + "MM:SS" +
  "·" + "N words"), rồi danh sách `drawer/item-0..9`: Add language · Remove language · Import · Export · Stats ·
  Theme · FAQ · Settings · Email us · Sync (alpha). Mỗi item icon + nhãn (ARB).
- DB: "TODAY'S ACTIVITY" đọc từ `daily_activity` **row hôm nay** — cột `minutes` + `words` (schema-contract §`daily_activity`);
  khoá ngày `daily_activity.day` = nửa đêm UTC của **ngày máy local** (D-021). Assert **nguồn (cột) + điều kiện "hôm nay"**,
  không assert "12:45"/"24".
- **D-010**: con số này CHỈ tổng hợp phiên **DueReview + NewLearn** (`study_sessions.mode` ∈ {due_review, new_learn});
  Game / Review (Browse) / Player **KHÔNG** cộng vào `daily_activity` → assert ràng buộc mode-nguồn, không chỉ tên bảng.

---

## 2. Elements (mỗi phần tử tương tác trong DOM spec ≥1 scenario)

### SC-LIBRARY-19 — `mxg-skel` (node skeleton state loading)
Nguồn: spec state `loading` — `mxg-skel` (toolbar-skel pill 350x48 r:999 + card icon-tile-skel + 2 text-line skel, `bg:surface-sunken`)
Given: provider library đang chờ resolve (→ state SC-LIBRARY-03).
Then: node `mxg-skel` render: một pill khung thay toolbar (350x48, r:999) + card khung (icon-tile-skel + 2 dòng text-line
skel); nền dùng token `bg:surface-sunken` (không hardcode). **KHÔNG** hiển thị số/tên/badge thật, không interactive
(không nhận tap). Đây là node kit riêng của state loading — trước đây chỉ nhắc gộp trong SC-LIBRARY-03, nay có scenario
phần tử riêng để inventory phủ đủ.
Nguồn: spec `library/menu-open` (mx:?)
When: chạm.
Then: mở drawer (→ SC-LIBRARY-10). Assert: có semantic label, hit-area ≥48, mở panel một lần.

### SC-LIBRARY-21 — `library/overflow` (icon-button more_vert)
Nguồn: spec `library/overflow` (mx:?)
When: chạm.
Then: mở overflow-menu (→ SC-LIBRARY-08). Assert label + hit-area ≥48.

### SC-LIBRARY-22 — `library/search-btn` (icon-button search)
Nguồn: spec `library/search-btn` (mx:?, exceptionKind behavior)
When: chạm.
Then: mở search-active (→ SC-LIBRARY-05). Assert: hiển thị ở mọi state (divergence FE).

### SC-LIBRARY-23 — `library/pair` (button cặp ngôn ngữ)
Nguồn: spec `library/pair` (text "한국어 English", swap_horiz + expand_more)
When: chạm.
Then: mở pair-picker (→ SC-LIBRARY-06). Nhãn nút = tên cặp active (nguồn `language_pairs` is_active=1), không hardcode.
⚠ icon `swap_horiz` gợi "đảo chiều" (glossary: "Đảo chiều hiển thị được") nhưng nút mở picker — xác nhận swap_horiz là
trang trí hay có hành động đảo chiều riêng (D-011: cùng một SrsState dù đảo chiều).

### SC-LIBRARY-24 — `library/sort-btn` (icon-button swap_vert)
Nguồn: spec `library/sort-btn` (mx:?, exceptionKind behavior)
When: chạm.
Then: mở sort-menu (→ SC-LIBRARY-07). Hiển thị ở mọi state (divergence FE).

### SC-LIBRARY-25..29 — `library/node-0..4` (card bộ thẻ)
Nguồn: spec `library/node-0..4` (icon-tile + tên + meta + progress + badge)
Given: loaded, ≥1 deck.
When: chạm một card.
Then: ⚠ đích khi chạm card chưa xác định trong DOM spec — mở deck-detail của deck? hay mở play-sheet? (xem Open questions).
Assert cấu trúc hiển thị mỗi card:
- tên deck (nguồn `decks.name`);
- dòng meta: biến thể "N decks · N words" (deck có con), "N words · N due" (due>0), "N words · N hidden" (có thẻ ẩn, D-006),
  "N words · mastered" (mọi thẻ box 8) — mỗi biến thể là format ARB/plural, số từ tổng hợp đệ quy (BR-5);
- progress-bar tỉ lệ (glossary "Tiến độ" = thẻ box 8 / tổng thẻ node);
- badge = số due (glossary "Số đến hạn", thẻ không ẩn đã đến hạn, D-001/D-006) hoặc "✓" khi mastered.

### SC-LIBRARY-30 — `library/create` (FAB "New")
Nguồn: spec `library/create` (mx:?, styleExempt + behavior — luôn hiển thị)
When: chạm.
Then: mở luồng tạo (thêm bộ thẻ / thêm nội dung). ⚠ Xác nhận đích: mở deck-editor tạo mới? hay action-sheet chọn
(tạo deck / thêm từ / import)? — chưa có trong DOM spec/D-xxx. Assert: FAB hiển thị ở mọi state (divergence FE); tap phản hồi một lần.

### SC-LIBRARY-31..35 — bottom-nav ×5 (Today/Library/Add/Stats/Profile)
Nguồn: spec bottom-nav item[1..5] · MANIFEST nav_tab
When: chạm từng mục.
Then: Today→tab Today · Library(active, no-op/scroll-top) · **Add**→action (mở luồng thêm, không phải tab, không active) ·
Stats→tab Stats · Profile→tab Profile. Pill active + màu primary-strong đúng tab Library.

### SC-LIBRARY-36 — `library/search-dock__input` + `library/search-clear`
Nguồn: spec search-active `search-dock__input`, `library/search-clear` (icon close)
Given: search-active có từ khoá đã gõ.
When: chạm `library/search-clear`.
Then: xoá nội dung input, quay về gợi ý RECENT (input rỗng). Assert clear-btn có label, hit-area ≥ vùng chạm.

### SC-LIBRARY-37..39 — recent items `library/recent-*`
Nguồn: spec search-active `library/recent-0..N` (icon history + term)
Given: search-active, có ≥1 recent.
When: chạm một recent.
Then: đổ từ khoá đó vào input, chạy tìm (→ kết quả). ⚠ nguồn lưu recent-search chưa có bảng/cột trong schema-contract → Open questions.

### SC-LIBRARY-40 — `library/pair-ko-en` / `library/pair-ja-en` (chọn cặp)
Nguồn: spec pair-picker `library/pair-ko-en`, `library/pair-ja-en`
Given: pair-picker mở; cặp A đang active.
When: chạm cặp B.
Then:
- UI: sheet đóng, toolbar `library/pair` đổi nhãn sang cặp B; danh sách bộ thẻ tải lại theo cặp B (BR-3: chỉ nội dung cặp đang chọn).
- DB: `language_pairs`: row B `is_active=1`, row A `is_active=0` (unique partial index: đúng 1 active).

### SC-LIBRARY-41 — `library/pair-add` ("Add language")
Nguồn: spec pair-picker `library/pair-add` · D-030
When: chạm.
Then: mở luồng tạo cặp ngôn ngữ. D-030: nếu tạo cặp source==target hoặc mã rỗng ⇒ ValidationFailure, không tạo
(nhưng field tạo cặp không thuộc màn `library` — validation chi tiết ở màn tạo cặp). Assert: mở luồng, không crash.
⚠ đích chính xác của "Add language" (màn nào) chưa trong DOM spec.

### SC-LIBRARY-42..45 — `library/sort-0..3` (tiêu chí sắp xếp)
Nguồn: spec sort-menu `library/sort-0..3` · D-023/BR-6
Given: sort-menu mở.
When: chạm từng tiêu chí.
Then:
- `sort-0` Alphabetical A→Z ⇒ danh sách sắp theo `decks.name` tăng.
- `sort-1` Alphabetical Z→A ⇒ theo tên giảm.
- `sort-2` Date created (newest) ⇒ theo `decks.created_at` giảm (deck-management: proxy id cho "ngày tạo").
- `sort-3` Last studied ⇒ theo ngày học gần nhất (max ngày-học cây con — deck-management §Trạng thái).
- DB: lựa chọn ghi vào `settings` key `deck.sort_criteria` + `deck.sort_dir`; sheet đóng, danh sách sắp lại, tiêu chí mới có check.

### SC-LIBRARY-46 — `library/of-import` ("Import cards")
Nguồn: spec overflow `library/of-import` · D-025
When: chạm.
Then: mở luồng nhập (CSV/Excel/clipboard, chọn separator) — D-025 tách cột, preview, cảnh báo trùng (D-020). Assert: mở luồng import.

### SC-LIBRARY-47 — `library/of-export` ("Export cards")
Nguồn: spec overflow `library/of-export` · D-026
When: chạm.
Then: mở luồng xuất (CSV/Excel/copy, chọn kèm SRS). D-026: đọc/ghi `settings` `export.format`/`export.include_srs`. Assert: mở luồng export.

### SC-LIBRARY-48 — `library/of-select` + `library/of-settings`
Nguồn: spec overflow `library/of-select`, `library/of-settings`
When: chạm từng nút.
Then: `of-select` ("Select multiple") ⇒ ⚠ vào chế độ chọn nhiều (đích/hành vi chưa có D-xxx → Open questions).
`of-settings` ⇒ điều hướng sang màn Settings.

### SC-LIBRARY-49 — play-sheet items `library/play-*`
Nguồn: spec play-sheet `library/play-learn/review/browse/game/player` · D-001/D-002/D-013/D-014/D-016
Given: play-sheet mở cho một bộ thẻ.
When: chạm từng mục.
Then:
- `play-learn` ("Learn · N new") ⇒ mở NewLearn (D-002: hoàn thành 5 chặng → thẻ vào ô 1).
- `play-review` ("Review · N due") ⇒ mở DueReview N thẻ due (D-001); ẩn khi due=0 (D-016).
- `play-browse` ("Browse cards") ⇒ mở ReviewMode/duyệt thẻ (không đổi SrsState, D-007).
- `play-game` ("Single game · due N / new N") ⇒ mở game-picker 1 trong 4 game (D-013; không đổi SrsState).
- `play-player` ("Player") ⇒ mở Player tự phát (D-014; không đổi SrsState).
- DB: chỉ Learn/Review dẫn tới ghi (srs_state/review_logs/study_sessions ở màn học); Browse/Game/Player **không** ghi.

### SC-LIBRARY-49b — drawer items `drawer/item-0..9`
Nguồn: spec drawer `drawer/item-0..9`
When: chạm từng item.
Then: Add language → luồng tạo cặp (D-030) · Remove language → luồng xoá cặp · Import → luồng nhập (D-025) ·
Export → luồng xuất (D-026) · Stats → tab Stats · Theme → chọn theme (`settings` theme.*) · FAQ → màn FAQ ·
Settings → màn Settings · Email us → mở mail · Sync (alpha) → luồng đồng bộ (D-027, alpha). ⚠ đích chi tiết từng
item chưa có D-xxx riêng cho library-drawer → assert mở đúng luồng, cờ ⚠ cho item chưa có spec.

---

## 3. Điều hướng vào/ra

### SC-LIBRARY-50 — Vào Library qua bottom-nav từ Today
Nguồn: dashboard SC-DASH-22..24 (Library tab) · spec bottom-nav
Given: đang ở Today.
When: chạm nav "Library".
Then: switch-branch sang Library (StatefulShellRoute), tab Library active, không mất state Today.

### SC-LIBRARY-51 — Vào Library qua "See all" từ Today
Nguồn: dashboard SC-DASH-17 (See all → Library)
When: từ Today chạm "See all".
Then: điều hướng sang tab Library.

### SC-LIBRARY-52 — Đóng overlay (scrim / back) cho sheet & drawer
Nguồn: spec pair-sheet/sort-sheet/overflow-sheet/play-sheet `library/scrim`, drawer `drawer/overlay`
Given: một sheet hoặc drawer đang mở.
When: chạm scrim ngoài sheet HOẶC back hệ thống HOẶC swipe-down grabber.
Then: sheet/drawer đóng, quay lại state trước đó (loaded/empty/error) giữ nguyên vị trí cuộn danh sách.

### SC-LIBRARY-53 — Thoát search-active
Nguồn: spec search-active
Given: search-active.
When: back hệ thống HOẶC nút đóng search.
Then: về loaded, toolbar/context khôi phục, bàn phím tắt. ⚠ Xác nhận có nút back riêng trong search-dock hay dùng
system back (DOM spec chỉ có `library/search-clear` = xoá text, không phải đóng search).

### SC-LIBRARY-54 — Ra deck-detail từ một card
Nguồn: SC-LIBRARY-25..29 (⚠ đích card)
When: chạm một card bộ thẻ.
Then: push deck-detail của deck đó; back quay lại Library giữ vị trí cuộn. ⚠ phụ thuộc xác nhận đích card.

### SC-LIBRARY-55 — Back tại Library (tab gốc)
Nguồn: shell nav
When: nhấn back hệ thống tại Library (không overlay).
Then: ⚠ Xác nhận: về Today (tab gốc initial) hay thoát app? (Android back tại nhánh shell).

### SC-LIBRARY-56 — Giữ vị trí cuộn khi quay lại
Given: cuộn danh sách bộ thẻ xuống, push deck-detail, back.
Then: Library giữ nguyên vị trí cuộn + state (StatefulShellRoute giữ nhánh).

### SC-LIBRARY-57 — Ra Settings từ overflow / drawer
Nguồn: SC-LIBRARY-48 (`of-settings`), SC-LIBRARY-49b (drawer Settings)
When: chạm "Settings" trong overflow-sheet hoặc drawer.
Then: điều hướng sang màn Settings; back quay lại Library.

---

## 4. Nhập liệu & validation (search field — mỗi biến thể)

> Field nhập duy nhất thuộc màn `library` là `search-dock__input`. Tạo/đổi-tên tên bộ thẻ (BR-1) và tạo cặp (D-030)
> có field ở màn editor riêng, **không** thuộc `library` → N/A ở đây (validation của chúng thuộc scenario màn tương ứng).
>
> ⚠ **KHÔNG-BỊA — render kết quả tìm kiếm không có nguồn DOM**: DOM spec `library` state `search-active` **chỉ** vẽ
> `search-dock` + "RECENT" + `library/recent-*`; **không có** node danh sách kết quả (results-list) và **không có** node
> "no results / empty results" (xem SC-LIBRARY-05 + Open questions #5). Vì vậy các SC dưới đây assert **tập kết quả ở tầng
> truy vấn/domain** (thẻ nào khớp theo BR-1/D-019, tính từ DB) — **KHÔNG** assert *cách hiển thị* danh sách kết quả hay
> màn nào chứa nó (library search-active vs màn `search` riêng). "Kết quả" nghĩa là *tập thẻ khớp do query trả về*, để
> gắn với chỗ render sau khi Open questions #5 được chốt. Không đoán layout kết quả mà kit chưa định nghĩa.

### SC-LIBRARY-60 — Search rỗng / chỉ khoảng trắng
Nguồn: search-active · BR-1 (tách token theo khoảng trắng)
When: input rỗng hoặc chỉ toàn khoảng trắng.
Then: **không** chạy tìm; hiện gợi ý RECENT (không kết quả rỗng gây lỗi). Trim khoảng trắng đầu/cuối trước khi tokenize.

### SC-LIBRARY-61 — Search 1 token
Nguồn: D-019/BR-1 (token đơn = khớp chuỗi con)
Given: DB có thẻ `cards.term` hoặc `card_meanings.content` chứa token.
When: gõ 1 token.
Then: **tập kết quả query** = thẻ mà term HOẶC nghĩa chứa token (LIKE chuỗi con); gồm cả thẻ ẩn (D-028/BR-2).
⚠ Assert ở tầng query/domain (thẻ khớp), KHÔNG assert cách hiển thị danh sách (DOM chưa có results-list — Open questions #5).

### SC-LIBRARY-62 — Search nhiều token (AND, chéo term/nghĩa)
Nguồn: D-019/BR-1 · AC-4
Given: một thẻ có 1 token khớp `term`, token kia khớp `card_meanings.content` của **cùng** thẻ.
When: gõ 2 token cách khoảng trắng.
Then: thẻ đó **thuộc tập kết quả query** (AND giữa token); thẻ chỉ khớp 1 token **không** thuộc tập kết quả.
⚠ Assert ở tầng query/domain, KHÔNG assert render danh sách (Open questions #5).

### SC-LIBRARY-63 — Search CJK (Hàn/Nhật)
Nguồn: BR-1 · glossary (learning language KO/JA)
When: gõ từ khoá CJK (vd "학교" / "がっこう").
Then: khớp `term`/`content` chứa glyph CJK; render input + kết quả đúng glyph (không tofu).

### SC-LIBRARY-64 — Search ký tự đặc biệt / emoji / LIKE-wildcard
Nguồn: BR-1
When: gõ ký tự đặc biệt (`%`, `_`, `'`), emoji.
Then: khớp theo chuỗi con an toàn (escape wildcard LIKE `%`/`_` để không match toàn bộ); không crash, không SQL injection.
⚠ Xác nhận hành vi escape wildcard trong search DAO (schema-contract §Search dùng LIKE, không nêu escape) → Open questions.

### SC-LIBRARY-65 — Search quá dài (biên)
When: dán từ khoá rất dài (vd >1000 ký tự).
Then: input không vỡ layout (cuộn ngang trong dock/ellipsis); tìm vẫn chạy hoặc no-match, không crash.

### SC-LIBRARY-66 — Search có bộ lọc trạng thái (mới/đến hạn/đã thuộc)
Nguồn: D-028/BR-2 · `settings` `search.status_filter`
Given: search có truy vấn khớp nhiều thẻ ở các trạng thái khác nhau.
When: áp bộ lọc "đến hạn".
Then: chỉ còn thẻ due trong kết quả (join `srs_state.box`/`due_at`). Lựa chọn ghi `settings` key `search.status_filter`.
⚠ DOM spec `library` search-active **không** vẽ hàng chip lọc trạng thái (BR-6 §Ghi chú search nói FE giữ `search/filters`
luôn hiện, nhưng node đó không thấy trong DOM spec library) → xác nhận chip lọc thuộc màn search riêng hay library search-active.

### SC-LIBRARY-67 — Search truy vấn hợp lệ trả về 0 kết quả (zero-match)
Nguồn: BR-1/D-019 (query hợp lệ) · ⚠ **KHÔNG có node "no results" trong DOM spec** (Open questions #5, #15)
Given: DB không có thẻ nào mà term/nghĩa chứa token; truy vấn hợp lệ (không rỗng, đã trim, tokenize được).
When: gõ một token hợp lệ không khớp thẻ nào.
Then:
- **Tầng query/domain**: tập kết quả = ∅ (empty result set) — assert query trả về 0 thẻ, không lỗi, không crash.
- ⚠ **UI 0-match KHÔNG được assert**: DOM spec `search-active` không có node "no results / empty results" (state chỉ vẽ
  `search-dock` + RECENT + `recent-*`). Cách hiển thị khi tập kết quả rỗng (giữ RECENT? hiện thông báo "không có kết quả"?
  màn nào?) **chưa được kit định nghĩa** → phải chốt spec (Open questions #15) TRƯỚC khi assert render. Không đoán.
- Phân biệt với SC-LIBRARY-60 (input rỗng/whitespace ⇒ **không chạy tìm**, hiện RECENT): SC-67 là truy vấn **hợp lệ đã
  chạy** nhưng khớp 0 thẻ — hai nhánh khác nhau.

---

## 5. Lượng dữ liệu

### SC-LIBRARY-70 — 0 bộ thẻ ⇒ empty
Nguồn: contract[empty]
Then: hiện state empty (→ SC-LIBRARY-02); không card. DB `decks`(pair active) = 0.

### SC-LIBRARY-71 — 1 bộ thẻ
Then: đúng 1 card render; số liệu tổng hợp từ 1 deck (BR-5).

### SC-LIBRARY-72 — Nhiều bộ thẻ (đủ màn)
Then: danh sách nhiều card; cuộn được trong `app__body` (layout_hint:scroll).

### SC-LIBRARY-73 — Rất nhiều bộ thẻ (lazy/scroll)
Nguồn: NFR deck-management §8 (mở bộ thẻ lớn vẫn mượt)
Given: hàng trăm/nghìn deck.
Then: danh sách cuộn mượt (builder/lazy), không giật, không overflow.

### SC-LIBRARY-74 — Bộ thẻ có thẻ ẩn (D-006)
Nguồn: D-006 · glossary "Số đến hạn"
Given: deck có thẻ `hidden=1`.
Then: dòng meta biến thể "N words · N hidden" hiển thị số ẩn; badge due **không** đếm thẻ ẩn (D-006); progress/tổng
loại thẻ ẩn theo BR-5/D-006. Assert nguồn `cards.hidden`.

### SC-LIBRARY-75 — Biên số (badge lớn, mastered)
Given: deck due rất lớn (vd 9999) hoặc mọi thẻ box 8 (mastered).
Then: badge số lớn không tràn card (min-width + ellipsis/wrap); deck mastered hiển thị badge "✓" (success-soft) +
meta "N words · mastered" + progress đầy. Assert định dạng, số từ nguồn DB.

---

## 6. Async & lỗi

### SC-LIBRARY-80 — loading → loaded
Nguồn: contract[loading]→[loaded]
Then: skeleton hiện khi chờ, thay bằng danh sách thật khi `decks` resolve; không nhấp nháy sai state.

### SC-LIBRARY-81 — loading → empty
Then: nếu resolve ra 0 deck ⇒ chuyển sang empty (không kẹt skeleton).

### SC-LIBRARY-82 — error + retry
Nguồn: contract[error] · `library/retry`
Given: đọc `decks` thất bại ⇒ state error.
When: chạm `library/retry`.
Then: gọi lại nguồn; nếu thành công ⇒ loaded/empty; nếu vẫn lỗi ⇒ ở lại error. Assert retry re-trigger provider.

### SC-LIBRARY-83 — local-first (không mạng)
Nguồn: schema-contract §Scope (local-only v1)
When: tắt mạng.
Then: Library vẫn render đầy đủ từ DB local (decks/cards) — không phụ thuộc mạng; error state chỉ do đọc DB thất bại, không do mạng.

### SC-LIBRARY-84 — Đổi pair đang tải
Given: chọn cặp B (SC-LIBRARY-40) khi danh sách cặp A đang tải.
Then: huỷ tải cũ, tải cặp B; không trộn kết quả 2 cặp (BR-3). ⚠ Xác nhận hành vi huỷ/tranh chấp khi đổi pair nhanh.

---

## 7. Persistence (DB round-trip)

### SC-LIBRARY-90 — Sắp xếp bền vững qua `settings`
Nguồn: SC-LIBRARY-42..45 · D-023 · `settings` deck.sort_criteria/deck.sort_dir
Given: chọn "Alphabetical Z → A".
When: rời màn rồi quay lại / kill & mở lại app.
Then: danh sách vẫn sắp Z→A; DB `settings`(`deck.sort_criteria`, `deck.sort_dir`) giữ giá trị đã chọn (round-trip).

### SC-LIBRARY-91 — Đổi cặp ngôn ngữ bền vững
Nguồn: SC-LIBRARY-40 · `language_pairs.is_active`
Given: đổi active pair sang B.
When: kill & mở lại app.
Then: Library mở với cặp B; DB `language_pairs`: đúng 1 row `is_active=1` (= B).

### SC-LIBRARY-92 — Xoá bộ thẻ cascade (D-024)
Nguồn: D-024/BR-4 · schema referential-integrity
Given: một bộ thẻ có cây con (deck con + cards + meanings + srs_state).
When: xoá bộ thẻ + xác nhận (⚠ điểm vào xoá deck ở library chưa rõ trong DOM spec — có thể qua deck-detail/select — Open questions).
Then:
- UI: card biến mất khỏi danh sách; nếu là deck cuối ⇒ chuyển empty.
- DB: cascade — `decks`(subtree), `cards`, `card_meanings`, `srs_state`, `review_logs`, `study_sessions` của cây con bị xoá (ON DELETE CASCADE).

### SC-LIBRARY-93 — Tạo bộ thẻ phản ánh vào danh sách
Nguồn: SC-LIBRARY-30 (`library/create`) / SC-LIBRARY-02 (`library/empty-deck`)
Given: empty; tạo deck mới (tên hợp lệ, BR-1).
Then:
- UI: chuyển từ empty sang loaded, card mới xuất hiện.
- DB: `decks` +1 row (name trimmed non-empty, language_pair_id = active, parent_id NULL nếu root, created_at, sort_index).

### SC-LIBRARY-94 — Import cards phản ánh số liệu (D-025)
Nguồn: SC-LIBRARY-46 · D-025
Given: import CSV vào một deck.
When: hoàn tất import.
Then: card đích cập nhật meta "N words" tăng; DB `cards`/`card_meanings` +N row (created_at stamp import).

### SC-LIBRARY-95 — Kill & mở lại giữ danh sách
Given: loaded với N deck.
When: kill & mở lại app.
Then: Library hiển thị lại N deck + số liệu từ DB (không mất); pair active + sort giữ nguyên.

### SC-LIBRARY-96 — Bộ lọc trạng thái search bền vững (`search.status_filter`)
Nguồn: SC-LIBRARY-66 · D-028/BR-2 · `settings` key `search.status_filter`
Given: ở search-active, áp bộ lọc trạng thái (vd "đến hạn") ⇒ SC-LIBRARY-66 ghi `settings` key `search.status_filter`.
When: rời search / rời màn rồi quay lại **HOẶC** kill & mở lại app.
Then: bộ lọc "đến hạn" vẫn được áp lại từ DB; `settings`(`search.status_filter`) giữ giá trị đã chọn (round-trip qua
phiên). Assert **round-trip DB** cho khoá này (khớp ghi ở SC-66) — trước đây mục 7 chỉ có sort (SC-90) + pair (SC-91),
thiếu chiều persistence cho `search.status_filter`.
⚠ Phụ thuộc Open questions #5 (chip lọc thuộc library search-active hay màn search riêng) — key ghi/đọc vẫn `settings`
`search.status_filter` bất kể chỗ render, nên round-trip assert được ở tầng persistence.

---

## 8. Định dạng & i18n

### SC-LIBRARY-100 — Plural "N decks" / "N words" / "N due" / "N hidden"
Nguồn: spec meta lines · CHECKLIST §8 plural
Then: dòng meta dùng ARB plural: 1 vs N ("1 word" vs "N words", "1 deck" vs "N decks", "1 due" vs "N due",
"1 hidden" vs "N hidden") — không nối chuỗi thủ công. "mastered" là nhãn ARB.

### SC-LIBRARY-101 — Tên bộ thẻ CJK
Given: `decks.name` chứa Hàn/Nhật (vd "한국어 기초").
Then: card render đúng glyph CJK (không tofu), không cắt sai.

### SC-LIBRARY-102 — Tên bộ thẻ rất dài
Then: tên deck dài → ellipsis/wrap (position:clip trong DOM), không đẩy badge/progress vỡ layout.

### SC-LIBRARY-103 — Nhãn cặp ngôn ngữ theo locale
Nguồn: `library/pair` nhãn "한국어 English"
Then: tên cặp hiển thị theo nguồn `language_pairs` (learning + native), không hardcode; đổi locale UI không đổi tên
ngôn ngữ (tên ngôn ngữ là dữ liệu), nhưng chuỗi khung ("Language pair", "Sort by"...) đổi theo ARB.

### SC-LIBRARY-104 — Drawer "TODAY'S ACTIVITY" định dạng thời gian/số + cột + điều kiện "hôm nay"
Nguồn: drawer block (icon schedule + "12:45" + "24 words") · schema-contract §`daily_activity` · D-010/D-021
Then:
- Định dạng: phút định dạng MM:SS/HH:MM theo locale; "N words" plural ARB; không assert mock ("12:45"/"24").
- **Nguồn cột** (không chỉ nêu tên bảng): đọc `daily_activity.minutes` (block thời gian) + `daily_activity.words`
  (block "N words") — assert đúng cột, không chung chung "nguồn daily_activity".
- **Điều kiện "hôm nay"**: row có `day` = nửa đêm UTC của **ngày máy local** (D-021 · `daily_activity.day` PK = midnight
  UTC of local day); nếu chưa có row hôm nay ⇒ 0 phút / 0 từ. Assert biên nửa đêm (đổi ngày ⇒ đổi row) — liên hệ SC-LIBRARY-122.
- **D-010** (nguồn chặt): giá trị `minutes`/`words` chỉ tích luỹ từ phiên DueReview + NewLearn; Game/Review/Player không cộng.

### SC-LIBRARY-105 — Chuỗi khung từ ARB (không copy kit)
Nguồn: README §nguyên tắc · CHECKLIST §8
Then: mọi chuỗi tĩnh ("Library", "RECENT", "Language pair", "Sort by", "Import cards", "Create deck",
"Your library is empty", "Couldn't load your library", "Retry"...) lấy từ ARB; kit là MOCK. **Gồm cả 2 chuỗi phụ đề
empty/error** (trước đây bỏ sót khỏi danh sách phải-từ-ARB): phụ đề empty "Decks and words you add will show up here.
Start with a deck or import a CSV." (SC-LIBRARY-02) + phụ đề error "Something went wrong loading data. Check your
connection and try again." (SC-LIBRARY-04) — cả hai phải từ ARB, không copy nguyên văn kit (kit chỉ là MOCK).

### SC-LIBRARY-106 — Sort menu nhãn theo locale
Then: "Alphabetical A → Z", "Date created (newest)", "Last studied" là nhãn ARB; đổi locale ⇒ đổi chuỗi, tiêu chí giữ nguyên.

---

## 9. Dark mode

### SC-LIBRARY-110 — Mọi state ở dark
Nguồn: CHECKLIST §9 · wireframe (light+dark shots)
Then: cả 10 state (loaded/empty/error/loading/search-active/pair-picker/sort-menu/overflow-menu/play-sheet/drawer)
render đúng ở dark (token `--memox-*`, không hardcode màu); scrim `bg:overlay`, card `bg:surface`, badge `bg:primary-soft`/
`success-soft`, error `bg:error-soft` remap đúng; contrast on-* đạt.

---

## 10. Responsive

### SC-LIBRARY-111 — 320px → tablet + xoay
Nguồn: CHECKLIST §10 · NFR deck-management §8
Then: ở 320px không overflow ngang (card co, tên ellipsis, badge không tràn); sheet/drawer (maxw:320 panel) vừa màn;
tablet giãn hợp lý; xoay ngang danh sách cuộn được; safe-area/notch (bottom-nav pos:absolute) OK.

---

## 11. A11y

### SC-LIBRARY-112 — Semantics & hit-area & focus order
Nguồn: CHECKLIST §11
Then:
- Mỗi control (menu-open, overflow, search-btn, pair, sort-btn, card, FAB, nav ×5, sheet buttons, retry, clear) có
  semantic label; hit-area ≥48 (icon-button 48x48 trong DOM đạt; card đủ vùng chạm).
- Thứ tự đọc: appbar (menu → title → overflow) → toolbar (search → pair → sort) → danh sách card (tên → meta → due) → FAB → nav.
- Sheet/drawer: focus vào sheet khi mở, back/scrim đóng; screen-reader đọc card thành câu có nghĩa (tên + "N words" + "N due"),
  không đọc rời "28".
- Badge due đọc kèm ngữ cảnh ("N thẻ đến hạn"), không chỉ "28".

---

## 12. Concurrency & edge thời gian

### SC-LIBRARY-120 — Double-tap card / FAB
Nguồn: CHECKLIST §12
Then: chạm nhanh 2 lần 1 card → chỉ push/mở **một** lần (không mở 2 màn/sheet); double-tap FAB → 1 luồng tạo.

### SC-LIBRARY-121 — Mở 2 sheet chồng nhau
Given: pair-picker đang mở.
When: chạm sort-btn (hoặc overflow) ngay.
Then: ⚠ Xác nhận: sheet cũ đóng trước rồi mở sheet mới, hay chặn? (không chồng 2 scrim). Assert đúng 1 scrim/sheet tại một thời điểm.

### SC-LIBRARY-122 — Đổi ngày nửa đêm ảnh hưởng drawer activity
Nguồn: D-021 (ngày = máy local, nửa đêm) · D-010 (nguồn cộng) · drawer "TODAY'S ACTIVITY" · `daily_activity.day`
Given: drawer mở lúc 23:59 có activity hôm nay (row `daily_activity.day` = ngày local hiện tại); qua 00:00 (đổi ngày local).
Then: sau nửa đêm, "hôm nay" trỏ sang `daily_activity.day` mới ⇒ nếu chưa học ngày mới thì minutes/words = 0 (row cũ giữ
nguyên là ngày hôm qua). Con số vẫn chỉ gồm DueReview/NewLearn của ngày mới (D-010).
⚠ Xác nhận: drawer "TODAY'S ACTIVITY" **tự chốt ngày** (reset về 0 khi đang mở qua nửa đêm) hay **chờ mở lại**?
(engagement: "tính trực tiếp từ lịch sử", chưa có job chốt-ngày) → Open questions.

### SC-LIBRARY-123 — Back khi đang load / xoá đang chạy
Given: đang tải danh sách HOẶC đang xoá deck cascade.
When: back giữa chừng.
Then: không crash; thao tác xoá DB hoàn tất transaction (cascade nguyên tử) hoặc rollback nhất quán; UI không kẹt loading.
⚠ Xác nhận hành vi huỷ giữa chừng thao tác xoá cascade.

---

## Open questions (⚠ cần chốt spec trước khi viết test — KHÔNG bịa)

1. **Trigger play-sheet**: DOM spec `loaded` không có id/nút "Play" trên `library/node-*`; play-sheet là state contract có
   thật nhưng **cách mở** (chạm card / long-press / nút Play riêng) chưa có → cần chốt (ảnh hưởng SC-LIBRARY-09, -49).
2. **Đích khi chạm card** (`library/node-*`): mở deck-detail hay play-sheet? (ảnh hưởng SC-LIBRARY-25..29, -54).
3. **`library/create` FAB đích**: mở deck-editor tạo mới, hay action-sheet (tạo deck / thêm từ / import)? (SC-LIBRARY-30).
4. **Recent-search nguồn lưu**: schema-contract **không** có bảng/cột cho lịch sử tìm kiếm gần đây → recent-* lưu ở đâu?
   (settings? bảng mới? in-memory?) (SC-LIBRARY-05, -37..39).
5. **Render kết quả tìm kiếm + chip lọc — cả hai vắng mặt trong DOM**: DOM spec `library` state `search-active` **chỉ** vẽ
   `search-dock` + "RECENT" head + `library/recent-*`. **KHÔNG có** node danh sách kết quả (results-list) **và KHÔNG có**
   hàng chip lọc trạng thái (BR-6 search nói FE giữ `search/filters` luôn hiện nhưng node đó không thấy trong DOM library).
   Cần chốt: **danh sách kết quả search render ở đâu** (màn `library` search-active hay màn `search` riêng?) và chip lọc
   thuộc màn nào — TRƯỚC khi assert cách hiển thị kết quả (SC-LIBRARY-05, -61..67, -66).
6. **Đóng search-active**: chỉ có `library/search-clear` (xoá text); nút/đường thoát search (về loaded) là system-back hay
   có nút riêng? (SC-LIBRARY-53).
7. **`swap_horiz` trên `library/pair`**: trang trí hay có hành động đảo chiều hiển thị riêng (D-011)? (SC-LIBRARY-23).
8. **`library/of-select` ("Select multiple")**: hành vi chế độ chọn nhiều (xoá hàng loạt? di chuyển?) chưa có D-xxx (SC-LIBRARY-48).
9. **Điểm vào xoá bộ thẻ ở library**: D-024 cascade rõ, nhưng UI trigger xoá deck từ màn library (qua select? deck-detail?)
   chưa trong DOM spec (SC-LIBRARY-92).
10. **Drawer items đích chi tiết** (Remove language / Theme / FAQ / Email us / Sync alpha): chưa có D-xxx riêng cho từng
    item drawer-library (SC-LIBRARY-49b).
11. **Escape LIKE wildcard** (`%`, `_`) trong search DAO: schema-contract §Search nêu LIKE nhưng không nêu escape (SC-LIBRARY-64).
12. **Back tại tab Library gốc**: về Today (initial) hay thoát app? (SC-LIBRARY-55).
13. **Đổi pair khi đang tải / mở 2 sheet chồng / huỷ xoá cascade giữa chừng**: hành vi tranh chấp chưa nêu (SC-LIBRARY-84, -121, -123).
14. **State empty biến thể**: "chưa có deck nào trong cặp active" vs "chưa có cặp ngôn ngữ nào" — DOM spec chỉ 1 empty; cần tách?
15. **Trạng thái search 0 kết quả (zero-match)**: DOM spec `search-active` **không có** node "no results / empty results".
    Khi truy vấn hợp lệ khớp 0 thẻ, hiển thị gì (giữ RECENT? thông báo "không có kết quả"? ở màn nào?) chưa được kit định
    nghĩa → phải chốt TRƯỚC khi assert render 0-match (SC-LIBRARY-67). Đây vừa là điểm cần chốt spec, vừa là thiếu-node UI.

> Các mục ⚠ ở trên là **danh sách phải hỏi BA/spec**, không được đoán. Khi có câu trả lời → cập nhật scenario tương ứng
> + xoá cờ ⚠. Đây chính là "không bỏ sót": phần chưa rõ được **liệt kê ra**, không lờ đi.
