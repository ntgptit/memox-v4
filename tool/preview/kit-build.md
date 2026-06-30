# MemoX UI-kit build loop

Prompt + quy ước + hàng đợi để **dựng toàn bộ màn của UI kit** (React, trong
`ui_kits/memox-app/`) từ các spec màn trong `docs/design/screens/`. Mỗi vòng lặp làm
**đúng 1 màn**, verify, rồi tick vào Hàng đợi bên dưới. Tự-chứa: một vòng lặp "nguội"
chỉ cần đọc file này + spec màn tương ứng.

## Kiến trúc thư mục (feature folders)

Mỗi màn là một **feature folder** dưới `_features/`; KHÔNG còn JSX màn ở top-level.

```
ui_kits/memox-app/
├── index.html                      # gallery + SCREENS registry + thẻ <script> nạp màn
├── kit-helpers.jsx                 # lớp helper/compat dùng chung (composite nhỏ)
├── _shared/                        # composite cấp app dùng bởi ≥2 màn (xem _shared/README.md)
│   └── README.md
├── _features/                      # 1 thư mục / màn (xem _features/README.md)
│   ├── dashboard/
│   │   ├── Dashboard.jsx           # screen ENTRY — index.html nạp, expose window.Dashboard
│   │   └── components/             # component cục bộ chỉ màn này dùng (tuỳ chọn)
│   ├── deck-detail/
│   │   └── DeckDetail.jsx
│   └── …                           # study-session/, library/, … (theo screen id)
├── specs/                          # SINH TỰ ĐỘNG — không sửa tay
└── shots/                          # SINH TỰ ĐỘNG — không sửa tay
```

Quy tắc đặt file:

- **Top-level `memox-app/` KHÔNG có JSX màn** — chỉ `index.html`, `kit-helpers.jsx`,
  và `specs/` + `shots/` (sinh tự động).
- **Screen entry** ở `_features/<screen>/<ScreenName>.jsx` (`<screen>` = screen id
  kebab trong `SCREENS`, vd `deck-detail`, `study-session`).
- **Component cục bộ của màn** ở `_features/<screen>/components/*.jsx` — chỉ màn đó dùng.
- **Composite cấp app** ở `_shared/*.jsx` **chỉ khi ≥2 màn dùng**; 1 màn dùng → để ở
  `components/` của màn đó.
- **Primitive design-system** (`Mx*`) ở `docs/design/MemoX Design System/components/`,
  KHÔNG đặt trong kit màn.
- **`specs/**` và `shots/**` sinh tự động** bởi `tool/ui_kit_shots` (`npm run export:all`)
  — không bao giờ sửa tay.

## Prompt để chạy loop

> Đọc `tool/preview/kit-build.md`. Trong **Hàng đợi**, chọn màn **pending** đầu tiên
> (ô `[ ]`). Đọc spec của nó trong `docs/design/screens/` rồi dựng/realign module kit
> theo **Quy ước**, đăng ký vào `index.html`, **verify** (server `memox-kit` cổng 4599,
> phải 0 lỗi console), rồi đổi ô đó thành `[x]` kèm prefix `data-mx-node`. Mỗi vòng đúng
> 1 màn. Khi không còn pending: chạy `node tool/doc_guard/run.mjs check` + `node
> tool/verify/run.mjs --docs`, commit, và báo cáo.

## Một vòng lặp làm gì (theo thứ tự)

1. Chọn màn pending đầu tiên trong Hàng đợi.
2. Đọc spec màn đó: `docs/design/screens/` (file `NN-*.md`) — lấy state + copy.
3. Tham chiếu pattern: `kit-helpers.jsx` (API helper) + 1 module đã có (vd `DeckDetail.jsx`).
4. Viết/realign `ui_kits/memox-app/_features/<screen>/<TênPascal>.jsx` theo **Quy ước**
   (tách chunk cục bộ vào `_features/<screen>/components/*.jsx` khi cần).
5. Đăng ký trong `index.html`: thêm một `<script type="text/babel" src="…">` cho **mỗi**
   `components/*.jsx` (nếu có), rồi cho screen entry
   `_features/<screen>/<Tên>.jsx` (sau `kit-helpers.jsx` / `_shared`, component trước
   entry) và một mục trong mảng `SCREENS`.
6. **Verify:** đảm bảo server `memox-kit` chạy (nếu chưa: preview_start "memox-kit"),
   rồi preview_screenshot + preview_console_logs(level error) → **0 lỗi**.
7. Tick ô màn đó `[x]` trong Hàng đợi (ghi prefix node đã dùng).
8. Dừng vòng (1 màn). Loop lặp lại.

## Quy ước (bắt buộc)

- **Module:** mỗi màn là `ui_kits/memox-app/_features/<screen>/<Tên>.jsx`, dạng IIFE:
  `(function(){ const NS = window.MemoXDesignSystem_2ffa54; const { Mx... } = NS; … window.<Tên> = <Tên>; })();`
  Component nhận prop `state` và nhánh theo state, trả `MxScaffold`.
- **Chỉ lắp từ** `Mx*` + helper `window.*` (xem dưới). KHÔNG markup card/button rời, KHÔNG
  đặt tên `Mx` mới.
- **Mọi node có nghĩa:** `data-mx-node="<screen>/<node>"` (kebab, ổn định, không tái dùng/xoá id).
- **Icon:** Material Symbols Rounded — `<span className="material-symbols-rounded">tên_icon</span>`.
  **KHÔNG emoji.**
- **Copy:** tiếng Việt (ngôn ngữ app); ví dụ "term" để tiếng Hàn (vd 안녕하세요).
- **Màu/spacing:** chỉ dùng token `var(--memox-*)`. Không hardcode hex ngoài helper.
- **Overlay (menu/dialog):** trả
  `<React.Fragment>{baseScaffold}<window.Scrim>…<window.Sheet/Dialog/></window.Scrim></React.Fragment>`.
  `Scrim align="center"` cho dialog, mặc định (end) cho bottom sheet.
- **`MxButton` KHÔNG có prop `style`** → cần lề thì bọc trong `<div style>`. `MxCard` thì CÓ `style`.
- **Tab screen** (library/dashboard/statistics/settings) có `bottomNav`; **màn push** (detail/
  editor/game/review/player/…) KHÔNG có bottomNav, dùng nút back ở `leading` của AppBar.

### API component
- `MxScaffold({ node, appBar, bottomNav, fab, flush, style, children })`
- `MxAppBar({ title, eyebrow, large, leading, trailing, node })`
- `MxCard({ variant: elevated|flat|muted|primary|primary-soft, interactive, padding: sm|md|lg, node, style, onClick })`
- `MxButton({ variant: primary|secondary|outline|ghost|contrast, size: sm|lg, icon, trailingIcon, block, danger, disabled, node })`
- `MxIconButton({ icon, variant: plain|filled|primary, size: sm, node })`
- `MxSearchDock({ placeholder, value, focused, trailing, node })`
- `MxChip({ label, icon, selected, variant: accent|ghost, node })`
- `MxFab({ icon, label, node })`
- `MxIconTile({ icon, tone, size: lg })`
- `MxBadge({ tone: success|warning|error|undefined, soft })`
- `MxSwitch({ checked, onChange, node })`
- `MxSegmentedControl({ value, onChange, block, segments: [{value,label}], node })`
- `MxAvatar({ name, size: sm|md|lg, ring })`
- `MxSectionHeader({ title, caption, action, node })`
- `MxBottomNav({ items: [{id,label,icon}], value, node })`
- `tone`: `accent` | `success` | `warning` | `error` | null

### Thứ tự nạp script trong `index.html`
1. React / vendor / `_ds_bundle.js` (base design-system).
2. `kit-helpers.jsx` (+ `_shared/*.jsx` nếu có) — helper/composite dùng chung.
3. `_features/<screen>/components/*.jsx` — component cục bộ của màn: **mỗi file một thẻ
   `<script type="text/babel">`**, theo thứ tự phụ thuộc, **trước** screen entry. Mỗi
   component expose qua namespace per-screen `window.MemoX<PascalScreen>.<Name>`
   (vd `dashboard` → `MemoXDashboard`, `study-session` → `MemoXStudySession`).
4. `_features/<screen>/<ScreenName>.jsx` — screen entry (destructure component từ
   `window.MemoX<PascalScreen>`).
5. Mảng `SCREENS` (registry). Mọi màn đang đăng ký phải còn nguyên; không xoá state,
   không đổi `data-mx-node` id.

### Helper `window.*` (trong `kit-helpers.jsx` — thêm composite mới nếu thực sự tái dùng)
- `ProgressBar({ value, tone, height, node })`
- `Skeleton({ w, h, r, style })`
- `EmptyState({ icon, tone, title, text, action, node })`
- `DeckRow({ icon, tone, name, meta, due, progress, node, onClick })`
- `ListRow({ icon, tone, title, sub, trailing, node, last, muted, onClick })`
- `Stat({ n, l, tone, node })`
- `Scrim({ children, align: end|center, node })`
- `Sheet({ title, children, node })`
- `MenuItem({ icon, label, tone, danger, trailing, node, onClick })`
- `Dialog({ icon, tone, title, text, actions, node })`
- `Note({ icon, text, tone: accent|success|warning|error })` — callout tint mềm (icon + text)
- `SectionLabel({ children })` — overline label nhỏ phía trên nhóm row/card
- `Ring({ pct, size, tone, inset, children })` — vòng tiến độ conic-gradient, punch-out giữa chứa children
- `ChoiceOption({ text, tone: correct|wrong, node })` — ô đáp án chọn (idle / đúng / sai)

## Verify

Server tĩnh `memox-kit` (`tool/preview/kit-server.mjs`, cổng 4599) phục vụ kit qua HTTP
(Babel không nạp được `.jsx` qua `file://`). Mỗi vòng: preview_screenshot +
preview_console_logs(error) phải **sạch lỗi**; verify mỗi màn bằng `preview_eval`: `fetch('_features/<screen>/<Tên>.jsx')` → `Babel.transform(src,{presets:['react']})` → `eval` → render mọi state qua `ReactDOM.render(React.createElement(window.<Tên>,{state}),div)` trong try/catch. Kết quả phải `OK … rendered=<đủ state>`, không `RENDER ERROR`/`LOAD ERROR`.

## Hàng đợi (state — tick khi xong)

Trạng thái: `[x]` xong · `[ ]` pending · `[~]` hoãn tới cuối · `(realign)` = màn cũ tiếng Anh cần viết lại sang
VI + nghiệp vụ MemoX.

- [x] `library/` — Library.jsx — spec 01 *(realign + bổ sung state tương tác)* — **pending realign** ⚠ đang là EN
- [x] `dashboard/` — Dashboard.jsx — spec 02 *(realign)* — state: loaded·empty·loading·goal-met·streak-reset
- [x] `folder-detail/` — FolderDetail.jsx — spec 03 — DONE
- [x] `deck-detail/` — DeckDetail.jsx — spec 04 — DONE
- [x] `flashcard-editor/` — FlashcardEditor.jsx — spec 05 — state: create·edit·validation·duplicate·multi-meaning·audio
- [x] `study-session/` — StudySession.jsx — spec 06 *(realign sang 5 chặng)* — state: stage1-review·stage2-matching·stage3-choice·stage4-recall·stage5-typing·relearn·due-review·exit·resume-error·answer-save-error
- [x] `game-picker/` — GamePicker.jsx — spec 07 — state: default·scope-dropdown·not-enough
- [x] `game-matching/` — GameMatching.jsx — spec 08 — state: playing·selected·correct·wrong·almost·complete
- [x] `game-mc/` — GameMultipleChoice.jsx — spec 09 — state: waiting·correct·wrong·complete
- [x] `game-recall/` — GameRecall.jsx — spec 10 — state: before-reveal·revealed·forgot·remembered·complete
- [x] `game-typing/` — GameTyping.jsx — spec 11 — state: waiting·typing·hint·correct·wrong·complete
- [x] `review/` — Review.jsx — spec 12 — state: browsing·editing·audio·end
- [x] `player/` — Player.jsx — spec 13 — state: playing·paused·speed·end
- [x] `study-result/` — StudyResult.jsx — spec 14 — state: standard·goal-met·goal-missed·many-wrong·finalizing·retry-finalize·finalize-error
- [x] `search/` — Search.jsx — spec 15 — state: empty-recent·results·filtered·no-results·loading
- [x] `statistics/` — Statistics.jsx — spec 16 — state: loading·loaded·insufficient·scope-switch
- [x] `settings/` — Settings.jsx — spec 17 *(realign)* — state: loaded·group-expanded·value-picker
- [x] `reminder/` — Reminder.jsx — spec 18 — state: on·off·time-picker
- [x] `account-sync/` — AccountSync.jsx — spec 19 — state: signed-out·signed-in·syncing·conflict·offline
- [x] `theme/` — Theme.jsx — spec 20 — state: light·dark·accent-size
- [x] `import/` — Import.jsx — spec 21 — state: source·mapping·preview·dup-warning·done
- [x] `export/` — Export.jsx — spec 22 — state: config·exporting·done
- [x] `drawer/` — Drawer.jsx — spec 23 — state: open·add-language·remove-language

## Hoàn tất (khi hết pending)

1. `node tool/doc_guard/run.mjs check` → 0 lỗi.
2. `node tool/verify/run.mjs --docs` → ghi pass-marker.
3. Commit (scope docs) + (tuỳ chọn) push kit lên Claude Design bằng
   `node tool/parity/sync-design.mjs` (workaround CLI design-logged-in).
