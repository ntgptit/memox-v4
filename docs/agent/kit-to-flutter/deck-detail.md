# Kit → Flutter conversion prompt — **deck-detail**

> SELF-CONTAINED. Đọc hết file này rồi thực thi tuần tự. Không cần đọc file prompt nào khác.
> Nhiệm vụ: đóng **state-composition parity gate** cho màn `deck-detail` (KHÔNG vẽ lại UI —
> UI đã có sẵn; việc ở đây là **curate contract + viết 1 test composition** theo Template B).
> Nếu gặp DRIFT hoặc DIVERGENCE cần người quyết → DỪNG, báo theo mẫu `DRIFT DETECTED` (`CLAUDE.md`), chờ.

---

## PROMPT ID

`kit-to-flutter/deck-detail` · screen `deck-detail` · feature `deck` · **13 kit states**.
FE: `lib/presentation/features/deck/screens/deck_detail_screen.dart`
(+ overlay widgets ở `lib/presentation/features/deck/widgets/deck_actions.dart`).

---

## Baseline

```bash
git checkout main
git pull --ff-only
git checkout -b claude/kit-to-flutter-deck-detail
```

Không bắt đầu khi working tree bẩn. Xác nhận `node tool/verify/run.mjs --quick` xanh trước khi sửa.

---

## Required reading (đọc trước khi code)

Universal (theo `CLAUDE.md`): `docs/_generated/repo-map.md`, `docs/_generated/where-is.md`,
`docs/business/index.md`, `docs/business/glossary.md`, `docs/contracts/error-contract.md`,
`docs/contracts/types-catalog.md`, `docs/contracts/code-style.md`.

Screen-specific — CHỈ đọc đúng các file này:
- `docs/design/MemoX Design System/ui_kits/memox-app/specs/deck-detail.md` — token-resolved DOM, 13 state (base `loaded` + 12 diff/full).
- `tool/parity/contracts/deck-detail.gen.json` — 17 keyed node (key/component/variant). **Đã xác minh: 0 MxCard.** KHÔNG sửa (generated).
- `tool/parity/contracts/deck-detail.slots.skeleton.json` — slot skeleton (chỉ dùng nếu có keyed text ổn định; xem dưới — ở đây KHÔNG có).
- `tool/parity/contracts/deck-detail.states.skeleton.json` — per-state node membership (SUPERSET 13 state, phải trim mạnh).
- FE: `lib/presentation/features/deck/screens/deck_detail_screen.dart` + `lib/presentation/features/deck/widgets/deck_actions.dart`.
- Tile dùng chung (key động): `lib/presentation/shared/widgets/mx_deck_tile.dart`.
- **Reference test cần COPY (Template B):** `test/presentation/features/engagement/dashboard_states_test.dart`.
- Curated mẫu để bắt chước format: `tool/parity/contracts/dashboard.states.json`, `dashboard.slots.json`.
- Ledger hiện có (đã có 6 mục `deck-detail`): `tool/parity/intent-ledger.json`.
- Contrast (KHÔNG áp dụng ở đây, chỉ để hiểu vì sao loại): `test/presentation/features/study/review_parity_test.dart` (Template A, MxCard-rich).
- Prompt anh em đã viết xong (mẫu depth/format): `docs/agent/kit-to-flutter/player.md`, `docs/agent/kit-to-flutter/library.md`.

**Drift check trước khi code:** deck-detail là node hỗn hợp (sub-deck + card trực tiếp), route `/deck/:id`
(`docs/design/screens/04-deck-detail.md`, `docs/business/navigation/navigation-flow.md`). FE hiện tại KHÔNG có
in-screen search dock (search route ra `/search`), KHÔNG có per-card audio/delete/reset row — các điểm này ĐÃ
được ghi trong `intent-ledger.json` là exception có chủ đích (xem mục Divergences). Đây KHÔNG phải drift mới; nếu
phát hiện điểm lệch behavior CHƯA có trong ledger và không thuộc doc → DỪNG, báo. Nếu chỉ khớp các exception đã có → tiếp.

---

## CHOSEN template: **B — state-composition** (KHÔNG phải Template A)

**Vì sao B:** `deck-detail.gen.json` có **0 node `MxCard`**. 17 node của nó là control/surface:
`MxScaffold` (`deck-detail/screen`), `MxAppBar` (`deck-detail/appbar`), `MxFab` (`deck-detail/add`),
`MxIconButton` (`deck-detail/menu`, `deck-detail/play-audio`), `MxSearchDock` (`deck-detail/search-dock`),
`MxButton` ×11 (`empty-add` primary, `empty-subdeck` ghost, `empty-import` ghost, `retry` primary,
`delete-ok/cancel`, `reset-ok/cancel`, `deck-delete-ok/cancel`, `move-apply`).
Các **sub-deck card** và **card row** trong kit là node ĐỘNG (`subdeck-0..1`, `card-0..5`) — trong FE chúng render qua
`MxDeckTile` (`Key('deckTile-${node.deck.id}')`) và `ListTile` (`Key('cardRow-${card.id}')`), **KHÔNG** phải literal
`mx-node:deck-detail/card-N`.

→ Không có slot MxCard cố định để gate kiểu review. Đúng khuôn là **assert tập keyed node render CHÍNH XÁC theo từng
state** (thừa = THỪA, thiếu = THIẾU) — y hệt `dashboard_states_test.dart`.

> KHÔNG dùng Template A (review-style): deck-detail không có node `MxCard` nào keyed; nó là list + overlay-heavy.

---

## Gate-able node list (keyed literal trong FE — đã xác minh bằng grep `mx-node:deck-detail`)

Grep cho ra ĐÚNG 10 literal keyed node (8 trong screen, 2 trong `deck_actions.dart`):

| key | component (gen) | variant (gen) | FE hiện tại | render trong state |
| --- | --- | --- | --- | --- |
| `mx-node:deck-detail/screen` | MxScaffold | null | ✓ MxScaffold (`deck_detail_screen.dart:45`) | mọi state (chrome) |
| `mx-node:deck-detail/appbar` | MxAppBar | null | ✓ MxAppBar (`:47`) | mọi state (chrome) |
| `mx-node:deck-detail/menu` | MxIconButton | null | ✓ MxIconButton `more_vert` (`:76`) — chỉ khi `node != null` | `loaded` (data) |
| `mx-node:deck-detail/add` | MxFab | null | ✓ MxFab (`:86`) — chỉ khi `node != null` | `loaded` (data) |
| `mx-node:deck-detail/empty-add` | MxButton | primary | ✓ MxButton primary (`:113`) | `empty` |
| `mx-node:deck-detail/empty-subdeck` | MxButton | ghost | ⚠ MxButton **variant `outline`** (`:120`) — divergence, mục dưới | `empty` |
| `mx-node:deck-detail/empty-import` | MxButton | ghost | ✓ MxButton ghost (`:128`) | `empty` |
| `mx-node:deck-detail/retry` | MxButton | primary | ✓ MxButton (`:240`) | `error` |
| `mx-node:deck-detail/deck-delete-cancel` | MxButton | ghost | ✓ TextButton (`deck_actions.dart:102`) — overlay dialog | `deck-delete-confirm` (overlay) |
| `mx-node:deck-detail/deck-delete-ok` | MxButton | primary (JSX attr; render = `.btn.danger` → bg:error) | ✓ FilledButton **destructive** (`deck_actions.dart` — bg:error/on-error khớp kit `.btn.danger`; PR #30) — overlay dialog | `deck-delete-confirm` (overlay) |

> LƯU Ý FE-truth (khác gen.json/kit): `menu` + `add` chỉ render khi `async.value?.node != null`
> (tức KHÔNG ở `loading`/`error`/notFound). `empty-*` chỉ ở nhánh `children.isEmpty && cards.isEmpty`.
> `retry` chỉ ở `_error()`. Test composition phải phản ánh HÀNH VI FE THỰC, không phải kit lý tưởng.

**Node trong gen.json NHƯNG KHÔNG keyed literal ở FE (identity-rollout / intended gap):**
`deck-detail/play-audio`, `deck-detail/search-dock` (đã là exception trong ledger),
`deck-detail/delete-ok`, `deck-detail/delete-cancel`, `deck-detail/reset-ok`, `deck-detail/reset-cancel`,
`deck-detail/move-apply` (đã là exception trong ledger — FE move áp dụng tức thì khi chọn đích, không có nút apply).
Xem mục "Divergences" + "Identity-rollout note".

---

## Per-state node SET (curate cho `deck-detail.states.json`)

Từ `deck-detail.states.skeleton.json` (13 state, SUPERSET có cả chrome + overlay + card động), **trim** xuống tập BODY
do state điều khiển mà FE THỰC render bằng **literal keyed node**. Theo mẫu dashboard/library: `screen` + `appbar` là
chrome — **loại khỏi tập gate** (không state-driven). Card/sub-deck động (`card-N`/`subdeck-N`) không có literal key →
KHÔNG vào tập gate (phủ ở test màn riêng qua key động).

Chỉ 4 state có node-set **kiểm chứng được ổn định** trong FE: `loaded`, `empty`, `error`, và overlay
`deck-delete-confirm` (2 nút của nó ĐÃ keyed literal trong `deck_actions.dart`). Tập gate đề xuất:

```jsonc
{
  "loaded":              ["mx-node:deck-detail/menu", "mx-node:deck-detail/add"],
  "empty":               ["mx-node:deck-detail/empty-add", "mx-node:deck-detail/empty-subdeck", "mx-node:deck-detail/empty-import", "mx-node:deck-detail/menu"],
  "error":               ["mx-node:deck-detail/retry"],
  "deck-delete-confirm": ["mx-node:deck-detail/deck-delete-cancel", "mx-node:deck-detail/deck-delete-ok"]
}
```

Ghi chú curate:
- `menu` xuất hiện ở cả `loaded` và `empty` (vì `node != null` ở cả hai) → không phân biệt 2 state đó; node **thực sự
  phân biệt** là `add` (chỉ khi có node — cũng ở empty; xem lưu ý dưới), `empty-*` (chỉ `empty`), `retry` (chỉ `error`),
  `deck-delete-*` (chỉ overlay). Universe = hợp 4 tập; gate bắt THỪA khi `empty-add` present ở `loaded`, `retry` present
  ở `loaded`, v.v.
- **Lưu ý `add` ở empty:** `MxFab add` render khi `node != null` — ở state `empty` node CŨNG != null (deck tồn tại nhưng
  rỗng) ⇒ FE render CẢ `add` (fab) LẪN `empty-add`. Kiểm chứng lại khi code: nếu `add` xuất hiện ở `empty`, thêm nó vào
  tập `empty` để tránh THỪA giả. Đặt tập theo FE-truth quan sát được, KHÔNG theo kit.
- **Overlay `deck-delete-confirm`:** 2 nút keyed nằm trong `AlertDialog` mở bởi `confirmDeleteDeck(context)` (một
  `showDialog`). Để drive được trong test cần **mở dialog** (tap `menu` → chọn Delete từ bottom-sheet → dialog confirm
  hiện). Nếu drive sạch được → gate 4 state. Nếu chuỗi tap overlay không ổn định trong widget test → **hạ
  `deck-delete-confirm` xuống coverage gap**, chỉ gate `loaded/empty/error` (3 state), báo rõ. ĐỪNG viết assert giả.

**KHÔNG có `deck-detail.slots.json`:** các keyed node ở đây là control (button/icon-button/fab), không mang keyed text
slot cần bind role/l10n. Card/sub-deck text (term/meaning/badge, deck name/stats) sống trong `ListTile` + `MxDeckTile`
(key động) → không gate qua slots ở màn này. → **BỎ QUA** `deck-detail.slots.json` (ghi rõ lý do trong report). KHÔNG tạo
file rỗng. (Skeleton `deck-detail.slots.skeleton.json` vẫn phải XÓA vì đã tiêu thụ/loại bỏ có chủ đích.)

---

## State-map: 13 state → drive được / coverage gap

| kit state | drivable trong FE? | cách drive | ghi chú |
| --- | --- | --- | --- |
| `loaded` | ✅ | seed 1 deck + ≥1 sub-deck hoặc ≥1 card → `_content()` list | data non-empty; gate `menu`+`add` |
| `empty` | ✅ | seed 1 deck, 0 child + 0 card → `children.isEmpty && cards.isEmpty` | `empty-add/subdeck/import` (+`menu`,`add`) |
| `error` | ⚠️ | ép `deckDetailProvider` ném lỗi (override provider) → `_error()` | nếu không ép sạch → coverage gap, báo |
| `deck-delete-confirm` | ⚠️ | mở `⋮ menu` → Delete → `confirmDeleteDeck` dialog | 2 nút keyed; nếu chuỗi overlay không ổn → gap |
| `loading` | ⚠️ | async đầu → `MxStateView.loading()` (skeleton) | KHÔNG có keyed body node → **coverage gap** |
| `search` | ❌ | FE search ra route `/search`, không có in-screen dock | **coverage gap** — `search-dock` là exception (ledger) |
| `no-results` | ❌ | thuộc màn `/search`, không phải deck-detail | **coverage gap** |
| `add-menu` | ❌ | FE `add` mở editor route trực tiếp (`_addWord`), không có bottom-sheet add | **coverage gap** — không có `add-word/subdeck/import` node keyed |
| `card-actions` | ❌ | FE quản lý card trong flashcard editor, không có per-row action sheet | **coverage gap** — exception (ledger `delete`) |
| `reset-confirm` | ❌ | v1 SRS không có reset thủ công | **coverage gap** — exception (ledger `reset`) |
| `deck-menu` | ⚠️ | `⋮` mở `showDeckActions` bottom-sheet (`ListTile` keyed `deckAction*`, KHÔNG keyed `deck-rename/move/reset/delete`) | overlay không keyed literal → **coverage gap** cho node-set; chỉ nút mở (`menu`) keyed |
| `move` | ❌ | FE dùng `SimpleDialog` (`promptMoveDeck`), áp dụng tức thì, không có `move-apply`/radio node keyed | **coverage gap** — exception (ledger `move-apply`) |
| `delete-confirm` | ❌ | đây là DELETE **CARD** của kit; FE xoá card trong editor, không có dialog per-row | **coverage gap** — exception (ledger `delete`) |

→ **Gate 3–4 state:** `loaded`, `empty`, `error` (+ `deck-delete-confirm` nếu overlay drive sạch).
**9–10 state là coverage gap** — ghi thẳng trong header test (giống `review_parity_test` giải thích state không map)
và tham chiếu các exception đã có trong ledger.

> Phân biệt hai overlay dễ nhầm: `deck-menu` (⋮ → rename/move/reset/delete) là bottom-sheet của FE
> (`showDeckActions`, `ListTile` key `deckActionRename/Move/Delete` — KHÔNG phải `mx-node:` literal ⇒ gap). Chỉ
> `deck-delete-confirm` (dialog xác nhận xoá DECK) mới có 2 nút `mx-node:` literal keyed ⇒ gate được. `delete-confirm`
> (kit) là xoá **card** — hoàn toàn không có ở FE (ledger exception `delete`).

---

## Divergences → `tool/parity/intent-ledger.json`

`intent-ledger.json` ĐÃ có **6 mục `deck-detail`** (kiểm chứng trước khi thêm, tránh trùng):
`delete`, `reset`, `play-audio`, `search-dock`, `move-apply`, và lưu ý deck-delete IS keyed. **Không thêm lại** các mục đã có.

Mục CẦN thêm/kiểm (mỗi mục: `screen · node · exceptionKind · reason · source`, giữ đúng format `exceptions[]` hiện có):

1. **`empty-subdeck` variant** — kit variant `ghost`, FE `MxButtonVariant.outline` (`deck_detail_screen.dart:120`). Đây là
   chệch **style/variant** có chủ đích (empty-state: primary Add + outline New sub-deck + ghost Import = phân cấp nhấn 3 bậc).
   → Thêm 1 mục `styleExempt` (field `variant` hoặc `*`) HOẶC `exceptions` tùy cách spec_diff phân loại; reason:
   `"empty-state uses outline for the secondary 'new sub-deck' CTA (3-tier emphasis: primary add / outline subdeck / ghost import); kit = ghost"`,
   source: `docs/business/deck/deck-management.md`. (Nếu variant không bị spec_diff so → chỉ cần note trong `$curated`
   của `states.json`, không cần ledger. Kiểm bằng verify.)
2. **`add-menu` không tồn tại** — kit có bottom-sheet Add (add-word/subdeck/import); FE `add` (fab) mở flashcard editor
   route trực tiếp (`_addWord` → `context.push(flashcardEditorLocation)`). → Thêm `exceptions` node `add-word` (hoặc
   `add-sheet`), reason: `"fe add FAB pushes the flashcard editor route directly; there is no intermediate add bottom-sheet"`,
   source: `docs/business/deck/deck-management.md`. (Nếu muốn tối giản, gộp là 1 mục cho tiền tố `add-`.)
3. **`deck-menu` items không keyed** — FE `showDeckActions` bottom-sheet dùng `ListTile` key `deckAction{Rename,Move,Delete}`
   (không phải `mx-node:deck-detail/deck-{rename,move,reset,delete}` literal). Ngoài ra **không có `deck-reset`** (v1 không
   reset — đã có exception `reset`). → Thêm `exceptions` cho tiền tố `deck-` (rename/move) nếu spec_diff yêu cầu coverage:
   reason `"deck actions render as a Material bottom-sheet (ListTile), keyed deckAction* not mx-node literals; no reset item (v1)"`,
   source: `docs/business/navigation/navigation-flow.md`.

> Nếu bất kỳ mục nào thực chất là **BUG** (không phải chủ ý) → **DỪNG**, báo theo mẫu DRIFT trong `CLAUDE.md`, chờ người.
> Không tự sửa UI trong prompt này. Divergence hợp lệ = vào ledger, KHÔNG ép FE về kit.

---

## Identity-rollout note (card + sub-deck rows)

- Card row: FE `_cardRow` → `ListTile(key: Key('cardRow-${card.id}'))` (`deck_detail_screen.dart:203`). Key phụ thuộc
  id runtime ⇒ **không thể** gate bằng literal `mx-node:deck-detail/card-N`.
- Sub-deck: `MxDeckTile(key: Key('deckTile-${node.deck.id}'))` (`mx_deck_tile.dart:31`). Tương tự — key động.

**Lựa chọn (khuyến nghị (A)):**
- **(A) Chấp nhận gap:** card/sub-deck là danh sách động, không thuộc tập literal keyed; parity phủ chúng qua test màn
  riêng (`deck_detail` screen test đã assert `cardRow-<id>` / `deckTile-<id>`). Composition gate chỉ lo control/empty/error/
  deck-delete. → KHÔNG đổi UI.
- **(B) Thêm literal ValueKey ổn định** cho tile đầu tiên — chỉ làm nếu muốn `loaded` có node body phân biệt; đụng
  `MxDeckTile` (widget dùng chung → rủi ro nhiều màn) + doc. Nếu chọn B: qua parity check, không phá test khác, ghi WBS.

Mặc định **(A)**.

---

## Workflow (thực thi tuần tự)

1. **Curate `tool/parity/contracts/deck-detail.states.json`** từ skeleton: chỉ 3–4 state
   (`loaded/empty/error` [+ `deck-delete-confirm` nếu drive sạch]), chỉ node keyed literal FE, bỏ chrome `screen`/`appbar`,
   bỏ card/sub-deck động, bỏ 9 overlay/state là gap. Thêm `$curated` header (bắt chước `dashboard.states.json`) giải thích
   9–10 state coverage gap + lý do từng nhóm + tham chiếu exception ledger. Kiểm `add` có ở `empty` không (mục State-SET) và
   đặt tập theo FE-truth.
2. **`deck-detail.slots.json`: BỎ QUA** — ghi lý do (không có keyed text slot; card/tile text là key động). Không tạo file rỗng.
3. **Align FE** `deck_detail_screen.dart` + `deck_actions.dart`: xác nhận 10 key literal đúng chính tả (grep đã confirm);
   token-only (`Mx*` + `MxSpacing` + theme token, KHÔNG hardcode màu/radius/spacing/text-style/duration/string). KHÔNG hoist
   node-literal sau dynamic key. KHÔNG thêm node mới cho các overlay là gap (add-sheet/card-actions/reset/move/deck-menu
   items) — ngoài scope style-parity. Divergence (`empty-subdeck` outline) giữ nguyên → vào ledger.
4. **l10n:** mọi chuỗi user-facing của các state gate ĐÃ có trong ARB (`deckDetailEmpty`, `deckAddWord`, `deckNewSubdeck`,
   `drawerImport`, `libraryError`, `commonRetry`, `deckDeleteConfirmTitle/Body`, `commonCancel`, `commonDelete`,
   `cardStatus*`). Nếu bạn thêm/đổi bất kỳ chuỗi nào → thêm vào **cả** `app_en.arb` **và** `app_vi.arb` cùng commit rồi
   regen; KHÔNG sửa `lib/l10n/generated/**` tay. KHÔNG copy MOCK COPY từ kit ("Korean Basics", "안녕하세요", "Empty deck"…)
   vào app/test — luôn từ ARB.
5. **Viết test composition** `test/presentation/features/deck/deck_detail_states_test.dart`: COPY cấu trúc
   `dashboard_states_test.dart` (đọc `deck-detail.states.json`, tính `universe` = hợp mọi tập, `recipes` seed cho từng
   state, pump `DeckDetailScreen(deckId: ...)`, assert mỗi key trong universe: allowed → `findsOneWidget` (THIẾU nếu absent),
   ngoài allowed → `findsNothing` (THỪA nếu present)). Seed Drift in-memory (languagePair ko→vi + deck [+ child/card]) theo
   mẫu `review_parity_test.dart` (`AppDatabase.forTesting(openInMemoryDatabase())`, override `databaseProvider` +
   `clockProvider`). `error` cần override provider ném lỗi; `deck-delete-confirm` cần chuỗi tap mở dialog — nếu không sạch,
   hạ xuống gap (comment lý do). Header test giải thích rõ 9–10 state coverage gap (giống review_parity_test).
6. **Xóa skeleton** đã tiêu thụ: `deck-detail.states.skeleton.json` **và** `deck-detail.slots.skeleton.json` (skeleton là
   AUTO-PROPOSED, không ship — theo ghi chú `$skeleton`).
7. **Cập nhật queue:** đổi ô `[ ] `03-deck-detail.md` — **deck-detail**...` → `[x]` trong `docs/agent/kit-to-flutter/README.md`.
8. **Ledger:** thêm các mục Divergences mục trên vào `intent-ledger.json` (không trùng 6 mục cũ).
9. **Doc parity:** nếu divergence ảnh hưởng behavior đã ghi ở `docs/business/**` / `docs/design/**` → cập nhật cùng commit
   (thường chỉ cần ledger + `$curated` note).

---

## Hard rules (vi phạm = fail — trích `CLAUDE.md`)

- KHÔNG vẽ lại/di chuyển UI trong prompt này; chỉ curate contract + viết test. Divergence → ledger, không tự sửa.
- **Token-only:** KHÔNG hardcode route/màu/radius/spacing/text-style/duration/string; string lấy từ ARB (`lib/l10n/`).
- KHÔNG hoist node-literal sau dynamic key; mỗi `ValueKey('mx-node:...')` là `const` gắn node tĩnh, không sinh key theo index/state.
- KHÔNG copy MOCK COPY từ kit spec vào app/test làm assert văn bản.
- KHÔNG ship skeleton làm curated; phải trim rồi XÓA cả 2 skeleton.
- KHÔNG bịa `error`/`deck-delete-confirm` nếu không drive được sạch → hạ xuống coverage gap và báo. Không viết assert giả.
- KHÔNG sửa generated (`*.g.dart`, `*.freezed.dart`, `deck-detail.gen.json`, `lib/l10n/generated/**`, `docs/_generated/**`).
- KHÔNG thêm dependency mới (Stop & ask nếu cần).
- KHÔNG đổi hành vi SRS/schedule, route, hay bỏ layering (UseCase → Repository → DataSource).
- Nếu chọn identity-rollout (B) đụng `MxDeckTile` (widget chung) → cân nhắc, cập nhật doc, không phá test màn khác, ghi WBS.
- KHÔNG đánh dấu done nếu `node tool/verify/run.mjs --full` chưa xanh.

---

## Verification

```bash
node tool/verify/run.mjs --full
```

Phải XANH (ghi pass-marker mà pre-commit hook yêu cầu; trong đó có test parity mới + freshness check của specs). Nếu đỏ
hoặc bị skip → sửa, KHÔNG commit vòng qua / KHÔNG báo done. Trong lúc dev có thể `--quick` (không marker). Chạy riêng test
mới để chắc: `flutter test test/presentation/features/deck/deck_detail_states_test.dart`.

Sau khi verify PASS, TRƯỚC final report: fan-out song song `code-reviewer` (review working-tree diff — cho nó chạy
`git add -N . && git diff`, KHÔNG commit trước) + `docs-drift-detector`. Gộp kết quả vào mục "Subagent review". Fix blocker
trước khi xong; liệt kê minor cho người.

---

## Commit (2 commit + WBS)

**Commit 1** — contract + test:
```
test(parity): deck-detail state-composition gate (loaded/empty/error[/deck-delete]) + curated states.json

- curate tool/parity/contracts/deck-detail.states.json (3-4 gated states; 9-10 coverage gaps documented)
- add test/presentation/features/deck/deck_detail_states_test.dart (Template B, copy dashboard_states_test)
- remove consumed skeletons (deck-detail.states.skeleton.json, deck-detail.slots.skeleton.json)
- deck-detail.slots.json intentionally skipped (no keyed text slot; card/sub-deck rows use dynamic keys)

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>
```

**Commit 2** — docs/ledger + queue:
```
docs(parity): deck-detail divergences → intent-ledger; mark deck-detail done in kit-to-flutter queue

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>
```

**WBS** (bắt buộc, `CLAUDE.md` §WBS): thêm dòng Commit Traceability Log (§10 của `docs/project-management/wbs.md`),
newest first: `<8-char hash> · <YYYY-MM-DD> · <WBS IDs> · deck-detail kit→flutter state-composition parity`.
Nếu WBS không bị ảnh hưởng về task breakdown, report ghi `WBS update: not needed — <reason>` (nhưng Commit Traceability
Log vẫn append nếu advance WP).

---

## Final report (đưa vào tin nhắn cuối)

- Template: **B (state-composition)** — lý do: 0 MxCard trong `deck-detail.gen.json`.
- Gate-able keyed node (FE, 10): `menu`, `add`, `empty-add`, `empty-subdeck`, `empty-import`, `retry`, `deck-delete-cancel`,
  `deck-delete-ok` (+ chrome `screen`/`appbar` loại khỏi gate).
- Gated states: `loaded`, `empty`, `error` [+ `deck-delete-confirm` nếu overlay drive sạch — nêu rõ 3 hay 4].
- Coverage gaps (9–10): `loading`, `search`, `no-results`, `add-menu`, `card-actions`, `reset-confirm`, `deck-menu`,
  `move`, `delete-confirm` — lý do từng cái (đa số là exception đã có trong ledger).
- Identity-rollout: card/sub-deck dùng key động (`cardRow-<id>` / `deckTile-<id>`); chọn (A) chấp nhận gap [hoặc (B) nếu
  thêm literal key — nêu rủi ro].
- Divergences → intent-ledger: `empty-subdeck` (outline vs ghost), `add-menu` (FE fab → editor route, no sheet),
  `deck-menu` items (Material bottom-sheet, keyed deckAction* not mx-node) + 6 mục cũ đã có.
- Docs updated: <list | none — style-parity only>. Skeletons deleted: 2.
- `node tool/verify/run.mjs --full`: PASS/FAIL.
- Subagent review: tóm tắt (blockers fixed / minor).
- WBS: dòng traceability đã append / hoặc "not needed — <reason>".
- l10n: các key state gate đã có ở app_en.arb + app_vi.arb [no new keys | new keys: ...].
```
