# Sơ đồ luồng toàn hệ thống — MemoX V4

**Status:** Specified

Bản hợp nhất luồng runtime của toàn hệ thống, chia **5 vùng**. Là nguồn chân lý cho
"bức tranh lớn"; chi tiết từng phần nằm ở các spec được truy vết bên dưới.

## Sơ đồ

```mermaid
flowchart TD
  subgraph Z1["① Vào app & ngữ cảnh"]
    direction LR
    A1["Mở app"] --> A2["Chọn cặp ngôn ngữ (한국어 → Tiếng Việt)"] --> A3["Thư viện: cây Bộ thẻ (lồng nhau)"]
  end
  subgraph Z2["② Chọn 1 nút → bấm Play → menu"]
    P["▶ Play → menu hành động"]
    M1["Lặp lại (ôn đến hạn)"]
    M2["Học (thẻ mới · 5 chặng)"]
    M3["Xem lại (duyệt)"]
    M4["Một trò chơi (4 game)"]
    M5["Trình phát (auto-play)"]
  end
  subgraph Z3["③ Engine học"]
    SH["Hiện thẻ → tự chấm"]
    DQ{"Đúng?"}
    RL["Học lại → quay lại hàng đợi"]
    LB["8-box Leitner: Đúng +1 / Sai −1 (sàn 1)"]
    DA["DailyActivity ++"]
    PR["Luyện tập: KHÔNG đổi SRS · sai → học lại trong ván"]
  end
  subgraph Z4["④ Gắn kết"]
    G1["Hoạt động ngày"] --> G2["Mục tiêu + Streak (đạt ≥1: phút/từ)"] --> G3["Thống kê"]
  end
  subgraph Z5["⑤ Hệ thống nền"]
    BG["Cài đặt · Theme · Backup(cục bộ) ≠ Đồng bộ(Google Drive) · Nhập/Xuất · Premium(hoãn)"]
  end

  A3 --> P
  P --> M1 & M2 & M3 & M4 & M5
  M1 --> SH
  M2 --> SH
  SH --> DQ
  DQ -- "Sai" --> RL --> SH
  DQ -- "Đúng" --> LB --> DA
  M3 --> PR
  M4 --> PR
  M5 --> PR
  DA --> G1

  class M1,M2,SH,RL,LB,DA srs
  classDef srs stroke:#3b82f6,stroke-width:2px;
```

Viền xanh (`srs`) = nhánh **đổi lịch SRS** (Lặp lại + Học). Còn lại là luyện tập / nền.

## Đọc theo vùng

1. **Vào app & ngữ cảnh** — mọi nội dung thuộc một cặp ngôn ngữ; thư viện là cây
   Bộ thẻ (lồng nhau) → Thẻ. Dữ liệu: `LanguagePair → Deck (tự lồng) → Card → SrsState (8 ô)`.
2. **Hành động tại 1 nút** — bấm Play mở menu 5 mục; "Lặp lại" chỉ hiện khi có thẻ đến hạn.
3. **Engine học** — nhánh SRS (Lặp lại/Học): hiện thẻ → tự chấm → Đúng +1 ô / Sai −1 ô
   (8-box) → cộng hoạt động; **sai ở mọi mode → học lại đến hết**. NewLearn = chuỗi 5
   chặng, thẻ mới vào ô1 sau khi đủ 5 chặng. Nhánh luyện tập không đổi SRS.
4. **Gắn kết** — hoạt động ngày → mục tiêu + streak → thống kê.
5. **Hệ thống nền** — cài đặt, theme, backup (cục bộ) ≠ đồng bộ (Google), nhập/xuất; Premium hoãn v1.

## Truy vết (vùng → spec / decision rows)

| Vùng | Spec | Dòng quyết định |
| --- | --- | --- |
| ② menu · Lặp lại · Học · Trình phát | `docs/business/study/study-flow.md` | D-001, D-002, D-010, D-014, D-016, D-029 |
| ③ SRS 8-box · Đúng+1/Sai−1 · học-lại | `docs/business/srs/srs-review.md` | D-003, D-004, D-005, D-015, D-018 |
| ② 4 game (picker) | `docs/business/game/game-modes.md` | D-008, D-013 |
| ④ hoạt động · mục tiêu · streak | `docs/business/engagement/dashboard-engagement.md` | D-010, D-021 |
| ⑤ nền | `docs/business/{settings/settings,account-sync/account-sync,import-export/import-export,personalization/personalization}.md` | D-012, D-025, D-026, D-027 |
| Dữ liệu | `docs/database/schema-contract.md` | — |

## Related

- `docs/business/system/overview.md` — tổng quan & bảng trạng thái
- `docs/business/index.md` — danh sách tính năng
- `docs/decision-tables/core-decision-table.md` — D-001…D-029
