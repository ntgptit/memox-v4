# Kịch bản — Xem lại các từ (Review) · screen `review`

Nguồn: `docs/contracts/review.md` [browsing · editing · audio · end] ·
DOM `specs/review.md` · D-007, D-011 (D-013/D-014/D-020 gián tiếp) ·
BR `business/study/study-flow.md` (BR-1, BR-5 · UC-4) + `business/flashcard/flashcard-management.md` (UC-2, BR-2, BR-3, BR-5) ·
DB `cards`, `card_meanings`, `srs_state`, `review_logs`, `study_sessions`, `daily_activity`.

> Số/tên/chuỗi trong kit là MOCK ("학교", "school", "7/20", "Playing…", "All reviewed", "Study now") —
> assert **định dạng & nguồn**, KHÔNG assert giá trị mock. Chuỗi lấy từ ARB, không copy kit.
>
> **Bản chất màn:** `review` = lối vào **"Xem lại các từ"** (UC-4 study-flow) — luyện tập thuần:
> duyệt từng thẻ (term + nghĩa + audio), sửa nghĩa inline. **Không đổi SRS, không cộng hoạt động**
> (D-007 / BR-5) — đây là **assertion âm** (no-write) mạnh nhất của màn này.

## DoE — review (12 chiều)

| # | Chiều | TT | Scenario / N/A |
|---|---|---|---|
| 1 | States (4) | ✅ | SC-REVIEW-01..04 |
| 2 | Elements (12 tương tác) | ✅ | SC-REVIEW-10..25 (25 = caret) |
| 3 | Nav vào/ra | ✅ | SC-REVIEW-30..36 |
| 4 | Nhập liệu & validation (field sửa nghĩa) | ✅ | SC-REVIEW-40..47 (47 = gõ phím → Save enable/disable) |
| 5 | Lượng dữ liệu | ✅ | SC-REVIEW-50..54 |
| 6 | Async & lỗi | ✅ | SC-REVIEW-60..64 |
| 7 | Persistence (DB round-trip + no-write) | ✅ | SC-REVIEW-70..74 |
| 8 | Định dạng & i18n | ✅ | SC-REVIEW-80..84 |
| 9 | Dark mode | ✅ | SC-REVIEW-90 |
| 10 | Responsive | ✅ | SC-REVIEW-91 |
| 11 | A11y | ✅ | SC-REVIEW-92 |
| 12 | Concurrency & edge thời gian | ✅ | SC-REVIEW-95..98 |

Element inventory (từ DOM spec — mỗi cái ≥1 scenario ở mục 2):
`review/back` (icon-button arrow_back) · `review/text-size` (icon-button format_size) · `review/options`
(icon-button more_vert) · `review/progress` (thanh tiến độ + "N/M") · `review/edit` (icon-button edit ↔ close) ·
`review/audio` (icon-button volume_up ↔ graphic_eq) · `review/prev` (icon-button chevron_left) ·
`review/next` (icon-button chevron_right) · `review/edit-cancel` (btn Cancel) · `review/edit-save` (btn Save) ·
`review/study-now` (btn ở state end) · `review/back-deck` (btn ở state end) ·
caret editing (span `text: |`, color primary — SC-REVIEW-25).

---

## 1. States

### SC-REVIEW-01 — browsing (state gốc: duyệt thẻ)
Nguồn: contract[browsing] · spec base · UC-4 study-flow
Given:
  - DB: `decks`(1 "Korean"), `cards`(≥2, hidden=0, có `term`), `card_meanings`(mỗi card ≥1 nghĩa sort_index=0)
When: vào `/review/:nodeId` (mở "Xem lại các từ" từ menu Play tại nút)
Then:
  - UI: appbar (back + tiêu đề "Review"(ARB) + text-size + options) · thanh progress + nhãn "vị-trí/tổng" ·
    card MEANING (nhãn "MEANING"(ARB) + nút edit + nội dung nghĩa đầu tiên) · card TERM (term lớn + nút audio) ·
    hàng điều hướng (prev + "Swipe to continue"(ARB) + next). Không skeleton, không banner.
  - DB: KHÔNG ghi gì (đọc thuần).

### SC-REVIEW-02 — editing (sửa nghĩa inline)
Nguồn: contract[editing] · spec "editing" diff · flashcard UC-2 (sửa inline)
Given: đang browsing thẻ hiện tại
When: chạm nút `review/edit`
Then:
  - UI: nút edit → biến thành nút `close`(icon) cùng vị trí · vùng nghĩa chuyển thành **field nhập** (viền
    2px `primary`, r:12) chứa nội dung nghĩa hiện tại + con trỏ · xuất hiện 2 nút `Cancel`(text primary-strong)
    + `Save`(nền primary, chữ surface). Card TERM vẫn hiển thị.
  - DB: chưa ghi (chỉ ghi khi Save — xem SC-REVIEW-42).

### SC-REVIEW-03 — audio (đang phát âm term)
Nguồn: contract[audio] · spec "audio" diff · flashcard US-5/UC (đọc term qua TTS) · D-014 audio
Given: đang browsing; thiết bị có TTS
When: chạm nút `review/audio` (volume_up)
Then:
  - UI: icon nút audio đổi volume_up → `graphic_eq` (trạng thái đang phát) · xuất hiện nhãn "Playing…"(ARB,
    màu primary) dưới nút.
  - DB: KHÔNG ghi gì (TTS live; `cards.audio_ref` vẫn NULL — hoãn v1).
  ⚠ Xác nhận: audio state THOÁT khi nào (→ quay lại volume_up, nhãn biến mất)? spec `audio` chỉ là **trạng thái
    tĩnh** (graphic_eq + "Playing…"), KHÔNG định nghĩa trigger/thời điểm thoát. Auto khi TTS kết thúc, hay tap-again
    toggle? (liên quan SC-REVIEW-97) — Open questions, KHÔNG bịa transition.

### SC-REVIEW-04 — end (đã duyệt hết thẻ)
Nguồn: contract[end] · spec "end" diff
Given: đang ở thẻ cuối
When: chạm `review/next` (hoặc swipe) qua thẻ cuối
Then:
  - UI: thân màn thay bằng khối end: icon-tile `done_all` (nền success-soft) · tiêu đề "All reviewed"(ARB) ·
    phụ đề **từ ARB** (assert **nguồn = ARB**, KHÔNG chốt nội dung dịch cụ thể — spec chỉ có mock
    "You've gone through every card in this deck.") · 2 nút `Study now`(primary, icon school) +
    `Back to deck`(icon arrow_back, primary-strong). **Ẩn** progress/MEANING/TERM/hàng điều hướng (diff spec).
  - DB: KHÔNG ghi gì.
  ⚠ Xác nhận: sau thẻ cuối có auto-vào end, hay cần thao tác next? spec chỉ định nghĩa state, không định nghĩa trigger.

---

## 2. Elements (mỗi phần tử ≥1 scenario)

### SC-REVIEW-10 — Nút back (`review/back`)
Nguồn: spec `review/back` (icon-button arrow_back, mx:?)
When: chạm back
Then: pop khỏi `/review/:nodeId`, quay về màn nguồn (deck-detail của nút). DB: không ghi.

### SC-REVIEW-11 — Nút text-size (`review/text-size`)
Nguồn: spec `review/text-size` (icon-button format_size, mx:?)
When: chạm text-size
Then: ⚠ Xác nhận đích — không có trong D-xxx/business/study-flow. Kit không định nghĩa overlay/sheet cho nút này.
Assert tối thiểu: nút có semantic label, hit-area ≥48, không crash. (Chức năng thật ⇒ Open questions.)

### SC-REVIEW-12 — Nút options (`review/options`)
Nguồn: spec `review/options` (icon-button more_vert, mx:?)
When: chạm more_vert
Then: ⚠ Xác nhận đích — kit không định nghĩa menu items cho more_vert ở màn review (không có node menu/sheet trong spec).
Assert tối thiểu: nút có semantic label, hit-area ≥48, không crash. (Nội dung menu ⇒ Open questions, KHÔNG bịa item.)

### SC-REVIEW-13 — Thanh progress (`review/progress` + nhãn)
Nguồn: spec `review/progress` (track surface-sunken, fill primary) + span "7/20"
Given: đang ở thẻ thứ i / tổng N thẻ hiển thị
Then: thanh fill theo tỉ lệ vị-trí; nhãn hiển thị "i/N" (định dạng "hiện-tại/tổng", KHÔNG assert giá trị mock 7/20).
Biến thể: thẻ đầu (i=1) fill nhỏ nhất; thẻ cuối fill đầy nhất.
⚠ Xác nhận: progress đếm theo thẻ đã xem hay theo vị-trí con trỏ? N = tổng thẻ hiển thị (loại hidden theo D-006)?

### SC-REVIEW-14 — Nút edit (`review/edit`, edit ↔ close)
Nguồn: spec `review/edit` (icon-button edit → editing state đổi thành close)
When: chạm edit (browsing) → chạm close (editing)
Then: edit ⇒ vào editing (SC-REVIEW-02); close ⇒ thoát editing về browsing, **không lưu** thay đổi (giống Cancel).
DB: không ghi ở cả hai thao tác này.

### SC-REVIEW-15 — Nút audio (`review/audio`, volume_up ↔ graphic_eq)
Nguồn: spec `review/audio` (icon-button volume_up → audio state đổi thành graphic_eq + "Playing…")
When: chạm audio
Then: phát TTS term theo **ngôn ngữ nguồn của cặp** (flashcard: đọc term qua TTS theo source lang);
UI vào audio state (SC-REVIEW-03). DB: không ghi (audio_ref NULL v1).

### SC-REVIEW-16 — Nút prev (`review/prev`, chevron_left)
Nguồn: spec `review/prev` (icon-button chevron_left)
Given: đang ở thẻ i (i>1)
When: chạm prev
Then: về thẻ i-1; progress lùi; MEANING/TERM đổi theo thẻ i-1. DB: không ghi.
Biên: ở thẻ đầu (i=1) chạm prev ⇒ ⚠ Xác nhận: no-op / disabled / vòng lại? (spec không nêu).

### SC-REVIEW-17 — Nút next (`review/next`, chevron_right)
Nguồn: spec `review/next` (icon-button chevron_right)
Given: đang ở thẻ i (i<N)
When: chạm next
Then: sang thẻ i+1; progress tiến; nội dung đổi. DB: không ghi.
Biên: ở thẻ cuối (i=N) chạm next ⇒ vào state end (SC-REVIEW-04) — ⚠ cần xác nhận trigger (mục Open questions).

### SC-REVIEW-18 — Nút Cancel khi editing (`review/edit-cancel`)
Nguồn: spec `review/edit-cancel` (btn "Cancel")
Given: đang editing, đã gõ thay đổi vào field nghĩa
When: chạm Cancel
Then: UI thoát editing về browsing, hiển thị lại nghĩa **cũ** (bỏ thay đổi). DB: `card_meanings.content` **không đổi**.

### SC-REVIEW-19 — Nút Save khi editing (`review/edit-save`)
Nguồn: spec `review/edit-save` (btn "Save") · flashcard UC-2
Given: đang editing, field nghĩa hợp lệ (khác rỗng sau trim — BR-2/BR-3)
When: chạm Save
Then:
  - UI: thoát editing về browsing; vùng nghĩa hiển thị nội dung **mới**.
  - DB: `card_meanings.content` (dòng nghĩa đang sửa) = giá trị mới (đã trim). `srs_state` **không đổi** (D-007).
    KHÔNG tạo `review_logs`/`study_sessions`/`daily_activity`.

### SC-REVIEW-20 — Nút Study now (state end) (`review/study-now`)
Nguồn: spec `review/study-now` (btn "Study now", icon school)
Given: đang ở state end
When: chạm Study now
Then: ⚠ Xác nhận đích — không có dòng D-xxx nối review-end → study. Khả năng: mở `/study/:nodeId` (newLearn?) hoặc
Play menu. Assert tối thiểu: có điều hướng đi ra, semantic label, không crash. (Đích chính xác ⇒ Open questions.)

### SC-REVIEW-21 — Nút Back to deck (state end) (`review/back-deck`)
Nguồn: spec `review/back-deck` (btn "Back to deck", icon arrow_back)
Given: đang ở state end
When: chạm Back to deck
Then: pop về deck-detail của nút nguồn (giống back nhưng có nhãn tường minh). DB: không ghi.

### SC-REVIEW-22 — Appbar title
Nguồn: spec `review/appbar__title` (text "Review")
Then: hiển thị tiêu đề màn từ ARB (không copy "Review" mock); ellipsis nếu quá dài (clip trong spec).

### SC-REVIEW-23 — Card MEANING nhãn + nội dung
Nguồn: spec `review/meaning` (span "MEANING" + div "school")
Then: nhãn "MEANING"(ARB) hiển thị; nội dung = nghĩa đầu tiên (sort_index nhỏ nhất) của thẻ hiện tại.
⚠ Xác nhận: thẻ nhiều nghĩa hiển thị nghĩa nào ở review? (schema: "first meaning is primary" — dùng sort_index=0).

### SC-REVIEW-24 — Card TERM
Nguồn: spec `review/term` (div "학교" + nút audio)
Then: term hiển thị lớn, căn giữa; nội dung = `cards.term` thẻ hiện tại (không assert glyph mock).

### SC-REVIEW-25 — Con trỏ nhập liệu (caret) ở field editing
Nguồn: spec editing — node `span` `text: |` (rel:[74,15 7x22], `color:primary`) bên trong field nghĩa
Given: đang editing (SC-REVIEW-02), field nghĩa được focus
Then: hiển thị **con trỏ/caret** trong field nghĩa; caret dùng màu `primary` (đồng bộ viền field 2px primary).
Assert: caret hiển thị khi field focus, màu primary (không assert vị trí px mock [74,15]); khi blur field ⇒
⚠ Xác nhận caret ẩn/hiện (spec chỉ chụp caret ở trạng thái focus tĩnh, không định nghĩa blur — Open questions).

---

## 3. Điều hướng vào/ra

### SC-REVIEW-30 — Vào review từ Play menu
Nguồn: study-flow UC-1/UC-4 · navigation route `review` (`/review/:nodeId`, push)
Given: ở deck-detail của nút có ≥1 thẻ hiển thị
When: mở menu Play → chọn "Xem lại các từ"
Then: push `/review/:nodeId`, vào browsing với thẻ đầu tiên. Params `nodeId` = nút nguồn.

### SC-REVIEW-31 — Ra: back → deck-detail
Nguồn: spec `review/back` · SC-REVIEW-10
Then: pop 1 lần về deck-detail; giữ nguyên state deck-detail trước đó.

### SC-REVIEW-32 — Ra: Back to deck (state end)
Nguồn: spec `review/back-deck` · SC-REVIEW-21
Then: pop về deck-detail.

### SC-REVIEW-33 — Ra: Study now (state end)
Nguồn: spec `review/study-now` · SC-REVIEW-20
Then: điều hướng đi ra (⚠ đích cần chốt — Open questions).

### SC-REVIEW-34 — Nút cha đệ quy (parent node)
Nguồn: study-flow BR-6 / D-009 (học/duyệt tại nút cha gộp đệ quy cây con)
Given: vào review tại một bộ thẻ **cha** có bộ thẻ con
When: browsing
Then: hàng đợi duyệt gồm **đệ quy** thẻ hiển thị của mọi bộ thẻ con (loại hidden — D-006). DB: không ghi.
⚠ Xác nhận: review có áp D-009 (gộp cây con) như học/ôn không? (BR-6 nêu "học/ôn tại nút cha"; review là luyện tập).

### SC-REVIEW-35 — Back hệ thống (Android) tại review
When: nhấn back hệ thống ở browsing/editing/audio
Then: browsing ⇒ pop về deck-detail. editing ⇒ ⚠ Xác nhận: hủy edit (như Cancel) rồi ở lại, hay pop luôn?
(spec không nêu hành vi back khi có edit chưa lưu — Open questions, KHÔNG bịa).

### SC-REVIEW-36 — Giữ vị trí thẻ khi mở overlay TTS
Given: đang ở thẻ i, chạm audio (audio state)
When: audio phát xong
Then: vẫn ở thẻ i, browsing; không nhảy thẻ. DB: không ghi.

---

## 4. Nhập liệu & validation (field sửa nghĩa — chỉ hiện ở editing)

> Field duy nhất của màn: ô sửa **nghĩa** (`card_meanings.content`) ở state editing.
> Term KHÔNG sửa được ở màn này (DOM editing chỉ thay MEANING thành field, TERM giữ nguyên).

### SC-REVIEW-40 — Nghĩa rỗng / chỉ khoảng trắng
Nguồn: flashcard BR-2/BR-3 (nghĩa bắt buộc, không rỗng sau trim)
Given: editing, xoá sạch nội dung (hoặc chỉ nhập "   ")
When: chạm Save
Then: chặn lưu; hiện thông báo lỗi cụ thể (ARB, nội dung "nghĩa không được để trống" + vị trí gần field).
DB: `card_meanings.content` **không đổi**.
⚠ Xác nhận: kit editing KHÔNG có node thông báo lỗi inline — vị trí/nội dung lỗi cần chốt (Open questions).
⚠ Xác nhận: kịch bản này **giả định Save luôn enable rồi chặn-tại-Save**. DOM editing KHÔNG định nghĩa
disabled-state cho Save ⇒ lựa chọn hành vi (disable-khi-rỗng vs luôn-enable) **chưa chốt từ nguồn** — xem
SC-REVIEW-47 + Open questions. KHÔNG bịa disabled-state.

### SC-REVIEW-41 — Nghĩa quá dài (biên max)
Given: editing, dán chuỗi rất dài vào field nghĩa
When: Save
Then: ⚠ Xác nhận có giới hạn độ dài nghĩa không? (schema `card_meanings.content` TEXT, business không nêu max).
Nếu không giới hạn ⇒ lưu nguyên; UI wrap không vỡ layout (xem SC-REVIEW-84). KHÔNG bịa max.

### SC-REVIEW-42 — Nghĩa hợp lệ → Save round-trip
Nguồn: flashcard UC-2 · schema `card_meanings.content`
Given: editing, sửa nghĩa thành chuỗi hợp lệ (trim còn nội dung)
When: Save
Then: DB: `card_meanings.content` (dòng đang sửa) = giá trị đã **trim**; các cột khác của dòng (language,
sort_index, card_id) không đổi. UI: browsing hiển thị nghĩa mới.

### SC-REVIEW-43 — Nghĩa CJK (Hàn/Nhật)
Given: editing, nhập nghĩa chứa CJK (vd "학교" / "がっこう")
When: Save
Then: DB lưu đúng chuỗi CJK (không mất/hỏng byte); UI render đúng glyph (không tofu) sau khi lưu.

### SC-REVIEW-44 — Nghĩa ký tự đặc biệt / emoji
Given: editing, nhập nghĩa chứa emoji + ký tự đặc biệt (vd "school 🏫 (n.)")
When: Save
Then: DB lưu nguyên chuỗi; UI hiển thị đúng, không vỡ layout.

### SC-REVIEW-45 — Trim khoảng trắng đầu/cuối
Given: editing, nhập "  school  "
When: Save
Then: DB `card_meanings.content` = "school" (đã trim 2 đầu). UI hiển thị bản đã trim.

### SC-REVIEW-46 — Soft-dup (D-020) KHÔNG áp cho sửa nghĩa
Nguồn: D-020/BR-5 (soft-dup theo **term** trong deck), flashcard BR-3 (nghĩa là văn bản tự do)
Given: editing nghĩa trùng nội dung một thẻ khác
When: Save
Then: **không** cảnh báo trùng — D-020 chỉ áp cho `term`, không cho `content`. Lưu bình thường.
⚠ Xác nhận: đúng là review không sửa term nên D-020 không kích hoạt ở màn này (khẳng định no-warning).

### SC-REVIEW-47 — Gõ phím / đổi field → trạng thái nút Save
Nguồn: (chưa có nguồn — DOM editing chỉ có 1 state nút Save, KHÔNG có disabled-state)
Given: đang editing; thay đổi nội dung field nghĩa (gõ thêm ký tự, xoá về rỗng, hoặc trở lại giá trị ban đầu)
Then: ⚠ Xác nhận hành vi nút Save theo nội dung field: **có** disable Save khi field rỗng (sau trim) và enable
lại khi có nội dung? hay Save **luôn enable** rồi chặn-tại-Save (SC-REVIEW-40)? DOM editing KHÔNG định nghĩa
disabled-state cho Save ⇒ Open questions, KHÔNG bịa. Assert tối thiểu: gõ phím cập nhật nội dung field mượt,
không mất ký tự, không crash; nút Save vẫn hiển thị (chưa chốt enable/disable).
⚠ Phụ: nếu chốt "luôn enable" ⇒ SC-REVIEW-40 giữ nguyên; nếu chốt "disable khi rỗng" ⇒ SC-REVIEW-40 đổi thành
"Save disabled, không cần chặn-tại-Save".

---

## 5. Lượng dữ liệu

### SC-REVIEW-50 — 0 thẻ hiển thị
Given: nút chỉ có thẻ ẩn (hidden=1) hoặc rỗng
When: vào review
Then: ⚠ Xác nhận: hiện state `end` ngay ("All reviewed") hay một empty riêng? Kit không có state `empty` cho review.
Assert tối thiểu: không crash, không có thẻ nào để duyệt. (Hành vi chính xác ⇒ Open questions.)

### SC-REVIEW-51 — 1 thẻ hiển thị
Then: browsing thẻ duy nhất; progress "1/1"; next ⇒ vào end. prev ở thẻ này ⇒ biên (SC-REVIEW-16).

### SC-REVIEW-52 — Nhiều thẻ (N vừa)
Then: prev/next đi qua đủ N thẻ; progress cập nhật đúng "i/N"; sau thẻ N → end.

### SC-REVIEW-53 — Rất nhiều thẻ (biên lớn)
Given: nút có hàng nghìn thẻ hiển thị
Then: duyệt mượt (dựng hàng đợi < 100ms — study-flow §8); progress "i/N" với N lớn không tràn nhãn (xem SC-REVIEW-83).

### SC-REVIEW-54 — Thẻ ẩn loại khỏi hàng đợi duyệt (D-006)
Nguồn: D-006/BR-4 (thẻ ẩn loại khỏi hàng đợi + số đếm)
Given: nút có cả thẻ hiển thị và thẻ ẩn (hidden=1)
Then: hàng đợi duyệt & tổng N **chỉ** gồm thẻ hiển thị; thẻ ẩn không xuất hiện. DB: đọc lọc `hidden=0`.
⚠ Xác nhận: review dùng cùng quy tắc "hàng đợi hiển thị" như học (D-006) — cần chốt review có loại hidden không.

---

## 6. Async & lỗi

### SC-REVIEW-60 — Loading hàng đợi → browsing
Given: provider dựng hàng đợi thẻ chưa resolve
When: vào review
Then: ⚠ Kit review KHÔNG có state `loading` (chỉ 4 state: browsing/editing/audio/end).
Assert: trong lúc dựng hàng đợi hiển thị gì? (skeleton? khung trống?) — cần spec (Open questions). Không bịa skeleton.

### SC-REVIEW-61 — TTS thất bại (không có engine / lỗi phát)
Nguồn: flashcard (TTS thiết bị) · D-014
Given: thiết bị không có TTS / TTS lỗi
When: chạm audio
Then: ⚠ Kit không có state lỗi audio. Assert: không crash; thông báo lỗi nhẹ (ARB) nếu có; quay lại browsing.
(Nội dung/dạng thông báo lỗi TTS ⇒ Open questions.)

### SC-REVIEW-62 — Save nghĩa thất bại (ghi DB lỗi) + retry
Given: editing, Save nhưng ghi `card_meanings` thất bại (lỗi tầng data → Failure → AsyncValue.error)
When: Save
Then: ⚠ Kit không có state lỗi save. Assert: không mất nội dung đang gõ; hiện lỗi (ARB); cho **retry** Save.
DB: `content` không đổi cho tới khi ghi thành công. (Surface lỗi ⇒ Open questions.)

### SC-REVIEW-63 — Local-first (không mạng)
Nguồn: local-first (AGENTS.md — không backend v1)
Given: mất mạng
When: duyệt + sửa nghĩa + Save
Then: mọi thao tác chạy từ DB local; Save ghi `card_meanings` bình thường (không phụ thuộc mạng).
TTS: ⚠ tùy engine on-device (không mạng vẫn đọc) — xác nhận.

### SC-REVIEW-64 — Hủy TTS giữa chừng (đổi thẻ khi đang phát)
Given: audio state đang "Playing…", chạm next/prev
Then: TTS hiện tại dừng (hoặc chuyển thẻ mới), không chồng tiếng; UI về browsing của thẻ mới.
⚠ Xác nhận: đổi thẻ khi đang phát có tự dừng audio không? (spec không nêu).

---

## 7. Persistence (DB round-trip + no-write)

### SC-REVIEW-70 — Sửa nghĩa persist qua kill-relaunch
Nguồn: flashcard UC-2 · schema `card_meanings`
Given: sửa nghĩa + Save (SC-REVIEW-42)
When: kill app → mở lại → vào lại review/deck-detail thẻ đó
Then: DB `card_meanings.content` giữ giá trị mới; UI hiển thị nghĩa mới (round-trip đủ vòng).

### SC-REVIEW-71 — No-write: review KHÔNG đổi SRS (D-007)
Nguồn: D-007/BR-5 (Review/Game/Player không đổi SrsState)
Given: chụp snapshot `srs_state` (box, due_at, last_reviewed_at) của mọi thẻ trước khi vào review
When: duyệt qua hết thẻ (prev/next/audio, kể cả sửa nghĩa + Save)
Then: DB `srs_state` **y hệt** snapshot (không dòng nào đổi box/due_at/last_reviewed_at). **Assertion cốt lõi.**

### SC-REVIEW-72 — No-write: review KHÔNG tạo review_logs
Nguồn: D-007 (practice records no log) · schema `review_logs`
When: chạy trọn phiên review
Then: DB `review_logs` không thêm dòng nào (đếm trước = đếm sau).

### SC-REVIEW-73 — No-write: review KHÔNG tạo study_sessions / daily_activity
Nguồn: D-010/BR-5 (chỉ DueReview/NewLearn cộng phiên + hoạt động)
When: chạy trọn phiên review (kể cả kéo dài nhiều phút)
Then: DB `study_sessions` không thêm dòng; `daily_activity` (minutes/words) **không tăng**. Streak không bị ảnh hưởng.

### SC-REVIEW-74 — Sửa nghĩa không đụng cột SRS của thẻ
Given: Save nghĩa cho thẻ đang có `srs_state` (vd box=3, due_at set)
When: Save
Then: DB chỉ `card_meanings.content` đổi; `srs_state` của thẻ đó **nguyên vẹn** (box/due_at/last_reviewed_at).

---

## 8. Định dạng & i18n

### SC-REVIEW-80 — Nhãn progress "i/N" theo locale số
Given: đổi locale (vi/en/ja)
Then: nhãn "i/N" dùng định dạng số theo locale; không vỡ layout. (Nguồn số = vị-trí/tổng thật, không mock "7/20".)

### SC-REVIEW-81 — Term CJK render đúng
Given: thẻ có term Hàn/Nhật (vd "학교" / "学校")
Then: TERM render đúng glyph CJK (không tofu); font size lớn không cắt; audio đọc theo source lang.

### SC-REVIEW-82 — Nghĩa text dài → wrap
Given: nghĩa rất dài
Then: card MEANING wrap nhiều dòng, card cao lên, không tràn ngang; ở editing field cũng wrap.

### SC-REVIEW-83 — Progress N lớn không tràn nhãn
Given: N = 9999 (SC-REVIEW-53)
Then: nhãn "i/N" hiển thị đủ, không tràn/che thanh progress.

### SC-REVIEW-84 — Chuỗi ARB dài (nút/tiêu đề) khác ngôn ngữ
Given: locale có chuỗi dài (vd "Study now"/"Back to deck"/"All reviewed" bản dịch dài)
Then: nút state end + tiêu đề appbar wrap/ellipsis, không vỡ layout ở 320px.

---

## 9. Dark mode

### SC-REVIEW-90 — Mọi state ở dark
Nguồn: wireframe (mỗi state có shot light + dark)
Then: 4 state (browsing/editing/audio/end) render đúng ở dark (token, không hardcode màu): card surface,
progress primary/surface-sunken, field border primary, nút Save nền primary/chữ surface, icon-tile success-soft,
nhãn "Playing…" primary — contrast đạt ở cả light + dark.

---

## 10. Responsive

### SC-REVIEW-91 — 320px → tablet + xoay
Then: ở 320px không overflow (card MEANING/TERM, hàng prev/audio/next, cụm nút editing Cancel/Save,
2 nút state end) co giãn đủ; term lớn không tràn; xoay ngang cuộn được; safe-area/notch OK.

---

## 11. A11y

### SC-REVIEW-92 — Semantics
Then: back/text-size/options/edit/audio/prev/next/Cancel/Save/study-now/back-deck có semantic label; hit-area ≥48
(nút edit 36x36 trong DOM ⇒ ⚠ kiểm tra hit-area đạt 48 dù kích thước hiển thị nhỏ — cần đệm hit-area);
field sửa nghĩa có label + đọc được nội dung; thứ tự đọc: tiêu đề → progress → MEANING → TERM → điều hướng;
"i/N" đọc thành câu có nghĩa (không đọc rời).

---

## 12. Concurrency & edge thời gian

### SC-REVIEW-95 — Double-tap next
Given: browsing thẻ i
When: chạm next 2 lần thật nhanh
Then: chỉ tiến **1** thẻ (i→i+1), không nhảy 2 thẻ; ở thẻ cuối double-tap không vào end 2 lần / không crash.
⚠ Xác nhận: chống double-advance là yêu cầu ẩn — cần chốt.

### SC-REVIEW-96 — Double-tap Save
Given: editing hợp lệ
When: chạm Save 2 lần thật nhanh
Then: chỉ ghi `card_meanings.content` **một** lần (không double-write); về browsing một lần.

### SC-REVIEW-97 — Double-tap audio
Given: browsing
When: chạm audio 2 lần nhanh
Then: không chồng 2 luồng TTS; chỉ một "Playing…". ⚠ Xác nhận: tap lần 2 = dừng (toggle) hay bỏ qua?

### SC-REVIEW-98 — Edit chưa lưu + back/đổi thẻ
Given: editing, đã gõ thay đổi chưa Save
When: chạm prev/next (hoặc back)
Then: ⚠ Xác nhận: đổi thẻ khi đang edit dở → tự hủy edit (mất thay đổi) / chặn / hỏi xác nhận?
(spec không nêu — Open questions, KHÔNG bịa; đề xuất mặc định an toàn = hủy edit như Cancel, nhưng phải chốt.)

---

## Open questions (⚠ cần chốt spec trước khi viết test — KHÔNG bịa)

1. **State end trigger**: sau thẻ cuối, vào `end` tự động hay cần thao tác next/swipe? (spec định nghĩa state, không định nghĩa trigger).
1b. **Audio state trigger THOÁT**: audio state (graphic_eq + "Playing…") thoát khi nào — **auto khi TTS kết thúc**, hay **tap-again toggle**? spec `audio` chỉ là trạng thái tĩnh, không định nghĩa transition/thời điểm thoát (SC-REVIEW-03/15; liên quan double-tap SC-REVIEW-97).
2. **Nút text-size** (`review/text-size`): đích/chức năng khi tap? (kit không định nghĩa overlay).
3. **Nút options** (`review/options`, more_vert): menu gồm item gì? (kit không có node menu/sheet — KHÔNG bịa item).
4. **Study now** (state end): đích điều hướng (mở `/study/:nodeId` newLearn? Play menu? khác?).
5. **Progress ngữ nghĩa**: đếm theo thẻ đã xem hay vị-trí con trỏ? N = tổng thẻ hiển thị (đã loại hidden)?
6. **D-006 ở review**: review có loại thẻ ẩn khỏi hàng đợi như học/ôn không? (SC-REVIEW-54).
7. **D-009 ở review**: review tại nút cha có gộp đệ quy cây con không? (BR-6 nêu "học/ôn"; review là luyện tập — SC-REVIEW-34).
8. **Thẻ nhiều nghĩa**: review hiển thị nghĩa nào? (giả định first/sort_index=0 — cần xác nhận).
9. **Sửa nghĩa nhiều-nghĩa**: field editing sửa nghĩa nào (nghĩa đang hiển thị)? có sửa được nghĩa thứ 2+ không?
10. **Validation lỗi editing**: kit editing không có node thông báo lỗi — nội dung + vị trí lỗi (rỗng/quá dài) hiển thị ở đâu?
10b. **Trạng thái nút Save theo field**: Save có **disable khi field rỗng** (sau trim) rồi enable lại khi có nội dung, hay **luôn enable** rồi chặn-tại-Save (SC-REVIEW-40)? DOM editing KHÔNG có disabled-state cho Save (SC-REVIEW-47).
10c. **Phụ đề state end (nội dung dịch)**: chỉ chốt **nguồn = ARB**; nội dung dịch cụ thể do BA/l10n quyết (spec chỉ có mock "You've gone through every card in this deck." — SC-REVIEW-04).
10d. **Caret editing khi blur**: caret (span `text: |`, primary) chỉ được spec chụp ở trạng thái focus tĩnh — ẩn/hiện khi field mất focus như thế nào? (SC-REVIEW-25).
11. **Giới hạn độ dài nghĩa**: có max không? (schema/business không nêu — SC-REVIEW-41).
12. **State loading**: dựng hàng đợi hiển thị gì? (kit không có `loading` — SC-REVIEW-60).
13. **Lỗi TTS / lỗi Save**: kit không có state lỗi — surface lỗi + retry ở đâu? (SC-REVIEW-61/62).
14. **0 thẻ hiển thị**: hiện `end` ngay hay empty riêng? (kit không có `empty` — SC-REVIEW-50).
15. **Back tại thẻ đầu (prev)** và **next tại thẻ cuối**: no-op/disabled/vòng lại/vào end? (biên điều hướng).
16. **Edit chưa lưu + đổi thẻ/back**: hủy / chặn / hỏi xác nhận? (SC-REVIEW-35/98).
17. **Đổi thẻ khi đang phát audio**: có tự dừng TTS không? (SC-REVIEW-64).
18. **Chống double-tap next/audio**: yêu cầu ẩn — cần chốt (SC-REVIEW-95/97).

> Các mục ⚠ ở trên là **danh sách phải hỏi BA/spec**, không được đoán. Khi có câu trả lời → cập nhật scenario
> tương ứng + xoá cờ ⚠. Đây chính là "không bỏ sót": phần chưa rõ được **liệt kê ra**, không lờ đi.
