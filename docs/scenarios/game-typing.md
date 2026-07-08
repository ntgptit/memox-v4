# Kịch bản — Typing (game Điền) · screen `game-typing`

Nguồn: `docs/contracts/game-typing.md` [waiting · typing · hint · correct · wrong · complete] ·
DOM `specs/game-typing.md` · D-013, D-015, D-008, D-007 (gián tiếp D-002/D-017 khi Điền chạy như chặng 5 NewLearn) ·
BR `business/game/game-modes.md` [BR-1..BR-5] · DB `srs_state`, `review_logs`, `daily_activity`, `study_sessions`, `cards`, `card_meanings`, `settings`.

> Số/chữ trong kit là MOCK ("friend", "친구", "친", "Hint: 2 characters…", "You typed the words correctly.") —
> assert **định dạng & nguồn** (nghĩa lấy từ `card_meanings.content`, term từ `cards.term`, chuỗi UI từ ARB),
> KHÔNG assert giá trị mock. Chuỗi UI lấy từ ARB, không copy kit.
>
> **Bối cảnh kép (game-modes §1):** Điền chạy ở **2 bối cảnh** — (a) **chạy riêng** qua picker "Một trò chơi"
> (D-013): luyện thuần, **KHÔNG** đổi `srs_state`/`review_logs`, **KHÔNG** cộng `daily_activity`/`study_sessions`
> (D-007, BR-4); (b) **chặng 5 của NewLearn**: chỉ khi hoàn tất đủ 5 chặng thẻ mới mới vào ô 1 (D-002),
> thoát giữa chừng ⇒ thẻ vẫn mới (D-017). Mỗi scenario ghi rõ bối cảnh ở dòng `Nguồn`.

## DoE — game-typing (12 chiều)

| # | Chiều | TT | Scenario / N/A |
|---|---|---|---|
| 1 | States (6) | ✅ | SC-GAMETYPING-01..06 |
| 2 | Elements (10 tương tác) | ✅ | SC-GAMETYPING-10..20 |
| 3 | Nav vào/ra | ✅ | SC-GAMETYPING-30..36 |
| 4 | Nhập liệu & validation (input term) | ✅ | SC-GAMETYPING-40..47 |
| 5 | Lượng dữ liệu (số thẻ/ván) + phạm vi BR-5 | ✅ | SC-GAMETYPING-50..58 |
| 6 | Async & lỗi | ✅ | SC-GAMETYPING-60..63 |
| 7 | Persistence (DB round-trip) | ✅ | SC-GAMETYPING-70..74 |
| 8 | Định dạng & i18n | ✅ | SC-GAMETYPING-80..84 |
| 9 | Dark mode | ✅ | SC-GAMETYPING-90 |
| 10 | Responsive | ✅ | SC-GAMETYPING-91 |
| 11 | A11y | ✅ | SC-GAMETYPING-92 |
| 12 | Concurrency & edge thời gian | ✅ | SC-GAMETYPING-95..98 |

Element inventory (từ DOM spec — mỗi cái ≥1 scenario ở mục 2):
`game-typing/back` (icon-button arrow_back) · `game-typing/options` (icon-button more_horiz) ·
`game-typing/progress` (thanh tiến độ, hiển thị) · `game-typing/meaning` (card MEANING + nghĩa, hiển thị) ·
`game-typing/input` (ô gõ term) · `game-typing/hint` (btn "Help") · `game-typing/check` (btn "Check") ·
`game-typing/next` (btn "Next" ở state correct / "Next round" ở state complete) · `game-typing/accept`
(btn "Correct" — chấp nhận thủ công ở state wrong) · `game-typing/retry` (btn "Retry" ở state wrong).

Phần tử **chỉ ở state complete** (từ DOM spec state complete — hiển thị, không tương tác, phủ ở SC-GAMETYPING-06):
`game-typing/complete` (container khối hoàn thành, id trong DOM spec) chứa `icon-tile` (nền `success-soft`, r:18)
+ `icon:celebration` (màu `on-success-soft`). Các node này thay thân màn khi ván xong; kiểm đếm ở SC-GAMETYPING-06.

> ⚠ `game-typing/options` (more_horiz) không có menu-item nào trong DOM spec (chỉ node icon-button) và
> không có D-xxx/BR mô tả → liệt kê ở Open questions, chỉ assert tối thiểu.

---

## 1. States

### SC-GAMETYPING-01 — waiting (base, chưa gõ)
Nguồn: contract[waiting] · spec base · game-modes §6 (Điền: hiện nghĩa, gõ lại term)
Given: DB `cards`(term nguồn), `card_meanings`(content = nghĩa hiển thị); ván Điền đang chạy, thẻ hiện tại chưa gõ ký tự nào
When: mở/đứng ở state waiting của game-typing
Then:
- UI: appbar (back + title "Typing"(ARB) + more_horiz) · progress bar (`game-typing/progress`) · card MEANING
  (nhãn "MEANING"(ARB) + nghĩa từ `card_meanings.content`) · nhãn "Type the term (…)"(ARB) · ô input rỗng
  hiện placeholder(ARB) · 2 nút grid: "Help"(ARB, `game-typing/hint`) + "Check"(ARB, `game-typing/check`).
  Nút Check ở trạng thái **mờ/vô hiệu** (spec: `op:0.45`) khi input rỗng.
- DB: không ghi gì (chỉ đọc `cards`/`card_meanings`).

### SC-GAMETYPING-02 — typing (đã gõ, chưa chấm)
Nguồn: contract[typing] · spec diff typing
Given: đang ở waiting
When: gõ ≥1 ký tự vào ô input (spec ví dụ "친")
Then:
- UI: ô `game-typing/input` hiển thị ký tự đã gõ (font lớn `30/800`, color `text`); nút "Check" chuyển **kích hoạt**
  (spec: bỏ `op:0.45`, có `shadow:8/18`). Nhãn/nút Help giữ nguyên.
- DB: không ghi gì (chưa chấm).

### SC-GAMETYPING-03 — hint (bấm Help)
Nguồn: contract[hint] · spec diff hint · game-modes §6 (Điền: có "Trợ giúp")
Given: đang ở typing hoặc waiting
When: chạm nút "Help" (`game-typing/hint`)
Then:
- UI: xuất hiện dải gợi ý (bg `warning-soft`, icon lightbulb + text gợi ý dạng "Hint: N characters, starts with …"(ARB)).
  Ô input vẫn nhận gõ tiếp. Nút Check vẫn hiện.
- DB: không ghi gì. ⚠ Xác nhận nội dung gợi ý (số ký tự? ký tự đầu? từ nguồn nào) — xem Open questions.

### SC-GAMETYPING-04 — correct (gõ đúng, chấm Đúng)
Nguồn: contract[correct] · spec diff correct · game-modes §6
Given: đang ở typing với input **khớp** term (theo dung sai — ⚠ quy tắc dung sai chưa định nghĩa, xem Open questions)
When: chạm "Check" (`game-typing/check`)
Then:
- UI: ô input viền `success` (spec `border:2px success`); ẩn 2 nút Help/Check; hiện nút "Next"(ARB, `game-typing/next`)
  full-width (icon arrow_forward + "Next"). Card MEANING + progress giữ.
- DB (bối cảnh chạy riêng — D-007/BR-4): `srs_state` KHÔNG đổi · `review_logs` KHÔNG +dòng · `daily_activity`/`study_sessions` KHÔNG đổi.

### SC-GAMETYPING-05 — wrong (gõ sai, chấm Sai)
Nguồn: contract[wrong] · spec diff wrong · D-015 (sai → học lại trong ván) · game-modes BR-3
Given: đang ở typing với input **không khớp** term
When: chạm "Check"
Then:
- UI: ô input viền `error` (spec `border:2px error`); hiển thị so khớp ký tự (ký tự đúng màu `success`, ký tự sai màu `error`);
  dòng "Answer:"(ARB) + term đúng (đậm, màu `success`) lấy từ `cards.term`; 2 nút mới: "Correct"(ARB, `game-typing/accept`) +
  "Retry"(ARB, `game-typing/retry`).
- DB (chạy riêng): không ghi `srs_state`/`review_logs`/`daily_activity`/`study_sessions` (D-007/BR-4).
  Thẻ sai được **đưa lại hàng đợi trong ván** (D-015/BR-3) — trạng thái hàng đợi là in-memory của ván, không phải cột DB.

### SC-GAMETYPING-06 — complete (xong ván)
Nguồn: contract[complete] · spec diff complete · game-modes UC-2 (ván xong khi mọi thẻ đã đúng)
Given: mọi thẻ trong ván đã được đánh Đúng (trực tiếp hoặc qua "Correct")
When: thẻ cuối chuyển đúng
Then:
- UI: thân màn thay bằng khối `game-typing/complete`: icon-tile celebration (bg `success-soft`) + tiêu đề
  "Round complete!"(ARB) + phụ đề "You typed the words correctly."(ARB) + nút "Next round"(ARB, `game-typing/next`).
  Progress bar = đầy (spec state complete: thanh trong `bg:primary` full width). Card MEANING/input/Help/Check bị gỡ.
- DB (chạy riêng): KHÔNG ghi `study_sessions`/`daily_activity` (BR-4) · `srs_state`/`review_logs` không đổi (D-007).
- ⚠ (bối cảnh NewLearn chặng 5): nếu Điền là chặng cuối của lộ trình học mới, hoàn tất đủ 5 chặng ⇒ thẻ mới vào ô 1
  (D-002) — nhưng màn game-typing này thuộc lớp game luyện; việc chốt SRS do lộ trình NewLearn quản (xem SC-GAMETYPING-73/Open questions).

---

## 2. Elements (mỗi phần tử ≥1 scenario)

### SC-GAMETYPING-10 — Nút back (`game-typing/back`)
Nguồn: spec `game-typing/back` (icon-button arrow_back, mx:?)
When: chạm back
Then: thoát màn game-typing (pop overlay), quay về màn trước (picker/menu Play). ⚠ Xác nhận: back giữa ván có
confirm "bỏ ván" không? (không có trong D-xxx/BR — xem Open questions). Assert tối thiểu: có semantic label, hit-area ≥48.
DB: chạy riêng ⇒ không ghi gì (BR-4); NewLearn chưa đủ 5 chặng ⇒ thẻ vẫn mới (D-017).

### SC-GAMETYPING-11 — Nút options (`game-typing/options`)
Nguồn: spec `game-typing/options` (icon-button more_horiz, mx:?)
When: chạm more_horiz
Then: ⚠ Xác nhận đích (menu gì? item nào?) — DOM spec không liệt kê menu-item, không có D-xxx/BR. Assert tối thiểu:
nút có semantic label, hit-area ≥48, không crash.

### SC-GAMETYPING-12 — Progress bar (`game-typing/progress`)
Nguồn: spec `game-typing/progress` (track `surface-sunken` + fill `primary`)
Then: hiển thị tiến độ ván (tỉ lệ thẻ đã đúng / tổng thẻ ván). ⚠ Xác nhận công thức tiến độ (theo số thẻ đã đúng?
theo lượt chấm?). State complete ⇒ fill đầy. Số kit (280/350) là MOCK — assert **nguồn** (dẫn xuất từ tiến độ ván), không assert %.

### SC-GAMETYPING-13 — Card MEANING (`game-typing/meaning`)
Nguồn: spec `game-typing/meaning` (nhãn "MEANING" + nghĩa "friend")
Then: nhãn "MEANING"(ARB) + nội dung nghĩa lấy từ `card_meanings.content`. Ở state complete card này bị gỡ.
Nghĩa MOCK "friend" — assert nguồn = `card_meanings.content`, không assert giá trị.
⚠ Thẻ có **nhiều** `card_meanings` thì game Điền hiển thị nghĩa nào (đầu/primary/theo `sort_index`?) — KHÔNG có
trong contract/DOM spec/D-xxx/game-modes → xem Open questions, KHÔNG assert cứng quy tắc chọn meaning.

### SC-GAMETYPING-14 — Ô input (`game-typing/input`)
Nguồn: spec `game-typing/input` (state waiting: placeholder; typing/hint/correct: giá trị gõ)
When: focus + gõ
Then: nhận ký tự (gồm CJK — xem SC-GAMETYPING-42); rỗng ⇒ placeholder(ARB) + Check mờ; có ký tự ⇒ Check kích hoạt.
Xem validation mục 4.

### SC-GAMETYPING-15 — Nút Help (`game-typing/hint`)
Nguồn: spec `game-typing/hint` (btn "Help" icon lightbulb) · game-modes §6 ("Trợ giúp")
When: chạm Help
Then: chuyển sang state hint (dải gợi ý). Xem SC-GAMETYPING-03. ⚠ Nội dung/quy tắc gợi ý — Open questions.

### SC-GAMETYPING-16 — Nút Check (`game-typing/check`)
Nguồn: spec `game-typing/check` (btn "Check")
When: chạm Check với input đã có
Then: chấm khớp term → chuyển correct (SC-04) hoặc wrong (SC-05). Input rỗng ⇒ Check vô hiệu (spec `op:0.45`),
tap không tác dụng (xem SC-GAMETYPING-40).

### SC-GAMETYPING-17 — Nút Next ở state correct (`game-typing/next`)
Nguồn: spec correct `game-typing/next` (btn arrow_forward + "Next")
When: (ở correct) chạm Next
Then: chuyển sang thẻ tiếp theo trong ván (về waiting với nghĩa mới) HOẶC sang state complete nếu đã là thẻ cuối.
DB: chạy riêng ⇒ không ghi gì (BR-4).

### SC-GAMETYPING-18 — Nút "Correct" chấp nhận thủ công (`game-typing/accept`)
Nguồn: spec wrong `game-typing/accept` (btn "Correct") · game-modes §6 (Điền: "chấp nhận dung sai")
When: (ở wrong) chạm "Correct"
Then: người học tự chấp nhận đáp án là đúng → xử lý như Đúng (thẻ rời hàng đợi ván, sang thẻ kế/complete). ⚠ Xác nhận
ngữ nghĩa: "Correct" = tự chấm đúng dù gõ sai (override dung sai) — chưa có D-xxx/BR khẳng định rõ; xem Open questions.
DB: chạy riêng ⇒ không ghi gì.

### SC-GAMETYPING-19 — Nút Retry ở state wrong (`game-typing/retry`)
Nguồn: spec wrong `game-typing/retry` (btn "Retry") · D-015/BR-3 (sai → học lại trong ván)
When: (ở wrong) chạm "Retry"
Then: thẻ sai vẫn trong hàng đợi ván (D-015/BR-3); DB: không ghi gì.
⚠ Ngữ nghĩa Retry **chưa chốt**: DOM spec chỉ liệt node btn "Retry", KHÔNG mô tả kết quả tap; D-015/BR-3 chỉ nói
"sai → học lại trong ván" (không nói giữ **cùng thẻ ngay** hay **đẩy về cuối hàng đợi ván**), và không nói có xoá
input hay không. → xem Open questions. Assert tối thiểu: tap có phản hồi, rời state wrong, không crash, không ghi DB.

### SC-GAMETYPING-20 — Nút "Next round" ở state complete (`game-typing/next`)
Nguồn: spec complete `game-typing/next` (btn "Next round")
When: (ở complete) chạm "Next round"
Then: ⚠ Xác nhận đích: bắt ván mới (lấy tập thẻ kế theo D-008/BR-2) hay đóng game về picker/menu? Chưa có D-xxx/BR
mô tả "next round". Assert tối thiểu: tap có phản hồi, không crash. DB: chạy riêng ⇒ không ghi gì (BR-4).

---

## 3. Điều hướng vào/ra

### SC-GAMETYPING-30 — Vào từ picker "Một trò chơi" (chạy riêng)
Nguồn: D-013/BR-1 (picker mở 1 trong 4 game; chọn "Điền")
Given: tại một nút, chọn "Một trò chơi" → picker
When: chọn "Điền"
Then: mở game-typing[waiting] với tập thẻ (mặc định 5, D-008/BR-2). DB: KHÔNG ghi (BR-4).

### SC-GAMETYPING-31 — Vào như chặng 5 NewLearn
Nguồn: study-flow §Mô hình luồng (NewLearn chặng 5 = Điền) · D-002/D-017
Given: đang trong lộ trình NewLearn, đã qua chặng 1–4
When: tới chặng 5 (Điền)
Then: mở game-typing[waiting]. Hoàn tất đủ 5 chặng ⇒ thẻ mới vào ô 1 (D-002); thoát trước khi xong ⇒ thẻ vẫn mới (D-017).
⚠ Ranh giới trách nhiệm chốt SRS giữa lớp game và lộ trình NewLearn — Open questions.

### SC-GAMETYPING-32 — Ra: back giữa ván
Nguồn: spec `game-typing/back`
When: chạm back / vuốt dismiss giữa ván
Then: pop về màn trước. ⚠ confirm bỏ ván? (Open questions). Chạy riêng ⇒ không ghi DB; NewLearn dở ⇒ D-017.

### SC-GAMETYPING-33 — Ra: hoàn tất ván (complete) → Next round
Nguồn: spec complete
When: (ở complete) chạm "Next round"
Then: xem SC-GAMETYPING-20 (đích ⚠ chưa chốt).

### SC-GAMETYPING-34 — Deep-link vào game-typing
Nguồn: —
Then: ⚠ Xác nhận có deep-link trực tiếp tới game-typing không (thường game là overlay push, không có route độc lập).
Nếu không có ⇒ **N/A** (game chỉ vào qua picker/NewLearn). Liệt kê Open questions.

### SC-GAMETYPING-35 — Android back (nút hệ thống) giữa ván
Nguồn: —
When: nhấn back hệ thống
Then: tương đương SC-GAMETYPING-32 (⚠ confirm bỏ ván?). Không mất dữ liệu DB (chạy riêng không ghi gì).

### SC-GAMETYPING-36 — Giữ/khôi phục trạng thái khi app bị đưa nền rồi quay lại
Nguồn: game-modes UC-2 (ván xong khi mọi thẻ đúng)
Given: đang giữa ván, đưa app nền
When: quay lại app
Then: ⚠ Xác nhận: ván (thẻ hiện tại + hàng đợi + input đã gõ) được giữ hay reset? Trạng thái ván là in-memory,
không có cột DB persist ván ⇒ mặc định có thể reset. Liệt kê Open questions.

---

## 4. Nhập liệu & validation (ô `game-typing/input` — gõ lại term)

### SC-GAMETYPING-40 — Rỗng
Given: input rỗng
When: chạm Check
Then: UI: nút Check vô hiệu (spec `op:0.45`), tap không chuyển state; không chấm. DB: không ghi.

### SC-GAMETYPING-41 — Chỉ khoảng trắng / trim
Given: input chỉ chứa khoảng trắng
When: chạm Check
Then: ⚠ Xác nhận: coi như rỗng (Check vẫn vô hiệu) hay trim rồi so? Quy tắc trim/dung sai chưa định nghĩa cho game Điền
(khác `cards.term` trim non-empty ở tầng nhập thẻ). Liệt kê Open questions. Assert tối thiểu: không crash.

### SC-GAMETYPING-42 — CJK (Hàn/Nhật)
Nguồn: game-modes §6 (Điền: gõ lại term; term thường là ngôn ngữ học, ví dụ kit "친구" Hàn)
Given: term = chuỗi CJK (vd tiếng Hàn "친구")
When: gõ đúng CJK "친구" → Check
Then: UI: render đúng glyph CJK trong ô input (không tofu); so khớp đúng → correct. DB: chạy riêng ⇒ không ghi.

### SC-GAMETYPING-43 — Quá dài (biên max)
Given: gõ chuỗi rất dài (vượt độ dài term)
When: Check
Then: UI: không tràn/không vỡ layout ô input (wrap/scroll/ellipsis theo kit); so khớp ⇒ wrong (khác term). DB: không ghi.
⚠ Xác nhận có giới hạn ký tự nhập không (Open questions).

### SC-GAMETYPING-44 — Ký tự đặc biệt / emoji
Given: gõ ký tự đặc biệt/emoji không thuộc term
When: Check
Then: UI: render an toàn (không crash), so khớp ⇒ wrong; hiển thị so khớp ký tự (SC-05). DB: không ghi.

### SC-GAMETYPING-45 — Khác hoa/thường & dấu (dung sai)
Nguồn: game-modes §6 ("chấp nhận dung sai")
Given: gõ term đúng nhưng khác hoa/thường hoặc thiếu/thừa dấu cách
When: Check
Then: ⚠ Xác nhận **quy tắc dung sai** (case-insensitive? bỏ dấu cách? Levenshtein? khoảng cách bao nhiêu?) —
chưa định nghĩa ở business/D-xxx. KHÔNG đoán ngưỡng. Liệt kê Open questions; test chờ chốt spec.

### SC-GAMETYPING-46 — So khớp một phần (ký tự đúng/sai)
Nguồn: spec wrong (ký tự đúng màu `success`, ký tự sai màu `error`)
Given: gõ term sai một phần (vd đúng ký tự đầu, sai ký tự sau — kit "친고" vs "친구")
When: Check
Then: UI: hiển thị từng ký tự với màu success (đúng) / error (sai) đúng vị trí; dòng "Answer:" + term đúng. DB: không ghi.

### SC-GAMETYPING-47 — Trùng (soft-dup) — N/A tầng game
Nguồn: D-020 (soft-dup thuộc tầng nhập/nhập khẩu thẻ)
Then: **N/A** — game Điền không tạo/lưu thẻ; soft-dup (D-020) áp ở màn editor/import, không phải input của game.

---

## 5. Lượng dữ liệu (số thẻ mỗi ván)

### SC-GAMETYPING-50 — 0 thẻ đủ điều kiện
Nguồn: D-008/BR-2 (ván dùng `game.words_per_round` thẻ)
Given: phạm vi chọn không có thẻ nào (deck rỗng / mọi thẻ ẩn D-006)
When: mở game Điền
Then: ⚠ Xác nhận: game-typing không có state `empty` trong kit → hiện gì khi 0 thẻ? (không mở ván? báo lỗi ở picker?).
Liệt kê Open questions. DB: không ghi.

### SC-GAMETYPING-51 — 1 thẻ
Given: chỉ 1 thẻ đủ điều kiện (dù `words_per_round`=5)
When: chơi
Then: ván có đúng 1 thẻ; sau khi đúng → complete ngay. DB: không ghi (BR-4).

### SC-GAMETYPING-52 — Đúng `words_per_round` (mặc định 5)
Nguồn: D-008/BR-2 · `settings` key `game.words_per_round`(default 5)
Given: ≥5 thẻ; `game.words_per_round`=5
When: bắt đầu ván
Then: ván lấy đúng 5 thẻ. DB: đọc `settings`(`game.words_per_round`, scope BR-5); không ghi.

### SC-GAMETYPING-53 — `game.random` bật/tắt
Nguồn: D-008 · `settings` key `game.random`
Given: nhiều thẻ; `game.random`=true (vs false)
When: bắt đầu ván
Then: random=true ⇒ tập thẻ chọn ngẫu nhiên; false ⇒ thứ tự xác định. Assert **nguồn** (đọc `settings`(`game.random`,
scope BR-5)), không assert tập cụ thể (ngẫu nhiên). DB: đọc `settings`; không ghi.

### SC-GAMETYPING-54 — Biên: `words_per_round` lớn hơn số thẻ có
Given: `game.words_per_round`=5 nhưng chỉ 3 thẻ đủ điều kiện
When: bắt đầu
Then: ván dùng 3 thẻ (min(words_per_round, số thẻ có)). ⚠ Xác nhận hành vi khi thiếu thẻ (dùng ít hơn hay báo?). Open questions.

### SC-GAMETYPING-55 — Phạm vi BR-5 = "Theo giãn cách" (ưu tiên đến hạn + mới)
Nguồn: game-modes UC-1 + BR-5 (tuỳ chọn "Chế độ lặp lại giãn cách": *Theo giãn cách*) · US-3 (ưu tiên thẻ đến hạn hoặc còn yếu)
Given: deck có thẻ ở nhiều trạng thái (đến hạn `srs_state.due_at ≤ now`, mới `box=0`/không `srs_state`, và thẻ chưa
đến hạn); người học chọn scope "Theo giãn cách" ở picker (màn `game`)
When: bắt đầu ván Điền với scope này
Then: tập thẻ vào ván **ưu tiên** thẻ đến hạn + thẻ mới (US-3 "ưu tiên đến hạn hoặc còn yếu"), tối đa `game.words_per_round`.
DB: đọc `settings`(scope BR-5) + `srs_state`(due_at/box) để xếp ưu tiên; KHÔNG ghi (BR-4). Assert **thứ tự ưu tiên**
(due+mới trước), không assert thẻ cụ thể.
⚠ Nhãn/nguồn ARB của 3 phạm vi trong picker thuộc màn `game` (không ở màn này); công thức "còn yếu" chưa định lượng — Open questions.

### SC-GAMETYPING-56 — Phạm vi BR-5 = "Tất cả"
Nguồn: game-modes BR-5 (*Tất cả*)
Given: deck có thẻ đủ mọi trạng thái; chọn scope "Tất cả"
When: bắt đầu ván
Then: tập thẻ lấy từ **toàn bộ** thẻ đủ điều kiện của phạm vi (không lọc theo due/thuộc), tối đa `game.words_per_round`
(ngẫu nhiên nếu `game.random`). DB: đọc `settings`(scope BR-5); loại `hidden=1` (D-006); KHÔNG ghi.

### SC-GAMETYPING-57 — Phạm vi BR-5 = "Chỉ thẻ chưa thuộc"
Nguồn: game-modes BR-5 (*Chỉ thẻ chưa thuộc*)
Given: deck có cả thẻ "đã thuộc" (box cao) lẫn thẻ "chưa thuộc"; chọn scope "Chỉ thẻ chưa thuộc"
When: bắt đầu ván
Then: tập thẻ **chỉ gồm** thẻ chưa thuộc; thẻ đã thuộc bị loại. DB: đọc `settings`(scope BR-5) + `srs_state` để lọc;
KHÔNG ghi. ⚠ Ngưỡng "chưa thuộc" (box < N? chưa graduate?) chưa định lượng ở business/D-xxx → xem Open questions; assert
**nguồn** (đọc scope + `srs_state` lọc), không assert ngưỡng cụ thể.

### SC-GAMETYPING-58 — Vòng lặp lại-khi-sai end-to-end: complete chỉ khi MỌI thẻ đã đúng
Nguồn: D-015/BR-3 (sai → lặp lại trong ván) · game-modes UC-2 ("ván chỉ kết thúc khi mọi thẻ đã đúng")
Given: ván ≥3 thẻ; ít nhất 1 thẻ (gọi X) sẽ bị gõ **sai**
When: chơi hết ván — thẻ X gõ sai (→ state wrong) → giải quyết (Retry gõ lại / hoặc "Correct") rồi các thẻ khác đúng
Then:
- Thẻ X sai phải **xuất hiện lại** trong ván (không rời hàng đợi khi chưa đúng) — D-015/BR-3.
- Màn **KHÔNG** vào `complete` chừng nào X chưa được giải quyết đúng; state complete chỉ đạt **sau khi** thẻ-sai cuối
  cùng cũng đúng (UC-2 core). Assert trực tiếp: complete xuất hiện ⇔ mọi thẻ (gồm X) đã đúng, không sớm hơn.
- DB (chạy riêng): KHÔNG ghi `srs_state`/`review_logs`/`daily_activity`/`study_sessions` suốt vòng lặp (BR-4/D-007).
⚠ Cơ chế "giải quyết" thẻ sai (Retry cùng thẻ ngay vs đẩy cuối hàng đợi) phụ thuộc câu trả lời Open question về Retry
(SC-GAMETYPING-19) — scenario này assert **bất biến** "complete chỉ sau khi mọi thẻ đúng", độc lập với cơ chế cụ thể.

---

## 6. Async & lỗi

### SC-GAMETYPING-60 — Nạp ván (loading)
Given: đang dựng tập thẻ cho ván (đọc `cards`/`card_meanings`/`settings`)
When: mở game
Then: ⚠ game-typing không có state `loading` trong kit → xác nhận hiển thị gì khi đang nạp (skeleton? chờ?). Open questions.

### SC-GAMETYPING-61 — Lỗi đọc thẻ (thất bại + retry)
Given: đọc `cards`/`card_meanings` thất bại (`Failure`)
When: mở game
Then: ⚠ game-typing không có state `error` trong kit → xác nhận surface lỗi (banner? về picker? retry?). Lỗi phải
flow `Failure`→`AsyncValue.error`, không nuốt. Open questions.

### SC-GAMETYPING-62 — Local-first (không mạng)
Nguồn: kiến trúc local-first (không backend v1)
Given: không mạng
When: chơi game Điền
Then: ván chạy đầy đủ từ DB local; không phụ thuộc mạng.

### SC-GAMETYPING-63 — Huỷ giữa chừng (thoát khi đang nạp/đang ván)
When: back khi ván chưa nạp xong / đang chơi
Then: huỷ an toàn, không crash; chạy riêng ⇒ không ghi DB; NewLearn dở ⇒ D-017 (thẻ vẫn mới).

---

## 7. Persistence (DB round-trip)

### SC-GAMETYPING-70 — Chạy riêng: KHÔNG đổi SRS
Nguồn: D-007 (Game không đổi `SrsState`) · BR-4
Given: thẻ có `srs_state`(box=k, due_at=T) trước ván
When: chơi hết ván Điền (đúng/sai/chấp nhận đủ kiểu)
Then: DB: `srs_state[card]` giữ nguyên box=k, due_at=T, last_reviewed_at không đổi; `review_logs` KHÔNG +dòng.

### SC-GAMETYPING-71 — Chạy riêng: KHÔNG cộng hoạt động ngày
Nguồn: D-010 (chỉ DueReview/NewLearn cộng) · BR-4
Given: `daily_activity`(hôm nay: minutes=m, words=w) trước ván
When: chơi hết ván Điền chạy riêng
Then: DB: `daily_activity`(hôm nay) giữ nguyên minutes=m, words=w; `study_sessions` KHÔNG +dòng.

### SC-GAMETYPING-72 — Thẻ ẩn bị loại khỏi tập thẻ ván
Nguồn: D-006 (`cards.hidden` loại khỏi hàng đợi/đếm)
Given: một số thẻ `hidden=1`
When: dựng tập thẻ ván
Then: DB/logic: thẻ `hidden=1` KHÔNG vào ván. ⚠ Xác nhận game có tôn trọng `hidden` như queue học không (D-006 nêu
"hàng đợi/đếm"; game là hàng đợi luyện). Open questions.

### SC-GAMETYPING-73 — NewLearn chặng 5 hoàn tất → vào ô 1
Nguồn: D-002 (new → box 1 khi hoàn tất đủ 5 chặng) — bối cảnh NewLearn
Given: thẻ mới (không có `srs_state` / box 0), Điền là chặng 5, đã qua chặng 1–4
When: hoàn tất Điền → hoàn tất đủ 5 chặng
Then: DB: `srs_state[card]` box=1, due_at = now + interval(ô 1 = 1 ngày), last_reviewed_at set.
⚠ Việc ghi này do lộ trình NewLearn chốt (không phải riêng màn game) — xác nhận ranh giới. Open questions.

### SC-GAMETYPING-74 — Kill & mở lại app
Given: chơi ván Điền chạy riêng rồi kill app
When: mở lại
Then: DB không đổi bởi ván (SC-70/71); dữ liệu `cards`/`card_meanings`/`srs_state`/`daily_activity` round-trip nguyên vẹn.
Trạng thái ván (in-memory) không được kỳ vọng khôi phục (không cột DB) — xem SC-GAMETYPING-36.

---

## 8. Định dạng & i18n

### SC-GAMETYPING-80 — Chuỗi UI theo ARB/locale
Given: đổi locale (vi/en/ja)
Then: "Typing"(title), "MEANING", "Type the term (…)", "Help", "Check", "Next", "Correct", "Retry", "Round complete!",
"You typed the words correctly.", "Next round", gợi ý — tất cả từ ARB, đổi theo locale; không hardcode kit copy.

### SC-GAMETYPING-81 — Nhãn ngôn ngữ trong "Type the term (Korean)"
Nguồn: spec nhãn "Type the term (Korean)"
Then: phần "(Korean)" là **tên ngôn ngữ học** — nguồn từ `language_pairs.learning_language` (không hardcode "Korean").
Đổi cặp ngôn ngữ ⇒ đổi nhãn. ⚠ Xác nhận nguồn tên hiển thị (learning_language raw hay map tên hiển thị). Open questions.

### SC-GAMETYPING-82 — Nghĩa & term CJK render đúng
Given: nghĩa/term chứa Hàn/Nhật
Then: card MEANING + ô input + dòng "Answer:" render đúng glyph CJK (không tofu); không cắt sai.

### SC-GAMETYPING-83 — Text dài (nghĩa/term rất dài)
Given: `card_meanings.content` hoặc `cards.term` rất dài
Then: card MEANING wrap/ellipsis không vỡ; ô input dài không tràn; dòng "Answer:" + term đậm không đẩy layout.

### SC-GAMETYPING-84 — Plural / số trong gợi ý & tiến độ
Nguồn: spec hint "Hint: 2 characters…"
Then: nếu gợi ý nêu số ký tự ⇒ dùng ARB plural (1 character vs N characters), không nối chuỗi. ⚠ nội dung gợi ý chưa chốt
(Open questions). Số trong progress là dẫn xuất, không hiển thị số thô nếu ARB không quy định.

---

## 9. Dark mode

### SC-GAMETYPING-90 — Mọi state ở dark
Then: 6 state (waiting/typing/hint/correct/wrong/complete) render đúng ở cả light + dark bằng token
(`bg`, `surface`, `surface-sunken` (track progress), `divider`, `primary`, `primary-strong` (icon+text nút Help),
`success`, `error`, `warning-soft`/`on-warning-soft`, `success-soft`/`on-success-soft`,
`text` / `text-secondary` (nhãn "Type the term", phụ đề complete, dòng "Answer:") /
`text-tertiary` (nhãn "MEANING", placeholder input)); không hardcode màu.
Viền success/error + dải hint contrast đạt ở dark; đặc biệt kiểm **contrast nút Help** (`primary-strong` trên nền `bg`
mặc định, không có nền nút) và các nhãn `text-secondary`/`text-tertiary` ở dark.

---

## 10. Responsive

### SC-GAMETYPING-91 — 320px → tablet + xoay
Then: ở 320px không overflow: appbar, card MEANING, ô input, grid 2 nút (Help/Check) co giãn; nút full-width
(Next/Next round) không tràn. Nội dung dài cuộn được (body `layout_hint:scroll`). Xoay ngang cuộn được; safe-area/notch OK.
State wrong (nhiều node: so khớp ký tự + Answer + 2 nút) không vỡ ở màn hẹp.

---

## 11. A11y

### SC-GAMETYPING-92 — Semantics & focus
Then: back/options/Help/Check/Next/Correct/Retry/Next round có semantic label (từ ARB); hit-area ≥48 (spec `minh:48`/
icon-button 48x48). Ô input có label "Type the term (…)". Thứ tự đọc: title → progress → MEANING+nghĩa → nhãn+input →
nút. State wrong: screen-reader đọc "Answer: <term>" thành câu có nghĩa. Nút Check vô hiệu được thông báo disabled.

---

## 12. Concurrency & edge thời gian

### SC-GAMETYPING-95 — Double-tap Check
When: chạm nhanh 2 lần nút Check
Then: chỉ chấm **một** lần (không chấm kép, không nhảy 2 state). DB: chạy riêng ⇒ không ghi (idempotent với BR-4).

### SC-GAMETYPING-96 — Double-tap Next / Next round
When: chạm nhanh 2 lần Next (correct) hoặc Next round (complete)
Then: chỉ tiến **một** thẻ / mở **một** ván; không bỏ qua thẻ, không mở 2 ván.

### SC-GAMETYPING-97 — Đổi ngày lúc nửa đêm giữa ván
Nguồn: D-021 (chốt streak nửa đêm) — nhưng game Điền KHÔNG cộng activity (BR-4)
Then: đổi ngày giữa ván **không** ảnh hưởng ván (game chạy riêng không ghi `daily_activity`/streak). Assert: ván tiếp tục
bình thường; `daily_activity` không bị game này chạm dù qua nửa đêm.

### SC-GAMETYPING-98 — Phiên gián đoạn (cuộc gọi/đưa nền) rồi resume
When: đang gõ, app bị gián đoạn rồi quay lại
Then: xem SC-GAMETYPING-36 (⚠ giữ hay reset ván — Open questions). Không crash; DB chạy riêng không ghi.

---

## Open questions (⚠ cần chốt spec trước khi viết test — KHÔNG bịa)

1. **Dung sai so khớp (game-modes §6 "chấp nhận dung sai")**: quy tắc cụ thể? case-insensitive? bỏ/chuẩn hoá dấu cách?
   khoảng cách chỉnh sửa (Levenshtein) ngưỡng bao nhiêu? — chưa có ở business/D-xxx (SC-GAMETYPING-45).
2. **Nút "Correct" (`game-typing/accept`)**: ngữ nghĩa "tự chấm đúng dù gõ sai" (override dung sai) — chưa có D-xxx/BR
   khẳng định (SC-GAMETYPING-18).
3. **Nội dung/quy tắc gợi ý (state hint)**: gợi ý gồm gì (số ký tự? ký tự đầu?), lộ dần hay cố định, bấm nhiều lần? —
   kit mock "Hint: 2 characters, starts with 친" (SC-GAMETYPING-03/15/84).
4. **Nút options (more_horiz)**: menu gì, item nào? DOM spec không liệt kê menu-item (SC-GAMETYPING-11).
5. **"Next round" (state complete)**: bắt ván mới (lấy tập kế theo D-008) hay đóng về picker/menu? (SC-GAMETYPING-20/33).
6. **Back giữa ván**: có confirm "bỏ ván" không? (SC-GAMETYPING-10/32/35).
7. **0 thẻ đủ điều kiện**: game-typing không có state `empty` — hiển thị gì / có mở ván không? (SC-GAMETYPING-50).
8. **loading / error**: game-typing không có state `loading`/`error` trong kit — surface gì khi nạp/đọc lỗi? (SC-GAMETYPING-60/61).
9. **Thẻ ẩn (D-006) với game**: game có loại `hidden` như queue học không (D-006 nói "hàng đợi/đếm")? (SC-GAMETYPING-72).
10. **Ranh giới chốt SRS ở NewLearn chặng 5**: màn game-typing hay lộ trình NewLearn ghi `srs_state` box 1 (D-002)?
    thoát giữa chặng 5 (D-017)? (SC-GAMETYPING-31/73).
11. **Nguồn tên ngôn ngữ trong "Type the term (…)"**: `language_pairs.learning_language` raw hay map tên hiển thị? (SC-GAMETYPING-81).
12. **Giữ/khôi phục ván khi đưa nền/kill**: ván (thẻ hiện tại + hàng đợi + input) reset hay resume? (SC-GAMETYPING-36/74/98).
13. **Trim / chỉ khoảng trắng ở input**: coi như rỗng hay trim rồi so? có giới hạn độ dài nhập? (SC-GAMETYPING-41/43).
14. **Công thức progress bar**: theo số thẻ đã đúng / theo lượt chấm? (SC-GAMETYPING-12).
15. **Deep-link**: có route độc lập tới game-typing không, hay chỉ overlay qua picker/NewLearn? (SC-GAMETYPING-34).
16. **Thiếu thẻ so với `words_per_round`**: dùng ít hơn hay báo? (SC-GAMETYPING-54).
17. **Meaning nào khi thẻ có nhiều `card_meanings`**: game Điền hiển thị nghĩa nào (đầu / primary / theo `sort_index`)?
    — KHÔNG có ở contract/DOM spec/D-xxx/game-modes (SC-GAMETYPING-13).
18. **Ngữ nghĩa nút Retry (`game-typing/retry`)**: tap Retry → gõ lại **cùng thẻ ngay** hay **đẩy thẻ về cuối hàng đợi
    ván**? có xoá input không? — DOM spec chỉ liệt node btn, không mô tả kết quả; D-015/BR-3 chỉ nói "sai → học lại
    trong ván" (SC-GAMETYPING-19/58).
19. **Phạm vi BR-5 định lượng**: nhãn/nguồn ARB 3 phạm vi (thuộc màn `game`); công thức "còn yếu"/ngưỡng "chưa thuộc"
    (box < N? chưa graduate?) — chưa định lượng ở business/D-xxx (SC-GAMETYPING-55/57).

> Các mục ⚠ trên là **danh sách phải hỏi BA/spec**, không được đoán. Khi có câu trả lời → cập nhật scenario
> tương ứng + xoá cờ ⚠. Đây chính là "không bỏ sót": phần chưa rõ được **liệt kê ra**, không lờ đi.
