# Kit → Flutter conversion prompt — **library**

> SELF-CONTAINED. Đọc hết file này rồi thực thi tuần tự. Không cần đọc file prompt nào khác.
> Nhiệm vụ: đóng **state-composition parity gate** cho màn `library` (KHÔNG vẽ lại UI —
> UI đã có sẵn; việc ở đây là **curate contract + viết 1 test composition** theo Template B).

---

## PROMPT ID

`kit-to-flutter/library` · screen `library` · feature `deck` · 10 kit states.
FE: `lib/presentation/features/deck/screens/library_screen.dart`.

---

## Baseline

```bash
git checkout main
git pull --ff-only
git checkout -b claude/kit-to-flutter-library
```

Không bắt đầu khi working tree bẩn. Xác nhận `node tool/verify/run.mjs --quick` xanh trước khi sửa.

---

## Required reading (đọc trước khi code)

Universal (theo `CLAUDE.md`): `docs/_generated/repo-map.md`, `docs/_generated/where-is.md`,
`docs/business/index.md`, `docs/business/glossary.md`, `docs/contracts/error-contract.md`,
`docs/contracts/types-catalog.md`, `docs/contracts/code-style.md`.

Screen-specific — CHỈ đọc đúng các file này:
- `docs/design/MemoX Design System/ui_kits/memox-app/specs/library.md` — token-resolved DOM, 10 state (base `loaded` + 9 diff).
- `tool/parity/contracts/library.gen.json` — 10 keyed node (key/component/variant). **Đã xác minh: 0 MxCard.**
- `tool/parity/contracts/library.slots.skeleton.json` — slot skeleton (chỉ dùng nếu có keyed text; xem dưới).
- `tool/parity/contracts/library.states.skeleton.json` — per-state node membership (SUPERSET, phải trim).
- FE: `lib/presentation/features/deck/screens/library_screen.dart`.
- Test hiện có (dùng làm khuôn seed/pump): `test/presentation/features/deck/library_screen_test.dart`.
- **Reference test cần COPY (Template B):** `test/presentation/features/engagement/dashboard_states_test.dart`.
- Curated mẫu để bắt chước format: `tool/parity/contracts/dashboard.states.json`, `dashboard.slots.json`.
- Contrast (KHÔNG áp dụng ở đây, chỉ để hiểu vì sao loại): `test/presentation/features/study/review_parity_test.dart` (Template A, MxCard-rich).

---

## CHOSEN template: **B — state-composition** (KHÔNG phải Template A)

**Vì sao B:** `library.gen.json` có **0 node `MxCard`**. 10 node của nó là
`MxScaffold` (`library/screen`), `MxAppBar` (`library/appbar`), `MxFab` (`library/create`),
`MxIconButton` (`library/search-btn`, `library/sort-btn`, `library/overflow`),
`MxButton` (`library/empty-deck` primary, `library/empty-add` ghost, `library/retry` primary),
`MxSearchDock` (`library/search-dock`). Các **deck card** trong kit là node động
`library/node-0..4` — trong FE chúng render qua `MxDeckTile` với key ĐỘNG
`Key('deckTile-${node.deck.id}')`, **KHÔNG** phải literal `mx-node:library/node-N`.

→ Không có slot MxCard cố định để gate kiểu review. Đúng khuôn là **assert tập keyed node
render CHÍNH XÁC theo từng state** (thừa = THỪA, thiếu = THIẾU) — y hệt `dashboard_states_test.dart`.

---

## Gate-able node list (keyed trong FE — đã xác minh bằng grep)

Grep `mx-node:library/` trong `lib/` cho ra ĐÚNG tập literal keyed sau:

| key | component | render trong state |
| --- | --- | --- |
| `mx-node:library/screen` | Scaffold/Column gốc | mọi state (chrome) |
| `mx-node:library/appbar` | toolbar Row | mọi state (chrome) |
| `mx-node:library/search-btn` | MxIconButton | `loaded` (data non-empty) |
| `mx-node:library/sort-btn` | MxIconButton | `loaded` (data non-empty) |
| `mx-node:library/create` | MxButton ghost (trong toolbar) | `loaded` (data non-empty) |
| `mx-node:library/empty-deck` | MxButton primary | `empty` |
| `mx-node:library/retry` | MxButton primary | `error` |

> LƯU Ý QUAN TRỌNG về sự thật FE (khác gen.json/kit): trong FE hiện tại `search-btn`,
> `sort-btn`, `create` nằm trong toolbar và **render ở mọi nhánh** (`loading/error/empty/data`)
> vì `_toolbar()` luôn được vẽ, chỉ phần `Expanded` mới đổi theo `asyncNodes.when`.
> Kit lại đặt search/sort/pair trong `library/context` (body) → CHỈ có ở state có data.
> Đây là **divergence** — ghi vào intent-ledger, ĐỪNG tự ý sửa UI trong prompt này.
> Test composition phải phản ánh HÀNH VI FE THỰC (xem state-map), không phải kit lý tưởng.

**Node trong gen.json nhưng KHÔNG keyed ở FE (identity-rollout gap):**
`mx-node:library/overflow`, `mx-node:library/search-dock`, `mx-node:library/empty-add`.
Xem mục "Identity-rollout note".

---

## Per-state node SET (curate cho `library.states.json`)

Từ `library.states.skeleton.json`, **trim** SUPERSET (bỏ chrome không do body điều khiển,
bỏ overlay/node chưa keyed trong FE) xuống tập BODY do state điều khiển mà FE THỰC render.
`screen` + `appbar` là chrome — theo mẫu dashboard, **loại khỏi tập gate** (không state-driven).

Chỉ 3 state có node-set **kiểm chứng được ổn định** trong FE hiện tại (`loaded/empty/error`).
Tập gate đề xuất (chỉ gồm node keyed FE, đã bỏ chrome `screen`/`appbar`):

```jsonc
{
  "loaded": ["mx-node:library/search-btn", "mx-node:library/sort-btn", "mx-node:library/create"],
  "empty":  ["mx-node:library/search-btn", "mx-node:library/sort-btn", "mx-node:library/create", "mx-node:library/empty-deck"],
  "error":  ["mx-node:library/search-btn", "mx-node:library/sort-btn", "mx-node:library/create", "mx-node:library/retry"]
}
```

> Vì toolbar luôn hiện, `search-btn/sort-btn/create` xuất hiện trong CẢ 3 tập →
> chúng KHÔNG phân biệt state. Node **thực sự phân biệt** chỉ là `empty-deck` (chỉ `empty`)
> và `retry` (chỉ `error`). Universe = hợp của 3 tập; assert `empty-deck` absent ở `loaded`/`error`
> và `retry` absent ở `loaded`/`empty` — ĐÓ là chỗ gate bắt được THỪA. Giữ `loading` NGOÀI gate
> (nội dung là skeleton `MxStateView.loading`, không có keyed body node phân biệt) — coverage gap.

**Không có `library.slots.json`:** các keyed node ở đây là control (button/icon-button),
không mang keyed text slot cần bind role/l10n. Deck-card text (title/subtitle/badge) sống trong
`MxDeckTile` (key động) → không gate qua slots ở màn này. → **BỎ QUA** `library.slots.json`
(ghi rõ lý do trong report). Nếu muốn phủ text tile, đó là việc của prompt/parity khác (dynamic-key).

---

## State-map: state nào drive được / state nào là coverage gap

| kit state | drivable trong FE? | cách drive | ghi chú |
| --- | --- | --- | --- |
| `loaded` | ✅ | seed ≥1 root deck vào `db.deck` (xem `library_screen_test.dart`) rồi `pumpAndSettle` | data non-empty |
| `empty` | ✅ | pump với DB rỗng (chỉ có `languagePair`) | `_empty()` → `empty-deck` |
| `error` | ⚠️ | cần ép `libraryProvider` ném lỗi (override provider hoặc DB lỗi) | nếu không ép được sạch → coverage gap, ghi rõ |
| `loading` | ⚠️ | trạng thái async đầu, khó chốt ổn định; không có keyed body node | **coverage gap** (skeleton) |
| `search-active` | ❌ | search là route riêng (`context.push(RoutePaths.search)`), `search-dock` không ở màn này | **coverage gap** — overlay ngoài phạm vi FE screen |
| `pair-picker` | ❌ | không có pair control keyed trong FE library | **coverage gap** (identity chưa rollout) |
| `sort-menu` | ⚠️ | `sort-btn` mở `showModalBottomSheet` (ListTile, không keyed `sort-0..3`) | overlay không keyed → **coverage gap** cho node-set; chỉ nút mở là keyed |
| `overflow-menu` | ❌ | `library/overflow` chưa keyed/chưa có trong FE | **coverage gap** |
| `play-sheet` | ❌ | không có trong FE library (thuộc deck-detail flow) | **coverage gap** |
| `drawer` | ❌ | drawer là shell-owned (`drawer/*`), không thuộc màn library | **coverage gap** (shell) |

→ **Gate 3 state:** `loaded`, `empty`, `error`. **7 state là coverage gap** (search-active,
pair-picker, sort-menu, overflow-menu, play-sheet, drawer, loading) — ghi thẳng trong header test
(giống review_parity_test giải thích state không map) và trong intent-ledger.

> Nếu khi code phát hiện `error` KHÔNG ép được sạch bằng override DB/provider → hạ `error`
> xuống coverage gap, chỉ gate `loaded` + `empty` (2 state). Báo rõ trong report. ĐỪNG viết test
> giả (fake) chỉ để có `error`.

---

## Divergences → intent-ledger

Ghi các mục sau vào intent-ledger (`docs/parity/intent-ledger.md` hoặc file ledger dự án đang dùng;
nếu chưa có, tạo mục cho screen `library`). Mỗi mục: `screen · node · kit-nói-gì · FE-làm-gì · lý do giữ`.

1. **Toolbar controls luôn hiện** — kit đặt `search-btn/sort-btn/pair` trong `library/context`
   (body, chỉ khi có data); FE đặt trong toolbar (luôn hiện mọi state). → INTENDED (toolbar ổn định),
   test composition theo hành vi FE.
2. **Pair control thiếu** — kit có `library/pair` + `pair-sheet`; FE library chưa có bộ chọn ngôn ngữ
   ở màn này. → GAP (chưa rollout), không phải màn này giải quyết.
3. **Deck card dùng key động** — kit `library/node-0..4` (literal) vs FE `deckTile-<id>` (động).
   → INTENDED (danh sách động), không gate literal; xem identity-rollout note.
4. **Sort qua ListTile bottom-sheet** — FE dùng `showModalBottomSheet` + `ListTile` thay vì
   `sort-sheet`/`sort-0..3` keyed. → INTENDED cho v1 (không keyed overlay).
5. **`overflow` / `search-dock` / `empty-add`** trong gen.json nhưng không có ở FE. → GAP.

Nếu bất kỳ mục nào thực chất là **BUG** (không phải chủ ý) → **DỪNG**, báo theo mẫu DRIFT trong
`CLAUDE.md` và chờ người. Không tự sửa UI trong prompt này.

---

## Identity-rollout note (deck cards)

Deck card trong FE render qua `MxDeckTile` (`lib/presentation/shared/widgets/mx_deck_tile.dart`,
`key: Key('deckTile-${node.deck.id}')`). Vì key phụ thuộc id runtime nên **không thể** gate bằng
literal `mx-node:library/node-N` như kit.

Hai lựa chọn — ghi rõ lựa chọn đã chọn vào report:
- **(A) Chấp nhận gap** (khuyến nghị cho prompt này): tile là danh sách động, không thuộc tập
  keyed literal; parity phủ chúng qua test `library_screen_test.dart` (đã assert `deckTile-<id>` +
  text). Composition gate chỉ lo control/empty/error. → KHÔNG đổi UI.
- **(B) Thêm literal ValueKey ổn định** cho tile đầu tiên (vd `mx-node:library/node-0`) để có 1
  node body gate được ở `loaded`. Chỉ làm nếu muốn `loaded` có node phân biệt state; cần cập nhật
  `MxDeckTile` (widget dùng chung → cẩn trọng, đụng nhiều màn) + doc. Nếu chọn B, phải qua
  parity check + không phá test khác.

Mặc định **(A)**. Nếu chọn (B), coi là thay đổi widget dùng chung → cân nhắc rủi ro, ghi WBS.

---

## Workflow (thực thi tuần tự)

1. **Curate `tool/parity/contracts/library.states.json`** từ skeleton: chỉ 3 state
   `loaded/empty/error`, chỉ node keyed FE, bỏ chrome `screen`/`appbar`. Thêm `$curated` header
   mô tả (bắt chước `dashboard.states.json`) giải thích 7 state là coverage gap và lý do.
2. **`library.slots.json`: BỎ QUA** — ghi lý do (không có keyed text slot; tile text là key động).
   Không tạo file rỗng.
3. **Viết test composition** `test/presentation/features/deck/library_states_test.dart`:
   COPY cấu trúc `dashboard_states_test.dart` (đọc `library.states.json`, tính `universe`,
   `recipes` seed cho từng state, pump `LibraryScreen`, assert mỗi key trong universe:
   allowed → `findsOneWidget` (THIẾU nếu absent), ngoài allowed → `findsNothing` (THỪA nếu present)).
   Seed theo `library_screen_test.dart` (insert `languagePair` + `deck`). Header test giải thích
   rõ 7 state coverage gap (giống review_parity_test giải thích state không map).
4. **Xóa skeleton** đã tiêu thụ: `library.states.skeleton.json` và `library.slots.skeleton.json`
   (skeleton là AUTO-PROPOSED, không ship — theo ghi chú `$skeleton` trong file).
5. **Cập nhật queue**: đổi `[ ] 02-library.md` → `[x]` trong `docs/agent/kit-to-flutter/README.md`
   (file này chính là `library.md`; giữ nhất quán tên trong README).
6. **Doc parity**: nếu có divergence ảnh hưởng behavior đã ghi ở `docs/business/**` hoặc
   `docs/design/**`, cập nhật cùng commit (thường chỉ cần intent-ledger).

---

## Hard rules (vi phạm = fail — trích `CLAUDE.md`)

- KHÔNG vẽ lại/di chuyển UI trong prompt này; chỉ curate contract + viết test. Divergence → ledger, không tự sửa.
- KHÔNG hardcode route/màu/text-style/duration/string; string lấy từ ARB (`lib/l10n/`).
- KHÔNG copy MOCK COPY từ kit spec vào app/test làm assert văn bản.
- KHÔNG ship skeleton làm curated; phải trim rồi xóa skeleton.
- KHÔNG bịa `error`/state nếu không drive được sạch → hạ xuống coverage gap và báo.
- KHÔNG sửa generated (`*.g.dart`, `*.freezed.dart`, `lib/l10n/generated/**`, `docs/_generated/**`).
- KHÔNG đánh dấu done nếu `node tool/verify/run.mjs --full` chưa xanh.
- Nếu chọn identity-rollout (B) đụng `MxDeckTile` (widget chung) → cân nhắc, cập nhật doc, không phá test màn khác.

---

## Verification

```bash
node tool/verify/run.mjs --full
```

Phải XANH (ghi pass-marker mà pre-commit hook yêu cầu). Nếu đỏ → sửa, không commit vòng qua.
Chạy riêng test mới để chắc: `flutter test test/presentation/features/deck/library_states_test.dart`.

Sau khi verify PASS, TRƯỚC report: fan-out song song `code-reviewer` (review working-tree diff) +
`docs-drift-detector`. Gộp kết quả vào mục "Subagent review". Sửa blocker trước khi xong.

---

## Commit (2 commit + WBS)

**Commit 1** — contract + test:
```
test(parity): library state-composition gate (loaded/empty/error) + curated states.json

- curate tool/parity/contracts/library.states.json (3 gated states; 7 coverage gaps documented)
- add test/presentation/features/deck/library_states_test.dart (Template B, copy dashboard_states_test)
- remove consumed skeletons (library.states.skeleton.json, library.slots.skeleton.json)
- library.slots.json intentionally skipped (no keyed text slot; deck tiles use dynamic key)

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>
```

**Commit 2** — docs/ledger + queue:
```
docs(parity): library divergences → intent-ledger; mark library done in kit-to-flutter queue

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>
```

**WBS** (bắt buộc, `CLAUDE.md` §WBS): thêm dòng Commit Traceability Log (§10 của
`docs/project-management/wbs.md`), newest first: `<8-char hash> · <YYYY-MM-DD> · <WBS IDs> · library kit→flutter state-composition parity`.
Nếu WBS không bị ảnh hưởng về task breakdown, report ghi: `WBS update: not needed — <reason>` (nhưng Commit Traceability Log vẫn append nếu advance WP).

---

## Final report (đưa vào tin nhắn cuối)

- Template: **B (state-composition)** — lý do: 0 MxCard trong `library.gen.json`.
- Gate-able keyed node (FE): `search-btn`, `sort-btn`, `create`, `empty-deck`, `retry` (+ chrome `screen`/`appbar` loại khỏi gate).
- Gated states: `loaded`, `empty`, `error` (hoặc 2 nếu `error` không drive sạch — nêu rõ).
- Coverage gaps (7): search-active, pair-picker, sort-menu, overflow-menu, play-sheet, drawer, loading — lý do từng cái.
- Identity-rollout: deck tiles dùng key động `deckTile-<id>`; chọn (A) chấp nhận gap [hoặc (B) nếu đã thêm literal key — nêu rủi ro].
- Divergences → intent-ledger (5 mục).
- Docs updated: liệt kê. Skeletons deleted: 2.
- `node tool/verify/run.mjs --full`: PASS/FAIL.
- Subagent review: tóm tắt.
- WBS: dòng traceability đã append / hoặc "not needed — <reason>".
