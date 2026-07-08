# Kịch bản — Import cards · screen `import`

Nguồn: `docs/contracts/import.md` [source · mapping · preview · dup-warning · done] ·
DOM `specs/import.md` · D-025 (import CSV/Excel/clipboard + separator + preview + trùng),
D-020 (soft-dup, cảnh báo mềm không chặn), D-009 (deck cha gộp cây con — deck đích) ·
BR `business/import-export/import-export.md` [BR-1 nguồn+separator · BR-2 preview+soft-dup ·
BR-4 UTF-8/CSV quoting · AC-1/AC-2] · BR `business/flashcard/flashcard-management.md`
[BR-2 term+≥1 nghĩa bắt buộc · AC-3 thiếu trường ⇒ chặn+nêu rõ · BR-3 nghĩa = ô văn bản tự do · line 64 nghĩa=tiếng mẹ đẻ] ·
nav `navigation-flow.md` (`deckImport` = `/deck/:id/import`, push từ deck-detail) ·
DB `cards`, `card_meanings`, `srs_state` (D-017), `decks`, `language_pairs` (native_language), `settings` (`import.separator` enum).

> Số/tên/nội dung trong kit là MOCK ("124 cards", "TOPIK I — Vocabulary", "8 cards already exist",
> "Column A → Term", "안녕하세요/Hello", "Tab/Comma/Semicolon") — assert **định dạng & nguồn**, KHÔNG
> assert giá trị mock. Chuỗi hiển thị lấy từ ARB (`lib/l10n/`), không copy kit. State phải có thật
> trong contract; cột DB phải có thật trong schema-contract. Preview đếm "124" chỉ minh hoạ — assert
> "số hàng parse được", không assert 124.

## DoE — import (12 chiều)

| # | Chiều | TT | Scenario / N/A |
|---|---|---|---|
| 1 | States (5) | ✅ | SC-IMPORT-01..05 |
| 2 | Elements (15 phần tử) | ✅ | SC-IMPORT-10..26 (gồm 2 hàng ánh xạ `import/map-term`/`import/map-meaning` + container `import/done`) |
| 3 | Nav vào/ra | ✅ | SC-IMPORT-30..36 |
| 4 | Nhập liệu & validation | ✅ | SC-IMPORT-40..48 |
| 5 | Lượng dữ liệu | ✅ | SC-IMPORT-50..55 |
| 6 | Async & lỗi | ✅ | SC-IMPORT-60..64 |
| 7 | Persistence (DB round-trip) | ✅ | SC-IMPORT-70..74 |
| 8 | Định dạng & i18n | ✅ | SC-IMPORT-80..85 |
| 9 | Dark mode | ✅ | SC-IMPORT-90 |
| 10 | Responsive | ✅ | SC-IMPORT-91 |
| 11 | A11y | ✅ | SC-IMPORT-92 |
| 12 | Concurrency & edge thời gian | ✅ | SC-IMPORT-93..96 |

Element inventory (từ DOM spec — mỗi cái ≥1 scenario ở mục 2):
`import/back` (icon-button arrow_back, mọi state) · `import/source-0` (card CSV file) ·
`import/source-1` (card Excel) · `import/source-2` (card Paste text) · `import/paste` (vùng dán văn bản, state source) ·
`import/sep-0..2` (chip Tab/Comma/Semicolon, state mapping) ·
`import/map-term` (hàng ánh xạ Term: icon text_fields + nhãn "Column X → Term" + sample, state mapping) ·
`import/map-meaning` (hàng ánh xạ Meaning: icon translate + nhãn "Column X → Meaning" + sample, state mapping) ·
`import/map-term-pick` (icon-button expand_more, chọn cột Term) ·
`import/map-meaning-pick` (icon-button expand_more, chọn cột Meaning) · `import/to-preview` (btn Continue, state mapping) ·
`import/do-import` (btn Import N cards, state preview + dup-warning) · `import/done` (container thành công căn giữa, state done) ·
`import/go-deck` (btn Back to deck, state done) ·
`import/dup-warning` (banner cảnh báo trùng, state dup-warning).

⚠ DOM spec KHÔNG có node mở picker cột dạng menu/sheet (chỉ có icon-button `expand_more`); overlay picker
cột **chưa được kit định nghĩa** → xem Open questions #1.

---

## 1. States (mỗi state 1 scenario)

### SC-IMPORT-01 — source (chọn nguồn)
Nguồn: contract[source] · spec base · BR-1
Given:
  - DB: `decks`(1 deck đích, ví dụ deckId=D1), mở qua `/deck/:id/import`
When: push màn Import từ deck-detail của D1
Then:
  - UI: appbar (back + tiêu đề "Import cards" từ ARB) · section "CHOOSE SOURCE" · 3 card nguồn
    (`import/source-0` CSV · `import/source-1` Excel · `import/source-2` Paste text) · vùng `import/paste`
    (placeholder từ ARB, gợi ý "term[tab]meaning"). Không banner trùng, không preview, không mapping.
  - DB: không ghi gì (chỉ mở màn).

### SC-IMPORT-02 — mapping (chọn separator + ánh xạ cột)
Nguồn: contract[mapping] · spec "mapping" · D-025 · BR-1/BR-2
Given: đã chọn 1 nguồn có dữ liệu bảng nhiều cột (file/paste đã có nội dung)
When: hệ thống chuyển sang bước ánh xạ
Then:
  - UI: section "SEPARATOR" + 3 chip `import/sep-0..2` (Tab/Comma/Semicolon; đúng 1 chip active =
    bg primary-soft) · section "COLUMN MAPPING" + 2 hàng (`import/map-term` "→ Term" với sample,
    `import/map-meaning` "→ Meaning" với sample) mỗi hàng có icon-button `expand_more` · bảng preview
    5 hàng (header Term/Meaning + hàng dữ liệu) · btn `import/to-preview` ("Continue").
  - DB: chưa ghi (chỉ cấu hình tách cột).

### SC-IMPORT-03 — preview (xem trước trước khi ghi)
Nguồn: contract[preview] · spec "preview" · D-025 · BR-2 · AC-1
Given: đã cấu hình separator + cột hợp lệ (mapping hợp lệ)
When: chạm "Continue" ở mapping
Then:
  - UI: eyebrow "PREVIEW · N CARDS" (N = số hàng parse được, ARB plural — KHÔNG assert "124") ·
    bảng preview (header + hàng term/meaning) · btn `import/do-import` ("Import N cards" + icon download).
    KHÔNG banner trùng (vì lô này không có thẻ trùng).
  - DB: **chưa ghi** (preview không mutate).

### SC-IMPORT-04 — dup-warning (có thẻ trùng)
Nguồn: contract[dup-warning] · spec "dup warning" · D-020 · BR-2 · AC-2
Given: lô nhập có M thẻ `term` trùng term đã có trong deck đích (soft-dup)
When: vào bước preview
Then:
  - UI: banner `import/dup-warning` (icon warning + text ARB kiểu "M cards already exist — import anyway?",
    M = số trùng, KHÔNG assert "8") trên đầu · vẫn hiện preview + btn `import/do-import` (**không bị chặn**, D-020).
  - Token (kit-first): banner dùng `bg:warning-soft` (nền), `icon:warning` màu `on-warning-soft`, text màu
    `on-warning-soft` (DOM spec line 904/910/917). Assert đúng cặp token warning-soft / on-warning-soft qua
    `MxTheme` — KHÔNG hardcode `Color(0x..)`. (Assert này áp cho cả light lẫn dark; SC-IMPORT-90 chỉ phủ dark chung.)
  - DB: **chưa ghi** (vẫn ở bước xác nhận).

### SC-IMPORT-05 — done (nhập xong)
Nguồn: contract[done] · spec "done" · DOM `import/done` (spec line 1126) · D-025
Given: đã chạm `import/do-import` và ghi thành công N thẻ
When: hoàn tất ghi
Then:
  - UI: container `import/done` — div căn giữa (flex:col justify:center align:center) chứa toàn bộ nội dung
    thành công · icon-tile task_alt (success-soft) · tiêu đề "Imported N cards" (ARB plural, N từ DB) ·
    phụ đề "…added to <tên deck đích>" (tên deck từ DB, KHÔNG assert "TOPIK I") · btn `import/go-deck` ("Back to deck").
    Assert: các con dựng **bên trong** `import/done` (một node đặt tên, không rời rạc).
  - DB: `cards` +N hàng trong deck đích; `card_meanings` +N hàng (mỗi thẻ ≥1 nghĩa); `srs_state`:
    thẻ mới ⇒ box 0 / hoặc chưa có hàng (thẻ mới, chưa xếp lịch — D-002/D-017).
    ⚠ Xem Open questions #4 (import ghi `srs_state` box 0 hay bỏ trống).

---

## 2. Elements (mỗi phần tử ≥1 scenario)

### SC-IMPORT-10 — Back (mọi state)
Nguồn: spec `import/back` (icon-button arrow_back, mx:?) — có mặt ở source/mapping/preview/dup-warning/done
When: chạm back
Then: UI đóng màn Import, quay về deck-detail của deck đích (pop). DB: nếu **chưa** chạm do-import ⇒ không ghi.
⚠ Back tại bước preview/mapping = huỷ toàn bộ (không lưu nháp) — xem Open questions #6.

### SC-IMPORT-11 — Nguồn CSV file (`import/source-0`)
Nguồn: spec `import/source-0` (icon description · "CSV file" · "Import from a .csv file") · BR-1
When: chạm card CSV
Then: mở bộ chọn file .csv (file_picker); chọn file hợp lệ ⇒ chuyển sang mapping (SC-IMPORT-02). DB: chưa ghi.
⚠ Đích tap chính xác (mở file_picker ngay? lọc đuôi .csv?) chưa nêu trong kit — Open questions #2.

### SC-IMPORT-12 — Nguồn Excel (`import/source-1`)
Nguồn: spec `import/source-1` (icon table_chart · "Excel" · "Import from an .xlsx file") · BR-1
When: chạm card Excel
Then: mở bộ chọn file .xlsx; chọn file hợp lệ ⇒ mapping. DB: chưa ghi.

### SC-IMPORT-13 — Nguồn Paste text (`import/source-2`)
Nguồn: spec `import/source-2` (icon content_paste · "Paste text" · "Copy from somewhere else") · US-2
When: chạm card Paste text
Then: focus/kích hoạt vùng `import/paste` để dán; sau khi có nội dung ⇒ mapping. DB: chưa ghi.
⚠ Quan hệ giữa card "Paste text" và vùng `import/paste` (tap card mới hiện field? field luôn hiện?) — Open questions #2.

### SC-IMPORT-14 — Vùng dán văn bản (`import/paste`)
Nguồn: spec `import/paste` ("Paste your data here (one card per line: term[tab]meaning)…", border divider)
When: dán nhiều dòng "term<tab>meaning"
Then: UI nhận nội dung; chuyển sang mapping (tách theo separator). DB: chưa ghi.
Assert: placeholder từ ARB; nội dung dán được giữ khi chuyển bước.

### SC-IMPORT-15..17 — Chip separator Tab / Comma / Semicolon (`import/sep-0..2`)
Nguồn: spec `import/sep-0` "Tab" (active mặc định) · `import/sep-1` "Comma" · `import/sep-2` "Semicolon" · D-025 · BR-1
When: chạm lần lượt từng chip
Then: UI chip được chọn thành active (bg primary-soft, on-primary-soft), 2 chip còn lại về surface;
bảng preview/mapping tách lại cột theo separator mới. DB: lựa chọn có thể lưu vào `settings.import.separator`
(xem SC-IMPORT-73). Assert: đúng **một** chip active tại một thời điểm.

### SC-IMPORT-18 — Picker cột Term (`import/map-term-pick`)
Nguồn: spec `import/map-term-pick` (icon-button expand_more) · D-025
When: chạm nút expand_more hàng Term
Then: mở picker chọn cột nguồn cho Term; chọn cột ⇒ nhãn "Column X → Term" + sample cập nhật; preview tách lại. DB: chưa ghi.
⚠ Kit KHÔNG có node overlay picker cột (chỉ icon-button) — nội dung/hình dạng picker chưa định nghĩa — Open questions #1.

### SC-IMPORT-19 — Picker cột Meaning (`import/map-meaning-pick`)
Nguồn: spec `import/map-meaning-pick` (icon-button expand_more) · D-025
When: chạm nút expand_more hàng Meaning
Then: mở picker chọn cột nguồn cho Meaning; cập nhật nhãn + sample; preview tách lại. DB: chưa ghi.
⚠ Cùng gap picker như SC-IMPORT-18 — Open questions #1.

### SC-IMPORT-25 — Hàng ánh xạ Term (`import/map-term`) — nhãn + sample + icon
Nguồn: spec `import/map-term` (DOM line 389; div hàng, khác nút `import/map-term-pick`) · icon-tile `icon:text_fields`
(line 403, bg primary-soft, color on-primary-soft) · nhãn "Column X → Term" (line 415, font 15/700) · sample subtitle
(line 422, font 13/400, color text-secondary)
Then:
  - UI: hàng `import/map-term` dựng **3 phần** — icon-tile `text_fields` (bg primary-soft) + khối chữ (nhãn
    "Column X → Term" từ ARB + dòng sample) + nút `import/map-term-pick`. Assert nhãn + sample cùng render trong
    hàng này (không chỉ nút pick).
  - Cập nhật: đổi cột nguồn (qua pick) ⇒ nhãn "Column X → Term" và **dòng sample** cập nhật theo cột mới.
  - Assert icon: dùng `text_fields` (icon riêng của bước mapping — KHÁC icon nguồn description/table_chart/content_paste
    ở SC-IMPORT-11/12/13); màu on-primary-soft trên nền primary-soft. KHÔNG assert giá trị sample mock (CJK "안녕하세요…").

### SC-IMPORT-26 — Hàng ánh xạ Meaning (`import/map-meaning`) — nhãn + sample + icon
Nguồn: spec `import/map-meaning` (DOM line 444; div hàng, khác nút `import/map-meaning-pick`) · icon-tile
`icon:translate` (line 456, bg primary-soft, color on-primary-soft) · nhãn "Column X → Meaning" (line 468, font 15/700) ·
sample subtitle (line 475, font 13/400, color text-secondary)
Then:
  - UI: hàng `import/map-meaning` dựng icon-tile `translate` (bg primary-soft) + nhãn "Column X → Meaning" (ARB) +
    dòng sample + nút `import/map-meaning-pick`. Assert nhãn + sample render trong hàng.
  - Cập nhật: đổi cột nguồn ⇒ nhãn + sample cập nhật.
  - Assert icon: dùng `translate` (icon mapping-specific, khác icon nguồn); màu on-primary-soft trên primary-soft.
    KHÔNG assert giá trị sample mock.

### SC-IMPORT-20 — Continue → preview (`import/to-preview`)
Nguồn: spec `import/to-preview` (btn "Continue", bg primary) · D-025 · BR-2
When: chạm Continue ở mapping (mapping hợp lệ)
Then: UI chuyển sang state preview (SC-IMPORT-03) hoặc dup-warning (nếu có trùng, SC-IMPORT-04). DB: chưa ghi.

### SC-IMPORT-21 — Import (`import/do-import`) — không trùng
Nguồn: spec `import/do-import` (btn "Import N cards" + icon download) — có ở preview & dup-warning · D-025
When: chạm Import ở preview
Then:
  - UI: chuyển sang state done (SC-IMPORT-05).
  - DB: `cards` +N (deck_id = deck đích, term trimmed, hidden=0, created_at set); `card_meanings` +N
    (card_id tương ứng, language + content trimmed, sort_index). Thẻ mới ⇒ chưa xếp lịch (box 0/không hàng srs_state).

### SC-IMPORT-22 — Import (`import/do-import`) — có trùng (import anyway)
Nguồn: spec `import/do-import` ở state dup-warning · D-020 · AC-2
When: chạm Import khi banner trùng đang hiện
Then:
  - UI: sang done "Imported N cards" (N = **toàn bộ** lô, gồm cả bản trùng — soft-dup không loại).
  - DB: `cards` +N (kể cả term trùng — **không** unique constraint `(deck_id, term)`, D-020); deck đích giờ có
    thẻ term lặp. Assert: số hàng cards mới = N (không bị khấu trừ M trùng).
⚠ "N" hiển thị ở done = tổng lô hay tổng-trừ-trùng? kit done mock "124" = tổng preview → giả định = tổng lô. Open questions #5.

### SC-IMPORT-23 — Back to deck (`import/go-deck`)
Nguồn: spec `import/go-deck` (btn "Back to deck" + icon arrow_forward, state done) · D-025
When: chạm ở state done
Then: UI đóng Import, về deck-detail deck đích; deck-detail hiển thị số thẻ đã cộng N. DB: không ghi thêm (đã ghi ở do-import).

### SC-IMPORT-24 — Appbar title
Nguồn: spec `appbar__title` "Import cards"
Then: hiển thị tiêu đề từ ARB (KHÔNG copy "Import cards"); giữ nguyên qua mọi state của màn.

---

## 3. Điều hướng vào/ra

### SC-IMPORT-30 — Vào: từ deck-detail
Nguồn: nav `deckImport` = `/deck/:id/import` (push từ deck-detail)
Given: đang ở deck-detail deckId=D1
When: mở hành động Import
Then: push màn Import[source] với deck đích = D1. Assert: deck đích lấy từ route param `:id` (không hardcode).
⚠ Nút/menu-item nào ở deck-detail mở Import (spec deck-detail, ngoài màn này) — Open questions #3.

### SC-IMPORT-31 — Ra: back tại source
Nguồn: spec `import/back`
When: back ở state source
Then: pop về deck-detail D1; DB không đổi.

### SC-IMPORT-32 — Ra: back giữa mapping/preview/dup-warning
Nguồn: spec `import/back` (mọi non-done state)
When: back trước khi do-import
Then: pop về deck-detail; **không** ghi cards/meanings (chưa xác nhận). Nội dung dán/cấu hình bị bỏ (không lưu nháp).
⚠ Xác nhận có dialog "bỏ thay đổi?" không — Open questions #6.

### SC-IMPORT-33 — Ra: back tại done
Nguồn: spec `import/back` (state done có back) + `import/go-deck`
When: back tại done (thay vì go-deck)
Then: pop về deck-detail; thẻ đã nhập vẫn còn (đã ghi ở do-import). Cả back và go-deck cùng về deck-detail.
⚠ back vs go-deck ở done khác đích? (kit đều về deck) — Open questions #7.

### SC-IMPORT-34 — Ra: go-deck → deck-detail
Nguồn: spec `import/go-deck`
When: chạm "Back to deck" ở done
Then: về deck-detail deck đích (loaded), reflect N thẻ mới.

### SC-IMPORT-35 — Deep-link
Nguồn: nav `/deck/:id/import`
Then: ⚠ Xác nhận có cho deep-link trực tiếp vào import không (route tồn tại, nhưng cần deck hợp lệ). Nếu deckId
không tồn tại ⇒ hành vi? — Open questions #8.

### SC-IMPORT-36 — Giữ state khi app resume (background→foreground)
When: đang ở mapping/preview, đưa app nền rồi mở lại
Then: ⚠ Xác nhận: giữ nguyên bước + nội dung dán, hay reset về source? — Open questions #6.

---

## 4. Nhập liệu & validation (vùng dán + parse)

Field nhập liệu chính = `import/paste` (dán văn bản) + cấu hình separator/cột. Không có field tên deck ở màn này
(deck đích cố định theo route). Validation dưới đây bám D-025/BR-4 (UTF-8, CSV quoting) + D-020 (soft-dup).

### SC-IMPORT-40 — Dán rỗng
When: vùng dán rỗng, cố Continue
Then: ⚠ Không có state error trong kit cho "rỗng" → hành vi? (nút Continue/Import disable, hay báo lỗi?). DB: không ghi.
Assert tối thiểu: không crash, không tạo cards rỗng. Open questions #9.

### SC-IMPORT-41 — Dán chỉ khoảng trắng / dòng trống
When: dán "   \n\t\n"
Then: các dòng trống/toàn khoảng trắng bị bỏ qua (term trimmed non-empty theo schema `cards.term`); nếu không còn
dòng hợp lệ ⇒ như rỗng (SC-IMPORT-40). DB: chỉ ghi hàng có term khác rỗng sau trim.

### SC-IMPORT-42 — Dòng thiếu cột meaning
Nguồn: flashcard-management BR-2 (line 95) + AC-3 (line 107-108) · schema `card_meanings.content` (trimmed non-empty, BR-3 line 127)
When: dán dòng chỉ có term, không có separator/meaning (⇒ thẻ thiếu nghĩa bắt buộc)
Then:
  - Quy tắc nguồn: term + **ít nhất một nghĩa** (tiếng mẹ đẻ) là **bắt buộc** (flashcard BR-2); thẻ thiếu
    term hoặc thiếu nghĩa bắt buộc ⇒ hệ thống **CHẶN và nêu rõ trường còn thiếu** (AC-3). Đây là hành vi
    có nguồn, không phải câu hỏi mở.
  - Assert: dòng chỉ-có-term (nghĩa rỗng) **không** được ghi thành thẻ hợp lệ; hệ thống chặn/báo dòng thiếu
    nghĩa (surface localized từ ARB nêu rõ "thiếu nghĩa"). `card_meanings.content` không bao giờ ghi giá trị
    rỗng/toàn-khoảng-trắng (schema trimmed non-empty).
  - DB: **không** tạo hàng `cards` cho dòng thiếu nghĩa (và do đó không có hàng `card_meanings` mồ côi).
  - Không assert giá trị mock. (Cách trình bày chặn cho **cả lô** — dừng import vs chỉ bỏ dòng lỗi — thuộc
    Open questions #9 về hình thức lỗi; nhưng *bản thân quy tắc chặn* đã có nguồn và được assert ở đây.)

### SC-IMPORT-43 — Term/Meaning quá dài (biên max)
When: dán 1 dòng có term & meaning rất dài
Then: parse & ghi được (không có giới hạn ký tự nêu trong schema); UI preview cell wrap/ellipsis không vỡ layout.
DB: `cards.term` / `card_meanings.content` lưu đủ chuỗi dài. ⚠ Có giới hạn độ dài không? — Open questions #11.

### SC-IMPORT-44 — Ký tự đặc biệt / emoji
When: dán dòng có emoji + ký tự đặc biệt (ví dụ dấu ngoặc kép, xuống dòng trong ô — CSV quoting BR-4)
Then: BR-4: ô chứa separator/newline được bọc trích dẫn đúng chuẩn CSV; UTF-8 giữ nguyên. DB: content lưu đúng
(không cắt, không escape sai). Preview render đúng.

### SC-IMPORT-45 — CJK (Hàn/Nhật)
When: dán "안녕하세요<tab>Hello", "太郎<tab>Taro"
Then: BR-4 UTF-8 giữ tiếng Hàn/Nhật; preview render đúng glyph (không tofu). DB: `cards.term`="안녕하세요",
`card_meanings.content`="Hello" đúng byte. (kit sample chính là CJK — assert render đúng, không assert giá trị mock.)

### SC-IMPORT-46 — Trùng term trong lô nhập (nội bộ)
When: lô nhập chứa 2 dòng cùng term
Then: ⚠ soft-dup D-020 nói về trùng với thẻ **đã có trong deck**; trùng **nội bộ trong lô** chưa nêu → đếm cả 2?
gộp? cảnh báo? — Open questions #12. Giả định theo "không chặn": ghi cả 2.

### SC-IMPORT-47 — Trùng term với thẻ có sẵn trong deck (soft-dup)
Nguồn: D-020 · BR-2 · AC-2
Given: deck đích có thẻ term="사과"; lô nhập cũng có "사과"
When: vào preview
Then: UI banner dup-warning đếm M=1 (số trùng, ARB). Chạm Import ⇒ vẫn ghi "사과" (deck có 2 thẻ term "사과").
DB: `cards` có ≥2 hàng term="사과" cùng deck (không unique constraint — D-020).

### SC-IMPORT-48 — Sai định dạng file (không phải CSV/Excel hợp lệ)
When: chọn file .csv/.xlsx hỏng hoặc sai định dạng
Then: hiện thông báo lỗi (ARB, đọc/giải mã lỗi — UC-1 luồng ngoại lệ) và **không ghi gì**. DB: không thay đổi.
⚠ Không có state `error` trong kit cho import → hiện lỗi kiểu nào (snackbar/inline/dialog)? — Open questions #9.

---

## 5. Lượng dữ liệu

### SC-IMPORT-50 — 0 hàng hợp lệ
When: nguồn không có dòng hợp lệ nào
Then: như rỗng (SC-IMPORT-40); "Import N cards" với N=0 ⇒ nút disable/không cho ghi. DB: không ghi.
⚠ N=0 → nút Import ẩn/disable? — Open questions #9.

### SC-IMPORT-51 — 1 hàng
When: lô nhập đúng 1 thẻ
Then: preview eyebrow "PREVIEW · 1 CARD" (plural số ít, ARB); "Import 1 card". DB sau import: `cards` +1, `card_meanings` +1.

### SC-IMPORT-52 — Nhiều hàng (preview cuộn)
When: lô nhập nhiều hàng (> chiều cao bảng preview)
Then: UI: bảng preview cuộn được (body scroll, layout_hint:scroll); header hàng đầu (Term/Meaning) giữ hoặc cuộn theo
(assert không vỡ). Kit hiển thị 5 hàng mẫu → assert "hiển thị nhiều hàng + cuộn", không assert đúng 5.
⚠ Preview hiển thị toàn bộ hay chỉ N hàng đầu? kit repeat x5 = mẫu — Open questions #13.

### SC-IMPORT-53 — Rất nhiều hàng (vài nghìn thẻ)
Nguồn: NFR §8 "nhập vài nghìn thẻ không treo UI"
When: lô nhập vài nghìn dòng
Then: UI không treo (xử lý nền nếu cần); preview + import chạy mượt; done "Imported N cards" N lớn không vỡ layout.
DB: `cards`/`card_meanings` +N đúng số.

### SC-IMPORT-54 — Biên số lớn ở nhãn
When: N rất lớn (ví dụ 99999)
Then: eyebrow "PREVIEW · N CARDS" + "Import N cards" + done "Imported N cards" không tràn card (ellipsis/wrap). Assert định dạng số theo locale.

### SC-IMPORT-55 — Toàn bộ lô là thẻ trùng
When: mọi dòng trong lô trùng thẻ đã có trong deck
Then: banner dup-warning M = N (tất cả trùng); Import vẫn ghi N (D-020). DB: deck có thêm N thẻ lặp.

---

## 6. Async & lỗi

### SC-IMPORT-60 — Đọc/parse file (loading → mapping)
When: chọn file lớn, đang đọc/parse
Then: ⚠ Không có state `loading` trong contract import (5 state không gồm loading) → hiện gì khi đang parse?
(spinner? disable?) — Open questions #14. Assert tối thiểu: không crash, không double-parse.

### SC-IMPORT-61 — Ghi thành công (do-import → done)
When: chạm Import, ghi hoàn tất
Then: UI sang done; DB `cards`/`card_meanings` +N như SC-IMPORT-21.

### SC-IMPORT-62 — Ghi thất bại + retry (atomic, không mồ côi)
Nguồn: UC-1 luồng ngoại lệ ("thất bại ⇒ báo lỗi, không ghi gì") · schema referential integrity (line 296-297:
`cards 1──∞ card_meanings`, mỗi thẻ ≥1 nghĩa — BR-2) · `card_meanings.card_id` FK→`cards.id` (line 125)
When: thao tác ghi lỗi giữa chừng
Then:
  - Hiện thông báo lỗi (ARB); **không** ghi một phần (atomic — "không ghi gì"). Người dùng thử lại được.
  - Biên giao dịch: cả lô (mọi `cards` + `card_meanings` tương ứng) ghi trong **một giao dịch Drift duy nhất** ⇒
    lỗi ⇒ rollback toàn bộ. Assert: sau lỗi, `cards`/`card_meanings` của lô = 0 hàng (rollback sạch).
  - Bất biến tham chiếu (partial-failure): **KHÔNG** tồn tại hàng `cards` mồ côi thiếu ≥1 `card_meanings` của nó
    (BR-2 + FK line 125). cards và card_meanings phải co-commit; không có nửa vời "cards ghi, meanings chưa".
⚠ Cơ chế hiển thị lỗi + retry chưa có state kit — Open questions #9. Bản thân bất biến atomic/no-orphan đã có
nguồn (schema line 296-297) và được assert.

### SC-IMPORT-63 — Huỷ giữa chừng (back khi đang ghi)
When: back trong lúc do-import đang chạy
Then: ⚠ Xác nhận: chờ ghi xong rồi pop, hay huỷ atomic (rollback)? — Open questions #6.

### SC-IMPORT-64 — Local-first (không mạng)
When: tắt mạng, thực hiện toàn bộ luồng import
Then: import chạy đủ (đọc file cục bộ + ghi Drift cục bộ) — không phụ thuộc mạng (local-first, không remote v1).

---

## 7. Persistence (DB round-trip)

### SC-IMPORT-70 — Ghi cards đúng bảng/cột
Nguồn: schema `cards`
Then: sau import, mỗi thẻ có hàng `cards`: `deck_id`=deck đích, `term` trimmed non-empty, `hidden`=0,
`created_at` set (import stamps it — schema note), `id` = ULID/UUID. Assert từng cột.

### SC-IMPORT-71 — Ghi meanings đúng bảng/cột
Nguồn: schema `card_meanings` · flashcard-management line 64 (nghĩa = "tiếng mẹ đẻ (bắt buộc)") ·
schema `language_pairs.native_language` (line 59, ngôn ngữ mẹ đẻ của cặp active — đúng 1 cặp active, line 60)
Then: mỗi thẻ có ≥1 hàng `card_meanings`: `card_id` khớp, `content` = cột Meaning trimmed non-empty,
`sort_index` set. `language` = **native_language của cặp ngôn ngữ đang active** — nghĩa nhập là "tiếng mẹ đẻ"
(flashcard line 64) và cặp active drive toàn app (schema line 60), nên ngôn ngữ nghĩa suy ra được từ nguồn,
KHÔNG hỏi BA. Assert: `card_meanings.language` = `language_pairs.native_language` của hàng `is_active=1`
(không hardcode, không lấy từ cột file).

### SC-IMPORT-72 — srs_state của thẻ mới (không xếp lịch, không vào due)
Nguồn: schema `srs_state` — D-017 (line 155-156: NewLearn bỏ dở/chưa học ⇒ **KHÔNG** ghi hàng srs_state / stays box 0) ·
line 140 (Absent/box 0 = brand-new) · idx_srs_due (line 158, due-queue join non-hidden `due_at<=now`)
Then:
  - Import KHÔNG chạy learn 5-stage ⇒ thẻ import chưa từng học. Theo D-017 (nghiêng về **không ghi hàng srs_state**;
    hoặc box 0 với `due_at`=NULL — cả hai đều = brand-new). Assert: thẻ import có **NO hàng srs_state** (ưu tiên theo
    D-017), hoặc nếu có thì box 0 + `due_at`=NULL. Không thẻ import nào ở box ≥1.
  - Không vào due-queue (assert kiểu D-006): thẻ import **KHÔNG** xuất hiện trong hàng đợi due (idx_srs_due lọc
    `due_at != NULL AND due_at <= now`; thẻ mới `due_at`=NULL/không hàng ⇒ loại). Assert: số "đến hạn" (due count)
    của deck đích **không** tăng sau import (chỉ tổng số thẻ hiển thị tăng N).
⚠ Còn mở (Open questions #4): chốt dứt điểm "no row" vs "box 0 row" — D-017 nghiêng "no row"; nhưng bất biến
"không vào due" ở trên đúng cho cả hai và được assert.

### SC-IMPORT-73 — Separator lưu vào settings (enum value + default)
Nguồn: schema `settings` key `import.separator` = **enum** (line 255, D-025) · DOM `import/sep-0` "Tab" active mặc định (spec)
When: đổi chip separator rồi import
Then:
  - DB `settings` có hàng `key`="import.separator", `value` thuộc **miền enum** — đúng một trong tập
    {tab, comma, semicolon} (3 chip `import/sep-0..2`). Assert `value` là mã enum ổn định, không phải ký tự thô
    (`\t`/`,`/`;`); ánh xạ enum→ký tự tách nằm ở tầng codec, không lưu ký tự vào settings.
  - Default: khi **chưa** có hàng `import.separator`, giá trị mặc định = `tab` (DOM: chip Tab active mặc định) ⇒
    chip Tab hiện active lần mở đầu. Assert default = tab.
  - Round-trip: đổi chip → ghi enum → mở lại import ⇒ chip active = separator đã lưu.
⚠ Còn mở: separator persist vĩnh viễn hay chỉ trong phiên (Open questions #16). Miền enum + default = tab thì đã có
nguồn (schema line 255 + DOM Tab-active) và được assert ở đây.

### SC-IMPORT-74 — Kill & mở lại app sau import
Then: kill app sau khi done, mở lại → deck đích vẫn có N thẻ đã nhập (cards/meanings còn trong Drift). Không mất.

---

## 8. Định dạng & i18n

### SC-IMPORT-80 — Plural "cards"
Then: eyebrow "PREVIEW · N CARDS", "Import N cards", "Imported N cards" dùng ARB plural: N=1 ⇒ số ít ("1 card"),
N>1 ⇒ số nhiều — không nối chuỗi. Banner dup: M=1 vs M>1 plural đúng.

### SC-IMPORT-81 — CJK render (Hàn/Nhật) trong preview + done
Then: preview cell + done subtitle chứa CJK (term Hàn, tên deck Nhật) render đúng glyph, không tofu, không cắt sai.

### SC-IMPORT-82 — Text dài trong preview/done
Then: term/meaning dài → cell wrap/ellipsis; tên deck dài ở subtitle done → wrap/ellipsis (maxw:220 trong kit),
không đẩy layout.

### SC-IMPORT-83 — Locale số
Then: N hiển thị theo định dạng số của locale (dấu phân nhóm nghìn nếu locale yêu cầu).

### SC-IMPORT-84 — Đổi locale → chuỗi đổi
When: đổi locale máy (vi/en/ja)
Then: mọi chuỗi (tiêu đề, section header, nhãn nút, banner, placeholder) đổi theo ARB; không vỡ layout (text dài).

### SC-IMPORT-85 — Chuỗi từ ARB (không hardcode)
Then: mọi text hiển thị (appbar, "CHOOSE SOURCE", tên nguồn, "SEPARATOR", "COLUMN MAPPING", "PREVIEW",
banner, nút) đều từ ARB — không copy MOCK kit; không có Color(0x..)/px cứng.

---

## 9. Dark mode

### SC-IMPORT-90 — Mọi state ở dark
Then: 5 state (source/mapping/preview/dup-warning/done) render đúng ở **cả** light + dark qua token
(bg/surface/primary/warning-soft/success-soft/divider/text*); không hardcode màu. Chip active, banner warning,
icon-tile success contrast đạt ở dark.

---

## 10. Responsive

### SC-IMPORT-91 — 320px → tablet + xoay
Then: ở 320px không overflow (card nguồn, bảng preview 2 cột term/meaning, banner, nút full-width co giãn);
xoay ngang cuộn được (body layout_hint:scroll); tablet giãn hợp lý; safe-area/notch OK; nút do-import/go-deck
giữ minh:48.

---

## 11. A11y

### SC-IMPORT-92 — Semantics
Then: back/3 card nguồn/3 chip separator/2 nút picker cột/Continue/Import/go-deck đều có semantic label (ARB);
hit-area ≥48 (nút picker kit 36x36 ⇒ ⚠ dưới 48, cần mở rộng hit-area — Open questions #17); chip active có
trạng thái selected đọc được; banner dup-warning đọc thành câu có nghĩa; thứ tự đọc: tiêu đề → section → nội dung → nút;
bảng preview đọc theo cặp term/meaning.

---

## 12. Concurrency & edge thời gian

### SC-IMPORT-93 — Double-tap Import
When: chạm `import/do-import` nhanh 2 lần
Then: chỉ ghi **một** lô (không nhân đôi cards); done hiện 1 lần. Assert: `cards` +N (không +2N).

### SC-IMPORT-94 — Double-tap nguồn / go-deck
When: chạm nhanh 2 lần 1 card nguồn (hoặc go-deck)
Then: chỉ mở picker/pop **một** lần (không mở 2 file_picker, không pop 2 màn).

### SC-IMPORT-95 — Back khi đang parse/ghi
When: back trong lúc đang đọc file hoặc đang ghi
Then: xem SC-IMPORT-62/63 — không ghi một phần; UI không kẹt. ⚠ Open questions #6.

### SC-IMPORT-96 — created_at & đổi ngày lúc nửa đêm
Given: import ngay quanh 00:00
Then: `cards.created_at` = "now" từ Clock tại thời điểm ghi (một mốc nhất quán cho lô); không phụ thuộc đổi ngày.
Import **không** đụng `daily_activity`/streak (import không phải phiên học DueReview/NewLearn — D-010). Assert: `daily_activity` không đổi sau import.

---

## Open questions (⚠ cần chốt spec trước khi viết test — KHÔNG bịa)

1. **Picker cột (map-term/map-meaning)**: kit chỉ có icon-button `expand_more`, KHÔNG có node overlay (menu/sheet/dialog)
   liệt kê danh sách cột. Hình dạng picker, danh sách cột nguồn, cách chọn — chưa định nghĩa trong kit. Cần kit-first bổ sung.
2. **Tap card nguồn**: CSV/Excel mở file_picker ngay (lọc đuôi)? Paste text kích hoạt vùng `import/paste` hay field luôn hiện?
   Quan hệ card "Paste text" ↔ vùng paste chưa rõ.
3. **Entry point từ deck-detail**: nút/menu-item nào mở Import (nằm ở spec deck-detail, ngoài màn này) — cần đối chiếu.
4. **srs_state cho thẻ import** (PHẦN LỚN ĐÃ CÓ NGUỒN — xem SC-IMPORT-72): schema D-017 (line 155-156) nói NewLearn
   chưa học ⇒ **KHÔNG ghi hàng srs_state**; line 140 "Absent/box 0 = brand-new". Bất biến "không vào due-queue/due count"
   đúng cho cả hai cách và đã được assert. Chỉ còn cần chốt dứt điểm "no row" vs "box 0 row" cho assert chính xác.
5. **N ở done/nút Import**: "Import N cards" và "Imported N cards" = tổng lô (gồm trùng) hay tổng-trừ-trùng? Giả định = tổng lô (soft-dup không loại).
6. **Back / huỷ / resume**: back giữa mapping/preview có dialog "bỏ thay đổi?" không? Huỷ khi đang ghi = rollback atomic? App resume giữ bước hay reset?
7. **Back vs go-deck ở done**: cả hai đều về deck-detail? Có khác đích không?
8. **Deep-link `/deck/:id/import`**: cho phép deep-link trực tiếp? deckId không tồn tại/không hợp lệ ⇒ hành vi?
9. **Lỗi & rỗng & N=0**: contract import KHÔNG có state `error`/`loading`/`empty`. Khi parse rỗng / N=0 / đọc-ghi lỗi:
   hiện gì (nút disable? snackbar? inline banner? dialog?)? Cần spec.
10. ~~**Dòng thiếu meaning**~~ **ĐÃ GIẢI QUYẾT** (xem SC-IMPORT-42): flashcard-management **BR-2** (line 95, term + ≥1 nghĩa
    bắt buộc) + **AC-3** (line 107-108, thiếu term/nghĩa ⇒ **CHẶN + nêu rõ trường thiếu**). Dòng chỉ có term ⇒ chặn,
    không ghi thẻ. (Trước đây ghi nhầm nguồn là BR-3 = "nghĩa là ô văn bản tự do" — sai; đã sửa citation.) Chỉ còn hình
    thức lỗi (chặn cả lô vs bỏ dòng) thuộc Open questions #9.
11. **Giới hạn độ dài** term/meaning khi import — có max không?
12. **Trùng nội bộ trong lô**: 2 dòng cùng term trong cùng lô — đếm cả 2 / gộp / cảnh báo riêng? (D-020 chỉ nói trùng với thẻ đã có).
13. **Preview hiển thị bao nhiêu hàng**: toàn bộ N hàng hay chỉ N hàng đầu (kit mẫu 5 hàng)?
14. **Trạng thái khi đang parse/ghi**: không có state `loading` trong kit — hiển thị tiến trình thế nào cho file lớn/lô nghìn thẻ?
15. ~~**`card_meanings.language`**~~ **ĐÃ GIẢI QUYẾT** (xem SC-IMPORT-71): nghĩa = "tiếng mẹ đẻ (bắt buộc)"
    (flashcard-management line 64) ⇒ `language` = `language_pairs.native_language` của cặp active (schema line 59-60,
    đúng 1 cặp active). Suy ra được từ nguồn — không lấy từ cột file, không hỏi BA.
16. **Persist separator** (default + miền enum ĐÃ CÓ NGUỒN — xem SC-IMPORT-73): `settings.import.separator` = enum
    {tab,comma,semicolon} (schema line 255); default = `tab` (DOM chip Tab active mặc định) — đã assert. Chỉ còn mở:
    lưu **vĩnh viễn** (mặc định cho lần sau) hay chỉ trong phiên.
17. **Hit-area picker cột**: nút `expand_more` kit 36x36 < 48 tối thiểu a11y — cần mở rộng vùng chạm.

> Các mục ⚠ ở trên là **danh sách phải hỏi BA/spec + kit-first**, không được đoán. Khi có câu trả lời → cập nhật
> scenario tương ứng + xoá cờ ⚠. Đây chính là "không bỏ sót": phần chưa rõ được **liệt kê ra**, không lờ đi.
