# Kịch bản — Card Editor (Tạo / Sửa thẻ) · screen `flashcard-editor`

Nguồn: `docs/contracts/flashcard-editor.md` [audio · create · duplicate · edit · multi-meaning · validation] ·
DOM `specs/flashcard-editor.md` · code thực `lib/presentation/features/flashcard-editor/` (screen +
`providers/editor_providers.dart` + `widgets/dup_banner.dart`) · ARB `lib/l10n/app_en.arb` (`editor*`) ·
D-006, D-011, D-020, **D-024** (cascade khi xoá deck cha, SC-75), **D-028** (thẻ ẩn VẪN trong search —
hệ quả trực tiếp của cột `hidden` do editor ghi, SC-23) · D-002/D-017 gián tiếp (thẻ mới tạo = box 0/new) ·
BR `business/flashcard/flashcard-management.md` (BR-1..BR-6, AC-1..AC-3; **status = Implemented**, TTS đọc
term đã ship, chỉ file-audio `card.audio_ref` hoãn) · DB `cards`, `card_meanings`, `srs_state`, `decks`,
`language_pairs`, `settings`.

> Số/tên/chuỗi trong kit là MOCK ("안녕하세요", "Hello (formal)…", "xin chào", "Term (Korean)",
> "Meaning (English)", "Secondary meaning (Vietnamese)") — assert **định dạng, cấu trúc & nguồn**,
> KHÔNG assert giá trị mock. Chuỗi lấy từ ARB (`editor*`, `gender*`, `editorCancel`/`editorSave`),
> không copy kit. Nhãn ngôn ngữ trường term/meaning suy từ **cặp ngôn ngữ đang chọn** (S0), không hardcode.
> ⚠ **KHÔNG có key ARB `comingSoon`** (grep `lib/l10n/app_en.arb` = 0 hit) và màn KHÔNG tham chiếu nó —
> đừng assert chuỗi `comingSoon` như thể có thật.

> ⚠ **Mâu thuẫn nguồn — audio KHÔNG hoãn ở build hiện tại (đảo lại claim cũ).** Ba nguồn xung đột:
> (a) `business/flashcard/flashcard-management.md` dòng 9 (status = *Implemented*): "**đọc term qua TTS**
> (`TtsService`/flutter_tts) ở editor + trình phát… **Sinh & lưu file audio (`card.audio_ref`) vẫn hoãn**" —
> chỉ **file-audio** hoãn, đọc TTS **KHÔNG** hoãn. (b) Code thực `providers/editor_providers.dart`
> `playAudio()` gọi `ref.read(audioServiceProvider).speak(data.term, languageCode:'ko')` → **phát TTS THẬT
> tức thì**, KHÔNG `comingSoon`, KHÔNG async-generating; icon là `Icons.volume_up` **tĩnh** (không đổi
> `sync`). (c) `design/screens/05-flashcard-editor.md` (S.12) + DOM spec vẽ state `audio` (icon `sync`,
> "Generating from term…") — nhưng đó là **kit MOCK/spec-đích cũ**, không khớp build. → Scenario **KHÔNG**
> assert `comingSoon`/audio-hoãn; hành vi thực = live-speak. State kit `audio(sync)` xử lý ở Open-questions
> (Open-q 5) là **spec-đích có thể undrivable**, không phải build hiện tại.

> ⚠ **"Xem thẻ đã có" (dup-view) — thuộc spec-đích, KHÔNG có trong build.** Widget thực `widgets/dup_banner.dart`
> chỉ render `MxActionCallout(icon: warning_amber, text: l10n.editorDupWarning)` — **1 callout tĩnh, KHÔNG
> nút nào** (không `dup-view`, không `dup-add`), và text = ARB `editorDupWarning` = "A card with this term
> already exists in this deck." → **chuỗi tĩnh 'this term', KHÔNG có placeholder `<term>`**. DOM spec kit
> (state `duplicate`) CÓ `dup-view`/`dup-add` + `<term>` nội suy — đó là **spec-đích chưa build**. Scenario
> phân biệt rõ: **build hiện tại = banner-không-nút, không `<term>`**; 2-nút + `<term>` = spec-đích (Open-q).

## DoE — flashcard-editor (12 chiều)

| # | Chiều | TT | Scenario / N/A |
|---|---|---|---|
| 1 | States (6) | ✅ | SC-FLASHCARDEDITOR-01..06 |
| 2 | Elements (12 tương tác) | ✅ | SC-FLASHCARDEDITOR-10..24 |
| 3 | Nav vào/ra | ✅ | SC-FLASHCARDEDITOR-30..36 |
| 4 | Nhập liệu & validation (2 field bắt buộc + 1 field phụ; **touched-gating**) | ✅ | SC-FLASHCARDEDITOR-40..49 (touched: 40a/42a) |
| 5 | Lượng dữ liệu (số meaning, độ dài) | ✅ | SC-FLASHCARDEDITOR-50..53 |
| 6 | Async & lỗi (lưu / audio) | ✅ | SC-FLASHCARDEDITOR-60..64 |
| 7 | Persistence (DB round-trip) | ✅ | SC-FLASHCARDEDITOR-70..75 |
| 8 | Định dạng & i18n | ✅ | SC-FLASHCARDEDITOR-80..84 |
| 9 | Dark mode | ✅ | SC-FLASHCARDEDITOR-90 |
| 10 | Responsive | ✅ | SC-FLASHCARDEDITOR-91 |
| 11 | A11y | ✅ | SC-FLASHCARDEDITOR-92 |
| 12 | Concurrency & edge thời gian | ✅ | SC-FLASHCARDEDITOR-95..98 |

**Element inventory** (từ DOM spec — mỗi cái ≥1 scenario ở mục 2):
`cancel` (btn appbar-lead "Cancel") · `appbar__title` (hiển thị "New card" / "Edit card") ·
`save` (btn appbar-trail, disabled/enabled qua opacity 0.45 ↔ shadow) · `term` (field bắt buộc, dấu `*`) ·
`meaning` (field bắt buộc đa dòng, dấu `*`) · `add-meaning` (btn "+ Add a secondary-language meaning") ·
`meaning-2` (khối nghĩa phụ ở state multi-meaning; **build hiện tại: nhãn ARB `editorSecondaryLabel`, ngôn
ngữ hardcode `vi` — bộ chọn ngôn ngữ HOÃN**, xem SC-05) · `gender` group = `gender-0..3` (chip
None/Masc/Fem/Neutral, chọn-loại-trừ) · `audio` field (value ARB `editorAudioAuto`) + `audio-play`
(icon-button **`Icons.volume_up` tĩnh** — build hiện tại phát TTS live; icon `sync` là spec-đích kit,
không xuất hiện) · `hidden` card + `hidden-switch` (switch Ẩn; title ARB `editorHideTitle`="Hide card",
sub ARB `editorHideSub`=**"Won't show during study **or** review"** — dùng **"or"**, KHÔNG "/"; kit MOCK
ghi "/" nhưng phải trích ARB) · `dup-warning` banner.
> ⚠ **Build hiện tại — `dup-view`/`dup-add` KHÔNG tồn tại.** `widgets/dup_banner.dart` = `MxActionCallout`
> (icon + text ARB) **1 callout không nút**. 2 nút `dup-view`("View existing") + `dup-add`("Add anyway") là
> **spec-đích DOM** (Open-q 5). Scenario chạm 2 nút này assert **spec-đích**, không phải build.

---

## 1. States (mỗi state đến được qua ≥1 scenario)

### SC-FLASHCARDEDITOR-01 — create (form rỗng, thẻ mới)
Nguồn: contract[create] · spec base · BR-2 · UC-1
Tiền điều kiện (Given):
  - DB: `language_pairs`(1 hàng active) · `decks`(1 "deck-X" thuộc pair) · chưa mở editor.
Thao tác (When):
  1. Từ deck-detail của "deck-X" → chạm hành động "Thêm từ" → mở `flashcard-editor` state create.
Kỳ vọng (Then):
  - UI: appbar title = ARB "New card" (kit MOCK "New card"); `cancel` hiển thị; `save` **mờ/disabled**
    (kit: `op:0.45`) vì thiếu term+meaning · trường term có placeholder (ARB, kit MOCK "Enter a word…")
    + dấu `*` bắt buộc · trường meaning đa dòng có placeholder + dấu `*` · `add-meaning` · gender chip
    (mặc định `gender-0` "None" selected = `bg:primary-soft`) · audio field (ARB `editorAudioAuto`) +
    `audio-play` (`volume_up`) · card Ẩn với `hidden-switch` OFF.
  - UI (**touched-gating — có nguồn trong code**): ở form rỗng **vừa mở, CHƯA có dòng lỗi**
    "Term/Meaning is required". Code chỉ hiện lỗi khi `termTouched && term.trim().isEmpty` (tương tự
    meaning) — `*` bắt buộc luôn hiển thị, **dòng lỗi thì KHÔNG** cho tới khi field bị chạm rồi bỏ trống
    (hoặc bấm Save). Assert: state create rỗng ⇒ 0 dòng lỗi. (Xem SC-40a/42a.)
  - DB: **chưa** ghi gì (`cards`/`card_meanings` không thêm hàng cho tới khi Save).

### SC-FLASHCARDEDITOR-02 — edit (mở thẻ đã có, đã điền)
Nguồn: contract[edit] · spec diff `edit` · UC-2
Given:
  - DB: `cards`(id=C1, deck=deck-X, term="안녕하세요" [MOCK], hidden=0) · `card_meanings`(C1: language=native, content="Hello…" [MOCK], sort_index=0) · `srs_state`(C1: box=k, due_at=D).
When:
  1. Mở editor cho thẻ C1 (từ deck-detail / khi ôn) → state edit.
Kỳ vọng (Then):
  - UI: appbar title = ARB "Edit card" (kit MOCK "Edit card") · term field hiện giá trị thật (màu `text`,
    không phải placeholder `text-tertiary`) · meaning field hiện content thật · `save` **sáng/enabled**
    (kit: `shadow:8/18`, không `op:0.45`) vì đã đủ trường.
  - DB: chưa đổi (chỉ đọc để prefill).

### SC-FLASHCARDEDITOR-03 — validation (bấm Save khi thiếu trường bắt buộc)
Nguồn: contract[validation] · spec diff `validation` · BR-2 · AC-3
Given: state create/edit, term rỗng HOẶC meaning rỗng.
When:
  1. Bấm `save`.
Kỳ vọng (Then):
  - UI: **không rời màn** · trường thiếu đổi viền `border:1px error` · hiện dòng lỗi dưới trường:
    term → ARB "Term is required" (kit MOCK "Term is required"); meaning → ARB "Meaning is required"
    (kit MOCK "Meaning is required") — màu `error`, vị trí ngay dưới ô tương ứng · body cho phép cuộn
    (kit đặt `scrollh:753`).
  - DB: **không** ghi `cards`/`card_meanings`.
  - ⚠ Xác nhận copy chính xác trong ARB (`editor*`) — kit MOCK, không copy nguyên văn.

### SC-FLASHCARDEDITOR-04 — duplicate (term trùng trong cùng deck → cảnh báo mềm)
Nguồn: contract[duplicate] · spec diff `duplicate` · D-020 · BR-5 · AC-2
Given:
  - DB: `decks`(deck-X) đã có `cards`(term="안녕하세요" [MOCK]) trong ĐÚNG deck-X.
When:
  1. Trong editor (deck-X), nhập term trùng "안녕하세요" (khớp term một thẻ đã có cùng deck).
Kỳ vọng (Then — **build hiện tại**, khớp `widgets/dup_banner.dart` + ARB):
  - UI: hiện banner `dup-warning` = `MxActionCallout(icon: warning_amber, text: editorDupWarning)`.
    Text = ARB `editorDupWarning` = **"A card with this term already exists in this deck."** — **chuỗi
    TĨNH** (dùng "this term", **KHÔNG** placeholder `<term>`, **KHÔNG** nội suy term đang gõ). Assert text
    khớp ARB nguyên văn, đổi theo locale.
  - UI: **KHÔNG có nút** trên banner (không `dup-view`, không `dup-add`). `save` **vẫn enabled** (KHÔNG chặn
    lưu — D-020): trùng chỉ set cờ `duplicate=true` để hiện callout, không đụng `canSave`.
  - DB: chưa ghi (cảnh báo mềm, chờ người dùng bấm Save như thường).
  - Then (**spec-đích DOM — CHƯA build**, để so sánh, KHÔNG assert ở build hiện tại): kit vẽ message có
    `<term>` nội suy + 2 nút `dup-view`("View existing")/`dup-add`("Add anyway"). Đây là Open-q 5.
  - ⚠ Xác nhận phạm vi so trùng: code gọi `DetectDuplicateTermUseCase(deckId, term, excluding: cardId)` —
    chỉ **cùng deck** (BR-5), loại chính thẻ đang sửa; hoa-thường/chuẩn hoá Unicode xem Open-q 4.

### SC-FLASHCARDEDITOR-05 — multi-meaning (thêm nghĩa ngôn ngữ phụ)
Nguồn: contract[multi-meaning] · spec diff `multi-meaning` · BR-3
Given: editor state edit/create có term + nghĩa mẹ đẻ đã điền.
When:
  1. Chạm `add-meaning`.
Kỳ vọng (Then — **build hiện tại**, khớp `showSecondary()` + screen):
  - UI: xuất hiện khối nghĩa phụ `meaning-2` = `Field(label: editorSecondaryLabel, placeholder:
    editorSecondaryPlaceholder)` + ô nhập · body dài hơn · gender + audio + hidden vẫn dưới cùng.
  - UI (**KHÔNG có bộ chọn ngôn ngữ**): code hardcode `_secondaryLanguage = 'vi'` (const trong
    `editor_providers.dart` dòng 17, comment dòng 15 "per-pair language selection is deferred — gap").
    Không có widget picker/endonym nào render. Assert: **không** có dropdown/picker ngôn ngữ cho nghĩa phụ.
  - DB: khi Save (nếu secondary không rỗng) → `card_meanings` có **2 hàng** cho cùng `card_id`: hàng 0
    `language='en'` (primary), hàng 1 `language='vi'` (secondary hardcode), `sort_index` 0→1.
  - ⚠ **Mâu thuẫn nguồn (S.12 vs code):** `design/screens/05-flashcard-editor.md` dòng 37 nói
    "thêm nghĩa phụ **kèm bộ chọn ngôn ngữ** (endonym, `supported_languages.dart`)" — tức spec **CÓ** picker;
    nhưng code **KHÔNG** có (hardcode `vi`, đánh dấu "deferred — gap"). Không assert picker như thật;
    picker + language-per-pair (primary hardcode `en` chứ chưa lấy từ pair active) ở Open-q 3 + Open-q 10.

### SC-FLASHCARDEDITOR-06 — audio (phát TTS live — ĐÃ SHIP)
Nguồn: code `editor_providers.dart` `playAudio()` · `business/flashcard-management.md` dòng 9 (status
Implemented, "đọc term qua TTS `TtsService`/flutter_tts"; chỉ file-audio hoãn) · schema-contract §Deferred
(`card.audio_ref` hoãn)
Given: editor có term đã điền.
When:
  1. Chạm `audio-play` (icon `Icons.volume_up`, semanticLabel ARB `editorAudioPlay`).
Kỳ vọng (Then — **build hiện tại = live-speak, KHÔNG comingSoon**):
  - Hành vi: gọi `audioServiceProvider.speak(data.term, languageCode: 'ko')` → **phát TTS THẬT tức thì**.
    Nếu term rỗng ⇒ no-op (guard `data.term.trim().isEmpty`). Lỗi speak ⇒ **chỉ** `logger.error` (không
    surface UI). **KHÔNG** hiển thị `comingSoon`, **KHÔNG** trạng thái "Generating…", **KHÔNG** đổi icon.
  - UI: icon `audio-play` **tĩnh `volume_up`** suốt — không đổi `sync`.
  - DB: `card.audio_ref` **giữ NULL** ở v1 (chỉ **sinh & lưu file audio** hoãn; TTS live không lưu file).
  - ⚠ `languageCode` hardcode `'ko'` (const `_termSpeakLanguage`, comment "documented gap") — chưa lấy từ
    ngôn ngữ nguồn của pair active. Xem Open-q 10.
  - ⚠ State kit `audio(sync)` / "Generating from term…" là **spec-đích/kit MOCK cũ**, KHÔNG có nhánh nào
    trong live-speak để dựng (speak tức thì, không async-generating hiển thị) → **undrivable**, Open-q 5.

---

## 2. Elements (mỗi phần tử tương tác ≥1 scenario)

### SC-FLASHCARDEDITOR-10 — `cancel` (nút Huỷ)
Nguồn: spec `flashcard-editor/cancel` (btn, mx:?, text "Cancel")
When: chạm `cancel`.
Then:
  - UI: đóng editor, quay về màn gọi (deck-detail / ôn) mà **không lưu**.
  - DB: không ghi.
  - ⚠ Xác nhận: nếu form đã sửa (dirty) → có dialog xác nhận bỏ thay đổi không? DOM spec KHÔNG có
    confirm-dialog → liệt kê Open questions (không bịa).

### SC-FLASHCARDEDITOR-11 — `appbar__title` (tiêu đề theo chế độ)
Nguồn: spec `appbar__title` (create="New card" / edit,validation,duplicate,multi-meaning,audio="Edit card")
Then: create ⇒ ARB "New card"; các state còn lại (mở thẻ có sẵn) ⇒ ARB "Edit card". Assert **nguồn ARB**
+ đổi theo chế độ, không hardcode chuỗi kit.

### SC-FLASHCARDEDITOR-12 — `save` disabled (thiếu trường bắt buộc)
Nguồn: spec `save` create (`bg:primary op:0.45`) · BR-2
Given: term rỗng hoặc meaning rỗng.
Then:
  - UI: `save` ở trạng thái **disabled thật** (`onPressed: null`, không chỉ mờ) — chạm không có tác dụng;
    style opacity giảm (kit `op:0.45`).
  - DB: không ghi.

### SC-FLASHCARDEDITOR-13 — `save` enabled → lưu thành công (create)
Nguồn: spec `save` edit (`bg:primary shadow:8/18`) · UC-1 · BR-1/BR-2 · D-002 gián tiếp
Given: create, đã nhập term hợp lệ + nghĩa mẹ đẻ hợp lệ, đang ở deck-X.
When: chạm `save`.
Then:
  - UI: `save` enabled (shadow) · lưu xong đóng editor, về màn gọi; thẻ mới hiện trong deck.
  - DB: `cards` +1 hàng (`deck_id`=deck-X, `term`=giá trị trim, `hidden`=0, `audio_ref`=NULL,
    `grammatical_gender`= giá trị chip đã chọn hoặc NULL nếu "None", `created_at` set) ·
    `card_meanings` +1 hàng (`card_id`=thẻ mới, `language`= ngôn ngữ mẹ đẻ của pair, `content`=trim,
    `sort_index`=0) · `srs_state` **KHÔNG** tạo hàng (thẻ mới = box 0/new, D-017: unscheduled, due_at NULL).
  - ⚠ Xác nhận: thẻ mới có ghi `srs_state` box=0 hay **không có hàng**? schema-contract nói "Absent/box 0 =
    brand-new" ⇒ ưu tiên KHÔNG có hàng; cần chốt.

### SC-FLASHCARDEDITOR-14 — `save` enabled → lưu thành công (edit, cập nhật nội dung)
Nguồn: spec `save` edit · UC-2 · BR-1..BR-3 · D-011
Given: edit thẻ C1, đổi meaning content.
When: chạm `save`.
Then:
  - UI: đóng editor, nội dung mới phản ánh.
  - DB: `cards`(C1).term/hidden/gender cập nhật đúng · `card_meanings`(C1) content cập nhật ·
    `srs_state`(C1) **KHÔNG đổi** (box/due_at/last_reviewed_at giữ nguyên — UC-2 hậu điều kiện "SRS không
    thay đổi"; D-011 một chiều duy nhất).

### SC-FLASHCARDEDITOR-15 — `term` field (nhập/prefill)
Nguồn: spec `flashcard-editor/term` (label + `*` error + input)
Then: gõ → text màu `text` thay placeholder `text-tertiary`; dấu `*` luôn hiển thị (bắt buộc). Xem
validation ở mục 4.

### SC-FLASHCARDEDITOR-16 — `meaning` field (đa dòng, prefill)
Nguồn: spec `flashcard-editor/meaning` (minh:74, đa dòng, `*`)
Then: ô cao hơn term (đa dòng), nhập nhiều dòng/ghi chú được; dấu `*` bắt buộc. Xem validation mục 4.

### SC-FLASHCARDEDITOR-17 — `add-meaning` (thêm nghĩa phụ)
Nguồn: spec `flashcard-editor/add-meaning` (btn "+ Add a secondary-language meaning") · BR-3
When: chạm → xem SC-FLASHCARDEDITOR-05 (state multi-meaning).
Then: thêm 1 khối nghĩa phụ; có thể thêm nhiều (kit `repeat: x5+`). ⚠ Xác nhận: có nút xoá 1 khối nghĩa
phụ không? DOM spec KHÔNG liệt kê nút remove → Open questions.

### SC-FLASHCARDEDITOR-18..21 — `gender-0..3` (chip None/Masc/Fem/Neutral, chọn-loại-trừ)
Nguồn: spec `flashcard-editor/gender-0..3` (chip, mx:?, selected = `bg:primary-soft color:on-primary-soft`,
unselected = `bg:surface color:text-secondary`) · label "Gender (optional)"
When: chạm lần lượt từng chip.
Then:
  - UI: chip đang chọn đổi sang style selected; các chip khác về unselected (chọn-loại-trừ, radio semantics).
    Mặc định "None" (`gender-0`) selected (`data.gender == null`).
  - DB (**giá trị lưu cụ thể — KIỂM CHỨNG ĐƯỢC, không phải open-question**): screen map option
    `(null, None)/('masc', Masc)/('fem', Fem)/('neutral', Neutral)` → `setGender(value)` lưu **chuỗi thường**.
    Sau Save: `cards.grammatical_gender` ∈ **{ NULL, 'masc', 'fem', 'neutral' }** — None ⇒ **NULL**;
    Masc/Fem/Neutral ⇒ `'masc'`/`'fem'`/`'neutral'` (lowercase). schema-contract: `cards.grammatical_gender`
    = TEXT nullable, enum "stored as stable string name". Assert đúng 4 giá trị này.
  - ⚠ Còn ngỏ (Open-q 2): danh sách gender **cố định 4** hay theo ngôn ngữ? (tập giá trị ở trên là của build
    hiện tại — const `editorGenders = ['masc','fem','neutral']`.)

### SC-FLASHCARDEDITOR-22 — `audio-play` (icon-button phát TTS)
Nguồn: spec `flashcard-editor/audio-play` (icon-button volume_up) · code `playAudio()`
When: chạm.
Then: xem SC-FLASHCARDEDITOR-06 — build hiện tại **phát TTS live** (`speak(term, 'ko')`), icon `volume_up`
tĩnh, KHÔNG `comingSoon`, KHÔNG state `sync`. `audio_ref` giữ NULL v1 (chỉ file-audio hoãn).

### SC-FLASHCARDEDITOR-23 — `hidden-switch` (công tắc Ẩn)
Nguồn: spec `flashcard-editor/hidden-switch` (switch) + ARB `editorHideTitle`/`editorHideSub` · D-006 ·
D-028 · BR-4
When: bật switch ON rồi Save.
Then:
  - UI: switch chuyển ON; nhãn = ARB `editorHideTitle` = "Hide card"; phụ đề = ARB `editorHideSub` =
    **"Won't show during study or review"** — assert theo **ARB (dùng "or")**, KHÔNG copy kit MOCK "study /
    review" (CLAUDE.md #3: strings-from-ARB).
  - DB: `cards.hidden` = 1.
  - Hệ quả (kiểm ở luồng khác — **D-006 + D-028**): thẻ ẩn bị loại khỏi hàng đợi học + số "đến hạn"
    (D-006/BR-4), **nhưng D-028: thẻ ẩn VẪN xuất hiện trong search** — đây là hệ quả **trực tiếp** của cột
    `hidden` do editor ghi (search không lọc `hidden`). (assert tối thiểu ở đây: cột `hidden`=1 round-trip;
    hệ quả queue/search kiểm ở luồng tương ứng.)

### SC-FLASHCARDEDITOR-24 — `dup-view` + `dup-add` (nút trên banner trùng — **SPEC-ĐÍCH, CHƯA BUILD**)
Nguồn: spec `flashcard-editor/dup-view` ("View existing") + `flashcard-editor/dup-add" ("Add anyway") · D-020
> ⚠ **Build hiện tại KHÔNG có 2 nút này.** `widgets/dup_banner.dart` = `MxActionCallout` không nút (xem
> Element-inventory + SC-04). Cả SC này là **spec-đích DOM**, test sẽ đỏ tới khi build. Ở build hiện tại,
> luồng "lưu bất chấp trùng" đạt được bằng cách **bấm `save` bình thường** (save không bị `duplicate` chặn).
When (spec-đích): ở state duplicate, chạm từng nút.
Then (spec-đích):
  - `dup-add` → tiếp tục lưu thẻ mới **bất chấp trùng** (D-020 không chặn): `cards` +1 hàng cùng term
    trong cùng deck (KHÔNG có unique constraint `(deck_id, term)` — schema-contract §cards). **Build hiện
    tại tương đương**: bấm `save` khi banner trùng đang hiện → vẫn lưu (SC-73 kiểm DB).
  - `dup-view` → điều hướng tới thẻ đã có / danh sách thẻ. **CHƯA build** (chờ màn danh sách thẻ / W6);
    không có `comingSoon` (không có key ARB đó). ⚠ Open-q 5.

---

## 3. Điều hướng vào/ra

### SC-FLASHCARDEDITOR-30 — Vào từ deck-detail "Thêm từ" → create
Nguồn: UC-1 tiền điều kiện ("đang trong một bộ thẻ") · design-05 layout
Then: mở editor **create** với `deck_id` = deck đang mở; appbar "New card".

### SC-FLASHCARDEDITOR-31 — Vào từ danh sách thẻ / khi ôn (inline) → edit
Nguồn: UC-2/UC-3 ("mở thẻ kể cả inline khi đang duyệt/ôn")
Then: mở editor **edit** với thẻ đang chọn; appbar "Edit card". ⚠ Xác nhận entry point inline khi ôn
(overlay/pushed?) — DOM spec ghi "pushed/overlay" ở contract; cần chốt cụ thể.

### SC-FLASHCARDEDITOR-32 — Ra: `cancel` → về màn gọi không lưu
Nguồn: spec `cancel`
Then: pop editor, DB không đổi. (Dirty-confirm: xem SC-FLASHCARDEDITOR-10 ⚠.)

### SC-FLASHCARDEDITOR-33 — Ra: `save` thành công → về màn gọi
Nguồn: spec `save`
Then: pop editor sau khi ghi DB (xem SC-FLASHCARDEDITOR-13/14).

### SC-FLASHCARDEDITOR-34 — Back hệ thống / swipe-dismiss
Nguồn: contract "pushed/overlay"
When: nhấn back hệ thống (Android) / swipe-down (overlay).
Then: tương đương `cancel` (đóng không lưu). ⚠ Xác nhận: back khi form dirty → confirm? (giống mục 10).

### SC-FLASHCARDEDITOR-35 — `dup-view` → điều hướng ra (**spec-đích, chưa build**)
Nguồn: spec `dup-view` · D-020
Then: (đích) push tới thẻ đã có; (**build hiện tại KHÔNG có nút `dup-view`** — banner không nút, xem SC-24).
Back quay lại editor giữ nội dung đang nhập. ⚠ Open-q 5.

### SC-FLASHCARDEDITOR-36 — Giữ nội dung khi quay lại editor
Given: đang nhập dở, push ra (vd dup-view) rồi back.
Then: editor giữ nguyên nội dung đã nhập + trạng thái field (không mất). ⚠ Phụ thuộc dup-view build được.

---

## 4. Nhập liệu & validation (mỗi field: rỗng · khoảng trắng · quá dài · ký tự đặc biệt/emoji · CJK · trùng · trim)

> 2 field bắt buộc: **term**, **meaning (mẹ đẻ)**. Field phụ: **meaning-2** (nghĩa phụ). Gender = chip
> (không nhập chữ). Audio = read-only field.

### SC-FLASHCARDEDITOR-40 — term rỗng → lỗi (sau khi Save / đã touched)
Nguồn: BR-2 · AC-3 · state validation · code `error: termTouched && term.trim().isEmpty`
When: để term rỗng, Save (hoặc chạm rồi bỏ trống ⇒ `termTouched=true`).
Then: UI viền `error` + "Term is required" (ARB `editorTermRequired`); DB không ghi.

### SC-FLASHCARDEDITOR-40a — touched-gating term (**có nguồn code — chưa chạm ⇒ chưa lỗi**)
Nguồn: code screen dòng `error: data.termTouched && data.term.trim().isEmpty ? editorTermRequired : null`
Given: state create vừa mở, term rỗng, **chưa chạm** term (`termTouched=false`).
Then:
  - UI: **KHÔNG** hiện dòng lỗi "Term is required" (dù rỗng) — dấu `*` bắt buộc vẫn hiện, nhưng dòng lỗi bị
    gate bởi `termTouched`. Chỉ sau khi người dùng **chạm** field (setTerm ⇒ `termTouched=true`) rồi để rỗng,
    HOẶC bấm Save (screen `_save` gọi `save()`; nếu `!canSave` không pop, và các field touched-hoá qua tương
    tác) ⇒ dòng lỗi mới xuất hiện.
  - Phân biệt với SC-40/03: SC-40 là **đã touched/Save** ⇒ CÓ dòng lỗi. Đừng sinh test kỳ vọng lỗi ngay khi
    mở form rỗng — sẽ sai.

### SC-FLASHCARDEDITOR-42a — touched-gating meaning
Nguồn: code `error: data.meaningTouched && data.meaning.trim().isEmpty ? editorMeaningRequired : null`
Given: state create vừa mở, meaning rỗng, **chưa chạm** (`meaningTouched=false`).
Then: **KHÔNG** hiện "Meaning is required" cho tới khi chạm rồi bỏ trống (`setMeaning` ⇒
`meaningTouched=true`). Đối xứng SC-40a.

### SC-FLASHCARDEDITOR-41 — term chỉ khoảng trắng → lỗi (trim)
Nguồn: BR-2 · schema-contract `cards.term` "trimmed non-empty"
When: term = "   " (chỉ space), Save.
Then: UI coi như rỗng → lỗi "Term is required"; DB không ghi (trim ⇒ rỗng).

### SC-FLASHCARDEDITOR-42 — meaning rỗng / chỉ khoảng trắng → lỗi
Nguồn: BR-2/BR-3 · AC-3 · `card_meanings.content` "trimmed non-empty"
When: meaning rỗng hoặc chỉ space, Save.
Then: UI "Meaning is required" (ARB) viền error; DB không ghi.

### SC-FLASHCARDEDITOR-43 — term hợp lệ có khoảng trắng đầu/cuối → trim khi lưu
Nguồn: schema-contract `cards.term` trimmed
When: term = "  안녕  ", meaning hợp lệ, Save.
Then: DB `cards.term` = "안녕" (đã trim 2 đầu); UI không lỗi.

### SC-FLASHCARDEDITOR-44 — term CJK (Hàn/Nhật) hợp lệ
Nguồn: reference domain (Hàn/Nhật) · i18n
When: term = "안녕하세요" / "こんにちは", meaning hợp lệ, Save.
Then: DB lưu nguyên glyph CJK (không tofu, không mất ký tự); UI render đúng. Round-trip đọc lại khớp.

### SC-FLASHCARDEDITOR-45 — term/meaning ký tự đặc biệt + emoji
Nguồn: i18n / edge input (không có rule cấm trong BR/D-xxx)
When: term = "café ①②", meaning = "note 😀 <b>", Save.
Then: DB lưu nguyên văn (free-text, BR-3); không escape sai/không crash. ⚠ Xác nhận: có giới hạn ký tự
cấm không? BR/D-xxx **không nêu** → không chặn (liệt kê Open questions).

### SC-FLASHCARDEDITOR-46 — term rất dài (biên độ dài tối đa)
Nguồn: BR/schema-contract **không quy định max length**
When: term = chuỗi 1.000+ ký tự, meaning hợp lệ, Save.
Then: ⚠ **KHÔNG có giới hạn độ dài trong spec** → assert tối thiểu: không crash, không tràn layout (ô cuộn/
wrap), lưu nguyên hoặc theo giới hạn nếu spec bổ sung. Liệt kê Open questions (không bịa max).

### SC-FLASHCARDEDITOR-47 — meaning đa dòng dài (ghi chú/ví dụ)
Nguồn: BR-3 (ô văn bản tự do) · spec meaning minh:74 đa dòng
When: meaning nhiều dòng + ví dụ.
Then: ô cao giãn/cuộn được; lưu nguyên xuống dòng vào `card_meanings.content`.

### SC-FLASHCARDEDITOR-48 — trùng term (soft-dup) — vào state duplicate
Nguồn: D-020 · BR-5 · AC-2 → xem SC-FLASHCARDEDITOR-04/24
When: nhập term trùng thẻ có trong cùng deck.
Then: banner cảnh báo mềm, **không chặn**; `dup-add` vẫn lưu. Không phải "lỗi validation" (khác state
validation).

### SC-FLASHCARDEDITOR-49 — nghĩa phụ (meaning-2) rỗng khi đã mở khối
Nguồn: BR-3 · state multi-meaning
When: mở khối nghĩa phụ nhưng để rỗng, Save.
Then: ⚠ Xác nhận: khối nghĩa phụ rỗng bị bỏ qua (không tạo hàng `card_meanings`) hay báo lỗi? BR-2 chỉ bắt
buộc **1** nghĩa mẹ đẻ; nghĩa phụ tuỳ chọn → suy đoán "bỏ qua khối rỗng" nhưng cần chốt (Open questions).

---

## 5. Lượng dữ liệu (số nghĩa · độ dài · biên)

### SC-FLASHCARDEDITOR-50 — 1 nghĩa (tối thiểu hợp lệ)
Nguồn: BR-2
Then: 1 term + 1 meaning ⇒ Save OK; `card_meanings` đúng 1 hàng.

### SC-FLASHCARDEDITOR-51 — nhiều nghĩa (multi-meaning)
Nguồn: BR-3 · state multi-meaning
Then: N khối nghĩa (mẹ đẻ + phụ) ⇒ `card_meanings` N hàng, `sort_index` 0..N-1, `language` khác nhau.

### SC-FLASHCARDEDITOR-52 — số nghĩa phụ tối đa
Nguồn: kit `repeat: x5+` (danh sách block)
Then: ⚠ Xác nhận số nghĩa tối đa cho phép (kit hiển thị "x5+" là minh hoạ MOCK, KHÔNG phải cap) → Open
questions. Assert tối thiểu: thêm nhiều khối, body cuộn được, không vỡ layout.

### SC-FLASHCARDEDITOR-53 — form dài (nhiều khối) → scroll
Nguồn: spec `app__body` `layout_hint:scroll` (scrollh:726/753/812 theo state)
Then: khi nội dung vượt viewport (multi-meaning/validation/duplicate), body cuộn được; appbar Cancel/Save
cố định trên; không che nút Save.

---

## 6. Async & lỗi (lưu / audio · local-first)

### SC-FLASHCARDEDITOR-60 — Save loading → success
Nguồn: S.12 build note "render AsyncValue.when" · UC-1
When: bấm Save; ghi DB async.
Then: UI hiện trạng thái đang lưu (không double-submit); xong → đóng editor. DB ghi đúng (SC-13).
  - ⚠ DOM spec KHÔNG có state loading riêng cho Save (chỉ 6 state). Assert: nút Save không cho bấm lại khi
    đang lưu; nếu có spinner thì theo build. Liệt kê Open questions về UI loading của Save.

### SC-FLASHCARDEDITOR-61 — Save thất bại (lỗi persistence local) — **build hiện tại KHÔNG surface/retry**
Nguồn: code `save()` (return false + `logger.error('editor save failed')`) + screen `_save()`
(`if (saved && mounted) context.pop()`) · ARB (KHÔNG có key `editorSaveError*`/retry cho editor)
When: ghi DB thất bại (giả lập).
Then (**build hiện tại — bám code, KHÔNG bịa retry**):
  - Hành vi: `save()` **`return false`** + `logger.error`; screen: vì `saved==false` ⇒ **KHÔNG `context.pop`**
    → **ở lại màn**, giữ nguyên nội dung đang nhập. **KHÔNG** SnackBar/dialog/surface lỗi, **KHÔNG** nút
    **retry** (không có UI lỗi cho hành động lưu ở editor; không có key ARB `editorSaveError*`).
  - Người dùng có thể tự bấm Save lại (không bị chặn) — nhưng đây **không** phải "retry affordance" có chủ đích.
  - DB: không có hàng thẻ dở (use case fail ⇒ không commit).
  - ⚠ **Mâu thuẫn nguồn:** S.12 build-note gợi ý "localized surface + retry" nhưng **code chưa hiện thực**
    (khác màn Study đã có `studySaveError*`+retry). Việc surface/retry lưu-lỗi ở editor ⇒ **spec-đích chưa
    build**, Open-q 8 — KHÔNG assert như kỳ vọng chắc chắn. Assert build hiện tại: **stay-on-screen, silent
    (chỉ log)**.

### SC-FLASHCARDEDITOR-62 — Audio phát lỗi (**build hiện tại: silent log, không surface**)
Nguồn: code `playAudio()` (`if (result case Err(:final failure)) logger.error('editor audio failed')`)
When: `speak(...)` trả về `Err`.
Then (**build hiện tại**): **chỉ** `logger.error` — **KHÔNG** thông báo UI, KHÔNG đổi icon (giữ `volume_up`
tĩnh), KHÔNG `card.audio_ref` (giữ NULL). KHÔNG có state "generating"/`sync` để rơi vào lỗi.
  - ⚠ State kit `audio(sync)` "Generating from term…" + nhánh lỗi hiển thị là **spec-đích/kit MOCK cũ**;
    với live-speak tức thì (đã ship) state này **undrivable** (không có bước async-generating quan sát được) —
    tương tự ghi chú memory "error state unreachable". Đưa vào Open-q 5, không assert như build hiện tại.

### SC-FLASHCARDEDITOR-63 — Local-first (không mạng vẫn lưu)
Nguồn: schema-contract "local-only v1, no remote backend" · CLAUDE.md layer contract
When: tắt mạng, tạo/sửa thẻ, Save.
Then: lưu thành công vào DB local (không phụ thuộc mạng); TTS (nếu ship) có thể là on-device.

### SC-FLASHCARDEDITOR-64 — Tra trùng (dup-check) chạy cục bộ/tức thì
Nguồn: D-020 · BR-5
When: gõ term.
Then: cảnh báo trùng tính từ DB local (query `cards` theo `deck_id`+`term`), không cần mạng. ⚠ Xác nhận
thời điểm check (khi gõ / khi blur / khi Save?) — DOM spec không nêu trigger → Open questions.

---

## 7. Persistence (DB round-trip · assert bảng/cột · kill-relaunch)

### SC-FLASHCARDEDITOR-70 — Tạo thẻ → assert đúng bảng/cột
Nguồn: schema-contract `cards`, `card_meanings` · UC-1
Then: sau Save (create): `cards`(deck_id, term, hidden=0, audio_ref=NULL, grammatical_gender, created_at) +
`card_meanings`(card_id, language, content, sort_index=0) đúng như nhập. `srs_state` chưa có hàng (box 0).

### SC-FLASHCARDEDITOR-71 — Sửa thẻ → cột cập nhật, SRS không đổi
Nguồn: UC-2 · D-011 · schema-contract `srs_state`
Then: `cards`/`card_meanings` cập nhật; `srs_state`(card) box/due_at/last_reviewed_at **bất biến**.

### SC-FLASHCARDEDITOR-72 — Bật Ẩn → cột `hidden`
Nguồn: D-006 · BR-4 · schema-contract `cards.hidden`
Then: `cards.hidden`=1 sau Save; (hệ quả D-006 kiểm ở luồng queue).

### SC-FLASHCARDEDITOR-73 — Add anyway (trùng) → 2 hàng cùng term
Nguồn: D-020 · schema-contract §cards ("no unique constraint on (deck_id, term)")
Then: sau `dup-add`+Save: `cards` có **2** hàng cùng `deck_id`+`term`, id khác nhau (soft-dup cho phép).

### SC-FLASHCARDEDITOR-74 — Kill & mở lại app → dữ liệu còn
Nguồn: DoE #7 round-trip
Given: tạo thẻ C-new, Save. Kill app. Mở lại.
Then: C-new + nghĩa + gender + hidden vẫn còn trong DB, hiển thị đúng khi mở lại thẻ trong editor.

### SC-FLASHCARDEDITOR-75 — Xoá deck cha → cascade thẻ (liên đới)
Nguồn: D-024 · schema-contract referential integrity (cascade)
Given: thẻ vừa tạo ở deck-X; xoá deck-X (ở màn khác).
Then: `cards`(deck-X) + `card_meanings` + `srs_state` + `review_logs` bị xoá lan (ON DELETE CASCADE).
  - Ghi chú: hành động xoá không thuộc màn editor — assert này chứng minh dữ liệu editor ghi ra tuân
    cascade; test thuộc luồng deck nhưng dữ liệu nguồn do editor tạo.

---

## 8. Định dạng & i18n

### SC-FLASHCARDEDITOR-80 — Nhãn ngôn ngữ trường theo cặp đang chọn
Nguồn: design-05 ("Nghĩa mẹ đẻ lấy ngôn ngữ từ cặp đang chọn S0") · `language_pairs`
Given: pair learning=Korean, native=Vietnamese.
Then: nhãn term = "Term (<learning>)" (kit MOCK "Term (Korean)"); nhãn meaning = "Meaning (<native>)"
(kit MOCK "Meaning (English)") — **suy từ pair**, KHÔNG hardcode "Korean"/"English". Đổi pair ⇒ đổi nhãn.

### SC-FLASHCARDEDITOR-81 — CJK render đúng (không tofu)
Nguồn: i18n · reference domain
Then: term/meaning Hàn/Nhật render đúng glyph ở cả field lẫn placeholder; không cắt sai.

### SC-FLASHCARDEDITOR-82 — Chuỗi UI từ ARB (không copy kit MOCK)
Nguồn: CLAUDE.md #3 ("strings from ARB") · S.12 (l10n keys `editor*`, `gender*`)
Then: `editorCancel`, `editorSave`, `editorNewTitle`/`editorEditTitle`, label field, placeholder,
`editorTermRequired`/`editorMeaningRequired`, `editorDupWarning`, gender chip, `editorHideTitle`/
`editorHideSub` (dùng **"or"**), `editorAudioAuto`, `editorAudioPlay` — **tất cả** lấy từ ARB; đổi locale
máy (vi/en) ⇒ đổi chuỗi. Kit MOCK không xuất hiện nguyên văn trong app.
  - ⚠ **KHÔNG** có key `comingSoon` trong ARB (grep = 0 hit) và màn không tham chiếu — đừng assert nó.

### SC-FLASHCARDEDITOR-83 — Banner trùng: `<term>` nội suy (**spec-đích — build hiện tại là chuỗi TĨNH**)
Nguồn: state duplicate DOM (kit MOCK có term trong câu) · D-020 · ARB `editorDupWarning`
Then (**build hiện tại — bám ARB thực**): banner = ARB `editorDupWarning` = "A card with this term already
exists in this deck." — **KHÔNG placeholder, KHÔNG ICU, dùng "this term" tĩnh**. Assert: text cố định, đổi
theo locale, **KHÔNG** kỳ vọng term người dùng gõ xuất hiện trong câu.
  - ⚠ **Spec-đích DOM** vẽ message có `<term>` nội suy (+ CJK trong câu). Đó là **chưa build** (Open-q 5):
    khi bổ sung, ARB phải chuyển sang key có placeholder ICU. KHÔNG assert nội suy `<term>` ở build hiện tại.

### SC-FLASHCARDEDITOR-84 — Text dài → ellipsis/wrap không vỡ
Nguồn: DoE #8
Then: term/meaning/nhãn ngôn ngữ rất dài → wrap trong ô (meaning) hoặc ellipsis (nhãn/appbar title),
không tràn ngang, không đẩy Save khỏi appbar.

---

## 9. Dark mode

### SC-FLASHCARDEDITOR-90 — Mọi state ở light + dark
Nguồn: contract 6 state × light/dark (wireframe có cột dark) · CLAUDE.md #3 (token, no hardcode)
Then: 6 state (create/edit/validation/duplicate/multi-meaning/audio) render đúng ở **dark**: nền `bg`,
field `surface`/`divider`, viền lỗi `error`, banner `warning-soft`/`on-warning-soft`, chip
`primary-soft`/`on-primary-soft`, save `primary`/`surface` — tất cả qua token (`--memox-*`), không màu cứng;
contrast đạt.

---

## 10. Responsive

### SC-FLASHCARDEDITOR-91 — 320px → tablet + xoay
Nguồn: DoE #10 · spec 390px base
Then:
  - 320px: form không overflow ngang; chip gender `wrap` xuống dòng nếu cần (kit `flex:row wrap`); appbar
    Cancel/title/Save không chồng; body cuộn dọc.
  - Tablet/ngang: form giãn/căn giữa hợp lý, không kéo field quá rộng vỡ tỉ lệ; keyboard bật vẫn cuộn tới
    field đang focus; safe-area/notch OK.

---

## 11. A11y

### SC-FLASHCARDEDITOR-92 — Semantics + focus + hit-area
Nguồn: S.12 §Accessibility · DoE #11
Then:
  - `cancel`/`save`/`add-meaning` = nút có **label ARB**, hit-area ≥48 (`MxSpacing.minTouchTarget`).
    (`dup-view`/`dup-add` = spec-đích, chưa build — a11y của chúng chỉ áp khi ship.)
  - `audio-play` icon-only → `semanticLabel` = ARB `editorAudioPlay` (code truyền vào `MxIconButton`),
    KHÔNG dùng tên icon ("volume_up").
  - gender chip = nhóm chọn-loại-trừ (`inMutuallyExclusiveGroup: true`, `selected`), mỗi chip addressable.
  - `hidden-switch` = switch có label + trạng thái on/off đọc được; disabled `save` báo trạng thái disabled.
  - Thứ tự đọc: title → term(label+required+lỗi) → meaning → add-meaning → gender → audio → hidden → Save.
  - Dòng lỗi validation gắn với field tương ứng (screen-reader đọc lỗi cùng field, không rời rạc).

---

## 12. Concurrency & edge thời gian

### SC-FLASHCARDEDITOR-95 — Double-tap Save (nhấn nhanh 2 lần)
Nguồn: DoE #12 · UC-1
When: chạm `save` 2 lần thật nhanh (create hợp lệ).
Then: chỉ tạo **một** thẻ (không double-insert); nút khoá sau lần đầu tới khi xong/đóng.
  - DB: `cards` chỉ +1 hàng (không 2).

### SC-FLASHCARDEDITOR-96 — Double-tap add-meaning
Nguồn: DoE #12
When: chạm `add-meaning` 2 lần nhanh.
Then: ⚠ Xác nhận: thêm 1 hay 2 khối? Suy đoán "mỗi tap 1 khối" (2 tap ⇒ 2 khối) nhưng cần chốt hành vi
mong muốn (Open questions).

### SC-FLASHCARDEDITOR-97 — Back/cancel khi đang lưu
Nguồn: DoE #12
When: bấm Save (đang ghi) rồi back ngay.
Then: không để lại thẻ dở/ghi một phần; hoặc chặn back khi đang commit. ⚠ Hành vi cụ thể chưa có trong
spec → Open questions.

### SC-FLASHCARDEDITOR-98 — Sửa `srs.new_cards_per_day` không ảnh hưởng tạo thẻ
Nguồn: D-018 (cap chỉ áp cho hàng đợi NewLearn, KHÔNG chặn tạo thẻ) · schema-contract `settings`
When: tạo thẻ thứ 21 trong ngày (đã đạt cap 20 new/day ở học).
Then: **vẫn tạo được** thẻ (cap 20/ngày chỉ giới hạn số thẻ mới **đưa vào học**/ngày — D-018, không giới
hạn số thẻ tạo). DB `cards` +1 bình thường; thẻ mới là box 0/new, chờ hàng đợi.
  - ⚠ Xác nhận: tạo thẻ có bị ràng gì bởi cap new/day không? spec D-018 chỉ nói hàng đợi ⇒ tạo không bị chặn.

---

## Open questions (⚠ cần chốt spec trước khi sinh test — KHÔNG bịa)

1. **Save của thẻ mới**: có ghi `srs_state` box=0 hay để **không có hàng** (absent = new)? (SC-13)
2. **grammatical_gender**: danh sách gender **cố định 4** (None/Masc/Fem/Neutral) hay theo ngôn ngữ? — *đây
   là câu hỏi duy nhất còn ngỏ; giá trị lưu thực ĐÃ RÕ:* build hiện tại `cards.grammatical_gender` ∈
   { NULL, 'masc', 'fem', 'neutral' } (const `editorGenders`, None ⇒ NULL). Không còn để ngỏ "enum/string".
   (SC-18..21)
3. **Nghĩa phụ — bộ chọn ngôn ngữ (mâu thuẫn nguồn S.12 vs code)**: S.12 dòng 37 nói **CÓ** picker (endonym,
   `supported_languages.dart`); code **KHÔNG** có — hardcode `_secondaryLanguage='vi'`, comment "deferred —
   gap". Chốt: build picker theo S.12 hay giữ hardcode? Ngoài ra: cho phép trùng ngôn ngữ với nghĩa mẹ đẻ?
   nút **xoá** 1 khối? khối **rỗng** khi Save → code hiện **bỏ qua** (chỉ thêm hàng nếu `secondaryText`
   không rỗng) — xác nhận đúng ý? số nghĩa phụ **tối đa** (kit "x5+" chỉ MOCK)? (SC-05, SC-17, SC-49, SC-52)
4. **Dup-check**: code so **cùng deck** + `excluding: cardId` (`DetectDuplicateTermUseCase`); trigger = **khi
   gõ** (`setTerm` → `_checkDuplicate`). Còn ngỏ: hoa-thường / trim / chuẩn hoá Unicode khi so? (SC-04, SC-64)
5. **Spec-đích chưa build (KHÔNG phải "audio hoãn" — sửa claim cũ)**: (a) **`dup-view`/`dup-add` + banner
   `<term>` nội suy** — build hiện tại banner là `MxActionCallout` **không nút, text tĩnh `editorDupWarning`
   không `<term>`**; 2 nút + `<term>` là spec-đích DOM (chờ màn danh sách thẻ/W6). (b) **State kit
   `audio(sync)` "Generating from term…"** — TTS **đã ship dạng live-speak** (`speak` tức thì); state
   generating/`sync` **undrivable** (không async-generating quan sát được). Chốt: có build async-generate +
   file-audio (`card.audio_ref`) không, hay giữ live-speak? **KHÔNG có `comingSoon`** ở bất kỳ đâu.
   (SC-04, SC-06, SC-24, SC-35, SC-62, SC-83)
6. **Cancel/back khi form dirty**: có dialog "Bỏ thay đổi?" không? DOM spec không có confirm-dialog. (SC-10,
   SC-34, SC-97)
7. **Giới hạn độ dài / ký tự cấm** cho term & meaning: BR/schema không quy định max/blacklist. (SC-45, SC-46)
8. **Save lưu-lỗi — surface + retry CHƯA build (sửa claim cũ)**: code `save()` chỉ `return false` +
   `logger.error`; screen `if (saved && mounted) context.pop()` ⇒ **ở lại màn, không surface, không retry,
   không key ARB `editorSaveError*`** (khác màn Study đã có). Chốt: có thêm surface+retry (giống Study) không,
   copy + vị trí? State loading của Save cũng không có (DOM chỉ 6 state). (SC-60, SC-61)
9. **Entry point khi ôn (inline edit)**: pushed hay overlay? có prefill từ thẻ đang ôn không? (SC-31)
10. **Ngôn ngữ meaning theo pair active (S0)**: code hardcode `_primaryLanguage='en'`, `_secondaryLanguage=
    'vi'`, `_termSpeakLanguage='ko'` (đều "deferred — gap") — **chưa** lấy `native`/`learning` từ pair active.
    Xác nhận: khi wire pair, `card_meanings.language` primary = native, secondary = ngôn ngữ chọn; TTS
    `languageCode` = learning của pair. (SC-05, SC-06, SC-13, SC-70, SC-80)

> Các mục ⚠ là **danh sách phải hỏi BA/spec**, không được đoán giá trị/logic. Khi có câu trả lời → cập nhật
> scenario tương ứng + xoá cờ ⚠. Đây chính là "không bỏ sót": phần chưa rõ được **liệt kê ra**, không lờ đi.
