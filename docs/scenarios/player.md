# Kịch bản — Player (Trình phát tự động) · screen `player`

Nguồn: `docs/contracts/player.md` [playing · paused · speed · end] ·
DOM `docs/design/MemoX Design System/ui_kits/memox-app/specs/player.md` ·
D-014 (mở Trình phát, phát tự động, không đổi `SrsState`) ·
D-007 (kết thúc luyện tập → `SrsState` không đổi) · D-010 (Player KHÔNG cộng `daily_activity`) ·
D-011 (đảo chiều hiển thị KO↔VI dùng **cùng một** `SrsState` — một chiều duy nhất; xem SC-PLAYER-15 + Open-question 16) ·
BR-8/BR-5 (`docs/business/study/study-flow.md`: Player = luyện tập thuần, không lịch, không hoạt động) ·
Chệch transport (Replay=`primary`, Close=`ghost`) **suy ra trực tiếp từ DOM** (replay `bg:primary`; close không nền, chữ `primary-strong`) — xem SC-PLAYER-21/22 ·
Nav `docs/business/navigation/navigation-flow.md` (`player` `/player/:nodeId`, push, auto-play) ·
DB assertion (chứng minh "no write"): `srs_state`, `review_logs`, `study_sessions`, `daily_activity`
(Player tuyệt đối KHÔNG ghi các bảng này); đọc thẻ để phát từ `cards` + `card_meanings`.

> Số/tên/chuỗi trong kit là MOCK ("TOPIK I — Vocabulary", "학교", "school", "×1", "All played") —
> assert **định dạng & nguồn (ARB)**, KHÔNG assert giá trị mock. Lưu ý DOM MOCK viết end-body là
> "…every card in this **deck**." nhưng ARB thật (`playerEndText`) = "The player has read through
> every card in this **set**." — assert theo ARB ("set"/"từ"), KHÔNG copy chuỗi mock của kit.
> Chuỗi lấy từ ARB (`playerTitle`, `playerBack`, `playerPlay`,
> `playerPause`, `playerPrev`, `playerNext`, `playerSpeed`, `playerSpeedValue`, `playerEndTitle`,
> `playerEndText`, `playerReplay`, `playerClose`, …), không copy kit.
> Player là **local-first**: đọc thẻ từ DB local, không phụ thuộc mạng.

## DoE — player (12 chiều)

| # | Chiều | TT | Scenario / N/A |
|---|---|---|---|
| 1 | States (4 kit: playing·paused·speed·end) | ✅ | SC-PLAYER-01..04 (+ empty/error ARB-only ⇒ SC-PLAYER-05..06, cờ ⚠) |
| 2 | Elements (10 tương tác trong DOM spec) | ✅ | SC-PLAYER-10..22 |
| 3 | Nav vào/ra | ✅ | SC-PLAYER-30..35 |
| 4 | Nhập liệu & validation | **N/A (text) + 1 discrete-choice** | Không có field text nhập liệu (nội dung thẻ read-only từ DB — validation thuộc flashcard-editor). Nhưng segmented speed LÀ input chọn giá trị ràng buộc {×0.75, ×1, ×1.5}: biên chọn (re-tap nhanh, chọn lại đoạn đang active) → SC-PLAYER-20 + SC-PLAYER-94. |
| 5 | Lượng dữ liệu | ✅ | SC-PLAYER-40..44 |
| 6 | Async & lỗi | ✅ | SC-PLAYER-50..53 |
| 7 | Persistence (DB round-trip) | ✅ | SC-PLAYER-60..63 |
| 8 | Định dạng & i18n | ✅ | SC-PLAYER-70..74 |
| 9 | Dark mode | ✅ | SC-PLAYER-80 |
| 10 | Responsive | ✅ | SC-PLAYER-81 |
| 11 | A11y | ✅ | SC-PLAYER-82 |
| 12 | Concurrency & edge thời gian | ✅ | SC-PLAYER-90..95 (95 = timer auto-advance đua với tap thủ công) |

Element inventory (từ DOM spec — mỗi cái ≥1 scenario ở mục 2):
`player/back` (icon-button arrow_back) · `player/text-size` (icon-button format_size) ·
`player/options` (icon-button more_vert) · `player/appbar__title` (tên nút, ellipsis) ·
`player/progress` (dải chấm tiến độ N đoạn) · `player/card` (term + divider + nghĩa) ·
`player/prev` (icon-button skip_previous) · `player/playpause` (nút pause/play_arrow, nền `primary` — biến thể FAB/IconButton ⚠ chưa chốt, xem Open-question 17) ·
`player/next` (icon-button skip_next) · `player/speed` (btn ×N mở control) ·
`player/speed-control` (segmented ×0.75/×1/×1.5) · `player/replay` (btn, end) · `player/close` (btn, end).

> ⚠ **playpause = FAB hay `MxIconButton` primary? CHƯA CÓ NGUỒN — xem Open-question 17.**
> DOM chỉ cho `bg:primary r:9999 shadow:8/18` (nhất quán với **cả** FAB **lẫn** IconButton-primary),
> `mx:?` (không map chắc), KHÔNG có ruling FAB-vs-IconButton. Không tồn tại
> `tool/parity/intent-ledger.json` / `tool/parity/contracts/` (đã kiểm) và không có "UC-4/§5/PR #31"
> trong contract/spec/decision-table. **KHÔNG assert biến thể playpause tới khi chốt spec + kit-first.**
>
> End-state Replay=`primary`, Close=`ghost` thì **suy ra được từ DOM** (replay `bg:primary`;
> close không nền, chữ `primary-strong`) ⇒ assert được (SC-PLAYER-21/22), KHÔNG cần ruling ngoài.

---

## 1. States

### SC-PLAYER-01 — playing (đang phát tự động)
Nguồn: contract[playing] · spec base · D-014 · BR-8
Tiền điều kiện (Given):
  - DB: `decks`(1 node "TOPIK I", có ≥2 thẻ visible), `cards`(hidden=0) + `card_meanings`(≥1 nghĩa/thẻ)
  - Vào `/player/:nodeId` với node có thẻ để phát
Thao tác (When):
  1. Mở Trình phát từ menu Play của nút → player[playing]
Kỳ vọng (Then):
  - UI: appbar (back + title = tên nút + text-size + options) · progress dots (đoạn đã phát = màu `primary`, còn lại = `surface-sunken`) · card hiện **term** (trên) + divider + **nghĩa** (dưới) · hàng transport [prev · playpause(icon `pause`, nền `primary`) · next] · nút speed "×N". Không banner.
  - UI: đang phát ⇒ nút giữa hiển thị **pause** (đang chạy có thể tạm dừng).
  - DB: `srs_state` / `review_logs` / `study_sessions` / `daily_activity` **KHÔNG có dòng mới nào** (D-014/D-007/D-010).
⚠ Xác nhận: nội dung card hiện đồng thời term+nghĩa hay lần lượt (D-014 "lần lượt hiện term + nghĩa")? — spec DOM vẽ cả hai cùng lúc; cần chốt trình tự hiển thị/đọc.

### SC-PLAYER-02 — paused (tạm dừng)
Nguồn: contract[paused] · spec "paused" diff (playpause: pause→play_arrow)
Given: đang ở player[playing]
When: chạm nút giữa (playpause)
Kỳ vọng (Then):
  - UI: nút giữa đổi icon `pause` → `play_arrow` (giữ nền `primary`, kích thước/shadow không đổi theo diff); tự-chuyển thẻ **dừng lại** tại thẻ hiện tại; progress dots giữ nguyên.
  - DB: không ghi bảng nào (vẫn là luyện tập).

### SC-PLAYER-03 — speed (mở bộ chọn tốc độ)
Nguồn: contract[speed] · spec "speed" diff (btn "×N" → segmented ×0.75/×1/×1.5)
Given: đang ở player[playing] hoặc [paused], speed hiện là "×1"
When: chạm nút speed "×N"
Kỳ vọng (Then):
  - UI: nút "×N" được thay bằng `player/speed-control` = segmented 3 đoạn `×0.75 · ×1 · ×1.5`; đoạn đang chọn (mock: ×1) có nền `surface` + `primary-strong` + shadow, hai đoạn kia `text-secondary` trên nền `surface-muted`.
  - UI (**ordered-diff invariant**): CHỈ hàng speed đổi. `player/speed` (btn "×N", `rel:[20,582 350x38]` h:38) bị **thay tại chỗ** bằng `player/speed-control` (`rel:[20,574 350x46]` h:46) — hàng cao thêm 8px và dịch lên (582→574) theo diff DOM. Hàng transport [prev · playpause · next] **phía trên KHÔNG đổi**; card + progress **KHÔNG reflow**; không phần tử nào khác thêm/bớt/xê dịch ngoài hàng speed.
  - UI: các nhãn tốc độ dùng ARB `playerSpeedValue` với placeholder `rate` (×{rate}), KHÔNG hardcode "×1".
⚠ Xác nhận: tập giá trị tốc độ = {0.75, 1, 1.5} có phải bộ chốt cuối? (kit chỉ mock 3 mốc). Tốc độ mặc định = ×1?

### SC-PLAYER-04 — end (đã phát hết)
Nguồn: contract[end] · spec "end" (full) · D-014
Given: đang phát; phát tới thẻ **cuối cùng** của hàng đợi và thẻ cuối kết thúc
When: player tự chuyển qua thẻ cuối
Kỳ vọng (Then):
  - UI: thân màn thay bằng `player/end` = icon-tile (library_music, nền `accent-soft`) + tiêu đề (ARB `playerEndTitle`) + mô tả (ARB `playerEndText`) + nút **Replay** (biến thể `primary`, icon replay) + nút **Close** (biến thể `ghost`, icon close, chữ `primary-strong`).
  - UI: appbar vẫn còn (back + title + text-size + options).
  - DB: không ghi bảng nào trong suốt phiên (D-007/D-010/D-014).

### SC-PLAYER-05 — empty (nút không có thẻ để phát) ⚠
Nguồn: ARB `playerEmptyTitle`/`playerEmptyText` (CÓ chuỗi) · **KHÔNG có state `empty` trong contract kit** (chỉ 4 state)
Given: DB — node được mở có **0 thẻ visible** (0 thẻ, hoặc mọi thẻ `hidden=1` theo D-006)
When: mở `/player/:nodeId`
Kỳ vọng (Then):
  - UI: hiển thị trạng thái rỗng dùng ARB `playerEmptyTitle` + `playerEmptyText`; không có transport phát; back vẫn hoạt động.
  - DB: không ghi bảng nào.
⚠ Xác nhận: kit contract chỉ liệt kê 4 state (không có `empty`) nhưng ARB đã có `playerEmpty*`. Cần bổ sung state `empty` vào kit + `/design-sync` TRƯỚC khi build UI (kit-first). Hiện là **spec đích**, test có thể đỏ tới khi kit định nghĩa. Ngưỡng "rỗng" = tính theo thẻ visible (loại `hidden`, D-006)?

### SC-PLAYER-06 — error (không mở được player) ⚠
Nguồn: ARB `playerErrorTitle`/`playerErrorText` (CÓ chuỗi) · **KHÔNG có state `error` trong contract kit**
Given: đọc thẻ để phát thất bại (lỗi DB/repository)
When: mở `/player/:nodeId`
Kỳ vọng (Then):
  - UI: hiển thị trạng thái lỗi dùng ARB `playerErrorTitle` + `playerErrorText`; có lối thử lại/thoát.
  - DB: không ghi bảng nào.
⚠ Xác nhận: `error` không có trong kit contract (4 state) dù ARB có chuỗi. Cần định nghĩa state `error` ở kit + `/design-sync`; retry đi đâu (đọc lại queue?) chưa có trong D-xxx/business. Spec đích.

---

## 2. Elements (mỗi phần tử trong DOM spec ≥1 scenario)

### SC-PLAYER-10 — Nút back (`player/back`, icon arrow_back)
Nguồn: spec `player/back` (icon-button, mx:?) · Nav (player push)
When: chạm back
Kỳ vọng: pop khỏi player, quay về nút nguồn (deck-detail/menu Play). DB: không ghi bảng nào (thoát Player không ghi hoạt động — D-010). Semantic label từ ARB `playerBack`; hit-area ≥48 (spec 48x48).

### SC-PLAYER-11 — Icon-button text-size (`player/text-size`, format_size) ⚠
Nguồn: spec `player/text-size` (icon-button, mx:?)
When: chạm text-size
Kỳ vọng: ⚠ Xác nhận đích — **không có** trong D-xxx/business/ARB (không có key nào cho text-size). Assert tối thiểu: nút có semantic label, hit-area ≥48 (spec 48x48), không crash. Hành vi (mở picker cỡ chữ? áp `theme.font_scale` cục bộ?) → Open questions, KHÔNG bịa.

### SC-PLAYER-12 — Icon-button options (`player/options`, more_vert) ⚠
Nguồn: spec `player/options` (icon-button, mx:?)
When: chạm options
Kỳ vọng: ⚠ Xác nhận đích — **không có** menu-item nào định nghĩa trong D-xxx/business/DOM (chỉ có node more_vert, không có sheet/menu con trong spec). Assert tối thiểu: semantic label, hit-area ≥48, mở overlay không crash. Danh sách menu-item → Open questions.

### SC-PLAYER-13 — Appbar title (`player/appbar__title`)
Nguồn: spec `player/appbar__title` (text "TOPIK I — Vocabulary", clip/ellipsis, expanded)
Kỳ vọng: hiển thị **tên nút** đang phát (nguồn = `decks.name` của `:nodeId`), không hardcode "TOPIK I"; tên dài → ellipsis 1 dòng (spec `clip`), không đẩy back/text-size/options. (xem SC-PLAYER-74)

### SC-PLAYER-14 — Progress dots (`player/progress`)
Nguồn: spec `player/progress` (hàng dot; dot đã phát = `primary`, chưa phát = `surface-sunken`; dot hiện tại rộng hơn — mock 16px)
Given: node có N thẻ, đang ở thẻ thứ k
Kỳ vọng: dải có **N đoạn** (1 đoạn/thẻ — ⚠ xác nhận mapping 1 dot = 1 thẻ hay theo cụm?); k đoạn đầu `primary`, còn lại `surface-sunken`; đoạn hiện tại nổi bật. Tiến k → cập nhật số dot `primary`. KHÔNG assert số dot mock (8) — assert **tỉ lệ theo tiến độ**.

### SC-PLAYER-15 — Card term + nghĩa (`player/card`)
Nguồn: spec `player/card` (div term font 48 · divider · div nghĩa font 30) · D-011 (đảo chiều hiển thị dùng cùng một `SrsState`)
Given: thẻ hiện tại có `cards.term` + `card_meanings.content` (nghĩa đầu, `sort_index` nhỏ nhất)
Kỳ vọng: card hiện raw-order theo DOM = **term** (trên, lớn) + divider + **nghĩa** (dưới); nguồn term = `cards.term`, nghĩa = `card_meanings.content` (meaning primary). Nhiều nghĩa ⇒ hiện nghĩa đầu (⚠ xác nhận: chỉ nghĩa đầu hay cuộn hết?).
⚠ **Chiều hiển thị (D-011)**: D-011 khẳng định đảo chiều KO↔VI dùng **cùng một** `SrsState` (một chiều lịch duy nhất) nhưng KHÔNG nói mặt nào lên trên khi *hiển thị*. SC-15 hiện giả định luôn term-trên-nghĩa-dưới theo DOM base. Cần chốt: Player có tôn trọng chiều hiển thị / hướng cặp-ngôn-ngữ của deck (đổi vế nào là "trên") hay luôn raw term→nghĩa? DOM chỉ vẽ 1 hướng — không đủ để suy chiều. (Open-question 16.)

### SC-PLAYER-16 — Nút prev (`player/prev`, skip_previous)
Nguồn: spec `player/prev` (icon-button, mx:?)
When: chạm prev
Kỳ vọng: lùi về thẻ trước; card đổi nội dung; progress dots giảm 1 `primary`. Ở thẻ **đầu** ⇒ ⚠ xác nhận: no-op, disable, hay vòng về cuối? DB: không ghi. Semantic label ARB `playerPrev`.

### SC-PLAYER-17 — Nút playpause (`player/playpause`)
Nguồn: spec `player/playpause` (pause↔play_arrow, nền `primary` `r:9999` `shadow:8/18`, mx:?)
When: chạm khi đang phát → khi đang dừng
Kỳ vọng: playing→paused (icon pause→play_arrow, ngừng auto-advance); paused→playing (play_arrow→pause, tiếp tục auto-advance). Semantic label ARB `playerPlay`/`playerPause` theo trạng thái. DB: không ghi.
⚠ Xác nhận: biến thể control (FAB hay `MxIconButton` primary) CHƯA có nguồn — DOM chỉ cho `bg:primary r:9999`, không có ruling. KHÔNG assert kiểu widget tới khi chốt (Open-question 17). Assert được: đổi icon theo trạng thái + hành vi pause/resume.

### SC-PLAYER-18 — Nút next (`player/next`, skip_next)
Nguồn: spec `player/next` (icon-button, mx:?)
When: chạm next
Kỳ vọng: sang thẻ kế; card đổi; progress dots +1 `primary`. Ở thẻ **cuối** + chạm next ⇒ đi tới `end` (SC-PLAYER-04) (⚠ xác nhận: next ở thẻ cuối = end hay no-op/vòng?). DB: không ghi. Semantic label ARB `playerNext`.

### SC-PLAYER-19 — Nút speed (`player/speed`)
Nguồn: spec `player/speed` (btn "×N", icon speed + span ×1, mx:?)
When: chạm nút speed
Kỳ vọng: mở `player/speed-control` (→ state speed, SC-PLAYER-03). Nhãn nút = tốc độ hiện tại qua ARB `playerSpeedValue`. Semantic label ARB `playerSpeed`.

### SC-PLAYER-20 — Segmented speed (`player/speed-control`, ×0.75/×1/×1.5)
Nguồn: spec `player/speed-control` (segmented 3 seg, seg chọn có nền `surface`+`primary-strong`)
When: đang mở speed-control, chạm một đoạn (vd ×1.5)
Kỳ vọng: đoạn được chọn thành active (nền `surface`, `primary-strong`, shadow); tốc độ auto-advance đổi theo (⚠ xác nhận đơn vị: hệ số nhân thời gian dừng mỗi thẻ? audio hoãn nên không phải tốc độ audio). Sau khi chọn ⇒ ⚠ xác nhận control đóng lại về nút "×N" hay giữ mở? DB: không ghi.

### SC-PLAYER-94 — Speed re-tap / chọn lại đoạn đang active (validation discrete-choice)
Nguồn: spec `player/speed-control` (3 đoạn cố định) · DoE dim 4 (input chọn giá trị ràng buộc)
Given: speed-control đang mở, đoạn active = ×1
When: (a) chạm lại đúng đoạn ×1 (đã active); (b) chạm rất nhanh 2 đoạn khác nhau (×0.75 rồi ×1.5)
Kỳ vọng:
  - (a) chọn lại đoạn đang active ⇒ no-op idempotent (vẫn ×1, không nhân đôi hiệu ứng, không kẹt); ⚠ xác nhận đích: có đóng control không (giống chọn giá trị mới)?
  - (b) tap nhanh liên tiếp ⇒ giá trị cuối cùng thắng (×1.5), active-segment styling khớp giá trị cuối, không kẹt 2 đoạn active, không đổi tốc độ giữa chừng theo giá trị bị ghi đè.
  - Tập giá trị bị **ràng buộc** {×0.75, ×1, ×1.5} — không có giá trị ngoài tập (không tự do nhập). DB: không ghi.
⚠ Tập giá trị + mặc định (×1?) là spec đích — xem Open-question 4.

### SC-PLAYER-21 — Nút Replay (`player/replay`, end, primary)
Nguồn: spec `player/replay` (btn nền `primary`, icon replay + span "Replay")
Given: đang ở end state
When: chạm Replay
Kỳ vọng: phát lại **từ thẻ đầu**; player về [playing]; progress dots reset (0 `primary`). Nhãn từ ARB `playerReplay`. DB: không ghi (vẫn luyện tập).

### SC-PLAYER-22 — Nút Close (`player/close`, end, ghost)
Nguồn: spec `player/close` (btn ghost, icon close + span "Close", chữ `primary-strong`)
Given: đang ở end state
When: chạm Close
Kỳ vọng: pop khỏi player, về nút nguồn (giống back). Nhãn từ ARB `playerClose`. DB: không ghi.

---

## 3. Điều hướng vào/ra

### SC-PLAYER-30 — Vào từ menu Play của một nút
Nguồn: Nav (`/player/:nodeId`, push) · study-flow BR-1 (Trình phát là 1/5 lối vào) · ARB `librarySheetPlayer`
Given: ở deck-detail/menu Play của node có thẻ
When: chọn "Player" (ARB `librarySheetPlayer`)
Kỳ vọng: push `/player/:nodeId` với đúng nodeId; player mở ở [playing] (auto-play). Player luôn hiện (không như "Lặp lại" cần due>0 — BR-2 chỉ áp Lặp lại). ⚠ Xác nhận: Player có luôn khả dụng cả khi node 0 thẻ (→ empty) hay bị ẩn khỏi menu?

### SC-PLAYER-31 — Vào tại nút cha (gộp đệ quy cây con)
Nguồn: D-009/BR-6 (nút cha gộp đệ quy thẻ cây con)
Given: node cha có bộ thẻ con chứa thẻ
When: mở Player tại node cha
Kỳ vọng: hàng đợi phát gộp **đệ quy** thẻ visible của toàn cây con (loại `hidden`, D-006); progress dots đếm theo tổng gộp. DB đọc: `decks` (CTE cây con) + `cards`(hidden=0) + `card_meanings`; không ghi.

### SC-PLAYER-32 — Ra: back → nút nguồn
Nguồn: Nav (pop về nút nguồn)
When: chạm back (SC-PLAYER-10) hoặc Close (SC-PLAYER-22) hoặc back hệ thống
Kỳ vọng: pop 1 lần về deck-detail/menu nguồn; không còn player trong stack. DB: không ghi.

### SC-PLAYER-33 — Back hệ thống (Android) khi đang phát
When: nhấn back hệ thống ở [playing]/[paused]/[speed]/[end]
Kỳ vọng: pop khỏi player (đóng phiên phát). ⚠ Xác nhận: có confirm khi đang phát không? (mock/business không nêu → mặc định pop thẳng, không confirm).

### SC-PLAYER-34 — Không deep-link ngoài v1
Nguồn: Nav ("Không deep-link ngoài v1")
Kỳ vọng: player chỉ đến được qua push nội bộ từ menu Play; không entry point deep-link.

### SC-PLAYER-35 — Quay lại nút nguồn giữ nguyên trạng thái
Given: mở Player từ deck-detail đã cuộn tới vị trí X
When: back khỏi Player
Kỳ vọng: deck-detail giữ nguyên vị trí cuộn + state (player là route push, không phá nhánh shell). ⚠ Xác nhận: Player có tự nhớ vị trí thẻ khi mở lại không (mỗi lần mở là phiên mới từ đầu)?

---

## 5. Lượng dữ liệu

### SC-PLAYER-40 — 0 thẻ visible → empty
Nguồn: SC-PLAYER-05 · D-006 (thẻ hidden loại khỏi hàng đợi)
Given: node 0 thẻ HOẶC mọi thẻ `hidden=1`
Kỳ vọng: state empty (ARB `playerEmpty*`); không transport. ⚠ (state empty chưa có trong kit — xem SC-PLAYER-05).

### SC-PLAYER-41 — 1 thẻ
Given: node đúng 1 thẻ visible
Kỳ vọng: progress = 1 đoạn; phát 1 thẻ rồi tới `end`; prev/next ở biên xử lý đúng (⚠ 1 thẻ: prev/next no-op?).

### SC-PLAYER-42 — Nhiều thẻ (vừa)
Given: node ~10 thẻ visible
Kỳ vọng: progress N đoạn; auto-advance tuần tự tới end; dots cập nhật từng bước.

### SC-PLAYER-43 — Rất nhiều thẻ (biên hiển thị progress)
Given: node ~500 thẻ visible
Kỳ vọng: dải progress không tràn ngang màn (⚠ xác nhận: dot/thẻ khi N lớn → gộp/đổi kiểu hiển thị? spec mock 8 dot); màn không overflow; auto-advance vẫn chạy.

### SC-PLAYER-44 — Thẻ ẩn nằm giữa cây con
Nguồn: D-006
Given: cây con có thẻ visible + thẻ `hidden=1` xen kẽ
Kỳ vọng: hàng đợi chỉ gồm thẻ visible; số đoạn progress = số thẻ visible (không đếm hidden). DB đọc lọc `hidden=0`.

---

## 6. Async & lỗi

### SC-PLAYER-50 — loading → playing
Given: đọc hàng đợi từ DB chưa xong
Kỳ vọng: ⚠ contract kit **không có** state `loading` (4 state); xác nhận UI khi đang tải (skeleton? spinner?) — chưa có ở kit. Sau khi resolve → [playing]. (Spec đích — xem Open questions.)

### SC-PLAYER-51 — đọc thẻ thất bại → error
Nguồn: SC-PLAYER-06 (ARB `playerError*`)
Given: repository ném lỗi khi dựng hàng đợi
Kỳ vọng: state error (ARB); DB không ghi. ⚠ state error chưa có trong kit (SC-PLAYER-06).

### SC-PLAYER-52 — Retry sau lỗi
Given: đang ở error state
When: chạm thử lại
Kỳ vọng: đọc lại hàng đợi; thành công → [playing]. ⚠ Xác nhận đích retry (business/D-xxx không nêu).

### SC-PLAYER-53 — Local-first (không mạng)
Nguồn: D-014/BR-8 (Player đọc DB local; audio hoãn)
Given: không có mạng
Kỳ vọng: Player vẫn dựng hàng đợi + phát bình thường từ DB local (audio hoãn nên không cần mạng). Không lỗi mạng. ⚠ audio (`cards.audio_ref` = NULL v1, DT.7 live-only) → xác nhận: có phát audio ở v1 không hay chỉ hiển thị (D-014 ghi "audio hoãn")?

---

## 7. Persistence (DB round-trip)

### SC-PLAYER-60 — Player KHÔNG đổi `srs_state`
Nguồn: D-014/D-007 · BR-5 · srs-review (Player leaves srs_state unchanged)
Given: chụp `srs_state` (box/due_at/last_reviewed_at) của mọi thẻ trước phiên
When: phát hết deck (tới end) rồi thoát
Kỳ vọng: `srs_state` mọi thẻ **y hệt** trước/sau (không dòng mới, không đổi box/due_at); thẻ `new` (box 0/không có row) **vẫn** không có srs_state.

### SC-PLAYER-61 — Player KHÔNG ghi `review_logs` / `study_sessions`
Nguồn: D-007/D-010 · schema-contract ("Practice modes record no log"; chỉ dueReview/newLearn tạo study_sessions)
Given: đếm dòng `review_logs` và `study_sessions` trước phiên
When: phát toàn deck + thao tác prev/next/pause/speed
Kỳ vọng: `review_logs` +0 dòng; `study_sessions` +0 dòng.

### SC-PLAYER-62 — Player KHÔNG cộng `daily_activity`
Nguồn: D-010 (chỉ DueReview/NewLearn cộng phút+từ) · BR-5
Given: `daily_activity`(hôm nay) = giá trị M trước phiên (hoặc không có dòng)
When: phát Player một lúc
Kỳ vọng: `daily_activity`(hôm nay).minutes/words **không đổi** so với trước (Player không cộng). Không tạo dòng ngày mới do Player.

### SC-PLAYER-63 — Kill & mở lại app sau khi dùng Player
Given: dùng Player xong, kill app
When: mở lại app, vào lại nút nguồn
Kỳ vọng: DB round-trip — `srs_state`/`review_logs`/`study_sessions`/`daily_activity` giữ nguyên như trước phiên Player (Player không để lại dấu vết). Mở lại Player = phiên mới từ thẻ đầu.

---

## 8. Định dạng & i18n

### SC-PLAYER-70 — Chuỗi từ ARB (không copy kit)
Kỳ vọng: mọi nhãn/tiêu đề dùng ARB (`playerTitle`? — appbar title là tên deck, không phải "Player"; `playerBack`, `playerPrev`, `playerNext`, `playerPlay`, `playerPause`, `playerSpeed`, `playerEndTitle`, `playerEndText`, `playerReplay`, `playerClose`); không hardcode "All played"/"Replay"/"Close". ⚠ Xác nhận: `playerTitle`="Player" dùng ở đâu (appbar hiển thị tên deck theo DOM, không phải "Player")?

### SC-PLAYER-71 — Speed value `playerSpeedValue` theo locale
Nguồn: ARB `playerSpeedValue` "×{rate}" (placeholder String)
Given: đổi locale (vi/en/ja)
Kỳ vọng: nhãn tốc độ render qua ARB với placeholder `rate` (vd "×0.75"), không nối chuỗi thủ công; dấu × + số hiển thị nhất quán, không tofu.

### SC-PLAYER-72 — Term/nghĩa CJK (Hàn/Nhật)
Given: thẻ term = "학교" (Hàn) / "学校" (Nhật), nghĩa CJK/latin
Kỳ vọng: card render đúng glyph CJK (không tofu); term font lớn + nghĩa font nhỏ hơn không cắt/ellipsis sai; divider giữa nguyên.

### SC-PLAYER-73 — Term/nghĩa rất dài → wrap/ellipsis
Given: term hoặc nghĩa dài (nhiều dòng)
Kỳ vọng: card cho phép xuống dòng/ellipsis trong khung, không tràn ra transport; layout card (minh 280) co giãn, không đẩy nút speed ra ngoài.

### SC-PLAYER-74 — Tên deck dài ở appbar title
Given: `decks.name` rất dài
Kỳ vọng: title ellipsis 1 dòng (spec `clip`), giữ back + text-size + options cố định, không tràn ngang.

---

## 9. Dark mode

### SC-PLAYER-80 — Mọi state ở dark
Kỳ vọng: 4 kit-state (playing/paused/speed/end) + empty/error render đúng ở **cả light + dark** qua token (`bg`/`surface`/`primary`/`surface-sunken`/`accent-soft`/`primary-strong`/`text`/`text-secondary`/`divider`), không hardcode màu; playpause `primary` trên nền, progress dots `primary` vs `surface-sunken`, end icon-tile `accent-soft`/`on-accent` đủ contrast ở dark.

---

## 10. Responsive

### SC-PLAYER-81 — 320px → tablet + xoay ngang
Kỳ vọng: ở 320px card + transport + progress không overflow; appbar 3 icon-button + title không chồng; ở tablet card giãn hợp lý; xoay ngang — card + transport cuộn/co được, safe-area/notch OK; end-state 2 nút không tràn.

---

## 11. A11y

### SC-PLAYER-82 — Semantics & hit-area & thứ tự đọc
Kỳ vọng:
  - Mỗi control có semantic label ARB: back(`playerBack`) · text-size(⚠ chưa có key) · options(⚠ chưa có key) · prev(`playerPrev`) · playpause(`playerPlay`/`playerPause` theo trạng thái) · next(`playerNext`) · speed(`playerSpeed`) · segment(`playerSpeedValue`) · replay(`playerReplay`) · close(`playerClose`).
  - Hit-area ≥48 (spec: icon-button 48x48, playpause 60x60, seg minh 38 — ⚠ seg <48 chiều cao, xác nhận vùng chạm ≥48).
  - Thứ tự đọc: title → progress → card(term→nghĩa) → transport(prev→playpause→next) → speed; end: tiêu đề → mô tả → Replay → Close.
  - Screen-reader đọc term+nghĩa thành câu có nghĩa; trạng thái playing/paused thông báo được (nút đổi nhãn).

---

## 12. Concurrency & edge thời gian

### SC-PLAYER-90 — Double-tap playpause
When: chạm nhanh 2 lần nút playpause
Kỳ vọng: trạng thái lật đúng 1 bước cuối cùng (2 tap = về trạng thái ban đầu), không kẹt trạng thái, không double auto-advance.

### SC-PLAYER-91 — Double-tap next / spam next
When: chạm next liên tục rất nhanh
Kỳ vọng: nhảy đúng số thẻ theo số tap (không nhảy đúp/mất thẻ); tới cuối → end đúng 1 lần (không mở end 2 lần). DB: không ghi.

### SC-PLAYER-92 — Back khi đang phát / khi đang mở speed-control
When: back hệ thống lúc auto-advance đang chạy hoặc speed-control đang mở
Kỳ vọng: ⚠ xác nhận: back đóng speed-control trước (1 back = đóng overlay) rồi back nữa mới pop player; hay pop thẳng? (mock/business không nêu). DB: không ghi.

### SC-PLAYER-93 — Đổi ngày lúc nửa đêm khi đang phát
Given: đang phát Player lúc 23:59, đồng hồ qua 00:00
Kỳ vọng: Player **không** liên quan streak/activity (D-010: Player không cộng `daily_activity`) ⇒ đổi ngày **không** phát sinh ghi/streak từ Player. Phiên phát tiếp tục bình thường. (Khác dashboard SC-DASH-90.)

### SC-PLAYER-95 — Auto-advance timer đua với tap thủ công (prev/next/pause)
Nguồn: D-014 (Player **tự chuyển thẻ** — auto-advance) · DoE dim 12 (hazard timing lõi của trình phát tự chuyển)
Given: đang ở [playing], timer auto-advance sắp bắn (đang ở thẻ k, sắp sang k+1)
When: người dùng tap **đúng thời điểm** timer bắn:
  1. tap **next** ngay lúc timer bắn
  2. tap **prev** ngay lúc timer bắn
  3. tap **pause** (playpause) ngay lúc timer bắn
Kỳ vọng:
  1. next + auto-advance KHÔNG cộng dồn → thẻ tiến đúng **1** bước (k→k+1), không nhảy 2 (k→k+2); progress dots +1 đúng một lần.
  2. prev thắng/ghép đúng: kết quả xác định (k-1) hoặc chống-đua rõ ràng — KHÔNG để timer đẩy k→k+1 đồng thời prev kéo k→k-1 gây kết quả không xác định. ⚠ Xác nhận policy: tap thủ công có **reset/huỷ** timer chu kỳ hiện tại không?
  3. pause ngay lúc timer bắn ⇒ hoặc dừng tại k (timer bị huỷ), hoặc dừng tại k+1 (advance rồi mới pause) — phải **xác định**, không kẹt giữa; sau pause không còn auto-advance ngầm.
  Ở thẻ cuối: timer bắn cùng lúc tap next ⇒ vào `end` đúng **một** lần (không mở end 2 lần). DB: không ghi.
⚠ Đây là hazard đua likely nhất của player tự-chuyển; policy "tap thủ công reset timer" cần chốt spec (Open-question 18).

---

## Open questions (⚠ cần chốt spec trước khi viết test — KHÔNG bịa)

1. **Trình tự card (D-014)**: D-014 nói "lần lượt hiện term + nghĩa + audio" nhưng DOM vẽ term+nghĩa **cùng lúc**. Card hiện đồng thời hay lần lượt (term trước → nghĩa sau)? Có timing/delay mỗi bước?
2. **text-size (`player/format_size`)**: đích khi tap? Không có key ARB, không có D-xxx/business. Mở picker cỡ chữ? Áp `theme.font_scale` cục bộ trong player?
3. **options (`player/more_vert`)**: menu-item nào? DOM chỉ có node more_vert, không có sheet/menu con. Cần kit định nghĩa danh sách item + hành vi + `/design-sync`.
4. **Speed**: tập giá trị chốt = {×0.75, ×1, ×1.5}? Mặc định ×1? Đơn vị speed áp vào cái gì (thời gian dừng mỗi thẻ — vì audio hoãn)? Chọn xong control tự đóng về nút "×N" hay giữ mở?
5. **Progress dots**: 1 dot = 1 thẻ? Khi N rất lớn (500) hiển thị thế nào (spec mock chỉ 8 dot)?
6. **Card nhiều nghĩa**: hiện nghĩa đầu (`sort_index` nhỏ nhất) hay cuộn/lật hết các nghĩa?
7. **Biên transport**: prev ở thẻ đầu = no-op/disable/vòng? next ở thẻ cuối = end/no-op/vòng? Với node 1 thẻ, prev/next làm gì?
8. **State empty**: kit contract chỉ 4 state (không có `empty`) nhưng ARB đã có `playerEmpty*`. Cần thêm state `empty` vào kit + `/design-sync`. Ngưỡng rỗng = 0 thẻ visible (loại hidden, D-006)?
9. **State error**: kit không có `error` dù ARB có `playerError*`. Cần thêm vào kit; retry đi đâu?
10. **State loading**: kit không có `loading`. Hiển thị gì khi đang dựng hàng đợi (skeleton/spinner)?
11. **`playerTitle`="Player"**: dùng ở đâu? DOM appbar title = tên deck (`decks.name`), không phải chữ "Player".
12. **Audio v1**: D-014 ghi "audio hoãn"; `cards.audio_ref` = NULL v1 (TTS live-only, DT.7). Player v1 có phát audio (TTS live) hay chỉ hiển thị + auto-advance im lặng?
13. **Back khi đang phát**: có confirm không? Back khi speed-control mở: đóng overlay trước hay pop player?
14. **Menu Play khả dụng**: mục "Player" có luôn hiện cả khi node 0 thẻ (→ empty) hay ẩn khi rỗng?
15. **Player khả dụng tại node cha rỗng thẻ trực tiếp nhưng cây con có thẻ (D-009/BR-6)** — xác nhận gộp đệ quy áp cho Player (spec study-flow BR-6 áp "học/ôn"; Player là luyện tập — có gộp cây con không?).
16. **Chiều hiển thị card (D-011)**: D-011 chốt đảo chiều KO↔VI dùng **cùng một** `SrsState` (một chiều lịch), nhưng KHÔNG quy định mặt nào **hiển thị** trên khi phát. Player tôn trọng chiều hiển thị / hướng cặp-ngôn-ngữ của deck (đổi vế "trên") hay luôn raw term→nghĩa? (SC-PLAYER-15.)
17. **Biến thể playpause (FAB vs `MxIconButton` primary) — KHÔNG CÓ NGUỒN**: DOM chỉ cho `bg:primary r:9999 shadow:8/18` `mx:?` (nhất quán với cả hai). KHÔNG tồn tại `tool/parity/intent-ledger.json` / `tool/parity/contracts/` (đã kiểm bằng `find`), và không có "UC-4/§5/PR #31" trong contract/spec/decision-table — các trích dẫn này **không xác minh được**. Cần kit định nghĩa biến thể + `/design-sync` (kit-first) TRƯỚC khi assert kiểu widget. (End-state Replay=`primary`/Close=`ghost` thì suy được từ DOM, KHÔNG thuộc câu hỏi này.)
18. **Policy timer auto-advance vs tap thủ công (D-014)**: tap prev/next/pause có **reset/huỷ** chu kỳ timer hiện tại không? Kết quả khi timer bắn trùng thời điểm tap phải xác định (không nhảy 2 thẻ, không kẹt). (SC-PLAYER-95.)

> Các mục ⚠ là **danh sách phải hỏi BA/design + kit-first** trước khi sinh test. Phần chưa rõ được
> **liệt kê ra**, không đoán giá trị/logic. Khi có câu trả lời → cập nhật scenario + xoá cờ ⚠.
