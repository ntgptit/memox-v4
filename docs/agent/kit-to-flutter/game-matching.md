# Kit → Flutter conversion prompt — **game-matching**

> SELF-CONTAINED. Đọc hết file này rồi thực thi tuần tự. Không cần đọc file prompt nào khác.
> Nhiệm vụ: đóng **state-composition parity gate** cho màn `game-matching` (KHÔNG vẽ lại UI —
> UI đã có sẵn; việc ở đây là **curate contract + viết 1 test composition** theo Template B).
> Nếu gặp DRIFT hoặc DIVERGENCE cần người quyết → DỪNG, báo theo mẫu `DRIFT DETECTED` trong `CLAUDE.md`, chờ.

---

## PROMPT ID

`kit-to-flutter/game-matching` · screen `game-matching` · feature `game` · 6 kit states
(playing / selected / correct / wrong / almost / complete).

FE (QUAN TRỌNG — SHARED): màn game **dùng chung 1 scaffold** cho cả 4 game, chọn body theo `GameType`:
- Khung: `lib/presentation/features/game/screens/game_screen.dart` (`GameScreen(request)` — MxScaffold + MxAppBar + `LinearProgressIndicator` + complete/not-enough state; per-type ValueKey qua `switch`).
- Body matching: `lib/presentation/features/game/widgets/matching_game.dart` (`MatchingGame` — cột trái = meaning, cột phải = term; tile là OutlinedButton/FilledButton).
- Pump vào bằng `GameScreen(request: GameRequest(type: GameType.matching, ...))` + seed Drift.

---

## Baseline

```bash
git checkout main
git pull --ff-only
git checkout -b claude/kit-to-flutter-game-matching
```

Không bắt đầu khi working tree bẩn. Xác nhận `node tool/verify/run.mjs --quick` xanh trước khi sửa.

---

## Required reading (đọc trước khi code)

Universal (theo `CLAUDE.md`): `docs/_generated/repo-map.md`, `docs/_generated/where-is.md`,
`docs/business/index.md`, `docs/business/glossary.md`, `docs/contracts/error-contract.md`,
`docs/contracts/types-catalog.md`, `docs/contracts/code-style.md`.

Screen-specific — CHỈ đọc đúng các file này:
- `docs/design/MemoX Design System/ui_kits/memox-app/specs/game-matching.md` — token-resolved DOM, base `playing` + 5 diff state (selected / correct / wrong / almost / complete).
- `tool/parity/contracts/game-matching.gen.json` — 4 keyed node (key/component/variant). **Đã xác minh: 0 MxCard.** KHÔNG sửa (generated).
- `tool/parity/contracts/game-matching.slots.skeleton.json` — slot skeleton (superset; tile-text là 15/700 bodyMedium).
- `tool/parity/contracts/game-matching.states.skeleton.json` — per-state node membership (SUPERSET, phải trim).
- FE: `game_screen.dart` + `matching_game.dart` (đã đọc ở header). Grep `mx-node:game-matching/` để xác nhận key thực.
- Domain/VM (hiểu cách reach state): `lib/presentation/features/game/round.dart`, `lib/presentation/features/game/viewmodels/game_session_notifier.dart`.
- Test hiện có (dùng làm khuôn SEED/PUMP GameScreen): `test/presentation/features/game/game_session_test.dart` (seed languagePair ko→vi + deck + card + **cardMeaning** — matching cần cả term lẫn meaning).
- **Reference test cần COPY (Template B):** `test/presentation/features/engagement/dashboard_states_test.dart`.
- Curated mẫu để bắt chước format: `tool/parity/contracts/dashboard.states.json`, `tool/parity/contracts/dashboard.slots.json`.
- Contrast (KHÔNG áp dụng ở đây, chỉ để hiểu vì sao loại Template A): `test/presentation/features/study/review_parity_test.dart` + `tool/parity/contracts/review.states.json`.

**Drift check trước khi code:** matching là game luyện tập — D-007 (không đụng `srs_state`), D-015
(sai thì card ở lại trong round, `markWrong(requeue:false)` — không re-queue). Spec kit khớp FE
(`matching_game.dart` gọi `markWrong(left, requeue:false)`, `markCorrect` xoá pending). Nếu FE
mâu thuẫn spec về HÀNH VI (vd matching đổi schedule) → DỪNG, báo `DRIFT DETECTED`, chờ.

---

## CHOSEN template: **B — state-composition** (KHÔNG phải Template A)

**Vì sao B:** `game-matching.gen.json` có **0 node `MxCard`**. 4 node của nó là
`MxScaffold` (`game-matching/screen`), `MxAppBar` (`game-matching/appbar`),
`MxIconButton` (`game-matching/options`), `MxButton` primary (`game-matching/next`).
Các **tile** trong kit (`game-matching/left-0..4`, `right-0..4`) là node lưới `Tile` div —
trong FE render qua `OutlinedButton`/`FilledButton` với key **ĐỘNG** `Key('matchLeft-$id')` /
`Key('matchRight-$id')`, **KHÔNG** phải literal `mx-node:game-matching/left-N`.

→ Không có MxCard cố định để gate kiểu review (Template A vòng `if (node.component != 'MxCard') continue;`
sẽ không assert gì). Đúng khuôn là **assert tập keyed node render CHÍNH XÁC theo từng state**
(thừa = THỪA, thiếu = THIẾU) — y hệt `dashboard_states_test.dart`.

---

## Gate-able node list (keyed trong FE — đã xác minh bằng grep)

`grep -n "mx-node:game-matching/" lib/` chỉ ra ĐÚNG 2 literal keyed, cả hai trong `game_screen.dart`
(gắn qua `switch (type)` per-game, nên KHÔNG thể đổi tên cho riêng matching):

| key | component (gen) | variant | FE hiện tại | citation |
| --- | --- | --- | --- | --- |
| `mx-node:game-matching/screen` | MxScaffold | null | ✓ MxScaffold (`key: _screenKey(type)`) | `game_screen.dart:34,132-137` |
| `mx-node:game-matching/appbar` | MxAppBar | null | ✓ MxAppBar (`key: _appbarKey(type)`) | `game_screen.dart:36,139-144` |

Cả 2 đều là **chrome** (theo mẫu dashboard/review → **loại khỏi tập gate**, không state-driven).

### Node trong gen.json / states.skeleton NHƯNG chưa key literal trong FE → identity-rollout gap

- `mx-node:game-matching/next` — kit `MxButton` primary "Next round" chỉ ở state `complete`. FE render
  ở nhánh `_complete()` là 2 `MxButton` (`gamePlayAgain` outline + `gameDone`), trong đó chỉ `gamePlayAgain`
  có `Key('gamePlayAgain')` (không phải `mx-node:` literal) và `gameDone` KHÔNG key (`game_screen.dart:112-123`). → gap (khác cả identity lẫn label vs kit "Next round").
- `mx-node:game-matching/options` — kit MxIconButton (appbar more_horiz). FE `MxAppBar` KHÔNG expose action này ⇒ không tồn tại trong FE. → gap.
- `mx-node:game-matching/back` — kit icon-button arrow_back (trong states.skeleton). FE `MxAppBar` back mặc định, KHÔNG key literal `mx-node:`. → gap.
- `mx-node:game-matching/progress` — kit là dải progress-bar. FE render `LinearProgressIndicator(value: state.progress)` KHÔNG key (`game_screen.dart:55`). → gap (widget khác + không identity).
- `mx-node:game-matching/complete` — kit là container complete (icon celebration + "Round complete!" + Next). FE render `_complete()` bọc `MxContentBounds` KHÔNG key literal (`game_screen.dart:92-128`). → gap.
- `mx-node:game-matching/left-0..4`, `right-0..4` — tile; FE key ĐỘNG `matchLeft-$id`/`matchRight-$id` (`matching_game.dart:81,95`). → **không thể** gate literal (key phụ thuộc id runtime). → gap (dynamic-key, xem "Identity-rollout note").

Liệt kê nguyên các gap này trong **final report** (mục "Identity-rollout gap"). **KHÔNG** rollout key
`mx-node:game-matching/*` mới cho các node sống trong `game_screen.dart` (progress/complete/next/back/options):
chúng SHARED cho cả 4 game qua switch — gắn 1 literal `game-matching/...` cứng ở đó sẽ **sai** cho
game-mc/recall/typing. Đây là task style-parity, không phải feature/refactor shared scaffold.

---

## Per-state node SET (curate cho `game-matching.states.json`)

Từ `game-matching.states.skeleton.json`, **trim** SUPERSET (bỏ chrome `screen`/`appbar`/`back`/`options`,
bỏ tile dynamic-key, bỏ node chưa keyed trong FE) xuống tập BODY do state điều khiển mà FE THỰC render bằng
**literal keyed node**. Vấn đề cốt lõi ở màn này: sau khi loại chrome + dynamic-key + chưa-rollout, **hầu như
không còn literal keyed body node nào phân biệt state** — đây chính là coverage gap lớn của game-matching,
phải ghi thẳng.

**6 kit state ánh xạ vào FE như sau:**

| kit state | bản chất | FE reach được? (bằng keyed literal) |
| --- | --- | --- |
| `playing` | lưới tile, chưa chọn gì | tile là dynamic-key → **không có literal body node** |
| `selected` | 1 tile được chọn (border primary) | chỉ đổi `OutlinedButton`→`FilledButton` của tile dynamic-key → không literal |
| `correct` | cặp đúng → success-soft, progress tăng | tile biến mất (pending giảm) — dynamic-key |
| `wrong` | cặp sai → error-soft | tile ở lại (D-015) — dynamic-key |
| `almost` | còn ít cặp (lưới rút gọn) | vẫn tile dynamic-key |
| `complete` | container celebration + Next | `_complete()` (MxContentBounds) — **chưa key literal** |

→ `playing/selected/correct/wrong/almost` **KHÔNG có literal keyed body node phân biệt** (toàn tile dynamic-key)
⇒ **coverage gap ở tầng state-composition**. `complete` có nội dung phân biệt rõ (không còn lưới, có celebration+Next)
NHƯNG hiện chưa key literal ⇒ cũng gap trừ khi rollout 1 key.

**Quyết định (2 lựa chọn — ghi rõ lựa chọn đã chọn vào report):**

- **(A) Mặc định — không rollout, gate rỗng/tối thiểu:** curate `game-matching.states.json` với 6 state
  nhưng đánh dấu TẤT CẢ là coverage gap (không có node literal phân biệt). Trong trường hợp này test
  composition **không có node body nào để assert** ⇒ **KHÔNG viết test composition rỗng vô nghĩa**; thay vào đó
  viết 1 test tối thiểu chỉ khẳng định chrome (`screen`+`appbar`) hiện ở `playing` và `complete` (2 nhánh khác thân),
  và ghi rõ toàn bộ 6 state là coverage gap ở header test. Đây là kết quả HỢP LỆ cho màn dynamic-key + shared-scaffold.

- **(B) Rollout tối thiểu 1 literal cho `complete`** (khuyến nghị nếu muốn có ≥1 node phân biệt state):
  đây là node DUY NHẤT chỉ thuộc matching-complete và không đụng 3 game kia **nếu** đặt key ở body-branch
  theo `GameType`. NHƯNG `_complete()` nằm trong `game_screen.dart` shared → phải key qua `switch(type)`
  giống `_screenKey`/`_appbarKey` (thêm helper `_completeKey(type)` trả `ValueKey('mx-node:game-matching/complete')`
  cho matching và key tương ứng cho 3 game kia — **đúng pattern hiện có**, không phá game khác). Khi đó
  `game-matching.states.json`: `complete → ["mx-node:game-matching/complete"]`, các state còn lại = gap.
  Test: seed 0 pending-after-correct để đẩy tới `isComplete` → assert `complete` present ở `complete`,
  absent ở `playing`. Nếu chọn (B) phải: cập nhật CẢ 4 game key (mc/recall/typing dùng key riêng của chúng),
  qua parity check, không phá test game khác.

> Khuyến nghị: chọn **(B)** cho `complete` (đúng pattern per-type key đã có, chi phí thấp, cho gate 1 node thật);
> giữ `playing/selected/correct/wrong/almost` = coverage gap (tile dynamic-key). Nếu (B) đụng test khác /
> phá game kia → hạ về (A) và báo rõ.

**Không có `game-matching.slots.json`:** keyed node còn lại là chrome + (nếu B) `complete` container;
tile-text (term/meaning) sống trong tile **dynamic-key** → không gate qua slots ở màn này (giống library
deck-tile). → **BỎ QUA** `game-matching.slots.json` (ghi rõ lý do trong report; không tạo file rỗng).
Nếu chọn (B), có thể thêm 1 slot cho `complete` (title role `title/headline` + Next label) — tùy chọn, không bắt buộc.

---

## State-map: state nào drive được / state nào là coverage gap

Pump pattern (giống `dashboard_states_test.dart` cho pump + `game_session_test.dart` cho seed):
seed Drift in-memory — `languagePair(ko→vi)` + `deck` + N `card` **kèm `cardMeaning`** (matching cần
term **và** meaning) — override `databaseProvider` + `clockProvider(_FixedClock)`, `pumpWidget(host)` với
`home: Scaffold(body: GameScreen(request: GameRequest(nodeId: deckId, type: GameType.matching, scope: GameScope.all, random: false)))`,
rồi `pumpAndSettle` (GameScreen dùng `async.when`; nhánh data không spin vô hạn). Dùng `random:false` để deterministic.

| kit state | drive được (keyed literal)? | cách drive | node-set gate |
| --- | --- | --- | --- |
| `playing` | ⚠ chỉ chrome | seed ≥2 card có meaning → `MatchingGame` render lưới | chỉ `screen`/`appbar` (chrome) — **coverage gap** cho body (tile dynamic-key) |
| `selected` | ✗ | tap 1 tile → `OutlinedButton`→`FilledButton`, **cùng node-set**, key động | **coverage gap** (không đổi identity literal) |
| `correct` | ✗ | tap left+right cùng id → `markCorrect`, tile biến mất | **coverage gap** (dynamic-key) |
| `wrong` | ✗ | tap left+right khác id → `markWrong(requeue:false)`, tile ở lại | **coverage gap** (dynamic-key) |
| `almost` | ✗ | ghép hết trừ vài cặp → lưới rút gọn | **coverage gap** (dynamic-key) |
| `complete` | ✓ (nếu chọn B) | ghép đúng HẾT cặp → `state.isComplete` → `_complete()`; hoặc seed rồi markCorrect toàn bộ qua notifier | (B): `["mx-node:game-matching/complete"]`; (A): coverage gap |

→ **Gate:** (B) 1 state `complete` + assert absent ở `playing`; (A) 0 body state (chỉ chrome smoke).
**5 state `playing/selected/correct/wrong/almost` là coverage gap** (tile dynamic-key — identity không phân biệt
được ở tầng literal). Ghi thẳng trong header test (giống review_parity_test giải thích state không map) và intent-ledger.

> Nếu khi code phát hiện KHÔNG đẩy được FE tới `complete` sạch (vd BuildGameRoundUseCase random/scope làm
> pending không rỗng) → dùng `random:false` + markCorrect từng cardId qua `gameSessionProvider(request).notifier`
> để ép `isComplete`. Nếu vẫn không sạch → hạ về (A), báo rõ. ĐỪNG viết test giả chỉ để có `complete`.

---

## Divergences → intent-ledger

Ghi các mục sau vào `tool/parity/intent-ledger.json` (append, giữ format hiện có; nếu chưa có mục
`game-matching` → tạo entry theo cấu trúc các screen khác). Mỗi mục: `screen · node · kit-nói-gì ·
FE-làm-gì · lý do giữ`. **KHÔNG** sửa FE để khớp kit ở các điểm này — chệch có chủ đích:

1. **Tile = OutlinedButton/FilledButton, key động** — kit `left-N`/`right-N` là `Tile` div literal-keyed;
   FE dùng `OutlinedButton`(unselected)/`FilledButton`(selected) với `Key('matchLeft-$id')`/`matchRight-$id`
   (`matching_game.dart:81,95,116-127`). → INTENDED (lưới động theo cardId; selected↔unselected đổi widget
   thay border). Ledger reason: `"tiles are dynamic-keyed match{Left,Right}-<id>, not literal mx-node tiles; selected = FilledButton"`.
2. **Feedback correct/wrong không có node-set riêng** — kit đổi màu tile (success-soft / error-soft) tại chỗ;
   FE: đúng → tile biến mất (pending giảm, D-015 xoá card), sai → tile ở lại (`markWrong(requeue:false)`),
   KHÔNG có node feedback riêng biệt. → INTENDED. Ledger reason: `"correct removes tile, wrong keeps tile (D-015); no separate feedback node"`.
3. **`next` (complete) khác label/identity** — kit MxButton primary "Next round"; FE `_complete()` render
   `gamePlayAgain`(outline) + `gameDone`(default), label từ ARB. → INTENDED (FE có 2 hành động end-round).
   Ledger reason: `"complete shows gamePlayAgain(outline)+gameDone, not a single 'Next round' primary"`.
4. **`options` / `back` appbar-action** — kit có more_horiz + arrow_back keyed; FE `MxAppBar` chỉ có back mặc định
   (không key literal), không có options. → GAP (chưa rollout), không phải màn này giải quyết.
5. **`progress`** — kit dải progress div; FE `LinearProgressIndicator` không key. → INTENDED (widget chuẩn), gap identity.
6. **Shared scaffold** — `game-matching/screen`+`appbar`(+`complete` nếu B) sống trong `GameScreen` dùng chung
   4 game qua `switch(type)`; identity per-type gắn ở đó. → INTENDED (1 scaffold, 4 identity).

Nếu bất kỳ mục nào thực chất là **BUG** (không phải chủ ý) → **DỪNG**, báo `DRIFT DETECTED` (`CLAUDE.md`),
chờ người. Không tự sửa UI trong prompt này. Sau khi ghi ledger, các divergence này **KHÔNG** được làm fail parity test.

---

## Identity-rollout note (tiles + shared scaffold)

- **Tiles (dynamic-key):** `matching_game.dart` render tile qua `Key('matchLeft-$id')`/`Key('matchRight-$id')`
  — key phụ thuộc cardId runtime ⇒ **không thể** gate literal `mx-node:game-matching/left-N`. Mặc định **chấp nhận gap**
  (danh sách động; phủ hành vi tap/correct/wrong qua game test riêng nếu cần). Không ép literal key cho tile trong task này.
- **Shared scaffold:** progress/complete/next/back/options nằm trong `game_screen.dart` dùng chung 4 game. Chỉ rollout
  literal `mx-node:game-matching/*` khi key đi qua `switch(type)` như `_screenKey`/`_appbarKey` (an toàn cho 3 game kia).
  Task này chỉ (tùy chọn B) thêm `_completeKey(type)`; KHÔNG thêm key khác.

---

## Workflow (thực thi tuần tự)

1. **Chọn (A) hay (B)** cho `complete` (mục Per-state SET). Khuyến nghị (B). Ghi lựa chọn vào report.
2. **(Nếu B) Align FE** `game_screen.dart`: thêm helper `_completeKey(GameType)` (giống `_screenKey`) trả
   `ValueKey('mx-node:game-matching/complete')` cho matching (+ key per-type cho mc/recall/typing) và gắn vào
   widget gốc của `_complete()` (bọc `MxContentBounds`/`Column` bằng `KeyedSubtree`/gán `key:`). KHÔNG hardcode
   màu/spacing/string; KHÔNG hoist node-literal sau dynamic key. KHÔNG đổi hành vi game.
3. **Curate `tool/parity/contracts/game-matching.states.json`** từ skeleton:
   - (B): `{ "complete": ["mx-node:game-matching/complete"], "playing": [], "selected": [], "correct": [], "wrong": [], "almost": [] }`
     — 5 state rỗng = coverage gap (tile dynamic-key), 1 state gate thật.
   - (A): tất cả state rỗng/coverage-gap; ghi rõ không có literal body node.
   - Thêm `$curated` header (bắt chước `dashboard.states.json`) giải thích: chrome loại khỏi gate; 5 state
     playing/selected/correct/wrong/almost là coverage gap do tile dynamic-key; complete gate (B) / gap (A).
4. **`game-matching.slots.json`: BỎ QUA** — ghi lý do (keyed node là chrome + complete-container; tile-text là key động).
   Không tạo file rỗng.
5. **Viết test composition** `test/presentation/features/game/game_matching_states_test.dart`:
   COPY cấu trúc `dashboard_states_test.dart` (đọc `game-matching.states.json`, tính `universe`, `recipes`
   seed cho từng state, pump `GameScreen(request matching)`, assert mỗi key trong universe: allowed →
   `findsOneWidget` (THIẾU nếu absent), ngoài allowed → `findsNothing` (THỪA nếu present)).
   - Seed theo `game_session_test.dart`: `languagePair` ko→vi + `deck` + N `card` **+ `cardMeaning`** (bắt buộc — matching cần meaning).
   - `random:false`, `scope: GameScope.all`.
   - `recipes`: (B) `playing` = seed ≥2 card, không tương tác; `complete` = seed rồi markCorrect hết qua
     `container.read(gameSessionProvider(request).notifier)` HOẶC tap ghép hết cặp rồi `pumpAndSettle`.
   - Header test giải thích rõ 5 state coverage gap (giống review_parity_test giải thích state không map).
   - (A): test tối thiểu khẳng định chrome hiện ở `playing`/`complete`; nêu toàn bộ 6 state là gap.
6. **Xóa skeleton** đã tiêu thụ: `game-matching.states.skeleton.json` **và** `game-matching.slots.skeleton.json`
   (AUTO-PROPOSED, không ship — theo ghi chú `$skeleton`).
7. **l10n**: `gameMatching`, `gameComplete`, `gamePlayAgain`, `gameDone`, `gameNotEnoughTitle`, `commonBack`
   đã có **cả** `app_en.arb` và `app_vi.arb` (đã verify). Nếu bạn thêm/đổi bất kỳ chuỗi user-facing nào →
   thêm vào **cả hai** ARB cùng lúc rồi regen; không copy mock copy từ kit ("Matching", "Round complete!",
   "Next round", "time/love/사랑"…) vào app/test. String luôn từ ARB.
8. **Cập nhật queue**: đổi ô `game-matching` → `[x]` trong `docs/agent/kit-to-flutter/README.md`.
9. **Doc parity**: task thuần style-parity ⇒ nhiều khả năng không đổi business doc; nếu (B) đổi FE có
   ValueKey mới nhưng không đổi behavior user-visible/route → thường chỉ cần intent-ledger + WBS trace.
   Nếu chạm behavior đã ghi ở `docs/business/**` hoặc `docs/design/**` → update cùng commit.

---

## Hard rules (vi phạm = fail — trích `CLAUDE.md`)

- KHÔNG vẽ lại/di chuyển UI; chỉ curate contract + viết test (+ tùy chọn B: thêm 1 ValueKey per-type cho complete). Divergence → ledger, không tự sửa.
- **Token-only**: KHÔNG hardcode màu, radius, spacing, text style, duration, chuỗi user-facing. Dùng `Mx*` widget + theme token + `MxSpacing`.
- **Không node-literal hoist sau dynamic key**: mỗi `ValueKey('mx-node:...')` phải `const`, gắn node tĩnh; không sinh key theo index/state/id.
- KHÔNG copy MOCK COPY từ kit spec vào app/test làm assert văn bản; string từ ARB (`lib/l10n/`).
- KHÔNG ship skeleton làm curated; phải trim rồi xóa 2 skeleton.
- KHÔNG bịa state nếu không drive được sạch → hạ xuống coverage gap và báo.
- Nếu chọn (B) rollout key `game-matching/complete`: PHẢI đi qua `switch(type)` (an toàn cho mc/recall/typing), KHÔNG gắn cứng 1 key cho cả 4 game.
- KHÔNG đổi hành vi game (D-007 không đụng srs_state, D-015 wrong giữ card requeue:false).
- KHÔNG sửa generated (`*.g.dart`, `*.freezed.dart`, `game-matching.gen.json`, `lib/l10n/generated/**`, `docs/_generated/**`).
- KHÔNG thêm dependency mới (Stop & ask nếu cần).
- KHÔNG đánh dấu done nếu `node tool/verify/run.mjs --full` chưa xanh.

---

## Verification

```bash
node tool/verify/run.mjs --full
```

Phải XANH (ghi pass-marker mà pre-commit hook yêu cầu); gồm test parity mới + freshness check của specs.
Nếu đỏ hoặc bị skip → sửa, KHÔNG commit vòng qua / KHÔNG báo done. Trong lúc dev có thể `--quick` (không marker).
Chạy riêng test mới để chắc: `flutter test test/presentation/features/game/game_matching_states_test.dart`.

Sau khi verify PASS, TRƯỚC final report: fan-out song song `code-reviewer` (review working-tree diff —
cho nó `git add -N . && git diff`, không commit trước) + `docs-drift-detector`. Gộp kết quả vào mục
"Subagent review". Fix blocker trước khi kết; liệt kê minor cho user.

---

## Commit (2 commit + WBS)

**Commit 1** — impl (contract + test [+ FE key nếu B]):
```
test(parity): game-matching state-composition gate (complete gated; playing/selected/correct/wrong/almost = coverage gap)

- curate tool/parity/contracts/game-matching.states.json (Template B; complete gated [B], 5 states coverage gap — tiles dynamic-keyed)
- add test/presentation/features/game/game_matching_states_test.dart (copy dashboard_states_test; pump GameScreen matching)
- [B only] game_screen.dart: _completeKey(type) → ValueKey mx-node:game-matching/complete (per-type, safe for other games)
- remove consumed skeletons (game-matching.states.skeleton.json, game-matching.slots.skeleton.json)
- game-matching.slots.json intentionally skipped (keyed nodes are chrome/complete; tiles use dynamic key)

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>
```

**Commit 2** — docs/ledger + queue:
```
docs(parity): game-matching divergences → intent-ledger; mark game-matching done in kit-to-flutter queue

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>
```

**WBS** (bắt buộc, `CLAUDE.md` §WBS): thêm dòng Commit Traceability Log (§10 của
`docs/project-management/wbs.md`), newest first:
`<8-char hash> · 2026-07-01 · <WBS IDs> · game-matching kit→flutter state-composition parity (Template B; complete gated, 5 states coverage gap)`.
Nếu task breakdown không đổi, report ghi `WBS update: not needed — <reason>` (nhưng Commit Traceability Log vẫn append nếu advance WP).

---

## Final report (đưa vào tin nhắn cuối)

- Template: **B (state-composition)** — lý do: 0 MxCard trong `game-matching.gen.json`; tile là dynamic-key.
- Gate-able keyed node (FE): `screen`, `appbar` (chrome, loại khỏi gate) [+ `complete` nếu chọn B].
- Lựa chọn complete: **(A) gap** / **(B) rollout `game-matching/complete` per-type** — nêu rõ đã chọn cái nào + rủi ro.
- Gated states: (B) `complete`; (A) none (chỉ chrome smoke).
- Coverage gaps: `playing`, `selected`, `correct`, `wrong`, `almost` (tile dynamic-key) [+ `complete` nếu chọn A] — lý do từng cái.
- Identity-rollout gap (chưa key literal): tiles (`left/right-N` → `match{Left,Right}-<id>` động), `next`, `options`, `back`, `progress` [, `complete` nếu A].
- Divergences → intent-ledger (6 mục): tile dynamic-key/FilledButton, correct-removes/wrong-keeps, next label khác, options/back gap, progress widget, shared scaffold.
- `game-matching.slots.json`: intentionally skipped (lý do). Skeletons deleted: 2.
- l10n: gameMatching/gameComplete/gamePlayAgain/gameDone/gameNotEnoughTitle/commonBack đã có ở app_en.arb + app_vi.arb [no new keys | new keys: ...].
- Docs updated: <list | none — style-parity only>.
- `node tool/verify/run.mjs --full`: PASS/FAIL.
- Subagent review: <blockers fixed | minor findings ...>.
- WBS: dòng traceability đã append / hoặc "not needed — <reason>".
```
