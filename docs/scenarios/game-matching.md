# Kịch bản — Matching (Ghép đôi) · screen `game-matching`

Nguồn: `docs/contracts/game-matching.md` [almost · complete · correct · playing · selected · wrong] ·
DOM `specs/game-matching.md` · D-007, D-008, D-013, D-015 (D-006/D-009/D-011 gián tiếp qua nguồn thẻ) ·
BR `business/game/game-modes.md` (BR-1..BR-5) · DB `cards`, `card_meanings`, `srs_state`, `review_logs`,
`study_sessions`, `daily_activity`, `settings`.

> Số/tên/chuỗi trong kit là MOCK ("time/love/friend", "사랑/학교", "5/5 pairs", "Round complete!",
> "Next round", "Matching") — assert **định dạng & nguồn (ARB)**, KHÔNG assert giá trị mock.
> `game-matching` là **luyện tập thuần** (BR-4): mọi journey phải assert **DB không đổi** ở
> `srs_state` / `review_logs` / `study_sessions` / `daily_activity` (D-007). Chuỗi lấy từ ARB, không copy kit.

## DoE — game-matching (12 chiều)

| # | Chiều | TT | Scenario / N/A |
|---|---|---|---|
| 1 | States (6: playing·selected·correct·wrong·almost·complete) | ✅ | SC-GAMEMATCHING-01..06 |
| 2 | Elements (hiển thị/tương tác: back · options · **title** · progress · tile(L×5+R×5) · complete-block · Next round) | ✅ | SC-GAMEMATCHING-10..17 |
| 3 | Nav vào/ra | ✅ | SC-GAMEMATCHING-30..35 |
| 4 | Nhập liệu & validation | **N/A** | màn ghép đôi không có field nhập text (chỉ tap chọn tile). Biên "nội dung tile" (rỗng/dài/CJK/trùng) gộp vào chiều 8 (SC-GAMEMATCHING-72..75) |
| 5 | Lượng dữ liệu (+ hình học grid: cols/gap/minh/border-width theo state) | ✅ | SC-GAMEMATCHING-40..45 |
| 6 | Async & lỗi | ✅ | SC-GAMEMATCHING-50..53 |
| 7 | Persistence (DB round-trip) | ✅ | SC-GAMEMATCHING-60..63 |
| 8 | Định dạng & i18n (+ typography token: font size/weight/line-height/tracking) | ✅ | SC-GAMEMATCHING-70..76 |
| 9 | Dark mode | ✅ | SC-GAMEMATCHING-80 |
| 10 | Responsive | ✅ | SC-GAMEMATCHING-81 |
| 11 | A11y | ✅ | SC-GAMEMATCHING-82 |
| 12 | Concurrency & edge thời gian | ✅ | SC-GAMEMATCHING-90..93 |

Element inventory (từ DOM spec — mỗi cái ≥1 scenario ở mục 2):
`back` (icon-button arrow_back, `game-matching/back`, mx:?) · `options` (icon-button more_horiz,
`game-matching/options`, mx:?) · **`appbar__title`** (node hiển thị riêng, `text:"Matching"`,
`font:20/700/30 tracking:-0.4`, `grow:1 basis:0 layout_hint:expanded`, `color:text` — DOM spec dòng 78-85;
là phần tử **hiển thị** trên appbar, không tương tác) · `progress` (thanh tiến độ `game-matching/progress`, nền
surface-sunken; fill `bg:primary` rộng theo tiến độ) · **cột trái** `left-0..4` (5 tile term, tap chọn) ·
**cột phải** `right-0..4` (5 tile nghĩa CJK, tap chọn) · **complete-block** (`game-matching/complete`):
`icon-tile`(celebration, `bg:success-soft`) + tiêu đề "Round complete!" + phụ đề "You matched N/N pairs…"
(`color:text-secondary`) + `next` (btn `game-matching/next` "Next round", mx:?).

> Kit KHÔNG có state `loading` / `error` / `empty`. Các chiều 6 (async/lỗi) & 5 (0 thẻ) vì vậy đa phần là
> **spec đích / Open questions** (⚠) — liệt kê, không bịa hành vi.

---

## 1. States (mỗi state ≥1 scenario dẫn tới nó)

### SC-GAMEMATCHING-01 — playing (ván đang chơi, chưa chọn gì)
Nguồn: contract[playing] · spec base · D-008/BR-2
Tiền điều kiện (Given):
  - DB: `settings`(`game.words_per_round`=5) · deck có ≥5 thẻ visible (`cards.hidden`=0), mỗi thẻ ≥1 `card_meanings`
  - Vào ván Matching qua picker (D-013) với scope mặc định
Thao tác (When): màn `gamePlay` render ván Matching
Kỳ vọng (Then):
  - UI: appbar (back + title "Matching" từ ARB + options) · thanh `progress` nền surface-sunken **chưa** có fill ·
    grid 2 cột × 5 hàng: cột trái N tile term, cột phải N tile nghĩa; mọi tile `bg:surface border:1px divider`,
    không tile nào ở trạng thái selected/correct/wrong
  - DB: `srs_state` / `review_logs` / `study_sessions` / `daily_activity` KHÔNG có dòng mới nào (D-007/BR-4)
  - ⚠ Xác nhận số tile mỗi cột = `game.words_per_round` (kit mock 5) và thứ tự tile có xáo trộn (`game.random`)?

### SC-GAMEMATCHING-02 — selected (đã chọn 1 tile, chờ ghép)
Nguồn: contract[selected] · spec "selected" diff (`bg:primary-soft color:on-primary-soft border:2px primary`)
Given: đang ở playing (SC-GAMEMATCHING-01)
When: tap **một** tile (vd một tile cột trái)
Then:
  - UI: tile được chọn đổi sang `bg:primary-soft` + viền `2px primary` + chữ `on-primary-soft`; các tile khác
    giữ nguyên `bg:surface`; chưa chấm đúng/sai (đang chờ tile thứ hai)
  - DB: không đổi (D-007)

### SC-GAMEMATCHING-03 — correct (ghép đúng một cặp)
Nguồn: contract[correct] · spec "correct" diff (`bg:success-soft border:2px success`; progress xuất hiện fill `bg:primary`)
Given: đã selected 1 tile ở cột này (SC-GAMEMATCHING-02)
When: tap tile tương ứng đúng cặp ở cột kia (term ↔ nghĩa khớp cùng `card_id`)
Then:
  - UI: **cả hai** tile của cặp chuyển `bg:success-soft` + viền `2px success` + chữ `on-success-soft`;
    border dày lên `1px → 2px` ⇒ tile cao `57 → 59px` (spec: right-0 `abs:[…169x59]` dòng 394; xem SC-GAMEMATCHING-45);
    thanh `progress` xuất hiện đoạn fill `bg:primary` (spec fill `abs:[20,80 70x8]` dòng 316-318 = 1/5 track 350px)
  - Trong snapshot `correct`, **cả hai tile vẫn còn trong DOM** (chỉ đổi style — right-0/left-1 vẫn hiện, dòng
    349-399), **chưa** bị gỡ khỏi lưới. Việc gỡ node chỉ xuất hiện ở `almost`/`complete` (SC-GAMEMATCHING-05/06/45).
  - DB: không đổi (D-007) — chỉ trạng thái ván trong bộ nhớ
  - **Spec đích (proportional invariant)**: bề rộng fill = `matched/total × track-width` (track = 350px). Ba mốc
    DOM chứng cứ mạnh: correct `70px` (1/5), almost `210px` (3/5, dòng 522), complete `350px` (5/5, dòng 851)
    ⇒ tuyến tính theo số cặp đã ghép. Assert quan hệ tỉ lệ này; con số px cụ thể là MOCK.
  - ⚠ Cơ chế + thời điểm cặp đúng "biến mất/khoá" (correct → highlight → gỡ khỏi lưới) **không** được state snapshot
    nào chứng minh (correct giữ nguyên node; chỉ almost/complete cho thấy đã gỡ) → Open question #17, KHÔNG assert
    là hành vi đã chốt.

### SC-GAMEMATCHING-04 — wrong (ghép sai một cặp)
Nguồn: contract[wrong] · spec "wrong" diff (`bg:error-soft border:2px error`) · D-015/BR-3
Given: đã selected 1 tile (SC-GAMEMATCHING-02)
When: tap tile **không khớp** cặp ở cột kia
Then:
  - UI: cả hai tile vừa chọn chuyển `bg:error-soft` + viền `2px error` + chữ `on-error-soft` (báo sai);
    sau phản hồi, cặp sai **được đưa lại hàng đợi ván** — hai tile trở về `bg:surface`, chọn được lại (D-015/BR-3:
    sai → lặp lại trong ván cho đến khi đúng); thanh progress KHÔNG tăng
  - DB: không đổi (D-007)
  - ⚠ Xác nhận: sau khi hiện wrong, tile tự bỏ chọn về playing hay giữ error đến lần tap kế? (thời lượng phản hồi?)

### SC-GAMEMATCHING-05 — almost (gần xong, còn ít cặp)
Nguồn: contract[almost] · spec "almost" diff (progress fill lớn hơn `bg:primary` ~210px; grid còn ít tile mỗi cột)
Given: đã ghép đúng phần lớn cặp, còn lại số ít (kit mock: còn ~2 tile mỗi cột)
When: tiếp tục ván sau nhiều cặp đúng
Then:
  - UI: thanh `progress` fill dài hơn (spec `210x8` = 3/5 track — xem invariant ở SC-GAMEMATCHING-03);
    grid chỉ còn các tile **chưa** ghép; layout vẫn 2 cột, không vỡ khi số tile giảm
  - **Gỡ khỏi DOM, không phải ẩn/xám**: trong diff `almost`, cả hai cột `left-0..4`/`right-0..4` bị **xoá node**
    (dòng 532-653 toàn dấu `-`) rồi thay bằng cột rút gọn `repeat:x2+(unit=2)` chỉ giữ tile còn dang dở
    (spec giữ `left-1`/`left-2` và `right-1`/`right-4` — dòng 660-706). Assert: tile đã ghép **bị loại khỏi cây
    DOM** (node bị xoá), không chỉ đổi màu/ẩn — đây là dữ kiện DOM cụ thể, không mơ hồ.
  - DB: không đổi (D-007)

### SC-GAMEMATCHING-06 — complete (ghép xong toàn bộ cặp)
Nguồn: contract[complete] · spec "complete" diff (grid biến mất; hiện `icon-tile` celebration + "Round complete!"
+ "You matched N/N pairs…" + btn `next`; progress full `bg:primary`) · D-015/BR-3
Given: mọi cặp đã ghép đúng (kể cả những cặp từng sai đã học lại đúng — D-015)
When: ghép đúng cặp cuối cùng
Then:
  - UI: grid tile thay bằng khối `game-matching/complete`: `icon-tile` (`bg:success-soft r:18`) chứa icon
    celebration (`color:on-success-soft`, dòng 862-874); tiêu đề "Round complete!" (ARB) `color:text`; phụ đề
    "matched N/N pairs" (ARB, plural + số từ DB, không copy mock) **`color:text-secondary`** (dòng 892);
    nút "Next round" (`game-matching/next`, `bg:primary` + chữ/icon `color:surface`); thanh `progress` full 100%
    `bg:primary` (dòng 850-853). Token complete-state: `bg` (nền screen/appbar), `success-soft`/`on-success-soft`
    (icon-tile), `text`/`text-secondary` (tiêu đề/phụ đề), `primary`/`surface` (nút) — đủ để SC-GAMEMATCHING-80 phủ.
  - DB: **không** ghi `study_sessions` / `daily_activity` / `review_logs` / `srs_state` (BR-4/D-007/D-010:
    Game không cộng hoạt động ngày, không đổi lịch ôn) — assert 4 bảng số dòng KHÔNG tăng so với trước ván

---

## 2. Elements (mỗi phần tử tương tác ≥1 scenario)

### SC-GAMEMATCHING-10 — Nút back (arrow_back)
Nguồn: spec `game-matching/back` (icon-button, mx:?)
When: tap back trên appbar
Then:
  - UI: pop khỏi màn `gamePlay`, quay về màn trước (picker game hoặc màn gọi ván — xem SC-GAMEMATCHING-31)
  - DB: không đổi (D-007) — thoát giữa ván không ghi gì
  - A11y: nút có semantic label (ARB), hit-area ≥48 (rel 48×48 trong spec)
  - ⚠ Xác nhận: thoát giữa ván có hỏi xác nhận (dialog) không? (không có trong kit → Open question)

### SC-GAMEMATCHING-11 — Nút options (more_horiz)
Nguồn: spec `game-matching/options` (icon-button, mx:?)
When: tap dấu 3 chấm
Then:
  - ⚠ Xác nhận đích: mở menu/sheet gì? (đổi scope? restart ván? báo lỗi thẻ?) — **không có** overlay tương ứng
    trong contract (6 state không gồm menu/sheet) và không có D-xxx cho menu **trong-ván** → **Open question**,
    KHÔNG bịa mục menu.
  - Cross-ref (để reviewer định vị): quyết định gần nhất chi phối menu là **D-013/D-016** (nội dung menu
    Play → game picker; D-016: menu KHÔNG có "Lặp lại"). Nhưng D-013/D-016 quy định menu ở **màn gọi ván**, không
    phải nút 3-chấm **trong** màn game. Vì vậy chưa thể suy nút options in-game tái dùng semantics của picker —
    vẫn để Open question #6, chỉ ghi rõ D-016 là decision gần nhất, không mở rộng.
  - Assert tối thiểu: nút có semantic label, hit-area ≥48, tap không crash.

### SC-GAMEMATCHING-12 — Thanh progress
Nguồn: spec `game-matching/progress` (nền `bg:surface-sunken r:999`; fill `bg:primary r:999`)
Then:
  - UI: playing → chưa fill; sau mỗi cặp đúng → fill tăng (SC-GAMEMATCHING-03); complete → full
  - progress là **hiển thị**, không tương tác (không tap)
  - ⚠ Xác nhận đơn vị fill: theo số cặp đã ghép hay theo % thời gian? (mặc định giả định số cặp — cần chốt)

### SC-GAMEMATCHING-13 — Tile cột trái (term) tap chọn
Nguồn: spec `left-0..4` (5 tile term, tap → selected)
When: tap một tile term
Then: tile vào state selected (SC-GAMEMATCHING-02); DB không đổi (D-007)

### SC-GAMEMATCHING-14 — Tile cột phải (nghĩa CJK) tap chọn/ghép
Nguồn: spec `right-0..4` (5 tile nghĩa; kit mock CJK "사랑/학교/음식/시간/친구")
When: sau khi đã chọn 1 tile trái, tap 1 tile phải
Then: nếu khớp `card_id` → correct (SC-GAMEMATCHING-03); nếu không → wrong (SC-GAMEMATCHING-04); DB không đổi (D-007)
  - ⚠ Xác nhận chiều ghép: bắt buộc trái(term)→phải(nghĩa), hay tap **bất kỳ** 1 trái + 1 phải theo thứ tự nào cũng được?
  - ⚠ Xác nhận: chọn 2 tile **cùng cột** có hợp lệ không? (kit chỉ minh hoạ trái↔phải)

### SC-GAMEMATCHING-15 — Nút "Next round" (complete)
Nguồn: spec `game-matching/next` (btn "Next round", icon arrow_forward, mx:?)
Given: đang ở complete (SC-GAMEMATCHING-06)
When: tap "Next round"
Then:
  - UI: bắt đầu **ván Matching mới** với tập thẻ kế tiếp theo scope/`game.words_per_round`; trở về state playing
  - DB: không đổi (D-007/BR-4) — ván mới cũng là luyện thuần
  - ⚠ Xác nhận nguồn thẻ ván kế: lấy tiếp thẻ chưa luyện trong scope? xáo lại toàn bộ? xử lý khi hết thẻ (< 5)?

### SC-GAMEMATCHING-16 — Nội dung tile lấy từ term + nghĩa của thẻ
Nguồn: spec tile text (mock) · BR §Ghép đôi ("term ↔ nghĩa") · DB `cards.term` + `card_meanings.content`
Then:
  - UI: mỗi cặp tile = `cards.term` (cột một) ↔ `card_meanings.content` (cột kia); dùng **nghĩa đầu**
    (`card_meanings.sort_index` nhỏ nhất — "first meaning is the primary shown in games", schema `card_meanings`)
  - assert **nguồn** (đọc từ DB), KHÔNG assert giá trị mock kit
  - ⚠ Xác nhận: khi thẻ có nhiều nghĩa, Matching dùng nghĩa đầu hay ngẫu nhiên 1 nghĩa?

### SC-GAMEMATCHING-17 — Tiêu đề appbar "Matching" (phần tử hiển thị)
Nguồn: spec `appbar__title` (dòng 78-85: `text:"Matching"`, `font:20/700/30 color:text tracking:-0.4`,
`grow:1 basis:0 layout_hint:expanded`, `clip`)
Then:
  - UI: appbar có node tiêu đề **riêng** ở giữa (giữa back và options), chiếm phần co giãn (`Expanded`), chữ
    `color:text`; là phần tử **hiển thị**, không tap được (không phải control)
  - chuỗi "Matching" lấy từ ARB (SC-GAMEMATCHING-70), KHÔNG copy mock kit
  - typography chốt theo spec: size 20 / weight 700 / line-height 30 / tracking -0.4 (xem SC-GAMEMATCHING-76)
  - text dài / locale khác → `clip` (spec `position: clip`): tiêu đề cắt gọn trong khung expanded, không đẩy vỡ appbar
  - A11y: tiêu đề là heading của màn (đọc trong thứ tự appbar → progress → grid, SC-GAMEMATCHING-82)

---

## 3. Điều hướng vào/ra

### SC-GAMEMATCHING-30 — Vào từ picker "Một trò chơi" → chọn Ghép đôi
Nguồn: D-013/BR-1 · navigation-flow (`game` picker → `gamePlay`)
Given: tại một nút deck, chọn Play → "Một trò chơi" → picker 4 game
When: chọn "Ghép đôi"
Then:
  - UI: push màn `gamePlay` state playing (SC-GAMEMATCHING-01) với `type`=matching
  - DB: không đổi (D-007) — vào ván không ghi gì
  - ⚠ Xác nhận: picker có bước chọn scope (BR-5: Theo giãn cách / Tất cả / Chỉ chưa thuộc) trước khi vào ván?

### SC-GAMEMATCHING-31 — Ra: back về picker/màn gọi
Nguồn: spec `game-matching/back` · navigation-flow (push)
Given: đang playing
When: tap back
Then: pop về màn trước (giữ nguyên state màn đó); DB không đổi (D-007)

### SC-GAMEMATCHING-32 — Ra: Next round giữ trong màn game
Nguồn: SC-GAMEMATCHING-15
Given: complete
When: tap Next round
Then: KHÔNG pop; ở lại `gamePlay`, reset về playing với thẻ mới (SC-GAMEMATCHING-15)

### SC-GAMEMATCHING-33 — Android back (nút hệ thống) giữa ván
Given: đang playing/selected/almost
When: nhấn back hệ thống
Then:
  - ⚠ Xác nhận: pop ngay (giống back appbar) hay hỏi xác nhận thoát? — không có dialog trong kit → Open question.
  - DB: không đổi (D-007)

### SC-GAMEMATCHING-34 — Deep-link vào thẳng ván
Nguồn: navigation-flow (`gamePlay` `/game/:nodeId/play` tham số nodeId,type,scope,random)
Given: mở deep-link tới `gamePlay` với type=matching
Then:
  - ⚠ Xác nhận: có cho deep-link trực tiếp vào ván không, hay bắt buộc qua picker? (route tồn tại nhưng luồng
    người dùng chuẩn đi qua picker) — Open question.

### SC-GAMEMATCHING-35 — Không giữ dở-dang khi rời màn
Nguồn: D-007 (Game không lưu tiến độ ván) + schema (không có bảng lưu ván game)
Given: ghép được vài cặp rồi back
When: mở lại ván Matching cùng nút
Then: ván **bắt đầu lại từ đầu** (không có bảng persist tiến độ game trong schema-contract); DB vẫn không đổi
  - ⚠ Xác nhận: đúng là không resume ván game? (không có bảng → suy ra không resume, nhưng cần chốt spec)

---

## 4. Nhập liệu & validation — N/A (xem chiều 8 cho biên nội dung tile)

Màn Matching không có field nhập text; tương tác chỉ là tap tile. Không áp dụng rỗng/dài/sai-định-dạng/trim theo
nghĩa "field". Biên **nội dung** hiển thị trên tile (rỗng/dài/CJK/trùng term) được phủ ở chiều 8
(SC-GAMEMATCHING-72..75). Soft-dup (D-020) thuộc màn tạo/nhập thẻ, không thuộc màn chơi.

---

## 5. Lượng dữ liệu

### SC-GAMEMATCHING-40 — Đúng `game.words_per_round` thẻ (mặc định 5)
Nguồn: D-008/BR-2 · `settings.game.words_per_round`
Given: `settings`(`game.words_per_round`=5), scope có ≥5 thẻ visible
Then: ván có đúng 5 cặp (5 tile mỗi cột); DB không đổi (D-007)

### SC-GAMEMATCHING-41 — Đổi `game.words_per_round` (vd 3) → ván N cặp
Nguồn: D-008 · settings
Given: `game.words_per_round`=3
Then: grid có 3 tile mỗi cột; layout không vỡ; DB không đổi
  - ⚠ Xác nhận giá trị min/max hợp lệ của `game.words_per_round` (biên dưới/trên)?

### SC-GAMEMATCHING-42 — Scope ít thẻ hơn round size
Nguồn: BR-2/BR-5 · D-006 (thẻ hidden loại khỏi nguồn)
Given: scope chỉ còn 2 thẻ visible (dù round size=5), phần còn lại `hidden`=1
Then:
  - ⚠ Xác nhận: ván dùng số thẻ có được (2 cặp) hay không đủ thì chặn mở game? — không có D-xxx quy định →
    Open question. Assert tối thiểu: thẻ `hidden`=1 KHÔNG xuất hiện làm tile (D-006).

### SC-GAMEMATCHING-43 — Nguồn đệ quy từ nút cha
Nguồn: D-009 (gộp đệ quy thẻ mọi bộ thẻ con)
Given: chọn Ghép đôi tại nút cha có thẻ nằm trong các deck con
Then: nguồn thẻ ván gộp **đệ quy** thẻ của toàn cây con (D-009); tile lấy từ tập gộp đó; DB không đổi (D-007)

### SC-GAMEMATCHING-44 — 0 thẻ trong scope
Nguồn: (không có state empty trong kit)
Given: scope không có thẻ visible nào
Then:
  - ⚠ Xác nhận: mở Ghép đôi khi 0 thẻ → hiện gì? (kit không có state empty/error cho game-matching) →
    Open question; KHÔNG bịa. Assert: không crash.

### SC-GAMEMATCHING-45 — Hình học grid & border-width theo state (parity DOM)
Nguồn: spec base grid (dòng 124-145) · diff selected/correct/wrong (border 2px, tile 59px)
Then:
  - Grid: container `grid cols:2 gap:12`, mỗi cột `flex:col gap:12`, `margin:8/0/0/0` (spec dòng 126-134)
  - Tile base: `minh:56`, `pad:16/12`, `r:12`, `border:1px divider`, cao render `57px` (spec dòng 144-145)
  - **Border-width đổi theo state** (dữ kiện DOM cụ thể, phải pin): base `border:1px` → selected/correct/wrong
    `border:2px` (spec: selected dòng 288, correct dòng 359/399, wrong dòng 449/494) ⇒ chiều cao tile `57 → 59px`
    (spec `abs:[…169x59]` các dòng 283/354/444/489). Assert: viền dày thêm 1px khi tile vào state có màu, không
    chỉ đổi màu viền.
  - progress track: `bg:surface-sunken r:999`, kích thước `350x8`; fill `bg:primary r:999` (SC-GAMEMATCHING-03/12)

---

## 6. Async & lỗi

### SC-GAMEMATCHING-50 — Local-first (không mạng)
Nguồn: local-first (schema §Scope — không có remote backend)
Then: ván Matching dựng & chơi hoàn toàn từ DB local (`cards`/`card_meanings`), không phụ thuộc mạng; DB không đổi

### SC-GAMEMATCHING-51 — Loading khi dựng ván
Nguồn: (kit KHÔNG có state loading cho game-matching)
Then:
  - ⚠ Xác nhận: trong lúc đọc thẻ dựng ván có skeleton/placeholder không? Kit chỉ có 6 state chơi, **không**
    có `loading` → Open question; nếu build thêm loading phải bổ sung kit trước (kit-first).

### SC-GAMEMATCHING-52 — Lỗi đọc thẻ (query thất bại)
Nguồn: (kit KHÔNG có state error cho game-matching)
Then:
  - ⚠ Xác nhận: khi đọc `cards`/`card_meanings` lỗi → hiện gì? Kit không có `error` state → Open question;
    error phải flow `Failure`→`AsyncValue.error` (CLAUDE.md) nhưng bề mặt UI cần kit định nghĩa trước.

### SC-GAMEMATCHING-53 — Sai + học lại (retry trong ván)
Nguồn: D-015/BR-3
Given: ghép sai một cặp (SC-GAMEMATCHING-04)
When: cặp sai quay lại hàng đợi, người chơi thử lại đến khi đúng
Then: ván chỉ đạt complete khi **mọi** cặp đã ghép đúng (D-015); progress chỉ tăng theo cặp đúng; DB không đổi (D-007)

---

## 7. Persistence (DB round-trip) — assert "KHÔNG ghi" là hợp đồng chính

### SC-GAMEMATCHING-60 — Chơi xong KHÔNG đổi srs_state
Nguồn: D-007/BR-4 · schema `srs_state`
Given: chụp `srs_state`(box/due_at/last_reviewed_at) của các thẻ trước ván
When: chơi trọn ván tới complete (kể cả nhiều lần sai)
Then: `srs_state` của mọi thẻ **y hệt** trước ván (box, due_at, last_reviewed_at không đổi) — D-007

### SC-GAMEMATCHING-61 — KHÔNG ghi review_logs / study_sessions
Nguồn: D-007/D-010 · schema `review_logs`, `study_sessions`
Then: sau ván, `review_logs` và `study_sessions` **không** có dòng mới (Game không phải DueReview/NewLearn)

### SC-GAMEMATCHING-62 — KHÔNG cộng daily_activity
Nguồn: D-010/BR-4 · schema `daily_activity`
Given: chụp `daily_activity`(day hôm nay: minutes/words) trước ván
Then: sau ván, `minutes`/`words` hôm nay **không tăng** (Game không cộng hoạt động ngày)

### SC-GAMEMATCHING-63 — Kill & mở lại app sau khi chơi Matching
Nguồn: D-007 (không persist ván) + round-trip
Given: chơi tới complete rồi kill app
When: mở lại app
Then: KHÔNG có dấu vết ván trong DB (srs/logs/sessions/activity nguyên trạng); mở lại Matching = ván mới từ đầu

---

## 8. Định dạng & i18n

### SC-GAMEMATCHING-70 — Chuỗi UI từ ARB, không copy mock
Nguồn: spec (mọi "..." là MOCK) · CLAUDE.md (strings từ ARB)
Then: "Matching" (title), "Round complete!", "You matched N/N pairs…", "Next round" đều lấy từ ARB;
đổi locale (vi/en/ja) → đổi bản dịch; không hiện chuỗi kit cứng

### SC-GAMEMATCHING-71 — Plural số cặp ở complete
Nguồn: complete phụ đề "matched N/N pairs" · CHECKLIST §8 plural
Then: 1 cặp ⇒ dạng số ít, N cặp ⇒ dạng số nhiều (ARB plural, không nối chuỗi); số lấy từ tổng cặp ván (DB), không mock

### SC-GAMEMATCHING-72 — Term/nghĩa CJK render đúng (Hàn/Nhật)
Nguồn: spec right tiles CJK ("사랑/학교…") · CHECKLIST §8 CJK
Given: thẻ có term/nghĩa Hàn ("사과") và Nhật ("りんご")
Then: tile render đúng glyph CJK (không tofu), căn giữa, không cắt sai; cả hai cột đều đúng

### SC-GAMEMATCHING-73 — Nội dung tile dài → wrap/ellipsis không vỡ ô
Nguồn: tile `minh:56` `pad:16/12` · CHECKLIST §8 text dài
Given: một term/nghĩa rất dài
Then: chữ trong tile wrap hoặc ellipsis trong khung; tile không tràn cột, không đè tile khác

### SC-GAMEMATCHING-74 — Nội dung tile rỗng/khoảng trắng (biên dữ liệu)
Nguồn: schema `cards.term`/`card_meanings.content` (trimmed non-empty theo domain)
Then:
  - Theo schema, `term`/`content` đã trimmed non-empty ở tầng domain ⇒ tile luôn có nội dung.
  - ⚠ Xác nhận: nếu dữ liệu cũ/nhập lỗi lọt term/nghĩa rỗng, Matching xử lý sao (bỏ thẻ khỏi nguồn?)? Open question.

### SC-GAMEMATCHING-75 — Hai thẻ trùng term / trùng nghĩa trong cùng ván
Nguồn: D-020 (soft-dup cho phép trùng term trong deck) · BR §Ghép đôi
Given: scope chứa 2 thẻ cùng `term` (khác `card_id`) rơi vào cùng ván
Then:
  - ⚠ Xác nhận: ghép đúng dựa trên `card_id` (không chỉ so text) để 2 tile trùng chữ không ghép nhầm?
    Cần chốt: tile mang khoá theo `card_id`, không so sánh chuỗi. Open question (BR chưa nêu rõ với Matching).

### SC-GAMEMATCHING-76 — Typography token pin theo DOM spec (style-parity)
Nguồn: spec font/weight/line-height/tracking (mọi node text) — parity chống drift kiểu chữ
Then (assert đúng token typography, KHÔNG assert giá trị chuỗi mock):
  - Tile term/nghĩa (`left/right-*`): `font:15/700/23` (size 15 / weight 700 / line-height 23), `text:center` (dòng 145 v.v.)
  - Tiêu đề appbar `appbar__title`: `font:20/700/30` + `tracking:-0.4` (dòng 85)
  - Tiêu đề complete "Round complete!": `font:20/800/30` + `tracking:-0.4` (dòng 886) — **weight 800**, khác title 700
  - Phụ đề complete: `font:15/400/23` `color:text-secondary` (dòng 892)
  - Nút "Next round": span `font:15/700` (dòng 914), icon arrow_forward `font:20/400` (dòng 908)
  - Icon back/options: `font:24/400`; icon celebration: `font:32/400`
  - Đây là điểm mù style-parity (per MEMORY note): token-diff dễ bỏ sót size/weight/line-height/tracking ⇒ pin rõ.
  - ⚠ font-family không nêu trong spec (chỉ size/weight/lh/tracking) → dùng theme mặc định, không đoán family.

---

## 9. Dark mode

### SC-GAMEMATCHING-80 — Cả 6 state ở light + dark
Nguồn: contract 6 state · wireframe (cột light/dark) · CHECKLIST §9
Then: playing/selected/correct/wrong/almost/complete render đúng ở **cả** light & dark bằng token; KHÔNG hardcode
màu; contrast selected/correct/wrong đạt. Token phải phủ (đầy đủ cho **cả 6 state**, bao gồm complete):
  - Nền & appbar/title: `bg` (screen + appbar, spec dòng 44/49/57), `text` (icon + title + tiêu đề complete)
  - progress: `surface-sunken` (track), `primary` (fill)
  - tile base: `surface` (nền), `divider` (viền), `text` (chữ)
  - selected: `primary-soft` / `on-primary-soft` / `primary` (viền)
  - correct: `success-soft` / `on-success-soft` / `success` (viền)
  - wrong: `error-soft` / `on-error-soft` / `error` (viền)
  - **complete-block**: `success-soft` (icon-tile nền) + `on-success-soft` (icon celebration), `text` (tiêu đề),
    **`text-secondary`** (phụ đề), `primary` (nút) + `surface` (chữ/icon trong nút)

---

## 10. Responsive

### SC-GAMEMATCHING-81 — 320px → tablet + xoay
Nguồn: grid 2 cột (spec) · CHECKLIST §10
Then:
  - 320px: grid 2 cột không overflow; tile co giãn theo bề rộng; chữ trong tile không tràn
  - complete: khối tiêu đề + nút "Next round" (maxw:220 cho block text) căn giữa, không tràn
  - xoay ngang / tablet: nội dung cuộn được (body `layout_hint:scroll`), safe-area/notch OK; grid không giãn xấu
  - ⚠ Xác nhận: tablet có đổi số cột / kích thước tile không? (kit chỉ đo 390px)

---

## 11. A11y

### SC-GAMEMATCHING-82 — Semantics & thao tác
Nguồn: CHECKLIST §11 · spec (back/options/tile/next là control)
Then:
  - back / options / mỗi tile / "Next round" có semantic label (ARB); hit-area ≥48 (tile minh:56; nút back/options 48×48; next minh:48)
  - trạng thái tile đọc được: selected/correct/wrong phải truyền đạt qua semantics (không chỉ bằng màu — WCAG)
  - thứ tự đọc hợp lý: appbar → progress → cột trái↔phải theo hàng; complete: tiêu đề → phụ đề → nút
  - ⚠ Xác nhận: cặp đúng "biến mất" có thông báo cho screen-reader (live region "matched")? Open question.

---

## 12. Concurrency & edge thời gian

### SC-GAMEMATCHING-90 — Double-tap cùng một tile
Nguồn: CHECKLIST §12 · state selected
Given: playing
When: tap nhanh 2 lần **cùng** tile
Then:
  - ⚠ Xác nhận: tap lần 2 = bỏ chọn (toggle về playing) hay giữ selected? — kit không mô tả toggle → Open question.
  - DB không đổi (D-007)

### SC-GAMEMATCHING-91 — Tap nhanh 2 tile khác cột (trước khi hiệu ứng chạy xong)
Nguồn: CHECKLIST §12
Given: đã selected 1 tile
When: tap tile thứ hai rồi tap tile thứ ba gần như tức thì
Then:
  - ⚠ Xác nhận: khoá input trong lúc đang chấm correct/wrong (tránh chọn chồng)? — cần chốt để tránh ghép nhầm.
    Assert tối thiểu: không crash; không có trạng thái "2 cặp cùng lúc" không hợp lệ.

### SC-GAMEMATCHING-92 — Back khi đang ở giữa hiệu ứng correct/wrong
Nguồn: CHECKLIST §12
When: tap back đúng lúc animation correct/wrong đang chạy
Then: pop an toàn, không crash; DB không đổi (D-007)

### SC-GAMEMATCHING-93 — Đổi ngày lúc nửa đêm khi đang chơi
Nguồn: CHECKLIST §12 · D-010/D-021 (Game không cộng activity)
Given: đang chơi Matching lúc 23:59, đồng hồ qua 00:00
Then: vì Game **không** cộng `daily_activity` (D-010/BR-4), việc đổi ngày **không** ảnh hưởng ván; không ghi gì cho
cả ngày cũ lẫn mới; streak không đổi do ván này (D-021 chỉ tính DueReview/NewLearn)

---

## Open questions (⚠ cần chốt spec trước khi viết test — KHÔNG bịa)

1. **Số tile & xáo trộn**: số tile mỗi cột = `game.words_per_round` (mock 5)? Thứ tự tile xáo theo `game.random`?
2. **Chiều ghép**: bắt buộc trái(term)→phải(nghĩa) hay tap 1 trái + 1 phải theo thứ tự bất kỳ? Chọn 2 tile cùng cột có hợp lệ?
3. **Khoá ghép theo `card_id`**: ghép đúng dựa trên id thẻ (không so text) để tile trùng term/nghĩa (D-020) không ghép nhầm?
4. **Nghĩa dùng cho tile**: khi thẻ nhiều nghĩa, Matching dùng nghĩa đầu (`sort_index` nhỏ nhất) hay ngẫu nhiên?
5. **progress**: spec đích đã đặt = `matched/total × 350px` (3 mốc DOM 70/210/350 = 1/5·3/5·5/5 — SC-GAMEMATCHING-03);
   chỉ còn cần BA xác nhận đơn vị là **số cặp** (không phải % thời gian) và không có easing/animation khác.
6. **Nút options (3 chấm)**: mở gì? Không có overlay trong contract 6 state, không có D-xxx.
7. **Thoát giữa ván**: back appbar / Android back có hỏi xác nhận (dialog)? Không có dialog trong kit.
8. **State loading / error / empty**: kit chỉ có 6 state chơi — khi dựng ván (loading), đọc thẻ lỗi (error),
   hoặc scope 0 thẻ (empty) thì hiện gì? Nếu cần, phải bổ sung kit trước (kit-first).
9. **wrong feedback**: sau khi hiện error, tile tự bỏ chọn về playing hay giữ đến tap kế? Thời lượng phản hồi?
10. **Next round**: nguồn thẻ ván kế (lấy tiếp thẻ chưa luyện / xáo lại / xử lý khi < round size); có hết-thẻ thì sao?
11. **scope picker (BR-5)**: người chơi chọn scope (Theo giãn cách / Tất cả / Chỉ chưa thuộc) ở picker trước ván?
12. **Resume ván**: xác nhận Matching KHÔNG resume tiến độ (không có bảng persist trong schema)?
13. **Deep-link `gamePlay`**: có cho vào thẳng ván (route tồn tại) hay bắt buộc qua picker?
14. **`game.words_per_round` biên**: giá trị min/max hợp lệ?
15. **Concurrency**: khoá input khi đang chấm correct/wrong? double-tap cùng tile = toggle bỏ chọn?
16. **A11y**: cặp đúng "biến mất" có live-region thông báo cho screen-reader không?
17. **Cơ chế + thời điểm gỡ cặp đúng**: state `correct` giữ **cả hai** tile trong DOM (chỉ restyle success-soft);
    việc gỡ node chỉ xuất hiện ở `almost`/`complete`. Chuỗi chuyển correct → highlight → gỡ khỏi lưới và **thời
    lượng** của nó KHÔNG có snapshot nào chứng minh → cần chốt (SC-GAMEMATCHING-03).

> Các mục ⚠ là **danh sách phải hỏi BA/spec**, không được đoán. Khi có câu trả lời → cập nhật scenario tương ứng
> + xoá cờ ⚠. Đây chính là "không bỏ sót": phần chưa rõ được **liệt kê ra**, không lờ đi.
