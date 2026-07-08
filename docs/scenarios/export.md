# Kịch bản — Export cards · screen `export`

Nguồn: `docs/contracts/export.md` [config · exporting · done] · DOM `specs/export.md` ·
D-026 (xuất: định dạng + kèm/không kèm SRS) · D-025 (separator Tab/,/;) · D-009 (incl. sub-decks = gộp đệ quy) ·
D-006 (thẻ ẩn loại khỏi hàng đợi/đếm — ⚠ phạm vi export chưa chốt) · D-020 (soft-dup, chỉ liên quan gián tiếp) ·
BR `business/import-export/import-export.md` (BR-3 định dạng+kèm SRS [dòng 60], BR-4 UTF-8/bọc trích dẫn [dòng 61], US-3 xuất để sao lưu/chia sẻ [dòng 37], AC-3 kèm trạng thái ôn → kết quả chứa ô/hạn ôn [dòng 69], §8 vài nghìn thẻ không treo UI [dòng 74], §UC-2 luồng chính xuất [dòng 49-52]; **luồng ngoại lệ xuất-thất-bại nằm ở §UC-1 dòng 46-47, KHÔNG ở §UC-2** — xem SC-51) — *đã đối chiếu với file thật ngày 2026-07-08; mọi citation trên khớp trừ điểm §UC-2 đã sửa* ·
Nav `business/navigation/navigation-flow.md` (`deckExport` `/deck/:id/export`, push từ deck-detail) ·
DB đọc: `decks`, `cards`, `card_meanings`, `srs_state`; DB ghi (tuỳ chọn bền): `settings`
(`export.format`, `export.include_srs`, `import.separator`).

> Số/tên/nhãn trong kit là MOCK ("Export cards", "This deck", "Exported 320 cards", "200/286" thanh tiến độ,
> "CSV / .csv file"…) — assert **định dạng & nguồn** (chuỗi từ ARB, số từ DB thật), KHÔNG assert giá trị mock.
> Chuỗi lấy từ ARB, không copy kit. State phải có thật trong contract (`config`/`exporting`/`done`).
> Cột DB phải có thật trong schema-contract.

## DoE — export (12 chiều)

| # | Chiều | TT | Scenario / N/A |
|---|---|---|---|
| 1 | States (3) | ✅ | SC-EXPORT-01..03 |
| 2 | Elements (15 handle: back · scope×2 · format×3 · sep×3 · incl-srs switch · do-export · bar · share · save; + appbar title & progress card không tương tác) | ✅ | SC-EXPORT-10..25 |
| 3 | Nav vào/ra | ✅ | SC-EXPORT-30..35 |
| 4 | Nhập liệu & validation | **N/A** | màn export không có field nhập text tự do — chỉ segmented/radio/chip/switch (chọn rời rạc, không gõ). Biên "phạm vi rỗng / thẻ ẩn" phủ ở mục 5. Xem ⚠ Open-Q #7 (không có field ⇒ không có validate rỗng/dài/CJK/trùng/sai-định-dạng ở tầng UI export) |
| 5 | Lượng dữ liệu | ✅ | SC-EXPORT-40..44 |
| 6 | Async & lỗi | ✅ | SC-EXPORT-50..53 |
| 7 | Persistence (DB round-trip) | ✅ | SC-EXPORT-60..63 |
| 8 | Định dạng & i18n | ✅ | SC-EXPORT-70..74 |
| 9 | Dark mode | ✅ | SC-EXPORT-80 |
| 10 | Responsive | ✅ | SC-EXPORT-81 |
| 11 | A11y | ✅ | SC-EXPORT-82 |
| 12 | Concurrency & edge thời gian | ✅ | SC-EXPORT-90..93 |

Element inventory (từ DOM spec — mỗi cái ≥1 scenario ở mục 2):
`export/back` (icon-button arrow_back) · `export/appbar` title "Export cards" ·
`export/scope` segmented ×2 seg (`This deck` / `Incl. sub-decks`) ·
format card ×3 hàng: `export/format-csv` (radio_button_checked) · `export/format-xlsx` (radio_button_unchecked) ·
`export/format-copy` (radio_button_unchecked) ·
separator chips ×3: `export/sep-0` Tab · `export/sep-1` Comma · `export/sep-2` Semicolon ·
`export/incl-srs` card [icon-tile bg:success-soft + `icon:schedule` on-success-soft (lines 351-358) — SC-25] + `export/incl-srs-switch` (switch) ·
`export/do-export` (btn "Export", icon download) ·
[state exporting] `export/progress` card + `export/bar` (thanh tiến độ) ·
[state done] `export/done` block + `export/share` (btn "Share file") + `export/save` (btn "Save to device").

---

## 1. States

### SC-EXPORT-01 — config (màn cấu hình xuất)
Nguồn: contract[config] · DOM base state · D-026
Tiền điều kiện (Given):
  - DB: `decks`(1 "TOPIK I") có cây con + `cards`>0 thuộc deck; mở export cho deck này.
Thao tác (When):
  1. Từ deck-detail → chạm "Export" → push `/deck/:id/export`.
Kỳ vọng (Then):
  - UI: state `config` render đủ: appbar (back + title "Export cards" từ ARB) ·
    section SCOPE + segmented (`This deck` chọn mặc định, `Incl. sub-decks`) ·
    section FORMAT + card 3 dòng (CSV/Excel/Copy text), một dòng có radio `checked` (mặc định) ·
    section SEPARATOR + 3 chip (Tab/Comma/Semicolon), một chip active ·
    card "Include review state" + switch · nút "Export" (đáy). Không skeleton, không progress, không block done.
  - DB: chỉ **đọc** (`decks`,`cards`); chưa ghi gì.
  - ⚠ Xác nhận mặc định: format mặc định = CSV? separator mặc định = Tab? scope mặc định = This deck? include-srs mặc định = bật? (kit vẽ CSV-checked, Tab-active, This-deck-active, switch-ON nhưng đó là MOCK — nguồn thật = `settings` `export.format`/`import.separator`/`export.include_srs` hay hằng mặc định? — Open-Q #1).

### SC-EXPORT-02 — exporting (đang xuất, có tiến độ)
Nguồn: contract[exporting] · DOM state exporting · BR-3
Given: đang ở `config` với deck có `cards`>0.
When: chạm nút "Export".
Then:
  - UI: chuyển sang state `exporting`: card `export/progress` (icon sync + nhãn "Exporting…" từ ARB + thanh `export/bar`).
    Các section cấu hình (scope/format/separator/incl-srs) và nút Export **biến mất** (ordered-diff của DOM: state exporting thay toàn bộ body bằng progress card).
    Thanh tiến độ hiển thị tiến trình (kit vẽ ~70% là MOCK — assert thanh **tồn tại & hiển thị tiến độ**, không assert %).
  - DB: đọc `cards`/`card_meanings`(+`srs_state` nếu include-srs bật) để encode; chưa ghi bảng dữ liệu.
  - ⚠ Xác nhận: exporting có nút huỷ không? (DOM state exporting KHÔNG có nút cancel — chỉ progress card; back button vẫn còn ở appbar) — Open-Q #5.

### SC-EXPORT-03 — done (xuất xong, có nút chia sẻ/lưu)
Nguồn: contract[done] · DOM state done · D-026 · BR-3
Given: state `exporting` hoàn tất tạo file cho deck có N thẻ.
When: quá trình encode kết thúc thành công.
Then:
  - UI: chuyển sang state `done`: khối `export/done` giữa màn: icon-tile success (ios_share) ·
    tiêu đề "Exported N cards" (N = **số thẻ thật đã xuất từ DB**, không phải mock 320;
    style DOM: `font:20/800/30` **weight 800** + `tracking:-0.4` + `text:center` — line 600;
    nặng hơn appbar title 700, assert đúng style tiêu đề headline nếu style-parity bật) ·
    phụ đề "Your file is ready to share or save." (ARB, `font:15/400` text-secondary, center) ·
    2 nút: `export/share` ("Share file") + `export/save` ("Save to device"). Appbar back vẫn còn.
  - DB: dữ liệu thẻ **không đổi** (export là read-only với `cards`/`card_meanings`/`srs_state`).
  - ⚠ Xác nhận nguồn N: đếm thẻ theo scope đã chọn (This deck vs Incl. sub-decks đệ quy D-009); có gồm thẻ ẩn `hidden=1` không? — Open-Q #3.

---

## 2. Elements (mỗi phần tử trong DOM spec ≥1 scenario)

### SC-EXPORT-10 — Nút back (`export/back`)
Nguồn: DOM `export/back` (icon-button arrow_back, mx:?)
When: chạm back ở appbar (state `config`).
Then: UI: pop khỏi `/deck/:id/export`, quay lại deck-detail của deck đó (không mất state deck-detail). DB: không ghi.
  - ⚠ Biến thể: back khi đang `exporting`/`done` — Open-Q #5/#6 (huỷ tiến trình? / rời màn giữ file?).

### SC-EXPORT-11 — Appbar title "Export cards"
Nguồn: DOM `export/appbar` title
Then: UI: hiển thị tiêu đề màn từ **ARB** (không copy "Export cards" từ kit); render đủ, không tràn (title `clip`, tracking -0.4).

### SC-EXPORT-12 — Segmented seg "This deck" (`export/scope` seg-0)
Nguồn: DOM `export/scope` segmented__seg "This deck" · D-009 (đối lập với incl sub-decks)
Given: state `config`; deck có ≥1 deck con.
When: chạm seg "This deck".
Then: UI: seg "This deck" thành active (bg surface + shadow), seg "Incl. sub-decks" inactive; phạm vi xuất = **chỉ deck hiện tại** (không gồm cây con).
  - DB (khi Export): tập thẻ xuất = `cards` where `deck_id` = deck hiện tại (không đệ quy).

### SC-EXPORT-13 — Segmented seg "Incl. sub-decks" (`export/scope` seg-1)
Nguồn: DOM `export/scope` seg "Incl. sub-decks" · **D-009** (gộp đệ quy thẻ mọi bộ thẻ con)
Given: deck cha có ≥1 deck con chứa thẻ.
When: chạm seg "Incl. sub-decks".
Then: UI: seg này active. DB (khi Export): tập thẻ = **gộp đệ quy** thẻ của deck + toàn bộ cây con (`decks.parent_id` CTE, D-009). Số N ở state `done` = tổng đệ quy.

### SC-EXPORT-14 — Format row CSV (`export/format-csv`)
Nguồn: DOM `export/format-csv` (icon description, radio_button_checked) · D-026 · BR-3
When: chạm dòng "CSV".
Then: UI: radio dòng CSV = checked (icon radio_button_checked, color primary), 2 dòng còn lại unchecked (radio_button_unchecked, color text-tertiary). Định dạng chọn = CSV → file `.csv`.
  - DB (nếu bền): `settings` `export.format` = giá trị CSV (⚠ chỉ nếu lựa chọn được persist — Open-Q #1).

### SC-EXPORT-15 — Format row Excel (`export/format-xlsx`)
Nguồn: DOM `export/format-xlsx` (icon table_chart) · D-026 · BR-3
When: chạm dòng "Excel".
Then: UI: radio Excel → checked, CSV/Copy → unchecked; định dạng = Excel → file `.xlsx`.
  - ⚠ Khi format=Excel: section SEPARATOR còn ý nghĩa không? (separator là khái niệm CSV; Excel/clipboard có thể không dùng) — Open-Q #2.

### SC-EXPORT-16 — Format row Copy text (`export/format-copy`)
Nguồn: DOM `export/format-copy` (icon content_copy, "To clipboard") · D-026 · BR-3
When: chạm dòng "Copy text".
Then: UI: radio Copy → checked; định dạng = sao chép văn bản (clipboard).
  - ⚠ Khi format=Copy: nút cuối vẫn là "Export" rồi ra state `done` với Share/Save? hay copy thẳng vào clipboard (không có file để Share/Save)? — Open-Q #4.

### SC-EXPORT-17 — Chip separator Tab (`export/sep-0`)
Nguồn: DOM `export/sep-0` "Tab" (chip active mặc định) · **D-025** (separator Tab/,/;)
When: chạm chip "Tab".
Then: UI: chip Tab active (bg primary-soft, color on-primary-soft), 2 chip kia inactive (bg surface, text-secondary). Separator = Tab.
  - DB (nếu bền): `settings` `import.separator` (khoá dùng chung import/export theo schema) = Tab (⚠ Open-Q #1).

### SC-EXPORT-18 — Chip separator Comma (`export/sep-1`)
Nguồn: DOM `export/sep-1` "Comma" · D-025 · BR-4 (ô chứa separator/xuống dòng phải bọc trích dẫn)
When: chạm chip "Comma".
Then: UI: chip Comma active. Separator = phẩy. Khi Export CSV: ô nội dung chứa dấu phẩy hoặc newline **được bọc trích dẫn** đúng chuẩn CSV (BR-4) → dữ liệu Hàn/Việt không vỡ cột.

### SC-EXPORT-19 — Chip separator Semicolon (`export/sep-2`)
Nguồn: DOM `export/sep-2` "Semicolon" · D-025
When: chạm chip "Semicolon".
Then: UI: chip Semicolon active. Separator = chấm phẩy; file CSV tách cột bằng `;`.

### SC-EXPORT-20 — Card + switch "Include review state" (`export/incl-srs` + `export/incl-srs-switch`)
Nguồn: DOM `export/incl-srs` ("Include review state" / "Leitner box + due date") + `export/incl-srs-switch` (switch) · **D-026** · BR-3 · AC-3
Given: state `config`.
When: bật/tắt switch "Include review state".
Then:
  - UI: hàng gồm **icon-tile** (bg:success-soft, `icon:schedule` — đồng hồ, color:on-success-soft; lines 351-358) ở đầu, khối nhãn ("Include review state" 15/700 + phụ đề "Leitner box + due date" 13/400 text-secondary) ở giữa, và switch ở cuối — assert cả 3 phần render (icon-tile là node DOM có thật, không được bỏ). Icon-tile dùng token success-soft/on-success-soft (không hardcode màu).
  - UI: switch phản ánh trạng thái ON/OFF (kit vẽ ON = bg primary, thumb translate — MOCK; assert toggle **đổi trạng thái** + semantic).
  - DB (khi Export, switch ON): kết quả **chứa** `srs_state.box` (Leitner box) + `srs_state.due_at` (due date) của mỗi thẻ (AC-3). Switch OFF: kết quả **không** chứa cột SRS.
  - DB (nếu bền): `settings` `export.include_srs` = ON/OFF (⚠ Open-Q #1).
  - ⚠ Thẻ chưa xếp lịch (box 0, `due_at=NULL` — D-002/D-017) khi include-srs ON: xuất box=0 và due rỗng thế nào? — Open-Q #8.

### SC-EXPORT-21 — Nút "Export" (`export/do-export`)
Nguồn: DOM `export/do-export` (btn "Export", icon download) · D-026 · BR-3
Given: state `config` với ≥1 thẻ trong phạm vi.
When: chạm "Export".
Then: UI: rời `config` → `exporting` (SC-EXPORT-02) → `done` (SC-EXPORT-03). DB: đọc thẻ theo scope+include-srs, encode qua codec (CSV/Excel/clipboard); không đổi dữ liệu thẻ.

### SC-EXPORT-22 — Thanh tiến độ (`export/bar`) trong state exporting
Nguồn: DOM state exporting `export/bar` (track bg surface-sunken + fill bg primary)
Given: state `exporting` với deck nhiều thẻ (đủ để tiến độ tăng dần).
Then: UI: thanh bar hiển thị fill tăng theo tiến trình encode; đạt xong → chuyển `done`. (kit fill ~70% là MOCK — assert bar tồn tại + tiến triển, không assert %).

### SC-EXPORT-23 — Nút "Share file" (`export/share`) trong state done
Nguồn: DOM state done `export/share` (btn primary "Share file", icon share) · US-3
Given: state `done` (đã tạo file).
When: chạm "Share file".
Then: UI: mở sheet chia sẻ hệ thống với file vừa tạo (định dạng đã chọn). DB: không ghi.
  - ⚠ Xác nhận: dùng share sheet OS? nội dung share = file `.csv`/`.xlsx`, hay text (khi format=Copy)? — Open-Q #4/#6.

### SC-EXPORT-24 — Nút "Save to device" (`export/save`) trong state done
Nguồn: DOM state done `export/save` (btn viền "Save to device", icon save_alt) · US-3
Given: state `done`.
When: chạm "Save to device".
Then: UI: mở luồng lưu file (file picker/save location OS), file được ghi ra thiết bị. DB: không ghi bảng dữ liệu.
  - ⚠ Xác nhận đích lưu (Downloads? user chọn thư mục?) + kết quả sau khi lưu (toast xác nhận từ ARB?) — Open-Q #6.

### SC-EXPORT-25 — Icon-tile "schedule" của card include-SRS (`export/incl-srs` icon-tile)
Nguồn: DOM `export/incl-srs` > icon-tile (`bg:success-soft r:16`) > `icon:schedule` (`font:26/400 color:on-success-soft`, lines 346-358)
Given: state `config`.
Then:
  - UI: card "Include review state" render **leading icon-tile** hình vuông (r:16) nền `success-soft` chứa icon `schedule` (đồng hồ) màu `on-success-soft` — phân biệt với icon-tile format-card (nền `primary-soft`, xem SC-14..16). Assert node icon-tile + icon tồn tại (hoàn thiện DOM: mọi node hiển thị ≥1 scenario), dùng token success-soft/on-success-soft, không hardcode màu, cả light+dark (SC-80).
  - Node trang trí (không tương tác) — không có ngữ nghĩa hành động; hit-target/toggle vẫn thuộc `export/incl-srs-switch` (SC-20).

---

## 3. Điều hướng vào/ra

### SC-EXPORT-30 — Entry: từ deck-detail
Nguồn: Nav `deckExport` `/deck/:id/export` push từ deck-detail
Given: đang ở deck-detail của 1 deck.
When: chạm hành động "Export".
Then: UI: push export ở state `config`, mang `deckId` đúng (title/nguồn thẻ theo deck đó). DB: đọc `decks`(deckId).
  - ⚠ Xác nhận entry point: nút/menu-item "Export" nằm ở đâu trong deck-detail (menu more? action?) — Open-Q #9 (không có trong DOM spec màn export; thuộc màn deck-detail).

### SC-EXPORT-31 — Deep-link `/deck/:id/export`
Nguồn: Nav route table
When: mở deep-link route export với deckId hợp lệ.
Then: UI: vào state `config` cho deck đó. Biến thể deckId không tồn tại/không hợp lệ → ⚠ xử lý (redirect/empty/lỗi) chưa có spec — Open-Q #10.

### SC-EXPORT-32 — Ra: back về deck-detail (state config)
Nguồn: DOM `export/back` · Nav pop
When: back tại `config`.
Then: UI: pop về deck-detail; không tạo file; DB không ghi.

### SC-EXPORT-33 — Ra: back giữa chừng (state exporting)
When: chạm back khi state `exporting`.
Then: ⚠ Xác nhận: huỷ tiến trình encode & pop? hay chặn back tới khi xong? (DOM exporting vẫn render back button; không có cờ chặn) — Open-Q #5.

### SC-EXPORT-34 — Ra: rời màn ở state done
When: back tại `done` (chưa Share/Save).
Then: ⚠ Xác nhận: file tạm bị bỏ? có nhắc "file chưa lưu"? — Open-Q #6.

### SC-EXPORT-35 — Android back / swipe-dismiss
When: nhấn back hệ thống / vuốt cạnh ở từng state.
Then: hành xử **giống** SC-EXPORT-32..34 tương ứng state; không kẹt màn, không double-pop.

---

## 5. Lượng dữ liệu

### SC-EXPORT-40 — Deck 0 thẻ (rỗng)
Given: deck không có `cards` nào (và scope "This deck").
When: mở export → chạm "Export".
Then: ⚠ Xác nhận: nút Export có bị vô hiệu khi 0 thẻ? hay Export ra file rỗng/`done` "Exported 0 cards"? (DOM config luôn hiện nút Export enabled; không có empty-state riêng cho 0 thẻ) — Open-Q #11.

### SC-EXPORT-41 — Deck 1 thẻ
Then: state `done` hiển thị "Exported 1 card" — **plural đúng** (1 ⇒ dạng số ít, xem SC-EXPORT-71). File có đúng 1 dòng dữ liệu (+ header nếu có).

### SC-EXPORT-42 — Deck nhiều thẻ (vài trăm)
Then: state `exporting` chạy có tiến độ; `done` = "Exported N cards" (N từ DB, plural nhiều). File chứa đủ N dòng.

### SC-EXPORT-43 — Rất nhiều thẻ (vài nghìn — NFR)
Nguồn: business §8 (xuất vài nghìn thẻ không treo UI; xử lý nền nếu cần)
Then: UI không đơ khi encode; thanh `export/bar` tiến triển mượt; hoàn tất → `done` với N đúng. (async off-main).

### SC-EXPORT-44 — Scope đệ quy vs không (biên D-009 + D-006)
Given: deck cha 5 thẻ + 1 deck con 10 thẻ, trong đó 3 thẻ `hidden=1`.
When: so sánh "This deck" vs "Incl. sub-decks".
Then:
  - "This deck": N = số thẻ trực tiếp của deck cha.
  - "Incl. sub-decks": N = 5 + 10 = tổng đệ quy (D-009).
  - ⚠ Thẻ `hidden=1` (D-006): export **có gồm** thẻ ẩn không? D-006 loại thẻ ẩn khỏi *hàng đợi học/đếm due*, nhưng export là sao lưu dữ liệu (US-3) — không có rule minh thị. Không được đoán → Open-Q #3.

## 6. Async & lỗi

### SC-EXPORT-50 — config → exporting → done (happy path)
Then: chuỗi state đúng thứ tự; không nhảy cóc; done hiển thị N.

### SC-EXPORT-51 — Encode/ghi thất bại + retry
Nguồn: business **§UC-1 luồng ngoại lệ** ("Nếu thao tác nhập/xuất thất bại (đọc/ghi/giải mã lỗi), hiện thông báo lỗi và không ghi gì" — import-export.md dòng 46-47; luồng ngoại lệ này nằm ở UC-1, **không** ở UC-2 vốn chỉ mô tả luồng chính xuất) · BR-3
Given: quá trình encode/ghi file lỗi (I/O, quyền, giải mã).
Then:
  - UI: ⚠ **contract export KHÔNG có state `error`** (chỉ config/exporting/done). Khi lỗi hiện gì? (rơi về `config` + thông báo lỗi ARB? snackbar? dialog?) — cần spec. Không bịa. Assert tối thiểu theo business: **không tạo file hỏng, hiện thông báo lỗi, cho thử lại**. — Open-Q #12.
  - DB: không thay đổi dữ liệu.

### SC-EXPORT-52 — Local-first (không mạng)
Then: export chạy hoàn toàn từ DB local (`cards`/`card_meanings`/`srs_state`), không phụ thuộc mạng; ngắt mạng giữa chừng không ảnh hưởng (không có remote backend v1).

### SC-EXPORT-53 — Huỷ giữa chừng
When: rời màn / back khi `exporting`.
Then: ⚠ tiến trình huỷ sạch (không để file rác, không callback ghi state sau khi màn đã pop) — hành vi cụ thể cần spec (gắn Open-Q #5).

## 7. Persistence (DB round-trip)

### SC-EXPORT-60 — Export không đổi dữ liệu thẻ (read-only)
Nguồn: schema (export chỉ đọc `cards`/`card_meanings`/`srs_state`)
Given: trước export ghi lại snapshot `cards`/`card_meanings`/`srs_state` của deck.
When: chạy export (mọi format, include-srs bật/tắt).
Then: DB: các bảng dữ liệu **bằng đúng** snapshot trước đó (export không mutate); chỉ có thể ghi `settings` (tuỳ chọn nhớ lựa chọn).

### SC-EXPORT-61 — Ghi nhớ lựa chọn vào `settings`
Nguồn: schema `settings` keys `export.format`, `export.include_srs`, `import.separator` (D-025/D-026)
Given: đổi format=Excel, separator=Semicolon, include-srs=OFF, rồi Export (hoặc rời màn — ⚠ thời điểm persist chưa rõ).
Then: DB: `settings.value` cho `export.format`=Excel, `import.separator`=Semicolon, `export.include_srs`=OFF (giá trị enum/bool đúng khoá).
  - ⚠ Xác nhận: lựa chọn có **được persist** không, và persist lúc nào (khi chọn / khi Export)? (schema có khoá nhưng UI-flow chưa chốt) — Open-Q #1.

### SC-EXPORT-62 — Kill & mở lại app → khôi phục lựa chọn
Given: SC-EXPORT-61 đã ghi `settings`.
When: kill app, mở lại, vào export cùng deck.
Then: UI: state `config` khôi phục **đúng** format/separator/include-srs từ `settings` (nếu persist theo Open-Q #1); nếu KHÔNG persist → về mặc định (assert theo quyết định Open-Q #1).

### SC-EXPORT-63 — Include-SRS round-trip nội dung
Nguồn: AC-3 · schema `srs_state.box`/`due_at`
Given: thẻ ở box 3 (`due_at` != NULL) và thẻ box 0 (`due_at`=NULL).
When: Export với include-srs ON.
Then: kết quả chứa cột box=3 + due_at (định dạng ngày — SC-EXPORT-70) cho thẻ 1; thẻ box 0 → box=0, due rỗng (⚠ định dạng ô rỗng — Open-Q #8). Round-trip: nội dung khớp giá trị DB, không bịa.

## 8. Định dạng & i18n

### SC-EXPORT-70 — Ngày `due_at` theo định dạng chuẩn
Nguồn: schema `srs_state.due_at` (epoch µs) · BR-4
Given: include-srs ON; thẻ có `due_at`.
Then: cột due trong file hiển thị ngày theo **định dạng ổn định** (⚠ ISO-8601 UTC? theo locale? — chưa có spec định dạng cột export → Open-Q #13). Assert: giá trị bắt nguồn từ `due_at` thật (không mock), không rỗng khi có due.

### SC-EXPORT-71 — Plural "Exported N cards"
Nguồn: DOM done "Exported 320 cards" (MOCK) · style DOM `font:20/800/30` tracking:-0.4 text:center (line 600)
Then: N=1 ⇒ dạng số ít; N=nhiều ⇒ dạng số nhiều — dùng **ARB plural**, không nối chuỗi. N đọc từ DB.
Style-parity (kit-is-source-of-truth): headline dùng **weight 800** (không phải 700 như appbar), `tracking:-0.4`, căn giữa (`text:center`), maxw 220 — chuỗi vẫn từ ARB nhưng font/tracking/align khớp DOM done title. Xem SC-EXPORT-03.

### SC-EXPORT-72 — Nội dung CJK (Hàn/Nhật) trong file
Nguồn: BR-4 (UTF-8; bảo toàn Hàn/Việt)
Given: thẻ `term`/`card_meanings.content` chứa Hàn ("사과") / Nhật ("りんご").
When: Export CSV/Excel.
Then: file mã hoá **UTF-8**, glyph CJK bảo toàn (không tofu/mojibake); ô chứa separator/newline được bọc trích dẫn (BR-4) → mở lại tách cột đúng.

### SC-EXPORT-73 — Ô chứa dấu phân tách / xuống dòng
Nguồn: BR-4
Given: nghĩa chứa dấu phẩy và/hoặc xuống dòng; separator=Comma.
Then: ô được bọc `"..."` theo chuẩn CSV, dấu `"` nội bộ được escape; import lại không vỡ cột.

### SC-EXPORT-74 — Nhãn UI dài / nhiều meaning
Given: thẻ có nhiều `card_meanings` (mỗi language một dòng).
Then: ⚠ cấu trúc cột khi 1 thẻ có N nghĩa (mỗi nghĩa 1 cột? nối? 1 dòng/nghĩa?) — chưa có spec cột export → Open-Q #14. UI section title (SCOPE/FORMAT/SEPARATOR) + nhãn dài không tràn (text-tertiary, tracking 0.5).

## 9. Dark mode

### SC-EXPORT-80 — Mọi state ở dark
Then: 3 state (`config`/`exporting`/`done`) render đúng ở **cả light + dark** bằng token (bg/surface/primary/on-primary-soft/success-soft/divider…), không hardcode màu; contrast nhãn/nút đạt; radio/chip/switch active phân biệt rõ ở dark.

## 10. Responsive

### SC-EXPORT-81 — 320px → tablet + xoay
Nguồn: DOM `config` app__body `scroll: scrollh:797` (line 94) vs viewport 716 · `exporting`/`done` app__body `layout_hint:scroll` **không kèm scrollh** (lines 475, 567 — nội dung ngắn hơn viewport, không tràn).
Then:
  - **State `config` (nội dung cao > viewport)**: ở 320px không overflow ngang — segmented 2 seg co giãn (grow:1 basis:0), card format 3 dòng + separator chip wrap/scroll gọn, nút Export full-width đáy. app__body **cuộn dọc được** (scrollh 797 > viewport 716 ⇒ overflow dọc thật, có scroll container); xoay ngang cuộn được; safe-area/notch OK. *Chỉ assert 797>716 cho state `config`* — đây là state duy nhất DOM phát ra `scrollh`.
  - **State `exporting`/`done` (nội dung ≤ viewport)**: app__body là scroll container (`layout_hint:scroll`) nhưng DOM **không** phát `scrollh` ⇒ **không** assert overflow/797>716 ở 2 state này. Assert: khối progress (exporting) / khối `export/done` (done) **căn giữa** (`justify:center align:center`) và không bị ép cuộn khi màn đủ cao; ở màn rất thấp (landscape) vẫn cuộn được nhờ scroll container mà không cắt nội dung. State done căn giữa vẫn cân ở tablet.

## 11. A11y

### SC-EXPORT-82 — Semantics & hit-area
Then:
  - `export/back`, `export/do-export`, `export/share`, `export/save`: có semantic label (từ ARB), hit-area ≥48 (back 48x48, nút minh:48).
  - segmented (`This deck`/`Incl. sub-decks`): đọc như **nhóm chọn 1** + trạng thái selected.
  - format radio ×3: role radio + selected/unselected + nhãn ("CSV"/"Excel"/"Copy text" + phụ đề).
  - separator chip ×3: đọc selected/unselected.
  - switch include-srs: role switch + on/off + nhãn "Include review state".
  - Thứ tự đọc: appbar → SCOPE → FORMAT → SEPARATOR → include-srs → Export; state done: tiêu đề "Exported N cards" đọc thành câu (không rời "320"/"cards").

## 12. Concurrency & edge thời gian

### SC-EXPORT-90 — Double-tap nút Export
Given: state `config`.
When: chạm "Export" nhanh 2 lần.
Then: chỉ khởi động **một** tiến trình export (không tạo 2 file / 2 lần chuyển state); lần chạm thứ 2 no-op khi đã rời `config`.

### SC-EXPORT-91 — Double-tap Share/Save (state done)
When: chạm "Share file" / "Save to device" nhanh 2 lần.
Then: chỉ mở **một** sheet share / một luồng save (không mở chồng 2 dialog).

### SC-EXPORT-92 — Đổi lựa chọn trong lúc chưa Export
When: đổi format ↔ separator ↔ scope ↔ switch nhiều lần trước khi Export.
Then: chỉ trạng thái **cuối cùng** được áp khi Export; radio/chip/switch phản ánh đúng lựa chọn cuối (không giữ lựa chọn cũ).

### SC-EXPORT-93 — Dữ liệu đổi giữa lúc mở màn (concurrency với sửa thẻ)
Given: mở export (config), ở màn khác thêm/xoá/ẩn thẻ trong deck (cascade D-024 / hidden D-006).
When: chạm Export.
Then: ⚠ Xác nhận: export đọc **snapshot lúc bấm Export** hay lúc mở màn? Số N ở `done` theo tập thẻ nào? — chưa có spec đồng thời → Open-Q #15. Assert tối thiểu: không crash, N nhất quán với tập đọc thực tế.

---

## Open questions (⚠ cần chốt spec trước khi viết test — KHÔNG bịa)

1. **Mặc định & persist lựa chọn**: format/separator/scope/include-srs mặc định lấy từ đâu (hằng số hay `settings` `export.format`/`import.separator`/`export.include_srs`)? Lựa chọn có được **ghi `settings`** không, và ghi lúc **chọn** hay lúc **Export**? (schema có khoá; UI-flow chưa chốt) → ảnh hưởng SC-EXPORT-01/14/17/20/61/62.
2. **Separator × format**: khi format = Excel hoặc Copy text, section SEPARATOR còn áp dụng không (separator là khái niệm CSV)? Chip có bị disable/ẩn khi không phải CSV? → SC-EXPORT-15/17.
3. **Phạm vi thẻ xuất**: N (số thẻ) tính theo scope (This deck vs Incl. sub-decks đệ quy D-009) — đã rõ; nhưng **có gồm thẻ ẩn `hidden=1`** (D-006) không? D-006 chỉ nói loại khỏi hàng đợi/đếm due, export là sao lưu → cần rule minh thị. → SC-EXPORT-03/44/63.
4. **Format = Copy text**: luồng ra sao — vẫn qua `exporting`→`done` với Share/Save, hay copy thẳng clipboard (không có file, Share/Save vô nghĩa)? → SC-EXPORT-16/23.
5. **Back/huỷ khi `exporting`**: cho huỷ + pop, hay chặn back tới khi xong? Huỷ có để lại file rác không? (DOM exporting không có nút cancel, vẫn có back). → SC-EXPORT-02/33/53.
6. **State `done` rời màn / Share / Save**: Share dùng OS share-sheet? Save đích ở đâu (Downloads/chọn thư mục)? Rời `done` chưa Save có nhắc gì? Có toast xác nhận (ARB)? → SC-EXPORT-23/24/34.
7. **Không có field nhập**: xác nhận export **không** có input text tự do (chỉ chọn rời rạc) ⇒ DoE mục 4 = N/A hợp lệ. Nếu có (vd đặt tên file) thì cần bổ sung validation.
8. **Include-SRS với thẻ box 0 / due NULL**: xuất box=0 + due rỗng thế nào (ô trống? "-"? bỏ)? → SC-EXPORT-20/63.
9. **Entry point trong deck-detail**: nút/menu-item "Export" ở đâu (more menu? action bar?)? (thuộc màn deck-detail, không có trong DOM export). → SC-EXPORT-30.
10. **Deep-link deckId sai/không tồn tại**: redirect / màn lỗi / empty? → SC-EXPORT-31.
11. **Deck 0 thẻ**: nút Export disable, hay ra `done` "Exported 0 cards" / thông báo "không có gì để xuất"? → SC-EXPORT-40.
12. **State lỗi export**: contract KHÔNG có state `error`. Khi encode/ghi lỗi hiện gì (về config + snackbar? dialog? state ẩn?) và cho retry ra sao? → SC-EXPORT-51.
13. **Định dạng cột ngày `due_at`**: ISO-8601 UTC / epoch / theo locale? Cột nào (chỉ due, hay cả last_reviewed_at)? → SC-EXPORT-70.
14. **Bố cục cột file**: cột nào xuất (term, meanings, box, due…)? Thẻ nhiều `card_meanings` biểu diễn thế nào (1 dòng/nghĩa? nối? nhiều cột)? Có header row không? → SC-EXPORT-63/70/74.
15. **Đồng thời sửa thẻ khi màn mở**: export đọc snapshot lúc mở màn hay lúc bấm Export? → SC-EXPORT-93.

16. **Kết quả đối chiếu citation BR/US/AC (audit 2026-07-08)** — file nghiệp vụ `business/import-export/import-export.md`
    **có tồn tại** và đã được đọc/đối chiếu trong lượt QA này. Kết luận: BR-3 (dòng 60), BR-4 (dòng 61), US-3 (dòng 37),
    AC-3 (dòng 69), §8 (dòng 74), §UC-2 luồng chính (dòng 49-52) **đều khớp** nội dung mà SC-EXPORT-18/20/23/43/72
    quy chiếu. **Một sai lệch đã sửa**: SC-EXPORT-51 trước ghi "§UC-2 luồng ngoại lệ", nhưng luồng ngoại lệ
    "nhập/xuất thất bại → thông báo lỗi, không ghi gì" thực nằm ở **§UC-1 dòng 46-47** (UC-2 chỉ có luồng chính,
    không có luồng ngoại lệ) → đã đổi citation. Không còn citation nào cần re-verify.

> Các mục ⚠ ở trên là **danh sách phải hỏi BA/spec**, không được đoán. Khi có câu trả lời → cập nhật scenario
> tương ứng + xoá cờ ⚠. Đây chính là "không bỏ sót": phần chưa rõ được **liệt kê ra**, không lờ đi.
