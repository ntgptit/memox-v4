# Kịch bản — Deck Detail (node cây) · screen `deck-detail`

Nguồn: `docs/contracts/deck-detail.md` [add-menu · card-actions · deck-delete-confirm · deck-menu ·
delete-confirm · empty · error · loaded · loading · move · no-results · reset-confirm · search] (13 state) ·
DOM `specs/deck-detail.md` · D-006, D-009, D-011, D-019, D-020, D-023, D-024, D-028 (D-001/D-002/D-016 gián tiếp
khi chạm Play/Add) · BR `business/deck/deck-management.md` (BR-1..6) + `business/flashcard/flashcard-management.md`
(BR-1..6) + `business/search/global-search.md` (BR-1..3) · DB `decks`, `cards`, `card_meanings`, `srs_state`,
`review_logs`, `study_sessions`, `settings`.

> Số/tên/chuỗi trong kit là MOCK ("Korean Basics", "안녕하세요", "3 decks · 412 words", "28", "Due/New/Mastered",
> "Nothing matched "xyz"") — assert **định dạng & nguồn**, KHÔNG assert giá trị mock. Chuỗi lấy từ ARB, không
> copy kit. State phải có thật trong contract; cột DB phải có thật trong schema-contract.

## DoE — deck-detail (12 chiều)

| # | Chiều | TT | Scenario / N/A |
|---|---|---|---|
| 1 | States (13) | ✅ | SC-DECKDETAIL-01..13 |
| 2 | Elements (mỗi node DOM ≥1) | ✅ | SC-DECKDETAIL-20..49 + 49a (icon:search) + 49b/49c (2 biến thể badge sub-deck) |
| 3 | Nav vào/ra | ✅ | SC-DECKDETAIL-50..57 |
| 4 | Nhập liệu & validation | ✅ / phần lớn N/A(*) | SC-DECKDETAIL-60..66 — (*) màn chỉ có 1 field nhập trực tiếp (search-dock__input); empty→state + LIKE-escape KHÔNG có nguồn ⇒ thuần Open questions #10 (không assert đoán, SC-60/65); rename/add-word có field nhưng nằm ở màn `flashcardEditor` / dialog rename **ngoài** DOM spec màn này ⇒ Open questions #5 |
| 5 | Lượng dữ liệu | ✅ | SC-DECKDETAIL-70..76 |
| 6 | Async & lỗi | ✅ | SC-DECKDETAIL-80..84 |
| 7 | Persistence (DB round-trip) | ✅ | SC-DECKDETAIL-90..96 |
| 8 | Định dạng & i18n | ✅ | SC-DECKDETAIL-100..105 + 101a (meta 'M words · mastered') + 102a (badge trạng thái bất biến, D-011) |
| 9 | Dark mode | ✅ | SC-DECKDETAIL-110 |
| 10 | Responsive | ✅ | SC-DECKDETAIL-111 |
| 11 | A11y | ✅ | SC-DECKDETAIL-112 |
| 12 | Concurrency & edge thời gian | ✅ | SC-DECKDETAIL-120..124 |

**Element inventory** (từ DOM spec — mỗi phần tử ≥1 scenario ở mục 2):
- **appbar**: `deck-detail/back` (icon-button arrow_back) · `appbar__title` (tên deck) · `deck-detail/play-audio`
  (icon-button volume_up) · `deck-detail/menu` (icon-button more_vert).
- **body loaded**: `deck-detail/search-dock` (+ leading `icon:search` non-interactive, color:text-tertiary) +
  `search-dock__input` · `deck-detail/sort` (icon-button swap_vert) · div "SUB-DECKS" · `deck-detail/subdeck-0/1`
  (card + icon-tile + tên + meta [2 dạng: "N decks · M words" / "M words · mastered"] + progress + badge
  [2 biến thể: số primary-soft / "✓" success-soft]) · div "CARDS" ·
  `deck-detail/card-0..5` (card: term + nghĩa + badge Due/Mastered/New; card-5 có icon `visibility_off` + op:0.5 =
  thẻ ẩn) · `deck-detail/add` (FAB).
- **search state**: `deck-detail/search-clear` (icon-button close, thay sort) · `deck-detail/filters` +
  `filter-0..3` (chip All/New/Due/Mastered) · `deck-detail/result-0..n`.
- **no-results state**: `deck-detail/nr-filter-0..3` (chip) · `deck-detail/no-results` (empty-illustration).
- **empty state**: `deck-detail/empty` + `deck-detail/empty-add` · `deck-detail/empty-subdeck` ·
  `deck-detail/empty-import` (3 btn).
- **error state**: `deck-detail/error` + `deck-detail/retry` (btn).
- **add-menu (sheet)**: `deck-detail/add-scrim` · `deck-detail/add-sheet` · `deck-detail/add-word` ·
  `deck-detail/add-subdeck` · `deck-detail/add-import`.
- **card-actions (sheet)**: `deck-detail/actions-scrim` · `deck-detail/actions-sheet` · `deck-detail/action-edit` ·
  `deck-detail/action-hide` · `deck-detail/action-delete`.
- **delete-confirm (dialog)**: `deck-detail/delete-scrim` · `deck-detail/delete-dialog` ·
  `deck-detail/delete-cancel` · `deck-detail/delete-ok`.
- **reset-confirm (dialog)**: `deck-detail/reset-scrim` · `deck-detail/reset-dialog` · `deck-detail/reset-cancel` ·
  `deck-detail/reset-ok`.
- **deck-menu (sheet)**: `deck-detail/deck-scrim` · `deck-detail/deck-sheet` · `deck-detail/deck-rename` ·
  `deck-detail/deck-move` · `deck-detail/deck-reset` · `deck-detail/deck-delete`.
- **deck-delete-confirm (dialog)**: `deck-detail/deck-delete-scrim` · `deck-detail/deck-delete-dialog` ·
  `deck-detail/deck-delete-cancel` · `deck-detail/deck-delete-ok`.
- **move (sheet)**: `deck-detail/move-scrim` · `deck-detail/move-sheet` · `deck-detail/move-root` +
  `move-root-pick` · `deck-detail/move-1` + `move-1-pick` · `deck-detail/move-self` (disabled op:0.55) ·
  `deck-detail/move-child` (disabled op:0.55) · `deck-detail/move-apply` (btn).

---

## 1. States (mỗi state trong contract → ≥1 scenario dẫn tới nó)

### SC-DECKDETAIL-01 — loaded (node hỗn hợp: có bộ thẻ con + thẻ)
Nguồn: contract[loaded] · spec base · BR-2/BR-5 (deck-management) · D-009
Tiền điều kiện (Given):
  - DB: `decks`(1 deck cha "Korean Basics" `parent_id=NULL`; ≥1 sub-deck có `parent_id`=deck cha),
    `cards`(≥1 thẻ trực tiếp thuộc deck cha, ≥1 nghĩa/thẻ ở `card_meanings`), `srs_state`(đủ box new/due/mastered).
When: mở deck-detail của deck cha.
Then:
  - UI: appbar (back + tên deck từ ARB/DB, không hardcode "Korean Basics" + play-audio + menu) · search-dock ·
    section "SUB-DECKS" + card sub-deck (icon-tile, tên, meta "N decks · M words", progress, badge số) · section
    "CARDS" + card thẻ (term + nghĩa + badge trạng thái) · FAB Add. Không skeleton, không empty, không dialog.
  - DB: các số hiển thị (số thẻ/từ/đến hạn của sub-deck) là **tổng hợp đệ quy** cây con (BR-5, D-009) đọc từ
    `decks`/`cards`/`srs_state`; assert **nguồn+định dạng** (không assert số mock "412").

### SC-DECKDETAIL-02 — empty (deck rỗng: không sub-deck, không thẻ)
Nguồn: contract[empty] · spec "empty" (full)
Given: DB `decks`(deck "Korean Basics") không có `cards` con và không có sub-deck (`decks` con).
When: mở deck-detail.
Then: UI hiện `deck-detail/empty` (icon-tile playing_cards + tiêu đề + mô tả từ ARB) + 3 nút
`empty-add` / `empty-subdeck` / `empty-import`. **KHÔNG** hiện SUB-DECKS/CARDS/search-dock body/FAB theo diff.
appbar vẫn còn (back + title + menu). ⚠ Xác nhận: empty ẩn cả search-dock (spec empty full không có search-dock).

### SC-DECKDETAIL-03 — loading (provider chưa resolve)
Nguồn: contract[loading] · spec "loading" (skeleton `mxg-skel`)
Given: provider deck-detail chưa resolve (đọc `decks`/`cards` đang chạy).
When: mở deck-detail.
Then: UI hiện appbar thật + skeleton (`mxg-skel`: 1 dải search-dock + N card khung xám với 3 mxg-skel/card:
term-line, meaning-line, badge-pill). Không số thật, không dialog, không crash.

### SC-DECKDETAIL-04 — error (đọc deck thất bại)
Nguồn: contract[error] · spec "error" (full) · `deck-detail/retry`
Given: đọc deck-detail lỗi (Failure → AsyncValue.error).
When: mở deck-detail.
Then: UI hiện `deck-detail/error` (icon-tile cloud_off + tiêu đề + mô tả ARB) + nút `retry`. appbar vẫn còn.
Không hiện SUB-DECKS/CARDS/FAB. ⚠ Xác nhận nguồn lỗi thực (local-first, không mạng — vì sao "check your
connection"? copy kit mock; ARB phải diễn đạt lỗi local đọc DB).

### SC-DECKDETAIL-05 — search (đang nhập truy vấn, có kết quả)
Nguồn: contract[search] · spec "search" diff · D-019/D-028 · BR-1..3 (global-search)
Given: DB deck có ≥1 thẻ khớp truy vấn.
When: chạm search-dock → gõ từ khoá.
Then: UI: sort (swap_vert) → thay bằng `search-clear` (close); hiện hàng `deck-detail/filters` (chip All/New/Due/
Mastered, "All" active bg:primary-soft); SUB-DECKS + FAB **biến mất** (theo diff); danh sách thu về
`deck-detail/result-*` khớp term hoặc nghĩa. DB: query khớp `cards.term` OR `card_meanings.content` (D-019),
**gồm thẻ ẩn** (D-028); assert nguồn+quy tắc AND-đa-token.

### SC-DECKDETAIL-06 — no-results (truy vấn không khớp)
Nguồn: contract[no-results] · spec "no results" (full) · D-019
Given: gõ từ khoá không khớp thẻ nào trong deck.
When: gõ truy vấn.
Then: UI: search-clear + hàng chip `nr-filter-0..3` vẫn hiện; body = `deck-detail/no-results` (icon-tile
search_off + "No cards found" + mô tả có chèn truy vấn — assert **truy vấn thật của người dùng**, không mock
"xyz"). DB: query trả 0 dòng.

### SC-DECKDETAIL-07 — add-menu (bottom-sheet Add)
Nguồn: contract[add-menu] · spec "add menu" diff · `deck-detail/add-*`
Given: state loaded.
When: chạm FAB `deck-detail/add`.
Then: UI hiện scrim `add-scrim` (bg:overlay z:60) + sheet `add-sheet` (drag-handle + tiêu đề "Add to <tên deck>"
từ ARB có tham số tên + 3 mục: `add-word` / `add-subdeck` / `add-import`). Nền dưới còn thấy loaded. DB: không đổi.

### SC-DECKDETAIL-08 — card-actions (bottom-sheet thao tác 1 thẻ)
Nguồn: contract[card-actions] · spec "card actions" diff · `deck-detail/action-*`
Given: state loaded, có thẻ.
When: chạm (long-press hoặc tap?) một card thẻ. ⚠ Xác nhận cử chỉ mở (tap card mở actions hay mở editor?).
Then: UI hiện `actions-scrim` + `actions-sheet` (drag-handle + tiêu đề = term thẻ + 3 mục: `action-edit` /
`action-hide` (visibility_off) / `action-delete` (màu error)). DB: chưa đổi (chỉ hiện menu).

### SC-DECKDETAIL-09 — delete-confirm (xoá 1 thẻ)
Nguồn: contract[delete-confirm] · spec "delete confirm" diff · D-024 · `delete-cancel`/`delete-ok`
Given: đang mở card-actions của 1 thẻ.
When: chạm `action-delete`.
Then: UI hiện dialog `delete-dialog` (icon delete error-soft + "Delete this card?" + mô tả có chèn term thẻ +
Cancel/Delete). DB: chưa xoá cho tới khi bấm `delete-ok` (xem SC-DECKDETAIL-40).

### SC-DECKDETAIL-10 — reset-confirm (reset tiến độ deck)
Nguồn: contract[reset-confirm] · spec "reset confirm" diff · `reset-cancel`/`reset-ok`
Given: đang mở deck-menu.
When: chạm `deck-reset`.
Then: UI hiện dialog `reset-dialog` (icon restart_alt warning-soft + "Reset progress?" + mô tả "…back to New?
Leitner box và due dates sẽ bị xoá" + Cancel/Reset). DB: chưa đổi tới khi `reset-ok` (xem SC-DECKDETAIL-44).
⚠ Xác nhận: reset áp cho **toàn cây con** (đệ quy) hay chỉ thẻ trực tiếp? — chưa có D-xxx/BR cho reset-progress.

### SC-DECKDETAIL-11 — deck-menu (bottom-sheet cấp deck)
Nguồn: contract[deck-menu] · spec "deck menu" diff · `deck-rename`/`deck-move`/`deck-reset`/`deck-delete`
Given: state loaded.
When: chạm `deck-detail/menu` (more_vert trên appbar).
Then: UI hiện `deck-scrim` + `deck-sheet` (drag-handle + tiêu đề = tên deck + 4 mục: Rename / Move / Reset
progress / Delete deck (màu error)). DB: không đổi.

### SC-DECKDETAIL-12 — deck-delete-confirm (xoá cả deck)
Nguồn: contract[deck-delete-confirm] · spec "deck delete-confirm" diff · D-024/BR-4 · `deck-delete-cancel`/`deck-delete-ok`
Given: đang mở deck-menu.
When: chạm `deck-delete`.
Then: UI hiện `deck-delete-dialog` (icon delete error-soft + "Delete this deck?" + mô tả "Deleting removes all
sub-decks, cards and review state inside. This can't be undone." từ ARB + Cancel/Delete). DB: chưa xoá tới khi
`deck-delete-ok` (xem SC-DECKDETAIL-48).

### SC-DECKDETAIL-13 — move (bottom-sheet chọn deck cha mới)
Nguồn: contract[move] · spec "move" diff · BR-3 (không tạo chu trình) · `move-*`
Given: đang mở deck-menu.
When: chạm `deck-move`.
Then: UI hiện `move-sheet` (drag-handle + "Move to" + danh sách đích: `move-root` "Library (root)" + các deck
đích + `move-self` "…(current)" **disabled** op:0.55 + `move-child` "— … (sub-deck)" **disabled** op:0.55 +
nút `move-apply`). Radio (`radio_button_unchecked`) cho đích chọn được. DB: chưa đổi tới khi `move-apply`
(xem SC-DECKDETAIL-46). Assert: chính deck và mọi deck trong **cây con của nó** bị disable (BR-3, tránh chu trình).

---

## 2. Elements (mỗi node DOM ≥1 scenario)

### SC-DECKDETAIL-20 — appbar back
Nguồn: spec `deck-detail/back` (icon-button arrow_back, mx:?)
When: chạm back.
Then: UI pop về màn trước (Library hoặc deck cha nếu lồng). DB: không đổi. Assert semantic label + hit-area ≥48.

### SC-DECKDETAIL-21 — appbar title
Nguồn: spec `appbar__title` "Korean Basics"
Then: hiển thị **tên deck từ DB** (`decks.name`), không hardcode; ellipsis khi dài (xem SC-DECKDETAIL-104).

### SC-DECKDETAIL-22 — play-audio (volume_up)
Nguồn: spec `deck-detail/play-audio` (icon-button volume_up, mx:?)
When: chạm volume_up.
Then: ⚠ Xác nhận đích: đọc TTS toàn deck? mở Trình phát (Player)? navigation-flow có route `player`. Chưa có
D-xxx gán icon này ⇒ assert tối thiểu: có semantic label, hit-area ≥48, không crash; đích LIỆT KÊ ở Open questions.

### SC-DECKDETAIL-23 — menu (more_vert) → deck-menu
Nguồn: spec `deck-detail/menu`
When: chạm more_vert.
Then: mở state deck-menu (SC-DECKDETAIL-11).

### SC-DECKDETAIL-24 — search-dock + input (kích hoạt tìm)
Nguồn: spec `deck-detail/search-dock` + `search-dock__input`
When: chạm ô search → focus → gõ.
Then: chuyển sang state search (SC-DECKDETAIL-05); bàn phím hiện; sort → search-clear.

### SC-DECKDETAIL-25 — sort (swap_vert)
Nguồn: spec `deck-detail/sort` (icon-button swap_vert) · D-023
When: chạm swap_vert.
Then: đổi tiêu chí/chiều sắp xếp danh sách theo D-023 (bảng chữ cái / ngày tạo / ngày học; tăng-giảm). DB đọc
để sắp: `decks.created_at` (proxy ngày tạo) + `srs_state` (proxy ngày học). ⚠ D-023 KHÔNG định nghĩa tên/khoá
`settings` cho tiêu chí+chiều, KHÔNG nói sort là per-app hay per-deck, KHÔNG khẳng định persistence — schema
`settings` thực tế chưa xác nhận (Open questions #14). ⚠ Xác nhận UI chọn: swap_vert mở picker tiêu chí, hay
toggle chiều? spec chỉ có 1 icon; navigation không nói (Open questions #3). Không đoán tên cột settings.

### SC-DECKDETAIL-26 — subdeck card (mở sub-deck)
Nguồn: spec `deck-detail/subdeck-0/1` (icon-tile + tên + meta + progress + badge)
When: chạm 1 card sub-deck.
Then: push deck-detail của sub-deck đó (lồng nhau). Assert **hành vi điều hướng** ở đây. Chi tiết element-level:
- meta có **hai định dạng** — "N decks · M words" (SC-DECKDETAIL-101) vs "M words · mastered" (SC-DECKDETAIL-101a);
- badge có **hai biến thể** — số đếm primary-soft (SC-DECKDETAIL-49b) vs "✓" success-soft (SC-DECKDETAIL-49c).
Công thức số/meta + phạm vi đệ quy chưa chốt (Open questions #13/#16); ở đây assert nguồn+điều hướng, không mock "28".

### SC-DECKDETAIL-27 — card thẻ (mở thao tác/sửa)
Nguồn: spec `deck-detail/card-0..4` (term + nghĩa + badge Due/Mastered/New)
When: chạm 1 card thẻ.
Then: ⚠ Xác nhận: mở card-actions (SC-08) hay mở `flashcardEditor` trực tiếp? Assert term hiển thị từ
`cards.term`, nghĩa từ `card_meanings.content` (nghĩa đầu, `sort_index` nhỏ nhất), badge trạng thái ánh xạ
`srs_state.box` (New=box 0, Due=`due_at<=now`, Mastered=box 8).

### SC-DECKDETAIL-28 — card thẻ ẩn (visibility_off + op:0.5)
Nguồn: spec `deck-detail/card-5` (icon `visibility_off`, container op:0.5) · D-006
Given: DB `cards`(1 thẻ `hidden=1`).
Then: UI card thẻ ẩn hiển thị mờ (op:0.5) + icon visibility_off cạnh term. DB assert (theo D-006): thẻ
`hidden=1` **vẫn liệt kê** trong danh sách deck-detail nhưng **không** tính vào "dựng hàng đợi / số đến hạn"
(D-006, dòng chuẩn). ⚠ **KHÔNG mở rộng** D-006 sang số hiển thị "N words" trên card/meta: D-006 chỉ nói loại
thẻ ẩn khỏi *hàng đợi/số đến hạn*, KHÔNG nói về công thức đếm "N words" hiển thị. Assertion "N words đếm
`WHERE hidden=0`" chưa có nguồn trong 3 nguồn đối chiếu (D-006 không đủ; BR-6 chưa xác minh trong phạm vi) ⇒
để ở Open questions #15, không khẳng định. Spec base có card-5 ẩn ⇒ deck-detail có hiện thẻ ẩn (đã chắc).

### SC-DECKDETAIL-29 — FAB Add
Nguồn: spec `deck-detail/add` (fab, mx:?)
When: chạm FAB.
Then: mở add-menu (SC-DECKDETAIL-07).

### SC-DECKDETAIL-30 — search-clear (close)
Nguồn: spec `deck-detail/search-clear` (icon-button close) [state search/no-results]
When: đang ở search → chạm close.
Then: xoá truy vấn + thoát search → về loaded; close → sort (swap_vert) trở lại; FAB + SUB-DECKS hiện lại.

### SC-DECKDETAIL-31..34 — filter chips All/New/Due/Mastered
Nguồn: spec `deck-detail/filter-0..3` (+ `nr-filter-0..3`) · D-028 · BR-2 (global-search)
When: đang search → chạm từng chip.
Then: All = mọi kết quả; New = `srs_state.box=0`; Due = `due_at<=now`; Mastered = `box=8`. Chip active
bg:primary-soft, còn lại bg:surface. DB: đọc `settings`(`search.status_filter`) + join `srs_state.box` (D-028).
Assert: kết quả **gồm thẻ ẩn** (D-028) khác với danh sách loaded (loại thẻ ẩn khỏi đếm nhưng vẫn liệt kê).

### SC-DECKDETAIL-35 — result card (mở thẻ từ kết quả)
Nguồn: spec `deck-detail/result-0..n`
When: chạm 1 result.
Then: mở thẻ (actions/editor như card thường). Hậu điều kiện global-search UC-1: người học mở 1 thẻ từ kết quả.

### SC-DECKDETAIL-36 — empty-add
Nguồn: spec `deck-detail/empty-add` (btn "Add words") [state empty]
When: chạm.
Then: mở luồng thêm thẻ (→ `flashcardEditor` hoặc add-word). Cùng đích với add-menu `add-word`. DB: chưa ghi.

### SC-DECKDETAIL-37 — empty-subdeck
Nguồn: spec `deck-detail/empty-subdeck` (btn "New sub-deck") [state empty]
When: chạm.
Then: mở luồng tạo sub-deck (deck con của deck hiện tại). DB: tạo 1 dòng `decks` mới `parent_id`=deck hiện tại
sau khi xác nhận tên (BR-1 tên bắt buộc). ⚠ Xác nhận UI nhập tên sub-deck (dialog/màn?) — ngoài DOM spec màn này.

### SC-DECKDETAIL-38 — empty-import
Nguồn: spec `deck-detail/empty-import` (btn "Import from file") [state empty]
When: chạm.
Then: push `deckImport` (`/deck/:id/import`, navigation-flow). Cùng đích với add-menu `add-import`.

### SC-DECKDETAIL-39 — retry
Nguồn: spec `deck-detail/retry` (btn) [state error]
When: state error → chạm Retry.
Then: gọi lại provider đọc deck; nếu thành công → loaded; nếu vẫn lỗi → error lại (xem SC-DECKDETAIL-83).

### SC-DECKDETAIL-40 — add-word (từ add-menu)
Nguồn: spec `deck-detail/add-word` [state add-menu] · flashcard UC-1
When: add-menu → chạm "Add word".
Then: đóng sheet → mở `flashcardEditor` (tạo thẻ trong deck hiện tại). DB: dòng `cards` + `card_meanings` chỉ
ghi khi lưu ở editor (BR-2 term + ≥1 nghĩa bắt buộc), trạng thái **Mới** (không ghi `srs_state`, box 0 mặc định).

### SC-DECKDETAIL-41 — add-subdeck (từ add-menu)
Nguồn: spec `deck-detail/add-subdeck` [state add-menu]
When: chạm "New sub-deck".
Then: đóng sheet → luồng tạo sub-deck (như SC-37). DB: `decks` mới `parent_id`=deck hiện tại.

### SC-DECKDETAIL-42 — add-import (từ add-menu)
Nguồn: spec `deck-detail/add-import` [state add-menu]
When: chạm "Import cards".
Then: đóng sheet → push `deckImport`.

### SC-DECKDETAIL-43 — action-edit / action-hide / action-delete (card-actions)
Nguồn: spec `deck-detail/action-edit`/`action-hide`/`action-delete` [state card-actions] · D-006 · D-024
When: card-actions → chạm từng mục.
Then:
  - Edit → mở `flashcardEditor` sửa thẻ; DB cập nhật `cards`/`card_meanings`; `srs_state` **không đổi** (flashcard UC-2).
  - Hide → set `cards.hidden=1`; thẻ mờ đi (op:0.5), rời hàng đợi/đếm due (D-006/BR-4); dữ liệu vẫn giữ. Assert
    round-trip: reopen → thẻ vẫn liệt kê, `hidden=1`. ⚠ Xác nhận: có mục "Unhide" khi thẻ đang ẩn? (spec chỉ có Hide).
  - Delete → mở delete-confirm (SC-DECKDETAIL-09).

### SC-DECKDETAIL-44 — delete-cancel / delete-ok (xoá thẻ)
Nguồn: spec `deck-detail/delete-cancel`/`delete-ok` [state delete-confirm] · D-024
When: delete-confirm → Cancel HOẶC Delete.
Then:
  - Cancel → đóng dialog, thẻ còn nguyên. DB: không đổi.
  - Delete (`delete-ok`) → xoá thẻ. DB: dòng `cards` bị xoá + **cascade** `card_meanings` + `srs_state` +
    `review_logs` của thẻ (ON DELETE CASCADE, D-024). UI: card biến khỏi danh sách; nếu thẻ cuối → có thể chuyển empty.

### SC-DECKDETAIL-45 — reset-cancel / reset-ok (reset tiến độ)
Nguồn: spec `deck-detail/reset-cancel`/`reset-ok` [state reset-confirm]
When: reset-confirm → Cancel HOẶC Reset.
Then:
  - Cancel → đóng dialog, tiến độ giữ nguyên.
  - Reset (`reset-ok`) → mọi thẻ về New. DB (chỉ theo mô tả dialog "Leitner box và due dates sẽ bị xoá"):
    `srs_state.box`→0, `due_at`→NULL. ⚠ **KHÔNG** kê thêm cột nào: `last_reviewed_at` KHÔNG có trong header
    schema màn này và không có D-xxx/BR định nghĩa reset-progress ⇒ liệt kê ở Open questions #4, đừng đưa vào
    assertion DB. ⚠ Xác nhận: reset có đặt/xoá cột "lần học cuối" (nếu schema có) không? có xoá `review_logs`
    không? phạm vi đệ quy cây con hay chỉ thẻ trực tiếp? — chưa có nguồn; đừng đoán logic/tên cột.

### SC-DECKDETAIL-46 — deck-rename / deck-move / deck-reset / deck-delete (deck-menu)
Nguồn: spec `deck-detail/deck-rename`/`deck-move`/`deck-reset`/`deck-delete` [state deck-menu] · BR-1/BR-3/D-024
When: deck-menu → chạm từng mục.
Then:
  - Rename → mở luồng đổi tên (DB: `decks.name` cập nhật, tên bắt buộc BR-1). ⚠ Xác nhận UI nhập (dialog rename)
    — ngoài DOM spec màn này ⇒ Open questions.
  - Move → mở state move (SC-DECKDETAIL-13).
  - Reset progress → mở reset-confirm (SC-DECKDETAIL-10).
  - Delete deck → mở deck-delete-confirm (SC-DECKDETAIL-12).

### SC-DECKDETAIL-47 — move-root/move-1 pick + move-apply (di chuyển deck)
Nguồn: spec `deck-detail/move-root`/`move-1` + `*-pick` + `move-apply` [state move] · BR-3 (deck-management)
When: move → chọn 1 đích hợp lệ (radio) → chạm `move-apply`.
Then: đóng sheet; DB: `decks.parent_id` của deck hiện tại = id đích (NULL nếu chọn "Library (root)"). Assert
BR-3: **không** cho chọn `move-self`/`move-child` (disabled) ⇒ không tạo chu trình. UI: sau move, deck xuất hiện
dưới cha mới.

### SC-DECKDETAIL-48 — move-self / move-child bị vô hiệu
Nguồn: spec `deck-detail/move-self`/`move-child` (op:0.55) [state move] · BR-3
When: move → thử chạm chính deck ("…(current)") hoặc deck con ("— … (sub-deck)").
Then: không chọn được (disabled), không có radio-pick; assert deck hiện tại + **mọi deck trong cây con** bị vô
hiệu (tránh chu trình). DB: không đổi.

### SC-DECKDETAIL-49 — deck-delete-cancel / deck-delete-ok (xoá deck cascade)
Nguồn: spec `deck-detail/deck-delete-cancel`/`deck-delete-ok` [state deck-delete-confirm] · D-024/BR-4
When: deck-delete-confirm → Cancel HOẶC Delete.
Then:
  - Cancel → đóng dialog, deck còn.
  - Delete (`deck-delete-ok`) → xoá deck. DB: dòng `decks` bị xoá + **cascade toàn cây con**: sub-decks
    (`parent_id` self-FK cascade) + `cards` + `card_meanings` + `srs_state` + `review_logs` + `study_sessions`
    (D-024, referential-integrity summary). UI: pop về màn trước (Library / deck cha).

### SC-DECKDETAIL-49a — icon:search (magnifier trong search-dock)
Nguồn: spec `icon:search` (leading, search-dock, `font:22/400 color:text-tertiary`, DOM base 139-144)
Then: glyph `search` hiển thị **thường trực** làm leading trong `search-dock` ở mọi state có search-dock (loaded,
search, no-results), màu token `text-tertiary`. **Non-interactive** (không phải icon-button, không có `id`, không
mở/đổi state) — chỉ là chỉ báo trực quan cho ô tìm; tap vào dock kích hoạt input (SC-DECKDETAIL-24), không phải glyph.
Assert: node glyph hiện + đúng token màu, KHÔNG assert hành vi tap riêng cho glyph. (Phủ DoE #2: node DOM này ≥1 scenario.)

### SC-DECKDETAIL-49b — badge sub-deck: đếm (primary-soft) — biến thể 1
Nguồn: spec `subdeck-0` badge "28" (`bg:primary-soft color:on-primary-soft`, DOM base 232-240)
Given: sub-deck có ≥1 con/thẻ đến hạn (chưa mastered toàn bộ).
Then: card sub-deck hiển thị badge **số đếm** nền token `primary-soft`, chữ `on-primary-soft`, `r:999`, `minw:20`.
Assert **nguồn+token+định dạng số** (số theo locale) — KHÔNG assert giá trị mock "28". Công thức số (đến hạn hay
tổng thẻ) + phạm vi đệ quy chưa chốt ⇒ Open questions #13; ở đây chỉ khẳng định biến thể badge **primary-soft số đếm** render đúng.

### SC-DECKDETAIL-49c — badge sub-deck: mastered "✓" (success-soft) — biến thể 2
Nguồn: spec `subdeck-1` badge "✓" (`bg:success-soft color:on-success-soft`, DOM base 299-307)
Given: sub-deck đã thuộc toàn bộ (mastered — không còn con/thẻ đến hạn).
Then: card sub-deck hiển thị badge **dấu "✓"** nền token `success-soft`, chữ `on-success-soft`, `r:999`, `minw:20`
— **tách khỏi** biến thể primary-soft số đếm (SC-49b), đúng token màu success-soft (không dùng nhầm primary-soft).
Assert element-level: hai biến thể badge là **hai node DOM riêng** với hai token nền khác nhau; khi nào hiện "✓"
vs số đếm (điều kiện mastered-toàn-bộ) chưa chốt công thức ⇒ Open questions #13. Assert nguồn+token, không mock.

---

## 3. Điều hướng vào/ra

### SC-DECKDETAIL-50 — Vào từ Library (entry chính)
Nguồn: navigation-flow (`library (/) ─▶ deckDetail`) · route `deckDetail` `/deck/:id`
When: ở Library → chạm 1 node deck.
Then: push deck-detail với `deckId`; đọc `decks`(id) + con. Nếu id không tồn tại → ⚠ xác nhận (error? pop?).

### SC-DECKDETAIL-51 — Vào lồng nhau (deck-detail → deck-detail con)
Nguồn: BR-2 (node hỗn hợp) · SC-DECKDETAIL-26
When: trong deck-detail → chạm sub-deck.
Then: push deck-detail con; back quay lại deck cha giữ vị trí cuộn.

### SC-DECKDETAIL-52 — Vào từ Dashboard continue-deck (entry phụ)
Nguồn: dashboard SC-DASH-18..20 (continue-deck → deck-detail[loaded])
When: từ Today → chạm thẻ continue-deck.
Then: push deck-detail của deck đó.

### SC-DECKDETAIL-53 — Ra: back/pop
Nguồn: spec `deck-detail/back` · Android system-back
When: chạm back HOẶC vuốt/hệ thống back.
Then: pop về entry (Library / deck cha / Today). ⚠ Xác nhận: back khi đang mở sheet/dialog → đóng overlay
trước, chưa pop màn (overlay z:60 phải nuốt back).

### SC-DECKDETAIL-54 — Ra: push flashcardEditor
Nguồn: navigation-flow (`deckDetail ─▶ flashcardEditor`) · route `/deck/:id/card`
When: add-word / action-edit / empty-add.
Then: push editor; back → về deck-detail, danh sách phản ánh thẻ mới/sửa.

### SC-DECKDETAIL-55 — Ra: push deckImport
Nguồn: navigation-flow · route `/deck/:id/import`
When: add-import / empty-import.
Then: push deckImport; back → về deck-detail.

### SC-DECKDETAIL-56 — Đóng overlay (scrim / drag-dismiss)
Nguồn: spec `*-scrim` (bg:overlay z:60) mọi sheet/dialog
When: chạm scrim ngoài sheet/dialog HOẶC vuốt sheet xuống.
Then: đóng overlay, về state nền (loaded), DB không đổi. Assert mỗi overlay (add/actions/deck/move sheet +
delete/reset/deck-delete dialog) đều đóng được bằng scrim.

### SC-DECKDETAIL-57 — Giữ vị trí cuộn khi quay lại
Nguồn: DoE #3
Given: cuộn danh sách thẻ xuống, push editor/sub-deck, back.
Then: deck-detail giữ nguyên vị trí cuộn + state search/filter (nếu đang mở).

---

## 4. Nhập liệu & validation

> Màn deck-detail có **một** field nhập trực tiếp trong DOM spec: `search-dock__input`. Các field khác (tên thẻ,
> tên deck khi rename, tên sub-deck) nằm ở màn/dialog **ngoài** DOM spec này (`flashcardEditor`, dialog rename)
> ⇒ validation của chúng thuộc scenario màn tương ứng; ở đây chỉ liệt kê điểm vào + gắn cờ Open questions.

### SC-DECKDETAIL-60 — search rỗng / chỉ khoảng trắng
Nguồn: `search-dock__input` · D-019
When: field rỗng HOẶC chỉ khoảng trắng.
Then: có nguồn (D-019): chuỗi chỉ-khoảng-trắng sau **trim** ⇒ coi như rỗng (D-019 tách token theo whitespace),
không crash. ⚠ **KHÔNG có nguồn** cho trạng-thái-đích khi query rỗng: về loaded, giữ search rỗng, hay hiện
gợi ý/recent? D-019 không định nghĩa → thuần Open questions #10, KHÔNG viết assertion đoán về state đích.

### SC-DECKDETAIL-61 — search truy vấn dài (biên)
Nguồn: `search-dock__input`
When: gõ truy vấn rất dài.
Then: input không vỡ layout; query vẫn chạy; kết quả hoặc no-results. ⚠ Xác nhận giới hạn ký tự (nếu có).

### SC-DECKDETAIL-62 — search CJK (Hàn/Nhật)
Nguồn: `search-dock__input` · D-019
When: gõ "안녕" / "感謝".
Then: khớp `cards.term`/`card_meanings.content` chứa CJK (render đúng, không tofu); LIKE khớp chuỗi con Unicode.

### SC-DECKDETAIL-63 — search đa token (AND)
Nguồn: D-019 · BR-1 (global-search) · AC-4
When: gõ 2 token, 1 khớp term, 1 khớp nghĩa của **cùng** thẻ.
Then: thẻ đó xuất hiện; thẻ chỉ khớp 1 token → không (AND giữa các token). DB: assert quy tắc AND.

### SC-DECKDETAIL-64 — search khớp thẻ ẩn
Nguồn: D-028 · BR-2 (global-search) · AC-2
Given: thẻ khớp truy vấn đang `hidden=1`.
When: tìm.
Then: thẻ **vẫn hiện** trong kết quả (khác với đếm due — D-006 loại khỏi đếm nhưng D-028 giữ trong search).

### SC-DECKDETAIL-65 — search ký tự đặc biệt / emoji
Nguồn: `search-dock__input`
When: gõ ký tự đặc biệt (%, _, ', emoji).
Then: có nguồn: input không crash với ký tự đặc biệt/emoji (render + xử lý an toàn). ⚠ **KHÔNG có nguồn** cho
LIKE-escape: D-019/D-028 chỉ nói tách token + AND, KHÔNG nói dùng LIKE, KHÔNG nói escape `%`/`_`. Việc `%`/`_`
có được escape (để không khớp sai hàng loạt) hay không là **suy đoán cách hiện thực** → thuần Open questions #10,
KHÔNG viết assertion escape wildcard như đã chắc. Chỉ khi chốt cơ chế match (LIKE vs FTS vs contains) mới assert.

### SC-DECKDETAIL-66 — soft-dup khi thêm thẻ trùng term (điểm vào)
Nguồn: D-020 · BR-5 (flashcard)
Given: deck đã có thẻ term="사과".
When: từ add-word/import thêm thẻ term="사과".
Then: **cảnh báo mềm**, vẫn cho lưu (không chặn); DB: 2 dòng `cards` cùng term (không unique constraint
`(deck_id, term)`). Validation cụ thể thuộc `flashcardEditor`; ở đây assert điểm vào từ deck-detail dẫn tới.

---

## 5. Lượng dữ liệu

### SC-DECKDETAIL-70 — 0 (deck rỗng) → state empty
Nguồn: contract[empty] · SC-DECKDETAIL-02
Then: hiện empty-illustration + 3 nút; không SUB-DECKS/CARDS.

### SC-DECKDETAIL-71 — chỉ có sub-deck, không thẻ trực tiếp
Nguồn: BR-2 (node hỗn hợp)
Given: deck có sub-deck nhưng 0 thẻ trực tiếp.
Then: ⚠ Xác nhận: hiện SUB-DECKS (có card) + CARDS rỗng (ẩn section?) — hay coi là empty? spec loaded có cả 2
section; cần rõ khi thiếu 1 nhóm.

### SC-DECKDETAIL-72 — chỉ có thẻ, không sub-deck
Given: deck có thẻ trực tiếp, 0 sub-deck.
Then: hiện CARDS, **ẩn** section SUB-DECKS. ⚠ Xác nhận header SUB-DECKS ẩn khi rỗng.

### SC-DECKDETAIL-73 — 1 thẻ
Then: 1 card thẻ; số "N words" của deck = 1 (không tính thẻ ẩn, BR-6); plural đúng (xem SC-DECKDETAIL-102).

### SC-DECKDETAIL-74 — nhiều thẻ (scroll)
Then: danh sách cuộn mượt; badge trạng thái mỗi thẻ đúng box.

### SC-DECKDETAIL-75 — rất nhiều thẻ (hàng nghìn — lazy/perf)
Nguồn: deck-management §8 (mở deck lớn cuộn mượt)
Then: cuộn mượt, không giật khi mở deck lớn; tổng hợp đệ quy không block UI.

### SC-DECKDETAIL-76 — deck có thẻ ẩn lẫn hiển thị (đếm)
Nguồn: D-006
Given: deck 5 thẻ hiển thị + 2 thẻ ẩn.
Then: danh sách liệt kê cả 7 (ẩn mờ op:0.5). Số **đến hạn / hàng đợi** chỉ tính 5 thẻ hiển thị (D-006, đếm
`WHERE hidden=0` cho *hàng đợi/due*). ⚠ Số hiển thị **"N words"** trên card/meta: chưa xác nhận có loại thẻ ẩn
hay không — D-006 chỉ phủ hàng đợi/số đến hạn, không phủ công thức "N words"; BR-6 chưa xác minh trong 3 nguồn
đối chiếu ⇒ Open questions #15. Assert `WHERE hidden=0` **chỉ cho số due/hàng đợi**, KHÔNG khẳng định cho "N words".

---

## 6. Async & lỗi

### SC-DECKDETAIL-80 — loading → loaded
Nguồn: contract[loading]→[loaded]
Then: skeleton `mxg-skel` → nội dung thật khi provider resolve.

### SC-DECKDETAIL-81 — loading → empty
Then: skeleton → empty-illustration khi deck rỗng.

### SC-DECKDETAIL-82 — đọc deck lỗi → error
Nguồn: contract[error] · Failure→AsyncValue.error
Then: skeleton → error-illustration + Retry. Lỗi không bị nuốt (flow Failure→AsyncValue.error).

### SC-DECKDETAIL-83 — error → Retry → loaded / lại error
Nguồn: `deck-detail/retry`
When: error → Retry.
Then: re-fetch; thành công → loaded; vẫn lỗi → error lại (retry idempotent, không nhân đôi listener).

### SC-DECKDETAIL-84 — local-first (không mạng)
Nguồn: schema-contract (local-only v1, không remote BE)
Then: deck-detail render đầy đủ từ DB local, **không** phụ thuộc mạng. ⚠ Copy kit error mock "check your
connection" gây hiểu nhầm — ARB phải nói lỗi đọc local, không phải mạng (đọc lỗi hiếm ở local-first).

---

## 7. Persistence (DB round-trip)

### SC-DECKDETAIL-90 — Thêm thẻ → phản ánh + round-trip
Nguồn: SC-DECKDETAIL-40 · `cards`/`card_meanings`
When: add-word → lưu ở editor → back.
Then: DB: +1 `cards` (term trimmed non-empty BR-2) + ≥1 `card_meanings` (`content` trimmed non-empty). UI: card
mới hiện. Kill & mở lại → thẻ còn.

### SC-DECKDETAIL-91 — Ẩn thẻ → round-trip
Nguồn: SC-DECKDETAIL-43 (hide) · D-006
When: action-hide.
Then: DB `cards.hidden=1`. Kill & mở lại → thẻ vẫn liệt kê, mờ; không tính vào due.

### SC-DECKDETAIL-92 — Xoá thẻ → cascade + round-trip
Nguồn: SC-DECKDETAIL-44 · D-024
When: delete-ok.
Then: DB xoá `cards` + cascade `card_meanings`/`srs_state`/`review_logs`. Kill & mở lại → thẻ mất; không mồ côi
`card_meanings` (assert count = 0 cho card_id đã xoá).

### SC-DECKDETAIL-93 — Xoá deck → cascade toàn cây + round-trip
Nguồn: SC-DECKDETAIL-49 · D-024/BR-4
When: deck-delete-ok trên deck có sub-deck + thẻ.
Then: DB xoá `decks`(deck) + cascade sub-decks + `cards` + `card_meanings` + `srs_state` + `review_logs` +
`study_sessions`. Kill & mở lại → deck + cả cây con mất.

### SC-DECKDETAIL-94 — Move deck → round-trip
Nguồn: SC-DECKDETAIL-47
When: move-apply chọn đích mới.
Then: DB `decks.parent_id` = id đích (hoặc NULL nếu root). Kill & mở lại → deck nằm dưới cha mới.

### SC-DECKDETAIL-95 — Rename deck → round-trip
Nguồn: SC-DECKDETAIL-46 (rename) · BR-1
When: rename → lưu tên mới (trimmed non-empty).
Then: DB `decks.name` cập nhật; appbar title đổi. Kill & mở lại → tên mới.

### SC-DECKDETAIL-96 — Đổi tiêu chí sort → persist (⚠ điều kiện, schema chưa chốt)
Nguồn: SC-DECKDETAIL-25 · D-023
When: đổi sort.
Then: ⚠ **KHÔNG khẳng định** khoá/persistence: D-023 chỉ định nghĩa hành vi sắp xếp, KHÔNG nói tiêu chí+chiều
được lưu vào `settings`, KHÔNG cho tên cột, KHÔNG nói per-app hay per-deck. Tên khoá `deck.sort_criteria`/
`deck.sort_dir` và hành vi round-trip là **suy đoán schema** → chuyển sang Open questions #14. Chỉ khi schema
`settings` được xác nhận mới viết assertion round-trip (kill & mở lại → giữ tiêu chí). Hiện chưa có nguồn.

---

## 8. Định dạng & i18n

### SC-DECKDETAIL-100 — CJK term/nghĩa render đúng
Nguồn: spec card (term "안녕하세요", nghĩa) · flashcard
Then: term + nghĩa CJK render đúng glyph (không tofu); badge/nhãn từ ARB.

### SC-DECKDETAIL-101 — meta "N decks · M words" theo locale + plural
Nguồn: spec `subdeck-0` meta "3 decks · 412 words" (DOM base 215)
Given: sub-deck **có** deck con (nhánh không-lá).
Then: số theo locale; plural đúng (1 deck vs N decks; 1 word vs N words) qua ARB plural, không nối chuỗi. Assert
định dạng, không mock "412". ⚠ Biến thể lá xem SC-DECKDETAIL-101a.

### SC-DECKDETAIL-101a — meta biến thể "M words · mastered" (sub-deck lá / mastered) + i18n
Nguồn: spec `subdeck-1` meta "180 words · mastered" (DOM base 282) — **không** có count decks, có hậu tố trạng thái
Given: sub-deck **không có** deck con (lá) và/hoặc đã mastered toàn bộ.
Then: meta đổi định dạng: bỏ đoạn "N decks ·" (không có con để đếm) và nối **hậu tố trạng thái** "mastered".
- i18n: hậu tố "mastered" phải từ **ARB** (không copy kit tiếng Anh), là **chuỗi có điều kiện** nối vào meta,
  không nối chuỗi thủ công (dùng placeholder/ARB pattern cho cả hai nhánh "N decks · M words" và "M words · <trạng thái>").
- plural: "M words" vẫn plural đúng ở nhánh này.
⚠ **KHÔNG có nguồn** cho *công thức meta*: khi nào hiện "N decks · M words" vs "M words · mastered" (do là lá?
do mastered-toàn-bộ? cả hai?) — DOM chỉ cho 2 mẫu, không cho quy tắc chọn. Điều kiện hiện hậu tố "mastered" vs
count ⇒ Open questions #13 + #16. Assert định dạng+nguồn ARB, không assert điều kiện đoán, không mock "180".

### SC-DECKDETAIL-102 — badge trạng thái từ ARB (Due/New/Mastered)
Nguồn: spec badge "Due"/"New"/"Mastered"
Then: chuỗi badge lấy từ ARB (không copy kit tiếng Anh); màu theo token (error-soft/primary-soft/success-soft).

### SC-DECKDETAIL-102a — badge trạng thái bất biến theo đảo chiều hiển thị (D-011)
Nguồn: D-011 (một chiều SRS duy nhất KO↔VI) · SC-DECKDETAIL-27 (badge ánh xạ `srs_state.box`)
Given: một thẻ có `srs_state.box` xác định (New/Due/Mastered).
When: đảo chiều hiển thị term↔nghĩa (KO↔VI).
Then: badge trạng thái (New/Due/Mastered) **không đổi** — vì SRS một chiều, mọi chiều hiển thị **dùng chung một**
`SrsState` (D-011). Badge ánh xạ trực tiếp từ `srs_state.box`, độc lập với chiều đọc term/nghĩa. Assert: đảo chiều
KHÔNG tạo trạng thái SRS thứ hai và KHÔNG đổi màu/chuỗi badge. (Phủ D-011 — trước chỉ liệt kê D-001/002/016 gián tiếp.)

### SC-DECKDETAIL-103 — tiêu đề dialog có tham số (tên/term)
Nguồn: spec delete-dialog "…"안녕하세요"…" · add-sheet "Add to Korean Basics" · actions-sheet tiêu đề=term
Then: chuỗi có tham số dùng placeholder ARB chèn tên deck/term thật (không nối chuỗi thủ công); CJK trong tham
số render đúng.

### SC-DECKDETAIL-104 — tên deck / term dài → ellipsis/wrap
Nguồn: spec `appbar__title` (clip) · card term/nghĩa (clip)
Then: tên deck rất dài ở appbar → ellipsis (clip), không đẩy icon trail; term/nghĩa dài → ellipsis/wrap không vỡ card.

### SC-DECKDETAIL-105 — no-results copy chèn truy vấn
Nguồn: spec no-results "Nothing matched "xyz""
Then: mô tả chèn **truy vấn thật** của người dùng (placeholder ARB), không hardcode "xyz"; CJK trong truy vấn OK.

---

## 9. Dark mode

### SC-DECKDETAIL-110 — Mọi state ở dark
Nguồn: wireframe (light+dark mỗi state) · DoE #9
Then: 13 state render đúng ở cả light + dark (token `--memox-*`, không hardcode màu). Scrim overlay, badge-soft
color, error/success/warning-soft, primary FAB đều đạt contrast ở dark.

---

## 10. Responsive

### SC-DECKDETAIL-111 — 320px → tablet + xoay + safe-area
Nguồn: DoE #10
Then: 320px không overflow (card co giãn, appbar không tràn 3 icon-button, FAB không che nội dung cuối);
sheet/dialog vừa màn nhỏ (dialog maxw:320); xoay ngang cuộn được; safe-area/notch OK; move-sheet dài cuộn được.

---

## 11. A11y

### SC-DECKDETAIL-112 — Semantics + hit-area + focus order
Nguồn: DoE #11 · spec icon-button (48x48) / btn (minh:48)
Then: back/play-audio/menu/sort/search-clear/FAB có semantic label (từ ARB); hit-area ≥48 (icon-button 48x48,
btn minh:48); thứ tự đọc: appbar → search → SUB-DECKS → CARDS → FAB; card thẻ đọc thành câu (term + nghĩa +
trạng thái) không rời rạc; dialog focus bẫy trong dialog, Cancel/Delete đọc rõ hành động; chip filter đọc trạng
thái selected. Radio move đọc chọn/không-chọn.

---

## 12. Concurrency & edge thời gian

### SC-DECKDETAIL-120 — Double-tap FAB / card / sub-deck
Nguồn: DoE #12
Then: chạm nhanh 2 lần FAB → mở add-menu **một** lần (không 2 sheet chồng); double-tap sub-deck → push **một**
deck-detail; double-tap delete-ok → xoá **một** lần (không lỗi cascade lần 2 trên hàng đã mất).

### SC-DECKDETAIL-121 — Back khi đang load
Nguồn: DoE #12
When: state loading → back.
Then: huỷ fetch, pop sạch (không setState-after-dispose / không giữ listener).

### SC-DECKDETAIL-122 — Xoá thẻ đang khi search mở
Given: đang search, xoá 1 result.
Then: result rời danh sách; nếu hết → no-results; DB cascade đúng; truy vấn giữ nguyên.

### SC-DECKDETAIL-123 — Mở deck-detail của deck vừa bị xoá ở nơi khác
Given: deck bị xoá (ví dụ từ Library) trong khi navigate.
Then: ⚠ Xác nhận: deck-detail hiện error/empty hay pop? — chưa có D-xxx; Open questions.

### SC-DECKDETAIL-124 — Overlay + back đồng thời
Given: đang mở sheet/dialog.
When: nhấn back hệ thống.
Then: đóng overlay trước (nuốt back), **không** pop màn; back lần 2 mới pop. (scrim z:60).

---

## Open questions (⚠ cần chốt spec trước khi viết test — KHÔNG bịa)

1. **play-audio (volume_up)**: đích khi tap? Đọc TTS toàn deck hay mở Trình phát (route `player`)? Chưa có D-xxx
   gán icon appbar này. (SC-DECKDETAIL-22)
2. **Cử chỉ mở card-actions vs mở editor**: tap card thẻ mở bottom-sheet `card-actions` hay mở `flashcardEditor`
   trực tiếp? long-press? (SC-DECKDETAIL-08/27)
3. **sort (swap_vert)**: 1 icon — mở picker chọn tiêu chí (bảng chữ cái/ngày tạo/ngày học) rồi chọn chiều, hay
   chỉ toggle chiều? UI chọn tiêu chí ở đâu? (D-023, SC-DECKDETAIL-25)
4. **Reset progress**: phạm vi (chỉ thẻ trực tiếp hay đệ quy cây con)? có xoá `review_logs` không? Chưa có
   D-xxx/BR riêng cho reset-progress. (SC-DECKDETAIL-10/45)
5. **Rename / New sub-deck**: UI nhập tên (dialog rename? màn?) — **không có** trong DOM spec màn này; validation
   tên (rỗng/trùng/dài/CJK/trim) thuộc màn nào? (SC-DECKDETAIL-37/46/95)
6. **Unhide**: card-actions chỉ có "Hide card" — khi thẻ đang ẩn, có mục "Unhide"/"Show" thay thế không?
   (SC-DECKDETAIL-43)
7. **empty ẩn search-dock**: spec empty (full) không có search-dock — deck rỗng có ẩn hẳn ô tìm không? (SC-02)
8. **Section rỗng**: deck chỉ-sub-deck (không thẻ) hay chỉ-thẻ (không sub-deck) — header SUB-DECKS/CARDS ẩn khi
   nhóm rỗng? (SC-DECKDETAIL-71/72)
9. **error copy**: kit mock "Check your connection" nhưng v1 local-first (không remote BE) — nguồn lỗi đọc DB
   thực là gì? ARB nên diễn đạt sao? (SC-DECKDETAIL-04/84)
10. **search field rỗng**: về loaded hay hiện gợi ý/recent? Escape wildcard LIKE (`%`,`_`) khi gõ ký tự đặc biệt?
    (SC-DECKDETAIL-60/65)
11. **deckId không tồn tại / deck bị xoá nơi khác**: deck-detail hiện error/empty hay pop? (SC-DECKDETAIL-50/123)
12. **card-actions cho sub-deck**: spec chỉ có actions cho **thẻ**; sub-deck có menu ngữ cảnh riêng
    (rename/move/delete cấp sub-deck) hay phải mở sub-deck rồi dùng deck-menu?
13. **Badge sub-deck "28" (primary-soft) vs "✓" (success-soft)**: "28" = số đến hạn hay số thẻ? "✓" = mastered
    toàn bộ? Công thức + phạm vi (đệ quy) + **điều kiện chọn biến thể** badge cần chốt (assert nguồn, không mock).
    (SC-DECKDETAIL-26/49b/49c)
14. **Schema `settings` cho sort**: D-023 chỉ định nghĩa *hành vi* sắp xếp — KHÔNG cho tên cột/khoá, KHÔNG nói
    tiêu chí+chiều được **persist**, KHÔNG nói **per-app hay per-deck**. Tên `deck.sort_criteria`/`deck.sort_dir`
    và round-trip là suy đoán → cần schema `settings` thực tế trước khi viết assertion persist. (SC-DECKDETAIL-25/96)
15. **Công thức đếm "N words" (card/meta) với thẻ ẩn**: D-006 chỉ loại thẻ ẩn khỏi *hàng đợi / số đến hạn*, KHÔNG
    nói về số hiển thị "N words". "N words `WHERE hidden=0`" dựa trên 'BR-6' chưa xác minh trong 3 nguồn đối chiếu
    ⇒ cần trích BR-6 chính xác (hoặc D-xxx) xác nhận "N words" có/không đếm thẻ ẩn. (SC-DECKDETAIL-28/73/76)
16. **Công thức + điều kiện định dạng meta sub-deck**: khi nào hiện "N decks · M words" vs "M words · mastered"
    (sub-deck lá / mastered-toàn-bộ / cả hai?); hậu tố trạng thái "mastered" là nhánh ARB có điều kiện — quy tắc
    hiện count vs hậu tố trạng thái cần chốt (i18n: hậu tố từ ARB). (SC-DECKDETAIL-101/101a)

> Các mục ⚠ là **danh sách phải hỏi BA/spec**, không được đoán. Có câu trả lời → cập nhật scenario + xoá cờ ⚠.
