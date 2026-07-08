# Kịch bản — Multiple Choice (Đoán) · screen `game-mc`

Nguồn: `docs/contracts/game-mc.md` [waiting · correct · wrong · complete] ·
DOM `specs/game-mc.md` · D-008, D-013, D-015, D-007, D-011 (chiều hiển thị/SrsState một chiều), D-009 (gộp đệ quy
thẻ bộ-cha) (D-006 gián tiếp khi dựng tập thẻ) ·
BR `business/game/game-modes.md` (BR-1..BR-5) + `business/study/study-flow.md` (BR-4/BR-5/BR-6/BR-7) ·
DB `cards`, `card_meanings`, `srs_state`, `review_logs`, `study_sessions`, `daily_activity`, `settings`.

> Screen `game-mc` = trò chơi **"Đoán"** (hiện 1 term, chọn nghĩa đúng trong N lựa chọn — game-modes §6),
> mở qua route `gamePlay` (`/game/:nodeId/play`, type=mc) từ picker `game` (D-013). Đây là **luyện tập thuần**:
> KHÔNG đổi `srs_state`, KHÔNG ghi `review_logs`/`study_sessions`, KHÔNG cộng `daily_activity` (D-007, BR-4).
>
> Số/chuỗi trong kit là MOCK ("학교", "school/hospital/park/restaurant", "5/5", "Round complete!", "Next round") —
> assert **định dạng & nguồn** (term/nghĩa từ DB, tiến độ theo cấu hình), KHÔNG assert giá trị mock. Chuỗi UI
> lấy từ ARB, không copy kit.

## DoE — game-mc (12 chiều)

| # | Chiều | TT | Scenario / N/A |
|---|---|---|---|
| 1 | States (4) | ✅ | SC-GAMEMC-01..04 |
| 2 | Elements (9 tương tác/hiển thị) | ✅ | SC-GAMEMC-10..21 |
| 3 | Nav vào/ra | ✅ | SC-GAMEMC-30..35 (scope bộ-cha đệ quy: SC-GAMEMC-45, BR-5×D-009) |
| 4 | Nhập liệu & validation | **N/A** | game-mc không có field nhập text (chọn đáp án bằng tap; term/nghĩa đọc từ DB, đã validate ở editor D-020). Biến thể nội dung (CJK/dài/emoji trong term & lựa chọn) phủ ở mục 8. |
| 5 | Lượng dữ liệu | ✅ | SC-GAMEMC-40..45 (SC-45 = scope bộ-cha-có-con → gộp đệ quy D-009/BR-6) |
| 6 | Async & lỗi | ✅ | SC-GAMEMC-50..53 |
| 7 | Persistence (DB round-trip) | ✅ | SC-GAMEMC-60..63 |
| 8 | Định dạng & i18n | ✅ | SC-GAMEMC-70..74 |
| 9 | Dark mode | ✅ | SC-GAMEMC-80 |
| 10 | Responsive | ✅ | SC-GAMEMC-81 |
| 11 | A11y | ✅ | SC-GAMEMC-82 |
| 12 | Concurrency & edge thời gian | ✅ | SC-GAMEMC-90..94 (SC-94 = race feedback→advance, phụ thuộc Open-q #14) |

Element inventory (từ DOM spec — mỗi cái ≥1 scenario ở mục 2):
`back` (icon-button arrow_back, `game-mc/back`) · `options` (icon-button more_horiz, `game-mc/options`) ·
`appbar__title` ("Multiple choice") · `progress` (thanh tiến độ `game-mc/progress`) · `prompt` card
(`game-mc/prompt` chứa term) · `audio` (icon-button volume_up, `game-mc/audio`) · `edit` (icon-button edit,
`game-mc/edit`) · `choice-0..3` (4 ô đáp án `game-mc/choice-N`) · `next` (btn "Next round" `game-mc/next`, chỉ ở
state complete).

---

## 1. States (mỗi state ≥1 scenario dẫn tới)

### SC-GAMEMC-01 — waiting (base: chờ người học chọn đáp án)
Nguồn: contract[waiting] · spec base · D-008 · D-011 (chiều hiển thị KO↔VI dùng CÙNG một SrsState một chiều)
Given (DB): `settings`(`game_words_per_round`=5), deck có ≥5 thẻ visible (`cards.hidden`=0) mỗi thẻ có ≥1
`card_meanings`; đã vào ván qua picker (type=mc).
When (UI): ván hiển thị thẻ đầu.
Then (UI): app bar (back + title "Multiple choice" + options) · thanh `progress` (một phần) · card `prompt`
hiện **term của thẻ hiện tại** (nguồn = `cards.term`) + `audio` + `edit` · **4 ô** `choice-0..3` viền `divider`,
nền `surface`, chưa ô nào đánh dấu đúng/sai · KHÔNG có icon check_circle/cancel.
Then (DB): KHÔNG ghi gì (chưa chấm).
⚠ Xác nhận (D-011): term hiển thị là learning-side hay meaning-side? (game-modes: Đoán = "hiện term, chọn nghĩa" ⇒
prompt = `term`, 4 ô = `content` nghĩa; cần chốt chiều hiển thị khi cặp đảo KO↔VI. D-011: đảo chiều KO↔VI dùng CÙNG
một `SrsState` một chiều — nhưng chiều **hiển thị** của game (prompt=term/4 ô=nghĩa) chưa được nguồn chốt → Open-q #1).

### SC-GAMEMC-02 — correct (chọn đúng)
Nguồn: contract[correct] · spec "correct" diff · D-015 (nhánh đúng)
Given: đang ở `waiting`, một ô là đáp án đúng (nghĩa khớp `card_meanings.content` của thẻ prompt).
When: chạm ô đúng.
Then (UI): ô đó chuyển nền `success-soft`, viền `2px success`, chữ `on-success-soft`, hiện icon `check_circle`
màu `success` bên phải; các ô khác giữ nguyên. Sau phản hồi → chuyển thẻ kế (progress tăng).
Then (DB): KHÔNG đổi `srs_state`, KHÔNG thêm `review_logs`/`study_sessions`/`daily_activity` (D-007, BR-4).

### SC-GAMEMC-03 — wrong (chọn sai)
Nguồn: contract[wrong] · spec "wrong" diff · D-015 (nhánh sai)
Given: đang ở `waiting`.
When: chạm một ô **sai**.
Then (UI): ô sai chuyển nền `error-soft`, viền `2px error`, chữ `on-error-soft`, icon `cancel` màu `error`;
đồng thời ô **đúng** được đánh dấu `success` (diff cho thấy choice-0 vẫn thành success + choice-2 thành error).
Thẻ trả lời sai được **đưa lại hàng đợi ván** (D-015/BR-3) → sẽ xuất hiện lại trước khi ván kết thúc.
Then (DB): KHÔNG đổi `srs_state`/`review_logs`/`study_sessions`/`daily_activity` (D-007).
⚠ Xác nhận: sau khi lộ đáp án đúng ở state wrong, người học tự chuyển tiếp bằng tap tiếp hay tự động? (spec chỉ
là diff tĩnh, không mô tả chuyển tiếp).

### SC-GAMEMC-04 — complete (hết thẻ trong ván)
Nguồn: contract[complete] · spec "complete" diff · D-008/D-015
Given: đã trả lời **đúng hết** tất cả thẻ của ván (mỗi thẻ sai bị lặp lại đến khi đúng — D-015).
When: thẻ cuối được chấm đúng.
Then (UI): prompt card + 4 ô **bị gỡ**; thay bằng khối `game-mc/complete`: icon-tile `celebration`
(nền `success-soft`) · tiêu đề "Round complete!" (ARB) · phụ đề dạng "N/M correct" (ARB plural, giá trị từ số
thẻ đúng/tổng của ván — KHÔNG assert "5/5") · nút `game-mc/next` (icon arrow_forward + nhãn "Next round", nền
`primary`). Thanh `progress` = đầy (`bg:primary` toàn chiều).
Then (DB): vẫn KHÔNG ghi gì (D-007).
⚠ Xác nhận: phụ đề "N/M correct" đếm theo lần-đúng-đầu-tiên hay tính cả lần lặp lại do sai? (spec MOCK "5/5"
không định nghĩa công thức).

---

## 2. Elements (mỗi phần tử ≥1 scenario)

### SC-GAMEMC-10 — Nút back (`game-mc/back`)
Nguồn: spec `game-mc/back` (icon-button arrow_back, mx:?)
When: chạm back trong ván.
Then (UI): pop khỏi ván, quay về nơi mở (picker `game` hoặc nút nguồn — xem SC-GAMEMC-31).
Then (DB): KHÔNG ghi gì; thoát giữa ván không tạo bản ghi nào (D-007 — không phải NewLearn nên không áp D-017).
⚠ Xác nhận: back giữa ván có hỏi xác nhận "bỏ ván?" không? (không có dialog trong contract states).

### SC-GAMEMC-11 — Nút options / more_horiz (`game-mc/options`)
Nguồn: spec `game-mc/options` (icon-button more_horiz, mx:?)
When: chạm nút 3-chấm.
Then: ⚠ Xác nhận đích — kit KHÔNG có overlay menu/sheet cho game-mc trong 4 state; hành vi chưa có ở D-xxx/BR.
Assert tối thiểu: nút có semantic label, hit-area ≥48, không crash. (Ghi chú parity: intent-ledger ghi
`game-mc/options` là node tái dùng key MxIconButton 3-chấm mà FE không có — realign hoãn post-v1; đừng bịa menu.)

### SC-GAMEMC-12 — Tiêu đề app bar (`appbar__title`)
Nguồn: spec `appbar__title` text "Multiple choice"
Then: hiển thị nhãn tên game từ ARB (không hardcode "Multiple choice"); đổi locale → đổi chuỗi (SC-GAMEMC-70).

### SC-GAMEMC-13 — Thanh tiến độ (`game-mc/progress`)
Nguồn: spec `game-mc/progress` (track `surface-sunken`, fill `primary`)
Given: ván N thẻ.
Then: fill phản ánh **tiến độ ván** (đã qua / tổng); ở `complete` fill = đầy. ⚠ Xác nhận: tiến độ tính theo
số thẻ đã-đúng hay số lượt đã trả lời (có tính lần lặp lại do sai)? (kit chỉ cho 1 khung; không có công thức).

### SC-GAMEMC-14 — Prompt term (`game-mc/prompt`)
Nguồn: spec `game-mc/prompt` (card `surface` r:20 shadow, chứa div text term "학교") · D-011 (chiều hiển thị)
Then: hiển thị **term thẻ hiện tại** đọc từ `cards.term` (không phải chuỗi kit); font lớn căn giữa; card có
shadow. Đổi thẻ → đổi term theo thẻ kế của ván. ⚠ Chiều hiển thị (term-side vs meaning-side khi cặp đảo KO↔VI)
phụ thuộc D-011/Open-q #1 — D-011 chốt SrsState một chiều, chưa chốt chiều **hiển thị** của game.

### SC-GAMEMC-15 — Nút audio (`game-mc/audio`)
Nguồn: spec `game-mc/audio` (icon-button volume_up, mx:?)
When: chạm loa.
Then: ⚠ Xác nhận — audio TTS/`card.audio_ref` **hoãn v1** (schema: `audio_ref` NULL, TTS live-only DT.7; D-014
ghi "audio hoãn"). Assert tối thiểu: nút render, có semantic label, hit-area ≥48, không crash khi chưa có audio.

### SC-GAMEMC-16 — Nút edit (`game-mc/edit`)
Nguồn: spec `game-mc/edit` (icon-button edit, mx:?)
When: chạm bút chì.
Then: ⚠ Xác nhận đích — sửa thẻ hiện tại giữa ván? (không có trong D-xxx/BR/nav). Assert tối thiểu: nút render,
semantic label, hit-area, không crash. Nếu mở editor thẻ ⇒ round-trip nội dung phải phản ánh (không bịa luồng).

### SC-GAMEMC-17..20 — Bốn ô đáp án (`game-mc/choice-0..3`)
Nguồn: spec `game-mc/choice-0..3` (mỗi ô `surface` r:12 border:1px `divider`, span nghĩa "school/hospital/park/restaurant")
Given: `waiting`, 4 lựa chọn — 1 đúng + 3 nhiễu (nhiễu = nghĩa của thẻ khác trong tập).
When: chạm từng ô.
Then (UI): ô đúng → dạng `correct` (SC-GAMEMC-02); ô sai → dạng `wrong` (SC-GAMEMC-03). Mỗi ô hiển thị
`card_meanings.content` (nguồn DB, không copy kit). Sau khi 1 ô được chọn, các ô còn lại **không nhận tap nữa**
cho thẻ đó (⚠ xác nhận: khoá lựa chọn sau lần chấm đầu?).
Then (DB): KHÔNG ghi gì (D-007).
⚠ Xác nhận: số lựa chọn cố định 4 hay theo cấu hình? (spec repeat x4; không có setting số option). Nguồn nhiễu:
cùng deck/tập ván hay toàn cặp ngôn ngữ?

### SC-GAMEMC-21 — Nút "Next round" (`game-mc/next`)
Nguồn: spec `game-mc/next` (btn nền `primary`, icon arrow_forward + "Next round"), chỉ state complete · D-029(tương tự "chạy lại")
When: ở `complete`, chạm "Next round".
Then (UI): bắt đầu **ván mới** cùng cấu hình (type=mc, cùng scope/random) với tập thẻ mới lấy `game_words_per_round`
(D-008); về `waiting`. ⚠ Xác nhận: "Next round" lấy tập thẻ **mới khác** hay lặp cùng tập? nếu hết thẻ khả dụng
thì sao (ván cuối)?
Then (DB): KHÔNG ghi gì (D-007).

---

## 3. Điều hướng vào/ra

### SC-GAMEMC-30 — Vào game-mc từ picker "Một trò chơi"
Nguồn: D-013 · nav `game`→`gamePlay` · game-modes BR-1
Given: mở menu Play tại 1 nút → "Một trò chơi" → picker chọn **"Đoán"** (+ tuỳ chọn scope BR-5, random).
When: xác nhận chọn.
Then (UI): push `gamePlay` (type=mc) → game-mc[waiting] với tập `game_words_per_round` thẻ (D-008).
Then (DB): đọc `settings`(`game_words_per_round`, `game_random`, scope BR-5) + `cards`/`card_meanings` (loại
`hidden=1` — D-006); KHÔNG ghi.

### SC-GAMEMC-31 — Ra: back → về màn mở ván
Nguồn: nav push/pop · spec `game-mc/back`
When: chạm back (hoặc back hệ thống) tại game-mc.
Then: pop về picker `game`/nút nguồn; giữ trạng thái màn nguồn. ⚠ Xác nhận: pop về picker hay về deck-detail?

### SC-GAMEMC-32 — Ra: complete → "Next round" (ở lại luồng game)
Nguồn: SC-GAMEMC-21
Then: không pop; thay nội dung sang ván mới (waiting). Back sau đó vẫn về màn mở ván ban đầu.

### SC-GAMEMC-33 — game-mc là chặng 2–5 của NewLearn (bối cảnh nhúng)
Nguồn: study-flow §Mô hình luồng ("chặng 2–5 dùng 4 game thật … Đoán") · game-modes §1
Given: đang trong chuỗi "Học" 5 chặng, tới chặng "Đoán".
When: chơi game-mc như một chặng.
Then (UI): render game-mc như thường; **khác biệt bối cảnh**: hoàn thành đóng góp vào tiến độ 5 chặng, KHÔNG
kết thúc bằng khối complete "Next round" độc lập mà chuyển sang chặng kế.
Then (DB): trong bối cảnh NewLearn, việc **vào ô 1** chỉ xảy ra sau **đủ 5 chặng** (D-002/D-017) — bản thân
chặng game-mc không tự ghi `srs_state`. ⚠ Xác nhận: cùng screen `game-mc` có phục vụ cả 2 bối cảnh (chạy riêng
vs chặng NewLearn) hay có màn riêng? (contract chỉ mô tả 4 state độc lập; cần chốt để không nhầm assertion).

### SC-GAMEMC-34 — Không deep-link
Nguồn: nav-flow "Không deep-link ngoài v1"
Then: game-mc chỉ đến được qua push nội bộ; không có route deep-link ngoài.

### SC-GAMEMC-35 — Back hệ thống (Android) giữa ván
Nguồn: nav push
When: nhấn back cứng khi đang `waiting`/sau chấm.
Then: tương đương SC-GAMEMC-31 (pop). ⚠ Xác nhận: có chặn/hỏi xác nhận bỏ ván không?

---

## 5. Lượng dữ liệu

### SC-GAMEMC-40 — Đủ thẻ (=`game_words_per_round`, mặc định 5)
Nguồn: D-008/BR-7 · setting `game_words_per_round`
Given: deck có ≥5 thẻ visible.
Then: ván dùng đúng 5 thẻ; progress chia theo 5.

### SC-GAMEMC-41 — Ít hơn round size (vd deck chỉ 3 thẻ visible)
Nguồn: D-008 (biên dưới)
Then: ⚠ Xác nhận — ván dùng 3 thẻ (tất cả khả dụng) hay không mở được? (spec không nêu min). Assert: nếu chạy,
progress chia theo số thẻ thực.

### SC-GAMEMC-42 — Chỉ 1 thẻ visible / thiếu nhiễu cho 4 ô
Nguồn: D-008 (biên) + SC-GAMEMC-17..20
Then: ⚠ Xác nhận — với 1 thẻ thì lấy đâu 3 nhiễu cho 4 ô? (không đủ nghĩa khác). Cần chốt: giảm số ô, lấy nhiễu
ngoài tập, hay chặn game. KHÔNG bịa.

### SC-GAMEMC-43 — 0 thẻ visible (rỗng / tất cả `hidden`)
Nguồn: D-006 (thẻ ẩn loại khỏi hàng đợi) · D-008
Given: deck rỗng hoặc mọi thẻ `hidden=1`.
Then: ⚠ Xác nhận — không có state `empty` trong contract game-mc. Cần chốt: picker chặn chọn Đoán, hay hiện
thông báo "không đủ thẻ"? KHÔNG bịa state.

### SC-GAMEMC-44 — Nhiều thẻ (> round size) + random
Nguồn: D-008 (`game_random`)
Given: deck 100 thẻ, `game_random`=on.
Then: ván lấy `game_words_per_round` thẻ **ngẫu nhiên**; `game_random`=off ⇒ lấy theo thứ tự ổn định. Assert
**nguồn chọn** (từ tập scope), không assert thẻ cụ thể nào.

### SC-GAMEMC-45 — Scope = bộ thẻ CHA có bộ con → tập ván gộp ĐỆ QUY toàn cây con
Nguồn: D-009 (bắt đầu học tại bộ-cha ⇒ gộp **đệ quy** thẻ mọi bộ con) · study-flow BR-6 ("Học/ôn tại một bộ thẻ
cha gộp **đệ quy** toàn bộ thẻ của các bộ thẻ con") · game-modes §1 (bốn game dùng chung tập thẻ) · scope BR-5
(giao với DoE #3 nav scope + #5 lượng dữ liệu).
Given (DB): mở game-mc tại một **deck cha** có ≥1 deck con (nhiều tầng), tổng thẻ visible của **cây con** ≥
`game_words_per_round`; mỗi bộ con có thẻ visible riêng; một số thẻ ở cấp cha, một số ở cấp con (kể cả cháu).
When (UI): xác nhận chọn Đoán tại nút deck cha (scope BR-5).
Then (DB): tập nguồn để dựng ván là **hợp đệ quy** thẻ visible (`cards.hidden`=0, loại `hidden=1` — D-006) của
deck cha **và toàn bộ cây con** (con, cháu…), KHÔNG chỉ thẻ trực tiếp của cha. `game_words_per_round` thẻ của ván
được lấy từ tập gộp này (ngẫu nhiên/ổn định theo `game_random` — SC-GAMEMC-44). KHÔNG ghi (D-007).
Then (UI): thẻ prompt của ván có thể là thẻ thuộc **bất kỳ** bộ con trong cây (assert **nguồn gộp đệ quy**, không
assert thẻ/bộ cụ thể); nhiễu 4 ô lấy trong cùng tập gộp (liên quan Open-q #5 về nguồn nhiễu).
⚠ Xác nhận: thứ tự duyệt cây (breadth/depth) & khử trùng lặp nếu thẻ xuất hiện nhiều nơi — không có nguồn chốt,
chỉ khẳng định **tính đệ quy** của tập (D-009/BR-6), không bịa thứ tự.

---

## 6. Async & lỗi

### SC-GAMEMC-50 — loading tập thẻ → waiting
Nguồn: contract states (không có state `loading` riêng) · async build tập thẻ
Given: dựng tập ván (đọc `cards`/`card_meanings`).
Then: ⚠ Xác nhận — game-mc contract KHÔNG có state `loading`/`error`. Cần chốt hiện gì khi đang tải (skeleton?
spinner? — study-flow NFR: dựng hàng đợi < 100 ms). Assert tối thiểu: không hiện đáp án rác trước khi có dữ liệu.

### SC-GAMEMC-51 — Lỗi đọc DB khi dựng ván
Nguồn: async lỗi · không có state `error` trong contract
Then: ⚠ Xác nhận — hiện gì khi query `cards`/`card_meanings` thất bại? (không có `error` state; lỗi phải flow
`Failure`→`AsyncValue.error` theo repo-rule nhưng UI đích chưa có trong kit). Cần spec; KHÔNG bịa banner.

### SC-GAMEMC-52 — Local-first (không mạng)
Nguồn: local-first (repo rule; TTS hoãn)
Then: game-mc chạy đầy đủ offline từ DB local (term/nghĩa/lựa chọn); chỉ chức năng audio (nếu có) mới cần
online — hiện hoãn (SC-GAMEMC-15).

### SC-GAMEMC-53 — Huỷ giữa chừng (thoát trước khi complete)
Nguồn: D-007/D-017 (ranh giới) · back
When: thoát ván ở giữa (chưa complete).
Then (DB): KHÔNG ghi bất kỳ bảng nào (game là practice — D-007; và không phải NewLearn nên không có "thẻ vẫn
mới" theo D-017, vì game-mc chạy-riêng không đụng `srs_state` từ đầu).

---

## 7. Persistence (DB round-trip)

### SC-GAMEMC-60 — Chơi xong 1 ván KHÔNG đổi `srs_state`
Nguồn: D-007/D-013 · BR-4 · schema `srs_state` "Game/Review/Player leave srs_state unchanged" · D-009 (khi scope
= bộ-cha-có-con: tập ván gộp đệ quy — SC-GAMEMC-45)
Given: ghi lại `srs_state.box`/`due_at`/`last_reviewed_at` của **mọi thẻ trong ván** trước khi chơi. Khi scope là
**bộ thẻ cha có bộ con** (D-009/BR-6, SC-GAMEMC-45), tập thẻ được snapshot phải **bao trùm cây con đệ quy** —
gồm cả thẻ của các deck con/cháu đã gộp vào ván, KHÔNG chỉ thẻ trực tiếp của deck cha (nếu không, assertion
"không đổi `srs_state`" sẽ bỏ sót thẻ con thuộc ván).
When: chơi hết ván (có cả câu sai được lặp lại tới đúng).
Then (DB): `srs_state` của **mọi thẻ trong ván (kể cả thẻ deck con gộp đệ quy)** **y hệt** trước (box/due_at/
last_reviewed_at không đổi).

### SC-GAMEMC-61 — KHÔNG ghi `review_logs`
Nguồn: D-007 · schema `review_logs` "Practice modes record no log"
When: trả lời đúng/sai nhiều lần.
Then (DB): số dòng `review_logs` **không tăng** (đếm trước/sau bằng nhau).

### SC-GAMEMC-62 — KHÔNG tạo `study_sessions` / cộng `daily_activity`
Nguồn: D-010/BR-4/BR-5 · schema `study_sessions` "only dueReview & newLearn create one"
When: hoàn tất ván (complete).
Then (DB): KHÔNG thêm dòng `study_sessions`; `daily_activity`(hôm nay).minutes/words **không đổi**.

### SC-GAMEMC-63 — Kill & mở lại app sau khi chơi
Nguồn: persistence round-trip
Given: chơi 1 ván rồi kill app.
Then: mở lại → mọi bảng học/lịch (`srs_state`, `review_logs`, `study_sessions`, `daily_activity`) đúng như
trước khi chơi (chơi game không để lại dấu vết bền vững). ⚠ Xác nhận: ván đang dở có được resume sau kill hay
mất? (không có state persistence cho ván trong schema).

---

## 8. Định dạng & i18n

### SC-GAMEMC-70 — Chuỗi UI theo locale
Nguồn: ARB · SC-GAMEMC-12
Given: đổi locale (vi/en/ja).
Then: title "Multiple choice", "Round complete!", "Next round", phụ đề "N correct" đổi theo ARB; không hardcode
chuỗi kit; layout không vỡ.

### SC-GAMEMC-71 — Plural phụ đề complete ("N correct")
Nguồn: contract[complete] MOCK "You answered 5/5 correctly." · CHECKLIST plural
Then: dùng ARB plural cho số câu đúng/tổng (1 vs N); KHÔNG nối chuỗi thủ công. Assert dạng plural đúng, không
assert "5/5".

### SC-GAMEMC-72 — Term & lựa chọn CJK (Hàn/Nhật)
Nguồn: kit MOCK term "학교" · CHECKLIST CJK
Given: thẻ có term CJK (vd "학교", "太郎") và nghĩa CJK.
Then: prompt + 4 ô render đúng glyph CJK (không tofu); không cắt sai; card/ô không vỡ.

### SC-GAMEMC-73 — Nội dung dài (term dài, nghĩa dài)
Nguồn: CHECKLIST text dài
Given: term rất dài / một lựa chọn có content rất dài.
Then: prompt wrap/ellipsis không tràn card; ô đáp án wrap/ellipsis không đẩy layout (span `grow:1`); 4 ô vẫn
đều.

### SC-GAMEMC-74 — Ký tự đặc biệt / emoji trong nội dung
Nguồn: CHECKLIST đặc biệt/emoji
Given: term/nghĩa chứa emoji, dấu, ký tự đặc biệt.
Then: render nguyên vẹn, không crash, không phá layout (dữ liệu đã qua validation editor — game chỉ hiển thị).

---

## 9. Dark mode

### SC-GAMEMC-80 — Mọi state ở dark
Nguồn: contract 4 state × dark · wireframe cột dark
Then: `waiting`/`correct`/`wrong`/`complete` render đúng ở dark bằng token (`surface`, `divider`,
`success`/`success-soft`/`on-success-soft`, `error`/`error-soft`/`on-error-soft`, `primary`, `surface-sunken`) —
KHÔNG hardcode màu; tương phản đáp án đúng/sai đạt ở cả light + dark.

## 10. Responsive

### SC-GAMEMC-81 — 320px → tablet + xoay
Nguồn: CHECKLIST responsive
Then: ở 320px không overflow (card prompt + 4 ô co giãn, ô cao tối thiểu giữ hit-area); body `layout_hint:scroll`
cuộn được khi nội dung dài/ngang; safe-area/notch OK; xoay ngang cuộn được, khối complete căn giữa.

## 11. A11y

### SC-GAMEMC-82 — Semantics
Nguồn: CHECKLIST a11y · spec icon-button/btn
Then: back/options/audio/edit/choice-0..3/next có semantic label; hit-area ≥48 (edit là 36×36 icon nhưng vùng
chạm phải ≥48 — ⚠ xác nhận); thứ tự đọc: title → progress → prompt(term) → 4 lựa chọn → (complete: tiêu đề →
phụ đề → Next); trạng thái đúng/sai của ô được screen-reader thông báo (không chỉ đổi màu); progress đọc thành
"đã X trên N".

## 12. Concurrency & edge thời gian

### SC-GAMEMC-90 — Double-tap 1 ô đáp án
Nguồn: CHECKLIST concurrency · SC-GAMEMC-17..20
When: chạm nhanh 2 lần cùng 1 ô.
Then: chỉ chấm **một** lần (một lần chuyển correct/wrong; không nhảy 2 thẻ). Không double-advance progress.

### SC-GAMEMC-91 — Tap 2 ô gần như đồng thời
Nguồn: CHECKLIST concurrency
When: chạm 2 ô khác nhau gần như cùng lúc.
Then: chỉ ô đầu được ghi nhận là lựa chọn; ô sau bị bỏ qua (khoá sau lần chấm đầu — liên quan SC-GAMEMC-17..20).

### SC-GAMEMC-92 — Double-tap "Next round"
Nguồn: CHECKLIST concurrency · SC-GAMEMC-21
When: ở complete, chạm "Next round" 2 lần nhanh.
Then: chỉ mở **một** ván mới (không chồng 2 ván / 2 push).

### SC-GAMEMC-93 — Đổi ngày lúc nửa đêm khi đang chơi
Nguồn: D-021 (ranh giới) · BR-4
Given: đang chơi game-mc lúc 23:59, đồng hồ qua 00:00.
Then (DB): vì game KHÔNG cộng `daily_activity` (BR-4/D-007), việc đổi ngày **không** ảnh hưởng streak/hoạt động
từ ván này (không có ghi nhận nào để rơi vào ngày nào). Assert: `daily_activity` không đổi bởi ván qua nửa đêm.

### SC-GAMEMC-94 — Race: tap ô mới ĐÚNG LÚC đang chuyển tiếp feedback→advance
Nguồn: CHECKLIST concurrency · SC-GAMEMC-02/03 (correct/wrong → chuyển thẻ kế) · **phụ thuộc Open-q #14**
(chuyển tiếp sau chấm là tự động hay chờ tap — CHƯA CHỐT).
Given: một ô vừa được chấm (correct/wrong), UI đang ở cửa sổ **chuyển tiếp** sang thẻ kế (progress sắp tăng).
When: người học chạm một ô **của thẻ kế** (hoặc chạm lại vùng đáp án) trong lúc transition chưa hoàn tất.
Then: ⚠ Xác nhận — hành vi đúng phụ thuộc câu trả lời **Open-q #14**: nếu **tự động** advance thì tap trong cửa
sổ transition phải bị **nuốt/bỏ qua** (KHÔNG được chấm nhầm cho thẻ kế trước khi thẻ kế thật sự hiển thị & khoá
chọn reset); nếu **chờ tap** thì tap đó chỉ là lệnh "next", không phải chọn đáp án. KHÔNG bịa cơ chế chuyển tiếp.
Assert tối thiểu (độc lập với Open-q #14): tap trong cửa sổ transition **không** double-advance progress và
**không** ghi/chấm nhầm sang thẻ kế. Đây là **edge phụ thuộc Open-q #14** — ghi rõ, không lờ đi; khi #14 chốt →
hoàn thiện assertion + xoá cờ ⚠.

---

## Open questions (⚠ cần chốt spec trước khi viết test — KHÔNG bịa)

1. **Chiều hiển thị (D-011)**: prompt = term / 4 ô = nghĩa — khi cặp đảo (KO↔VI) thì term-side là gì? **D-011**
   ("đảo chiều hiển thị KO↔VI → dùng CÙNG một `SrsState` một chiều") chốt lịch SRS một chiều, nhưng KHÔNG chốt
   chiều **hiển thị** của game (prompt=term/4 ô=nghĩa, xử lý cặp đảo). Map trực tiếp về SC-GAMEMC-01/14.
2. **Nút options (3-chấm)**: đích khi tap? kit không có menu/sheet cho game-mc (intent-ledger ghi node tái dùng
   key, realign hoãn) — hiện gì?
3. **Nút edit**: sửa thẻ hiện tại giữa ván? mở màn gì? có trong luồng nào không?
4. **Nút audio**: TTS/audio hoãn v1 (audio_ref NULL) — nút hiển thị nhưng no-op, hay ẩn?
5. **Số lựa chọn & nguồn nhiễu**: cố định 4 ô? nhiễu lấy từ cùng tập ván, cùng deck, hay toàn cặp ngôn ngữ?
6. **Công thức progress & "N/M correct"**: đếm theo thẻ-đúng hay theo lượt (có tính lần lặp do sai — D-015)?
7. **Biên số thẻ**: <round size (vd 3) → chạy hay chặn? 1 thẻ (không đủ nhiễu) → xử lý sao? 0 thẻ → không có
   state empty trong contract.
8. **State loading/error**: contract game-mc chỉ có 4 state (waiting/correct/wrong/complete) — hiện gì khi đang
   tải tập thẻ hoặc query lỗi?
9. **"Next round"**: lấy tập thẻ mới khác hay lặp cùng tập? xử lý khi hết thẻ khả dụng?
10. **Back giữa ván**: có dialog xác nhận "bỏ ván"? pop về picker hay deck-detail?
11. **Bối cảnh nhúng (chặng 2–5 NewLearn) vs chạy-riêng**: cùng screen `game-mc` phục vụ cả hai, hay màn riêng?
    khác biệt kết thúc (complete "Next round" vs chuyển chặng) cần chốt.
12. **Resume ván sau kill**: ván đang dở có được khôi phục không? (không có bảng lưu state ván trong schema).
13. **Khoá lựa chọn sau lần chấm đầu**: sau khi chọn 1 ô, các ô khác có bị vô hiệu cho thẻ đó không?
14. **Chuyển tiếp sau state wrong/correct**: tự động sang thẻ kế hay chờ người học tap tiếp? (Cửa sổ chuyển tiếp
    feedback→advance là edge race của **SC-GAMEMC-94** — assertion đầy đủ phụ thuộc câu trả lời mục này.)

> Các mục ⚠ ở trên là **danh sách phải hỏi BA/spec**, không được đoán. Khi có câu trả lời → cập nhật scenario
> tương ứng + xoá cờ ⚠. Đây chính là "không bỏ sót": phần chưa rõ được **liệt kê ra**, không lờ đi.
