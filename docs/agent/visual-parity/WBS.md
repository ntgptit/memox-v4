# Visual-Parity WBS — exporter spec/shots **viết mới hoàn toàn** (`tool/ui_kit_shots/`)

> **Mục tiêu.** Dựng lại trục gate **thị giác** giữa kit và Flutter — mũi tên thứ hai
> trong sơ đồ 3-contract của retrospective (§2, [`kit-conversion-retrospective.md`](../../design/kit-conversion-retrospective.md)):
> API đã có `props_check` gác; **visual (layout/token/state render)** hiện KHÔNG có gì
> gác từ khi repo reset làm mất tool cũ. Tool mới xuất `shots/` (PNG chuẩn per
> screen × state × theme) + `specs/` (DOM spec máy đọc được) từ kit gallery, kèm
> freshness/completeness gate wired vào `tool/verify/run.mjs` + CI.
>
> **Tool cũ chỉ để THAM KHẢO, không restore.** Nguồn tham khảo:
> `git show f702ecb^:tool/ui_kit_shots/<file>` (export_shots.mjs, export_specs.mjs,
> check_specs_fresh.mjs, check_specs_complete.mjs, serve_kit.mjs, source_hash.mjs,
> spec-*.template.md). Lý do viết mới: xem §1.

---

## 0. Phạm vi & nguyên tắc

**Trong phạm vi.**
- Tool mới `tool/ui_kit_shots/` (Node): render kit headless → xuất shots + specs
  cho **22 màn × mọi state trong registry × light+dark**.
- Gate: source-hash freshness + completeness, wired vào verify gate + CI, có
  wiring-guard test (như `props_check_gate_test.dart`).
- Drift watch: báo màn nào lệch baseline sau mỗi lần kit đổi / design-sync pull.
- Baseline mới cho toàn bộ specs/shots (thay sạch outputs cũ đang stale).

**Ngoài phạm vi.**
- Props/API — đã có `props_check --strict` gác.
- Sửa UI kit hay Flutter (trừ khi drift watch phát hiện lệch thật → task riêng).
- So pixel Flutter↔kit hai đầu (VP.6 là stretch, cần quyết định riêng — xem D-VP-5).

**Nguyên tắc bất biến (kế thừa AGENTS.md + retrospective PHẦN D).**
1. **Kit là nguồn chân lý** — specs/shots là *ảnh chụp máy* của kit, không hand-edit.
2. **Deterministic trước hết**: chạy 2 lần trên cùng máy = byte-equal; baseline
   pixel chỉ sinh trên nền tảng chuẩn (CI); local dùng check cấu trúc.
3. **Parse nguồn trực tiếp** (CSS/JSX/registry) — không tin manifest trung gian
   (bẫy `_ds_manifest.json` đã trả học phí).
4. **Mọi lời hứa có gate + wiring-guard** — không có "tool tồn tại nhưng verify
   không gọi" lần nữa (đó chính là trạng thái hiện tại của freshness check cũ).
5. **No silent caps** — registry nói 6 state thì thiếu 1 shot là gate đỏ, không
   phải "xuất được bao nhiêu hay bấy nhiêu".
6. **STOP-on-drift** — drift phát hiện là chặn/lên task ngay, không ghi sổ để đó
   (bài học intent-ledger thành nghĩa địa).

---

## 1. Vì sao viết mới (khuyết tật đã biết của tool cũ — reference-only)

| # | Khuyết tật cũ | Hệ quả | Yêu cầu cho tool mới |
|---|---|---|---|
| 1 | Đo **light-only**, dark giả định "remap token là đủ" | Lỗi dark-only (contrast, shadow, token sai chiều) lọt | Render + chụp CẢ dark; spec ghi token map cho cả 2 theme, geometry đối chiếu light↔dark phải bằng nhau (lệch = bug kit) |
| 2 | Token-diff **bỏ sót render-state/content/format** (blind spots đã ghi nhận: date format, text content, populated vs empty) | "Gated" bị over-claim | Spec ghi cả text content (đánh dấu MOCK COPY) + format warning; state registry phải seed đủ POPULATED state |
| 3 | `#rrggbb` không map được token chỉ được *ghi chú*, không gate | Gap màu tồn đọng vô hạn | Bộ đếm gap per screen, baseline hoá; gate đỏ khi gap TĂNG (ratchet) |
| 4 | Freshness hash có nhưng verify gate **không còn wire** | Spec stale không ai biết (trạng thái hiện tại) | `check:fresh` chạy trong `run.mjs --docs` VÀ full; wiring-guard test |
| 5 | Xuất phụ thuộc **network + Chrome hệ thống + font online** | Không deterministic; golden đa nền tảng đỏ (bẫy đã ghi) | Playwright pinned Chromium; vendor React/Babel/fonts vào repo hoặc cache có hash; animations/caret off |
| 6 | Enumerate states bằng parse HTML tay | Dễ lệch với gallery thật | Kit expose registry máy-đọc (`window.__MX_SCREENS`), exporter đọc runtime — một nguồn duy nhất |
| 7 | Kit tách node / FE gộp node → states.json lệch | Tranh cãi derivation | Spec/states theo **kit derivation** (quy ước đã chốt); FE composition verify bằng widget test, không phải việc exporter |
| 8 | Ordered-diff state mong manh, đổi nhỏ nổ diff lớn | Review nhiễu | Diff keyed theo `data-mx-node` trước, vị trí sau; node vô danh mới rơi về document-order |

---

## 2. Contract đầu ra (chốt ở VP.0, đây là mặc định đề xuất)

```
tool/ui_kit_shots/
  README.md                 # contract + cách chạy + troubleshooting
  package.json              # deps pinned (playwright, …); scripts: export, export:shots,
                            # export:specs, check:fresh, check:complete, watch:drift, serve
  src/…                     # exporter mới (module hoá: serve / registry / walk / tokenmap /
                            # specfmt / shoot / hash / drift)
docs/design/MemoX Design System/ui_kits/memox-app/
  shots/<screen>--<state>--<theme>.png   # 390×780, đủ registry, INDEX.md
  specs/<screen>.md                      # DOM spec v2 (schema dưới) + .source-hash
```

**Spec v2 giữ những gì đã chứng minh giá trị ở format cũ** (reading guide đầu
`specs/*.md`): box `abs/rel`, layout `flex/grid gap align`, `pad/margin`,
`minw/maxw`, `pos/scroll/z`, token-name thay hex, `mx:` identity theo
`data-mx-node`, `repeat:xN`, cảnh báo MOCK COPY, non-base state = diff. **Thêm
mới**: token map 2 theme, gap-ratchet count, diff keyed theo node id, font/format
warning, hash + tool version stamp.

---

## 3. Phases (foundation tuần tự VP.0→VP.4, mỗi phase = 1 PR; VP.5 theo batch)

### VP.0 — Khảo cổ & chốt contract *(không code exporter)*
- [ ] Đọc tool cũ từ git (reference-only), trích: cách serve, cách walk DOM, format
      spec, hash — ghi `docs/agent/visual-parity/reference-notes.md` (những gì GIỮ /
      BỎ / SỬA, đối chiếu bảng §1).
- [ ] Chốt các quyết định (ghi vào README tool + bảng D-VP dưới):
      **D-VP-1** runtime = Node + Playwright (pinned Chromium).
      **D-VP-2** dark được ĐO thật (không giả định remap).
      **D-VP-3** pixel-baseline sinh trên CI-chuẩn (ubuntu); local = check cấu trúc + fresh.
      **D-VP-4** vendor hoá runtime deps của kit (react/babel/Material Symbols) để offline-deterministic — cách làm cụ thể (vendor vs cache-by-hash).
- [ ] Viết `tool/ui_kit_shots/README.md` (contract §2) — review xong mới sang VP.1.
- **DoD:** README + reference-notes merged; chưa có code.

### VP.1 — Harness render deterministic
- [ ] `serve`: static server cho `docs/design/` (port cố định, no network ra ngoài).
- [ ] Vendor hoá deps kit theo D-VP-4 (kit index.html vẫn chạy được ở chế độ dev cũ).
- [ ] Kit expose `window.__MX_SCREENS` (id/title/states) — SCREENS array trong
      `index.html` là nguồn duy nhất; exporter đọc registry lúc runtime.
- [ ] Page harness: load gallery, đợi fonts/babel xong (deterministic ready signal),
      API điều khiển: `render(screenId, state, theme)` — không click-mò UI.
- [ ] Tắt nguồn nhiễu: animations, caret, scrollbar, hover.
- **DoD:** script demo render dashboard/empty light+dark 2 lần → DOM digest y hệt;
  chạy được cả khi cắt mạng.

### VP.2 — `export:shots` v2
- [ ] Chụp 390×780 PNG per screen×state×theme từ registry; `INDEX.md` tự sinh.
- [ ] Determinism: same-machine byte-equal (test lặp 2 lần trong CI job).
- [ ] `.gitattributes`: PNG binary; mọi file sinh ra LF (bẫy CRLF).
- **DoD:** full export chạy < 5 phút; đủ `registry × 2` ảnh, không thiếu cái nào
  (checker đếm — no silent caps).

### VP.3 — `export:specs` v2 (DOM spec)
- [ ] Walker: node tree (giữ container), box abs/rel, layout/flex-child, pad/margin,
      constraints, pos/scroll/z/clip, transform.
- [ ] Token back-map: computed style → `--memox-*` (parse tokens CSS trực tiếp);
      hex không map được = GAP + đếm; opacity dạng `token@NN`.
- [ ] Typography (size/weight/line-height/tracking), radius, shadow→elevation.
- [ ] `mx:` identity từ `data-mx-node`; `repeat:xN` detection; MOCK COPY warning.
- [ ] Dark pass: token map dark + assert geometry dark ≡ light (lệch → lỗi xuất).
- [ ] Non-base state = diff keyed theo node id (§1.8), `...` cho run không đổi.
- [ ] Hash: `.source-hash` từ (tokens css + components.css + kit-helpers + _features
      jsx + index.html + tool version).
- **DoD:** spec dashboard đọc lại đối chiếu tay với gallery (spot-check 10 node);
  format tương thích reading-guide (agent cũ đọc được không cần học lại).

### VP.4 — Gates & wiring
- [ ] `check:fresh` — hash nguồn ↔ hash trong outputs; đỏ khi kit đổi mà chưa re-export.
- [ ] `check:complete` — registry × 2 theme đủ shot + spec; đếm GAP ratchet (§1.3).
- [ ] Wire vào `tool/verify/run.mjs`: `--docs` (fresh+complete) và full (thêm bước
      trước analyze); degrade có thông báo khi tool chưa cài (npm i chưa chạy).
- [ ] CI: job export trên ubuntu (D-VP-3) — regenerate + diff, đỏ khi lệch commit.
- [ ] Wiring-guard test Dart (như `props_check_gate_test.dart`): run.mjs có gọi,
      CI có job, README tồn tại.
- [ ] Tích hợp `tool/parity/after-sync.mjs`: trỏ sang lệnh mới (`export`,
      `check:fresh`, `watch:drift`).
- **DoD:** verify gate đỏ khi (a) sửa kit không re-export, (b) xoá 1 shot, (c) gỡ
  wiring — cả ba chứng minh bằng test.

### VP.5 — Re-baseline toàn bộ + drift watch
- [ ] `watch:drift`: diff specs/shots hiện tại vs baseline committed → report màn
      lệch (dùng sau design-sync pull). STOP-on-drift: mỗi màn lệch = 1 task.
- [ ] Regenerate sạch 22 màn (xoá outputs cũ stale — trong đó dashboard đã lệch từ
      các PR #207/#208/#210) — theo batch ~5 màn/PR để review được.
- [ ] Đối chiếu Flutter cho các màn đã build (S-phase đã xong): mỗi batch kèm 1 lượt
      soát widget theo spec mới (lệch → task con, không vá bừa trong batch).
- [ ] Cập nhật docs: retrospective A4 (pointer sang tool mới), AGENTS/CLAUDE nếu có
      đường dẫn cũ, memory dọn ở cuối.
- **DoD:** toàn bộ specs/shots tươi (gate xanh), drift watch chạy trong after-sync.

### VP.6 — *(stretch, cần D-VP-5)* Parity 2 đầu: đo Flutter thật
- Ý tưởng: widget test harness đọc spec v2, so `getRect` của node neo (map qua Key ↔
  `data-mx-node`) với `rel:` trong spec; pixel golden chỉ trên CI-chuẩn.
- KHÔNG bắt đầu trước khi VP.0–VP.5 xong và có quyết định D-VP-5 (giá trị vs chi phí
  duy trì mapping Key↔node).

---

## 4. Bảng quyết định

| ID | Quyết định | Trạng thái |
|---|---|---|
| D-VP-1 | Node + Playwright pinned Chromium | đề xuất — chốt ở VP.0 |
| D-VP-2 | Đo thật dark theme (geometry assert ≡ light, token map riêng) | đề xuất — chốt ở VP.0 |
| D-VP-3 | Pixel baseline sinh trên CI ubuntu; local = cấu trúc + fresh | đề xuất — chốt ở VP.0 |
| D-VP-4 | Vendor hoá react/babel/fonts cho offline-deterministic | mở — chốt ở VP.0 |
| D-VP-5 | Có làm VP.6 (đo Flutter thật) hay không | mở — chốt sau VP.5 |

## 5. Rủi ro

| Rủi ro | Né |
|---|---|
| Font render khác máy → shots đỏ chéo nền tảng | D-VP-3: baseline chỉ từ CI; local không diff pixel |
| Kit gallery đổi cấu trúc DOM chrome (mxg-row…) làm walker gãy | Walker chỉ walk TRONG frame 390×780 (`[data-theme]` root), không đụng chrome gallery |
| Export chậm (22 màn × ~10 state × 2 theme) | Reuse 1 page, đổi props qua API render() thay vì reload; đo ở VP.2 DoD |
| CRLF Windows phá hash/byte-equal | `.gitattributes` LF cho outputs text; hash chuẩn hoá EOL |
| Tool mới lặp lại bug cũ | Bảng §1 là checklist review của từng phase |
