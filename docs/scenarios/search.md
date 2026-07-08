# Kịch bản — Tìm kiếm · screen `search`

Nguồn: `docs/contracts/search.md` [empty-recent · filtered · loading · no-results · results] ·
DOM `specs/search.md` · D-019, D-028, D-011 (badge/lọc dùng cùng một `srs_state` bất kể chiều — SC-SEARCH-74)
(D-006 gián tiếp: thẻ ẩn vẫn hiện) ·
BR `business/search/global-search.md` [BR-1 token AND · BR-2 gồm thẻ ẩn + lọc trạng thái · BR-3 phạm vi cặp/nút] ·
Nav `business/navigation/navigation-flow.md` [`/search`, param `query?`, push] ·
DB `cards`(term, hidden), `card_meanings`(content), `srs_state`(box, due_at), `settings`(`search.status_filter`),
`decks`(name), `language_pairs`(is_active).

> Số/tên/chuỗi trong kit là MOCK ("안녕하세요", "공부하다", "to study", "TOPIK I — Vocabulary", "xyz",
> "No matches", "All/New/Due/Mastered") — assert **định dạng, nguồn, cấu trúc**, KHÔNG assert giá trị mock.
> Mọi chuỗi hiển thị lấy từ ARB (`lib/l10n/`), không copy từ kit. State phải có thật trong contract;
> cột DB phải có thật trong schema-contract.

## DoE — search (12 chiều)

| # | Chiều | TT | Scenario / N/A(lý do) |
|---|---|---|---|
| 1 | States (5: empty-recent · filtered · loading · no-results · results) | ✅ | SC-SEARCH-01..05 |
| 2 | Elements (8 nhóm tương tác) | ✅ | SC-SEARCH-10..21 |
| 3 | Điều hướng vào/ra | ✅ | SC-SEARCH-30..36 |
| 4 | Nhập liệu & validation (field query) | ✅ | SC-SEARCH-40..48 |
| 5 | Lượng dữ liệu | ✅ | SC-SEARCH-50..55 |
| 6 | Async & lỗi | ✅ | SC-SEARCH-60..64 |
| 7 | Persistence (DB round-trip) | ✅ | SC-SEARCH-70..74 |
| 8 | Định dạng & i18n | ✅ | SC-SEARCH-80..85 |
| 9 | Dark mode | ✅ | SC-SEARCH-90 |
| 10 | Responsive | ✅ | SC-SEARCH-91 |
| 11 | A11y | ✅ | SC-SEARCH-92 |
| 12 | Concurrency & edge thời gian | ✅ | SC-SEARCH-95..98 |

Element inventory (từ DOM spec — mỗi cái ≥1 scenario ở mục 2):
`search/back` (icon-button arrow_back) · `search/dock__input` (field nhập query) · icon `search` (trang trí
trong dock) · `search/clear` (icon-button close — chỉ hiện khi có query: results/filtered/no-results/loading) ·
`search/filter-0..3` (chip lọc: All · New · Due · Mastered) · `search/result-N` (card kết quả, chạm mở thẻ) ·
badge trạng thái trên card (Due/Mastered/New) · icon `visibility_off` (thẻ ẩn trong kết quả) ·
`search/recent-0..2` (hàng gợi ý gần đây, empty-recent) · `search/recent-fill-N` (icon-button north_west — điền lại
truy vấn gần đây) · `search/no-results` (khối rỗng: icon search_off + tiêu đề + phụ đề).

> **Lưu ý parity (FE↔kit, có chủ đích — BR §Ghi chú giao diện):** hàng chip lọc `search/filters` được FE render
> ở **MỌI** state (kể cả empty-recent), trong khi kit ẩn nó ở empty-recent. Ghi tại
> `tool/parity/intent-ledger.json` (`search/filters`, `exceptionKind: behavior`). Scenario theo **hành vi FE**
> (chip luôn hiện) — xem SC-SEARCH-01 + SC-SEARCH-14.

---

## 1. States (mỗi state ≥1 scenario)

### SC-SEARCH-01 — empty-recent (mở màn, chưa gõ)
Nguồn: contract[empty-recent] · spec base · BR-3 · parity(search/filters luôn hiện)
Tiền điều kiện (Given):
  - DB: `language_pairs`(1 dòng `is_active=1`); `cards`/`card_meanings` có dữ liệu bất kỳ.
  - Có lịch sử truy vấn gần đây ≥1 (nguồn recent — xem Open Q #2).
Thao tác (When):
  1. Điều hướng vào `/search` không kèm `query` (dock rỗng).
Kỳ vọng (Then):
  - UI: appbar[back + search-dock(icon search + input rỗng, KHÔNG có nút clear)] · nhãn section "RECENT" (ARB) ·
    card gợi ý với ≥1 hàng recent (icon history + chuỗi truy vấn + nút north_west) · **KHÔNG** có card kết quả ·
    **KHÔNG** khối no-results · **KHÔNG** skeleton.
  - UI (parity FE): hàng chip lọc `search/filters` (All/New/Due/Mastered) **vẫn hiển thị** đầu body (khác kit).
  - DB: chỉ đọc, không ghi.
  - ⚠ Nguồn "recent" chưa có trong schema-contract (không có bảng recent-queries) → xem Open Q #2.

### SC-SEARCH-02 — results (có kết quả khớp)
Nguồn: contract[results] · spec "results" · D-019/BR-1 · D-028/BR-2
Given:
  - DB: `cards`(≥3 dòng, `hidden=0`) trong cặp active; mỗi thẻ có `card_meanings`(content) khớp; `srs_state` đa dạng box.
When:
  1. Vào `/search` · gõ 1 token khớp `term` HOẶC `content` của ≥1 thẻ.
Then:
  - UI: appbar có nút `search/clear` (close) hiện lên · hàng chip lọc (chip `All` active = bg primary-soft) ·
    danh sách card `search/result-N`, mỗi card = term (đậm) + nghĩa (phụ) + tên deck nguồn + badge trạng thái.
  - DB: kết quả = mọi thẻ trong cặp active mà token khớp `cards.term` OR `card_meanings.content` (LIKE, BR-1);
    số card hiển thị = số dòng khớp (assert đếm khớp query DB, KHÔNG assert giá trị mock).
  - Badge nguồn từ `srs_state.box`: box 0 → "New", `due_at<=now` → "Due", box 8 → "Mastered" (nhãn từ ARB) —
    ⚠ ánh xạ nhãn↔trạng thái cần xác nhận (Open Q #4).

### SC-SEARCH-03 — filtered (áp chip lọc trạng thái)
Nguồn: contract[filtered] · spec "filtered" diff · D-028/BR-2
Given: đang ở results (SC-SEARCH-02); có thẻ ở đủ trạng thái new/due/mastered khớp truy vấn.
When:
  1. Chạm chip `search/filter-2` ("Due").
Then:
  - UI: chip "Due" đổi sang active (bg primary-soft, color on-primary-soft); các chip khác về surface/text-secondary ·
    danh sách chỉ còn card có trạng thái Due.
  - DB: kết quả = tập con của truy vấn AND `srs_state.due_at != NULL AND due_at <= now` (D-028); các trạng thái khác bị loại.
  - DB: giá trị chip đang chọn ghi `settings(key='search.status_filter', value='due')` — ⚠ xác nhận có persist per-session
    hay per-app (Open Q #5).

### SC-SEARCH-04 — no-results (không khớp)
Nguồn: contract[no-results] · spec "no results" · D-019
Given: DB không có thẻ nào khớp token trong cặp active.
When:
  1. Vào `/search` · gõ token không khớp thẻ nào.
Then:
  - UI: hàng chip lọc vẫn hiện · khối `search/no-results` = icon-tile(search_off) + tiêu đề (ARB, vd "Không có kết quả") +
    phụ đề chèn lại truy vấn người dùng (ARB có placeholder `{query}`, KHÔNG hardcode "xyz") · nút clear hiện.
  - DB: query trả 0 dòng.
  - ⚠ Phụ đề kit chèn "xyz" trong nháy nháy “…” → FE phải chèn truy vấn thật qua ARB placeholder (Open Q #6 về nội dung copy).

### SC-SEARCH-05 — loading (đang truy vấn)
Nguồn: contract[loading] · spec "loading"
Given: provider search chưa resolve (truy vấn đang chạy).
When:
  1. Gõ token → trong lúc chờ kết quả.
Then:
  - UI: hàng chip lọc vẫn hiện · 3 card skeleton (`mxg-skel` × 3 dòng/card, bg surface-sunken) thay cho kết quả thật ·
    nút clear hiện · KHÔNG số/chữ thật, không crash.
  - ⚠ Với LIKE local (<200ms, NFR §8) loading có thể chớp nhoáng/không tới được thực tế → xem Open Q #7 (đây là **spec đích**,
    test có thể phải bơm delay giả để chạm state).

---

## 2. Elements (mỗi phần tử tương tác ≥1 scenario)

### SC-SEARCH-10 — Nút back (`search/back`)
Nguồn: spec `search/back` (icon-button arrow_back) · Nav (push → pop)
When: chạm back.
Then: UI pop khỏi `/search`, trở về màn nguồn (Library/deck-detail); DB không ghi. Semantic label + hit-area ≥48.

### SC-SEARCH-11 — Field nhập (`search/dock__input`)
Nguồn: spec `search-dock__input` · D-019/BR-1
When: focus input, gõ ký tự.
Then: UI input hiển thị text đang gõ · khi có ≥1 ký tự → nút `search/clear` xuất hiện (diff filtered/results) ·
kết quả cập nhật theo token (BR-1). ⚠ Có debounce không & mấy ms? (Open Q #7).

### SC-SEARCH-12 — Icon search (trang trí)
Nguồn: spec icon `search` trong dock (color text-tertiary)
Then: hiển thị icon tĩnh, KHÔNG tương tác (không phải nút). Assert: không nhận tap-handler riêng.

### SC-SEARCH-13 — Nút clear (`search/clear`)
Nguồn: spec `search/clear` (icon-button close, chỉ có ở results/filtered/no-results/loading — vắng ở empty-recent)
Given: đang ở results với query khác rỗng.
When: chạm clear.
Then: UI input về rỗng · màn trở lại empty-recent (recent + chip lọc) · nút clear biến mất · reset chip lọc về "All"?
(⚠ xác nhận clear có reset filter không — Open Q #5). DB không ghi (trừ có thể reset `search.status_filter`).

### SC-SEARCH-14 — Chip lọc All (`search/filter-0`)
Nguồn: spec `search/filter-0` "All" (active mặc định, bg primary-soft) · D-028
Given: đang ở filtered (vd đang lọc Due).
When: chạm chip "All".
Then: UI chip "All" active, bỏ lọc trạng thái · danh sách trở lại toàn bộ thẻ khớp truy vấn (gồm new+due+mastered, và thẻ ẩn).
DB: bỏ ràng buộc box/due; `settings(search.status_filter)` = giá trị "all"/rỗng (⚠ Open Q #5).

### SC-SEARCH-15 — Chip New (`search/filter-1`)
Nguồn: spec `search/filter-1` "New" · D-028
When: chạm "New".
Then: UI chỉ còn thẻ New. DB: kết quả AND `srs_state` box=0 (hoặc không có srs_state → new) — ⚠ định nghĩa "New" (box 0 vs chưa có row) cần chốt (Open Q #4).

### SC-SEARCH-16 — Chip Due (`search/filter-2`)
Nguồn: spec `search/filter-2` "Due" · D-028 — (xem SC-SEARCH-03).
Then: DB: AND `srs_state.due_at != NULL AND due_at <= now`.

### SC-SEARCH-17 — Chip Mastered (`search/filter-3`)
Nguồn: spec `search/filter-3` "Mastered" · D-028
When: chạm "Mastered".
Then: UI chỉ còn thẻ Mastered. DB: AND `srs_state.box = 8` (D-005/schema: box 8 = mastered).

### SC-SEARCH-18 — Card kết quả (`search/result-N`) → mở thẻ
Nguồn: spec `search/result-N` (card term+nghĩa+deck+badge) · UC-1 hậu điều kiện "mở một thẻ"
When: chạm 1 card kết quả.
Then: UI điều hướng tới đích mở thẻ đó. ⚠ Đích chính xác chưa có trong Nav (route mở thẻ = flashcardEditor `/deck/:id/card`?
hay deck-detail cuộn tới thẻ?) → Open Q #1. Assert tối thiểu: tap có phản hồi, push đi ra 1 lần.

### SC-SEARCH-19 — Badge trạng thái trên card
Nguồn: spec badge (Due=error-soft · Mastered=success-soft · New=primary-soft)
Then: mỗi card hiển thị đúng badge theo `srs_state` của thẻ (nhãn ARB, màu theo token). ⚠ ánh xạ trạng thái↔badge (Open Q #4).

### SC-SEARCH-20 — Thẻ ẩn trong kết quả (icon `visibility_off`)
Nguồn: spec result-2 có icon `visibility_off` + op:0.5 · D-006/D-028/BR-2 (thẻ ẩn vẫn hiện trong search)
Given: DB có 1 thẻ `cards.hidden=1` khớp truy vấn.
When: tìm token khớp thẻ ẩn.
Then: UI thẻ ẩn **vẫn hiển thị** trong kết quả, có chỉ báo ẩn (icon visibility_off + card mờ op:0.5).
DB: thẻ `hidden=1` nằm trong tập kết quả (D-028 — khác với queue học vốn loại thẻ ẩn theo D-006).

### SC-SEARCH-21 — Hàng recent + nút điền lại (`search/recent-N`, `search/recent-fill-N`)
Nguồn: spec `search/recent-0..2` + `search/recent-fill-N` (icon-button north_west)
Given: empty-recent có ≥1 hàng recent.
When: (a) chạm nút north_west của 1 hàng recent; (b) chạm cả hàng.
Then: UI điền lại truy vấn đó vào dock → chuyển sang results/no-results tương ứng.
⚠ Nguồn danh sách recent + hành vi (chạm hàng vs chạm nút có khác nhau?) chưa có spec/DB → Open Q #2.

---

## 3. Điều hướng vào/ra

### SC-SEARCH-30 — Entry point vào `/search`
Nguồn: Nav (`/search` push, mở từ library/deck-detail)
When: từ Library (hoặc deck-detail) kích hoạt hành động mở tìm kiếm.
Then: push `/search`. ⚠ Control nào mở search chưa xác định trong DOM các màn khác (không có nút "search" trong dashboard spec)
→ Open Q #1. Assert: màn search mở ở empty-recent khi không kèm `query`.

### SC-SEARCH-31 — Deep-link `/search?query=...`
Nguồn: Nav (param `query?`)
When: mở `/search` kèm `query` khác rỗng.
Then: UI dock điền sẵn query, chạy tìm ngay → results/no-results/loading tương ứng (bỏ qua empty-recent).
⚠ Nav ghi "Không deep-link ngoài v1" — param query? là nội bộ (điền từ recent/nút) hay có deep-link? Open Q #1/#2.

### SC-SEARCH-32 — Tìm trong phạm vi 1 nút (in-node)
Nguồn: BR-3 (phạm vi toàn thư viện HOẶC trong nút đang mở)
When: mở search từ trong deck-detail của 1 nút.
Then: kết quả giới hạn thẻ thuộc nút đó (đệ quy subtree, D-009). DB: kết quả AND `cards.deck_id ∈ subtree(node)`.
⚠ `/search` không có param nodeId trong route table → cơ chế truyền phạm vi chưa rõ (Open Q #3).

### SC-SEARCH-33 — Back/pop khỏi search
Nguồn: Nav (push → pop)
When: nhấn back hệ thống hoặc nút `search/back`.
Then: pop về màn nguồn, giữ nguyên state màn nguồn (StatefulShellRoute nếu về tab).

### SC-SEARCH-34 — Giữ/khôi phục vị trí cuộn kết quả
Given: results dài, cuộn xuống, chạm 1 card → mở thẻ → back.
Then: ⚠ search là màn push (không thuộc shell) — quay lại có giữ query+cuộn không hay dựng lại? Open Q #8.

### SC-SEARCH-35 — Swipe-dismiss (iOS back gesture)
Then: vuốt cạnh trái pop khỏi search (tương đương back). Assert: về màn nguồn, không mất dữ liệu màn nguồn.

### SC-SEARCH-36 — Không có bottom-nav/FAB trong search
Nguồn: spec (DOM search không có bottom-nav, không FAB)
Then: màn search KHÔNG hiển thị bottom-nav (là màn push toàn khung), không Review FAB.

---

## 4. Nhập liệu & validation (field `search/dock__input`)

### SC-SEARCH-40 — Query rỗng
When: input rỗng (chưa gõ / xoá hết).
Then: UI hiện empty-recent (recent + chip), KHÔNG chạy tìm, KHÔNG no-results. DB: không truy vấn.

### SC-SEARCH-41 — Chỉ khoảng trắng
Nguồn: BR-1 (tách token theo khoảng trắng)
When: gõ toàn dấu cách "   ".
Then: ⚠ sau khi tách token → 0 token hợp lệ → coi như rỗng (về empty-recent) hay chạy tìm rỗng? Cần chốt (Open Q #9). Assert đích:
trim → 0 token → empty-recent, không lỗi.

### SC-SEARCH-42 — Đa token (AND)
Nguồn: BR-1/D-019/AC-4
When: gõ 2 token, token A khớp `term`, token B khớp `content` của **cùng** một thẻ.
Then: UI thẻ đó hiển thị; thẻ chỉ khớp 1 token KHÔNG hiển thị.
DB: kết quả = thẻ mà (A khớp term|content) AND (B khớp term|content) — AND giữa token (BR-1).

### SC-SEARCH-43 — Token dài / biên max
When: gõ chuỗi rất dài (vd > độ dài term dài nhất, hàng trăm ký tự).
Then: UI input không vỡ layout (cuộn ngang trong dock/ellipsis) · tìm trả 0 dòng nếu không khớp (no-results), không crash.
⚠ có giới hạn độ dài query không? (Open Q #9).

### SC-SEARCH-44 — Ký tự đặc biệt / emoji
When: gõ ký tự đặc biệt (`% _ ' " \`) và emoji.
Then: UI hiển thị đúng · DB: LIKE phải **escape** `%` và `_` (ký tự wildcard SQL) để tìm literal, không khớp sai hàng loạt.
⚠ escape wildcard cần xác nhận đã xử lý (rủi ro: `%` → khớp mọi thẻ). Đây là **spec đích** — test phải khẳng định `%` chỉ khớp literal.

### SC-SEARCH-45 — CJK (Hàn/Nhật)
Nguồn: D-019 · kit dùng term CJK (안녕하세요, 공부하다)
When: gõ token tiếng Hàn/Nhật.
Then: UI render đúng glyph CJK (không tofu) · DB: LIKE khớp `term`/`content` chứa chuỗi CJK; khớp chuỗi con Unicode đúng.

### SC-SEARCH-46 — Trùng term (nhiều thẻ cùng term)
Nguồn: D-020 (soft-dup: cùng term trong deck vẫn cho thêm)
Given: DB có ≥2 thẻ cùng `term` khớp truy vấn.
Then: UI hiển thị **tất cả** thẻ trùng term (mỗi card 1 dòng), phân biệt bằng nghĩa/deck nguồn. DB: đếm card = số dòng khớp (không gộp).

### SC-SEARCH-47 — Trim đầu/cuối
When: gõ " 학교 " (có khoảng trắng bao quanh).
Then: DB: tách token bỏ khoảng trắng thừa → tìm token "학교" (BR-1). Assert: kết quả giống khi gõ không có space thừa.

### SC-SEARCH-48 — Khớp giữa chuỗi (substring, 1 token)
Nguồn: BR-1 ("một token đơn = khớp chuỗi con như cũ")
When: gõ 1 token là chuỗi con của term/nghĩa (không phải prefix).
Then: DB: LIKE `%token%` khớp cả khi token nằm giữa chuỗi. Assert: thẻ có term chứa token ở giữa vẫn xuất hiện.

---

## 5. Lượng dữ liệu

### SC-SEARCH-50 — 0 kết quả
→ no-results (SC-SEARCH-04).

### SC-SEARCH-51 — 1 kết quả
Then: UI đúng 1 card; không có khoảng trống/lỗi layout.

### SC-SEARCH-52 — Nhiều kết quả (cuộn)
Given: >20 thẻ khớp.
Then: UI body cuộn được (layout_hint:scroll), mọi card render đúng; không overflow.

### SC-SEARCH-53 — Rất nhiều (lazy/perf)
Given: thư viện lớn (hàng nghìn thẻ), truy vấn khớp nhiều.
Then: ⚠ có lazy/pagination không? (spec chỉ nêu NFR <200ms, không nêu paging) → Open Q #10. Assert đích: trả trong ngưỡng, không đơ UI.

### SC-SEARCH-54 — 0 recent (empty-recent không có lịch sử)
Given: chưa có truy vấn gần đây.
Then: ⚠ empty-recent hiển thị gì khi 0 recent? (kit chỉ vẽ trạng thái CÓ recent) → Open Q #2. Assert đích: không card recent rỗng vỡ layout.

### SC-SEARCH-55 — Biên: thẻ ẩn chiếm toàn bộ kết quả
Given: mọi thẻ khớp đều `hidden=1`.
Then: UI vẫn hiện đủ (D-028), tất cả có chỉ báo ẩn; KHÔNG rơi vào no-results (khác queue học).

---

## 6. Async & lỗi

### SC-SEARCH-60 — loading → results
Nguồn: contract[loading]→[results]
Then: gõ token → skeleton (nếu chạm được) → thay bằng card thật khi resolve.

### SC-SEARCH-61 — Truy vấn thất bại (đọc DB lỗi)
Then: ⚠ contract search KHÔNG có state `error` → hiện gì khi query DB lỗi? (inline error? giữ kết quả cũ? empty?) → Open Q #11.
Lỗi phải nổi cả cho người dùng (surface ARB) lẫn dev (log/report), không nuốt lỗi (CLAUDE.md §5).

### SC-SEARCH-62 — Retry sau lỗi
Given: query lỗi 1 lần.
When: gõ lại / thử lại.
Then: ⚠ cơ chế retry (tự động khi gõ tiếp? nút thử lại?) chưa có spec → Open Q #11.

### SC-SEARCH-63 — Local-first (không mạng)
Nguồn: kiến trúc local-first (schema §Scope: no remote backend)
Then: search chạy hoàn toàn từ DB local; tắt mạng vẫn trả kết quả đầy đủ.

### SC-SEARCH-64 — Huỷ truy vấn giữa chừng (gõ nhanh)
When: gõ token A (đang chạy) rồi gõ tiếp token B trước khi A xong.
Then: kết quả cuối cùng khớp token B (huỷ/bỏ kết quả A cũ, không race hiển thị sai). ⚠ debounce/cancel — Open Q #7.

---

## 7. Persistence (DB round-trip)

### SC-SEARCH-70 — Kết quả phản ánh DB hiện tại
Nguồn: D-019/D-028 (đọc `cards`+`card_meanings`+`srs_state`)
Given: DB có bộ thẻ đã seed.
When: tìm.
Then: DB: mọi card hiển thị tồn tại thật trong `cards`/`card_meanings` của cặp `is_active=1`; term/nghĩa/deck-name khớp cột thật
(`cards.term`, `card_meanings.content`, `decks.name`). Search là read-only — KHÔNG ghi `cards`/`srs_state`.

### SC-SEARCH-71 — Persist bộ lọc trạng thái
Nguồn: schema `settings(key='search.status_filter', new·due·mastered)` · D-028
When: chọn chip "Due".
Then: DB: ghi `settings` dòng `key='search.status_filter'`, `value='due'` (giá trị enum hợp lệ new/due/mastered).
⚠ xác nhận có persist "all" và có áp lại khi mở màn sau không (Open Q #5).

### SC-SEARCH-72 — Kill & mở lại app
Given: đã chọn filter "Mastered".
When: kill app → mở lại → vào search.
Then: ⚠ nếu filter persist (SC-SEARCH-71) → chip "Mastered" active lại; nếu không → về "All". Cần chốt (Open Q #5).
Recent (nếu có persist) hiển thị lại — Open Q #2.

### SC-SEARCH-73 — Cascade xoá phản ánh vào search
Nguồn: D-024 (xoá deck → cascade cards/meanings/srs_state)
Given: đã xoá 1 deck chứa thẻ từng khớp truy vấn.
When: tìm lại cùng token.
Then: DB: các thẻ thuộc deck đã xoá KHÔNG còn trong kết quả (đã cascade khỏi `cards`/`card_meanings`).

### SC-SEARCH-74 — Badge & lọc dùng CÙNG một `srs_state` bất kể chiều hiển thị (D-011)
Nguồn: D-011 / BR-6 (`business/srs/srs-review.md`: "Mỗi thẻ có **một** trạng thái lịch (một chiều);
đảo chiều hiển thị không tạo lịch riêng") · badge suy ra từ `srs_state` (SC-SEARCH-19) · chip lọc lọc theo `srs_state` (D-028)
Given:
  - DB: 1 thẻ trong cặp active có **một** dòng `srs_state` (một chiều duy nhất — không có dòng lịch thứ hai cho chiều đảo).
  - Cặp cho phép học/hiển thị cả hai chiều (KO→VI và VI→KO) nhưng **dùng chung** dòng `srs_state` đó.
When:
  1. Tìm token khớp thẻ này → xem badge trên card.
  2. Áp chip lọc trạng thái (New/Due/Mastered) khớp với `srs_state` của thẻ.
Then:
  - DB: badge trạng thái đọc từ **đúng một** dòng `srs_state` của thẻ; KHÔNG có nhánh chọn lịch theo chiều hiển thị
    (không tồn tại `srs_state` per-direction — D-011/BR-6). Badge (New/Due/Mastered) và bộ lọc **cùng** suy ra từ một `box`/`due_at`.
  - DB: khi lọc theo trạng thái, thẻ chỉ vào/ra tập kết quả theo `srs_state` chung đó — **không** phụ thuộc thẻ đang được
    hiển thị/khớp ở chiều KO→VI hay VI→KO. Đảo chiều hiển thị KHÔNG đổi badge, KHÔNG đổi việc thẻ có lọt bộ lọc hay không.
  - UI: một thẻ = một badge nhất quán ở mọi chiều; không có trường hợp cùng thẻ hiện 2 badge khác nhau theo chiều.

---

## 8. Định dạng & i18n

### SC-SEARCH-80 — Nhãn chip/section từ ARB (không copy kit)
Nguồn: BR (chuỗi từ ARB) · kit MOCK "All/New/Due/Mastered/RECENT"
Then: nhãn chip + "RECENT" + tiêu đề no-results lấy từ ARB; đổi locale → đổi chuỗi tương ứng, không hardcode tiếng Anh kit.

### SC-SEARCH-81 — CJK trong kết quả (không tofu)
Then: term/nghĩa chứa Hàn/Nhật render đúng glyph ở mọi card; font hỗ trợ CJK.

### SC-SEARCH-82 — Text dài (term/nghĩa/deck-name)
Then: term rất dài → ellipsis/wrap trong card (spec div term có `clip`); nghĩa/deck-name dài không đẩy vỡ card hay badge.

### SC-SEARCH-83 — Phụ đề no-results chèn query
Nguồn: spec no-results phụ đề chèn “xyz” · ARB placeholder `{query}`
Then: phụ đề dùng ARB có placeholder, chèn đúng query người dùng (kể cả CJK/ký tự đặc biệt); không nối chuỗi thủ công.

### SC-SEARCH-84 — Số lượng / plural (nếu có đếm kết quả)
Then: ⚠ kit KHÔNG hiện "N kết quả" → nếu FE thêm đếm phải dùng ARB plural; nếu không có counter thì N/A. Open Q #12.

### SC-SEARCH-85 — RTL
Then: ⚠ v1 locale (vi/en/CJK) không RTL → **N/A** cho tới khi thêm ngôn ngữ RTL. Ghi nhận: layout dùng flex (không hardcode LTR),
nếu thêm RTL sau, chip/badge/icon phải mirror.

---

## 9. Dark mode

### SC-SEARCH-90 — Mọi state ở dark
Then: 5 state (empty-recent/results/filtered/no-results/loading) render đúng ở cả light+dark bằng token
(bg/surface/surface-sunken/primary-soft/error-soft/success-soft/warning-soft, text/on-* tương phản đạt);
KHÔNG hardcode màu. Skeleton `surface-sunken`, badge & chip theo token đổi đúng ở dark.

---

## 10. Responsive

### SC-SEARCH-91 — 320px → tablet + xoay
Then: 320px: dock + chip lọc không overflow (hàng chip cuộn ngang — spec `layout_hint:scroll`); card co giãn theo bề rộng;
tablet: card không kéo giãn xấu (max-width hợp lý); xoay ngang: body cuộn được; safe-area/notch OK; nút back/clear ≥48 vẫn đủ chạm.

---

## 11. A11y

### SC-SEARCH-92 — Semantics & focus order
Then: `search/back` (label "quay lại"), `search/dock__input` (label ô tìm kiếm + hint), `search/clear` (label "xoá"),
mỗi chip lọc (label + trạng thái selected), mỗi card kết quả (đọc thành câu: term + nghĩa + trạng thái, KHÔNG đọc rời badge),
nút recent-fill (label "điền lại truy vấn X"). Hit-area ≥48. Thứ tự đọc: back → ô tìm → clear → chip lọc → kết quả.
Chip selected phải báo trạng thái toggled cho screen-reader. Contrast text-tertiary trên surface đạt AA.

---

## 12. Concurrency & edge thời gian

### SC-SEARCH-95 — Double-tap card kết quả
When: chạm nhanh 2 lần 1 card.
Then: chỉ push mở thẻ **một** lần (không mở 2 màn/2 push).

### SC-SEARCH-96 — Double-tap chip lọc
When: chạm nhanh 2 lần 1 chip.
Then: chip toggle ổn định (không nhấp nháy trạng thái, không chạy 2 query chồng); kết quả cuối nhất quán với chip đang chọn.

### SC-SEARCH-97 — Back khi đang loading
When: gõ token (đang loading) rồi bấm back ngay.
Then: pop an toàn, huỷ query đang chạy, không setState-sau-dispose/crash.

### SC-SEARCH-98 — Đổi `due_at` qua mốc thời gian trong lúc lọc "Due"
Nguồn: `srs_state.due_at` phụ thuộc `now` (lịch SRS — `business/srs/srs-review.md`) · D-028 (chip "Due" = `due_at<=now`)
(⚠ KHÔNG dựa D-021: D-021 chỉ nói streak reset lúc nửa đêm, KHÔNG quy định tính lại `due_at` theo `now`.
Cơ chế "Due" refresh theo `now` chưa có trong bảng quyết định → để trong Open Q #13.)
Given: đang lọc "Due"; 1 thẻ có `due_at` vừa qua/sắp tới `now`.
When: thời gian trôi qua mốc `due_at` (hoặc re-query).
Then: ⚠ danh sách "Due" cập nhật theo `now` mới khi truy vấn lại; có tự refresh realtime không hay chỉ khi re-query? Open Q #7/#14.
Assert đích tối thiểu: khi re-query, tập "Due" = truy vấn AND `due_at != NULL AND due_at <= now` với `now` tại thời điểm truy vấn
(nguồn ngưỡng "Due" = lịch SRS `business/srs/srs-review.md` + D-028, KHÔNG phải D-021).

---

## Open questions (⚠ cần chốt spec trước khi viết test — KHÔNG bịa)

1. **Entry point + đích mở thẻ**: control nào mở `/search` (không thấy nút search trong DOM dashboard/library spec)?
   Chạm 1 card kết quả điều hướng tới đâu — `flashcardEditor` (`/deck/:id/card`), deck-detail cuộn tới thẻ, hay màn xem thẻ riêng?
2. **Recent queries**: nguồn danh sách "RECENT" — schema-contract KHÔNG có bảng recent-queries; lưu ở đâu (settings? bảng mới?),
   có persist qua kill không, tối đa mấy mục, chạm hàng vs chạm nút north_west khác nhau thế nào, cách xoá 1 recent?
3. **Phạm vi in-node (BR-3)**: `/search` route không có param `nodeId` — làm sao truyền phạm vi "trong nút đang mở" (D-009 subtree)?
4. **Ánh xạ trạng thái↔badge/chip**: "New" = `srs_state.box=0` hay "chưa có row srs_state"? "Due" = `due_at<=now`?
   "Mastered" = `box=8`? Thẻ box 0 nhưng chưa có row có tính New không? (schema: box 0 = new/unscheduled).
5. **Persist filter**: `settings.search.status_filter` có được áp lại khi mở màn sau/relaunch không? Nút clear/chip All có reset filter?
   "All" lưu giá trị gì (rỗng/null/'all')?
6. **Copy no-results/empty**: nội dung ARB cho tiêu đề + phụ đề no-results (kit MOCK "No matches"/"Nothing matched …"),
   và có empty-recent copy khi 0 recent không?
7. **Debounce / cancel / realtime**: gõ có debounce (mấy ms)? Query cũ có bị cancel khi gõ tiếp? "Due" có tự refresh theo `now`?
8. **Giữ state khi pop-back**: search là màn push — quay lại (từ mở thẻ) có giữ query+filter+vị trí cuộn hay dựng lại empty-recent?
9. **Validation query**: chỉ-khoảng-trắng → coi rỗng hay tìm rỗng? Có giới hạn độ dài query? (schema không nêu).
10. **Data volume lớn**: có lazy-load/pagination cho kết quả không, hay tải hết (NFR chỉ nêu <200ms)?
11. **State error**: contract search không có `error` — hiển thị gì khi đọc DB lỗi? Có retry (tự động/nút)?
12. **Đếm kết quả**: FE có hiển thị "N kết quả" (cần ARB plural) hay không có counter?
13. **Escape LIKE wildcard**: `%`/`_` trong query có được escape để khớp literal không? (rủi ro `%` khớp mọi thẻ) — cần khẳng định.
14. **"Due" refresh theo `now`**: khi lọc "Due" đang mở mà thời gian trôi qua mốc `due_at`, danh sách có tự refresh realtime
    hay chỉ cập nhật khi re-query? (ngưỡng "Due" thuộc lịch SRS `srs-review.md` + D-028; **KHÔNG** liên quan D-021/streak.)

> Các mục ⚠ là **danh sách phải hỏi BA/spec**, KHÔNG được đoán. Có câu trả lời → cập nhật scenario tương ứng + xoá cờ ⚠.
> Đây chính là "không bỏ sót": phần chưa rõ được **liệt kê ra**, không lờ đi.
