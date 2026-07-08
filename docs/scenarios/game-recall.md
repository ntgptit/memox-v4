# Kịch bản — Recall (Nhớ lại) · screen `game-recall`

Nguồn: `docs/contracts/game-recall.md` [before-reveal · revealed · forgot · remembered · complete] ·
DOM `specs/game-recall.md` · D-007, D-008, D-013, D-015 (D-002 gián tiếp khi Recall là chặng 4 của NewLearn) ·
BR `business/game/game-modes.md` [BR-1..BR-5] · DB `settings` (`game.words_per_round`, `game.random`), `cards`, `card_meanings`, `srs_state`, `study_sessions`, `review_logs`, `daily_activity` (các bảng SRS/hoạt động chỉ dùng để assert **KHÔNG ghi** khi chạy game độc lập — D-007/BR-4).

> Số/chuỗi trong kit là MOCK ("친구", "friend", "a friend, companion", thanh tiến độ 60%) — assert **định dạng & nguồn**
> (term từ `cards.term`, nghĩa từ `card_meanings.content` meaning đầu), KHÔNG assert giá trị mock. Chuỗi UI lấy từ ARB, không copy kit.
> Recall chạy ở **hai bối cảnh** (game-modes §1): (a) game độc lập từ picker — luyện thuần, không đổi SRS/hoạt động (D-007/D-013/BR-4);
> (b) chặng 4 trong lộ trình NewLearn 5 chặng (study-flow) — chấm SRS chỉ xảy ra khi hoàn thành đủ 5 chặng (D-002), KHÔNG tại màn Recall này.
> Các scenario dưới đây bám bối cảnh (a) game độc lập trừ khi ghi rõ.

## DoE — game-recall (12 chiều)

| # | Chiều | TT | Scenario / N/A |
|---|---|---|---|
| 1 | States (5) | ✅ | SC-GAMERECALL-01..05 |
| 2 | Elements (8 tương tác) | ✅ | SC-GAMERECALL-10..21 (mọi control `mx:?` → identity contract chưa chốt, Open q #19) |
| 3 | Nav vào/ra | ✅ | SC-GAMERECALL-30..36 |
| 4 | Nhập liệu & validation | **N/A** | Recall không có field nhập trực tiếp (tự chấm Forgot/Got it; chỉ hiển thị term+nghĩa). Nhập/sửa thẻ diễn ra ở màn khác qua nút `edit` (SC-GAMERECALL-13). |
| 5 | Lượng dữ liệu | ✅ | SC-GAMERECALL-40..45 |
| 6 | Async & lỗi | ✅ | SC-GAMERECALL-50..53 |
| 7 | Persistence (DB round-trip) | ✅ | SC-GAMERECALL-60..64 |
| 8 | Định dạng & i18n | ✅ | SC-GAMERECALL-70..74 |
| 9 | Dark mode | ✅ | SC-GAMERECALL-80 |
| 10 | Responsive | ✅ | SC-GAMERECALL-81 |
| 11 | A11y | ✅ | SC-GAMERECALL-82 |
| 12 | Concurrency & edge thời gian | ✅ | SC-GAMERECALL-90..93 |

Element inventory (từ DOM spec — mỗi cái ≥1 scenario ở mục 2):
`back` (icon-button arrow_back, `game-recall/back`) · `options` (icon-button more_horiz, `game-recall/options`) ·
`audio` (icon-button volume_up, `game-recall/audio`) · `edit` (icon-button edit, `game-recall/edit`) ·
`reveal` (btn "Show", `game-recall/reveal`, chỉ ở `before-reveal`) · `forgot` (btn "Forgot", `game-recall/forgot`) ·
`remembered` (btn "Got it", `game-recall/remembered`) · `next` (btn "Next round", `game-recall/next`, chỉ ở `complete`).
Phần tử hiển thị (không tương tác): `progress` (thanh tiến độ) · `term` card (친구) · `meaning` card (gợi ý → nghĩa sau reveal) ·
banner forgot ("You'll see this word again this round." + icon replay) · banner remembered ("Nice! Moving to the next card." + icon check_circle) ·
divider (gạch ngăn term/nghĩa — spec `bg:divider r:6`, 56x4px, **CHỈ ở revealed/forgot/remembered**, không có ở before-reveal/complete — dòng 279–281) ·
complete panel (`icon-tile` bg `success-soft` r:18 + icon celebration `color:on-success-soft` + tiêu đề + phụ đề — spec dòng 698/704).

---

## 1. States

### SC-GAMERECALL-01 — before-reveal (base — chờ lộ nghĩa)
Nguồn: contract[before-reveal] · spec base · BR-1/D-013
Tiền điều kiện (Given):
- DB: `settings`(`game.words_per_round`=5), deck có ≥1 thẻ visible; card[0] term (CJK, vd Hàn) + ≥1 `card_meanings`.
Thao tác (When):
1. Vào Recall độc lập cho deck (SC-GAMERECALL-30) → thẻ đầu tiên hiển thị.
Kỳ vọng (Then):
- UI: appbar (back + title Recall(ARB) + options) · `progress` (thanh, tiến độ ván) · `term` card hiện **term thẻ** (nguồn `cards.term`) + nút `audio` + `edit` · `meaning` card hiện dòng gợi ý (ARB, kèm icon visibility) · nút `reveal` "Show"(ARB). KHÔNG hiện nghĩa, KHÔNG hiện forgot/remembered.
- DB: KHÔNG ghi (chưa thao tác) — `srs_state`/`review_logs`/`study_sessions`/`daily_activity` không đổi.

### SC-GAMERECALL-02 — revealed (đã lộ nghĩa, chưa tự chấm)
Nguồn: contract[revealed] · spec "revealed" diff · game-modes §6 (Nhớ lại)
Given: đang ở `before-reveal` với thẻ hiện tại.
When: chạm `reveal` "Show".
Then:
- UI: dòng gợi ý + nút `reveal` **biến mất** (theo diff); `meaning` card hiện divider + **nghĩa chính** (nguồn `card_meanings.content` meaning đầu sort_index nhỏ nhất) + (nếu có) dòng phụ nghĩa (spec `color:text-secondary`); xuất hiện lưới 2 nút `forgot` "Forgot"(ARB) + `remembered` "Got it"(ARB). `term` card vẫn hiển thị.
- **Divider**: assert xuất hiện với token màu `divider` (spec `bg:divider r:6`, 56x4px — dòng 279–281); KHÔNG có ở before-reveal.
- **Token nút mặc định (chưa active)**: `forgot` là nút text `color:primary-strong` (spec dòng 315), `remembered` là nút text `color:text` (spec dòng 331) — assert cả hai màu mặc định, không chỉ màu active. (Tổ hợp 2×2 màu-nút-theo-state, xem SC-GAMERECALL-21.)
- **Layout height**: `meaning` card cao lên **128px** (spec abs 350x128 — dòng 233) so với 120px ở before-reveal (do thêm divider + nghĩa chính + nghĩa phụ); `minh:120` giữ nguyên, card tự cao thêm (xem SC-GAMERECALL-73).
- DB: KHÔNG ghi (chỉ đổi state UI).

### SC-GAMERECALL-03 — forgot (tự chấm Đã quên)
Nguồn: contract[forgot] · spec "forgot" diff · D-015/BR-3
Given: đang ở `revealed` (thẻ hiện tại), ván còn ≥1 thẻ.
When: chạm `forgot` "Forgot".
Then:
- UI: hiện banner cảnh báo mềm (`bg:warning-soft` + `color:on-warning-soft`, icon replay `color:on-warning-soft`) "sẽ gặp lại thẻ này trong ván"(ARB); thẻ được **đưa lại hàng đợi ván** (D-015/BR-3) → tiếp tục chuyển sang thẻ kế (hoặc lặp lại theo hàng đợi). `progress` KHÔNG tăng quá mức đã học đúng.
- **Token nút theo state `forgot`**: nút `forgot` (đang active) chuyển `bg:error` + text `color:surface` (spec dòng 431/437); nút `remembered` (không active) VẪN là text `color:text` (spec dòng 453) — assert cả nút không active, không chỉ nút được chấm.
- **Divider** vẫn hiện (`bg:divider`); nghĩa phụ vẫn `color:text-secondary`.
- DB: KHÔNG ghi (game độc lập không đổi `srs_state`/`review_logs` — D-007/BR-4).
⚠ Xác nhận: sau khi chấm Forgot, banner hiển thị bao lâu rồi tự chuyển thẻ, hay chờ thao tác? (kit chỉ chụp state tĩnh).

### SC-GAMERECALL-04 — remembered (tự chấm Nhớ được)
Nguồn: contract[remembered] · spec "remembered" diff · game-modes §6
Given: đang ở `revealed` (thẻ hiện tại).
When: chạm `remembered` "Got it".
Then:
- UI: hiện banner tích cực (`bg:success-soft` + `color:on-success-soft`, icon check_circle `color:on-success-soft`) "chuyển sang thẻ kế"(ARB); thẻ rời hàng đợi ván; `progress` tăng.
- **Token nút theo state `remembered`**: nút `remembered` (đang active) chuyển `bg:primary` + text `color:surface` (spec dòng 569/575); nút `forgot` (không active) VẪN là text `color:primary-strong` (spec dòng 559) — assert cả nút không active, không chỉ nút được chấm.
- **Divider** vẫn hiện (`bg:divider`); nghĩa phụ vẫn `color:text-secondary`.
- DB: KHÔNG ghi (game độc lập — D-007/BR-4).
⚠ Xác nhận: thời lượng banner trước khi tự chuyển thẻ (như SC-GAMERECALL-03).

### SC-GAMERECALL-05 — complete (hết thẻ trong ván)
Nguồn: contract[complete] · spec "complete" diff · BR-3/D-015
Given: ván đạt điều kiện hoàn thành theo D-015 ("phiên xong khi MỌI thẻ đã đúng"). ⚠ Điều kiện chính xác khi có thẻ Forgot chưa được nguồn kit/contract chốt (thẻ Forgot phải Got-it lại rồi mới complete, hay Forgot chỉ đẩy xuống cuối 1 lần?) → xem Open questions #18; KHÔNG phát biểu như fact.
When: chấm thẻ cuối "Got it" (ván không còn thẻ trong hàng đợi).
Then:
- UI: `progress` đầy (`bg:primary` full-width — spec dòng 585); term/meaning card biến mất; hiện panel `game-recall/complete`: `icon-tile` (assert nền `bg:success-soft` r:18 — spec dòng 698) chứa icon celebration (assert `color:on-success-soft` — spec dòng 704) + tiêu đề "Round complete!"(ARB, `color:text`) + phụ đề (ARB, `color:text-secondary`) + nút `next` "Next round"(ARB, `bg:primary`+`color:surface`, icon arrow_forward).
- DB: KHÔNG ghi (game độc lập không cộng hoạt động/không đổi SRS — BR-4/D-007).

---

## 2. Elements (mỗi phần tử ≥1 scenario)

### SC-GAMERECALL-10 — Nút back (`game-recall/back`)
Nguồn: spec `game-recall/back` (icon-button arrow_back, mx:?)
When: chạm back giữa ván.
Then:
- UI: thoát Recall, quay về màn nguồn (picker game hoặc deck-detail — xem SC-GAMERECALL-33).
- DB: KHÔNG ghi (bỏ ván game độc lập không lưu tiến độ/không đổi SRS — D-007/BR-4).
⚠ Xác nhận: back giữa ván có hiện dialog xác nhận "bỏ ván" không? (không có trong kit/D-xxx → liệt kê Open questions).

### SC-GAMERECALL-11 — Nút options (`game-recall/options`, more_horiz)
Nguồn: spec `game-recall/options` (icon-button more_horiz, mx:?)
When: chạm more_horiz.
Then: ⚠ Xác nhận đích (mở menu/sheet gì? — kit KHÔNG chụp overlay nào cho nút này; không có D-xxx/business). Assert tối thiểu: nút có semantic label, hit-area ≥48, không crash. Nội dung menu → Open questions.

### SC-GAMERECALL-12 — Nút audio (`game-recall/audio`, volume_up)
Nguồn: spec `game-recall/audio` (icon-button volume_up, mx:?) · game-modes §9 (audio là phụ thuộc nội dung)
When: chạm loa.
Then: phát audio phát âm term. ⚠ Xác nhận: schema-contract ghi `cards.audio_ref` **NULL ở v1** (TTS live-only, DT.7 hoãn) → build hiện tại phát TTS live hay no-op? Assert tối thiểu: nút có label, hit-area ≥48, không crash; nếu audio hoãn → assert no-op/disabled theo spec. Không assert nội dung âm thanh.

### SC-GAMERECALL-13 — Nút edit (`game-recall/edit`)
Nguồn: spec `game-recall/edit` (icon-button edit, mx:?)
When: chạm edit trên term card.
Then: ⚠ Xác nhận đích: mở màn/sheet sửa thẻ hiện tại? (không có trong D-xxx/business game). Nếu mở editor: sửa `cards.term`/`card_meanings.content` → soft-dup D-020 áp dụng ở màn editor (không ở đây). Assert tối thiểu: nút có label, hit-area ≥36 (spec 36x36 — xem A11y SC-GAMERECALL-82), điều hướng có phản hồi. Đích chính xác → Open questions.

### SC-GAMERECALL-14 — Nút reveal "Show" (`game-recall/reveal`)
Nguồn: spec `game-recall/reveal` (btn, mx:?) — chỉ tồn tại ở `before-reveal`
When: chạm "Show".
Then: chuyển `before-reveal` → `revealed` (xem SC-GAMERECALL-02); nút `reveal` biến mất khỏi cây; nghĩa lộ ra. DB: KHÔNG ghi.

### SC-GAMERECALL-15 — Nút forgot "Forgot" (`game-recall/forgot`)
Nguồn: spec `game-recall/forgot` (btn, mx:?) — có ở `revealed`/`forgot`/`remembered`
When: chạm "Forgot" ở `revealed`.
Then: → state `forgot` (SC-GAMERECALL-03); thẻ quay lại hàng đợi ván (D-015). DB: KHÔNG ghi.

### SC-GAMERECALL-16 — Nút remembered "Got it" (`game-recall/remembered`)
Nguồn: spec `game-recall/remembered` (btn, mx:?)
When: chạm "Got it" ở `revealed`.
Then: → state `remembered` (SC-GAMERECALL-04); thẻ rời hàng đợi; `progress` tăng. DB: KHÔNG ghi.

### SC-GAMERECALL-17 — Nút next "Next round" (`game-recall/next`)
Nguồn: spec `game-recall/next` (btn, mx:?) — chỉ ở `complete`
When: chạm "Next round" ở `complete`.
Then: ⚠ Xác nhận đích: bắt đầu ván mới (lấy `game.words_per_round` thẻ mới, ngẫu nhiên nếu `game.random` — D-008) trên **cùng** deck, hay quay về màn nguồn? Assert cấu trúc: nếu ván mới → về `before-reveal` với thẻ đầu ván mới; `progress` reset. DB: KHÔNG ghi. Đích chính xác → Open questions.

### SC-GAMERECALL-18..21 — (gộp phần tử hiển thị)
- **18 `progress`**: thanh phản ánh số thẻ đã "Got it" / tổng thẻ ván (không assert giá trị mock 60%; assert tỉ lệ đúng theo số thẻ đã đúng). Track `bg:surface-sunken`; fill `bg:primary` (spec dòng 121/126).
- **18b `divider`** (sau reveal): assert token màu `divider` (`bg:divider r:6`, 56x4px — spec dòng 279–281); CHỈ hiện ở revealed/forgot/remembered, KHÔNG ở before-reveal (dòng gợi ý thay chỗ) và KHÔNG ở complete (card biến mất). Assert per-element sự hiện/vắng theo state, không gộp im lặng.
- **19 `term` card**: hiện `cards.term` (không copy "친구"); giữ nguyên qua before-reveal→revealed→forgot→remembered; biến mất ở `complete`.
- **20 `meaning` card**: before-reveal = gợi ý (ARB, `color:text-tertiary`); revealed+ = nghĩa chính từ `card_meanings.content` (meaning đầu, `color:text`) + dòng phụ (`color:text-secondary`, nếu có meaning thứ 2 / định dạng nghĩa). Card cao 120→128px khi lộ nghĩa (xem SC-GAMERECALL-02/73).
- **21 banner + tổ hợp token nút theo state (2×2)**: banner forgot = `warning-soft`+`on-warning-soft` + icon replay + copy ARB; banner remembered = `success-soft`+`on-success-soft` + icon check_circle + copy ARB. **Nút Forgot/Got it × 2 state** (assert đủ 4/4, không chỉ 2/4):
  - state `revealed`: Forgot=text `primary-strong`, Got it=text `text`.
  - state `forgot`: Forgot=`bg:error`+`surface`, Got it=text `text`.
  - state `remembered`: Forgot=text `primary-strong`, Got it=`bg:primary`+`surface`.
  (Assert token màu theo state, không hardcode.)

> ⚠ **Component mapping / identity contract chưa chốt**: MỌI control tương tác trong DOM spec là `mx:?` (`back`/`options`/`audio`/`edit`/`reveal`/`forgot`/`remembered`/`next` — spec dòng 65,92,150,164,203,301,317,724) = "no confident MemoX component mapping". Khoá identity per-screen (`tool/parity/contracts/`) cho các control này chưa được chốt → xem Open questions #19; không giả định mapping.

---

## 3. Điều hướng vào/ra

### SC-GAMERECALL-30 — Vào Recall qua picker "Một trò chơi"
Nguồn: navigation-flow (`game` `/game/:nodeId` → `gamePlay` `/game/:nodeId/play` type/scope/random) · D-013/BR-1
Given: deck có ≥1 thẻ visible.
When: tại một nút deck → Play → "Một trò chơi" → picker → chọn "Nhớ lại" (+ tuỳ chọn phạm vi BR-5).
Then:
- UI: push `gamePlay` với type=recall; màn Recall mở ở `before-reveal`.
- DB: đọc thẻ theo phạm vi (BR-5: *Theo giãn cách*=ưu tiên due+mới / *Tất cả* / *Chỉ chưa thuộc*), lấy tối đa `game.words_per_round`; KHÔNG ghi.
⚠ Xác nhận: tên/label 4 phạm vi trong picker lấy từ ARB nào (BR-5 mô tả 3 giá trị; kit picker ở màn `game`, không ở màn này).

### SC-GAMERECALL-31 — Vào Recall là chặng 4 của NewLearn
Nguồn: study-flow UC-2 (Xem lại → Ghép đôi → Đoán → **Nhớ lại** → Điền) · D-002
Given: chọn "Học" tại deck có thẻ mới; đã qua chặng 1–3.
When: tới chặng 4 (Nhớ lại).
Then:
- UI: màn Recall mở ở `before-reveal`; `progress` phản ánh tiến độ tích luỹ 5 chặng (không chỉ trong ván Recall). ⚠ Xác nhận: progress ở bối cảnh NewLearn tính theo 5 chặng hay theo thẻ trong chặng Recall?
- DB: chấm SRS **chưa** xảy ra ở chặng này; thẻ vào ô 1 **chỉ** khi hoàn thành đủ 5 chặng (D-002). Nếu thoát giữa chặng → thẻ vẫn mới, không có `srs_state` box>0 (D-017).

### SC-GAMERECALL-32 — Ra: back về màn nguồn
Nguồn: spec `back` · navigation (push/pop)
When: chạm back ở bất kỳ state.
Then: pop về màn nguồn (picker game hoặc lộ trình NewLearn); Recall bị huỷ. DB: game độc lập không lưu (D-007).

### SC-GAMERECALL-33 — Back giữ/không giữ vị trí màn nguồn
Given: vào Recall từ deck-detail đã cuộn.
When: hoàn thành/back.
Then: quay về màn nguồn giữ vị trí cuộn + state (nếu qua shell/StatefulShell). ⚠ Xác nhận: Recall là push chồng (overlay theo contract "pushed/overlay") → back trả về nguyên trạng màn dưới.

### SC-GAMERECALL-34 — Android system back giữa ván
When: nhấn back hệ thống (Android) khi đang chơi.
Then: tương đương nút back (SC-GAMERECALL-32). ⚠ Xác nhận: có dialog xác nhận bỏ ván không? (chung với SC-GAMERECALL-10).

### SC-GAMERECALL-35 — Swipe-dismiss (iOS back-swipe)
When: vuốt cạnh trái (nếu bật) khi đang chơi.
Then: pop như back. ⚠ Xác nhận: có chặn swipe-dismiss giữa ván để tránh mất tiến độ không? (không có trong kit → Open questions).

### SC-GAMERECALL-36 — Deep-link vào `gamePlay`
Nguồn: navigation route `/game/:nodeId/play`
When: mở deep-link tới ván Recall (nếu hỗ trợ).
Then: ⚠ Xác nhận: route có nhận deep-link trực tiếp không? nếu nodeId không tồn tại/không có thẻ → xử lý gì (empty/back)? → Open questions + xem SC-GAMERECALL-40.

---

## 5. Lượng dữ liệu

### SC-GAMERECALL-40 — 0 thẻ đủ điều kiện trong phạm vi
Given: deck rỗng hoặc mọi thẻ bị `hidden` (D-006) / không thẻ nào khớp phạm vi BR-5.
When: cố mở Recall.
Then: ⚠ Xác nhận: kit KHÔNG có state empty cho `game-recall` → hiện gì khi không đủ thẻ? (chặn ở picker? báo "không có thẻ"? mở thẳng `complete`?). Assert tối thiểu: không crash; KHÔNG ghi DB. → Open questions.

### SC-GAMERECALL-41 — 1 thẻ trong ván
Given: `game.words_per_round`=5 nhưng deck chỉ 1 thẻ visible.
Then: ván có đúng 1 thẻ; chấm "Got it" → thẳng `complete`. ⚠ Xác nhận: ván lấy min(words_per_round, số thẻ khả dụng)?

### SC-GAMERECALL-42 — Đúng `game_words_per_round` thẻ (mặc định 5)
Nguồn: D-008/BR-2 · `settings.game.words_per_round`
Given: deck ≥5 thẻ visible; `game.words_per_round`=5.
Then: ván dùng đúng 5 thẻ; DB: đọc 5 thẻ (ngẫu nhiên nếu `game.random`=1 — D-008), KHÔNG ghi.

### SC-GAMERECALL-43 — Đổi `game.words_per_round` (biên)
Given: đổi `settings.game.words_per_round` (vd 1, hoặc lớn) rồi mở ván.
Then: số thẻ ván khớp giá trị mới đọc từ `settings`. ⚠ Xác nhận: có min/max cho words_per_round không? (schema chỉ ghi default 5).

### SC-GAMERECALL-44 — Thẻ ẩn bị loại (cả dựng hàng đợi VÀ đếm due)
Nguồn: D-006 · `cards.hidden` · BR-5
Given: một số thẻ deck có `hidden=1`.
Then:
- **Dựng hàng đợi**: thẻ ẩn KHÔNG vào ván Recall (D-006 loại khỏi hàng đợi). DB assert: tập thẻ ván ⊆ thẻ `hidden=0`.
- **Đếm số đến hạn** (nhánh thứ 2 của D-006): khi phạm vi = *Theo giãn cách* (BR-5, ưu tiên due+mới), thẻ `hidden=1` cũng bị loại khỏi phép **đếm due** → số thẻ due dùng để chọn ván không cộng thẻ ẩn. DB assert: count due chỉ tính `hidden=0`. (D-006 áp cho CẢ hai nhánh "dựng hàng đợi / tính số đến hạn".)

### SC-GAMERECALL-45 — Recall tại deck cha → gộp đệ quy thẻ deck con
Nguồn: D-009 (gộp **đệ quy** thẻ của mọi bộ thẻ con khi học tại bộ thẻ cha) · study-flow
Given: vào Recall (SC-GAMERECALL-30) từ một nút deck **cha** có thẻ nằm trong các deck con (cây nhiều tầng).
When: dựng ván Recall tại deck cha.
Then:
- Hàng đợi ván gộp **đệ quy** thẻ của toàn cây con (D-009 — giống study-flow/game khác), không chỉ thẻ trực tiếp của deck cha; sau đó áp phạm vi BR-5 + `hidden=0` (D-006) + lấy tối đa `game.words_per_round` (D-008).
- DB assert: tập thẻ ván ⊆ hợp đệ quy thẻ (`hidden=0`) của deck cha và mọi deck con; KHÔNG ghi (D-007).

---

## 6. Async & lỗi

### SC-GAMERECALL-50 — loading (dựng ván)
Given: đang đọc `settings` + thẻ theo phạm vi để dựng ván.
Then: ⚠ Xác nhận: kit KHÔNG có state `loading` cho `game-recall` → hiện gì trong lúc dựng? (skeleton? spinner? mở ngay?). Assert tối thiểu: không hiện số/nghĩa rác; không crash. → Open questions.

### SC-GAMERECALL-51 — Đọc thẻ/settings thất bại
Given: truy vấn `cards`/`card_meanings`/`settings` lỗi.
Then: ⚠ Xác nhận: kit KHÔNG có state `error` cho `game-recall` → hiện gì? (báo lỗi ARB + retry? pop về nguồn?). Lỗi phải flow `Failure`→`AsyncValue.error`, không nuốt (CLAUDE.md §5). → Open questions.

### SC-GAMERECALL-52 — Retry sau lỗi
Given: (nếu có surface lỗi ở SC-51) có nút thử lại.
When: chạm retry.
Then: dựng lại ván; nếu thành công → `before-reveal`. ⚠ Phụ thuộc câu trả lời SC-51.

### SC-GAMERECALL-53 — Local-first (không mạng)
Nguồn: CLAUDE.md §4 (local-first, no remote v1)
Given: tắt mạng.
Then: Recall chạy đầy đủ từ DB local (thẻ/nghĩa từ Drift); chỉ `audio` (nếu là TTS live) có thể phụ thuộc mạng — xem SC-GAMERECALL-12. Không phần nào khác phụ thuộc mạng.

---

## 7. Persistence (DB round-trip)

### SC-GAMERECALL-60 — Game độc lập KHÔNG đổi SRS
Nguồn: D-007/D-013/BR-4 · `srs_state`
Given: card[X] có `srs_state`(box=k, due_at=T) trước ván.
When: chơi trọn ván Recall độc lập, chấm Forgot rồi Got it card[X].
Then:
- UI: đi qua revealed→forgot→…→remembered→complete.
- DB: `srs_state[X].box`=k, `due_at`=T, `last_reviewed_at` **không đổi**; `review_logs` **không** thêm dòng cho card[X] (D-007).

### SC-GAMERECALL-61 — Game độc lập KHÔNG cộng hoạt động ngày
Nguồn: BR-4/D-010 · `study_sessions`, `daily_activity`
Given: `daily_activity`(hôm nay: minutes=m, words=w).
When: hoàn thành ván Recall độc lập.
Then: DB: KHÔNG thêm `study_sessions`; `daily_activity`(hôm nay) minutes=m, words=w **không đổi** (chỉ DueReview/NewLearn cộng — D-010/BR-4).

### SC-GAMERECALL-62 — Recall trong NewLearn: SRS chỉ khi đủ 5 chặng
Nguồn: D-002/D-017 (bối cảnh b)
Given: thẻ mới, đang ở chặng 4 (Recall) của NewLearn.
When: (a) hoàn thành đủ 5 chặng → (b) thoát giữa chặng 4.
Then:
- (a) DB: sau chặng 5, `srs_state[card].box`=1, `due_at`=now+interval(ô1)=now+1 ngày; +1 `review_logs`? ⚠ Xác nhận: NewLearn graduating có ghi `review_logs` không (schema ghi review_logs cho "DueReview grade"; NewLearn chỉ đổi box). — Open questions.
- (b) DB: thẻ **vẫn mới**, KHÔNG có `srs_state` box>0 (D-017).

### SC-GAMERECALL-63 — Kill & mở lại app giữa ván (game độc lập)
When: đang chơi ván Recall độc lập → kill app → mở lại.
Then: ⚠ Xác nhận: ván game độc lập KHÔNG persist (không bảng lưu tiến độ ván trong schema) → mở lại app KHÔNG resume ván; DB nguyên trạng (không rác). Assert: `srs_state`/`review_logs`/`study_sessions`/`daily_activity` giống trước khi vào ván. → Open questions (resume policy).

---

### SC-GAMERECALL-64 — Nghĩa chính = `card_meanings.sort_index` nhỏ nhất (DB round-trip)
Nguồn: `card_meanings.sort_index` · contract[revealed] (meaning đầu) · schema
Given: seed 1 thẻ có ≥2 `card_meanings` với `sort_index` **đảo thứ tự insert** — vd insert content "B" trước (rowid nhỏ hơn) nhưng `sort_index`=1, insert content "A" sau nhưng `sort_index`=0.
When: mở Recall thẻ này → chạm reveal.
Then:
- UI: **nghĩa chính** hiển thị = content của meaning có `sort_index` **nhỏ nhất** ("A"), KHÔNG phải theo rowid/thứ tự insert ("B"); dòng phụ (nếu render) = meaning `sort_index` kế tiếp.
- Đây là assert nguồn-dữ liệu load-bearing: ordering thực theo `sort_index`, round-trip qua Drift. DB: KHÔNG ghi.
⚠ Liên quan Open questions #14 (số meaning hiển thị): assert này chỉ chốt **thứ tự chọn nghĩa chính**, không chốt có nối nhiều nghĩa hay không.

---

## 8. Định dạng & i18n

### SC-GAMERECALL-70 — Term/nghĩa CJK render đúng
Nguồn: term MOCK "친구" (Hàn) · game-modes §9
Given: card term Hàn/Nhật ("친구" / "友達"), nghĩa có ký tự CJK.
Then: term card + nghĩa (sau reveal) render đúng glyph CJK (không tofu); không cắt sai; font size lớn (spec term 48px) vẫn khít card.

### SC-GAMERECALL-71 — Chuỗi UI theo locale (ARB)
Given: đổi locale (vi/en/ja).
Then: title "Recall", nút "Show"/"Forgot"/"Got it"/"Next round", gợi ý, banner, "Round complete!" + phụ đề đều đổi theo ARB (không hardcode kit copy); layout không vỡ.

### SC-GAMERECALL-72 — Term rất dài → wrap/ellipsis
Given: term dài (nhiều từ / 1 từ dài).
Then: term card wrap hoặc scale, KHÔNG tràn card (spec term font 48/800) và KHÔNG đẩy audio/edit ra ngoài. ⚠ Xác nhận: term dài thu nhỏ font hay wrap nhiều dòng?

### SC-GAMERECALL-73 — Nghĩa dài / nhiều nghĩa
Given: `card_meanings.content` dài, hoặc thẻ có nhiều meaning.
Then: nghĩa (sau reveal) wrap trong `meaning` card (`minh:120`, tự cao thêm). **Assert layout-height-delta theo state**: card đo 120px ở before-reveal (spec dòng 181) → **128px** ở revealed/forgot/remembered (spec abs 350x128 — dòng 233/339/461) do thêm divider + nghĩa chính + nghĩa phụ; `minh:120` là sàn, không phải chiều cao cố định. Dòng phụ nghĩa hiển thị hợp lý. ⚠ Xác nhận: hiển thị mấy meaning (chỉ meaning đầu, hay nối)? — spec chỉ có 1 dòng nghĩa chính + 1 dòng phụ (Open questions #14).

### SC-GAMERECALL-74 — Progress theo tỉ lệ (không phụ thuộc locale số)
Then: thanh `progress` là tỉ lệ đồ hoạ (không hiển thị số) → không cần format số; nhưng nếu có nhãn %/đếm thẻ (⚠ kit không có) thì theo locale. Assert: tỉ lệ khớp số thẻ đã đúng / tổng.

---

## 9. Dark mode

### SC-GAMERECALL-80 — Mọi state ở dark
Nguồn: CLAUDE.md §3 (token, không hardcode)
Then: 5 state (before-reveal/revealed/forgot/remembered/complete) render đúng ở cả light + dark bằng token: `bg`/`surface`/`surface-sunken`/`primary`/**`primary-strong`** (nút Forgot mặc định — spec dòng 315/559)/`divider`/`warning-soft`+`on-warning-soft`/`success-soft`+`on-success-soft`/`error`/`text`/**`text-secondary`** (nghĩa phụ "a friend, companion" — spec dòng 293)/**`text-tertiary`** (dòng gợi ý before-reveal — spec dòng 195/201)/`surface` (text-on-primary/on-error). Không `Color(0x..)`. Contrast nút primary (surface on primary) + nút error (surface on error) đạt.

---

## 10. Responsive

### SC-GAMERECALL-81 — 320px → tablet + xoay
Then: ở 320px: appbar không tràn; term/meaning card + lưới 2 nút (forgot/remembered gap 12) không overflow; nút reveal min-height 56 giữ. Nội dung dài cuộn được (body là scroll container). Xoay ngang: card co giãn, nút không chồng. Safe-area/notch: appbar + nút dưới không bị che.

---

## 11. A11y

### SC-GAMERECALL-82 — Semantics + hit-area + thứ tự đọc
Then:
- Mỗi control (`back`/`options`/`audio`/`edit`/`reveal`/`forgot`/`remembered`/`next`) có semantic label (ARB, mô tả hành động — không đọc tên icon "arrow_back").
- Hit-area ≥48: `back`/`options`/`audio` = 48x48 ✅; **`edit` = 36x36** (< 48) → ⚠ cần mở rộng vùng chạm ≥48 dù icon 36 (A11y gap tiềm ẩn — liệt kê Open questions).
- Thứ tự đọc: appbar (back→title→options) → progress (đọc "đã học X/Y"?) → term → audio/edit → meaning/gợi ý → reveal; sau reveal: nghĩa → forgot → remembered; complete: tiêu đề → phụ đề → next.
- Banner forgot/remembered được screen-reader thông báo (live region) khi xuất hiện.
- Term CJK đọc đúng ngôn ngữ (lang attribute theo learning language).

---

## 12. Concurrency & edge thời gian

### SC-GAMERECALL-90 — Double-tap reveal / forgot / remembered / next
Then: chạm nhanh 2 lần cùng nút → chỉ áp **một** lần chuyển state (không double-reveal, không chấm 2 thẻ, không mở 2 ván). `reveal` sau khi biến mất không nhận thêm tap.

### SC-GAMERECALL-91 — Chấm nhanh Forgot rồi Remembered (đảo)
Given: `revealed`.
When: chạm Forgot rồi ngay Got it (hoặc ngược lại) trước khi chuyển thẻ.
Then: ⚠ Xác nhận: hành vi khi hai nút bấm sát nhau — chỉ ăn nút đầu? khoá nút sau khi chấm? (kit chụp state tĩnh). Assert: chỉ một kết quả áp cho thẻ hiện tại. → Open questions.

### SC-GAMERECALL-92 — Back khi banner forgot/remembered đang hiện
When: chấm Got it → banner hiện → back ngay trước khi chuyển thẻ.
Then: pop an toàn, không crash; game độc lập không ghi DB. ⚠ Xác nhận (chung dialog bỏ ván SC-GAMERECALL-10/34).

### SC-GAMERECALL-93 — Nửa đêm đổi ngày khi đang chơi (game độc lập)
Given: đang chơi ván Recall độc lập lúc 23:59; đồng hồ qua 00:00.
Then: game độc lập KHÔNG cộng `daily_activity`/không đổi streak (BR-4/D-010) → đổi ngày KHÔNG ảnh hưởng ván; không ghi bucket ngày mới. Assert: `daily_activity` không thêm dòng do ván này. (Khác dashboard SC-DASH-90 vốn phụ thuộc hoạt động.)

---

## Open questions (⚠ cần chốt spec trước khi viết test — KHÔNG bịa)

1. **Nút `options` (more_horiz)**: mở menu/sheet gì? nội dung menu-item? (kit không chụp overlay; không có D-xxx/business) — SC-GAMERECALL-11.
2. **Nút `audio`**: v1 phát TTS live hay no-op/disabled (schema `cards.audio_ref` NULL ở v1, TTS hoãn DT.7)? — SC-GAMERECALL-12.
3. **Nút `edit`**: đích khi chạm (mở editor thẻ hiện tại?); quay lại Recall giữ vị trí ván? — SC-GAMERECALL-13.
4. **Nút `next` "Next round"**: bắt đầu ván mới trên cùng deck (lấy words_per_round thẻ, random theo `game.random`) hay quay về màn nguồn? — SC-GAMERECALL-17.
5. **Thời lượng banner** forgot/remembered trước khi tự chuyển thẻ (tự động sau N ms hay chờ thao tác?) — SC-GAMERECALL-03/04.
6. **Back giữa ván**: có dialog xác nhận "bỏ ván"? chặn swipe-dismiss/Android back? — SC-GAMERECALL-10/34/35.
7. **State empty**: khi 0 thẻ đủ điều kiện (deck rỗng / toàn hidden / phạm vi rỗng) — kit không có state empty cho màn này; hiện gì? — SC-GAMERECALL-40.
8. **State loading**: dựng ván — kit không có `loading`; hiện skeleton/spinner/mở ngay? — SC-GAMERECALL-50.
9. **State error**: đọc thẻ/settings lỗi — kit không có `error`; surface lỗi + retry ra sao? — SC-GAMERECALL-51/52.
10. **Progress ở NewLearn**: tính theo 5 chặng tích luỹ hay theo thẻ trong chặng Recall? — SC-GAMERECALL-31.
11. **NewLearn graduating** có ghi `review_logs` không (schema mô tả review_logs cho DueReview grade; NewLearn chỉ đổi box)? — SC-GAMERECALL-62.
12. **Resume ván**: kill/mở lại app giữa ván game độc lập — không persist tiến độ ván (không bảng trong schema) → xác nhận "không resume"? — SC-GAMERECALL-63.
13. **words_per_round biên**: có min/max? ván lấy min(words_per_round, thẻ khả dụng)? — SC-GAMERECALL-41/43.
14. **Số meaning hiển thị** sau reveal: chỉ meaning đầu, hay nối nhiều meaning (spec: 1 nghĩa chính + 1 dòng phụ)? — SC-GAMERECALL-73.
15. **Label phạm vi BR-5** trong picker (Theo giãn cách / Tất cả / Chỉ chưa thuộc) — nguồn ARB? (thuộc màn `game`, ảnh hưởng tập thẻ vào Recall) — SC-GAMERECALL-30.
16. **A11y hit-area `edit`**: icon 36x36 < 48 — có mở rộng vùng chạm ≥48 không? — SC-GAMERECALL-82.
17. **Đảo Forgot/Got it** sát nhau: khoá nút sau chấm đầu? — SC-GAMERECALL-91.
18. **Định nghĩa hoàn thành ván khi có thẻ Forgot**: D-015 chỉ nói "phiên xong khi MỌI thẻ đã đúng"; điều kiện chính xác để đạt `complete` khi có thẻ Forgot chưa có nguồn kit/contract — thẻ Forgot phải được Got-it lại rồi mới complete, hay Forgot chỉ đẩy xuống cuối hàng đợi **1 lần**? — SC-GAMERECALL-05.
19. **Component mapping / identity contract cho control game-recall**: mọi control tương tác (`back`/`options`/`audio`/`edit`/`reveal`/`forgot`/`remembered`/`next`) là `mx:?` trong DOM spec = không có MemoX component mapping tin cậy; khoá identity per-screen (`tool/parity/contracts/`) cho các control này chưa được chốt — chốt mapping/identity key nào? — SC-GAMERECALL-18..21.

> Các mục ⚠ ở trên là **danh sách phải hỏi BA/spec**, không được đoán. Khi có câu trả lời → cập nhật
> scenario tương ứng + xoá cờ ⚠. Đây chính là "không bỏ sót": phần chưa rõ được **liệt kê ra**, không lờ đi.
