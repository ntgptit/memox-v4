# Kit → Flutter conversion prompt — **game-typing**

> SELF-CONTAINED. Đọc hết file này rồi thực thi tuần tự. Không cần đọc file prompt nào khác.
> Nhiệm vụ: đóng **state-composition parity gate** cho màn `game-typing` (KHÔNG vẽ lại UI —
> UI đã có sẵn; việc ở đây là **curate contract + viết 1 test composition** theo Template B,
> + align identity ValueKey cho đúng, + đẩy divergence vào intent-ledger).
> Nếu gặp DRIFT (spec ↔ FE mâu thuẫn về HÀNH VI) cần người quyết → DỪNG, báo theo mẫu
> `DRIFT DETECTED` trong `CLAUDE.md`, chờ.

---

## PROMPT ID

`kit-to-flutter/game-typing` · screen `game-typing` · feature `game` · 6 kit states
(`waiting` / `typing` / `hint` / `correct` / `wrong` / `complete`).

FE **SHARED**: `lib/presentation/features/game/screens/game_screen.dart` (khung dùng chung cho cả 4
game: matching / mc / recall / typing — chọn body theo `request.type`).
Body typing: `lib/presentation/features/game/widgets/typing_game.dart`.

> ⚠ `game_screen.dart` là màn CHUNG. `screen`/`appbar` key được chọn theo `request.type`
> (`_screenKey` / `_appbarKey`, dòng 132–144). Với typing chúng resolve về
> `mx-node:game-typing/screen` + `mx-node:game-typing/appbar`. KHÔNG đổi khung chung khi
> chỉ làm typing — đụng khung là đụng 3 game còn lại. Body-node keyed nằm trong `typing_game.dart`.

---

## Baseline

```bash
git checkout main
git pull --ff-only
git checkout -b claude/kit-to-flutter-game-typing
```

Không bắt đầu khi working tree bẩn. Xác nhận `node tool/verify/run.mjs --quick` xanh trước khi sửa.

---

## Required reading (đọc trước khi code)

Universal (theo `CLAUDE.md`): `docs/_generated/repo-map.md`, `docs/_generated/where-is.md`,
`docs/business/index.md`, `docs/business/glossary.md`, `docs/contracts/error-contract.md`,
`docs/contracts/types-catalog.md`, `docs/contracts/code-style.md`.

Screen-specific — CHỈ đọc đúng các file này:
- `docs/design/MemoX Design System/ui_kits/memox-app/specs/game-typing.md` — token-resolved DOM,
  6 state (base `waiting` + 5 diff).
- `tool/parity/contracts/game-typing.gen.json` — 9 keyed node (key/component/variant). **KHÔNG sửa** (generated).
- `tool/parity/contracts/game-typing.slots.skeleton.json` — slot skeleton (superset) → curate/trim.
- `tool/parity/contracts/game-typing.states.skeleton.json` — per-state node membership (SUPERSET, phải trim).
- FE: `lib/presentation/features/game/screens/game_screen.dart` + `lib/presentation/features/game/widgets/typing_game.dart`.
- Hỗ trợ FE: `lib/presentation/features/game/round.dart` (RoundState/RoundActions),
  `lib/presentation/features/game/viewmodels/game_session_notifier.dart` (GameRequest / GameSessionState).
- **Reference test cần COPY (Template B):** `test/presentation/features/engagement/dashboard_states_test.dart`.
- Curated mẫu để bắt chước format: `tool/parity/contracts/dashboard.states.json` (+ `dashboard.slots.json`).
- Contrast (KHÔNG áp dụng ở đây — chỉ để hiểu VÌ SAO loại A): `test/presentation/features/study/review_parity_test.dart`
  (Template A, cần MxCard keyed thật).

**Drift check trước khi code:** typing là màn luyện tập (D-007: không đụng `srs_state`; D-015:
sai → re-queue trong ván). FE khớp (`game_session_notifier.dart` markWrong requeue, không schedule).
Nếu FE mâu thuẫn spec ở HÀNH VI (vd typing được ghi là đổi lịch SRS) → DỪNG, báo `DRIFT DETECTED`.
Ở đây spec = "luyện tập, sai re-queue, không schedule" và FE khớp → OK, tiếp tục. Task này là
**style/composition-parity**, KHÔNG phải feature — không thêm hành vi mới.

---

## CHOSEN template: **B — state-composition** (KHÔNG phải Template A)

**Vì sao B (đã xác minh, KHÔNG chỉ dựa gen.json):**

`game-typing.gen.json` có 1 node `mx-node:game-typing/meaning` = `MxCard` (variant `elevated`).
NHƯNG trong FE (`typing_game.dart:59–60`) node đó render bằng **`Card` của Material** (KHÔNG phải
`MxCard`), tuy có key `ValueKey('mx-node:game-typing/meaning')`:

```dart
Card(
  key: const ValueKey('mx-node:game-typing/meaning'),
  child: Padding( ... Text(current.meaning, style: bodySmall … textTertiary) … ),
)
```

Template A vòng `if (node['component'] != 'MxCard') continue;` rồi gọi `tester.widget<MxCard>(finder)`.
Vì widget dưới key này là `Card` **chứ không phải** `MxCard`, cast `widget<MxCard>()` sẽ **ném lỗi** →
Template A KHÔNG áp dụng được. FE có **0 `MxCard` widget keyed** ở màn này.

→ Đúng khuôn là **assert tập keyed node render CHÍNH XÁC theo từng state** (thừa = THỪA, thiếu =
THIẾU) — y hệt `dashboard_states_test.dart` (Template B). Đây cũng là lý do dùng B như màn `library`
(0 MxCard keyed thật).

> `meaning` = `Card` (không MxCard) là **divergence** → intent-ledger (mục Divergences). ĐỪNG tự ý
> đổi `Card` → `MxCard` trong prompt này (đó là thay đổi UI/kit-fit, ngoài scope style-composition;
> nếu muốn fix về kit thì là task riêng, cần parity check + không phá test game khác). Trừ khi
> Kit-is-source-of-truth buộc fix ngay → nếu chọn fix, phải: đổi sang `MxCard(variant: elevated)`,
> giữ nguyên key, cập nhật slots.json, và có thể NÂNG lên khả năng gate Template-A cho `meaning`.
> **Mặc định: giữ `Card`, ghi ledger, dùng B.** (Xem "Quyết định cần chốt" cuối file.)

---

## Gate-able node list (keyed trong FE — đã xác minh bằng grep)

Grep `mx-node:game-typing/` trong `lib/` cho ĐÚNG tập literal keyed sau (7 node):

| key | component (gen) | variant (gen) | FE thực (file:dòng) | render ở state |
| --- | --- | --- | --- | --- |
| `mx-node:game-typing/screen` | MxScaffold | null | `game_screen.dart:136` (khung chung) | mọi state (chrome) |
| `mx-node:game-typing/appbar` | MxAppBar | null | `game_screen.dart:143` (khung chung) | mọi state (chrome) |
| `mx-node:game-typing/meaning` | MxCard elevated | elevated | `typing_game.dart:60` — **`Card` (không MxCard)** | waiting/typing/hint/wrong (round đang chơi) |
| `mx-node:game-typing/hint` | MxButton ghost | ghost | `typing_game.dart:102` — `OutlinedButton` | waiting/typing/hint (nhánh `!_checkedWrong`) |
| `mx-node:game-typing/check` | MxButton primary | primary | `typing_game.dart:110` — `FilledButton` | waiting/typing/hint (nhánh `!_checkedWrong`) |
| `mx-node:game-typing/retry` | MxButton primary | primary | `typing_game.dart:122` — `OutlinedButton` | wrong (nhánh `_checkedWrong`) |
| `mx-node:game-typing/accept` | MxButton outline | outline | `typing_game.dart:133` — `FilledButton` | wrong (nhánh `_checkedWrong`) |

**Node phân biệt state thực sự** (chỗ gate bắt THỪA/THIẾU): `hint`+`check` (chỉ khi CHƯA sai)
vs `retry`+`accept` (chỉ khi ĐÃ sai). `meaning` có mặt ở cả 2 nhánh round-đang-chơi → không phân biệt
2 nhánh đó nhưng phân biệt với `complete`/`notEnough` (nơi nó absent).

**Node trong gen.json NHƯNG KHÔNG keyed ở FE (identity-rollout gap — KHÔNG ép rollout ở task này):**
- `mx-node:game-typing/next` — kit có ở state `correct` (nút Next) và `complete` (Next round). FE:
  ở `correct` KHÔNG có nút Next (markCorrect tự nhảy card kế — xem state-map); ở `complete`,
  `_complete()` render `MxButton` `gamePlayAgain` (key `Key('gamePlayAgain')`) + `gameDone` **KHÔNG**
  key `mx-node:game-typing/next`. → GAP.
- Kit `game-typing/input` (ô nhập) — FE là `TextField(key: Key('typingField'))` **KHÔNG** key
  `mx-node:game-typing/input`. → GAP (xem "keyboardType note").
- Kit `game-typing/progress` — FE render `LinearProgressIndicator` (game_screen.dart:55) **KHÔNG** key. → GAP.
- Kit `game-typing/back` / `game-typing/options` — appbar action; `MxAppBar` FE chưa expose,
  KHÔNG có trong FE. → GAP.
- Kit `game-typing/complete` (container empty-state hoàn thành) — FE `_complete()` là
  `MxContentBounds`/`Column` **KHÔNG** key. → GAP.

Liệt kê nguyên các gap này trong **final report** ("Identity-rollout gap"). KHÔNG rollout key mới
cho input/progress/next/complete trong task này (style-composition, không phải feature).

---

## Per-state node SET (curate cho `game-typing.states.json`)

Từ `game-typing.states.skeleton.json`, **trim** SUPERSET (bỏ chrome `screen`/`appbar` — không
state-driven, theo mẫu dashboard; bỏ node chưa keyed trong FE: `input`/`progress`/`back`/`options`/
`next`/`complete`) xuống tập BODY do state điều khiển mà FE THỰC render.

FE reach được **2 tập node-set body ổn định**: nhánh "đang trả lời" (chưa sai) và nhánh "vừa sai".
Đề xuất curate (chỉ node keyed FE, đã bỏ chrome):

```jsonc
{
  "waiting": ["mx-node:game-typing/meaning", "mx-node:game-typing/hint", "mx-node:game-typing/check"],
  "typing":  ["mx-node:game-typing/meaning", "mx-node:game-typing/hint", "mx-node:game-typing/check"],
  "hint":    ["mx-node:game-typing/meaning", "mx-node:game-typing/hint", "mx-node:game-typing/check"],
  "wrong":   ["mx-node:game-typing/meaning", "mx-node:game-typing/retry", "mx-node:game-typing/accept"]
}
```

> `waiting`/`typing`/`hint` = **cùng node-set** trong FE: gõ chữ (`typing`) chỉ đổi `_controller.text`
> (không đổi node keyed); bấm Help (`hint`) chỉ set `_showHint=true` → thêm 1 `Text` gợi ý **KHÔNG
> keyed**. Cả 3 giữ `meaning`+`hint`+`check`. Giữ đủ 3 key trong states.json cho documented, nhưng
> test chỉ **drive 1 lần** cho tập này (xem state-map) — 3 state không phân biệt ở tầng identity.
> `wrong` = tập phân biệt thật (`retry`+`accept`, `hint`/`check` biến mất).
> `correct` / `complete` = **coverage gap** (xem state-map) — KHÔNG đưa vào states.json làm state
> drive được, hoặc đưa vào kèm `$curated` note "documented, not driven". Ưu tiên bám mẫu review
> (list state không drive để đủ bộ) — nhưng KHÔNG assert chúng trong test nếu không reach sạch.

Thêm `$curated` header (bắt chước `dashboard.states.json`) giải thích: chrome loại khỏi gate;
waiting/typing/hint cùng node-set (typing/hint chỉ đổi text không-keyed); correct/complete là
coverage gap và lý do.

**Về `game-typing.slots.json`:** node keyed FE ở đây gồm 1 text-card (`meaning`) + các control
(button). `meaning` render `Text(current.meaning, bodySmall/textTertiary)` — là **user content**
(không l10n), và widget là `Card` chứ không `MxText` role-based ⇒ slot-role assert kiểu review
KHÔNG áp dụng (test B không vòng slot). → **BỎ QUA `game-typing.slots.json`** (ghi rõ lý do trong
report; KHÔNG tạo file rỗng). Nếu sau này `meaning` đổi sang `MxCard`+`MxText` thì mới thêm slots.

---

## State-map: state nào drive được / state nào là coverage gap

FE: `GameScreen(request: GameRequest(type: typing, …))` → `gameSessionProvider(request)` async.
`data` → nếu `state.isEmpty` = `_notEnough()`; nếu `state.isComplete` = `_complete()`; ngược lại
render `LinearProgressIndicator` + `TypingGame(round, actions)`. Trong `TypingGame`, `_checkedWrong`
điều khiển nhánh nút (false → hint/check; true → retry/accept); `_showHint` chỉ thêm Text gợi ý.

Pump pattern: **giống `dashboard_states_test.dart` / `review_parity_test.dart`** — seed Drift
in-memory (`languagePair` ko→vi + 1 `deck` + N `card`), override `databaseProvider` +
`clockProvider(_FixedClock)`, host `MaterialApp(home: Scaffold(body: GameScreen(request: …)))`,
rồi **pump vòng `for` 50ms** (KHÔNG `pumpAndSettle` — provider load async; `TextField autofocus`
có thể giữ frame; theo review dùng vòng pump). `GameRequest`: `nodeId: deckId`, `type: GameType.typing`,
`scope:` (dùng scope mặc định của game — kiểm `game_scope.dart`; chọn scope cho phép chọn thẻ luyện),
`random: false` để deterministic.

| kit state | drive được trong FE? | cách drive | node-set FE |
| --- | --- | --- | --- |
| `waiting` | ✅ | seed **≥1 card** → round đang chơi, `_checkedWrong=false` | `meaning`+`hint`+`check` |
| `typing` | ⚠️ = waiting | gõ vào `typingField` KHÔNG đổi node keyed | (= waiting) — coverage gap ở tầng identity |
| `hint` | ⚠️ = waiting | tap `mx-node:game-typing/hint` → chỉ thêm `Text` gợi ý (không keyed) | (= waiting) — coverage gap ở tầng identity |
| `wrong` | ✅ | seed ≥1 card → nhập sai → tap `check` → `_checkedWrong=true` | `meaning`+`retry`+`accept` |
| `correct` | ❌ coverage gap | markCorrect (nhập đúng → tap `check`, hoặc tap `accept`) **loại card khỏi pending** → hoặc nhảy card kế (= `waiting` lần nữa) hoặc round complete. Kit `correct` có nút `next` — FE KHÔNG có state trung gian "đã đúng, chờ Next"; không reach được node-set riêng. | — |
| `complete` | ⚠️/❌ | seed cards rồi trả đúng hết → `isComplete` → `_complete()`. Nhưng `_complete()` **KHÔNG có body node keyed** (`gamePlayAgain` dùng `Key('gamePlayAgain')`, không `mx-node:game-typing/*`). Không có keyed body node để gate ⇒ coverage gap cho tập này. | (không keyed node) |

→ **Gate 2 tập node-set:** `waiting` (đại diện cho waiting/typing/hint) và `wrong`.
**Coverage gap:** `typing`/`hint` (cùng node-set như waiting — chỉ đổi text không-keyed),
`correct` (không có node-set trung gian riêng trong FE), `complete` (không có keyed body node).

> Trong test, đủ để drive:
> - **`waiting`**: seed ≥1 card, pump → assert `meaning`+`hint`+`check` present, `retry`+`accept` absent.
> - **`wrong`**: seed ≥1 card, `enterText(find.byKey(Key('typingField')), 'sai')` → `tap(check)` →
>   pump → assert `meaning`+`retry`+`accept` present, `hint`+`check` absent.
> Universe = hợp của mọi tập trong states.json; với mỗi key: allowed → `findsOneWidget` (THIẾU nếu
> absent), ngoài allowed → `findsNothing` (THỪA nếu present). Chrome `screen`/`appbar` KHÔNG nằm
> trong universe (loại khỏi gate — theo mẫu dashboard).

> **keyboardType note (cho `game-typing/input`):** kit yêu cầu ô nhập term (spec state typing hiển
> thị ký tự Hàn "친"). FE `TextField` hiện KHÔNG set `keyboardType`. KHÔNG đổi trong task này (input
> chưa keyed, ngoài scope) — nhưng GHI nhận trong report: nếu sau này rollout `mx-node:game-typing/input`
> thì cân nhắc `keyboardType`/IME cho input đa ngôn ngữ (term có thể là ko/ja/zh). Không hardcode.

---

## Divergences → intent-ledger

Ghi các mục sau vào intent-ledger (`tool/parity/intent-ledger.json` — append, giữ format hiện có;
nếu chưa có mục `game-typing` → tạo entry theo cấu trúc các screen khác). **Không** ép FE về kit ở
các điểm này — chệch có chủ đích. Mỗi mục: `screen · node · kit-nói-gì · FE-làm-gì · lý do giữ`.

1. **`meaning` = `Card` (Material) không phải `MxCard`** — kit/gen `MxCard elevated`, FE render
   `Card` với key `mx-node:game-typing/meaning`. Lý do giữ: đây là body dùng chung của các game
   widget; đổi sang MxCard là thay đổi UI/kit-fit ngoài scope composition-parity. → INTENDED (task
   này), gate qua composition (present/absent), KHÔNG assert MxCard variant. Ledger reason:
   `"fe meaning = Material Card (not MxCard); composition-gated, MxCard-fit deferred"`.
2. **Control widget divergence** — kit map `hint`=MxButton ghost / `check`=MxButton primary /
   `retry`=MxButton primary / `accept`=MxButton outline; FE dùng `OutlinedButton`/`FilledButton`
   (Material) với đúng key. Lý do: game widget dùng button Material thô; identity đã đúng, variant
   chưa map sang `MxButton`. → GAP/INTENDED; composition gate không assert variant (Template B).
   Ledger reason: `"fe typing buttons = Material Outlined/Filled, not MxButton; identity keyed, variant deferred"`.
3. **`hint` exempt (per WBS)** — nút Help/hint được miễn kit-fit theo WBS (xác nhận dòng liên quan
   trong `docs/project-management/wbs.md` trước khi ghi). Ledger reason:
   `"hint button exempt from MxButton-fit per WBS"`. (Nếu WBS KHÔNG có exempt này → BỎ mục 3, chỉ giữ
   1+2, và note trong report rằng WBS không xác nhận exempt.)
4. **`next` / `complete` / `input` / `progress` chưa keyed** — có trong gen.json, không có ở FE. → GAP.
5. **`correct` không có node-set trung gian** — kit có state `correct` với nút `next`; FE markCorrect
   nhảy thẳng card kế / complete, không có màn "đã đúng chờ Next". → INTENDED (flow FE).

Nếu bất kỳ mục nào thực chất là **BUG** (không phải chủ ý) → **DỪNG**, báo mẫu `DRIFT DETECTED`,
chờ người. Không tự sửa UI trong prompt này.

---

## Workflow (thực thi tuần tự, mỗi bước một layer)

1. **Curate `tool/parity/contracts/game-typing.states.json`** từ skeleton: `waiting`/`typing`/`hint`
   (cùng node-set `meaning`+`hint`+`check`) + `wrong` (`meaning`+`retry`+`accept`); chỉ node keyed FE,
   bỏ chrome `screen`/`appbar`. Thêm `$curated` header giải thích waiting≡typing≡hint (text không
   keyed) + correct/complete coverage gap.
2. **`game-typing.slots.json`: BỎ QUA** — ghi lý do (không có keyed MxText role slot; `meaning` là
   Material Card + user content). Không tạo file rỗng.
3. **Align FE identity** — xác nhận 7 key đúng chính tả (grep đã confirm). KHÔNG hoist node-literal
   sau dynamic key; mỗi `ValueKey('mx-node:...')` là `const` gắn node tĩnh. KHÔNG đổi `Card`→`MxCard`,
   KHÔNG đổi Material button → MxButton (divergence → ledger, mặc định). KHÔNG thêm key mới cho
   input/progress/next/complete. KHÔNG hardcode màu/spacing/text-style/route/string.
4. **l10n**: các key dùng ở màn này (`gameTyping`, `gameTypingPlaceholder`, `gameHelp`, `gameCheck`,
   `gameRetry`, `gameAccept`, `gameAnswerWas`, `gameComplete`, `gamePlayAgain`, `gameDone`,
   `gameNotEnoughTitle`, `commonBack`) **đã có ở CẢ** `app_en.arb` **và** `app_vi.arb` (đã verify).
   KHÔNG copy MOCK COPY từ kit spec ("MEANING", "friend", "Type the Korean word…", "Round complete!"…)
   vào app/test. Nếu buộc phải thêm/đổi chuỗi user-facing → thêm vào **cả hai** ARB cùng commit rồi
   regen l10n (không sửa `lib/l10n/generated/**` tay). Kỳ vọng: **no new keys**.
5. **Viết test composition** `test/presentation/features/game/game_typing_states_test.dart`:
   COPY cấu trúc `dashboard_states_test.dart` — đọc `game-typing.states.json`, tính `universe`,
   `recipes`/seed cho từng state, pump `GameScreen(request: …)`, assert mỗi key trong universe
   (allowed → `findsOneWidget` = THIẾU nếu absent; ngoài allowed → `findsNothing` = THỪA nếu present).
   - seed: `languagePair(ko→vi)` + 1 `deck` + N `card` (term `'학교'`) — pattern như review/dashboard test.
   - `GameRequest(nodeId: deckId, type: GameType.typing, scope: <scope hợp lệ>, random: false)`.
   - pump vòng `for` 50ms (KHÔNG `pumpAndSettle`).
   - **`waiting`**: seed ≥1 card → assert node-set waiting.
   - **`wrong`**: seed ≥1 card → `enterText(find.byKey(const Key('typingField')), 'sai')` →
     `tap(find.byKey(const ValueKey('mx-node:game-typing/check')))` → pump → assert node-set wrong.
   - Header test giải thích rõ typing/hint/correct/complete là coverage gap (giống review_parity_test
     giải thích state không map).
6. **Xóa skeleton** đã tiêu thụ: `game-typing.states.skeleton.json` **và** `game-typing.slots.skeleton.json`
   (AUTO-PROPOSED, không ship — theo ghi chú `$skeleton`).
7. **Cập nhật queue**: đổi ô `[ ] <NN>-game-typing.md` → `[x]` trong `docs/agent/kit-to-flutter/README.md`.
8. **Doc parity**: task thuần style/composition-parity ⇒ nhiều khả năng không đổi business/design doc
   (chỉ intent-ledger). Nếu chạm hành vi user-visible → update doc tương ứng cùng commit. Xác nhận rồi
   ghi rõ trong report.

---

## Hard rules (vi phạm = fail — trích `CLAUDE.md`)

- KHÔNG vẽ lại/di chuyển UI trong prompt này; chỉ curate contract + align identity + viết test.
  Divergence → ledger, không tự sửa (đặc biệt: KHÔNG đổi `Card`→`MxCard`, KHÔNG đổi Material button →
  MxButton trừ khi có quyết định riêng — xem "Quyết định cần chốt").
- KHÔNG đụng khung chung `game_screen.dart` theo cách ảnh hưởng matching/mc/recall (màn SHARED).
- KHÔNG hardcode route/màu/text-style/duration/string; string lấy từ ARB (`lib/l10n/`).
- KHÔNG copy MOCK COPY từ kit spec vào app/test làm assert văn bản.
- KHÔNG ship skeleton làm curated; phải trim rồi xóa 2 skeleton.
- KHÔNG bịa state nếu không drive được sạch (`correct`/`complete`) → hạ xuống coverage gap, báo rõ.
- KHÔNG rollout key mới cho input/progress/next/complete (ngoài scope) trừ khi thêm hành vi thật.
- KHÔNG sửa generated (`*.g.dart`, `*.freezed.dart`, `game-typing.gen.json`, `lib/l10n/generated/**`,
  `docs/_generated/**`).
- KHÔNG thêm dependency mới (Stop & ask nếu cần).
- KHÔNG đổi hành vi SRS (D-007: game không đụng `srs_state`; D-015: sai re-queue).
- KHÔNG đánh dấu done nếu `node tool/verify/run.mjs --full` chưa xanh.

---

## Verification

```bash
node tool/verify/run.mjs --full
```

Phải XANH (ghi pass-marker mà pre-commit hook yêu cầu; gồm test parity mới + freshness check của
specs). Nếu đỏ hoặc bị skip → KHÔNG được báo done. Trong lúc dev có thể `--quick` (không marker).
Chạy riêng để chắc: `flutter test test/presentation/features/game/game_typing_states_test.dart`.

Sau khi verify PASS, TRƯỚC final report: fan-out song song `code-reviewer` (review working-tree diff:
cho nó chạy `git add -N .` rồi `git diff`) + `docs-drift-detector`. Gộp kết quả vào mục
"Subagent review"; sửa blocker trước khi kết, liệt kê minor findings.

---

## Commit (2 commit + WBS)

**Commit 1** — contract + test + identity align:
```
test(parity): game-typing state-composition gate (waiting/wrong) + curated states.json

- curate tool/parity/contracts/game-typing.states.json (2 gated node-sets; typing/hint/correct/complete coverage gaps documented)
- add test/presentation/features/game/game_typing_states_test.dart (Template B, copy dashboard_states_test)
- remove consumed skeletons (game-typing.states.skeleton.json, game-typing.slots.skeleton.json)
- game-typing.slots.json intentionally skipped (no keyed MxText role slot; meaning is Material Card + user content)

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>
```

**Commit 2** — docs/ledger + queue:
```
docs(parity): game-typing divergences → intent-ledger; mark game-typing done in kit-to-flutter queue

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>
```

**WBS** (bắt buộc, `CLAUDE.md` §WBS): append 1 dòng Commit Traceability Log (§10 của
`docs/project-management/wbs.md`), newest first:
`<8-char hash> · <YYYY-MM-DD> · <WBS IDs> · game-typing kit→flutter state-composition parity (waiting/wrong gated; typing/hint/correct/complete coverage gap; meaning-Card + Material-button + hint-exempt → intent-ledger)`.
Nếu WBS breakdown không bị ảnh hưởng, report ghi `WBS update: not needed — <reason>` (Commit
Traceability Log vẫn append nếu advance WP).

---

## Quyết định cần chốt (nếu Kit-is-source-of-truth buộc fix ngay)

Theo memory "Kit is source of truth", FE lệch kit ⇒ **fix về kit, đừng hỏi**. Nhưng ở đây có 2 lệch
lớn (`meaning` Card vs MxCard; button Material vs MxButton) chạm nhiều game (widget/khung chung) và
làm ĐỔI template (nếu fix `meaning`→MxCard thì có thể gate Template A). **Mặc định prompt này: giữ
divergence + ledger + Template B** (an toàn, đúng scope composition-parity). NẾU người dùng muốn fit
kit ngay: đó là task riêng (đổi `Card`→`MxCard elevated` + `OutlinedButton`/`FilledButton`→`MxButton`
đúng variant, thêm `game-typing.slots.json` cho `meaning`, có thể chuyển sang Template A cho `meaning`)
— phải qua parity check, không phá test 3 game còn lại, và ghi WBS. Hỏi trước khi mở rộng scope.

---

## Final report format

```
## game-typing — kit→flutter DONE
- Template: B (state-composition) — lý do: FE có 0 MxCard keyed thật (meaning = Material Card), giống library
- Gate-able keyed node (FE): meaning(Card), hint, check, retry, accept  [+ chrome screen/appbar loại khỏi gate]  [7 keyed / 5 body]
- Gated node-sets: waiting (meaning+hint+check), wrong (meaning+retry+accept)
- Coverage gap: typing & hint (cùng node-set như waiting — chỉ đổi text không keyed), correct (không có node-set trung gian), complete (không có keyed body node)
- Divergences → intent-ledger: meaning=Card(not MxCard), typing buttons=Material(not MxButton), hint exempt (WBS), next/input/progress/complete chưa keyed, correct không có state trung gian
- Identity-rollout gap (chưa key trong FE): game-typing/next, /input, /progress, /back, /options, /complete
- slots.json: BỎ QUA — không có keyed MxText role slot (lý do)
- l10n: gameTyping/gameTypingPlaceholder/gameHelp/gameCheck/gameRetry/gameAccept/gameAnswerWas/gameComplete/... đã có ở app_en.arb + app_vi.arb  [no new keys | new keys: ...]
- keyboardType note: input chưa keyed; nếu rollout /input cân nhắc keyboardType/IME đa ngôn ngữ
- Skeletons deleted: 2 (states + slots skeleton)
- Docs updated: <list | none — style/composition-parity only>
- WBS update: <line appended | not needed — reason>
- Verify: node tool/verify/run.mjs --full → PASS
- Subagent review: <blockers fixed | minor findings ...>
```
