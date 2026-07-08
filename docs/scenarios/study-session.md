# Kịch bản — Study Session (5 chặng) · screen `study-session`

Nguồn: `docs/contracts/study-session.md` [stage1-review · stage2-matching · stage3-choice ·
stage4-recall · stage5-typing · relearn · due-review · exit · resume-error · answer-save-error] ·
DOM `specs/study-session.md` · D-001, D-002, D-003, D-004, D-005, D-006, D-007, D-009, D-010,
D-011, D-015, D-016, D-017, D-018, D-021, D-029 · BR `business/study/study-flow.md` (BR-1..8) +
`business/srs/srs-review.md` (BR-1..8) + `business/game/game-modes.md` (BR-3) ·
DB `srs_state`, `review_logs`, `study_sessions`, `daily_activity`, `cards`, `card_meanings`,
`decks`, `settings`.

> Route (navigation-flow): `study` = `/study/:nodeId` (push), tham số **`entry` = newLearn / dueReview**.
> Màn học đơn không có UI riêng cho DueReview — nó **tái dùng** các màn chặng (study-flow UC-3, D-029).
> Số/tên/nghĩa trong kit là MOCK ("학교", "school", "16%", "학교↔school") — assert **định dạng & nguồn**
> (term từ `cards.term`, nghĩa từ `card_meanings.content`, % = tiến độ tính từ hàng đợi), KHÔNG assert
> giá trị mock. Chuỗi lấy từ ARB (`lib/l10n/`), không copy kit. State phải có thật trong contract.

## DoE — study-session (12 chiều)

| # | Chiều | TT | Scenario / N/A |
|---|---|---|---|
| 1 | States (10) | ✅ | SC-STUDYSESSION-01..10 |
| 2 | Elements (node có `id`/interactive trong DOM spec — xem đếm bên dưới) | ✅ | SC-STUDYSESSION-20..43 |
| 3 | Nav vào/ra | ✅ | SC-STUDYSESSION-50..57 |
| 4 | Nhập liệu & validation (field `check`/typing) | ✅ | SC-STUDYSESSION-60..67 |
| 5 | Lượng dữ liệu | ✅ | SC-STUDYSESSION-70..75 |
| 6 | Async & lỗi | ✅ | SC-STUDYSESSION-80..85 |
| 7 | Persistence (DB round-trip) | ✅ | SC-STUDYSESSION-90..98 |
| 8 | Định dạng & i18n | ✅ | SC-STUDYSESSION-100..105 |
| 9 | Dark mode | ✅ | SC-STUDYSESSION-110 |
| 10 | Responsive | ✅ | SC-STUDYSESSION-111 |
| 11 | A11y | ✅ | SC-STUDYSESSION-112 |
| 12 | Concurrency & edge thời gian | ✅ | SC-STUDYSESSION-120..126 |

Element inventory — **phạm vi đếm** = node **có `id`** hoặc **interactive** trong DOM spec (mỗi node ≥1
scenario ở mục 2). DOM spec có **14 control interactive có `id`** (mỗi cái 1 scenario 1-1 ở dưới):
`close` (icon-button, id `study-session/close`, SC-20) · `options` (icon-button more_horiz · id
`study-session/options`, SC-22) · `next` (btn "Next" · stage1, id `study-session/next`, SC-23) ·
`reveal` (btn "Show" · stage4, SC-28) · `hint` (btn "Help" · stage5, SC-30) · `check` (btn "Check" ·
stage5, SC-31/32) · `due-relearn` (btn "Relearn" · due-review, SC-33) · `due-next` (btn "Next" ·
due-review, SC-34) · `exit-cancel` (btn "Stay", SC-35) · `exit-ok` (btn "Leave", SC-36) · `resume-retry`
(btn "Restart session", SC-37) · `resume-back` (btn "Back to deck", SC-38) · `save-error-retry` (btn
"Retry", SC-39) · `save-error-back` (btn "Back", SC-40).
Node **có `id` không-interactive** (đọc/hiển thị): `progress` (span % · id `study-session/progress`, SC-21) ·
`card` (thẻ nội dung · id `study-session/card` ở stage1 + due-review, SC-43) · các container id
(`screen`/`appbar`/`exit-scrim`/`exit-dialog`/`resume-error`/`save-error-scrim`/`save-error-dialog`) — phủ
gián tiếp qua state (mục 1) + a11y (mục 11).
Node **KHÔNG có `id`** nhưng bấm được (kit không gắn id — mỗi loại vẫn cần scenario tương tác): chip ghép
đôi stage2 (6 `div` term/nghĩa, mỗi chip 1 node bấm được — SC-24/25 gộp hành vi + SC-41 khẳng định
mỗi chip là 1 target riêng) · hàng lựa chọn stage3/relearn (3 `div` row, mỗi row 1 `span` nghĩa — SC-26/27
gộp + SC-42 khẳng định mỗi row là 1 target riêng) · field typing stage5 (`div` placeholder "Type the
Korean word…", SC-29) · banner relearn/due-review (hiển thị, không bấm — phủ ở SC-06/07).
> Ghi chú đếm: con số cũ "17 node" đã bỏ vì không có căn cứ 1-1 với DOM spec; phạm vi nay chốt theo
> **node có `id`/interactive**. Các chip/row id-less được ánh xạ 1-1 bằng SC-41/SC-42 để giữ tiêu chí
> "mỗi node DOM bấm được ≥1 scenario".

---

## 1. States (mỗi state ≥1 scenario dẫn tới nó)

### SC-STUDYSESSION-01 — stage1-review (base, chặng 1 = Xem lại)
Nguồn: contract[stage1-review] · spec base · study-flow UC-2 (chặng 1 = Xem lại) · BR-3(study)
Given: DB `decks`(1 "Korean"), `cards`(1 term hiển thị, hidden=0, ≥1 `card_meanings`), `srs_state` chưa có (box 0);
mở `study` với `entry=newLearn`
When: phiên tới thẻ đầu ở chặng 1
Then:
- UI: appbar hiện `close` + `progress` (nhãn % định dạng "N%" từ tiến độ hàng đợi, KHÔNG assert "16%") + `options`;
  tiêu đề section "Stage 1 · Review" (ARB) · thẻ `study-session/card` hiện term (font lớn) + divider + nghĩa (từ
  `card_meanings.content`, meaning `sort_index` nhỏ nhất) + phụ đề loại từ nếu có · nút `next` "Next" (ARB).
- DB: chưa ghi gì (D-017 — chưa hoàn thành 5 chặng ⇒ không có `srs_state`).

### SC-STUDYSESSION-02 — stage2-matching (chặng 2 = Ghép đôi)
Nguồn: contract[stage2-matching] · spec diff · study-flow (chặng 2–5 = 4 game) · game-modes "Ghép đôi"
Given: đang trong phiên newLearn, đã qua chặng 1
When: sang chặng 2
Then:
- UI: "Stage 2 · Matching"; lưới 2 cột — cột trái các nghĩa/term, cột phải phía đối ứng (6 chip trong mock),
  mỗi chip là thẻ có `border:1px divider`; `progress` cập nhật tiến độ cao hơn chặng 1.
- DB: không ghi (chặng chưa chốt).

### SC-STUDYSESSION-03 — stage3-choice (chặng 3 = Đoán / Multiple choice)
Nguồn: contract[stage3-choice] · spec diff · game-modes "Đoán" (term → nghĩa)
Given: đang trong phiên newLearn, qua chặng 2
When: sang chặng 3
Then:
- UI: "Stage 3 · Multiple choice"; card hiện term; danh sách 3 hàng lựa chọn (mỗi hàng 1 nghĩa), mỗi hàng
  `bg:surface r:12 border:1px divider`. ⚠ Số lựa chọn = mấy? mock=3; xác nhận N (xem Open questions).
- DB: không ghi.

### SC-STUDYSESSION-04 — stage4-recall (chặng 4 = Nhớ lại)
Nguồn: contract[stage4-recall] · spec diff · game-modes "Nhớ lại"
Given: đang trong phiên newLearn, qua chặng 3
When: sang chặng 4
Then:
- UI: "Stage 4 · Recall"; card term + card gợi ý "Recall the meaning, then tap "Show"" (ARB) ·
  nút `reveal` "Show" (icon visibility). ⚠ Sau khi bấm Show lộ gì + nút tự chấm "Đã quên/Nhớ được"
  (game-modes) — DOM spec state này KHÔNG có nút chấm ⇒ liệt kê Open questions.
- DB: không ghi.

### SC-STUDYSESSION-05 — stage5-typing (chặng 5 = Điền)
Nguồn: contract[stage5-typing] · spec diff · game-modes "Điền" (nghĩa → term)
Given: đang trong phiên newLearn, qua chặng 4
When: sang chặng 5
Then:
- UI: "Stage 5 · Typing"; card hiện nghĩa + nhãn "MEANING" (ARB) · field nhập placeholder "Type the Korean word…"
  (ARB) · hàng 2 nút: `hint` "Help" (icon lightbulb) + `check` "Check" (icon; primary).
- DB: không ghi (chưa chốt phiên).

### SC-STUDYSESSION-06 — relearn (học lại thẻ sai — không tính tiến độ)
Nguồn: contract[relearn] · spec diff · study-flow BR-4 / D-015 (sai → học lại) · game-modes BR-3
Given: trong phiên, người học trả lời **sai** một thẻ ở một chặng
When: thẻ được đưa lại hàng đợi để học lại
Then:
- UI: banner "Review this word — not counted toward progress." (ARB · `bg:warning-soft` · icon replay) đặt trên
  nội dung chặng luyện lại (mock hiển thị dạng "Stage 3 · Multiple choice"); `progress` KHÔNG tăng cho lần luyện lại.
- DB: không ghi `srs_state` (D-017 vẫn giữ — chưa hoàn thành).
- ⚠ Sai có thể xảy ra ở **bất kỳ** chặng (2/3/4/5 · BR-4), nhưng kit chỉ mock relearn ở dạng Multiple choice.
  Không rõ relearn **giữ đúng dạng chặng vừa sai** hay **luôn về Multiple choice** ⇒ Open questions (#20).

### SC-STUDYSESSION-07 — due-review (Lặp lại thẻ đến hạn — chấm SRS)
Nguồn: contract[due-review] · spec diff · study-flow UC-3 / D-001 · srs-review UC-2
Given: DB `srs_state` có ≥1 thẻ `due` (box k, `due_at <= now`), thẻ không hidden (D-006); mở `study` với
`entry=dueReview` (badge>0 ⇒ mục "Lặp lại" khả dụng, D-001/D-016)
When: phiên tới một thẻ đến hạn
Then:
- UI: tiêu đề "Review · due cards" (ARB) · banner "Reviewing due cards — results update the Leitner box." (ARB ·
  `bg:warning-soft` · icon schedule) · card hiện term + nghĩa · hàng nút `due-relearn` "Relearn" (icon replay ·
  ghost) + `due-next` "Next" (icon arrow_forward · primary).
- DB: chưa ghi cho tới khi chấm (xem SC-…-90/91).

### SC-STUDYSESSION-08 — exit (dialog xác nhận thoát)
Nguồn: contract[exit] · spec diff · D-017 (thoát giữa chừng → thẻ vẫn Mới)
Given: đang trong một chặng bất kỳ (newLearn chưa hoàn tất)
When: bấm `close` (hoặc back hệ thống)
Then:
- UI: scrim `bg:overlay` (z:60) + dialog `exit-dialog`: icon-tile logout (`bg:warning-soft`) · tiêu đề
  "Leave the session?" (ARB) · mô tả "Cards that haven't finished all 5 stages will stay New." (ARB) ·
  2 nút `exit-cancel` "Stay" (ghost) + `exit-ok` "Leave" (primary).
- DB: chưa ghi gì (chỉ khi bấm Leave và D-017 áp — không tạo `srs_state`).

### SC-STUDYSESSION-09 — resume-error (không khôi phục được phiên)
Nguồn: contract[resume-error] · spec full
Given: có một phiên dở dang cần resume nhưng khôi phục thất bại
When: mở màn / thử resume
Then:
- UI: appbar `close` + tiêu đề "Resume session" (ARB) · icon-tile play_disabled (`bg:error-soft`) ·
  tiêu đề "Couldn't resume your session" (ARB) · mô tả "We couldn't restore where you left off…" (ARB) ·
  nút `resume-retry` "Restart session" (primary, icon refresh) + `resume-back` "Back to deck" (ghost).
- DB: không ghi.
- ⚠ Cơ chế lưu/khôi phục phiên dở (persist session progress) chưa có bảng trong schema-contract ⇒ Open questions.

### SC-STUDYSESSION-10 — answer-save-error (lưu kết quả 1 thẻ thất bại)
Nguồn: contract[answer-save-error] · spec full · srs-review UC-2 (ghi lịch)
Given: đang ở một chặng (mock = Stage 5 · Typing), người học chấm xong một thẻ; ghi `srs_state`/`review_logs` lỗi
When: hệ thống cố lưu kết quả và thất bại
Then:
- UI: màn chặng nền + scrim (z:60) + dialog `save-error-dialog`: icon-tile sync_problem (`bg:error-soft`) ·
  tiêu đề "Couldn't save your answer" (ARB) · mô tả "Your result for this card wasn't saved. Retry…" (ARB) ·
  2 nút `save-error-back` "Back" (ghost) + `save-error-retry` "Retry" (primary, icon refresh).
- DB: bản ghi thất bại KHÔNG được commit (kết quả thẻ chưa lưu — schedule giữ nguyên tới khi Retry thành công).

---

## 2. Elements (mỗi node tương tác trong DOM spec ≥1 scenario)

### SC-STUDYSESSION-20 — `close` (icon-button đóng, mọi state có appbar)
Nguồn: spec `study-session/close` (mx:?) · D-017
When: chạm `close` khi đang giữa phiên newLearn
Then: UI mở overlay `exit` (SC-…-08), KHÔNG rời màn ngay. ⚠ Xác nhận: trong dueReview / khi phiên "sạch"
(chưa trả lời thẻ nào) — `close` mở dialog hay thoát thẳng? (spec chỉ định nghĩa 1 dialog exit).

### SC-STUDYSESSION-21 — `progress` (span %)
Nguồn: spec `study-session/progress`
Then: hiển thị % tiến độ định dạng "N%" theo locale (SC-…-100); giá trị = tiến độ hàng đợi (không assert mock).
Biến thể: 0% đầu phiên · gần 100% chặng cuối · relearn KHÔNG tăng %.

### SC-STUDYSESSION-22 — `options` (icon-button more_horiz)
Nguồn: spec `study-session/options` (mx:?)
When: chạm `options`
Then: ⚠ Đích chưa có trong D-xxx/business (menu gì? — kết thúc phiên? báo lỗi thẻ? tắt âm?). Assert tối thiểu:
nút có semantic label, hit-area ≥48, không crash. Nội dung menu ⇒ Open questions.

### SC-STUDYSESSION-23 — `next` (btn "Next" · stage1 review)
Nguồn: spec `study-session/next` (stage1) · study-flow UC-2 (5 chặng khó dần, ở **cấp phiên**)
When: ở chặng 1 chạm "Next"
Then: UI sang chặng 2 (stage2-matching); `progress` tăng. DB: không ghi.
> ⚠ DOM spec chỉ là các state độc lập ("the kit carries no flow") — **transition** stage1→2→…→5 và việc mỗi
> chặng = 1 thẻ hay = cả hàng đợi (per-card vs per-stage-batch) là **suy diễn** (study-flow liệt kê 5 chặng ở
> cấp phiên, không cấp thẻ). Giả định này ngầm ở SC-…-01..05/24/71 ⇒ Open questions (#21) — chốt mô hình tiến trình.

### SC-STUDYSESSION-24 — Chip ghép đôi đúng (stage2)
Nguồn: spec stage2 (6 chip 2 cột) · game-modes "Ghép đôi" (cặp đúng biến mất)
When: chọn 1 chip cột trái + chip đối ứng đúng cột phải
Then: UI cặp đúng biến mất/đánh dấu khớp; khi hết cặp → sang chặng 3. DB: không ghi.
(⚠ "hết cặp → sang chặng 3" giả định luồng tuyến tính per-stage — xem mô hình tiến trình Open questions #21.)

### SC-STUDYSESSION-25 — Chip ghép đôi SAI (stage2)
Nguồn: spec stage2 · D-015 / BR-3(game) (sai → lặp lại trong ván)
When: chọn 2 chip không khớp
Then: UI báo sai (cặp không biến mất; thẻ lặp lại); ⚠ hình thức phản hồi sai (rung/đổi màu) không có trong spec ⇒
Open questions. DB: không ghi.

### SC-STUDYSESSION-26 — Đáp án đúng (stage3 choice)
Nguồn: spec stage3 (3 hàng) · game-modes "Đoán"
When: chạm hàng chứa nghĩa đúng
Then: UI đánh dấu đúng → sang chặng 4. DB: không ghi.

### SC-STUDYSESSION-27 — Đáp án SAI (stage3 choice)
Nguồn: spec stage3 · D-015
When: chạm hàng nghĩa sai
Then: UI báo sai; thẻ vào diện học lại (có thể chuyển trạng thái `relearn` SC-…-06). DB: không ghi.

### SC-STUDYSESSION-28 — `reveal` (btn "Show" · stage4 recall)
Nguồn: spec `study-session/reveal` · game-modes "Nhớ lại"
When: chạm "Show"
Then: UI lộ nghĩa của thẻ. ⚠ Sau khi lộ, spec state stage4 KHÔNG có nút "Đã quên/Nhớ được" (game-modes yêu cầu) ⇒
Open questions (thiếu control tự chấm). DB: không ghi (chưa chốt).

### SC-STUDYSESSION-29 — Field typing (stage5)
Nguồn: spec stage5 field "Type the Korean word…"
When: gõ ký tự vào field
Then: UI field nhận input; placeholder ẩn khi có text. (Validation chi tiết ở mục 4.) DB: không ghi khi gõ.

### SC-STUDYSESSION-30 — `hint` (btn "Help" · stage5)
Nguồn: spec `study-session/hint` · game-modes "Điền" (có "Trợ giúp")
When: chạm "Help"
Then: UI hiện gợi ý cho term đang điền. ⚠ Nội dung gợi ý (lộ 1 ký tự? lộ term?) không có trong spec ⇒ Open questions.
DB: không ghi.

### SC-STUDYSESSION-31 — `check` (btn "Check" · stage5) — đúng
Nguồn: spec `study-session/check` · game-modes "Điền" ("chấp nhận dung sai") · BR-2(srs)/BR-3(study)
Given: field chứa term khớp (kể cả dung sai)
When: chạm "Check"
Then: UI đánh dấu đúng → hoàn tất chặng 5. ⚠ "thẻ graduate sau đủ 5 chặng" đúng theo BR-2/BR-3, nhưng
**mô hình tiến trình** (mỗi thẻ đi riêng qua 5 chặng hay cả hàng đợi đi theo từng chặng/batch) KHÔNG được
DOM spec/study-flow định nghĩa rõ ⇒ Open questions (khi nào graduate 1 thẻ vs cả phiên). Nếu là thẻ cuối →
chốt phiên (SC-…-90). DB (khi chốt): xem mục 7.

### SC-STUDYSESSION-32 — `check` (btn "Check" · stage5) — sai
Nguồn: spec `study-session/check` · D-015
Given: field chứa term không khớp
When: chạm "Check"
Then: UI báo sai; thẻ vào diện học lại (relearn). DB: không ghi.

### SC-STUDYSESSION-33 — `due-relearn` (btn "Relearn" · due-review) = chấm SAI
Nguồn: spec `study-session/due-relearn` · srs-review BR-4 / D-004 · study-flow UC-3
When: ở due-review chạm "Relearn" cho thẻ ở ô k
Then:
- UI: sang thẻ due kế tiếp (hoặc chốt nếu hết).
- DB: `srs_state[card].box` = max(1, k−1) (D-004 · sàn ô 1); `last_reviewed_at` = now; `review_logs` +1 dòng
  `grade='fail'`, `reviewed_at`=now. `due_at` khi sai = **suy diễn** now+interval(ô mới) — chưa có nguồn minh
  thị (BR-4 chỉ nói lùi ô), xem Open questions (#19).

### SC-STUDYSESSION-34 — `due-next` (btn "Next" · due-review) = chấm ĐÚNG
Nguồn: spec `study-session/due-next` · srs-review BR-3 / D-003, D-005
When: ở due-review chạm "Next" cho thẻ ở ô k
Then:
- UI: sang thẻ due kế tiếp (hoặc chốt).
- DB: nếu k<8 → `box`=k+1, `due_at`=now+interval(k+1) (D-003); nếu k=8 → giữ box 8, `due_at`=NULL (D-005/BR-5);
  `last_reviewed_at`=now; `review_logs` +1 dòng `grade='pass'`, `reviewed_at`=now (khớp `last_reviewed_at`).

### SC-STUDYSESSION-35 — `exit-cancel` (btn "Stay")
Nguồn: spec `study-session/exit-cancel`
When: ở overlay exit chạm "Stay"
Then: UI đóng dialog, quay lại đúng chặng đang dở (giữ nguyên tiến độ). DB: không đổi.

### SC-STUDYSESSION-36 — `exit-ok` (btn "Leave")
Nguồn: spec `study-session/exit-ok` · D-017
When: ở overlay exit (phiên newLearn dở) chạm "Leave"
Then:
- UI: rời màn `study` → về nơi gọi (deck-detail).
- DB: các thẻ **chưa** hoàn thành đủ 5 chặng KHÔNG có `srs_state` (giữ box 0 / vẫn Mới · D-017);
  không tạo `study_sessions`, không cộng `daily_activity` (phiên chưa chốt).

### SC-STUDYSESSION-37 — `resume-retry` (btn "Restart session")
Nguồn: spec `study-session/resume-retry`
When: ở resume-error chạm "Restart session"
Then: UI dựng lại phiên từ đầu cho cùng node/entry (về chặng 1 hoặc thẻ due đầu). DB: không ghi khi restart.

### SC-STUDYSESSION-38 — `resume-back` (btn "Back to deck")
Nguồn: spec `study-session/resume-back`
When: ở resume-error chạm "Back to deck"
Then: UI rời `study` → về deck-detail của node. DB: không đổi.

### SC-STUDYSESSION-39 — `save-error-retry` (btn "Retry")
Nguồn: spec `study-session/save-error-retry` · srs-review UC-2
When: ở answer-save-error chạm "Retry"
Then:
- UI: đóng dialog nếu lưu lại thành công → tiếp phiên.
- DB: ghi lại kết quả thẻ (`srs_state` chuyển ô + `review_logs` +1) đúng như SC-…-33/34 (idempotent — không nhân đôi log).

### SC-STUDYSESSION-40 — `save-error-back` (btn "Back")
Nguồn: spec `study-session/save-error-back`
When: ở answer-save-error chạm "Back"
Then: UI rời màn / về deck-detail (không lưu kết quả thẻ vừa chấm). ⚠ Xác nhận: "Back" bỏ kết quả thẻ hiện tại
hay giữ các thẻ đã chấm trước đó trong phiên? DB: kết quả thẻ lỗi không commit.

### SC-STUDYSESSION-41 — Mỗi chip ghép đôi (stage2) là 1 target bấm riêng
Nguồn: spec stage2 (6 `div` chip id-less, 2 cột × 3 hàng) · game-modes "Ghép đôi"
When: chạm **đúng một** chip bất kỳ trong 6 chip (không phải cả lưới)
Then: UI đánh dấu **chỉ** chip đó là đang-chọn (không kích hoạt chip khác cùng lúc); mỗi chip có hit-area ≥48
(mỗi `div` cao 57 theo spec) và semantic label riêng (term/nghĩa). Hành vi ghép đúng/sai: SC-…-24/25.
> Bổ sung ánh xạ 1-1 cho node id-less: 6 chip = 6 target độc lập, không gộp thành 1 vùng.

### SC-STUDYSESSION-42 — Mỗi hàng lựa chọn (stage3/relearn) là 1 target bấm riêng
Nguồn: spec stage3 + relearn (3 `div` row id-less, mỗi row 1 `span` nghĩa) · game-modes "Đoán"
When: chạm **đúng một** hàng trong 3 hàng
Then: UI chỉ hàng đó nhận tương tác (không chọn 2 hàng cùng lúc); mỗi row hit-area ≥48 (spec: row cao 57),
semantic label = nghĩa của row. Đúng/sai: SC-…-26/27. Relearn dùng cùng layout 3-hàng (xem SC-…-06 + Open q).
> Bổ sung ánh xạ 1-1 cho node id-less: 3 row = 3 target độc lập.

### SC-STUDYSESSION-43 — `study-session/card` (thẻ nội dung có `id`)
Nguồn: spec `study-session/card` (id, ở stage1-review + due-review) · D-011 (một chiều)
Then: node `card` là vùng hiển thị term + nghĩa (không phải nút) — assert: render term (`cards.term`) + nghĩa
(`card_meanings.content`) + divider; ở due-review card cao 220, ở stage1 cao ≥320 (grow). KHÔNG có tương tác
bấm trên chính `card` (các nút nằm ngoài card). Nội dung theo chiều hiển thị hiện hành nhưng đọc/ghi **cùng một**
`srs_state` (SC-…-98). Không assert giá trị mock "학교"/"school".

---

## 3. Điều hướng vào/ra

### SC-STUDYSESSION-50 — Vào từ menu Play (Học · newLearn)
Nguồn: navigation-flow `study` `/study/:nodeId` entry=newLearn · study-flow UC-2 · D-002
Given: deck có thẻ mới
When: deck-detail → Play → "Học"
Then: push `study` với `entry=newLearn`; vào chặng 1 (SC-…-01).

### SC-STUDYSESSION-51 — Vào từ menu Play (Lặp lại · dueReview)
Nguồn: navigation-flow entry=dueReview · study-flow UC-3 · D-001/D-016
Given: deck có due>0
When: deck-detail → Play → "Lặp lại N từ"
Then: push `study` với `entry=dueReview`; vào due-review (SC-…-07). Mục "Lặp lại" chỉ hiện khi due>0 (D-016).

### SC-STUDYSESSION-52 — Vào tại node cha (gộp đệ quy subtree)
Nguồn: D-009 / BR-6 · schema `decks.parent_id` cascade
Given: deck cha có deck con chứa thẻ mới/due
When: Play tại deck cha → Học/Lặp lại
Then: hàng đợi gộp **đệ quy** thẻ của mọi deck con (không chỉ deck cha). DB đọc: subtree qua `decks.parent_id`.

### SC-STUDYSESSION-53 — Ra: hoàn tất phiên → study-result
Nguồn: study-flow UC-2/UC-3 (có màn result) · D-029
When: hoàn thành mọi thẻ trong phiên
Then: UI push sang `study-result` (màn kết quả). ⚠ study-result là màn riêng — kịch bản chi tiết ("Tiếp tục"
chạy lại đúng entry) ở file scenario `study-result`; ở đây chỉ assert transition xảy ra.

### SC-STUDYSESSION-54 — Ra: back hệ thống giữa phiên
Nguồn: D-017 · contract[exit]
When: nhấn back OS khi đang chặng dở
Then: UI mở overlay `exit` (chặn thoát trực tiếp), giống `close` (SC-…-08). ⚠ Xác nhận back trong dueReview.

### SC-STUDYSESSION-55 — Ra: exit-ok về đúng nơi gọi
Nguồn: navigation-flow (push) · SC-…-36
When: Leave từ dialog
Then: pop về màn trước (deck-detail của node), không về tab gốc sai.

### SC-STUDYSESSION-56 — Không giữ state khi quay lại (phiên là push tạm)
Nguồn: navigation-flow (study = push, không phải tab shell)
When: rời phiên rồi mở lại
Then: ⚠ Xác nhận: mở lại là phiên MỚI hay resume phiên cũ (liên quan resume-error SC-…-09)? Cơ chế persist tiến độ
phiên chưa có bảng schema ⇒ Open questions.

### SC-STUDYSESSION-57 — DueReview: kết thúc một mode → mời "học lại" đúng mode vừa chạy (in-session)
Nguồn: study-flow UC-3 ("kết thúc một hình thức thì mời học lại đúng hình thức đó") · D-029 (chốt mode →
hiện "học lại" đúng mode vừa chạy; DueReview không có UI riêng ⇒ tái dùng màn chặng)
Given: `entry=dueReview`; phiên đang chạy một hình thức (một màn chặng tái dùng, ví dụ Nhớ lại/Đoán) cho các thẻ due
When: người học **kết thúc hết** các thẻ của hình thức đang chạy trong lượt DueReview (chưa hết toàn phiên)
Then:
- UI: hiện lời mời "học lại" **đúng hình thức vừa chạy** (không nhảy sang hình thức khác, không có UI DueReview
  riêng — tái dùng chính màn chặng đó · study-flow UC-3 / D-029). Đây là **nhánh trong-phiên** của D-029,
  tách khỏi nhánh "study-result → Tiếp tục" (SC-…-53, file `study-result`).
- DB: bản thân lời mời không ghi gì; chấm từng thẻ trong mode vẫn theo SC-…-91/92.
- ⚠ Cơ chế chọn "mode vừa chạy" khi DueReview tái dùng nhiều màn chặng (nếu một lượt due gồm >1 hình thức) —
  thứ tự/việc lặp lại đúng hình thức nào — DOM spec không mock trạng thái "mời học lại" ⇒ Open questions (#16).

---

## 4. Nhập liệu & validation — field typing (stage5) + field check

### SC-STUDYSESSION-60 — Field rỗng → Check
Nguồn: spec stage5 field · game-modes "Điền"
When: field rỗng, chạm "Check"
Then: ⚠ Xác nhận: chặn (nút disabled?) hay coi như sai? spec không định nghĩa disabled-state cho `check` ⇒ Open questions.
Assert tối thiểu: không crash.

### SC-STUDYSESSION-61 — Chỉ khoảng trắng → Check
Nguồn: spec stage5 · schema `cards.term` (trimmed)
When: field chỉ chứa spaces, chạm "Check"
Then: sau trim = rỗng ⇒ xử lý như SC-…-60 (⚠ cùng câu hỏi mở). So khớp phải trim trước khi so với `cards.term`.

### SC-STUDYSESSION-62 — Nhập đúng có dung sai (case/space)
Nguồn: game-modes "Điền" ("chấp nhận dung sai")
When: nhập term khác hoa/thường hoặc thừa/thiếu khoảng trắng biên, chạm "Check"
Then: chấp nhận đúng (dung sai). ⚠ Mức dung sai cụ thể (bỏ dấu? khoảng cách Levenshtein?) không có trong spec ⇒ Open questions.

### SC-STUDYSESSION-63 — Nhập sai hoàn toàn
Nguồn: spec stage5 · D-015
When: nhập chuỗi khác term, Check
Then: báo sai → relearn (SC-…-06). DB: không ghi.

### SC-STUDYSESSION-64 — Nhập CJK (Hàn/Nhật) đúng term
Nguồn: CHECKLIST §4 CJK · term MOCK "학교" là Hàn
When: term là chữ Hàn/Nhật, nhập đúng glyph CJK
Then: field render đúng CJK (không tofu); Check khớp `cards.term` (so sánh Unicode chuẩn hoá).
> ⚠ Nguồn so khớp: stage5 là "nghĩa → term" (game-modes "Điền"), Check so với `cards.term`. Nhưng một thẻ có
> thể có **nhiều** `card_meanings` (schema) — nghĩa nào được hiển thị làm prompt, và term có biến thể nào được
> chấp nhận khi thẻ nhiều nghĩa/nhiều dạng — DOM spec chỉ mock 1 nghĩa "school" ⇒ Open questions (#17).

### SC-STUDYSESSION-65 — Nhập rất dài (biên)
Nguồn: CHECKLIST §4 quá dài
When: dán chuỗi rất dài vào field
Then: field không vỡ layout (cuộn/ellipsis nội bộ); Check vẫn so khớp (khác term ⇒ sai). Không crash/tràn.

### SC-STUDYSESSION-66 — Ký tự đặc biệt/emoji
Nguồn: CHECKLIST §4 emoji/đặc biệt
When: nhập emoji/ký tự đặc biệt rồi Check
Then: coi như không khớp term (trừ khi term chứa đúng vậy) ⇒ sai; không crash.

### SC-STUDYSESSION-67 — Trim đầu/cuối trước so khớp
Nguồn: schema `cards.term` "trimmed non-empty"
When: nhập " <term> " (term đúng, có space biên), Check
Then: sau trim khớp ⇒ đúng (nhất quán với SC-…-62).

> Ghi chú: màn này KHÔNG có validation "trùng/soft-dup" (D-020 thuộc màn tạo/nhập thẻ, không thuộc study-session)
> ⇒ chiều "trùng" của CHECKLIST §4 là **N/A** ở đây (nêu để không sót).

---

## 5. Lượng dữ liệu

### SC-STUDYSESSION-70 — 0 thẻ mới (newLearn)
Nguồn: study-flow UC-2 tiền điều kiện · D-018
When: mở Học tại node không còn thẻ mới trong ngày
Then: ⚠ Xác nhận: study-session không mở (menu ẩn "Học"?) hay mở rồi báo trống? spec không có state "empty" ⇒ Open questions.

### SC-STUDYSESSION-71 — 1 thẻ (newLearn)
Nguồn: study-flow · D-002
When: node có đúng 1 thẻ mới
Then: phiên đi qua 5 chặng cho 1 thẻ → chốt → thẻ vào ô 1. DB: 1 `srs_state` box=1.

### SC-STUDYSESSION-72 — Nhiều thẻ + cap 20/ngày (newLearn)
Nguồn: srs-review BR-7 / D-018 · settings `srs.new_cards_per_day`=20
Given: node có >20 thẻ mới, `settings[srs.new_cards_per_day]`=20
When: dựng phiên Học
Then: hàng đợi chỉ nạp **tối đa 20** thẻ mới. DB đọc `settings`; các thẻ dư vẫn box 0.

### SC-STUDYSESSION-73 — Cap tùy chỉnh khác 20
Nguồn: settings `srs.new_cards_per_day` (cấu hình) · D-018
Given: đổi cap = 5
When: dựng phiên Học tại node >5 thẻ mới
Then: hàng đợi nạp tối đa 5. (Assert đọc từ `settings`, không hardcode 20.)

### SC-STUDYSESSION-74 — Nhiều thẻ due (dueReview)
Nguồn: D-001 · srs-review UC-2
Given: nhiều thẻ `due` (badge=N)
When: mở Lặp lại
Then: phiên duyệt lần lượt N thẻ due; `progress` phản ánh N; chốt sau thẻ cuối.

### SC-STUDYSESSION-75 — Loại thẻ ẩn khỏi hàng đợi
Nguồn: D-006 / BR-8 · schema `cards.hidden`
Given: node có thẻ due + thẻ `hidden=1`
When: dựng phiên Lặp lại/Học
Then: thẻ `hidden=1` KHÔNG xuất hiện trong phiên (loại khỏi cả due queue lẫn new queue). DB đọc: lọc `hidden=0`.

---

## 6. Async & lỗi

### SC-STUDYSESSION-80 — Dựng hàng đợi (loading) → nội dung
Nguồn: CHECKLIST §6 loading · study-flow NFR (<100ms)
When: mở phiên
Then: UI hiện trạng thái chờ ngắn (nếu có) rồi chặng 1 / thẻ due đầu. ⚠ spec KHÔNG có state loading riêng cho
study-session ⇒ nếu build có skeleton phải chốt; hiện liệt kê Open questions.

### SC-STUDYSESSION-81 — Lưu kết quả thất bại → answer-save-error
Nguồn: contract[answer-save-error] · SC-…-10
When: ghi `srs_state`/`review_logs` lỗi sau khi chấm
Then: hiện dialog save-error (SC-…-10). DB: không commit dòng lỗi.

### SC-STUDYSESSION-82 — Retry lưu thành công
Nguồn: SC-…-39
When: từ save-error chạm Retry, lần này ghi thành công
Then: đóng dialog, tiếp phiên; DB có đúng 1 `review_logs` (không nhân đôi) + `srs_state` đúng ô.

### SC-STUDYSESSION-83 — Khôi phục phiên thất bại → resume-error
Nguồn: contract[resume-error] · SC-…-09
When: resume phiên dở nhưng thất bại
Then: hiện resume-error; Restart hoặc Back. DB: không ghi.

### SC-STUDYSESSION-84 — Local-first (không mạng)
Nguồn: CLAUDE.md §4 local-first · schema local-only
When: tắt mạng, chạy cả newLearn lẫn dueReview
Then: phiên chạy đầy đủ, chấm + ghi `srs_state`/`review_logs`/`study_sessions` bình thường (không phụ thuộc mạng).

### SC-STUDYSESSION-85 — Hủy giữa chừng khi đang lưu
Nguồn: CHECKLIST §6 hủy giữa chừng · D-017
When: bấm close/back ngay lúc đang ghi kết quả một thẻ
Then: ⚠ Xác nhận: chờ ghi xong rồi mở exit, hay hủy ghi? Không được để `srs_state` ghi dở/không nhất quán. Open questions.

---

## 7. Persistence (DB round-trip)

### SC-STUDYSESSION-90 — newLearn hoàn tất → thẻ vào ô 1 (D-002)
Nguồn: D-002 / BR-3(study) / srs-review BR-2 · schema `srs_state` + `review_logs`
Given: thẻ Mới (box 0, không có `srs_state`)
When: hoàn thành đủ **5 chặng** cho thẻ
Then:
- UI: thẻ rời phiên (hoặc phiên chốt nếu là thẻ cuối) → study-result.
- DB (`srs_state`): `srs_state[card]` (khoá `card_id`, **không** có cột `direction` — schema: 1 dòng/thẻ,
  một chiều): box=1, `due_at`=now+interval(ô 1)=now+1 ngày, `last_reviewed_at`=now.
- DB (`review_logs`) — **negative assertion**: NewLearn **KHÔNG** ghi `review_logs`. Schema `review_logs`:
  "A row is written on **every DueReview grade** (`GradeCard`)" — chỉ DueReview, không phải NewLearn. Vậy lượt
  NewLearn graduate 1 thẻ tạo/ghi `srs_state` nhưng **không** thêm dòng `review_logs`.
- DB (`study_sessions`/`daily_activity`): chỉ ghi khi **chốt phiên** (SC-…-94), không phải mỗi thẻ.

### SC-STUDYSESSION-91 — dueReview chấm đúng → chuyển ô + log (D-003)
Nguồn: D-003 · srs-review BR-3 · schema `srs_state` + `review_logs`
Given: thẻ ở ô k (1≤k<8), due
When: chạm `due-next` (Đúng)
Then: DB: `srs_state.box`=k+1; `due_at`=now+interval(k+1); `last_reviewed_at`=now;
`review_logs` +1: `grade='pass'`, `card_id`=thẻ, `reviewed_at`=now (== `last_reviewed_at`).

### SC-STUDYSESSION-92 — dueReview chấm sai → lùi ô + log (D-004)
Nguồn: D-004 · srs-review BR-4
Given: thẻ ở ô k (k>1), due
When: chạm `due-relearn` (Sai)
Then: DB: `box`=k−1; `review_logs` +1 `grade='fail'`, `reviewed_at`=now (== `last_reviewed_at`).
Biên: k=1 sai → giữ ô 1 (sàn, D-004); `review_logs` vẫn +1 `fail`.
> ⚠ `due_at` khi **sai**: BR-4 chỉ nói "lùi 1 ô (sàn ô 1)", KHÔNG quy định `due_at` tính lại thế nào. Giả định
> `due_at`=now+interval(ô mới k−1) là **suy diễn** (nhất quán với scheduler "stamp `due_at`=now+interval"),
> nhưng có thể fail đặt `due_at`=now/ngày mai để ôn lại sớm ⇒ chưa có nguồn minh thị · Open questions (#19).

### SC-STUDYSESSION-93 — Ô 8 chấm đúng → giữ ô 8 (D-005)
Nguồn: D-005 · srs-review BR-3/BR-5
Given: thẻ ở ô 8, due (⚠ ô 8 `due_at`=NULL theo BR-5 ⇒ khi nào ô 8 lại "due"? — Open questions)
When: chấm Đúng
Then: DB: box giữ 8; `due_at`=NULL (rời lịch); `review_logs` +1 `pass`.

### SC-STUDYSESSION-94 — Chốt phiên đếm → study_sessions + daily_activity (D-010)
Nguồn: D-010 / BR-5(study) · **schema-contract** `study_sessions` + `daily_activity` (tên cột lấy verbatim từ schema)
Given: phiên `entry`=newLearn HOẶC dueReview hoàn tất
When: chốt phiên
Then: DB: +1 `study_sessions` với đúng cột schema — `id` · `deck_id`=node (FK `decks.id`, phủ subtree BR-6) ·
`mode` (`StudyMode`) ∈ {`new_learn`,`due_review`} · `started_at` (µs) · `duration_minutes` (INTEGER) ·
`words_studied` (INTEGER, số thẻ distinct); `daily_activity[day]` (khoá `day` = nửa đêm local): `minutes`+=,
`words`+= (roll-up theo `started_at` ngày local · index `idx_sessions_started`).
> ⚠ **Mâu thuẫn đơn vị nguồn** (không tự chọn): schema-contract định nghĩa cột là **phút** (`study_sessions.
> duration_minutes`, `daily_activity.minutes`), nhưng bảng quyết định **D-010** ghi "`DailyActivity` cộng
> **giây** + số từ". Assertion ở đây bám **tên cột schema** (phút) vì đó là hợp đồng DB round-trip; nhưng
> đơn vị chuẩn (giây theo D-010 vs phút theo schema) phải chốt trước khi viết test ⇒ Open questions (#18).

### SC-STUDYSESSION-95 — Practice KHÔNG ghi (D-007) — kiểm negative
Nguồn: D-007 · study-flow BR-5 · game-modes BR-4
Given: một hoạt động luyện (Xem lại/Trò chơi/Trình phát) — **không** phải study-session newLearn/dueReview
When: kết thúc
Then: DB: `srs_state` KHÔNG đổi; KHÔNG có `review_logs`, `study_sessions`, `daily_activity` mới.
> Đây là contract "no-write"; study-session chỉ áp cho newLearn/dueReview.

### SC-STUDYSESSION-96 — Thoát giữa chừng KHÔNG ghi srs (D-017) — negative
Nguồn: D-017 · schema `srs_state`
Given: newLearn, thẻ mới chưa qua đủ 5 chặng
When: exit-ok "Leave"
Then: DB: KHÔNG tạo `srs_state` cho thẻ chưa graduate (vẫn box 0/Mới); không `study_sessions`/`daily_activity`.

### SC-STUDYSESSION-97 — Kill & mở lại app (round-trip)
Nguồn: CHECKLIST §7 kill-relaunch · schema bền vững
Given: chấm xong ≥1 thẻ due (ghi `srs_state`/`review_logs`) rồi kill app
When: mở lại
Then: DB giữ nguyên `srs_state.box`/`due_at`/`last_reviewed_at` + `review_logs`; mở lại Lặp lại: thẻ đã chuyển ô
không còn due (nếu chưa tới hạn). ⚠ Phiên đang dở (chưa chốt) khi kill → resume hay mất? (liên resume-error). Open questions.

### SC-STUDYSESSION-98 — Đảo chiều hiển thị (KO↔VI) dùng CHUNG một `srs_state` (D-011/BR-6)
Nguồn: **D-011** / srs-review BR-6 · schema `srs_state` ("one row per card, single-direction · pair defines
display direction but the schedule is one shared `srs_state`, not per-direction" · PK = `card_id`, **không** có
cột `direction`)
Given: một thẻ đã có `srs_state` (ví dụ box k); người học học/ôn thẻ ở **chiều đảo** (nghĩa→term thay vì term→nghĩa)
When: chấm thẻ ở chiều đảo trong một lượt DueReview (hoặc học lại)
Then:
- DB: đọc **và** ghi vào **đúng một** dòng `srs_state` khoá theo `card_id` (không tạo dòng thứ 2 cho chiều đảo,
  không có khoá phụ `direction`). Chuyển ô/`due_at`/`last_reviewed_at` áp lên chính dòng đó (D-003/D-004).
- UI: chiều hiển thị chỉ đổi prompt (term↔nghĩa) — **không** tạo lịch riêng; % tiến độ và box phản ánh cùng
  một trạng thái. (Bản chất D-011 — một chiều lịch duy nhất; đây là scenario khẳng định riêng cho D-011, tách
  khỏi edge concurrency SC-…-125.)
- ⚠ Cách app **chọn** chiều hiển thị cho một lượt (cố định theo cặp deck? người dùng chọn?) không thuộc màn này
  (thuộc cấu hình học/deck) — nêu để không lẫn; SC này chỉ khẳng định **một** `srs_state` dùng chung.

---

## 8. Định dạng & i18n

### SC-STUDYSESSION-100 — % tiến độ theo locale
Nguồn: spec `progress` · CHECKLIST §8
When: đổi locale (vi/en/ja)
Then: nhãn % định dạng theo locale (dấu %/khoảng cách), text không tràn appbar. Không assert giá trị mock "16%".

### SC-STUDYSESSION-101 — Term/nghĩa CJK render đúng
Nguồn: spec (term mock "학교", nghĩa "school") · CHECKLIST §8 CJK
When: thẻ có term Hàn/Nhật + nghĩa CJK
Then: card render đúng glyph (không tofu), căn giữa; font lớn không cắt chữ.

### SC-STUDYSESSION-102 — Nghĩa/term rất dài → wrap/ellipsis
Nguồn: CHECKLIST §8 text dài
When: term hoặc nghĩa rất dài
Then: card wrap/thu nhỏ hợp lý, không tràn khỏi card/màn; nút bên dưới vẫn thấy.

### SC-STUDYSESSION-103 — Nhãn nút/tiêu đề từ ARB theo locale
Nguồn: contract (mọi chuỗi ARB) · CHECKLIST §8
When: đổi locale
Then: "Next/Show/Check/Help/Stay/Leave/Relearn/Retry/Back…" + tiêu đề chặng + banner + dialog đều đổi theo ARB
(không copy mock kit). CJK/text dài trên nút không vỡ layout.

### SC-STUDYSESSION-104 — Số lựa chọn/plural (nếu có "N từ")
Nguồn: study-flow UC-3 nhãn "Lặp lại N từ" (điểm vào) · CHECKLIST §8 plural
Then: nếu study-session hiển thị số thẻ còn lại/plural, dùng ARB plural (1 vs N). ⚠ Xác nhận study-session có hiển
thị count không (spec chỉ có %). Open questions.

### SC-STUDYSESSION-105 — RTL
Nguồn: CHECKLIST §8 RTL
Then: **N/A** — v1 chỉ hỗ trợ locale không-RTL (vi/en/ja/ko); nêu để không sót. Xác nhận nếu thêm RTL sau.

---

## 9. Dark mode

### SC-STUDYSESSION-110 — Mọi state ở dark
Nguồn: CHECKLIST §9 · contract 10 state · spec token (`--memox-*`)
Then: cả 10 state render đúng ở light + dark bằng token (không hardcode màu):
card `surface`, primary button `primary`/on-`surface`, banner `warning-soft`/`on-warning-soft`,
error-soft/on-error-soft (resume/save-error), scrim `overlay`. Contrast term/nghĩa đạt ở dark.

---

## 10. Responsive

### SC-STUDYSESSION-111 — 320px → tablet + xoay
Nguồn: CHECKLIST §10 · spec (phone 390 base)
Then: ở 320px không overflow (card, lưới ghép đôi 2 cột, hàng 2 nút hint/check, dialog maxw:320 vẫn vừa);
xoay ngang: card + bàn phím (stage5) không che field, nội dung cuộn được; safe-area/notch OK; tablet căn giữa hợp lý.

---

## 11. A11y

### SC-STUDYSESSION-112 — Semantics + hit-area + thứ tự đọc
Nguồn: CHECKLIST §11 · spec (icon-button 48x48, nút minh:48/56)
Then: `close`/`options`/`next`/`reveal`/`check`/`hint`/chip/đáp án/nút dialog đều có semantic label (từ ARB);
hit-area ≥48 (spec: icon-button 48x48, nút 48/56); thứ tự đọc: tiêu đề chặng → nội dung thẻ → nút hành động;
% tiến độ đọc thành câu có nghĩa (không đọc rời "16"); dialog exit/error trap focus + đọc tiêu đề trước nút;
field typing có label rõ (không chỉ placeholder).

---

## 12. Concurrency & edge thời gian

### SC-STUDYSESSION-120 — Double-tap nút hành động
Nguồn: CHECKLIST §12 · D-003/D-004 (một lần chấm)
When: chạm nhanh 2 lần `due-next` / `check` / `next`
Then: chỉ tiến **một** thẻ / ghi **một** `review_logs` (không chuyển ô 2 lần, không nhân đôi log).
(Nút chọn đáp án chip/hàng/reveal: xem SC-…-126.)

### SC-STUDYSESSION-121 — Double-tap close (không mở 2 dialog)
Nguồn: CHECKLIST §12 · contract[exit]
When: chạm nhanh 2 lần `close`
Then: mở đúng **một** overlay exit (không chồng 2 scrim).

### SC-STUDYSESSION-122 — Back khi đang mở dialog exit
Nguồn: CHECKLIST §12
When: đang ở overlay exit, nhấn back OS
Then: ⚠ Xác nhận: back đóng dialog (= Stay) hay = Leave? Không được rời màn mà bỏ qua cảnh báo D-017. Open questions.

### SC-STUDYSESSION-123 — Đổi ngày lúc nửa đêm khi đang học
Nguồn: D-021 (chốt ngày) · D-010 · engagement (tính từ lịch sử)
Given: đang trong phiên đếm lúc 23:59, đồng hồ qua 00:00 rồi mới chốt phiên
When: chốt phiên sau nửa đêm
Then: `daily_activity` cộng vào ngày của `study_sessions.started_at` (ngày bắt đầu) — assert bucket theo `started_at`
(schema: "its calendar day is the daily_activity bucket"). ⚠ Nếu phiên vắt qua nửa đêm, gán trọn cho ngày bắt đầu?
Open questions (không bịa chia đôi).

### SC-STUDYSESSION-124 — Chấm rồi lỗi lưu rồi retry nhanh (không nhân đôi)
Nguồn: SC-…-82 · CHECKLIST §12
When: chấm → save-error → retry nhiều lần nhanh
Then: DB cuối cùng có đúng 1 `review_logs` + `srs_state` một lần chuyển ô (idempotent theo thẻ trong lượt).

### SC-STUDYSESSION-125 — Cùng thẻ due mở ở 2 lối vào (đồng thời hiếm)
Nguồn: CHECKLIST §12 · D-011 (một `srs_state`/thẻ)
When: (edge) thẻ due được chấm ở phiên này trong khi trạng thái cũ còn cache nơi khác
Then: `srs_state` là 1 dòng/thẻ (D-011); lần ghi sau phản ánh ô mới, không tạo 2 dòng. ⚠ App v1 có mở 2 phiên song song
không? (điều hướng push đơn) — nếu không, đánh dấu N/A. Open questions.

### SC-STUDYSESSION-126 — Double-tap chip / hàng lựa chọn / reveal (chống chọn 2 đáp án)
Nguồn: CHECKLIST §12 · spec stage2 chip / stage3 row / stage4 `reveal` · game-modes (một lượt 1 đáp án)
When: chạm nhanh 2 lần một chip ghép đôi (stage2) · hoặc 2 hàng lựa chọn (stage3) gần như đồng thời · hoặc
double-tap `reveal` (stage4)
Then:
- Chip/hàng lựa chọn: chỉ **một** lựa chọn được ghi nhận cho lượt đó (không chấm 2 đáp án cùng lúc, không tính
  đúng+sai chồng nhau); double-tap cùng một target không kích hoạt 2 lần chuyển chặng.
- `reveal`: lộ nội dung **một** lần (không mở/đóng chớp nháy, không double-advance).
- Không có ghi DB ở các chặng luyện (SC-…-02..05), nên chỉ assert UI-state ổn định (bổ trợ SC-…-120 vốn chỉ
  phủ `due-next`/`check`/`next`).

---

## Open questions (⚠ cần chốt spec trước khi viết test — KHÔNG bịa)

1. **stage3 số lựa chọn**: mock=3 hàng — N cố định 3 hay theo cấu hình? nguồn các "distractor" (nghĩa nhiễu)?
2. **stage4 recall thiếu control tự chấm**: DOM spec stage4 chỉ có nút "Show"; game-modes yêu cầu "Đã quên/Nhớ được"
   sau khi lộ — thiếu 2 nút này trong kit ⇒ kit thiếu hay flow khác? (không đoán).
3. **stage2/stage3/stage5 phản hồi SAI**: hình thức báo sai (đổi màu/rung/toast) không có trong spec.
4. **`options` (more_horiz)**: menu chứa gì? (kết thúc phiên / báo lỗi thẻ / tắt âm?) — chưa có D-xxx/business.
5. **`close`/back trong dueReview vs newLearn "sạch"**: có mở dialog exit không, hay thoát thẳng khi chưa chấm thẻ nào?
6. **`hint` (Help)**: gợi ý lộ gì (1 ký tự / độ dài / term)?
7. **Điền — mức "dung sai"**: bỏ dấu? case-insensitive? khoảng cách chỉnh sửa? — game-modes nói "chấp nhận dung sai"
   nhưng không định lượng.
8. **Field rỗng → Check**: nút disabled hay coi là sai? (không có disabled-state trong spec).
9. **State loading**: study-session không có state loading/empty trong contract — khi dựng hàng đợi chậm / 0 thẻ mới
   hiển thị gì?
10. **Persist tiến độ phiên (resume)**: resume-error ngụ ý có lưu phiên dở, nhưng schema-contract KHÔNG có bảng
    session-progress. Cơ chế lưu/khôi phục là gì? Kill giữa phiên → resume hay mất?
11. **Ô 8 "due"**: BR-5 nói box 8 `due_at`=NULL (rời lịch) ⇒ thẻ ô 8 không bao giờ due; vậy D-005 ("ô 8 chấm đúng
    giữ 8") kích hoạt qua lối nào trong study-session?
12. **Hủy giữa chừng khi đang ghi**: close/back đúng lúc commit — chờ xong hay hủy? tránh `srs_state` dở.
13. **Nửa đêm vắt phiên**: phiên bắt đầu 23:59 chốt sau 00:00 — gán trọn `daily_activity` cho ngày `started_at`?
14. **study-result → "Tiếp tục" (D-029, nhánh sau-phiên)**: chạy lại đúng entry vừa chạy — chi tiết ở file
    scenario `study-result`. Nhánh **trong-phiên** của D-029 ("kết thúc một mode DueReview → mời học lại đúng
    mode") đã phủ ở SC-…-57 (câu hỏi mở còn lại: #16).
15. **Đa phiên song song**: v1 có cho mở 2 phiên học đồng thời không? (ảnh hưởng SC-…-125).
16. **DueReview chọn "mode vừa chạy" (D-029 trong-phiên · SC-…-57)**: khi DueReview tái dùng nhiều màn chặng,
    "học lại đúng hình thức vừa chạy" chọn mode nào và lặp ra sao? DOM spec không mock trạng thái "mời học lại".
17. **stage5 chọn nghĩa/term khi thẻ nhiều nghĩa (SC-…-64)**: thẻ có >1 `card_meanings` — nghĩa nào làm prompt,
    term nào (biến thể) được chấp nhận khi Check? spec chỉ mock 1 nghĩa.
18. **Đơn vị đếm hoạt động (D-010 vs schema · SC-…-94)**: bảng quyết định D-010 ghi cộng **giây**, nhưng
    schema-contract cột là **phút** (`duration_minutes`/`minutes`). Chốt đơn vị chuẩn trước khi viết test.
19. **`due_at` khi chấm Sai (SC-…-33/92)**: BR-4 chỉ nói lùi 1 ô; không quy định `due_at`. now+interval(ô mới)
    là suy diễn — hay fail đặt `due_at`=now/ngày mai để ôn lại sớm?
20. **Relearn giữ dạng chặng vừa sai hay luôn Multiple choice (SC-…-06)**: sai có thể ở chặng 2/3/4/5 nhưng kit
    chỉ mock relearn dạng Multiple choice — relearn dùng đúng dạng vừa sai hay luôn quy về choice?
21. **Mô hình tiến trình per-card vs per-stage-batch (SC-…-23/24 và 01..05/71)**: DOM spec là các state độc
    lập, không có transition; study-flow liệt kê 5 chặng ở **cấp phiên**. Mỗi thẻ đi riêng qua 5 chặng, hay cả
    hàng đợi tiến theo từng chặng (batch)? Ảnh hưởng thời điểm graduate 1 thẻ (SC-…-31/90) vs chốt phiên.

> Các mục ⚠ là **danh sách phải hỏi BA/spec**, không được đoán. Có câu trả lời → cập nhật scenario tương ứng +
> xoá cờ ⚠. Đây chính là "không bỏ sót": phần chưa rõ được **liệt kê ra**, không lờ đi.
