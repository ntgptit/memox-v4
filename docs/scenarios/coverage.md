# Coverage — đo mức "đầy đủ" của scenario

Cập nhật tay khi thêm scenario. "Đầy đủ" ⇔ mọi D-xxx (trừ REMOVED/HOÃN) có ≥1 scenario,
và mọi user-facing kit-state đến được qua ≥1 bước. Xem [README §Đầy đủ](README.md).

## 1. Decision-table D-xxx → scenario

| D-xxx | Hành vi | Scenario | Trạng thái |
|---|---|---|---|
| D-001 | "Lặp lại" ôn N thẻ due | SC-STUDY-03, -07 | ✅ |
| D-002 | new → ô 1 sau 5 chặng | SC-STUDY-01 | ✅ |
| D-003 | Đúng → ô k+1, dời hạn | SC-STUDY-03, -05 | ✅ |
| D-004 | Sai → ô k−1 (sàn 1) | SC-STUDY-04 | ✅ |
| D-005 | ô 8 Đúng → giữ 8 | SC-STUDY-06 | ✅ |
| D-006 | thẻ ẩn khỏi queue/đếm | SC-STUDY-10 | ✅ |
| D-007 | Game/Review/Player không đổi SRS | SC-STUDY-11 (biến thể) | ✅ |
| D-008 | game_words_per_round=5 | — | ⏳ games.md |
| D-009 | học tại cha gộp đệ quy | SC-STUDY-09 | ✅ |
| D-010 | DueReview/NewLearn cộng DailyActivity | SC-STUDY-11 | ✅ |
| D-011 | đảo chiều dùng chung srs_state | — | ⏳ study-srs.md (bổ sung) |
| D-012 | Premium | — | ⊘ HOÃN v1 |
| D-013 | picker 4 game, không đổi SRS | — | ⏳ games.md |
| D-014 | Player tự chạy, không đổi SRS | — | ⏳ player.md |
| D-015 | Sai → học lại; xong khi mọi thẻ Đúng | SC-STUDY-12, -04 | ✅ |
| D-016 | due=0 → không "Lặp lại" | SC-STUDY-07 | ✅ |
| D-017 | thoát NewLearn giữa chừng → vẫn new | SC-STUDY-02 | ✅ |
| D-018 | cap new_cards_per_day (20) | SC-STUDY-08 | ✅ |
| D-019 | search token AND, term+nghĩa | — | ⏳ search.md |
| D-020 | trùng term → cảnh báo mềm | — | ⏳ content.md |
| D-021 | streak +1/reset | SC-STUDY-13 | ✅ |
| D-022 | (folder removed) | — | ⊘ REMOVED |
| D-023 | sort deck (tên/ngày) | — | ⏳ content.md |
| D-024 | xoá deck lan cây con | — | ⏳ content.md |
| D-025 | import CSV/Excel/clipboard | — | ⏳ import-export.md |
| D-026 | export + kèm SRS | — | ⏳ import-export.md |
| D-027 | sync LWW snapshot | — | ⊘ HOÃN v1 |
| D-028 | search gồm thẻ ẩn + lọc trạng thái | — | ⏳ search.md |
| D-029 | DueReview "Tiếp tục" chạy lại đúng mode | — | ⏳ study-srs.md (bổ sung) |
| D-030 | tạo cặp source==target → ValidationFailure | — | ⏳ glossary.md |

**Tổng:** 14/30 đã phủ (study-srs.md) · 3 HOÃN/REMOVED (không cần) · **13 còn trống** →
cần thêm 6 feature file: `content`, `games`, `player`, `search`, `import-export`, `glossary`
(+ 2 dòng bổ sung vào study-srs: D-011, D-029).

## 2. Kit-state coverage (đến được qua bước scenario)

Điền dần theo từng feature file. study-srs.md đã chạm:
- `deck-detail`[loaded] · `library`[play-sheet] · `study-session`[stage1-review…stage5-typing,
  due-review, relearn, exit] · `study-result`[standard] · `dashboard`[loaded, goal-met, streak-reset]

Còn phải phủ (feature file tương ứng): các state của flashcard-editor, library (đủ), search,
import, export, statistics, settings, drawer, reminder, theme, 4 game, review, player,
study-result[goal-met/goal-missed/many-wrong/finalize-error/…]. Danh mục đầy đủ 117 state:
`MANIFEST.yaml` + `docs/contracts/`.

## 3. Ghi chú

- State thuần `loading`/`error` (mô phỏng lỗi hạ tầng) — phủ ở test tầng thấp, không bắt buộc
  có journey E2E riêng (README §Đầy đủ, mục 2).
- Mỗi khi thêm/đổi 1 dòng D-xxx (decision-table) → thêm scenario + cập nhật bảng này.
