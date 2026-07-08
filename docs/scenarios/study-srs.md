# Kịch bản — Vòng học lõi & SRS (study · srs · engagement)

MẪU hoàn chỉnh cho phương pháp (xem [README](README.md)). Phủ D-001..D-011, D-015..D-018,
D-021. Assertion DB dùng bảng `srs_state` (box 0..8, `due_at` µs), `review_logs`,
`daily_activity` (theo `docs/database/schema-contract.md`). Khoảng cách ô 1..7 =
**1·3·7·14·30·60·120 ngày**; ô 0/8 → `due_at = NULL`.

Quy ước Given rút gọn: `card(new)` = `cards(hidden=0)` chưa có dòng `srs_state` (⇔ box 0).

---

### SC-STUDY-01 — Học thẻ mới, hoàn tất 5 chặng → vào ô 1
Nguồn: D-002 · kit: deck-detail[loaded], library[play-sheet], study-session[stage1-review…stage5-typing], study-result[standard] · BR: srs-review §xếp-lịch
Given:
  - DB: `decks`(1: "Korean Basics"), `cards`(1: term="사과", hidden=0), `srs_state`: (trống → new)
When:
  1. Library → chạm "Korean Basics" → `deck-detail[loaded]`
  2. Play → `library[play-sheet]` → "Học"
  3. Đi hết 5 chặng, chấm Đúng → `study-result[standard]`
Then:
  - UI: study-session lần lượt stage1-review → stage5-typing; kết thúc `study-result[standard]`
  - DB: `srs_state[card]` = { box: **1**, due_at: `now + 1 ngày` }; `review_logs` **+1** dòng
  - UI: về `deck-detail[loaded]`, thẻ rời nhóm `new`

### SC-STUDY-02 — Thoát giữa chừng khi học mới → vẫn là thẻ mới
Nguồn: D-017 · kit: study-session[…], study-session[exit] · BR: srs-review
Given: như SC-STUDY-01
When: vào "Học", tới chặng 3, chạm back → `study-session[exit]` → xác nhận thoát
Then:
  - UI: về `deck-detail[loaded]`
  - DB: **không** có dòng `srs_state` cho thẻ (vẫn box 0); `review_logs` **không đổi**

### SC-STUDY-03 — Ôn "Lặp lại", chấm Đúng → lên 1 ô, dời hạn
Nguồn: D-001, D-003 · kit: library[play-sheet], study-session[due-review], study-result[standard]
Given: DB: 1 thẻ, `srs_state`={ box: 2, due_at: `now − 1h` } (đến hạn) ; badge due=1
When: deck → Play → "Lặp lại" (chỉ hiện vì due>0) → chấm Đúng
Then:
  - UI: study-session[due-review] → study-result[standard]
  - DB: `srs_state[card]` = { box: **3**, due_at: `now + 7 ngày` } ; `review_logs` +1

### SC-STUDY-04 — Ôn "Lặp lại", chấm Sai → lùi 1 ô (sàn ô 1)
Nguồn: D-004 · kit: study-session[due-review, relearn]
Given: DB: 1 thẻ, `srs_state`={ box: 3, due_at đến hạn }
When: Play → "Lặp lại" → chấm Sai
Then:
  - UI: thẻ vào lại hàng đợi (relearn); phiên chỉ xong khi thẻ được chấm Đúng (D-015)
  - DB (sau khi phiên chốt): `srs_state[card].box` = **2** (k−1)
  - Biến thể: thẻ đang ở **box 1** chấm Sai ⇒ giữ **box 1** (sàn, không xuống 0)

### SC-STUDY-05 — Đúng ở ô 7 → lên ô 8 (đã thuộc), rời lịch
Nguồn: D-003 (biên) · kit: study-session[due-review], study-result[standard]
Given: DB: `srs_state`={ box: 7, due_at đến hạn }
When: "Lặp lại" → chấm Đúng
Then: DB: `srs_state[card]` = { box: **8**, due_at: **NULL** } (mastered, off-schedule)

### SC-STUDY-06 — Đúng ở ô 8 → giữ nguyên ô 8
Nguồn: D-005 · kit: study-session[due-review]
Given: DB: `srs_state`={ box: 8, due_at: NULL } (không nằm hàng đợi due)
When: (thẻ không đến hạn — kịch bản kiểm scheduler qua "Xem lại"/browse rồi chấm) chấm Đúng
Then: DB: `srs_state[card]` = { box: **8**, due_at: NULL } (không đổi)

### SC-STUDY-07 — "Lặp lại" chỉ xuất hiện khi due>0
Nguồn: D-001, D-016 · kit: library[play-sheet]
Given: DB: deck có thẻ nhưng **due=0** (mọi thẻ chưa đến hạn hoặc box 8)
When: Play → `library[play-sheet]`
Then: UI: sheet có Học / Xem lại / Trò chơi / Trình phát; **KHÔNG** có "Lặp lại"
  - Biến thể (due>0): mục "Lặp lại" hiện, nhãn số = badge due

### SC-STUDY-08 — Cap thẻ mới mỗi ngày (mặc định 20)
Nguồn: D-018 · kit: study-session[…] · BR: srs-review §cap
Given: DB: deck có 25 thẻ mới; Cài đặt `new_cards_per_day=20`
When: "Học"
Then:
  - UI: phiên học chỉ nạp **20** thẻ (hàng đợi = 20)
  - DB: sau khi hoàn tất, đúng **20** dòng `srs_state` box 1 được tạo trong ngày; 5 thẻ còn `new`
  - Biến thể: đặt `new_cards_per_day=5` ⇒ hàng đợi 5

### SC-STUDY-09 — Học tại bộ thẻ cha gộp đệ quy thẻ con
Nguồn: D-009 · kit: deck-detail[loaded]
Given: DB: "A"(cha) có 2 thẻ; con "A/B" có 3 thẻ (đều mới)
When: mở "A" → "Học"
Then: UI: hàng đợi = **5** thẻ (2 của A + 3 của A/B, đệ quy)

### SC-STUDY-10 — Thẻ ẩn bị loại khỏi hàng đợi & số đến hạn
Nguồn: D-006 · kit: deck-detail[loaded]
Given: DB: deck 3 thẻ đến hạn, 1 trong đó `hidden=1`
When: xem badge due trên deck; "Lặp lại"
Then:
  - UI: badge due = **2** (không tính thẻ ẩn)
  - DB/hàng đợi: phiên ôn chỉ gồm **2** thẻ

### SC-STUDY-11 — Chốt phiên DueReview/NewLearn cộng DailyActivity; mode khác không
Nguồn: D-010 · kit: study-result[standard], dashboard[loaded]
Given: DB: `daily_activity`(hôm nay: minutes=0, words=0)
When: hoàn tất một phiên NewLearn (n thẻ, m giây)
Then:
  - DB: `daily_activity`(hôm nay).words += n; .minutes += m/60
  - UI: dashboard[loaded] phản ánh hoạt động mới
  - Biến thể: chạy Game / Review / Player ⇒ `daily_activity` **không đổi** (D-007/D-013/D-014)

### SC-STUDY-12 — Chấm Sai ở bất kỳ mode → học lại; phiên xong khi mọi thẻ Đúng
Nguồn: D-015 · kit: study-session[…], study-result[standard]
Given: DB: phiên 2 thẻ mới
When: thẻ #1 chấm Sai (quay lại đuôi hàng đợi), sau đó chấm lại Đúng; thẻ #2 Đúng
Then: UI: phiên chỉ kết thúc `study-result` khi cả 2 thẻ cuối cùng đều Đúng

### SC-STUDY-13 — Streak +1 khi đạt mục tiêu; reset khi bỏ ngày
Nguồn: D-021 · kit: dashboard[loaded, goal-met, streak-reset] · BR: dashboard-engagement
Given: DB: streak hiện = 4; `daily_goal`(minutes=15 HOẶC words=20)
When: hôm nay học đạt ≥1 mục tiêu → chốt ngày (nửa đêm giờ máy)
Then:
  - DB: streak = **5**; UI: dashboard[goal-met]
  - Biến thể: ngày **không** đạt mục tiêu → chốt ngày ⇒ streak = **0**; UI: dashboard[streak-reset]

---

> **Chưa phủ ở file này** (để feature khác/mở rộng): D-011 (đảo chiều KO↔VI dùng chung
> `srs_state`), D-014 Player, các game (D-008/D-013), search (D-019/D-028), import/export
> (D-025/D-026), deck CRUD (D-023/D-024), glossary (D-030). Xem [coverage.md](coverage.md).
