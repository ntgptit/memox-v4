# Kit → Flutter conversion prompt — **game-picker**

> SELF-CONTAINED. Đọc hết file này rồi thực thi tuần tự. Không cần đọc file prompt nào khác.
> Nhiệm vụ: đóng **state-composition parity gate** cho màn `game-picker` (KHÔNG vẽ lại UI —
> UI đã có sẵn; việc ở đây là **curate contract + viết 1 test composition** theo Template B).
> Nếu gặp DRIFT hoặc DIVERGENCE cần người quyết → DỪNG, báo theo mẫu `DRIFT DETECTED` trong
> `CLAUDE.md`, chờ người.

---

## PROMPT ID

`kit-to-flutter/game-picker` · screen `game-picker` · feature `game` · WBS **W5** (style/parity: W5,W14) · 3 kit states.
FE: `lib/presentation/features/game/screens/game_picker_screen.dart`.
Màn "A game" picker (D-013): chọn 1 trong 4 game + 1 scope (repeat mode), hoặc trạng thái không đủ thẻ.

---

## 1. Baseline

```bash
git checkout main
git pull --ff-only
git checkout -b claude/kit-to-flutter-game-picker
```

Không bắt đầu khi working tree bẩn. Xác nhận `node tool/verify/run.mjs --quick` xanh trước khi sửa.

---

## 2. Required reading (CHỈ đọc đúng các file này)

Universal (theo `CLAUDE.md`): `docs/_generated/repo-map.md`, `docs/_generated/where-is.md`,
`docs/business/index.md`, `docs/business/glossary.md`, `docs/contracts/error-contract.md`,
`docs/contracts/types-catalog.md`, `docs/contracts/code-style.md`.

Screen-specific:
- `docs/design/MemoX Design System/ui_kits/memox-app/specs/game-picker.md` — token-resolved DOM, 3 state (base `default` + 2 diff: `scope dropdown`, `not enough`).
- `tool/parity/contracts/game-picker.gen.json` — 4 keyed node (key/component/variant). **KHÔNG sửa** (generated). **Đã xác minh: `game-picker/scope` gen là `MxCard` nhưng FE KHÔNG render MxCard cho node đó** (xem mục 3).
- `tool/parity/contracts/game-picker.slots.skeleton.json` — slot skeleton (superset; chỉ dùng nếu có keyed text slot — xem mục "slots.json BỎ QUA").
- `tool/parity/contracts/game-picker.states.skeleton.json` — per-state node membership (SUPERSET, phải trim mạnh: skeleton liệt kê cả `scope-*`, `game-matching..typing`, `not-enough` — hầu hết KHÔNG keyed trong FE).
- FE: `lib/presentation/features/game/screens/game_picker_screen.dart`.
- **Reference test cần COPY (Template B):** `test/presentation/features/engagement/dashboard_states_test.dart`.
- Curated mẫu để bắt chước format: `tool/parity/contracts/dashboard.states.json`, `dashboard.slots.json`.
- Contrast (KHÔNG áp dụng ở đây — để hiểu vì sao loại): `test/presentation/features/study/review_parity_test.dart` (Template A, MxCard-rich) + `tool/parity/contracts/review.slots.json`, `review.states.json`.
- Ledger hiện có: `tool/parity/intent-ledger.json` (đã có sẵn 1 entry `styleExempt` cho `game-picker/scope`).

**Drift check trước khi code (BẮT BUỘC — có 1 divergence business ở dưới):**

- Kit `not enough` banner nói *"This deck needs at least **4** words to play."*. FE branch là
  `switch (_count) { null => loading; 0 => _notEnough; _ => _picker }` — tức FE hiện **chỉ**
  vào not-enough khi `count == 0`, còn `1..3` thẻ vẫn vào picker. Kit ngưỡng = 4, FE ngưỡng = 0.
  → Đây là **behavior divergence** đã tồn tại trong FE. Task này là **style/state-composition
  parity**, KHÔNG phải sửa business rule. Xử lý: (a) seed `not-enough` bằng **0 thẻ** (đúng nhánh
  FE reach được), (b) ghi divergence vào intent-ledger `exceptions` với `source` là
  `docs/business/game/game-modes.md`, (c) nếu doc business quy định ngưỡng ≥4 và FE mâu thuẫn →
  DỪNG, báo `DRIFT DETECTED` (code-file vs doc-file), chờ người. **Không** tự đổi `0 =>` thành
  `< 4 =>` trong task parity này.

---

## 3. CHOSEN template: **B — state-composition** (KHÔNG phải Template A)

**Vì sao B (không A):**

1. `game-picker.gen.json` liệt kê `mx-node:game-picker/scope` = `MxCard` (variant `elevated`).
   Nhưng grep FE cho thấy `ValueKey('mx-node:game-picker/scope')` gắn trên một
   **`DropdownButton<GameScope>`** (`game_picker_screen.dart:123`) — KHÔNG phải `MxCard`.
   Template A vòng `if (node['component'] != 'MxCard') continue;` ⇒ sẽ **bỏ qua toàn bộ** (không có
   MxCard thật để tìm) ⇒ gate rỗng, vô nghĩa. Loại A.
2. Các "game row" trong kit (`game-matching/mc/recall/typing`) trong FE render bằng `ListTile` với
   key ĐỘNG `Key('gamePick-${type.name}')` (`game_picker_screen.dart:177`), **KHÔNG** phải literal
   `mx-node:game-picker/game-*`. Không có MxCard cố định để gate kiểu review.
3. Cái phân biệt state ở đây là **tập control render** (picker controls vs not-enough CTA), đúng
   khuôn `dashboard_states_test.dart`: assert tập keyed node render CHÍNH XÁC theo state
   (thừa = THỪA, thiếu = THIẾU).

→ Dùng **Template B**. Copy `dashboard_states_test.dart`, đổi seed/pump sang `GamePickerScreen`.

---

## 4. Gate-able node list (keyed trong FE — đã xác minh bằng grep `mx-node:game-picker`)

Grep `mx-node:game-picker` trong `lib/` cho ra ĐÚNG **4** literal keyed:

| key | component (gen) | variant (gen) | FE thực tế | render trong state |
| --- | --- | --- | --- | --- |
| `mx-node:game-picker/screen` | MxScaffold | null | ✓ `MxScaffold` (`:74`) | mọi state (chrome) |
| `mx-node:game-picker/appbar` | MxAppBar | null | ✓ `MxAppBar` (`:76`) | mọi state (chrome) |
| `mx-node:game-picker/scope` | **MxCard** elevated | — | ⚠ `DropdownButton<GameScope>` (`:123`) — **divergence** (mục 6) | `default` (picker) |
| `mx-node:game-picker/add-cards` | MxButton primary | primary | ✓ `MxButton` (`:102`) | `not-enough` |

**Node phân biệt state thực sự:** chỉ `scope` (chỉ ở picker) và `add-cards` (chỉ ở not-enough).
`screen`/`appbar` là chrome — theo mẫu dashboard, **loại khỏi tập gate** (không state-driven).

### Node trong gen.json / kit spec NHƯNG KHÔNG keyed ở FE (identity-rollout gap — ghi nhận, KHÔNG ép)

- **Game rows** `game-picker/game-matching`, `game-mc`, `game-recall`, `game-typing` — FE render
  qua `ListTile` key động `gamePick-<type.name>` (`:177`), không literal `mx-node:`. → gap (list động).
- **Scope sheet** `game-picker/scope-scrim`, `scope-sheet`, `scope-srs`, `scope-all`,
  `scope-unlearned` — kit là bottom-sheet overlay; FE dùng **Material `DropdownButton` menu overlay**
  (không phải sheet, không keyed các item) → gap (overlay không keyed; xem coverage gap mục 6).
- **Not-enough banner** `game-picker/not-enough` — kit là 1 `ActionCallout` (warning-soft banner
  icon+text+CTA inline); FE render 1 `Center(Column)` icon + `MxText` + `MxButton` (KHÔNG keyed
  container `not-enough`, chỉ `add-cards` bên trong keyed). → gap cho container identity.
- **Words hint / back button** `game-picker/back` (skeleton states) — FE back nằm trong `MxAppBar`,
  không keyed literal; words-hint là `MxText(...bodySmall)` không keyed. → gap.

Liệt kê nguyên các gap này trong **final report** ("Identity-rollout gap"). KHÔNG rollout key mới
cho game rows / sheet items / banner container trong task này (đây là task parity, không phải feature/UI).

---

## 5. Per-state node SET (curate cho `game-picker.states.json`)

Từ `game-picker.states.skeleton.json`, **trim mạnh** SUPERSET xuống tập BODY do state điều khiển mà
FE THỰC render bằng literal key. Loại chrome (`screen`/`appbar`), loại mọi node chưa keyed FE
(game rows động, sheet items, not-enough container). Tập gate đề xuất — CHỈ node keyed FE:

```jsonc
{
  "default":    ["mx-node:game-picker/scope"],
  "not-enough": ["mx-node:game-picker/add-cards"]
}
```

- `default` (picker, có ≥1 thẻ) → render `scope` dropdown; KHÔNG render `add-cards`.
- `not-enough` (0 thẻ) → render `add-cards`; KHÔNG render `scope`.
- Universe = `{ scope, add-cards }`. Gate bắt THỪA: assert `add-cards` **absent** ở `default`, và
  `scope` **absent** ở `not-enough` — đó là chỗ 2 nhánh phân biệt chắc chắn.
- `scope-dropdown` **KHÔNG** là state trong `states.json` (coverage gap — mục 6): nó chỉ mở menu
  overlay của cùng `scope` dropdown, không đổi tập keyed node.

Thêm `$curated` header (bắt chước `dashboard.states.json` / `review.states.json`) giải thích:
2 state gated (`default`/`not-enough`); `scope-dropdown` là coverage gap (Material dropdown overlay,
không keyed item, cùng node-set với `default`); chrome loại khỏi gate; ngưỡng not-enough FE = 0 thẻ
(kit = <4) đã ghi ledger.

**`game-picker.slots.json`: BỎ QUA.** Lý do: 2 node keyed còn lại là control —
`scope` = `DropdownButton` (không có keyed MxText slot cần bind role/l10n), `add-cards` = `MxButton`
(label từ ARB `deckAddWord`, không phải MxText slot cần gate role). Text của game rows / title /
words-hint sống ngoài node keyed literal (ListTile / MxAppBar / MxText không keyed). → KHÔNG tạo
`game-picker.slots.json`; ghi rõ lý do trong report. (Nếu muốn phủ text đó là việc của prompt khác:
dynamic-key hoặc slot rollout — ngoài scope.)

---

## 6. State-map: state nào drive được / state nào là coverage gap

FE là `ConsumerStatefulWidget`; `initState` gọi `_load()` → đọc
`cardRepositoryProvider.listByDeck(nodeId)` → `setState(_count = cards.length)`. Nhánh body:
`switch (_count) { null => MxStateView.loading; 0 => _notEnough; _ => _picker }`.
Pump pattern: **giống `dashboard_states_test`** — seed Drift in-memory (languagePair + deck + N card),
override `databaseProvider`, `pumpWidget(host)`. `game-picker` load trong `initState` async ⇒
KHÔNG dùng thẳng `pumpAndSettle` nếu `MxStateView.loading` có spinner; dùng vòng `for` pump 50ms
(giống `review_parity_test`) hoặc `pumpAndSettle` nếu loading là determinate — thử `pumpAndSettle`
trước; nếu treo (spinner) thì đổi sang vòng `for (var i=0;i<5;i++) pump(50ms)`.

| kit state | FE reach được? | Cách drive | Node-set FE |
| --- | --- | --- | --- |
| `default` (picker) | ✅ | seed **≥1 thẻ** (dùng 1 hoặc 12 thẻ; bất kỳ `count>0` → `_picker`) | `scope` (add-cards absent) |
| `not-enough` | ✅ | seed **0 thẻ** (deck rỗng, chỉ `languagePair`+`deck`) → `count==0` → `_notEnough` | `add-cards` (scope absent) |
| `scope-dropdown` | ❌ coverage gap | Node `scope` là **Material `DropdownButton`**; mở nó bung 1 menu overlay (`DropdownMenuItem`) — KHÔNG có keyed node `scope-srs/all/unlearned` như kit bottom-sheet. Overlay không đổi tập keyed literal ⇒ không phân biệt được ở tầng identity. | (= default) |
| (`loading`) | ⚠ | trạng thái async đầu (`_count == null`) → `MxStateView.loading`, không có keyed body node phân biệt | **coverage gap** (skeleton) |

→ **Gate 2 state:** `default`, `not-enough`. **coverage gap:** `scope-dropdown` (Material dropdown
overlay, item không keyed — kit là bottom-sheet với `scope-*` keyed; divergence + gap), `loading`
(async đầu, không keyed body node). Ghi thẳng trong `$curated` header của `states.json` và trong
header test (giống review_parity_test giải thích state không map).

> Nếu khi code phát hiện `not-enough` KHÔNG reach sạch bằng seed 0 thẻ (vd repo trả lỗi thay vì
> list rỗng) → hạ xuống coverage gap, chỉ gate `default`. Báo rõ trong report. ĐỪNG viết test giả.

---

## 7. Divergences → `tool/parity/intent-ledger.json` (KHÔNG ép FE về kit)

Ghi/xác nhận các mục sau (append vào mảng đúng, giữ format hiện có). **Không** sửa FE để khớp kit ở
các điểm này — chệch có chủ đích. Mỗi mục `exceptions` cần `source` (doc/owner ruling); mỗi mục
`styleExempt` cần `source`.

1. **`scope` = DropdownButton, không MxCard/sheet** — kit: `MxCard` elevated surface chip (r:20) mở
   bottom-sheet; FE: Material `DropdownButton` mở menu overlay. → **ĐÃ CÓ** entry `styleExempt`
   `{screen:"game-picker", node:"scope", field:"*", source:"docs/business/game/game-modes.md"}`
   trong `intent-ledger.json`. **Xác nhận còn đúng, KHÔNG trùng lặp.** Thêm (nếu chưa có) 1 mục
   `exceptions` cho `scope-*` sheet items (kit bottom-sheet vs FE dropdown menu — không keyed item):
   `exceptionKind:"behavior"`, reason ~ *"kit scope là bottom-sheet với 3 lựa chọn keyed
   (scope-srs/all/unlearned); FE dùng Material DropdownButton menu (item không keyed literal), giữ
   1 control gọn thay 1 sheet"*, `source:"docs/business/game/game-modes.md"`.
2. **Not-enough ngưỡng** — kit banner: *"…at least 4 words…"* (ActionCallout warning-soft, render
   khi 1..3 thẻ vẫn thiếu); FE: chỉ vào not-enough khi `count == 0`, layout `Center(Column)` không
   phải callout banner. → mục `exceptions` `{screen:"game-picker", node:"not-enough",
   exceptionKind:"behavior", reason:"FE not-enough trigger tại count==0 (deck rỗng) và render dạng
   empty-state Center(Column) icon+text+CTA, không phải kit ActionCallout ngưỡng <4",
   source:"docs/business/game/game-modes.md"}`. **Nếu** business doc quy định ngưỡng ≥4 → đây là
   DRIFT, DỪNG + báo, đừng tự ledger.
3. **Game rows key động** — kit `game-matching/mc/recall/typing` literal vs FE `gamePick-<type>`
   động. → mục `exceptions` (INTENDED, list game cố định nhưng key theo enum type, không literal
   `mx-node`), `source:"docs/business/game/game-modes.md"` (hoặc FE file nếu doc không nói).

Sau khi ghi ledger, các divergence này KHÔNG được làm fail test composition (test chỉ gate tập
`{scope, add-cards}` present/absent theo state).

> Nếu bất kỳ mục nào thực chất là **BUG** (không phải chủ ý) → DỪNG, báo `DRIFT DETECTED`, chờ người.

---

## 8. Workflow (thực thi tuần tự, mỗi bước một layer)

1. **Curate `tool/parity/contracts/game-picker.states.json`** từ skeleton: chỉ 2 state
   `default`/`not-enough`, chỉ node keyed FE (`scope` / `add-cards`), bỏ chrome `screen`/`appbar`,
   bỏ game rows / sheet items / not-enough container (chưa keyed). Thêm `$curated` header mô tả
   (bắt chước `dashboard.states.json`) — nêu `scope-dropdown` + `loading` là coverage gap, ngưỡng
   not-enough FE=0.
2. **`game-picker.slots.json`: BỎ QUA** — ghi lý do (2 node keyed đều là control, không keyed text
   slot). KHÔNG tạo file rỗng.
3. **Align FE** `game_picker_screen.dart` — xác nhận 4 key hiện có đúng chính tả (grep đã confirm:
   screen/appbar/scope/add-cards). KHÔNG hoist node-literal sau dynamic key; KHÔNG thêm node mới
   cho game rows / sheet / banner (ngoài scope). KHÔNG hardcode màu/spacing/route/string — nếu phát
   hiện chỗ hardcode khi rà, sửa về token/ARB trong cùng commit (token-only). Divergence (scope
   dropdown, not-enough layout, game-row key động) giữ nguyên → đã vào ledger.
4. **l10n**: các key màn này (`gameTitle`, `gameScopeLabel`, `gameScopeSpaced/All/NotMastered`,
   `gameWordsHint`, `gameMatching(+Desc)`, `gameMultipleChoice(+Desc)`, `gameRecall(+Desc)`,
   `gameTyping(+Desc)`, `gameNotEnoughTitle`, `deckAddWord`) **đã có ở CẢ** `app_en.arb` và
   `app_vi.arb` (đã verify). Nếu bạn thêm/đổi bất kỳ chuỗi user-facing nào → thêm vào **cả hai** ARB
   cùng commit rồi regen; KHÔNG sửa `lib/l10n/generated/**` tay. KHÔNG copy mock copy từ kit spec
   ("Single game", "By schedule", "This deck needs at least 4 words to play"…) vào app/test.
5. **Viết test composition** `test/presentation/features/game/game_picker_states_test.dart` —
   COPY cấu trúc `dashboard_states_test.dart`:
   - đọc `tool/parity/contracts/game-picker.states.json`, tính `universe = ∪ allowed`;
   - `recipes` seed cho từng state: `'default'` → seed deck + **N thẻ (≥1, vd 12)**; `'not-enough'`
     → seed deck + **0 thẻ**;
   - seed pattern giống `review_parity_test`: `AppDatabase.forTesting(openInMemoryDatabase())` →
     insert `LanguagePairCompanion(ko→vi)` → `DeckCompanion(pairId, name)` → N ×
     `CardCompanion.insert(deckId, term:'학교', createdAt:1)`;
   - host = `ProviderScope(overrides:[databaseProvider.overrideWithValue(db)], MaterialApp(theme
     AppTheme.light(), l10n delegates, home: Scaffold(body: GamePickerScreen(nodeId: deckId))))`;
     (game-picker đọc `cardRepositoryProvider` → repo dùng `databaseProvider`; nếu repo cần override
     riêng, override `cardRepositoryProvider` giống các test khác — kiểm `card_providers.dart`);
   - pump: thử `pumpAndSettle`; nếu treo do `MxStateView.loading` spinner → đổi vòng
     `for (var i=0;i<5;i++) await tester.pump(const Duration(milliseconds:50));`;
   - assert mỗi key trong `universe`: allowed → `findsOneWidget` (THIẾU nếu absent), ngoài allowed →
     `findsNothing` (THỪA nếu present);
   - header test giải thích rõ `scope-dropdown` + `loading` coverage gap + ngưỡng not-enough FE=0
     (giống review_parity_test giải thích state không map).
6. **Xóa skeleton** đã tiêu thụ: `tool/parity/contracts/game-picker.states.skeleton.json` **và**
   `game-picker.slots.skeleton.json` (skeleton là AUTO-PROPOSED, không ship — theo ghi chú
   `$skeleton`; giống review/dashboard/library không còn skeleton).
7. **Cập nhật queue**: đổi `[ ] 05-game-picker.md` → `[x]` trong
   `docs/agent/kit-to-flutter/README.md`.
8. **Doc parity**: nếu divergence ảnh hưởng behavior đã ghi ở `docs/business/**` hoặc
   `docs/design/**` → cập nhật cùng commit. Task này thuần state-composition/parity ⇒ nhiều khả năng
   chỉ cần intent-ledger (không đổi business doc), TRỪ ngưỡng not-enough nếu mâu thuẫn doc (→ DRIFT).

---

## 9. Hard rules (vi phạm = task fail — trích `CLAUDE.md`)

- KHÔNG vẽ lại/di chuyển UI trong prompt này; chỉ curate contract + viết test. Divergence → ledger,
  KHÔNG tự sửa UI. Nếu divergence là BUG → DỪNG + báo DRIFT.
- **Token-only**: KHÔNG hardcode màu, radius, spacing, text style, duration, route, chuỗi
  user-facing. String lấy từ ARB (`lib/l10n/`).
- KHÔNG copy MOCK COPY từ kit spec vào app/test làm assert văn bản.
- KHÔNG node-literal hoist sau dynamic key; mỗi `ValueKey('mx-node:...')` là `const` gắn node tĩnh.
- KHÔNG ship skeleton làm curated; phải trim rồi xóa 2 skeleton.
- KHÔNG bịa state nếu không drive được sạch → hạ xuống coverage gap và báo.
- KHÔNG sửa file generated (`*.g.dart`, `*.freezed.dart`, `game-picker.gen.json`,
  `lib/l10n/generated/**`, `docs/_generated/**`).
- KHÔNG thêm dependency mới (Stop & ask nếu cần).
- KHÔNG đổi hành vi SRS/schedule (game luyện thuần D-007/D-013 — không đổi lịch); KHÔNG đổi ngưỡng
  not-enough business trong task parity.
- KHÔNG đánh dấu done nếu `node tool/verify/run.mjs --full` chưa xanh.

---

## 10. Verification

```bash
node tool/verify/run.mjs --full
```

Phải PASS (ghi pass-marker mà pre-commit hook yêu cầu) — gồm test parity mới + freshness check của
specs. Nếu `--full` fail hoặc bị skip → KHÔNG được báo done. Lúc dev có thể `--quick` (không marker).
Chạy riêng test mới để chắc:
`flutter test test/presentation/features/game/game_picker_states_test.dart`.

Sau khi verify PASS, TRƯỚC final report: fan-out song song `code-reviewer` (review working-tree diff:
cho nó chạy `git add -N .` rồi `git diff`, KHÔNG commit trước) + `docs-drift-detector`. Gộp kết quả
vào mục "Subagent review". Sửa blocker trước khi kết; liệt kê minor cho user.

---

## 11. Commit (2 commit + WBS)

**Commit 1** — contract + test:
```
test(parity): game-picker state-composition gate (default/not-enough) + curated states.json

- curate tool/parity/contracts/game-picker.states.json (2 gated states; scope-dropdown + loading coverage gaps)
- add test/presentation/features/game/game_picker_states_test.dart (Template B, copy dashboard_states_test)
- remove consumed skeletons (game-picker.states.skeleton.json, game-picker.slots.skeleton.json)
- game-picker.slots.json intentionally skipped (scope=DropdownButton, add-cards=MxButton; no keyed text slot)

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>
```

**Commit 2** — docs/ledger + queue:
```
docs(parity): game-picker divergences → intent-ledger; mark game-picker done in kit-to-flutter queue

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>
```

**WBS** (bắt buộc, `CLAUDE.md` §WBS — Commit Traceability Log §10 của
`docs/project-management/wbs.md`, newest first):
`<8-char hash> · <YYYY-MM-DD> · W5,W14 · game-picker kit→flutter state-composition parity (Template B; default+not-enough gated; scope-dropdown/loading coverage gap; scope=Dropdown + not-enough<4 → intent-ledger)`.
W5 đã Done — task này KHÔNG đổi task breakdown ⇒ report ghi `WBS update: not needed — parity-only, W5 already Done` (nhưng Commit Traceability Log VẪN append vì advance parity WP).

---

## 12. Final report format

```
## game-picker — kit→flutter DONE
- Template: B (state-composition) — lý do: game-picker/scope gen=MxCard nhưng FE key trên DropdownButton (không MxCard render) → Template A gate rỗng; state phân biệt bằng tập control.
- Gate-able keyed node (FE): scope (DropdownButton), add-cards (MxButton) [+ chrome screen/appbar loại khỏi gate] — 4 keyed tổng, 2 state-driven
- Gated states: default (≥1 card → scope), not-enough (0 card → add-cards)  [2]
- Coverage gap: scope-dropdown (Material dropdown overlay, item không keyed — kit là bottom-sheet scope-*), loading (async đầu, không keyed body node)  [2]
- Divergences → intent-ledger: scope=DropdownButton vs MxCard/sheet (styleExempt đã có), scope-* sheet items (dropdown menu vs sheet), not-enough count==0 + Center layout vs kit ActionCallout <4, game rows key động gamePick-<type> vs literal
- Identity-rollout gap (chưa key FE): game-matching/mc/recall/typing (ListTile key động), scope-scrim/sheet/srs/all/unlearned, not-enough container, back, words-hint
- slots.json: BỎ QUA (scope=Dropdown, add-cards=MxButton — không keyed text slot). Skeletons deleted: 2
- l10n: gameTitle/gameScope*/gameWordsHint/game*Desc/gameNotEnoughTitle/deckAddWord đã có ở app_en.arb + app_vi.arb  [no new keys | new keys: ...]
- Docs updated: <list | none — parity-only (chỉ intent-ledger)>
- WBS: not needed — parity-only, W5 already Done; Commit Traceability Log appended
- Verify: node tool/verify/run.mjs --full → PASS
- Subagent review: <blockers fixed | minor findings ...>
```
```
