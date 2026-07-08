# Open Questions — chốt spec trước khi sinh test

> Tổng hợp MỌI câu hỏi ⚠ (hành vi kit/business CHƯA định nghĩa) từ 21 file scenario.
> Đây là **hàng rào cuối**: chưa trả lời thì chưa sinh test cho phần đó. Điền vào ô `Trả lời:`
> (một câu là đủ). Xong mình sẽ **fold ngược** câu trả lời vào scenario tương ứng + xoá cờ ⚠.
> ID ổn định `OQ-<screen>-<n>` để scenario/commit trích dẫn.

**Tổng: 329 câu hỏi / 21 màn.**

## Mục lục

- [`dashboard` (10)](#dashboard)
- [`library` (15)](#library)
- [`deck-detail` (16)](#deck-detail)
- [`flashcard-editor` (10)](#flashcard-editor)
- [`game-picker` (13)](#game-picker)
- [`game-matching` (17)](#game-matching)
- [`game-mc` (14)](#game-mc)
- [`game-recall` (19)](#game-recall)
- [`game-typing` (19)](#game-typing)
- [`review` (18)](#review)
- [`player` (18)](#player)
- [`study-result` (13)](#study-result)
- [`search` (14)](#search)
- [`statistics` (23)](#statistics)
- [`reminder` (15)](#reminder)
- [`theme` (5)](#theme)
- [`import` (17)](#import)
- [`export` (16)](#export)
- [`drawer` (17)](#drawer)
- [`study-session` (21)](#study-session)
- [`settings` (19)](#settings)

<a id="dashboard"></a>
## `dashboard` — 10 câu · [file](dashboard.md)

**OQ-dashboard-1** — **Greeting**: ngưỡng buổi (sáng/chiều/tối) theo giờ nào? nguồn **tên** người dùng (profile/settings)? fallback khi rỗng?
> Trả lời: 

**OQ-dashboard-2** — **Continue-decks**: tiêu chí chọn (học gần nhất / có due / ...)? thứ tự? tối đa mấy thẻ (N=3?)?
> Trả lời: 

**OQ-dashboard-3** — **Mastered %**: công thức + phạm vi (toàn app / theo cặp ngôn ngữ đang chọn)?
> Trả lời: 

**OQ-dashboard-4** — **Goal ring**: hiển thị theo phút, theo từ, hay max(tiến độ)?
> Trả lời: 

**OQ-dashboard-5** — **Review FAB**: v1 là `comingSoon` (navigation-flow S0) hay ôn due thật (D-001)? — quyết định assert nào.
> Trả lời: 

**OQ-dashboard-6** — **Notifications / avatar**: đích khi tap?
> Trả lời: 

**OQ-dashboard-7** — **State empty**: gộp "chưa học hôm nay" và "chưa có deck" — cần tách?
> Trả lời: 

**OQ-dashboard-8** — **State error**: dashboard không có `error` trong kit — hiện gì khi đọc DB lỗi?
> Trả lời: 

**OQ-dashboard-9** — **Initial route** + **Android back** tại tab gốc.
> Trả lời: 

**OQ-dashboard-10** — **Nửa đêm**: chốt ngày realtime hay lazy khi mở lại?
> Trả lời: 


<a id="library"></a>
## `library` — 15 câu · [file](library.md)

**OQ-library-1** — **Trigger play-sheet**: DOM spec `loaded` không có id/nút "Play" trên `library/node-*`; play-sheet là state contract có thật nhưng **cách mở** (chạm card / long-press / nút Play riêng) chưa có → cần chốt (ảnh hưởng SC-LIBRARY-09, -49).
> Trả lời: 

**OQ-library-2** — **Đích khi chạm card** (`library/node-*`): mở deck-detail hay play-sheet? (ảnh hưởng SC-LIBRARY-25..29, -54).
> Trả lời: 

**OQ-library-3** — **`library/create` FAB đích**: mở deck-editor tạo mới, hay action-sheet (tạo deck / thêm từ / import)? (SC-LIBRARY-30).
> Trả lời: 

**OQ-library-4** — **Recent-search nguồn lưu**: schema-contract **không** có bảng/cột cho lịch sử tìm kiếm gần đây → recent-* lưu ở đâu? (settings? bảng mới? in-memory?) (SC-LIBRARY-05, -37..39).
> Trả lời: 

**OQ-library-5** — **Render kết quả tìm kiếm + chip lọc — cả hai vắng mặt trong DOM**: DOM spec `library` state `search-active` **chỉ** vẽ `search-dock` + "RECENT" head + `library/recent-*`. **KHÔNG có** node danh sách kết quả (results-list) **và KHÔNG có** hàng chip lọc trạng thái (BR-6 search nói FE giữ `search/filters` luôn hiện nhưng node đó không thấy trong DOM library). Cần chốt: **danh sách kết quả search render ở đâu** (màn `library` search-active hay màn `search` riêng?) và chip lọc thuộc màn nào — TRƯỚC khi assert cách hiển thị kết quả (SC-LIBRARY-05, -61..67, -66).
> Trả lời: 

**OQ-library-6** — **Đóng search-active**: chỉ có `library/search-clear` (xoá text); nút/đường thoát search (về loaded) là system-back hay có nút riêng? (SC-LIBRARY-53).
> Trả lời: 

**OQ-library-7** — **`swap_horiz` trên `library/pair`**: trang trí hay có hành động đảo chiều hiển thị riêng (D-011)? (SC-LIBRARY-23).
> Trả lời: 

**OQ-library-8** — **`library/of-select` ("Select multiple")**: hành vi chế độ chọn nhiều (xoá hàng loạt? di chuyển?) chưa có D-xxx (SC-LIBRARY-48).
> Trả lời: 

**OQ-library-9** — **Điểm vào xoá bộ thẻ ở library**: D-024 cascade rõ, nhưng UI trigger xoá deck từ màn library (qua select? deck-detail?) chưa trong DOM spec (SC-LIBRARY-92).
> Trả lời: 

**OQ-library-10** — **Drawer items đích chi tiết** (Remove language / Theme / FAQ / Email us / Sync alpha): chưa có D-xxx riêng cho từng item drawer-library (SC-LIBRARY-49b).
> Trả lời: 

**OQ-library-11** — **Escape LIKE wildcard** (`%`, `_`) trong search DAO: schema-contract §Search nêu LIKE nhưng không nêu escape (SC-LIBRARY-64).
> Trả lời: 

**OQ-library-12** — **Back tại tab Library gốc**: về Today (initial) hay thoát app? (SC-LIBRARY-55).
> Trả lời: 

**OQ-library-13** — **Đổi pair khi đang tải / mở 2 sheet chồng / huỷ xoá cascade giữa chừng**: hành vi tranh chấp chưa nêu (SC-LIBRARY-84, -121, -123).
> Trả lời: 

**OQ-library-14** — **State empty biến thể**: "chưa có deck nào trong cặp active" vs "chưa có cặp ngôn ngữ nào" — DOM spec chỉ 1 empty; cần tách?
> Trả lời: 

**OQ-library-15** — **Trạng thái search 0 kết quả (zero-match)**: DOM spec `search-active` **không có** node "no results / empty results". Khi truy vấn hợp lệ khớp 0 thẻ, hiển thị gì (giữ RECENT? thông báo "không có kết quả"? ở màn nào?) chưa được kit định nghĩa → phải chốt TRƯỚC khi assert render 0-match (SC-LIBRARY-67). Đây vừa là điểm cần chốt spec, vừa là thiếu-node UI.
> Trả lời: 


<a id="deck-detail"></a>
## `deck-detail` — 16 câu · [file](deck-detail.md)

**OQ-deck-detail-1** — **play-audio (volume_up)**: đích khi tap? Đọc TTS toàn deck hay mở Trình phát (route `player`)? Chưa có D-xxx gán icon appbar này. (SC-DECKDETAIL-22)
> Trả lời: 

**OQ-deck-detail-2** — **Cử chỉ mở card-actions vs mở editor**: tap card thẻ mở bottom-sheet `card-actions` hay mở `flashcardEditor` trực tiếp? long-press? (SC-DECKDETAIL-08/27)
> Trả lời: 

**OQ-deck-detail-3** — **sort (swap_vert)**: 1 icon — mở picker chọn tiêu chí (bảng chữ cái/ngày tạo/ngày học) rồi chọn chiều, hay chỉ toggle chiều? UI chọn tiêu chí ở đâu? (D-023, SC-DECKDETAIL-25)
> Trả lời: 

**OQ-deck-detail-4** — **Reset progress**: phạm vi (chỉ thẻ trực tiếp hay đệ quy cây con)? có xoá `review_logs` không? Chưa có D-xxx/BR riêng cho reset-progress. (SC-DECKDETAIL-10/45)
> Trả lời: 

**OQ-deck-detail-5** — **Rename / New sub-deck**: UI nhập tên (dialog rename? màn?) — **không có** trong DOM spec màn này; validation tên (rỗng/trùng/dài/CJK/trim) thuộc màn nào? (SC-DECKDETAIL-37/46/95)
> Trả lời: 

**OQ-deck-detail-6** — **Unhide**: card-actions chỉ có "Hide card" — khi thẻ đang ẩn, có mục "Unhide"/"Show" thay thế không? (SC-DECKDETAIL-43)
> Trả lời: 

**OQ-deck-detail-7** — **empty ẩn search-dock**: spec empty (full) không có search-dock — deck rỗng có ẩn hẳn ô tìm không? (SC-02)
> Trả lời: 

**OQ-deck-detail-8** — **Section rỗng**: deck chỉ-sub-deck (không thẻ) hay chỉ-thẻ (không sub-deck) — header SUB-DECKS/CARDS ẩn khi nhóm rỗng? (SC-DECKDETAIL-71/72)
> Trả lời: 

**OQ-deck-detail-9** — **error copy**: kit mock "Check your connection" nhưng v1 local-first (không remote BE) — nguồn lỗi đọc DB thực là gì? ARB nên diễn đạt sao? (SC-DECKDETAIL-04/84)
> Trả lời: 

**OQ-deck-detail-10** — **search field rỗng**: về loaded hay hiện gợi ý/recent? Escape wildcard LIKE (`%`,`_`) khi gõ ký tự đặc biệt? (SC-DECKDETAIL-60/65)
> Trả lời: 

**OQ-deck-detail-11** — **deckId không tồn tại / deck bị xoá nơi khác**: deck-detail hiện error/empty hay pop? (SC-DECKDETAIL-50/123)
> Trả lời: 

**OQ-deck-detail-12** — **card-actions cho sub-deck**: spec chỉ có actions cho **thẻ**; sub-deck có menu ngữ cảnh riêng (rename/move/delete cấp sub-deck) hay phải mở sub-deck rồi dùng deck-menu?
> Trả lời: 

**OQ-deck-detail-13** — **Badge sub-deck "28" (primary-soft) vs "✓" (success-soft)**: "28" = số đến hạn hay số thẻ? "✓" = mastered toàn bộ? Công thức + phạm vi (đệ quy) + **điều kiện chọn biến thể** badge cần chốt (assert nguồn, không mock). (SC-DECKDETAIL-26/49b/49c)
> Trả lời: 

**OQ-deck-detail-14** — **Schema `settings` cho sort**: D-023 chỉ định nghĩa *hành vi* sắp xếp — KHÔNG cho tên cột/khoá, KHÔNG nói tiêu chí+chiều được **persist**, KHÔNG nói **per-app hay per-deck**. Tên `deck.sort_criteria`/`deck.sort_dir` và round-trip là suy đoán → cần schema `settings` thực tế trước khi viết assertion persist. (SC-DECKDETAIL-25/96)
> Trả lời: 

**OQ-deck-detail-15** — **Công thức đếm "N words" (card/meta) với thẻ ẩn**: D-006 chỉ loại thẻ ẩn khỏi *hàng đợi / số đến hạn*, KHÔNG nói về số hiển thị "N words". "N words `WHERE hidden=0`" dựa trên 'BR-6' chưa xác minh trong 3 nguồn đối chiếu ⇒ cần trích BR-6 chính xác (hoặc D-xxx) xác nhận "N words" có/không đếm thẻ ẩn. (SC-DECKDETAIL-28/73/76)
> Trả lời: 

**OQ-deck-detail-16** — **Công thức + điều kiện định dạng meta sub-deck**: khi nào hiện "N decks · M words" vs "M words · mastered" (sub-deck lá / mastered-toàn-bộ / cả hai?); hậu tố trạng thái "mastered" là nhánh ARB có điều kiện — quy tắc hiện count vs hậu tố trạng thái cần chốt (i18n: hậu tố từ ARB). (SC-DECKDETAIL-101/101a)
> Trả lời: 


<a id="flashcard-editor"></a>
## `flashcard-editor` — 10 câu · [file](flashcard-editor.md)

**OQ-flashcard-editor-1** — **Save của thẻ mới**: có ghi `srs_state` box=0 hay để **không có hàng** (absent = new)? (SC-13)
> Trả lời: 

**OQ-flashcard-editor-2** — **grammatical_gender**: danh sách gender **cố định 4** (None/Masc/Fem/Neutral) hay theo ngôn ngữ? — *đây là câu hỏi duy nhất còn ngỏ; giá trị lưu thực ĐÃ RÕ:* build hiện tại `cards.grammatical_gender` ∈ { NULL, 'masc', 'fem', 'neutral' } (const `editorGenders`, None ⇒ NULL). Không còn để ngỏ "enum/string". (SC-18..21)
> Trả lời: 

**OQ-flashcard-editor-3** — **Nghĩa phụ — bộ chọn ngôn ngữ (mâu thuẫn nguồn S.12 vs code)**: S.12 dòng 37 nói **CÓ** picker (endonym, `supported_languages.dart`); code **KHÔNG** có — hardcode `_secondaryLanguage='vi'`, comment "deferred — gap". Chốt: build picker theo S.12 hay giữ hardcode? Ngoài ra: cho phép trùng ngôn ngữ với nghĩa mẹ đẻ? nút **xoá** 1 khối? khối **rỗng** khi Save → code hiện **bỏ qua** (chỉ thêm hàng nếu `secondaryText` không rỗng) — xác nhận đúng ý? số nghĩa phụ **tối đa** (kit "x5+" chỉ MOCK)? (SC-05, SC-17, SC-49, SC-52)
> Trả lời: 

**OQ-flashcard-editor-4** — **Dup-check**: code so **cùng deck** + `excluding: cardId` (`DetectDuplicateTermUseCase`); trigger = **khi gõ** (`setTerm` → `_checkDuplicate`). Còn ngỏ: hoa-thường / trim / chuẩn hoá Unicode khi so? (SC-04, SC-64)
> Trả lời: 

**OQ-flashcard-editor-5** — **Spec-đích chưa build (KHÔNG phải "audio hoãn" — sửa claim cũ)**: (a) **`dup-view`/`dup-add` + banner `<term>` nội suy** — build hiện tại banner là `MxActionCallout` **không nút, text tĩnh `editorDupWarning` không `<term>`**; 2 nút + `<term>` là spec-đích DOM (chờ màn danh sách thẻ/W6). (b) **State kit `audio(sync)` "Generating from term…"** — TTS **đã ship dạng live-speak** (`speak` tức thì); state generating/`sync` **undrivable** (không async-generating quan sát được). Chốt: có build async-generate + file-audio (`card.audio_ref`) không, hay giữ live-speak? **KHÔNG có `comingSoon`** ở bất kỳ đâu. (SC-04, SC-06, SC-24, SC-35, SC-62, SC-83)
> Trả lời: 

**OQ-flashcard-editor-6** — **Cancel/back khi form dirty**: có dialog "Bỏ thay đổi?" không? DOM spec không có confirm-dialog. (SC-10, SC-34, SC-97)
> Trả lời: 

**OQ-flashcard-editor-7** — **Giới hạn độ dài / ký tự cấm** cho term & meaning: BR/schema không quy định max/blacklist. (SC-45, SC-46)
> Trả lời: 

**OQ-flashcard-editor-8** — **Save lưu-lỗi — surface + retry CHƯA build (sửa claim cũ)**: code `save()` chỉ `return false` + `logger.error`; screen `if (saved && mounted) context.pop()` ⇒ **ở lại màn, không surface, không retry, không key ARB `editorSaveError*`** (khác màn Study đã có). Chốt: có thêm surface+retry (giống Study) không, copy + vị trí? State loading của Save cũng không có (DOM chỉ 6 state). (SC-60, SC-61)
> Trả lời: 

**OQ-flashcard-editor-9** — **Entry point khi ôn (inline edit)**: pushed hay overlay? có prefill từ thẻ đang ôn không? (SC-31)
> Trả lời: 

**OQ-flashcard-editor-10** — **Ngôn ngữ meaning theo pair active (S0)**: code hardcode `_primaryLanguage='en'`, `_secondaryLanguage= 'vi'`, `_termSpeakLanguage='ko'` (đều "deferred — gap") — **chưa** lấy `native`/`learning` từ pair active. Xác nhận: khi wire pair, `card_meanings.language` primary = native, secondary = ngôn ngữ chọn; TTS `languageCode` = learning của pair. (SC-05, SC-06, SC-13, SC-70, SC-80)
> Trả lời: 


<a id="game-picker"></a>
## `game-picker` — 13 câu · [file](game-picker.md)

**OQ-game-picker-1** — **Ngưỡng "đủ từ"**: kit banner MOCK ghi "at least 4 words" nhưng `game.words_per_round` mặc định = **5**. Ngưỡng-tối-thiểu để bật 4 game là 4, 5, hay = `words_per_round`? BR-2 chỉ nói "≥ N từ". → chốt con số + nguồn.
> Trả lời: 

**OQ-game-picker-2** — **Footer "change in Settings"**: là text tĩnh (spec `node:div`, không `mx:`) hay là link/nút chạm mở màn Settings? Nếu link → thêm scenario nav ra Settings.
> Trả lời: 

**OQ-game-picker-3** — **Nút "Add words"** (not-enough): đích khi tap — `flashcardEditor` (tạo thẻ cho nút nguồn), `deckImport`, hay màn khác? Chưa có D-xxx/navigation-flow.
> Trả lời: 

**OQ-game-picker-4** — **Phạm vi (scope) lưu ở đâu**: chỉ giữ trong phiên/route param (`gamePlay.scope`) hay ghi bền vào `settings` (khoá nào — schema-contract KHÔNG có khoá `game.scope`)? Ảnh hưởng round-trip kill (SC-GAMEPICKER-63).
> Trả lời: 

**OQ-game-picker-5** — **Định nghĩa "Unlearned only"**: "chưa thuộc" = `srs_state.box` < 8 (chưa mastered) hay = box 0/absent (chưa xếp lịch = mới)? "By schedule" (BR-5: ưu tiên đến hạn + mới) tiêu chí chọn thẻ cụ thể ra sao?
> Trả lời: 

**OQ-game-picker-6** — **Back priority khi sheet mở**: back hệ thống đóng sheet trước rồi mới pop màn (SC-GAMEPICKER-33) — xác nhận đúng.
> Trả lời: 

**OQ-game-picker-7** — **State loading**: kit game-picker chỉ có 3 state, KHÔNG có loading — hiển thị gì trong lúc đếm thẻ/đọc settings?
> Trả lời: 

**OQ-game-picker-8** — **State error**: kit KHÔNG có error — hiển thị gì khi đọc DB (cards/settings) lỗi?
> Trả lời: 

**OQ-game-picker-9** — **Reactive re-evaluate**: picker đang mở, thẻ bị xoá/ẩn nơi khác khiến tụt ngưỡng — picker có tự chuyển default↔not-enough theo thời gian thực không?
> Trả lời: 

**OQ-game-picker-10** — **Thứ tự & danh sách 4 game cố định**: kit liệt kê Matching→MC→Recall→Typing — xác nhận thứ tự này là cố định (không cấu hình/ẩn game nào).
> Trả lời: 

**OQ-game-picker-11** — **Card scope ở not-enough**: state not-enough vẫn hiện card scope (spec giữ) — chạm scope khi not-enough có mở sheet được không, hay cũng bị disable như 4 card game?
> Trả lời: 

**OQ-game-picker-12** — **Title clip vs ellipsis**: spec `appbar__title` chỉ có `position: clip` (overflow hidden) + `grow:1 basis:0`, KHÔNG có thuộc tính ellipsis/`text-overflow`. Tiêu đề dài cắt cụt trơn (`clip`) hay hiện dấu "…" (ellipsis)? Kit chỉ chứng minh `clip`; ellipsis là suy diễn → chốt spec (SC-GAMEPICKER-11/74).
> Trả lời: 

**OQ-game-picker-13** — **Ai đọc & lọc danh sách thẻ đưa vào ván** — game-picker hay `gamePlay`? Picker chỉ đọc **đếm đủ-từ** (SC-GAMEPICKER-40..45) rồi push `nodeId`+`scope`, còn `gamePlay` đọc/lọc danh sách thẻ thật (theo `scope` + `hidden=0` D-006 + subtree đệ quy D-009) TẠI ván? Hay picker đọc sẵn danh sách và truyền qua? Ảnh hưởng assertion DB-read của SC-GAMEPICKER-13..16 (SC-GAMEPICKER-13 nêu ranh giới này).
> Trả lời: 


<a id="game-matching"></a>
## `game-matching` — 17 câu · [file](game-matching.md)

**OQ-game-matching-1** — **Số tile & xáo trộn**: số tile mỗi cột = `game.words_per_round` (mock 5)? Thứ tự tile xáo theo `game.random`?
> Trả lời: 

**OQ-game-matching-2** — **Chiều ghép**: bắt buộc trái(term)→phải(nghĩa) hay tap 1 trái + 1 phải theo thứ tự bất kỳ? Chọn 2 tile cùng cột có hợp lệ?
> Trả lời: 

**OQ-game-matching-3** — **Khoá ghép theo `card_id`**: ghép đúng dựa trên id thẻ (không so text) để tile trùng term/nghĩa (D-020) không ghép nhầm?
> Trả lời: 

**OQ-game-matching-4** — **Nghĩa dùng cho tile**: khi thẻ nhiều nghĩa, Matching dùng nghĩa đầu (`sort_index` nhỏ nhất) hay ngẫu nhiên?
> Trả lời: 

**OQ-game-matching-5** — **progress**: spec đích đã đặt = `matched/total × 350px` (3 mốc DOM 70/210/350 = 1/5·3/5·5/5 — SC-GAMEMATCHING-03); chỉ còn cần BA xác nhận đơn vị là **số cặp** (không phải % thời gian) và không có easing/animation khác.
> Trả lời: 

**OQ-game-matching-6** — **Nút options (3 chấm)**: mở gì? Không có overlay trong contract 6 state, không có D-xxx.
> Trả lời: 

**OQ-game-matching-7** — **Thoát giữa ván**: back appbar / Android back có hỏi xác nhận (dialog)? Không có dialog trong kit.
> Trả lời: 

**OQ-game-matching-8** — **State loading / error / empty**: kit chỉ có 6 state chơi — khi dựng ván (loading), đọc thẻ lỗi (error), hoặc scope 0 thẻ (empty) thì hiện gì? Nếu cần, phải bổ sung kit trước (kit-first).
> Trả lời: 

**OQ-game-matching-9** — **wrong feedback**: sau khi hiện error, tile tự bỏ chọn về playing hay giữ đến tap kế? Thời lượng phản hồi?
> Trả lời: 

**OQ-game-matching-10** — **Next round**: nguồn thẻ ván kế (lấy tiếp thẻ chưa luyện / xáo lại / xử lý khi < round size); có hết-thẻ thì sao?
> Trả lời: 

**OQ-game-matching-11** — **scope picker (BR-5)**: người chơi chọn scope (Theo giãn cách / Tất cả / Chỉ chưa thuộc) ở picker trước ván?
> Trả lời: 

**OQ-game-matching-12** — **Resume ván**: xác nhận Matching KHÔNG resume tiến độ (không có bảng persist trong schema)?
> Trả lời: 

**OQ-game-matching-13** — **Deep-link `gamePlay`**: có cho vào thẳng ván (route tồn tại) hay bắt buộc qua picker?
> Trả lời: 

**OQ-game-matching-14** — **`game.words_per_round` biên**: giá trị min/max hợp lệ?
> Trả lời: 

**OQ-game-matching-15** — **Concurrency**: khoá input khi đang chấm correct/wrong? double-tap cùng tile = toggle bỏ chọn?
> Trả lời: 

**OQ-game-matching-16** — **A11y**: cặp đúng "biến mất" có live-region thông báo cho screen-reader không?
> Trả lời: 

**OQ-game-matching-17** — **Cơ chế + thời điểm gỡ cặp đúng**: state `correct` giữ **cả hai** tile trong DOM (chỉ restyle success-soft); việc gỡ node chỉ xuất hiện ở `almost`/`complete`. Chuỗi chuyển correct → highlight → gỡ khỏi lưới và **thời lượng** của nó KHÔNG có snapshot nào chứng minh → cần chốt (SC-GAMEMATCHING-03).
> Trả lời: 


<a id="game-mc"></a>
## `game-mc` — 14 câu · [file](game-mc.md)

**OQ-game-mc-1** — **Chiều hiển thị (D-011)**: prompt = term / 4 ô = nghĩa — khi cặp đảo (KO↔VI) thì term-side là gì? **D-011** ("đảo chiều hiển thị KO↔VI → dùng CÙNG một `SrsState` một chiều") chốt lịch SRS một chiều, nhưng KHÔNG chốt chiều **hiển thị** của game (prompt=term/4 ô=nghĩa, xử lý cặp đảo). Map trực tiếp về SC-GAMEMC-01/14.
> Trả lời: 

**OQ-game-mc-2** — **Nút options (3-chấm)**: đích khi tap? kit không có menu/sheet cho game-mc (intent-ledger ghi node tái dùng key, realign hoãn) — hiện gì?
> Trả lời: 

**OQ-game-mc-3** — **Nút edit**: sửa thẻ hiện tại giữa ván? mở màn gì? có trong luồng nào không?
> Trả lời: 

**OQ-game-mc-4** — **Nút audio**: TTS/audio hoãn v1 (audio_ref NULL) — nút hiển thị nhưng no-op, hay ẩn?
> Trả lời: 

**OQ-game-mc-5** — **Số lựa chọn & nguồn nhiễu**: cố định 4 ô? nhiễu lấy từ cùng tập ván, cùng deck, hay toàn cặp ngôn ngữ?
> Trả lời: 

**OQ-game-mc-6** — **Công thức progress & "N/M correct"**: đếm theo thẻ-đúng hay theo lượt (có tính lần lặp do sai — D-015)?
> Trả lời: 

**OQ-game-mc-7** — **Biên số thẻ**: <round size (vd 3) → chạy hay chặn? 1 thẻ (không đủ nhiễu) → xử lý sao? 0 thẻ → không có state empty trong contract.
> Trả lời: 

**OQ-game-mc-8** — **State loading/error**: contract game-mc chỉ có 4 state (waiting/correct/wrong/complete) — hiện gì khi đang tải tập thẻ hoặc query lỗi?
> Trả lời: 

**OQ-game-mc-9** — **"Next round"**: lấy tập thẻ mới khác hay lặp cùng tập? xử lý khi hết thẻ khả dụng?
> Trả lời: 

**OQ-game-mc-10** — **Back giữa ván**: có dialog xác nhận "bỏ ván"? pop về picker hay deck-detail?
> Trả lời: 

**OQ-game-mc-11** — **Bối cảnh nhúng (chặng 2–5 NewLearn) vs chạy-riêng**: cùng screen `game-mc` phục vụ cả hai, hay màn riêng? khác biệt kết thúc (complete "Next round" vs chuyển chặng) cần chốt.
> Trả lời: 

**OQ-game-mc-12** — **Resume ván sau kill**: ván đang dở có được khôi phục không? (không có bảng lưu state ván trong schema).
> Trả lời: 

**OQ-game-mc-13** — **Khoá lựa chọn sau lần chấm đầu**: sau khi chọn 1 ô, các ô khác có bị vô hiệu cho thẻ đó không?
> Trả lời: 

**OQ-game-mc-14** — **Chuyển tiếp sau state wrong/correct**: tự động sang thẻ kế hay chờ người học tap tiếp? (Cửa sổ chuyển tiếp feedback→advance là edge race của **SC-GAMEMC-94** — assertion đầy đủ phụ thuộc câu trả lời mục này.)
> Trả lời: 


<a id="game-recall"></a>
## `game-recall` — 19 câu · [file](game-recall.md)

**OQ-game-recall-1** — **Nút `options` (more_horiz)**: mở menu/sheet gì? nội dung menu-item? (kit không chụp overlay; không có D-xxx/business) — SC-GAMERECALL-11.
> Trả lời: 

**OQ-game-recall-2** — **Nút `audio`**: v1 phát TTS live hay no-op/disabled (schema `cards.audio_ref` NULL ở v1, TTS hoãn DT.7)? — SC-GAMERECALL-12.
> Trả lời: 

**OQ-game-recall-3** — **Nút `edit`**: đích khi chạm (mở editor thẻ hiện tại?); quay lại Recall giữ vị trí ván? — SC-GAMERECALL-13.
> Trả lời: 

**OQ-game-recall-4** — **Nút `next` "Next round"**: bắt đầu ván mới trên cùng deck (lấy words_per_round thẻ, random theo `game.random`) hay quay về màn nguồn? — SC-GAMERECALL-17.
> Trả lời: 

**OQ-game-recall-5** — **Thời lượng banner** forgot/remembered trước khi tự chuyển thẻ (tự động sau N ms hay chờ thao tác?) — SC-GAMERECALL-03/04.
> Trả lời: 

**OQ-game-recall-6** — **Back giữa ván**: có dialog xác nhận "bỏ ván"? chặn swipe-dismiss/Android back? — SC-GAMERECALL-10/34/35.
> Trả lời: 

**OQ-game-recall-7** — **State empty**: khi 0 thẻ đủ điều kiện (deck rỗng / toàn hidden / phạm vi rỗng) — kit không có state empty cho màn này; hiện gì? — SC-GAMERECALL-40.
> Trả lời: 

**OQ-game-recall-8** — **State loading**: dựng ván — kit không có `loading`; hiện skeleton/spinner/mở ngay? — SC-GAMERECALL-50.
> Trả lời: 

**OQ-game-recall-9** — **State error**: đọc thẻ/settings lỗi — kit không có `error`; surface lỗi + retry ra sao? — SC-GAMERECALL-51/52.
> Trả lời: 

**OQ-game-recall-10** — **Progress ở NewLearn**: tính theo 5 chặng tích luỹ hay theo thẻ trong chặng Recall? — SC-GAMERECALL-31.
> Trả lời: 

**OQ-game-recall-11** — **NewLearn graduating** có ghi `review_logs` không (schema mô tả review_logs cho DueReview grade; NewLearn chỉ đổi box)? — SC-GAMERECALL-62.
> Trả lời: 

**OQ-game-recall-12** — **Resume ván**: kill/mở lại app giữa ván game độc lập — không persist tiến độ ván (không bảng trong schema) → xác nhận "không resume"? — SC-GAMERECALL-63.
> Trả lời: 

**OQ-game-recall-13** — **words_per_round biên**: có min/max? ván lấy min(words_per_round, thẻ khả dụng)? — SC-GAMERECALL-41/43.
> Trả lời: 

**OQ-game-recall-14** — **Số meaning hiển thị** sau reveal: chỉ meaning đầu, hay nối nhiều meaning (spec: 1 nghĩa chính + 1 dòng phụ)? — SC-GAMERECALL-73.
> Trả lời: 

**OQ-game-recall-15** — **Label phạm vi BR-5** trong picker (Theo giãn cách / Tất cả / Chỉ chưa thuộc) — nguồn ARB? (thuộc màn `game`, ảnh hưởng tập thẻ vào Recall) — SC-GAMERECALL-30.
> Trả lời: 

**OQ-game-recall-16** — **A11y hit-area `edit`**: icon 36x36 < 48 — có mở rộng vùng chạm ≥48 không? — SC-GAMERECALL-82.
> Trả lời: 

**OQ-game-recall-17** — **Đảo Forgot/Got it** sát nhau: khoá nút sau chấm đầu? — SC-GAMERECALL-91.
> Trả lời: 

**OQ-game-recall-18** — **Định nghĩa hoàn thành ván khi có thẻ Forgot**: D-015 chỉ nói "phiên xong khi MỌI thẻ đã đúng"; điều kiện chính xác để đạt `complete` khi có thẻ Forgot chưa có nguồn kit/contract — thẻ Forgot phải được Got-it lại rồi mới complete, hay Forgot chỉ đẩy xuống cuối hàng đợi **1 lần**? — SC-GAMERECALL-05.
> Trả lời: 

**OQ-game-recall-19** — **Component mapping / identity contract cho control game-recall**: mọi control tương tác (`back`/`options`/`audio`/`edit`/`reveal`/`forgot`/`remembered`/`next`) là `mx:?` trong DOM spec = không có MemoX component mapping tin cậy; khoá identity per-screen (`tool/parity/contracts/`) cho các control này chưa được chốt — chốt mapping/identity key nào? — SC-GAMERECALL-18..21.
> Trả lời: 


<a id="game-typing"></a>
## `game-typing` — 19 câu · [file](game-typing.md)

**OQ-game-typing-1** — **Dung sai so khớp (game-modes §6 "chấp nhận dung sai")**: quy tắc cụ thể? case-insensitive? bỏ/chuẩn hoá dấu cách? khoảng cách chỉnh sửa (Levenshtein) ngưỡng bao nhiêu? — chưa có ở business/D-xxx (SC-GAMETYPING-45).
> Trả lời: 

**OQ-game-typing-2** — **Nút "Correct" (`game-typing/accept`)**: ngữ nghĩa "tự chấm đúng dù gõ sai" (override dung sai) — chưa có D-xxx/BR khẳng định (SC-GAMETYPING-18).
> Trả lời: 

**OQ-game-typing-3** — **Nội dung/quy tắc gợi ý (state hint)**: gợi ý gồm gì (số ký tự? ký tự đầu?), lộ dần hay cố định, bấm nhiều lần? — kit mock "Hint: 2 characters, starts with 친" (SC-GAMETYPING-03/15/84).
> Trả lời: 

**OQ-game-typing-4** — **Nút options (more_horiz)**: menu gì, item nào? DOM spec không liệt kê menu-item (SC-GAMETYPING-11).
> Trả lời: 

**OQ-game-typing-5** — **"Next round" (state complete)**: bắt ván mới (lấy tập kế theo D-008) hay đóng về picker/menu? (SC-GAMETYPING-20/33).
> Trả lời: 

**OQ-game-typing-6** — **Back giữa ván**: có confirm "bỏ ván" không? (SC-GAMETYPING-10/32/35).
> Trả lời: 

**OQ-game-typing-7** — **0 thẻ đủ điều kiện**: game-typing không có state `empty` — hiển thị gì / có mở ván không? (SC-GAMETYPING-50).
> Trả lời: 

**OQ-game-typing-8** — **loading / error**: game-typing không có state `loading`/`error` trong kit — surface gì khi nạp/đọc lỗi? (SC-GAMETYPING-60/61).
> Trả lời: 

**OQ-game-typing-9** — **Thẻ ẩn (D-006) với game**: game có loại `hidden` như queue học không (D-006 nói "hàng đợi/đếm")? (SC-GAMETYPING-72).
> Trả lời: 

**OQ-game-typing-10** — **Ranh giới chốt SRS ở NewLearn chặng 5**: màn game-typing hay lộ trình NewLearn ghi `srs_state` box 1 (D-002)? thoát giữa chặng 5 (D-017)? (SC-GAMETYPING-31/73).
> Trả lời: 

**OQ-game-typing-11** — **Nguồn tên ngôn ngữ trong "Type the term (…)"**: `language_pairs.learning_language` raw hay map tên hiển thị? (SC-GAMETYPING-81).
> Trả lời: 

**OQ-game-typing-12** — **Giữ/khôi phục ván khi đưa nền/kill**: ván (thẻ hiện tại + hàng đợi + input) reset hay resume? (SC-GAMETYPING-36/74/98).
> Trả lời: 

**OQ-game-typing-13** — **Trim / chỉ khoảng trắng ở input**: coi như rỗng hay trim rồi so? có giới hạn độ dài nhập? (SC-GAMETYPING-41/43).
> Trả lời: 

**OQ-game-typing-14** — **Công thức progress bar**: theo số thẻ đã đúng / theo lượt chấm? (SC-GAMETYPING-12).
> Trả lời: 

**OQ-game-typing-15** — **Deep-link**: có route độc lập tới game-typing không, hay chỉ overlay qua picker/NewLearn? (SC-GAMETYPING-34).
> Trả lời: 

**OQ-game-typing-16** — **Thiếu thẻ so với `words_per_round`**: dùng ít hơn hay báo? (SC-GAMETYPING-54).
> Trả lời: 

**OQ-game-typing-17** — **Meaning nào khi thẻ có nhiều `card_meanings`**: game Điền hiển thị nghĩa nào (đầu / primary / theo `sort_index`)? — KHÔNG có ở contract/DOM spec/D-xxx/game-modes (SC-GAMETYPING-13).
> Trả lời: 

**OQ-game-typing-18** — **Ngữ nghĩa nút Retry (`game-typing/retry`)**: tap Retry → gõ lại **cùng thẻ ngay** hay **đẩy thẻ về cuối hàng đợi ván**? có xoá input không? — DOM spec chỉ liệt node btn, không mô tả kết quả; D-015/BR-3 chỉ nói "sai → học lại trong ván" (SC-GAMETYPING-19/58).
> Trả lời: 

**OQ-game-typing-19** — **Phạm vi BR-5 định lượng**: nhãn/nguồn ARB 3 phạm vi (thuộc màn `game`); công thức "còn yếu"/ngưỡng "chưa thuộc" (box < N? chưa graduate?) — chưa định lượng ở business/D-xxx (SC-GAMETYPING-55/57).
> Trả lời: 


<a id="review"></a>
## `review` — 18 câu · [file](review.md)

**OQ-review-1** — **State end trigger**: sau thẻ cuối, vào `end` tự động hay cần thao tác next/swipe? (spec định nghĩa state, không định nghĩa trigger). 1b. **Audio state trigger THOÁT**: audio state (graphic_eq + "Playing…") thoát khi nào — **auto khi TTS kết thúc**, hay **tap-again toggle**? spec `audio` chỉ là trạng thái tĩnh, không định nghĩa transition/thời điểm thoát (SC-REVIEW-03/15; liên quan double-tap SC-REVIEW-97).
> Trả lời: 

**OQ-review-2** — **Nút text-size** (`review/text-size`): đích/chức năng khi tap? (kit không định nghĩa overlay).
> Trả lời: 

**OQ-review-3** — **Nút options** (`review/options`, more_vert): menu gồm item gì? (kit không có node menu/sheet — KHÔNG bịa item).
> Trả lời: 

**OQ-review-4** — **Study now** (state end): đích điều hướng (mở `/study/:nodeId` newLearn? Play menu? khác?).
> Trả lời: 

**OQ-review-5** — **Progress ngữ nghĩa**: đếm theo thẻ đã xem hay vị-trí con trỏ? N = tổng thẻ hiển thị (đã loại hidden)?
> Trả lời: 

**OQ-review-6** — **D-006 ở review**: review có loại thẻ ẩn khỏi hàng đợi như học/ôn không? (SC-REVIEW-54).
> Trả lời: 

**OQ-review-7** — **D-009 ở review**: review tại nút cha có gộp đệ quy cây con không? (BR-6 nêu "học/ôn"; review là luyện tập — SC-REVIEW-34).
> Trả lời: 

**OQ-review-8** — **Thẻ nhiều nghĩa**: review hiển thị nghĩa nào? (giả định first/sort_index=0 — cần xác nhận).
> Trả lời: 

**OQ-review-9** — **Sửa nghĩa nhiều-nghĩa**: field editing sửa nghĩa nào (nghĩa đang hiển thị)? có sửa được nghĩa thứ 2+ không?
> Trả lời: 

**OQ-review-10** — **Validation lỗi editing**: kit editing không có node thông báo lỗi — nội dung + vị trí lỗi (rỗng/quá dài) hiển thị ở đâu? 10b. **Trạng thái nút Save theo field**: Save có **disable khi field rỗng** (sau trim) rồi enable lại khi có nội dung, hay **luôn enable** rồi chặn-tại-Save (SC-REVIEW-40)? DOM editing KHÔNG có disabled-state cho Save (SC-REVIEW-47). 10c. **Phụ đề state end (nội dung dịch)**: chỉ chốt **nguồn = ARB**; nội dung dịch cụ thể do BA/l10n quyết (spec chỉ có mock "You've gone through every card in this deck." — SC-REVIEW-04). 10d. **Caret editing khi blur**: caret (span `text: |`, primary) chỉ được spec chụp ở trạng thái focus tĩnh — ẩn/hiện khi field mất focus như thế nào? (SC-REVIEW-25).
> Trả lời: 

**OQ-review-11** — **Giới hạn độ dài nghĩa**: có max không? (schema/business không nêu — SC-REVIEW-41).
> Trả lời: 

**OQ-review-12** — **State loading**: dựng hàng đợi hiển thị gì? (kit không có `loading` — SC-REVIEW-60).
> Trả lời: 

**OQ-review-13** — **Lỗi TTS / lỗi Save**: kit không có state lỗi — surface lỗi + retry ở đâu? (SC-REVIEW-61/62).
> Trả lời: 

**OQ-review-14** — **0 thẻ hiển thị**: hiện `end` ngay hay empty riêng? (kit không có `empty` — SC-REVIEW-50).
> Trả lời: 

**OQ-review-15** — **Back tại thẻ đầu (prev)** và **next tại thẻ cuối**: no-op/disabled/vòng lại/vào end? (biên điều hướng).
> Trả lời: 

**OQ-review-16** — **Edit chưa lưu + đổi thẻ/back**: hủy / chặn / hỏi xác nhận? (SC-REVIEW-35/98).
> Trả lời: 

**OQ-review-17** — **Đổi thẻ khi đang phát audio**: có tự dừng TTS không? (SC-REVIEW-64).
> Trả lời: 

**OQ-review-18** — **Chống double-tap next/audio**: yêu cầu ẩn — cần chốt (SC-REVIEW-95/97).
> Trả lời: 


<a id="player"></a>
## `player` — 18 câu · [file](player.md)

**OQ-player-1** — **Trình tự card (D-014)**: D-014 nói "lần lượt hiện term + nghĩa + audio" nhưng DOM vẽ term+nghĩa **cùng lúc**. Card hiện đồng thời hay lần lượt (term trước → nghĩa sau)? Có timing/delay mỗi bước?
> Trả lời: 

**OQ-player-2** — **text-size (`player/format_size`)**: đích khi tap? Không có key ARB, không có D-xxx/business. Mở picker cỡ chữ? Áp `theme.font_scale` cục bộ trong player?
> Trả lời: 

**OQ-player-3** — **options (`player/more_vert`)**: menu-item nào? DOM chỉ có node more_vert, không có sheet/menu con. Cần kit định nghĩa danh sách item + hành vi + `/design-sync`.
> Trả lời: 

**OQ-player-4** — **Speed**: tập giá trị chốt = {×0.75, ×1, ×1.5}? Mặc định ×1? Đơn vị speed áp vào cái gì (thời gian dừng mỗi thẻ — vì audio hoãn)? Chọn xong control tự đóng về nút "×N" hay giữ mở?
> Trả lời: 

**OQ-player-5** — **Progress dots**: 1 dot = 1 thẻ? Khi N rất lớn (500) hiển thị thế nào (spec mock chỉ 8 dot)?
> Trả lời: 

**OQ-player-6** — **Card nhiều nghĩa**: hiện nghĩa đầu (`sort_index` nhỏ nhất) hay cuộn/lật hết các nghĩa?
> Trả lời: 

**OQ-player-7** — **Biên transport**: prev ở thẻ đầu = no-op/disable/vòng? next ở thẻ cuối = end/no-op/vòng? Với node 1 thẻ, prev/next làm gì?
> Trả lời: 

**OQ-player-8** — **State empty**: kit contract chỉ 4 state (không có `empty`) nhưng ARB đã có `playerEmpty*`. Cần thêm state `empty` vào kit + `/design-sync`. Ngưỡng rỗng = 0 thẻ visible (loại hidden, D-006)?
> Trả lời: 

**OQ-player-9** — **State error**: kit không có `error` dù ARB có `playerError*`. Cần thêm vào kit; retry đi đâu?
> Trả lời: 

**OQ-player-10** — **State loading**: kit không có `loading`. Hiển thị gì khi đang dựng hàng đợi (skeleton/spinner)?
> Trả lời: 

**OQ-player-11** — **`playerTitle`="Player"**: dùng ở đâu? DOM appbar title = tên deck (`decks.name`), không phải chữ "Player".
> Trả lời: 

**OQ-player-12** — **Audio v1**: D-014 ghi "audio hoãn"; `cards.audio_ref` = NULL v1 (TTS live-only, DT.7). Player v1 có phát audio (TTS live) hay chỉ hiển thị + auto-advance im lặng?
> Trả lời: 

**OQ-player-13** — **Back khi đang phát**: có confirm không? Back khi speed-control mở: đóng overlay trước hay pop player?
> Trả lời: 

**OQ-player-14** — **Menu Play khả dụng**: mục "Player" có luôn hiện cả khi node 0 thẻ (→ empty) hay ẩn khi rỗng?
> Trả lời: 

**OQ-player-15** — **Player khả dụng tại node cha rỗng thẻ trực tiếp nhưng cây con có thẻ (D-009/BR-6)** — xác nhận gộp đệ quy áp cho Player (spec study-flow BR-6 áp "học/ôn"; Player là luyện tập — có gộp cây con không?).
> Trả lời: 

**OQ-player-16** — **Chiều hiển thị card (D-011)**: D-011 chốt đảo chiều KO↔VI dùng **cùng một** `SrsState` (một chiều lịch), nhưng KHÔNG quy định mặt nào **hiển thị** trên khi phát. Player tôn trọng chiều hiển thị / hướng cặp-ngôn-ngữ của deck (đổi vế "trên") hay luôn raw term→nghĩa? (SC-PLAYER-15.)
> Trả lời: 

**OQ-player-17** — **Biến thể playpause (FAB vs `MxIconButton` primary) — KHÔNG CÓ NGUỒN**: DOM chỉ cho `bg:primary r:9999 shadow:8/18` `mx:?` (nhất quán với cả hai). KHÔNG tồn tại `tool/parity/intent-ledger.json` / `tool/parity/contracts/` (đã kiểm bằng `find`), và không có "UC-4/§5/PR #31" trong contract/spec/decision-table — các trích dẫn này **không xác minh được**. Cần kit định nghĩa biến thể + `/design-sync` (kit-first) TRƯỚC khi assert kiểu widget. (End-state Replay=`primary`/Close=`ghost` thì suy được từ DOM, KHÔNG thuộc câu hỏi này.)
> Trả lời: 

**OQ-player-18** — **Policy timer auto-advance vs tap thủ công (D-014)**: tap prev/next/pause có **reset/huỷ** chu kỳ timer hiện tại không? Kết quả khi timer bắn trùng thời điểm tap phải xác định (không nhảy 2 thẻ, không kẹt). (SC-PLAYER-95.)
> Trả lời: 


<a id="study-result"></a>
## `study-result` — 13 câu · [file](study-result.md)

**OQ-study-result-1** — **Đích + cơ chế điều hướng các nút** (`close`, `continue`, `library`, `later`, `review-wrong`, `finalize-later`): navigation-flow/D-029 chưa nhắc study-result → đóng về đâu (deck-detail/Library/Today)? `continue` = chạy lại phiên (D-029, chỉ DueReview) hay phiên mới? **Cơ chế push vs replace sang study-session** cho continue/review-wrong CHƯA có nguồn (D-029 chỉ nói "hiện học lại đúng mode", không nói study-result push study-session) — không assert như Then (xem SC-34). Back-stack sau khi mở phiên mới (back quay lại study-result hay bỏ qua)? `review-wrong` chạy lại đúng N thẻ sai (nguồn danh sách từ đâu) hay toàn phiên?
> Trả lời: 

**OQ-study-result-2** — **Ngưỡng many-wrong**: số/% thẻ sai để rơi vào state `many-wrong` là bao nhiêu? (không có trong D-xxx/business).
> Trả lời: 

**OQ-study-result-3** — **Điều kiện phân nhánh state (precedence)**: thứ tự ưu tiên khi vừa goal-met vừa many-wrong (hoặc goal-missed + many-wrong)? Một phiên rơi vào state nào khi nhiều điều kiện đúng? → SC-STUDYRESULT-46 là scenario đóng-vai-chốt (blocked-on-Q3): buộc chốt precedence trước khi viết test, chỉ assert bất biến mutual-exclusion.
> Trả lời: 

**OQ-study-result-4** — **Nguồn % correct & "N thẻ sai" cho newLearn**: schema chỉ nói `review_logs` ghi mỗi lần GradeCard của **DueReview**. NewLearn (5 chặng game) tính % đúng và đếm thẻ sai từ đâu? có ghi log không? 5b. **`review_logs` không có `session_id` → không truy được "log-per-session"**: cột của `review_logs` chỉ gồm `id, card_id, grade, reviewed_at` (schema-contract) — KHÔNG có khoá nối phiên. Vậy % correct/"N thẻ sai" **của một phiên** (stat-1 SC-15/63, phụ đề many-wrong SC-04) lấy từ đâu: (a) bộ đếm in-memory giữ trong phiên study-session rồi truyền qua result, hay (b) lọc `review_logs WHERE reviewed_at ∈ [session.started_at, finalize_at]`? Cách (b) rủi ro khi chạy nhiều deck/nhiều phiên chồng lấn thời gian. Chốt nguồn trước khi viết assertion "khớp log của phiên".
> Trả lời: 

**OQ-study-result-5** — **Đơn vị thời lượng — XUNG ĐỘT NGUỒN D-010 ↔ schema (chốt canonical trước khi test)**: D-010 (decision-table) nói `DailyActivity` cộng **GIÂY** + số từ; schema-contract nói `study_sessions.duration_minutes` / `daily_activity.minutes` là INTEGER **PHÚT**. Hai nguồn được trích mâu thuẫn về đơn vị lưu. Thêm nữa kit hiển thị "6:30" (phút:giây) trong khi cột là phút tròn. Cần chốt: (a) đơn vị canonical lưu DB = giây hay phút? (b) stat "min" hiển thị phút:giây hay phút tròn, nguồn giây lấy từ đâu nếu cột chỉ có phút? Mọi assertion "phút" trong file này (SC-16/60/61/92) tạm bám schema và ĐÁNH DẤU blocked-on-Q5.
> Trả lời: 

**OQ-study-result-6** — **Streak "+1 today" realtime**: goal-met hiện "+1" ngay tại result, nhưng engagement nói "chưa có job chốt-ngày — tính trực tiếp từ lịch sử" và reset ở **nửa đêm**. Streak hiển thị ở result là dự đoán realtime hay giá trị đã chốt? có nguy cơ lệch khi chưa qua nửa đêm?
> Trả lời: 

**OQ-study-result-7** — **"còn N phút/từ" (goal-missed)**: tính theo phút, theo từ, hay chỉ số gần đạt nhất?
> Trả lời: 

**OQ-study-result-8** — **Bản chất lỗi finalize**: local-first (ghi Drift) thì `finalize-error`/`cloud_off`/"cloud" ứng với lỗi thực nào (đĩa đầy? DB lock?)? Ghi có atomic không (partial write khi lỗi)?
> Trả lời: 

**OQ-study-result-9** — **Bấm close/back khi đang finalizing/retry**: huỷ (phiên không tính) hay chờ xong? Kill giữa chừng finalize → phiên có được tính không?
> Trả lời: 

**OQ-study-result-10** — **`finalize-later` ("Not now")**: bỏ qua finalize ⇒ phiên mất vĩnh viễn hay xếp hàng thử lại lần sau? có ghi phần nào không?
> Trả lời: 

**OQ-study-result-11** — **Chống ghi trùng khi Retry**: cơ chế idempotent (session id ổn định / upsert `daily_activity`)?
> Trả lời: 

**OQ-study-result-12** — **study-result có tái dùng cho luyện tập không**: theo BR-5 chỉ due/new finalize — cần xác nhận game/player có màn tổng kết khác (không phải screen này).
> Trả lời: 

**OQ-study-result-13** — **Phụ đề có chèn tên deck không** (cho i18n/CJK) hay chỉ số thẻ?
> Trả lời: 


<a id="search"></a>
## `search` — 14 câu · [file](search.md)

**OQ-search-1** — **Entry point + đích mở thẻ**: control nào mở `/search` (không thấy nút search trong DOM dashboard/library spec)? Chạm 1 card kết quả điều hướng tới đâu — `flashcardEditor` (`/deck/:id/card`), deck-detail cuộn tới thẻ, hay màn xem thẻ riêng?
> Trả lời: 

**OQ-search-2** — **Recent queries**: nguồn danh sách "RECENT" — schema-contract KHÔNG có bảng recent-queries; lưu ở đâu (settings? bảng mới?), có persist qua kill không, tối đa mấy mục, chạm hàng vs chạm nút north_west khác nhau thế nào, cách xoá 1 recent?
> Trả lời: 

**OQ-search-3** — **Phạm vi in-node (BR-3)**: `/search` route không có param `nodeId` — làm sao truyền phạm vi "trong nút đang mở" (D-009 subtree)?
> Trả lời: 

**OQ-search-4** — **Ánh xạ trạng thái↔badge/chip**: "New" = `srs_state.box=0` hay "chưa có row srs_state"? "Due" = `due_at<=now`? "Mastered" = `box=8`? Thẻ box 0 nhưng chưa có row có tính New không? (schema: box 0 = new/unscheduled).
> Trả lời: 

**OQ-search-5** — **Persist filter**: `settings.search.status_filter` có được áp lại khi mở màn sau/relaunch không? Nút clear/chip All có reset filter? "All" lưu giá trị gì (rỗng/null/'all')?
> Trả lời: 

**OQ-search-6** — **Copy no-results/empty**: nội dung ARB cho tiêu đề + phụ đề no-results (kit MOCK "No matches"/"Nothing matched …"), và có empty-recent copy khi 0 recent không?
> Trả lời: 

**OQ-search-7** — **Debounce / cancel / realtime**: gõ có debounce (mấy ms)? Query cũ có bị cancel khi gõ tiếp? "Due" có tự refresh theo `now`?
> Trả lời: 

**OQ-search-8** — **Giữ state khi pop-back**: search là màn push — quay lại (từ mở thẻ) có giữ query+filter+vị trí cuộn hay dựng lại empty-recent?
> Trả lời: 

**OQ-search-9** — **Validation query**: chỉ-khoảng-trắng → coi rỗng hay tìm rỗng? Có giới hạn độ dài query? (schema không nêu).
> Trả lời: 

**OQ-search-10** — **Data volume lớn**: có lazy-load/pagination cho kết quả không, hay tải hết (NFR chỉ nêu <200ms)?
> Trả lời: 

**OQ-search-11** — **State error**: contract search không có `error` — hiển thị gì khi đọc DB lỗi? Có retry (tự động/nút)?
> Trả lời: 

**OQ-search-12** — **Đếm kết quả**: FE có hiển thị "N kết quả" (cần ARB plural) hay không có counter?
> Trả lời: 

**OQ-search-13** — **Escape LIKE wildcard**: `%`/`_` trong query có được escape để khớp literal không? (rủi ro `%` khớp mọi thẻ) — cần khẳng định.
> Trả lời: 

**OQ-search-14** — **"Due" refresh theo `now`**: khi lọc "Due" đang mở mà thời gian trôi qua mốc `due_at`, danh sách có tự refresh realtime hay chỉ cập nhật khi re-query? (ngưỡng "Due" thuộc lịch SRS `srs-review.md` + D-028; **KHÔNG** liên quan D-021/streak.)
> Trả lời: 


<a id="statistics"></a>
## `statistics` — 23 câu · [file](statistics.md)

**OQ-statistics-1** — **Khối "dự báo đến hạn N ngày"**: business doc liệt kê "dự báo đến hạn 7 ngày" nhưng **DOM spec `loaded` KHÔNG render khối forecast** (chỉ streak/calendar/weekly/leitner/accuracy/overview). Kit thiếu hay doc thừa? → cần kit-first quyết trước khi test (đừng dựng khối không có trong kit).
> Trả lời: 

**OQ-statistics-2** — **Persist scope**: lựa chọn "This pair"/"All" có lưu vào `settings` (round-trip qua kill-relaunch) không? `settings` không có key scope thống kê.
> Trả lời: 

**OQ-statistics-3** — **Ngưỡng "đủ dữ liệu"** phân biệt `loaded` vs `insufficient`: số phiên/ngày/thẻ tối thiểu là bao nhiêu? (chưa có trong business/D-xxx).
> Trả lời: 

**OQ-statistics-4** — **Streak trên Stats theo scope?**: current/longest streak tính toàn app hay theo cặp? (`daily_activity` không có cột pair).
> Trả lời: 

**OQ-statistics-5** — **Bậc cường độ heatmap**: op {0.08…1.0} map theo minutes / words / max? ngưỡng mỗi bậc?
> Trả lời: 

**OQ-statistics-6** — **Định nghĩa "tuần" & nhãn thứ** trong "Time per week": 7 ngày gần nhất hay tuần lịch? bắt đầu thứ Hai/CN? nhãn theo locale nào?
> Trả lời: 

**OQ-statistics-7** — **Box 0 (new)** có được đếm/hiển thị đâu đó không, hay Leitner chỉ 1..8?
> Trả lời: 

**OQ-statistics-8** — **Accuracy cửa sổ & scope**: đúng 30 ngày? có lọc theo cặp (join card→deck→pair) không?
> Trả lời: 

**OQ-statistics-9** — **"total"** ở overview có gồm thẻ `hidden` không? (D-006 loại hidden khỏi count study).
> Trả lời: 

**OQ-statistics-10** — **"mastered"** = box 8 hay ngưỡng khác? phải khớp định nghĩa mastered của dashboard.
> Trả lời: 

**OQ-statistics-11** — **Entry drawer**: nav-flow nhắc "cùng route mở từ drawer" — drawer có thật ở build hiện tại?
> Trả lời: 

**OQ-statistics-12** — **Android back** tại tab gốc Stats: về Today hay thoát app?
> Trả lời: 

**OQ-statistics-13** — **Accuracy khi 0 log**: hiển thị 0% / "—" / ẩn khối? (chia 0).
> Trả lời: 

**OQ-statistics-14** — **State error**: statistics không có `error` trong kit — hiện gì khi đọc DB lỗi?
> Trả lời: 

**OQ-statistics-15** — **Cascade xoá deck vs `daily_activity`**: xoá deck cascade cards/srs/logs, nhưng `daily_activity` là roll-up theo ngày (không FK deck) — số cũ có bị sai/không đồng bộ không?
> Trả lời: 

**OQ-statistics-16** — **Nhãn đơn vị streak**: "current streak"/"longest" có kèm "day(s)" không (plural)?
> Trả lời: 

**OQ-statistics-17** — **Hit-area segmented**: kit minh:38 < 48 — Flutter có phải tăng lên ≥48 cho a11y không?
> Trả lời: 

**OQ-statistics-18** — **Nửa đêm realtime vs lazy**: Stats chốt ngày mới ngay hay chờ mở lại?
> Trả lời: 

**OQ-statistics-19** — **Reactive update**: Stats watch stream tự cập nhật khi dữ liệu đổi ở tab khác, hay chỉ đọc 1 lần?
> Trả lời: 

**OQ-statistics-20** — **XUNG ĐỘT NGUỒN heatmap 12-vs-14 tuần** (kit-first quyết): business doc `docs/business/statistics/statistics.md` §0 ghi "heatmap hoạt động **12 tuần**", nhưng DOM spec chốt **14** (caption "last 14 weeks" + grid 14 cột × 7 ô). Sửa business doc về 14 hay kit về 12? Cửa sổ heatmap + test đếm cột phụ thuộc câu trả lời (SC-STATISTICS-14/45). **Không lặng lẽ chọn 14.**
> Trả lời: 

**OQ-statistics-21** — **XUNG ĐỘT ĐƠN VỊ thời gian giây↔phút**: decision-table D-010 ghi "`DailyActivity` cộng **giây** + số từ", nhưng schema `daily_activity.minutes` ("Sum of the day's session minutes") + `study_sessions.duration_minutes` + caption kit "min / day" đều là **phút**. Nguồn chênh đơn vị (hệ số 60) → chốt: sửa D-010 về "phút", hay cột thực chất là giây? Ảnh hưởng weekly bar + roll-up assert (SC-STATISTICS-15/60). **Không im.**
> Trả lời: 

**OQ-statistics-22** — **Hàm biên ngày = midnight-UTC-của-ngày-local**: xác nhận domain có hàm chuyển `study_sessions.started_at`(µs UTC) → `daily_activity.day`(midnight-UTC-của-ngày-local, theo schema) — ở timezone ≠ UTC dễ lệch bucket nếu nhầm midnight-UTC-thuần ↔ midnight-local (SC-STATISTICS-91/94).
> Trả lời: 

**OQ-statistics-23** — **Leitner có loại `hidden` không?** (chưa có nguồn cho màn statistics): D-006/BR-8 chỉ loại hidden khỏi **due/new queue + due counts**; KHÔNG nói về **biểu đồ phân bố Leitner**; business/statistics doc im lặng. Cột Leitner đếm `srs_state.box` có trừ thẻ hidden hay không? → hỏi BA, đừng suy từ D-006 (SC-STATISTICS-16). (Khác Open-Q #7 chỉ hỏi box 0.)
> Trả lời: 


<a id="reminder"></a>
## `reminder` — 15 câu · [file](reminder.md)

**OQ-reminder-1** — **Quyền OS (BR-4)**: bật nhắc lần đầu có xin quyền notification? Khi bị từ chối / bị tối ưu pin — UI hiển thị gì (không có trong kit)? Có route "mở cài đặt hệ thống"?
> Trả lời: 

**OQ-reminder-2** — **Bước & phạm vi picker**: cột giờ 24h (0..23) hay 12h + AM/PM? cột phút bước 1 (0..59) hay bước 15 (00/15/30/45 như kit MOCK)?
> Trả lời: 

**OQ-reminder-3** — **Ngữ nghĩa bật/tắt switch**: bật thì set tập thứ mặc định nào (tất cả 7? tập trước đó?)? tắt có giữ `reminder.hour`/`minute`/tập thứ để bật lại không? (schema: rỗng weekdays = tắt.)
> Trả lời: 

**OQ-reminder-4** — **Chỉ số weekday**: quy ước index trong `reminder.weekdays` (0=Mon? ISO 1..7? 0=Sun?) + có chuẩn hoá thứ tự khi lưu không?
> Trả lời: 

**OQ-reminder-5** — **Đầu tuần**: thứ tự chip theo locale (Mon-first vs Sun-first) hay cố định?
> Trả lời: 

**OQ-reminder-6** — **on-nhưng-0-thứ**: bỏ hết thứ khi đang on → tự tắt switch, hay giữ on nhưng vô hiệu? (rỗng=tắt gợi ý tự tắt.)
> Trả lời: 

**OQ-reminder-7** — **Async surface + retry**: contract không có state `loading`/`error`. Trong lúc đọc settings hiển thị gì? Khi ghi settings lỗi surface lỗi kiểu gì (snackbar/inline) và ở đâu? **Có cơ chế retry không?** (s07 dòng 43 chỉ nói "localized surface + logged", KHÔNG nói retry — "cho retry" là suy diễn, phải chốt spec trước khi assert.)
> Trả lời: 

**OQ-reminder-8** — **Định dạng giờ**: theo định dạng OS (12/24h) hay luôn 24h trong app?
> Trả lời: 

**OQ-reminder-9** — **Plural**: có chuỗi phụ thuộc số nhiều nào không (kit không nêu)?
> Trả lời: 

**OQ-reminder-10** — **Timezone/DST**: đổi TZ/DST sau khi đặt giờ — lịch OS bắn theo giờ tường nào? (phụ thuộc #15: OS-schedule đã build hay chưa.)
> Trả lời: 

**OQ-reminder-11** — **Vùng mở picker**: chỉ icon `reminder/time-edit` mở picker, hay chạm cả vùng số giờ cũng mở?
> Trả lời: 

**OQ-reminder-12** — **Dismiss picker**: đóng bằng scrim/swipe/back = **huỷ không lưu** (chỉ "Done" mới áp) — xác nhận đúng mặc định; có nút Cancel riêng không?
> Trả lời: 

**OQ-reminder-13** — **Card giờ khi off**: disabled thật (không tap được) hay chỉ dimmed?
> Trả lời: 

**OQ-reminder-14** — **`mx:?` mapping**: back/switch/time-edit/chip/picker-done đều `mx:?` (kit chưa map component chuẩn) — chốt component `Mx*` khi build (không ảnh hưởng scenario, ghi nhận để parity).
> Trả lời: 

**OQ-reminder-15** — **⚠ NGUỒN NGHIỆP VỤ XUNG ĐỘT — OS notification đã build hay chưa?** `business/navigation/navigation-flow.md` (dòng 25) ghi route `reminder` = *"lên lịch OS hoặc … hoãn (gated)"* ⇒ hàm ý **chưa build / gated**. NHƯNG `business/settings/settings.md` (dòng 9) ghi Trạng thái = **Implemented** và mô tả *"nhắc học lên lịch thông báo OS qua `NotificationService` (flutter_local_notifications + timezone), 1 thông báo/ngày-trong-tuần đã chọn"* ⇒ **ĐÃ build**. Hai spec nghiệp vụ mâu thuẫn trực tiếp. Phải hỏi BA chốt: notification OS có nổ thật ở v1 hiện tại không? Trước khi chốt: mọi scenario chạm "OS bắn notification / OS re-schedule / OS xin quyền" chỉ assert **ghi settings đúng**, KHÔNG khẳng định OS behavior. (Chi phối SC-12/23/63/93/94 + banner phạm vi.)
> Trả lời: 


<a id="theme"></a>
## `theme` — 5 câu · [file](theme.md)

**OQ-theme-1** — **Accent: mapping 6 swatch DOM → 3 enum** (`theme.accent`∈{brand,warm,cool}). *Behavior đã rõ (G.08: single-accent, preview-only)* — điều **còn thiếu** chỉ là mapping từng swatch (indigo/violet/…) → giá trị lưu nào + nhãn tên-màu a11y, và 3 swatch "thừa" trong v1 là gì (disabled? placeholder cho khi kit thêm token?). Đây là gap **kit/thiết kế** (kit phải định nghĩa), KHÔNG phải "chờ BA chốt hành vi". Tới khi kit chốt: chỉ assert "1 row, value ∈ enum".
> Trả lời: 

**OQ-theme-2** — **Preview content**: term "학교"/gloss "school"/label "PREVIEW" là chuỗi demo cố định hay lấy từ dữ liệu thật? Nguồn ARB cho preview?
> Trả lời: 

**OQ-theme-3** — **Chip "Study now" trong preview**: trang trí hay có tap? Nếu tap thì đi đâu?
> Trả lời: 

**OQ-theme-4** — **Giữ scroll/state** khi rời & quay lại màn theme (màn push, không tab shell) — mở lại từ đầu hay giữ vị trí?
> Trả lời: 

**OQ-theme-5** — **Error-UI cho ghi thất bại** (chỉ phần sản phẩm còn thiếu, xem ghi chú trên): BR-3/§10 không định nghĩa **có hiển thị localized error + retry** cho người dùng hay không. Đường lỗi kỹ thuật đã có (Result/AsyncValue.error, không nuốt) — chỉ thiếu quyết định UX surface.
> Trả lời: 


<a id="import"></a>
## `import` — 17 câu · [file](import.md)

**OQ-import-1** — **Picker cột (map-term/map-meaning)**: kit chỉ có icon-button `expand_more`, KHÔNG có node overlay (menu/sheet/dialog) liệt kê danh sách cột. Hình dạng picker, danh sách cột nguồn, cách chọn — chưa định nghĩa trong kit. Cần kit-first bổ sung.
> Trả lời: 

**OQ-import-2** — **Tap card nguồn**: CSV/Excel mở file_picker ngay (lọc đuôi)? Paste text kích hoạt vùng `import/paste` hay field luôn hiện? Quan hệ card "Paste text" ↔ vùng paste chưa rõ.
> Trả lời: 

**OQ-import-3** — **Entry point từ deck-detail**: nút/menu-item nào mở Import (nằm ở spec deck-detail, ngoài màn này) — cần đối chiếu.
> Trả lời: 

**OQ-import-4** — **srs_state cho thẻ import** (PHẦN LỚN ĐÃ CÓ NGUỒN — xem SC-IMPORT-72): schema D-017 (line 155-156) nói NewLearn chưa học ⇒ **KHÔNG ghi hàng srs_state**; line 140 "Absent/box 0 = brand-new". Bất biến "không vào due-queue/due count" đúng cho cả hai cách và đã được assert. Chỉ còn cần chốt dứt điểm "no row" vs "box 0 row" cho assert chính xác.
> Trả lời: 

**OQ-import-5** — **N ở done/nút Import**: "Import N cards" và "Imported N cards" = tổng lô (gồm trùng) hay tổng-trừ-trùng? Giả định = tổng lô (soft-dup không loại).
> Trả lời: 

**OQ-import-6** — **Back / huỷ / resume**: back giữa mapping/preview có dialog "bỏ thay đổi?" không? Huỷ khi đang ghi = rollback atomic? App resume giữ bước hay reset?
> Trả lời: 

**OQ-import-7** — **Back vs go-deck ở done**: cả hai đều về deck-detail? Có khác đích không?
> Trả lời: 

**OQ-import-8** — **Deep-link `/deck/:id/import`**: cho phép deep-link trực tiếp? deckId không tồn tại/không hợp lệ ⇒ hành vi?
> Trả lời: 

**OQ-import-9** — **Lỗi & rỗng & N=0**: contract import KHÔNG có state `error`/`loading`/`empty`. Khi parse rỗng / N=0 / đọc-ghi lỗi: hiện gì (nút disable? snackbar? inline banner? dialog?)? Cần spec.
> Trả lời: 

**OQ-import-10** — ~~**Dòng thiếu meaning**~~ **ĐÃ GIẢI QUYẾT** (xem SC-IMPORT-42): flashcard-management **BR-2** (line 95, term + ≥1 nghĩa bắt buộc) + **AC-3** (line 107-108, thiếu term/nghĩa ⇒ **CHẶN + nêu rõ trường thiếu**). Dòng chỉ có term ⇒ chặn, không ghi thẻ. (Trước đây ghi nhầm nguồn là BR-3 = "nghĩa là ô văn bản tự do" — sai; đã sửa citation.) Chỉ còn hình thức lỗi (chặn cả lô vs bỏ dòng) thuộc Open questions #9.
> Trả lời: 

**OQ-import-11** — **Giới hạn độ dài** term/meaning khi import — có max không?
> Trả lời: 

**OQ-import-12** — **Trùng nội bộ trong lô**: 2 dòng cùng term trong cùng lô — đếm cả 2 / gộp / cảnh báo riêng? (D-020 chỉ nói trùng với thẻ đã có).
> Trả lời: 

**OQ-import-13** — **Preview hiển thị bao nhiêu hàng**: toàn bộ N hàng hay chỉ N hàng đầu (kit mẫu 5 hàng)?
> Trả lời: 

**OQ-import-14** — **Trạng thái khi đang parse/ghi**: không có state `loading` trong kit — hiển thị tiến trình thế nào cho file lớn/lô nghìn thẻ?
> Trả lời: 

**OQ-import-15** — ~~**`card_meanings.language`**~~ **ĐÃ GIẢI QUYẾT** (xem SC-IMPORT-71): nghĩa = "tiếng mẹ đẻ (bắt buộc)" (flashcard-management line 64) ⇒ `language` = `language_pairs.native_language` của cặp active (schema line 59-60, đúng 1 cặp active). Suy ra được từ nguồn — không lấy từ cột file, không hỏi BA.
> Trả lời: 

**OQ-import-16** — **Persist separator** (default + miền enum ĐÃ CÓ NGUỒN — xem SC-IMPORT-73): `settings.import.separator` = enum {tab,comma,semicolon} (schema line 255); default = `tab` (DOM chip Tab active mặc định) — đã assert. Chỉ còn mở: lưu **vĩnh viễn** (mặc định cho lần sau) hay chỉ trong phiên.
> Trả lời: 

**OQ-import-17** — **Hit-area picker cột**: nút `expand_more` kit 36x36 < 48 tối thiểu a11y — cần mở rộng vùng chạm.
> Trả lời: 


<a id="export"></a>
## `export` — 16 câu · [file](export.md)

**OQ-export-1** — **Mặc định & persist lựa chọn**: format/separator/scope/include-srs mặc định lấy từ đâu (hằng số hay `settings` `export.format`/`import.separator`/`export.include_srs`)? Lựa chọn có được **ghi `settings`** không, và ghi lúc **chọn** hay lúc **Export**? (schema có khoá; UI-flow chưa chốt) → ảnh hưởng SC-EXPORT-01/14/17/20/61/62.
> Trả lời: 

**OQ-export-2** — **Separator × format**: khi format = Excel hoặc Copy text, section SEPARATOR còn áp dụng không (separator là khái niệm CSV)? Chip có bị disable/ẩn khi không phải CSV? → SC-EXPORT-15/17.
> Trả lời: 

**OQ-export-3** — **Phạm vi thẻ xuất**: N (số thẻ) tính theo scope (This deck vs Incl. sub-decks đệ quy D-009) — đã rõ; nhưng **có gồm thẻ ẩn `hidden=1`** (D-006) không? D-006 chỉ nói loại khỏi hàng đợi/đếm due, export là sao lưu → cần rule minh thị. → SC-EXPORT-03/44/63.
> Trả lời: 

**OQ-export-4** — **Format = Copy text**: luồng ra sao — vẫn qua `exporting`→`done` với Share/Save, hay copy thẳng clipboard (không có file, Share/Save vô nghĩa)? → SC-EXPORT-16/23.
> Trả lời: 

**OQ-export-5** — **Back/huỷ khi `exporting`**: cho huỷ + pop, hay chặn back tới khi xong? Huỷ có để lại file rác không? (DOM exporting không có nút cancel, vẫn có back). → SC-EXPORT-02/33/53.
> Trả lời: 

**OQ-export-6** — **State `done` rời màn / Share / Save**: Share dùng OS share-sheet? Save đích ở đâu (Downloads/chọn thư mục)? Rời `done` chưa Save có nhắc gì? Có toast xác nhận (ARB)? → SC-EXPORT-23/24/34.
> Trả lời: 

**OQ-export-7** — **Không có field nhập**: xác nhận export **không** có input text tự do (chỉ chọn rời rạc) ⇒ DoE mục 4 = N/A hợp lệ. Nếu có (vd đặt tên file) thì cần bổ sung validation.
> Trả lời: 

**OQ-export-8** — **Include-SRS với thẻ box 0 / due NULL**: xuất box=0 + due rỗng thế nào (ô trống? "-"? bỏ)? → SC-EXPORT-20/63.
> Trả lời: 

**OQ-export-9** — **Entry point trong deck-detail**: nút/menu-item "Export" ở đâu (more menu? action bar?)? (thuộc màn deck-detail, không có trong DOM export). → SC-EXPORT-30.
> Trả lời: 

**OQ-export-10** — **Deep-link deckId sai/không tồn tại**: redirect / màn lỗi / empty? → SC-EXPORT-31.
> Trả lời: 

**OQ-export-11** — **Deck 0 thẻ**: nút Export disable, hay ra `done` "Exported 0 cards" / thông báo "không có gì để xuất"? → SC-EXPORT-40.
> Trả lời: 

**OQ-export-12** — **State lỗi export**: contract KHÔNG có state `error`. Khi encode/ghi lỗi hiện gì (về config + snackbar? dialog? state ẩn?) và cho retry ra sao? → SC-EXPORT-51.
> Trả lời: 

**OQ-export-13** — **Định dạng cột ngày `due_at`**: ISO-8601 UTC / epoch / theo locale? Cột nào (chỉ due, hay cả last_reviewed_at)? → SC-EXPORT-70.
> Trả lời: 

**OQ-export-14** — **Bố cục cột file**: cột nào xuất (term, meanings, box, due…)? Thẻ nhiều `card_meanings` biểu diễn thế nào (1 dòng/nghĩa? nối? nhiều cột)? Có header row không? → SC-EXPORT-63/70/74.
> Trả lời: 

**OQ-export-15** — **Đồng thời sửa thẻ khi màn mở**: export đọc snapshot lúc mở màn hay lúc bấm Export? → SC-EXPORT-93.
> Trả lời: 

**OQ-export-16** — **Kết quả đối chiếu citation BR/US/AC (audit 2026-07-08)** — file nghiệp vụ `business/import-export/import-export.md` **có tồn tại** và đã được đọc/đối chiếu trong lượt QA này. Kết luận: BR-3 (dòng 60), BR-4 (dòng 61), US-3 (dòng 37), AC-3 (dòng 69), §8 (dòng 74), §UC-2 luồng chính (dòng 49-52) **đều khớp** nội dung mà SC-EXPORT-18/20/23/43/72 quy chiếu. **Một sai lệch đã sửa**: SC-EXPORT-51 trước ghi "§UC-2 luồng ngoại lệ", nhưng luồng ngoại lệ "nhập/xuất thất bại → thông báo lỗi, không ghi gì" thực nằm ở **§UC-1 dòng 46-47** (UC-2 chỉ có luồng chính, không có luồng ngoại lệ) → đã đổi citation. Không còn citation nào cần re-verify.
> Trả lời: 


<a id="drawer"></a>
## `drawer` — 17 câu · [file](drawer.md)

**OQ-drawer-1** — **Contract thiếu state**: kit khai báo 3 state (open/add-language/remove-language) nhưng ARB có sẵn **error** (`drawerErrorTitle/Text`) và **empty** (`drawerRemoveEmptyTitle/Text`) + `actionRetry`. Cần thêm 2 state này vào kit contract, hay chúng là gap? (SC-DRAWER-50, 60, 61).
> Trả lời: 

**OQ-drawer-2** — **FAQ / Email us / Sync (alpha)** (`drawer/item-7..9`): **không** có khoá ARB (`drawerFaq`/`drawerEmail`/`drawerSync`), không route, không D-xxx. Đích khi tap là gì? Sync alpha = placeholder do D-027 hoãn? (SC-DRAWER-18..20).
> Trả lời: 

**OQ-drawer-3** — **Import / Export từ drawer**: route `deckImport`/`deckExport` cần `:id` (deck đích) — từ drawer chưa có deck context. Tap dẫn đâu? (SC-DRAWER-13, 14).
> Trả lời: 

**OQ-drawer-4** — **Language picker**: nguồn danh sách ngôn ngữ (cố định / nhập tự do)? cho phép giá trị rỗng không? (SC-DRAWER-26, 27, 43).
> Trả lời: 

**OQ-drawer-5** — **Add-language khởi tạo**: mở từ trạng thái rỗng (`drawerChooseLanguage`) hay điền sẵn cặp active? Sau khi thêm thành công quay về đâu? Cặp mới có tự `is_active`? (SC-DRAWER-02, 44).
> Trả lời: 

**OQ-drawer-6** — **Validation surface**: khi learning==native / rỗng (D-030) — nút `drawerAddPair` disabled hay báo lỗi inline? khoá ARB thông báo lỗi? (SC-DRAWER-40..43).
> Trả lời: 

**OQ-drawer-7** — **Trùng cặp**: thêm lại cặp "A → B" đã có — chặn / cảnh báo mềm / cho phép? (chưa có rule; D-020 chỉ cho thẻ) (SC-DRAWER-46).
> Trả lời: 

**OQ-drawer-8** — **Đổi cặp active**: drawer có cho switch cặp active không (kit chỉ Add/Remove)? xoá cặp active thì active chuyển sang đâu? xoá cặp cuối → không còn active? (SC-DRAWER-73, 74).
> Trả lời: 

**OQ-drawer-9** — **Nút Cancel dialog**: khoá ARB nào (không thấy `drawerCancel`)? (SC-DRAWER-25).
> Trả lời: 

**OQ-drawer-10** — **Đếm "N cards" ở remove-language**: khoá ARB đếm thẻ (chưa thấy `drawerPairCards`)? có gồm thẻ ẩn (D-006) không? (SC-DRAWER-53, 82).
> Trả lời: 

**OQ-drawer-11** — **Định dạng thời lượng header** "12:45": mm:ss hay hh:mm? nguồn `daily_activity.minutes` (phút) hiển thị sao? (SC-DRAWER-10).
> Trả lời: 

**OQ-drawer-12** — **Điều hướng vào/ra**: avatar hiện ở tab nào? scrim-tap + back cứng đóng drawer? back từ add/remove về drawel[open] hay màn nền? giữ vị trí cuộn list? (SC-DRAWER-21, 31, 33, 34, 35).
> Trả lời: 

**OQ-drawer-13** — **Nửa đêm**: header "Today's activity" chốt ngày realtime hay lazy khi mở lại? (SC-DRAWER-97).
> Trả lời: 

**OQ-drawer-14** — **Xoá cặp khi đang học cặp đó**: chặn hay để cascade? phiên kết thúc **sau** khi deck bị xoá thì write `study_sessions.deck_id` (FK→deck đã mất) fail hay nuốt? (SC-DRAWER-98).
> Trả lời: 

**OQ-drawer-15** — **Khoá ARB `drawerBackup` ("Backup", @desc "Drawer item: backup")**: đây là khoá **định dùng cho item-9** (DOM dán nhãn "Sync (alpha)" — vậy text kit lệch ARB, cần chốt "Backup" hay "Sync (alpha)") hay là **orphan key** cho một item drawer DOM chưa vẽ? Nếu là item-9 thì SC-DRAWER-18..20 phải sửa lại claim "items 7-9 zero ARB coverage". (Header note · SC-DRAWER-20).
> Trả lời: 

**OQ-drawer-16** — **Khoá ARB `drawerTitle` ("Menu", @desc "Title of the drawer menu")**: DOM `open` không có node tiêu đề (header là `drawerActivityLabel`) — `drawerTitle` là title a11y/route/AppBar (chưa có surface trong kit) hay orphan? Cần một scenario/assertion khi surface được chốt. (Header note).
> Trả lời: 

**OQ-drawer-17** — **Sheet language picker (`drawerLanguagePicker`)**: kit **chưa** vẽ nội dung sheet — nguồn danh sách ngôn ngữ, có ô search không, các state open/loading/empty/selected/dismiss ra sao? (SC-DRAWER-47..49; liên quan #4).
> Trả lời: 


<a id="study-session"></a>
## `study-session` — 21 câu · [file](study-session.md)

**OQ-study-session-1** — **stage3 số lựa chọn**: mock=3 hàng — N cố định 3 hay theo cấu hình? nguồn các "distractor" (nghĩa nhiễu)?
> Trả lời: 

**OQ-study-session-2** — **stage4 recall thiếu control tự chấm**: DOM spec stage4 chỉ có nút "Show"; game-modes yêu cầu "Đã quên/Nhớ được" sau khi lộ — thiếu 2 nút này trong kit ⇒ kit thiếu hay flow khác? (không đoán).
> Trả lời: 

**OQ-study-session-3** — **stage2/stage3/stage5 phản hồi SAI**: hình thức báo sai (đổi màu/rung/toast) không có trong spec.
> Trả lời: 

**OQ-study-session-4** — **`options` (more_horiz)**: menu chứa gì? (kết thúc phiên / báo lỗi thẻ / tắt âm?) — chưa có D-xxx/business.
> Trả lời: 

**OQ-study-session-5** — **`close`/back trong dueReview vs newLearn "sạch"**: có mở dialog exit không, hay thoát thẳng khi chưa chấm thẻ nào?
> Trả lời: 

**OQ-study-session-6** — **`hint` (Help)**: gợi ý lộ gì (1 ký tự / độ dài / term)?
> Trả lời: 

**OQ-study-session-7** — **Điền — mức "dung sai"**: bỏ dấu? case-insensitive? khoảng cách chỉnh sửa? — game-modes nói "chấp nhận dung sai" nhưng không định lượng.
> Trả lời: 

**OQ-study-session-8** — **Field rỗng → Check**: nút disabled hay coi là sai? (không có disabled-state trong spec).
> Trả lời: 

**OQ-study-session-9** — **State loading**: study-session không có state loading/empty trong contract — khi dựng hàng đợi chậm / 0 thẻ mới hiển thị gì?
> Trả lời: 

**OQ-study-session-10** — **Persist tiến độ phiên (resume)**: resume-error ngụ ý có lưu phiên dở, nhưng schema-contract KHÔNG có bảng session-progress. Cơ chế lưu/khôi phục là gì? Kill giữa phiên → resume hay mất?
> Trả lời: 

**OQ-study-session-11** — **Ô 8 "due"**: BR-5 nói box 8 `due_at`=NULL (rời lịch) ⇒ thẻ ô 8 không bao giờ due; vậy D-005 ("ô 8 chấm đúng giữ 8") kích hoạt qua lối nào trong study-session?
> Trả lời: 

**OQ-study-session-12** — **Hủy giữa chừng khi đang ghi**: close/back đúng lúc commit — chờ xong hay hủy? tránh `srs_state` dở.
> Trả lời: 

**OQ-study-session-13** — **Nửa đêm vắt phiên**: phiên bắt đầu 23:59 chốt sau 00:00 — gán trọn `daily_activity` cho ngày `started_at`?
> Trả lời: 

**OQ-study-session-14** — **study-result → "Tiếp tục" (D-029, nhánh sau-phiên)**: chạy lại đúng entry vừa chạy — chi tiết ở file scenario `study-result`. Nhánh **trong-phiên** của D-029 ("kết thúc một mode DueReview → mời học lại đúng mode") đã phủ ở SC-…-57 (câu hỏi mở còn lại: #16).
> Trả lời: 

**OQ-study-session-15** — **Đa phiên song song**: v1 có cho mở 2 phiên học đồng thời không? (ảnh hưởng SC-…-125).
> Trả lời: 

**OQ-study-session-16** — **DueReview chọn "mode vừa chạy" (D-029 trong-phiên · SC-…-57)**: khi DueReview tái dùng nhiều màn chặng, "học lại đúng hình thức vừa chạy" chọn mode nào và lặp ra sao? DOM spec không mock trạng thái "mời học lại".
> Trả lời: 

**OQ-study-session-17** — **stage5 chọn nghĩa/term khi thẻ nhiều nghĩa (SC-…-64)**: thẻ có >1 `card_meanings` — nghĩa nào làm prompt, term nào (biến thể) được chấp nhận khi Check? spec chỉ mock 1 nghĩa.
> Trả lời: 

**OQ-study-session-18** — **Đơn vị đếm hoạt động (D-010 vs schema · SC-…-94)**: bảng quyết định D-010 ghi cộng **giây**, nhưng schema-contract cột là **phút** (`duration_minutes`/`minutes`). Chốt đơn vị chuẩn trước khi viết test.
> Trả lời: 

**OQ-study-session-19** — **`due_at` khi chấm Sai (SC-…-33/92)**: BR-4 chỉ nói lùi 1 ô; không quy định `due_at`. now+interval(ô mới) là suy diễn — hay fail đặt `due_at`=now/ngày mai để ôn lại sớm?
> Trả lời: 

**OQ-study-session-20** — **Relearn giữ dạng chặng vừa sai hay luôn Multiple choice (SC-…-06)**: sai có thể ở chặng 2/3/4/5 nhưng kit chỉ mock relearn dạng Multiple choice — relearn dùng đúng dạng vừa sai hay luôn quy về choice?
> Trả lời: 

**OQ-study-session-21** — **Mô hình tiến trình per-card vs per-stage-batch (SC-…-23/24 và 01..05/71)**: DOM spec là các state độc lập, không có transition; study-flow liệt kê 5 chặng ở **cấp phiên**. Mỗi thẻ đi riêng qua 5 chặng, hay cả hàng đợi tiến theo từng chặng (batch)? Ảnh hưởng thời điểm graduate 1 thẻ (SC-…-31/90) vs chốt phiên.
> Trả lời: 


<a id="settings"></a>
## `settings` — 19 câu · [file](settings.md)

**OQ-settings-1** — **Entry point màn settings**: là **tab Profile** (DOM spec bottom-nav Profile active, app bar không có back) hay **push `/settings` từ drawer** (navigation-flow)? Hai nguồn mâu thuẫn (SC-SETTINGS-30/31/36).
> Trả lời: 

**OQ-settings-2** — **Nguồn Profile (tên/email/avatar)**: không có bảng user trong schema-contract, `settings` k-v không có key profile, `language_pairs` không giữ tên. Lấy từ đâu? Có màn edit không? (SC-SETTINGS-10/41).
> Trả lời: 

**OQ-settings-3** — **group-expanded = inline accordion hay push màn SRS con?** navigation-flow không có route `/settings/srs`; kit dựng như diff nội trang (SC-SETTINGS-02).
> Trả lời: 

**OQ-settings-4** — **Số ô Leitner (8) & Intervals (1·3·7·14·30·60·120)**: read-only (chốt cứng theo srs-review/schema) hay cho đổi? Nếu cho đổi thì picker/validation nào? (SC-SETTINGS-20/21).
> Trả lời: 

**OQ-settings-5** — **Switch "Due notifications" ghi vào key nào?** schema có `reminder.weekdays` (rỗng=off) nhưng không có key riêng cho toggle thông báo đến-hạn (SC-SETTINGS-22/61).
> Trả lời: 

**OQ-settings-6** — **Tile Cloud sync (`g-7`)** ở v1: **bỏ hẳn** hay **giữ trạng thái alpha/disabled**? Tránh trùng chức năng với `g-6` Backup/Restore (SC-SETTINGS-18).
> Trả lời: 

**OQ-settings-7** — **Word display (`g-1`)** và **Voice (`g-4`)**: business doc W12 ghi **HOÃN v1** — tile vẫn render? đích khi chạm? (SC-SETTINGS-12/15).
> Trả lời: 

**OQ-settings-8** — **Tập giá trị hợp lệ words/round**: kit mock 5/10/20; business chỉ nói mặc định 5. Danh sách đầy đủ + ngưỡng do đâu định nghĩa? (SC-SETTINGS-03/23).
> Trả lời: 

**OQ-settings-9** — **Default values thiếu trong schema**: `theme.mode`/`theme.accent`/`theme.font_scale`/`game.random`/`goal.minutes_target`/`goal.words_target` không ghi default (SC-SETTINGS-40).
> Trả lời: 

**OQ-settings-10** — **Backup "Auto"**: toggle tự-động-sao-lưu lưu ở đâu? `settings` k-v không có key backup (SC-SETTINGS-17).
> Trả lời: 

**OQ-settings-11** — **State loading/error cho settings**: contract chỉ 3 state (không loading/error). Hiện gì khi đang load / khi ghi lỗi? (SC-SETTINGS-50/51/53).
> Trả lời: 

**OQ-settings-12** — **Value-picker đóng**: chọn xong tự đóng ngay hay có nút xác nhận? Scrim/swipe-down có huỷ không? (SC-SETTINGS-23/24).
> Trả lời: 

**OQ-settings-13** — **Tap lại tab Profile đang active** + **Android back tại tab gốc** (SC-SETTINGS-25/36).
> Trả lời: 

**OQ-settings-14** — **maxWidth ở tablet** cho card settings (SC-SETTINGS-81).
> Trả lời: 

**OQ-settings-15** — **`new_cards_per_day` min/max**: D-018 mặc định 20 nhưng không có ngưỡng biên khi cho đổi (SC-SETTINGS-45).
> Trả lời: 

**OQ-settings-16** — **Reminders — mâu thuẫn business-vs-navigation về lịch OS**: business dòng 9 = Implemented (NotificationService lên lịch OS); navigation-flow dòng 25 = "lên lịch OS hoãn (gated)". Nguồn nào đúng cho phần **lên lịch OS**? (bản thân tính năng Reminders ĐÃ CÓ) (SC-SETTINGS-16).
> Trả lời: 

**OQ-settings-17** — **Phụ đề tile Theme gộp 3 chiều**: cỡ chữ (`theme.font_scale`) có hiển thị trong phụ đề tile (cùng mode+accent) hay chỉ trong màn con? kit mock chỉ hiện "Light · default accent" (mode+accent) (SC-SETTINGS-19).
> Trả lời: 

**OQ-settings-18** — **`new_cards_per_day` (D-018) không có UI đổi trong settings**: thiếu element trong kit → **kit-first** bổ sung hàng "New cards/day" vào group-expanded, hay mặc định 20 cố định read-only v1? (SC-SETTINGS-28).
> Trả lời: 

**OQ-settings-19** — **Giá trị đã lưu ngoài tập option kit** (vd `words_per_round=15` do import/backup/migration): picker đánh dấu mục nào? thêm option động? không option nào check? (SC-SETTINGS-46).
> Trả lời: 

