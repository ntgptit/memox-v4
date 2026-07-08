# Kịch bản — Game Picker (Một trò chơi) · screen `game-picker`

Nguồn: `docs/contracts/game-picker.md` [default · not-enough · scope-dropdown] ·
DOM `specs/game-picker.md` · D-013 (mở picker, chọn 1/4) · D-016 (mục "Một trò chơi" luôn có trong menu Play) ·
D-007 · D-008 · D-010 (DailyActivity CHỈ cộng DueReview/NewLearn; Game KHÔNG cộng) ·
D-015 (wrong-answer/học-lại của **ván** — thuộc màn `gamePlay`, game-picker chỉ truyền `type`; out-of-scope, xem SC-GAMEPICKER-16b) ·
BR `business/game/game-modes.md` [BR-1..BR-5] (+ study-flow BR-4/BR-5/BR-7) ·
DB `cards`, `card_meanings`, `srs_state`, `settings` (`game.words_per_round`, `game.random`), `study_sessions`, `daily_activity`, `review_logs`.

> Số/chuỗi trong kit là MOCK ("Single game", "By schedule", "5 words per round · change in Settings",
> "This deck needs at least 4 words to play.", "Add words", "Matching", "Match terms to meanings", …) —
> assert **định dạng & nguồn**, KHÔNG assert giá trị mock. Chuỗi lấy từ ARB, không copy kit.
> Ngưỡng "4 words" trong banner MOCK vs `game.words_per_round`=5 (default) là mâu thuẫn ⚠ (Open questions #1).

## DoE — game-picker (12 chiều)

| # | Chiều | TT | Scenario / N/A |
|---|---|---|---|
| 1 | States (3) | ✅ | SC-GAMEPICKER-01..03 |
| 2 | Elements (11 tương tác + hiển thị) | ✅ | SC-GAMEPICKER-10..24 (+16b: D-015 học-lại thuộc gamePlay) |
| 3 | Nav vào/ra | ✅ | SC-GAMEPICKER-30..37 |
| 4 | Nhập liệu & validation | **N/A** | game-picker không có field nhập trực tiếp (chỉ nút/card/menu chọn). Ngưỡng "đủ từ" xử ở SC-GAMEPICKER-40..44 (data volume) |
| 5 | Lượng dữ liệu | ✅ | SC-GAMEPICKER-40..45 |
| 6 | Async & lỗi | ✅ | SC-GAMEPICKER-50..53 |
| 7 | Persistence (DB round-trip) | ✅ | SC-GAMEPICKER-60..63 (+63b: write-path chọn scope, 2 nhánh OQ#4) |
| 8 | Định dạng & i18n | ✅ | SC-GAMEPICKER-70..74 |
| 9 | Dark mode | ✅ | SC-GAMEPICKER-80 |
| 10 | Responsive | ✅ | SC-GAMEPICKER-81 |
| 11 | A11y | ✅ | SC-GAMEPICKER-82 |
| 12 | Concurrency & edge thời gian | ✅ | SC-GAMEPICKER-90..93 |

Element inventory (từ DOM spec — mỗi cái ≥1 scenario ở mục 2):
`back` (icon-button arrow_back) · `appbar__title` ("Single game") · `scope` card (icon-tile tune + "Card source" /
"By schedule" + expand_more) · `game-matching` card (icon join_inner + chevron_right) · `game-mc` card (icon quiz) ·
`game-recall` card (icon psychology) · `game-typing` card (icon keyboard) · footer "N words per round · change in Settings" ·
`not-enough` banner (icon info + text) · `add-cards` btn ("Add words") · scope-sheet 3 nút: `scope-srs` ("By schedule" + check),
`scope-all` ("All cards"), `scope-unlearned` ("Unlearned only") · `scope-scrim` (overlay bấm ngoài) · sheet drag-handle.

---

## 1. States

### SC-GAMEPICKER-01 — default (đủ từ để chơi)
Nguồn: contract[default] · spec base · D-013 · BR-1
Given:
  - DB: `decks`(1 nút nguồn `nodeId`), `cards`(≥ ngưỡng-tối-thiểu thẻ visible `hidden=0` trong subtree nút, D-009), mỗi thẻ có ≥1 `card_meanings`
  - DB: `settings`(`game.words_per_round`=5 default)
When: từ menu Play của nút → chọn "Một trò chơi" (D-013) → push `game` `/game/:nodeId`
Then:
  - UI: appbar (back + title "Single game" từ ARB) · card `scope` (icon tune, "Card source" + scope hiện tại + expand_more) ·
    4 card game theo thứ tự Matching→Multiple choice→Recall→Typing (mỗi card icon-tile + tên + phụ đề + chevron_right) ·
    footer "N words per round · change in Settings". KHÔNG banner not-enough, KHÔNG scrim/sheet.
  - DB: chỉ đọc (không ghi) — game-picker là màn chọn, chưa chạy ván (D-007).

### SC-GAMEPICKER-02 — not-enough (nút thiếu từ để chơi)
Nguồn: contract[not-enough] · spec "not enough" diff · BR-2 (game-modes) · BR-7 (study-flow: cỡ ván)
Given: DB nút nguồn có **< ngưỡng-tối-thiểu** thẻ visible (subtree, D-009; thẻ `hidden=1` bị loại D-006)
When: mở game-picker của nút này
Then:
  - UI: banner cảnh báo (icon info trên `warning-soft`, text kiểu "cần ≥ N từ để chơi" từ ARB) + nút `add-cards` ("Add words") ·
    4 card game hiển thị **mờ (op:0.5) — không tương tác** · card `scope` vẫn hiện. KHÔNG scrim.
  - ⚠ Xác nhận ngưỡng thực (kit banner MOCK "4 words" vs default round=5) → Open questions #1.
  - DB: chỉ đọc (đếm thẻ visible subtree).

### SC-GAMEPICKER-03 — scope-dropdown (mở sheet chọn phạm vi)
Nguồn: contract[scope-dropdown] · spec "scope dropdown" diff · BR-5 (game-modes) · D-008
Given: state default (đủ từ)
When: chạm card `scope`
Then:
  - UI: hiện `scope-scrim` (overlay `bg:overlay`, z:60) + `scope-sheet` (bottom-sheet r:28, drag-handle) chứa nhãn "Card source" +
    3 nút: `scope-srs` ("By schedule" + icon schedule + icon check ở phạm vi đang chọn), `scope-all` ("All cards" + apps),
    `scope-unlearned` ("Unlearned only" + hourglass_empty). Đúng 3 lựa chọn = BR-5 (Theo giãn cách / Tất cả / Chỉ chưa thuộc).
  - DB: chỉ đọc.

---

## 2. Elements (mỗi phần tử ≥1 scenario)

### SC-GAMEPICKER-10 — Nút back (arrow_back)
Nguồn: spec `game-picker/back` (icon-button, mx:?)
When: chạm back
Then: UI: pop game-picker, quay về màn gọi (deck-detail hoặc menu Play nguồn); DB: không ghi. Semantic label + hit-area ≥48.

### SC-GAMEPICKER-11 — Appbar title
Nguồn: spec `game-picker/appbar__title` ("Single game")
Then: UI: hiển thị tiêu đề màn từ ARB (không hardcode "Single game"); 1 dòng, **clip** khi dài (spec `position: clip` = overflow hidden, KHÔNG có thuộc tính ellipsis trong spec — SC-GAMEPICKER-74). ⚠ clip vs ellipsis (dấu …) → Open questions #12.

### SC-GAMEPICKER-12 — Card scope (mở sheet)
Nguồn: spec `game-picker/scope` (icon-tile tune + "Card source" + phạm vi hiện tại + expand_more) · BR-5
When: chạm card scope
Then: UI: mở scope-sheet (→ state scope-dropdown, SC-GAMEPICKER-03). Nhãn dòng phụ = tên phạm vi đang chọn (ARB), đồng bộ lựa chọn có dấu check trong sheet.

### SC-GAMEPICKER-13 — Card game Matching
Nguồn: spec `game-picker/game-matching` (icon join_inner + "Matching" + "Match terms to meanings" + chevron_right) · D-013 · BR-3 (game-modes: Ghép đôi)
When: chạm card Matching (state default)
Then:
  - UI: push `gamePlay` `/game/:nodeId/play` với params `type`=matching, `scope`=phạm vi đang chọn, `random`=`game.random`.
  - DB (ghi): bắt đầu ván **không** ghi `srs_state`/`review_logs`/`study_sessions`/`daily_activity` (D-007/BR-4).
  - DB (đọc — ranh giới ai đọc thẻ): ⚠ Xác nhận **picker hay gamePlay** đọc/lọc danh sách thẻ đưa vào ván (theo `scope` + `hidden=0` D-006 + subtree đệ quy D-009). Giả định hiện tại: picker chỉ đọc **đếm đủ-từ** (SC-GAMEPICKER-40..45) rồi push `nodeId`+`scope`; gamePlay đọc/lọc danh sách thẻ thật TẠI ván. → Open questions #13. Assert theo quyết định #13, KHÔNG bịa bên nào đọc.

### SC-GAMEPICKER-14 — Card game Multiple choice
Nguồn: spec `game-picker/game-mc` (icon quiz + "Multiple choice" + "Pick the right meaning" + chevron_right) · D-013 · BR-3 (Đoán)
When: chạm card MC
Then: UI: push `gamePlay` type=multipleChoice, scope, random. DB: không ghi SRS (D-007).

### SC-GAMEPICKER-15 — Card game Recall
Nguồn: spec `game-picker/game-recall` (icon psychology + "Recall" + "Recall, then self-grade" + chevron_right) · D-013 · BR-3 (Nhớ lại)
When: chạm card Recall
Then: UI: push `gamePlay` type=recall, scope, random. DB: không ghi SRS (D-007).

### SC-GAMEPICKER-16 — Card game Typing
Nguồn: spec `game-picker/game-typing` (icon keyboard + "Typing" + "Type the term from its meaning" + chevron_right) · D-013 · BR-3 (Điền)
When: chạm card Typing
Then: UI: push `gamePlay` type=typing, scope, random. DB: không ghi SRS (D-007).

### SC-GAMEPICKER-16b — Logic học-lại (wrong-answer/re-queue) của ván thuộc `gamePlay`, KHÔNG thuộc game-picker
Nguồn: D-015 (bất kỳ chế độ học kể cả 4 game — trả lời SAI ⇒ thẻ **học lại**/quay lại hàng đợi; phiên xong khi MỌI thẻ đã đúng) · navigation-flow (`gamePlay` push)
Given: từ game-picker chọn 1 trong 4 game → push `gamePlay` với `type` đã chọn
Then:
  - **Phạm vi:** game-picker CHỈ truyền param `type`/`scope`/`random` (SC-GAMEPICKER-13..16); hành vi học-lại D-015 (trả lời sai → re-queue, kết thúc khi mọi thẻ đúng) được thực thi **hoàn toàn bên `gamePlay`**, KHÔNG có điểm neo/assertion nào trong màn game-picker.
  - Assert (out-of-scope tại đây): game-picker không hiển thị/không xử lý câu trả lời, không quản hàng đợi thẻ, không quyết định phiên xong. D-015 được kiểm chứng ở scenario của `gamePlay` (test `test/presentation/features/game/game_session_test.dart`, core-decision-table), không phải màn này.

### SC-GAMEPICKER-17 — Footer "N words per round · change in Settings"
Nguồn: spec `div` footer ("5 words per round · change in Settings") · D-008 · BR-2/BR-7 · settings `game.words_per_round`
Then:
  - UI: hiển thị số N = `settings.game.words_per_round` (đọc từ DB, KHÔNG hardcode "5"); text từ ARB.
  - ⚠ Xác nhận: footer có phải là nút mở Settings (chạm "change in Settings") hay chỉ text tĩnh? spec đánh `node:div` (không mx) → mặc định coi là text; nếu là link → Open questions #2.

### SC-GAMEPICKER-18 — Banner not-enough (icon info + text)
Nguồn: spec `game-picker/not-enough` (icon info + span cảnh báo) — state not-enough
Then: UI: banner nền `warning-soft`, icon info màu `on-warning-soft`, text ngưỡng từ ARB (plural theo N — SC-GAMEPICKER-71). Chỉ hiện ở state not-enough.

### SC-GAMEPICKER-19 — Nút "Add words" (add-cards)
Nguồn: spec `game-picker/add-cards` (btn "Add words", mx:?, bg:primary) — state not-enough
When: chạm "Add words"
Then:
  - UI: ⚠ Xác nhận đích — mở `flashcardEditor` `/deck/:id/card` (tạo thẻ cho nút nguồn) hay `deckImport`? navigation-flow/D-xxx chưa nêu → Open questions #3. Assert tối thiểu: nút có label ARB, tap có phản hồi, dẫn tới luồng thêm thẻ.

### SC-GAMEPICKER-20 — 4 card game bị mờ ở not-enough (không tương tác)
Nguồn: spec not-enough diff (4 card game `op:0.5`)
When: chạm 1 card game ở state not-enough
Then: UI: **không** push `gamePlay` (card disabled); không phản hồi mở ván. (Chỉ `add-cards` hoạt động.) DB: không ghi.

### SC-GAMEPICKER-21 — Nút scope "By schedule" (scope-srs)
Nguồn: spec `game-picker/scope-srs` (icon schedule + "By schedule" + check) · BR-5 (Theo giãn cách: ưu tiên đến hạn + mới)
When: mở sheet → chạm "By schedule"
Then: UI: sheet đóng; dòng phụ card scope = "By schedule" (ARB); dấu check gắn mục này. DB: ⚠ Xác nhận lựa chọn phạm vi có ghi `settings` (khoá nào?) hay chỉ giữ trong phiên/route param → Open questions #4.

### SC-GAMEPICKER-22 — Nút scope "All cards" (scope-all)
Nguồn: spec `game-picker/scope-all` (icon apps + "All cards") · BR-5 (Tất cả)
When: chạm "All cards"
Then: UI: sheet đóng; scope hiện = "All cards" (ARB); check chuyển sang mục này. Khi chơi, ván lấy từ toàn bộ thẻ visible subtree (D-009/D-006).

### SC-GAMEPICKER-23 — Nút scope "Unlearned only" (scope-unlearned)
Nguồn: spec `game-picker/scope-unlearned` (icon hourglass_empty + "Unlearned only") · BR-5 (Chỉ thẻ chưa thuộc)
When: chạm "Unlearned only"
Then: UI: sheet đóng; scope = "Unlearned only" (ARB); check chuyển. DB: ⚠ Xác nhận định nghĩa "chưa thuộc" (thẻ `srs_state.box` < 8? hay box 0 = mới? kit dùng "unlearned") → Open questions #5. Khi chơi, ván lọc theo tiêu chí này.

### SC-GAMEPICKER-24 — Scrim đóng sheet (bấm ngoài) + drag-handle
Nguồn: spec `game-picker/scope-scrim` (overlay bg:overlay) + drag-handle div
When: (a) chạm vùng scrim ngoài sheet; (b) kéo/swipe-down handle
Then: UI: sheet đóng, về state default, KHÔNG đổi phạm vi (giữ lựa chọn cũ). DB: không ghi.

---

## 3. Điều hướng vào/ra

### SC-GAMEPICKER-30 — Vào từ menu Play → "Một trò chơi"
Nguồn: D-013 · D-016 (menu Play: mục "Một trò chơi" luôn có; chỉ "Lặp lại" phụ thuộc due>0) · navigation-flow (`game` `/game/:nodeId` push) · study-flow BR-1
Given: nút bất kỳ (lá hoặc cha), với due>0 HOẶC due=0
When: bấm Play tại nút → chọn "Một trò chơi"
Then:
  - UI (entry-point luôn tồn tại): mục "Một trò chơi" trong menu Play **luôn khả dụng bất kể `due`** (D-016 — khác "Lặp lại" chỉ hiện khi due>0) ⇒ game-picker luôn vào được. Push `game-picker` với `nodeId` đúng nút; hiện state default (hoặc not-enough nếu thiếu từ, độc lập với due).
  - DB: đọc subtree nút (D-009). due=0 KHÔNG chặn vào game-picker (đủ-từ tính theo thẻ visible, không theo due).

### SC-GAMEPICKER-31 — Ra: chọn game → gamePlay (push)
Nguồn: navigation-flow (`gamePlay` `/game/:nodeId/play` params type/scope/random)
When: chạm 1 trong 4 card game
Then: UI: push `gamePlay` mang đúng (nodeId, type, scope hiện tại, random=`game.random`). Back từ ván → quay lại game-picker giữ scope đã chọn.

### SC-GAMEPICKER-32 — Ra: back → pop về nút nguồn
Nguồn: spec `back` · navigation-flow (push/pop)
When: chạm back / back hệ thống
Then: UI: pop về màn gọi (deck-detail hoặc menu Play). State game-picker không giữ (màn push, dựng lại khi vào lại).

### SC-GAMEPICKER-33 — Back khi sheet scope đang mở
Nguồn: state scope-dropdown · overlay dismiss
When: sheet scope mở → nhấn back hệ thống
Then: UI: back **đóng sheet trước** (về default), KHÔNG pop cả màn. Back lần 2 mới pop game-picker. ⚠ Xác nhận thứ tự ưu tiên back → Open questions #6.

### SC-GAMEPICKER-34 — Ra: "Add words" (not-enough) → luồng thêm thẻ
Nguồn: SC-GAMEPICKER-19
When: chạm "Add words"
Then: UI: push luồng thêm thẻ cho nút nguồn (đích ⚠ Open questions #3); back quay lại game-picker, nếu đã đủ từ → chuyển state default (SC-GAMEPICKER-53).

### SC-GAMEPICKER-35 — Deep-link
Nguồn: navigation-flow ("Không deep-link ngoài v1")
Then: **N/A** — v1 không hỗ trợ deep-link ngoài; game-picker chỉ vào qua push nội bộ từ menu Play.

### SC-GAMEPICKER-36 — Swipe-dismiss sheet
Nguồn: state scope-dropdown (bottom-sheet)
When: kéo sheet xuống dưới ngưỡng
Then: UI: sheet đóng, về default, không đổi phạm vi. (Xem SC-GAMEPICKER-24b.)

### SC-GAMEPICKER-37 — Vào lại sau khi chơi xong 1 ván
Nguồn: navigation-flow (gamePlay pop về picker) · D-007
When: chơi xong/thoát ván → pop về game-picker
Then: UI: game-picker hiển thị lại (state default), scope giữ nguyên lựa chọn trước. DB: sau ván, `srs_state`/`daily_activity` KHÔNG đổi (D-007) — kiểm chứng ở SC-GAMEPICKER-60.

---

## 5. Lượng dữ liệu

### SC-GAMEPICKER-40 — 0 thẻ visible ở nút
Nguồn: state not-enough · D-006
Given: nút không có thẻ visible nào (rỗng hoặc mọi thẻ `hidden=1`)
Then: UI: state not-enough (banner + 4 card mờ). DB: đếm visible subtree = 0.

### SC-GAMEPICKER-41 — Đúng biên dưới ngưỡng (thiếu 1)
Nguồn: state not-enough · BR-2
Given: số thẻ visible = ngưỡng-tối-thiểu − 1
Then: UI: not-enough. ⚠ ngưỡng chính xác chờ chốt (Open questions #1).

### SC-GAMEPICKER-42 — Đúng biên bằng ngưỡng
Given: số thẻ visible = ngưỡng-tối-thiểu
Then: UI: state default (đủ chơi); 4 card game bật, không banner.

### SC-GAMEPICKER-43 — Nhiều thẻ hơn cỡ ván (round=5)
Given: thẻ visible ≫ `game.words_per_round`
Then: UI: default; khi chơi, ván chỉ dùng N=`words_per_round` thẻ (D-008/BR-7) — picker không đổi. (Assert cỡ ván ở nhánh gamePlay, không phải màn này.)

### SC-GAMEPICKER-44 — Nút cha gộp subtree đệ quy
Nguồn: D-009 · BR-6 (study-flow)
Given: nút cha có subtree; thẻ nằm ở bộ thẻ con
Then: UI: đếm "đủ từ" gộp **đệ quy** toàn bộ thẻ visible của subtree (D-009); default nếu tổng ≥ ngưỡng.

### SC-GAMEPICKER-45 — Thẻ hidden bị loại khỏi đếm
Nguồn: D-006
Given: nút có thẻ nhưng phần lớn `hidden=1`, phần visible < ngưỡng
Then: UI: not-enough (thẻ hidden không tính vào đủ-từ, D-006). DB: đếm chỉ `hidden=0`.

---

## 6. Async & lỗi

### SC-GAMEPICKER-50 — loading → default
Nguồn: contract (kit chỉ có 3 state, KHÔNG có state loading riêng)
Given: provider đếm thẻ/đọc scope chưa resolve
Then: UI: ⚠ kit game-picker KHÔNG có state loading → Xác nhận hiển thị gì khi đang tải (skeleton? spinner? render tối thiểu?) → Open questions #7. Assert tối thiểu: không crash, không hiện số/scope rác trước khi có DB.

### SC-GAMEPICKER-51 — provider lỗi (đọc cards/settings thất bại)
Nguồn: contract (KHÔNG có state error trong kit)
Then: UI: ⚠ kit KHÔNG có state error → Xác nhận hành vi khi đọc DB lỗi (inline error? fallback not-enough? snackbar?) → Open questions #8. Lỗi phải chảy `Failure`→`AsyncValue.error`, không nuốt (CLAUDE.md #5).

### SC-GAMEPICKER-52 — local-first (không mạng)
Nguồn: CLAUDE.md #4 (local-first, no remote v1)
Then: UI: game-picker render đầy đủ từ DB local, không phụ thuộc mạng (đếm thẻ, đọc scope/round đều local).

### SC-GAMEPICKER-53 — thêm từ đủ ngưỡng → chuyển not-enough→default
Nguồn: SC-GAMEPICKER-34 · state chuyển tiếp
Given: state not-enough → chạm "Add words" → thêm đủ thẻ → back về picker
Then: UI: game-picker re-evaluate, chuyển sang default (4 card bật, banner biến mất). DB: `cards` +N dòng (visible) đủ ngưỡng.

---

## 7. Persistence (DB round-trip)

### SC-GAMEPICKER-60 — Chơi 1 ván KHÔNG đổi SRS/hoạt động
Nguồn: D-007 · D-010 (DailyActivity cộng giây + số từ **CHỈ** DueReview/NewLearn; Game/Review/Player KHÔNG cộng) · BR-4 (game-modes) · BR-5 (study-flow) · schema `srs_state`/`review_logs`/`study_sessions`/`daily_activity` (contract "no write")
Given: snapshot `srs_state`, `daily_activity`, `review_logs`, `study_sessions` trước khi chơi
When: từ picker chọn 1 game → chơi xong → về picker
Then: DB: 4 bảng trên **không đổi** (không dòng mới, box/due_at giữ nguyên) — chứng minh game standalone = luyện thuần (D-007). Cụ thể `daily_activity`(hôm nay) **không** cộng thêm giây/số-từ nào sau ván game (D-010 — Game bị loại khỏi DailyActivity, đây chính là rule cấm cộng).

### SC-GAMEPICKER-61 — Đọc cỡ ván từ settings
Nguồn: settings `game.words_per_round` (default 20? — no; default **5**) · D-008
Given: `settings`(`game.words_per_round`=5)
Then: UI: footer hiển thị 5. Đổi giá trị trong DB (vd 8) → mở lại picker → footer hiển thị 8 (đọc từ `settings`, không hardcode).

### SC-GAMEPICKER-62 — Đọc toggle random từ settings
Nguồn: settings `game.random` · D-008
Then: DB: khi push `gamePlay`, param `random` = `settings.game.random`. (Toggle không có UI trên game-picker — đọc gián tiếp; đổi ở Settings.)

### SC-GAMEPICKER-63 — Kill & mở lại app rồi vào lại picker
Nguồn: DoE #7 round-trip
Given: chọn scope "Unlearned only" → kill app → mở lại → vào lại game-picker cùng nút
Then: UI: ⚠ scope có bền qua kill không phụ thuộc Open questions #4 (nếu lưu `settings` thì bền; nếu chỉ trong phiên thì reset về mặc định). Assert theo quyết định #4. Cỡ ván/đủ-từ phải khôi phục đúng từ DB.

### SC-GAMEPICKER-63b — Write-path khi CHỌN scope (INSERT/UPDATE settings hay 0-write)
Nguồn: DoE #7 (write-path) · SC-GAMEPICKER-21/22/23 · schema-contract (KHÔNG có khoá `game.scope`) · Open questions #4
Given: state default, snapshot bảng `settings` trước khi chọn scope
When: mở sheet → chọn 1 phạm vi khác hiện tại (vd "All cards")
Then: DB (hai nhánh theo quyết định #4 — chưa chốt, assert đúng nhánh được chọn, KHÔNG bịa):
  - **Nhánh A (ghi bền `settings`):** thời điểm chọn scope có **1 UPDATE/INSERT** vào `settings` (khoá scope — ⚠ khoá nào chưa có trong schema-contract, chờ #4); round-trip đọc lại đúng giá trị; bền qua kill (SC-GAMEPICKER-63 nhánh bền).
  - **Nhánh B (chỉ trong phiên/route param):** chọn scope ⇒ **0 write** vào `settings`/bất kỳ bảng nào; giá trị chỉ sống trong state/route `gamePlay.scope`; reset về mặc định sau kill (SC-GAMEPICKER-63 nhánh reset).
  - ⚠ Đúng một trong hai nhánh là thật; hiện chưa có khoá `game.scope` trong schema-contract ⇒ mặc định nghi vấn Nhánh B, nhưng phải chốt #4 trước khi viết test. Assert nhánh sai = FAIL.

---

## 8. Định dạng & i18n

### SC-GAMEPICKER-70 — Tên/phụ đề game theo locale
Given: đổi locale (vi/en/ja)
Then: UI: tên 4 game + phụ đề + tiêu đề "Single game" + nhãn scope đổi theo ARB tương ứng; không tofu, không vỡ layout.

### SC-GAMEPICKER-71 — Plural ngưỡng & cỡ ván
Nguồn: footer "N words per round" · banner "at least N words"
Then: UI: N=1 ⇒ "1 word per round" / N từ ⇒ "N words per round" (ARB plural, không nối chuỗi); banner ngưỡng cũng plural. Không hardcode "words".

### SC-GAMEPICKER-72 — Nội dung CJK (nếu thẻ term/nghĩa Hàn/Nhật)
Given: nút có thẻ term "사과" / nghĩa tiếng Nhật; app locale đặt ja/ko
Then:
  - UI (in-scope màn này): game-picker **không render nội dung thẻ** (term/nghĩa) trực tiếp — chỉ đếm/hiển thị. Assert phần thật sự thuộc màn: chuỗi UI CJK (title "Single game", nhãn scope, footer, banner) render đúng glyph locale CJK khi đổi ngôn ngữ app, không tofu/không vỡ layout.
  - Out-of-scope: kỳ vọng "luồng sang ván giữ CJK đúng" (term/nghĩa Hàn/Nhật hiển thị chuẩn trong ván) là hành vi của **`gamePlay`** — màn đó render nội dung thẻ, không phải game-picker. Assert CJK term/nghĩa thuộc scenario của `gamePlay`, KHÔNG neo tại đây.

### SC-GAMEPICKER-73 — Nhãn scope dài
Given: ARB ngôn ngữ có nhãn phạm vi dài (vd tiếng Đức "Nur ungelernte Karten")
Then: UI: dòng phụ card scope + nút trong sheet ellipsis/wrap, không đẩy tràn card/sheet.

### SC-GAMEPICKER-74 — Tiêu đề dài
Then: UI: appbar title dài → **clip** (spec `position: clip` = overflow hidden + `grow:1 basis:0`), không đẩy nút back. Spec chỉ chứng minh `clip`; ellipsis (…) KHÔNG có trong spec → clip vs ellipsis treo ở Open questions #12.

---

## 9. Dark mode

### SC-GAMEPICKER-80 — Mọi state ở dark
Nguồn: DoE #9 · token, không hardcode
Then: UI: 3 state (default/not-enough/scope-dropdown) render đúng ở dark; banner `warning-soft`/`on-warning-soft`, card `surface`, scrim `overlay`, nút scope check `primary`, "Add words" `primary`/`surface` — tất cả qua token, contrast đạt. 4 card mờ op:0.5 ở not-enough vẫn phân biệt được ở dark.

---

## 10. Responsive

### SC-GAMEPICKER-81 — 320px → tablet + xoay
Then: UI: ở 320px card game + card scope không overflow (spec **card `pad:16`**; **body `app__body` `pad:16/20/96/20`** — pad 16/20 là của body, KHÔNG phải của card); danh sách 4 card + footer cuộn được (body `layout_hint:scroll`); sheet scope neo đáy, không tràn; xoay ngang cuộn được; safe-area/notch OK; ở tablet card không giãn quá rộng vỡ tỉ lệ.

---

## 11. A11y

### SC-GAMEPICKER-82 — Semantics
Then: UI: back/scope-card/4 card game/add-cards/3 nút scope có semantic label (ARB); hit-area ≥48 (card 80px, nút sheet 46–48px — OK); thứ tự đọc: title → scope → Matching → MC → Recall → Typing → footer; card game đọc thành câu "tên game, phụ đề" (không đọc rời icon); ở not-enough, banner đọc trước, 4 card mờ báo disabled cho screen-reader; sheet mở → focus chuyển vào sheet, đọc "Card source" + 3 lựa chọn + mục đang chọn (check).

---

## 12. Concurrency & edge thời gian

### SC-GAMEPICKER-90 — Double-tap 1 card game
Nguồn: DoE #12
When: chạm nhanh 2 lần 1 card game
Then: UI: chỉ push `gamePlay` **một** lần (không mở 2 ván). DB: không ghi.

### SC-GAMEPICKER-91 — Double-tap card scope
When: chạm nhanh 2 lần card scope
Then: UI: chỉ mở **một** sheet (không chồng 2 sheet/scrim).

### SC-GAMEPICKER-92 — Chọn scope rồi chạm game ngay
When: mở sheet → chọn "All cards" (sheet đóng) → chạm ngay card Typing
Then: UI: push `gamePlay` với `scope`=all (lựa chọn mới đã kịp áp), không dùng scope cũ. DB: param nhất quán.

### SC-GAMEPICKER-93 — Xoá thẻ ở nơi khác khi picker đang mở
Nguồn: D-024 (cascade) · D-006
Given: đang mở game-picker (default) → ở tab khác/tiến trình khác xoá thẻ khiến nút tụt dưới ngưỡng
Then: UI: ⚠ Xác nhận picker có re-evaluate reactive (chuyển sang not-enough) hay giữ default tới khi vào lại → Open questions #9. Nếu bấm game khi thực tế thiếu từ → ván phải xử lý an toàn (không crash).

---

## Open questions (⚠ cần chốt spec trước khi viết test — KHÔNG bịa)

1. **Ngưỡng "đủ từ"**: kit banner MOCK ghi "at least 4 words" nhưng `game.words_per_round` mặc định = **5**. Ngưỡng-tối-thiểu để bật 4 game là 4, 5, hay = `words_per_round`? BR-2 chỉ nói "≥ N từ". → chốt con số + nguồn.
2. **Footer "change in Settings"**: là text tĩnh (spec `node:div`, không `mx:`) hay là link/nút chạm mở màn Settings? Nếu link → thêm scenario nav ra Settings.
3. **Nút "Add words"** (not-enough): đích khi tap — `flashcardEditor` (tạo thẻ cho nút nguồn), `deckImport`, hay màn khác? Chưa có D-xxx/navigation-flow.
4. **Phạm vi (scope) lưu ở đâu**: chỉ giữ trong phiên/route param (`gamePlay.scope`) hay ghi bền vào `settings` (khoá nào — schema-contract KHÔNG có khoá `game.scope`)? Ảnh hưởng round-trip kill (SC-GAMEPICKER-63).
5. **Định nghĩa "Unlearned only"**: "chưa thuộc" = `srs_state.box` < 8 (chưa mastered) hay = box 0/absent (chưa xếp lịch = mới)? "By schedule" (BR-5: ưu tiên đến hạn + mới) tiêu chí chọn thẻ cụ thể ra sao?
6. **Back priority khi sheet mở**: back hệ thống đóng sheet trước rồi mới pop màn (SC-GAMEPICKER-33) — xác nhận đúng.
7. **State loading**: kit game-picker chỉ có 3 state, KHÔNG có loading — hiển thị gì trong lúc đếm thẻ/đọc settings?
8. **State error**: kit KHÔNG có error — hiển thị gì khi đọc DB (cards/settings) lỗi?
9. **Reactive re-evaluate**: picker đang mở, thẻ bị xoá/ẩn nơi khác khiến tụt ngưỡng — picker có tự chuyển default↔not-enough theo thời gian thực không?
10. **Thứ tự & danh sách 4 game cố định**: kit liệt kê Matching→MC→Recall→Typing — xác nhận thứ tự này là cố định (không cấu hình/ẩn game nào).
11. **Card scope ở not-enough**: state not-enough vẫn hiện card scope (spec giữ) — chạm scope khi not-enough có mở sheet được không, hay cũng bị disable như 4 card game?
12. **Title clip vs ellipsis**: spec `appbar__title` chỉ có `position: clip` (overflow hidden) + `grow:1 basis:0`, KHÔNG có thuộc tính ellipsis/`text-overflow`. Tiêu đề dài cắt cụt trơn (`clip`) hay hiện dấu "…" (ellipsis)? Kit chỉ chứng minh `clip`; ellipsis là suy diễn → chốt spec (SC-GAMEPICKER-11/74).
13. **Ai đọc & lọc danh sách thẻ đưa vào ván** — game-picker hay `gamePlay`? Picker chỉ đọc **đếm đủ-từ** (SC-GAMEPICKER-40..45) rồi push `nodeId`+`scope`, còn `gamePlay` đọc/lọc danh sách thẻ thật (theo `scope` + `hidden=0` D-006 + subtree đệ quy D-009) TẠI ván? Hay picker đọc sẵn danh sách và truyền qua? Ảnh hưởng assertion DB-read của SC-GAMEPICKER-13..16 (SC-GAMEPICKER-13 nêu ranh giới này).

> Các mục ⚠ ở trên là **danh sách phải hỏi BA/spec**, không được đoán. Khi có câu trả lời → cập nhật
> scenario tương ứng + xoá cờ ⚠. Đây chính là "không bỏ sót": phần chưa rõ được **liệt kê ra**, không lờ đi.
