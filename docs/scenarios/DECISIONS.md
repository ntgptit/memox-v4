# Quyết định spec (chốt mặc định) — giải quyết Open-Questions

> **Uỷ quyền:** các hành vi kit/business chưa định nghĩa được **chốt mặc định** tại đây theo
> thứ tự ưu tiên **quyết định v1 → kit → convention Flutter/Material/UX**. Đây là spec để
> viết test. **Sẽ revise** khi có bug thực tế hoặc thay đổi requirement (yêu cầu sau).
> Thay cho việc để trống 329 ô trong [OPEN-QUESTIONS.md](OPEN-QUESTIONS.md).
> Ký hiệu: `DEC-G-n` = chính sách chung (áp mọi màn); `DEC-<screen>-n` = quyết riêng màn.

## A. Chính sách chung (áp cho MỌI màn — giải quyết phần lớn OQ)

- **DEC-G-1 · State lỗi (local-first):** đọc/ghi DB lỗi (`Failure`→`AsyncValue.error`) → **inline
  error box + nút "Thử lại"** (retry = `ref.invalidate(provider)`). Copy ARB nói *không
  tải/lưu được (dữ liệu cục bộ)* — **KHÔNG** dùng "kiểm tra kết nối" (v1 không remote). Màn
  không có state `error` trong kit vẫn dùng pattern này.
- **DEC-G-2 · Hai loại "rỗng" TÁCH RIÊNG:** (a) *chưa có nội dung nào* ở phạm vi → **onboarding/
  empty hero** theo kit; (b) *đã lọc/tìm nhưng 0 kết quả* → **no-results** ("không có kết quả" +
  gợi ý). Dù kit gộp 1 state, FE phân biệt 2.
- **DEC-G-3 · Search 0 kết quả:** query hợp lệ khớp 0 → hiện **no-results ngay tại màn đang
  search** (library search-active / deck-detail search / màn search), **không** giữ RECENT.
- **DEC-G-4 · Lịch sử tìm kiếm (recent):** lưu **cục bộ** — bảng mới `recent_searches(query, at,
  language_pair_id)`, giữ **10** query gần nhất/pair (⚠ schema-contract chưa có → thêm ở bước DT
  khi build). Trước khi có bảng: in-memory theo phiên.
- **DEC-G-5 · Escape LIKE:** search DAO escape `%`, `_`, `\` (dùng `ESCAPE '\'`); người dùng gõ
  các ký tự này = **literal**, không phải wildcard.
- **DEC-G-6 · Chống double-tap / tranh chấp:** mọi điều hướng + hành động ghi → **guard** (disable/
  debounce khi đang chạy); double-tap 1 item chỉ push/thực thi **một** lần; back khi đang load →
  huỷ điều hướng an toàn, không treo.
- **DEC-G-7 · Android back tại tab gốc:** ở tab khác Today → về **Today**; ở **Today** →
  **double-back-to-exit** (snackbar "Nhấn back lần nữa để thoát").
- **DEC-G-8 · Back trong stack push:** về màn trước, **giữ state + vị trí cuộn** (StatefulShellRoute
  giữ nhánh tab).
- **DEC-G-9 · Chốt ngày / nửa đêm:** **LAZY** — hoạt-động-hôm-nay + streak tính **trực tiếp từ
  `daily_activity`** khi render; không job realtime; qua nửa đêm mà đang mở màn → cập nhật ở lần
  rebuild/mở lại kế tiếp (engagement doc).
- **DEC-G-10 · CJK:** mọi text Hàn/Nhật/Hoa render đúng glyph (không tofu); test dùng font CJK sẵn có.
- **DEC-G-11 · Định dạng/i18n:** ngày/giờ/số theo **locale máy**; plural qua **ARB**; text dài →
  ellipsis (1 dòng) hoặc wrap (đa dòng), **không vỡ layout**; trim input.
- **DEC-G-12 · Dark mode:** mọi state đúng ở **light + dark** (token, không hardcode màu).
- **DEC-G-13 · Responsive:** 320px **không overflow**; tablet cap `maxContentWidth` + center; xoay
  ngang cuộn được; tôn trọng safe-area/notch.
- **DEC-G-14 · A11y:** mọi control có **semantic label**; **hit-area ≥48**; focus/đọc theo thứ tự
  trực quan; contrast đạt.
- **DEC-G-15 · Loading:** skeleton/shimmer ở **frame xác định** (pumpAndSettle bounded); không số thật.
- **DEC-G-16 · Xác nhận hành động phá huỷ:** xoá deck/thẻ/pair, reset progress → **confirm dialog**
  (kit): Cancel (ghost, trái) + hành động (danger, phải) **hàng ngang**; chỉ thực thi sau xác nhận.
- **DEC-G-17 · Section rỗng:** list nhiều nhóm (SUB-DECKS / CARDS…) → **ẩn header nhóm** khi nhóm rỗng.
- **DEC-G-18 · Chạm node deck & mở luồng học (chuẩn hoá toàn app):** chạm 1 node deck (library/
  dashboard/deck-detail) → **PUSH `deck-detail`** của node; các mode học (Học/Lặp lại/Game/Player/
  Xem lại) mở qua **play-sheet** từ một **nút/entry "Play" riêng** trên node; **long-press** node →
  menu ngữ cảnh (rename / move / delete).
- **DEC-G-19 · account-sync & liên quan (HOÃN v1):** Cloud sync → **Backup/Restore cục bộ**; FAQ/
  Email = link tĩnh (hoặc ẩn); "Sync alpha" **ẩn**; màn Account & Sync không build v1.
- **DEC-G-20 · Chọn nhiều (bulk):** v1 **cơ bản** — chọn nhiều để **xoá hàng loạt** (cascade D-024);
  **di chuyển hàng loạt = DEFER** (ẩn khỏi menu chọn-nhiều ở v1).
- **DEC-G-21 · Notifications:** chưa có màn trong kit/MANIFEST → **ẩn/defer** nút chuông ở v1
  (hoặc no-op "coming soon"); không build panel thông báo.
- **DEC-G-22 · Reset progress:** phạm vi **đệ quy cây con**; đưa thẻ về **box 0 (new)** + xoá
  `srs_state` của subtree; **giữ** `review_logs` (không xoá lịch sử).
- **DEC-G-23 · Avatar:** chạm avatar → mở **tab Profile** (settings).
- **DEC-G-24 · Escape/thoát search:** ngoài `search-clear` (xoá text), **system-back** thoát
  search-active về `loaded`; không cần nút X riêng.

## B. Quyết định theo màn (áp §A + phần riêng)

> Mỗi màn: các OQ đã được §A phủ ⇒ ghi "theo DEC-G-…"; phần riêng chốt bên dưới.

### dashboard — (đã điền chi tiết trong OPEN-QUESTIONS.md)
Greeting: buổi theo giờ máy (sáng 5–11 / chiều 12–17 / tối 18–4), tên từ hồ sơ (nguồn field
tên: **Profile/Settings**, ⚠ thêm field khi build) · Continue-decks: due>0 trước rồi last-studied,
tối đa **3** · Mastered %: box8 / visible theo pair · Goal ring: **max(phút, từ)** clamp 100% (BR-2)
· Review FAB: v1 comingSoon, đích D-001 · empty/error/back/midnight/notifications/avatar: DEC-G-2/1/7/9/21/23.

### library
Trigger play-sheet & chạm card: **DEC-G-18** (chạm→deck-detail; Play qua entry Play) · `create` FAB
→ **action-sheet** (Tạo deck / Thêm từ / Import) · recent: DEC-G-4 · render kết quả search + chip lọc:
**tại chính library search-active** (danh sách kết quả + hàng chip trạng thái mới/đến-hạn/đã-thuộc
render ngay dưới search-dock; đây là node FE thêm, kit thiếu) · zero-match: DEC-G-3 · `swap_horiz`
trên pair = **trang trí** (đảo chiều học là D-011 ở cấp thẻ, không ở đây) · of-select: DEC-G-20 ·
xoá deck: qua **long-press → menu** hoặc chọn-nhiều (DEC-G-18/20) · drawer items: DEC-G-19 · escape
LIKE: DEC-G-5 · back: DEC-G-7 · empty biến thể: DEC-G-2 (chưa có deck vs chưa có pair — tách).

### deck-detail
play-audio (volume_up) → **TTS đọc lần lượt term của thẻ hiển thị** (không mở Player) · chạm thẻ →
**card-actions** (bottom-sheet); mở editor qua action "Edit" trong sheet; long-press không dùng · sort
(swap_vert) → **mở picker** chọn tiêu chí (bảng chữ cái / ngày tạo / ngày học) + chiều (D-023) · reset
progress: DEC-G-22 · rename / new sub-deck → **dialog nhập tên** (validation theo DEC-G-…/§validation
màn editor) · unhide: card-actions của thẻ **đang ẩn** đổi "Hide"→"Unhide" · empty ẩn search-dock: có
(deck rỗng ẩn ô tìm) · section rỗng: DEC-G-17 · error copy: DEC-G-1 · deckId không tồn tại/bị xoá nơi
khác → **state error** (không pop) · card-actions cho sub-deck: sub-deck dùng **long-press→menu**
(rename/move/delete cấp sub-deck) · badge sub-deck: "N" = **số đến hạn**, "✓" = đã thuộc (progress=100).

### flashcard-editor
Validation (mỗi field): rỗng/chỉ-space → chặn lưu + lỗi inline; quá dài → giới hạn maxLength; CJK ok;
trùng term → **cảnh báo mềm** vẫn cho lưu (D-020); trim trước lưu · nhiều nghĩa: thêm/xoá dòng nghĩa,
≥1 nghĩa bắt buộc · audio: v1 **defer** ghi/ghi âm nếu chưa có (ẩn) · gender/tag chips: theo kit · huỷ
khi có thay đổi → confirm bỏ · lưu → ghi `cards`+`card_meanings`, về deck-detail.

### game-picker / game-matching / game-mc / game-recall / game-typing
Mọi game: **KHÔNG đổi `srs_state`** (D-007/D-013) · số thẻ/ván = `game_words_per_round` (mặc định 5,
D-008) · sai → **học lại trong ván**, ván xong khi mọi thẻ đúng (D-015) · chọn nguồn thẻ (scope) =
deck hiện tại/đệ quy · nội dung sai/đúng/hoàn thành theo state kit · thoát giữa ván → confirm, không
ghi SRS/activity (D-007) · timer/điểm (nếu kit có) = trang trí, không persist v1 · các OQ UI/format/
dark/responsive/a11y: DEC-G-10..15.

### review
Xem lại (browse) **KHÔNG đổi SRS** (D-007) · sửa nhanh thẻ trong review → mở editor/inline, ghi
`cards` · audio: DEC (defer nếu chưa build) · end → về deck-detail · các OQ chung: §A.

### player
Trình phát tự chạy: lần lượt term→nghĩa→audio, tự chuyển; **KHÔNG đổi SRS**, **KHÔNG cộng activity**
(D-014/D-010) · tốc độ/pause/next = điều khiển phát, không persist · audio chưa build → defer/ẩn · end
→ về deck-detail · các OQ chung: §A.

### study-result
Số liệu (words/min/streak) từ phiên vừa xong (đọc DB) · "Tiếp tục" chạy lại **đúng mode vừa chạy**
(D-029) · goal-met/goal-missed theo BR-2 · finalize-error → **retry** (DEC-G-1) · many-wrong = hiển
thị, không đổi luật · finalizing = loading (DEC-G-15).

### search
Khớp **term + nghĩa**, token AND, **gồm thẻ ẩn** + lọc trạng thái (mới/đến-hạn/đã-thuộc) (D-019/D-028)
· zero-match/recent/escape: DEC-G-3/4/5 · chạm kết quả → mở thẻ/deck-detail · filtered theo chip.

### statistics
Heatmap = lịch nhiệt theo `daily_activity` · overview (total/mastered/due) từ stats · scope-switch =
cặp↔toàn app · insufficient = ít dữ liệu → thông báo · streak/weekly từ lịch sử (DEC-G-9) · công thức
% mastered: box8/visible · các OQ chung: §A.

### reminder
Đặt giờ nhắc + chọn ngày (chips) · on/off toggle → lưu `settings` · time-picker → lưu giờ · quyền
thông báo: xin quyền khi bật; từ chối → hướng dẫn mở cài đặt · nội dung nhắc theo ARB · lưu bền (DB/
settings) round-trip.

### theme
Chọn light/dark/system + accent (6) → **lưu `settings`**, áp ngay toàn app (DEC-G-12) · preview card
cập nhật · round-trip qua kill-relaunch.

### import
Nguồn CSV/Excel/clipboard + separator (tab/,/;) → preview map cột → áp **cảnh báo trùng** (D-020/D-025)
· lỗi parse → thông báo + cho sửa mapping · encoding/CJK ok · import → ghi `cards`+`meanings` vào deck
đích · huỷ giữa chừng → không ghi.

### export
Chọn định dạng (CSV/Excel/copy) + separator + **kèm/không SRS** (D-026) · export → sinh file/clipboard
· done state · lỗi ghi file → DEC-G-1 · phạm vi (deck/đệ quy/toàn app) chọn được.

### drawer
Quản lý cặp ngôn ngữ (thêm/xoá/chọn) · remove-language → confirm + **hiển thị số thẻ/pair** (tính từ
`decks.languagePairId` → cards; ⚠ feature đếm đang ở task riêng) · FAQ/Email/Sync: DEC-G-19 · Theme →
màn theme · thêm pair validation (source≠target, không rỗng → D-030).

### study-session
5 chặng (review→matching→choice→recall→typing) cho NewLearn; DueReview không UI riêng · Đúng/Sai theo
D-002..D-005/D-015/D-017 · thoát giữa chừng: NewLearn chưa xong 5 chặng → **giữ new/box 0** (D-017),
DueReview đã chấm → áp kết quả · resume-error/answer-save-error → **retry** (DEC-G-1) · exit → confirm
· cộng `daily_activity` (D-010) · các OQ chung: §A.

### settings
Nhóm cài đặt (mục tiêu ngày / thẻ mới-ngày / SRS / theme / backup / …) → lưu `settings`, áp ngay ·
value-picker → chọn số/tuỳ chọn · group-expanded = mở nhóm · Cloud sync → **Backup/Restore** (DEC-G-19)
· mục v1 khác kit → theo scope v1 · round-trip bền.

## C. Điều còn cần con người (ít, đánh dấu để hỏi sau khi build)

Các mục ⚠ trong DECISIONS ở trên là **giả định làm việc** (mình tự chốt), sẽ hỏi lại khi chạm thực tế:
- Nguồn **field tên người dùng** (Profile chưa có field) — cần khi làm greeting/avatar.
- Bảng **`recent_searches`** (schema chưa có) — thêm khi build tầng DB search.
- Feature **đếm thẻ/pair** ở drawer (đang là task riêng).
- **audio** (record/play) — defer nếu chưa có hạ tầng.

> Khi viết test: mỗi scenario có OQ → tra quyết định tương ứng (DEC-G-… hoặc DEC-<screen>-…) trong
> file này. Không còn "chờ duyệt": tất cả đã có phương án mặc định.
