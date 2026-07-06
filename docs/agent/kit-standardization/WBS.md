# Kit-Standardization WBS — chuẩn hóa toàn bộ design system

> **Mục tiêu.** Sau các đợt fix theo finding (G1 contrast, M3 wave 1–2), chuẩn hóa
> **cả bộ kit** thành một hệ nhất quán: (1) mọi giá trị đi qua token, (2) mọi
> pattern lặp thành component/class, (3) mỗi khái niệm chỉ có MỘT convention.
> Nguồn: 2 lượt inventory exhaustive 2026-07-06 (magic values + convention
> divergence) trên `components.css` + toàn bộ `ui_kits/memox-app`. Gộp luôn phần
> còn lại của M3 backlog (M3-3…6 — xem `docs/design/m3-compliance-audit.md`).
>
> Quy trình mỗi wave: **kit trước** → render-check gallery → `gen_tokens` →
> Flutter mirror → `tool/verify/run.mjs` full → design-sync → PR. Additive-only
> với token (names frozen).

---

## 0. Hiện trạng đo được (điểm chính từ inventory)

**Magic values (components.css):** 52 khai báo hardcode — 35+ cần token mới
(kích thước component: chip 34, switch 52/32/thumb, badge 20/10/6, avatar
32/44/64, icon-tile 48/60, icon-btn-sm 36, search-dock 52, nav-pill 56×30,
segmented 40), 7 chỗ nên dùng token CÓ SẴN (glyph 18/22/24 đúng; 20/24 đang
tham chiếu font-scale thay vì icon-scale), 10 transition hardcode
(0.12/0.14/0.16/0.18s + 1 cubic-bezier) trong khi motion tokens ĐÃ định nghĩa mà
không được tiêu thụ (M3-6). Icon glyph lệch scale: 26px (tile/fab/nav) và 32px
(tile-lg) nằm ngoài scale 18/22/28.

**Pattern lặp (JSX):** SectionLabel bị inline ~15 chỗ dù helper đã tồn tại;
stat-block (số to + nhãn nhỏ) lặp 5+ dù `Stat` helper tồn tại; hằng opacity
.45/.5/.55/.85/.9 rải rác không token.

**Convention divergence:** action-bar cuối flow có 3 kiểu (grid 1fr-1fr / cột
stacked / fragment dialog) trên 18 màn; progress có 4 kiểu (bar+n/N ở Review —
audit gốc chấm là chuẩn tốt nhất / %text ở study-session / bar trần ở games /
dots ở player); banner 3 hệ chồng nhau (Note / ActionCallout / DupBanner +
SyncBlock banner cục bộ); SubDeckCard nhân bản DeckRow. **Đã chuẩn sẵn**: empty
state (13 màn đều dùng EmptyState ✓), sheet/dialog (Scrim+Sheet/Dialog ✓),
list rows (DeckRow/StatusCardRow/ListRow ✓ trừ SubDeckCard).

---

## 1. Quyết định phải chốt trước khi code (Đ-K-1…4)

| Mã | Câu hỏi | **Quyết định (chốt 2026-07-06)** |
|---|---|---|
| Đ-K-1 | Glyph 26px (icon-tile/fab/nav) ngoài scale — hợp nhất lên 28 hay thêm token 26? | **HỢP NHẤT 28** (`icon-size-lg` có sẵn, +2px visual) + thêm `icon-size-xl: 32` |
| Đ-K-2 | Convention progress: bar + "n/N" mọi flow hay bar-trần trong games? | **BAR + "n/N"** mọi flow (chuẩn Review); player dots chỉ giữ cho autoplay |
| Đ-K-3 | Destructive: "Leave" & "Reset progress" = danger hay 3-tier warning? | **DANGER cả hai** (mất tiến độ phiên/SRS là mất dữ liệu thật) |
| Đ-K-4 | Phạm vi token hoá: full 46 hay curated ~25? | **FULL 46 TOKEN** — không còn bất kỳ px trần nào; K.6 whitelist chỉ còn cho trường hợp thật sự bất khả token |

---

## 2. Waves

> **Trạng thái (2026-07-06):** K.1 #218 · K.2 #219 · K.3 #220 · K.4a #221 ·
> K.4b #222 · K.5 #223 · K.6 (guard) — PR này. HOÀN THÀNH toàn bộ chương trình.

### K.1 — Token hoá kích thước + opacity *(1 PR)*
- [ ] `tokens/component.css` MỚI (Layer 1, curated theo Đ-K-4): chip-height,
      switch-w/h, badge-h/minw/px/dot, avatar-sm/md/lg, icon-tile-md/lg,
      icon-btn-sm, search-dock-height, nav-pill-w/h, segmented-seg-height.
- [ ] `tokens/icon-size.css`: xử lý 26/32 theo Đ-K-1.
- [ ] Opacity scale (vào typography.css hay file riêng — theo generator):
      disabled .45, muted .55, on-tint-soft .85, on-tint .9; thay mọi hằng inline.
- [ ] `gen_tokens.mjs`: hỗ trợ group mới → mirror `mx_component_sizes.dart`
      (hoặc nhập vào MxSizes); Flutter constants "raw px with no matching token"
      (MxChip._height, MxSearchDock.height, badge, segmented…) chuyển sang mirror.
- [ ] 7 tham chiếu sai → token đúng (glyph 20/24 → icon-scale sau Đ-K-1).
- **DoD:** components.css không còn số trần ngoài danh sách "legitimately raw"
  được comment; gate full xanh; props parity không đổi.

### K.2 — Motion wiring (M3-6) *(1 PR)*
- [ ] 10 transition → `var(--memox-duration-*)` + `var(--memox-ease-*)`
      (0.12/0.14/0.16→fast; 0.18→fast; bezier thumb→ease-standard). Nếu giữ
      160ms làm chuẩn riêng → đổi GIÁ TRỊ duration-fast thay vì thêm token.
- [ ] Flutter: audit chỗ dùng Duration hardcode trong `Mx*` → `MxMotion`.
- **DoD:** không còn duration/easing trần ở cả 2 phía; gen_tokens hết prune
  duration tokens.

### K.3 — Component hoá pattern lặp *(1 PR)*
- [ ] Kit: 15 chỗ label ALL-CAPS inline → `SectionLabel` (mở rộng props nếu cần:
      `uppercase`, `onPrimary` cho TODAY trên card tím); stat-block 5+ chỗ →
      `Stat` helper thống nhất.
- [ ] Flutter: widget shared `MxSectionLabel` + `MxStat` thay các `_Label`/figure
      cục bộ (deck-detail, drawer, export, search, settings, srs, reminder,
      theme, game-typing, review, dashboard TodaySummary/StreakCard).
- [ ] SubDeckCard (deck-detail) → dùng `DeckRow` (xoá bản nhân bản).
- **DoD:** grep pattern label/figure inline = 0 hit; props parity cập nhật.

### K.4 — Convention hợp nhất *(2 PR: 4a progress+action-bar, 4b banner+destructive)*
- [ ] **Progress (Đ-K-2):** helper `ProgressHeader` (bar 8px + "n/N") dùng cho
      study-session (thay %text), 4 games (thêm count), review giữ nguyên;
      player dots chỉ autoplay.
- [ ] **Action bar (G4):** chốt convention — flow đang chạy: grid 1fr-1fr
      (ghost trái + primary phải, 48px+); kết flow: cột stacked primary-trên;
      dialog: giữ Fragment theo ConfirmDialog; grade buttons của Recall nâng
      trọng số (primary cho "Got it"). Helper `ActionBar` trong kit-helpers +
      Flutter composite.
- [ ] **Banner 3-tier:** Note (transient) / ActionCallout (feature + 1 action) /
      local chỉ khi 2+ action (DupBanner); SyncBlock banner cục bộ → ActionCallout.
- [ ] **Destructive (Đ-K-3, M3-4):** "Leave" + "Reset" → danger; "Sign out" hạ
      tone (ghost danger + confirm); bảng risk-grid ghi vào README kit.
- **DoD:** bảng convention trong `_shared/README.md`; các state test/screen test
  cập nhật; mọi màn thuộc blast radius render đúng gallery.

### K.5 — Nits còn lại của M3 (M3-3, M3-5) *(1 PR)*
- [ ] FAB clearance: `.app__body--with-fab` pad-bottom ≈148 (nav80+FAB60+8?
      đo lại với nav mới 80) + `MxScaffold` fab-aware padding.
- [ ] Badge "✓" unicode → Material symbol `check` / soft "Done".
- [ ] G8 nits còn lại từ audit gốc (Stat icon token…).
- **DoD:** m3-compliance-audit.md cập nhật trạng thái M3-1…6 = ĐÓNG.

### K.6 — Khoá chống tái phát *(1 PR)*
- [ ] Guard/lint cho kit: script check components.css không có px/hex/duration
      trần ngoài whitelist comment `/* raw-ok: lý do */` — wire vào verify gate
      (như gen_tokens --check).
- [ ] Cập nhật `_adherence.oxlintrc.json` nếu còn dùng; ghi quy tắc vào AGENTS.md.
- **DoD:** thêm 1 px trần mới vào components.css → gate đỏ.

---

## 3. Thứ tự & ước lượng

K.1 → K.2 (rẻ, nền tảng) → K.3 → K.4a → K.4b → K.5 → K.6. Mỗi wave 1 PR, gate
full + design-sync. K.4 có blast radius lớn nhất (18+8 màn) — làm sau khi nền
token/component đã ổn định để diff sạch.

## 4. Ngoài phạm vi

- Visual-parity exporter (WBS riêng: `docs/agent/visual-parity/WBS.md`) — nhưng
  K.x làm xong sẽ khiến spec cũ stale THÊM; re-baseline dồn về VP.5.
- Đổi bố cục màn hình (layout redesign) — chương trình riêng đã bàn, chạy sau
  khi kit chuẩn hoá xong để không redesign trên nền lệch chuẩn.
