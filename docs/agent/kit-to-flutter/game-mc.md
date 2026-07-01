# Kit → Flutter conversion prompt — **game-mc**

> SELF-CONTAINED. Đọc hết file này rồi thực thi tuần tự. Không cần đọc prompt nào khác.
> Nhiệm vụ: đóng **state-composition parity gate** cho màn `game-mc` (Multiple choice /
> "guess" game). KHÔNG vẽ lại UI — UI đã có; việc ở đây là **curate contract + viết 1 test
> composition** (Template B) + **align FE để keyed node có ValueKey ổn định**.
> Nếu gặp DRIFT hoặc DIVERGENCE cần người quyết → DỪNG, báo theo mẫu `DRIFT DETECTED` trong
> `CLAUDE.md`, chờ.

---

## PROMPT ID

`kit-to-flutter/game-mc` · screen `game-mc` · feature `game` · 4 kit states (waiting / correct / wrong / complete).
FE (SHARED game frame): `lib/presentation/features/game/screens/game_screen.dart`.
FE (mc body widget): `lib/presentation/features/game/widgets/multiple_choice_game.dart`.

> Lưu ý kiến trúc: `game-mc` KHÔNG có màn riêng. `GameScreen` là frame dùng chung cho cả 4 game
> (matching/mc/recall/typing); nó chọn body theo `GameType` và mang **per-type node identity**
> (`_screenKey` / `_appbarKey` switch theo type → `mx-node:game-mc/screen`, `mx-node:game-mc/appbar`
> khi `type == multipleChoice`). Body mc nằm trong `MultipleChoiceGame`. Complete/not-enough là
> nhánh dùng chung trong `GameScreen` (`_complete`, `_notEnough`) — KHÔNG mang key game-mc (xem gap).

---

## Baseline

```bash
git checkout main
git pull --ff-only
git checkout -b claude/kit-to-flutter-game-mc
```

Không bắt đầu khi working tree bẩn. Xác nhận `node tool/verify/run.mjs --quick` xanh trước khi sửa.

---

## Required reading (CHỈ đọc đúng các file này)

Universal (theo `CLAUDE.md`): `docs/_generated/repo-map.md`, `docs/_generated/where-is.md`,
`docs/business/index.md`, `docs/business/glossary.md`, `docs/contracts/error-contract.md`,
`docs/contracts/types-catalog.md`, `docs/contracts/code-style.md`.

Screen-specific:
- `docs/design/MemoX Design System/ui_kits/memox-app/specs/game-mc.md` — token-resolved DOM,
  4 state (base `waiting` + diff `correct` / `wrong` / `complete`).
- `tool/parity/contracts/game-mc.gen.json` — 7 keyed node (key/component/variant). **KHÔNG sửa** (generated).
- `tool/parity/contracts/game-mc.slots.skeleton.json` — slot skeleton (SUPERSET) → curate/trim.
- `tool/parity/contracts/game-mc.states.skeleton.json` — per-state membership (SUPERSET) → trim → `game-mc.states.json`.
- FE: `lib/presentation/features/game/screens/game_screen.dart` + `lib/presentation/features/game/widgets/multiple_choice_game.dart`.
- `lib/presentation/features/game/viewmodels/game_session_notifier.dart` + `lib/presentation/features/game/round.dart` —
  hiểu state machine (waiting/correct/wrong đều là **cùng node-set** trong FE; complete = nhánh riêng).
- Reference TEST để COPY (**Template B**): `test/presentation/features/engagement/dashboard_states_test.dart`.
- Reference seed/pump cho game: `test/presentation/features/game/game_session_test.dart` (cách seed card + meaning + open provider).
- Curated mẫu format: `tool/parity/contracts/dashboard.states.json`, `dashboard.slots.json`.
- Contrast (KHÔNG áp dụng — chỉ để hiểu vì sao loại Template A): `test/presentation/features/study/review_parity_test.dart`,
  `tool/parity/contracts/review.slots.json`, `review.states.json`.
- Ledger: `tool/parity/intent-ledger.json` (đã có sẵn mục `game-mc/next`, `game-mc/audio`, `game-mc/edit` ở
  `exceptions`, và `game-mc/options` ở `styleExempt`). Bổ sung nếu cần, KHÔNG trùng lặp.

**Drift check trước khi code:** game-mc là practice round — D-007 (KHÔNG chạm `srs_state`) + D-015
(sai thì re-queue trong vòng). FE `GameSessionNotifier` khớp (markWrong re-queue, không schedule). Nếu
phát hiện FE đổi lịch SRS hoặc màn có màn riêng khác frame chung → DỪNG, báo DRIFT. Ở đây spec khớp FE ⇒ tiếp tục.

---

## CHOSEN template: **B — state-composition** (KHÔNG phải Template A)

**Vì sao B (đọc kỹ — đây là điểm mấu chốt):**

`game-mc.gen.json` có đúng **1 node MxCard**: `mx-node:game-mc/prompt` (variant `elevated`, term card).
Điều kiện dùng Template A là node MxCard đó phải **thực sự là `MxCard` keyed** trong FE. Kiểm tra FE:

- `multiple_choice_game.dart:26` render prompt bằng **`Card`** (Material), KHÔNG phải `MxCard`
  (`key: const ValueKey('mx-node:game-mc/prompt')`). ⇒ Template A sẽ `tester.widget<MxCard>(finder)`
  và **không tìm thấy MxCard** → không assert được variant. **Đây là DIVERGENCE** (xem mục Divergences).
- Các đáp án (`choice-0..3`) trong kit là node keyed riêng; FE render chúng là `OutlinedButton` **KHÔNG key**
  bên trong 1 `Column` keyed `mx-node:game-mc/options` (`multiple_choice_game.dart:39`). ⇒ không có MxCard slot
  cố định để gate kiểu review; choices không phải node keyed literal.

→ Không đủ điều kiện Template A (không có MxCard keyed thực). Đúng khuôn là **assert TẬP keyed node
render CHÍNH XÁC theo từng state** (thừa = THỪA, thiếu = THIẾU) — y hệt `dashboard_states_test.dart`.

> KHÔNG cố ép prompt thành `MxCard` để chạy được Template A. Việc đổi `Card` → `MxCard` là 1 lựa chọn
> align hợp lệ (mục Workflow bước 3, tùy chọn), nhưng gate CHÍNH của prompt này là composition (B),
> không phải per-MxCard variant.

---

## Gate-able node list (keyed trong FE — đã xác minh bằng grep)

`grep mx-node:game-mc lib/` cho ĐÚNG 4 literal keyed:

| key | component (gen.json) | render trong FE | state có mặt |
| --- | --- | --- | --- |
| `mx-node:game-mc/screen` | MxScaffold | `game_screen.dart:134` `_screenKey(multipleChoice)` — MxScaffold | mọi state (chrome) |
| `mx-node:game-mc/appbar` | MxAppBar | `game_screen.dart:141` `_appbarKey(multipleChoice)` — MxAppBar | mọi state (chrome) |
| `mx-node:game-mc/prompt` | MxCard (elevated) | `multiple_choice_game.dart:26` — **`Card`** (không MxCard) | waiting/correct/wrong (body có current card) |
| `mx-node:game-mc/options` | (kit: nhóm choice) | `multiple_choice_game.dart:39` — `Column` bọc 4 `OutlinedButton` | waiting/correct/wrong |

> `screen` + `appbar` là **chrome** — theo mẫu dashboard/library/review, **loại khỏi tập gate**
> (không do state-body điều khiển; chúng luôn hiện). Tập gate BODY thực sự phân biệt state chỉ gồm
> `game-mc/prompt` + `game-mc/options` (hiện khi có `current` card, absent khi complete/not-enough).

**Node trong gen.json NHƯNG chưa keyed ở FE (identity-rollout gap):**

- `mx-node:game-mc/next` — kit là nút "Next round" ở complete-state. FE `_complete()` render `MxButton`
  (`gamePlayAgain` + `gameDone`) KHÔNG key `game-mc/next` (nhánh dùng chung mọi game). ⇒ gap +
  **đã có exception `game-mc/next` trong intent-ledger** ("auto-advance on answer, no manual next").
- `mx-node:game-mc/audio`, `mx-node:game-mc/edit` — icon-button trong prompt card. FE KHÔNG render
  (prompt chỉ là term display). ⇒ gap + **đã có exception cả 2 trong intent-ledger**.
- `mx-node:game-mc/progress` — kit là dải progress trong body. FE render `LinearProgressIndicator`
  (`game_screen.dart:55`) KHÔNG key `game-mc/progress`. ⇒ gap (khác widget lẫn identity).
- (`game-mc/choice-0..3` — kit node đáp án; FE là `OutlinedButton` không key, gộp trong `game-mc/options`.
  Không rollout literal per-choice key trong task này — danh sách động, ngoài scope.)

Liệt kê nguyên các gap này trong **final report** ("Identity-rollout gap"). KHÔNG rollout key mới cho
next/audio/edit/progress trong task này trừ khi bạn thêm hành vi thật — đây là task style/composition-parity,
không phải feature; và next/audio/edit **đã được ledger là INTENDED absence**, KHÔNG được thêm.

---

## Per-state node SET (curate cho `game-mc.states.json`)

Từ `game-mc.states.skeleton.json`, **trim** SUPERSET (bỏ chrome `screen`/`appbar`, bỏ node chưa keyed FE:
`audio`/`edit`/`next`/`progress`/`back`/`options`-kit-choices) xuống tập BODY keyed FE thực render.

Sự thật FE (đọc `game_screen.dart` + `multiple_choice_game.dart`):
- `waiting` / `correct` / `wrong` render **CÙNG node-set**: `prompt` + `options` (state chỉ đổi màu/icon
  feedback của từng `OutlinedButton`, KHÔNG đổi tập node keyed). ⇒ 3 kit-state này **không phân biệt được
  ở tầng identity** → gộp làm 1 tập "in-game", drive 1 đại diện (`waiting`), 2 cái kia = coverage gap documented.
- `complete` → nhánh `_complete()` trong `GameScreen` (dùng chung, KHÔNG key game-mc): `prompt` + `options`
  **absent**; nội dung complete KHÔNG mang keyed game-mc node ⇒ tập gate rỗng cho complete.

Tập gate đề xuất cho `game-mc.states.json` (chỉ node keyed BODY của FE):

```jsonc
{
  "waiting":  ["mx-node:game-mc/prompt", "mx-node:game-mc/options"],
  "correct":  ["mx-node:game-mc/prompt", "mx-node:game-mc/options"],
  "wrong":    ["mx-node:game-mc/prompt", "mx-node:game-mc/options"],
  "complete": []
}
```

`$curated` header (bắt chước `dashboard.states.json`) phải nêu rõ:
1. chrome `screen`/`appbar` loại khỏi gate (shell/frame, không state-driven);
2. `waiting`/`correct`/`wrong` là **cùng node-set** trong FE (feedback chỉ đổi màu/icon của choice, không
   đổi identity) → chỉ `waiting` được drive trong test; `correct`/`wrong` documented-not-driven coverage gap;
3. `complete` = tập rỗng: nhánh complete dùng chung không mang keyed game-mc node → test assert `prompt`+`options`
   **absent** ở complete (đó là chỗ gate bắt THỪA nếu body mc rò rỉ vào complete).

> Universe của test = hợp các tập = `{prompt, options}`. Ở `complete` cả hai phải `findsNothing` → chính
> đây là giá trị gate: nếu ai đó vô tình render body mc khi round xong, test đỏ.

**`game-mc.slots.json`:** node keyed FE ở đây là `prompt` (một khối term `Text`) và `options` (nhóm nút).
- `prompt` mang 1 slot text = `card.term` (role `displayLarge` theo FE `Theme.of(context).textTheme.displayLarge`,
  khớp skeleton `48/800`). `bind = card.term` (user content, KHÔNG l10n).
- Skeleton còn đề `choice-0..3` role `bodyMedium` — đó là kit choice node, FE không key riêng ⇒ KHÔNG đưa vào
  slots (text đáp án là user content `card.meaning`, không gate qua slot).

Curate **tối giản** (giống `review.slots.json`): chỉ giữ `game-mc/prompt` → `{ "name": "term", "role":
"displayLarge", "bind": "card.term" }`. `$curated` note giải thích: term=displayLarge (FE truth), options là
nhóm nút không có keyed text slot, scope = 1-card in-game.

> Nếu prompt vẫn là `Card` (không `MxCard`) và test B chỉ kiểm identity present/absent (không assert MxCard
> variant/role), thì `game-mc.slots.json` là **tùy chọn** (Template B không đọc slots như test A). Có thể ship
> slots tối giản cho hồ sơ đầy đủ, HOẶC bỏ qua và ghi lý do (như library bỏ slots). **Khuyến nghị: ship slots
> tối giản 1 node** để giữ đối xứng với các screen khác — nhưng KHÔNG bắt test B đọc nó.

---

## State-map: state nào drive được / state nào coverage gap

Pump pattern: dựa `dashboard_states_test.dart` (Template B) + seed theo `game_session_test.dart`
(insert `languagePair` + `deck` + N `card` kèm `cardMeaning`). Dựng `GameScreen(request: GameRequest(nodeId:
deckId, type: GameType.multipleChoice, scope: GameScope.all, random: false, wordsPerRound: N))` trong host
`ProviderScope` override `databaseProvider` + `clockProvider(_FixedClock)`. `GameSessionNotifier.build` load
async ⇒ **KHÔNG `pumpAndSettle` mù** (mc body có `MxStateView.loading` khi async pending) — dùng vòng `for`
pump 50ms như `review_parity_test.dart`, HOẶC `pumpAndSettle` được vì progress + body là determinate sau khi
data về (thử `pumpAndSettle`; nếu treo do loading spinner → chuyển sang vòng `for` pump).

| kit state | drive được trong FE? | cách drive | node-set FE |
| --- | --- | --- | --- |
| `waiting` | ✅ | seed **≥1 card có meaning** → `state.cards` non-empty, `pending` non-empty → nhánh body mc (`current != null`) | `prompt`, `options` |
| `correct` | ⚠️ documented-not-driven | Sau khi seed, gọi `markCorrect(current.cardId)` sẽ **advance/complete**, không có "correct-highlight" state riêng trong FE (không có post-answer feedback frame). Node-set = giống waiting cho tới khi pending rỗng. | (= waiting) coverage gap |
| `wrong` | ⚠️ documented-not-driven | `markWrong` re-queue card (D-015); FE KHÔNG render feedback highlight state riêng (không đổi node-set). | (= waiting) coverage gap |
| `complete` | ✅ | seed **1 card**, `markCorrect(cardId)` → `pending` rỗng → `state.isComplete` → nhánh `_complete()`; body mc (`prompt`/`options`) absent | `[]` (không keyed game-mc node) |

> `correct`/`wrong` trong kit là **post-answer visual feedback** (choice đổi `success-soft`/`error-soft` +
> icon check/cancel). FE hiện KHÔNG có frame feedback đó — chọn xong là advance ngay (D-015 auto-advance,
> đã ledger `game-mc/next`). Vì vậy chúng KHÔNG phải node-set phân biệt được ⇒ coverage gap (documented).
> Đây CHÍNH là divergence "answer options = ChoiceOption color+icon feedback" — ghi ledger (mục dưới).

**Gate 2 state:** `waiting` (in-game body) + `complete` (empty gate). **`correct`/`wrong` = coverage gap**
(cùng node-set với waiting; FE không có feedback frame) — ghi rõ trong `$curated` + header test + report.

> Nếu khi code, `complete` KHÔNG drive được sạch (vd markCorrect trong widget test cần tap thật): tap nút đáp
> án đúng (`OutlinedButton` có `Key('mcCorrect')` gắn ở `multiple_choice_game.dart:45` cho option ==
> current.meaning) rồi pump — 1 card → complete. ĐỪNG fake state; nếu không sạch, hạ complete xuống gap và báo.

---

## Divergences → `tool/parity/intent-ledger.json` (KHÔNG ép về kit)

Ledger đã có sẵn cho game-mc: `exceptions` `next`/`audio`/`edit`, `styleExempt` `options` (color+font).
**Bổ sung** các mục sau nếu chưa có (giữ format hiện tại; match theo `screen`+`node`; mỗi mục cần `source`).
KHÔNG sửa FE để khớp kit ở các điểm này — chệch có chủ đích:

1. `game-mc/prompt` — kit `MxCard` (elevated); FE render `Card` (Material) keyed. → `exceptions` hoặc
   `styleExempt` (field `*`): FE mc body dùng `Card` Material đơn giản cho khối term, chưa nâng lên `MxCard`
   design-system. Reason: `"fe prompt = Material Card (term display), not MxCard elevated"`.
   `source`: `docs/business/game/game-modes.md`. (Nếu bạn CHỌN align `Card`→`MxCard` ở bước Workflow 3 thì
   KHÔNG cần mục ledger này — thay vào đó cập nhật gate lên Template-A-lite; xem bước 3.)
2. `game-mc/options` — answer feedback: kit các đáp án là ChoiceOption đổi `success-soft`/`error-soft` +
   icon `check_circle`/`cancel` sau khi trả lời (state `correct`/`wrong`). FE render `OutlinedButton` thường,
   **không có post-answer color+icon feedback** (auto-advance ngay). → `styleExempt`/`exceptions` (đã có 1
   phần color+font ở styleExempt; thêm 1 dòng behavior nếu cần cho "no post-answer feedback frame").
   Reason: `"fe options auto-advance on tap, no correct/wrong highlight frame (D-015)"`.
   `source`: `docs/business/game/game-modes.md`.

Nếu bất kỳ mục nào thực chất là **BUG** (không phải chủ ý) → DỪNG, báo mẫu DRIFT, chờ người. Không tự sửa UI.

---

## Workflow (thực thi tuần tự, mỗi bước một layer)

1. **Curate `tool/parity/contracts/game-mc.states.json`** từ skeleton: 4 state như bảng mục "Per-state node
   SET" (`waiting`/`correct`/`wrong` = `[prompt, options]`; `complete` = `[]`). Bỏ chrome `screen`/`appbar`
   và mọi node chưa keyed FE. `$curated` header giải thích 3 điểm (chrome loại, correct/wrong cùng node-set
   = gap, complete rỗng).
2. **Curate `tool/parity/contracts/game-mc.slots.json`** tối giản: chỉ `game-mc/prompt` →
   `{ "name": "term", "role": "displayLarge", "bind": "card.term" }`. `$curated` note (term=displayLarge FE
   truth; options không có keyed text slot). (Tùy chọn bỏ qua như library — nếu bỏ, ghi rõ lý do, đừng tạo file rỗng.)
3. **Align FE** để keyed node có `ValueKey('mx-node:...')` ổn định, token-only:
   - Xác nhận 4 key hiện có đúng chính tả (grep đã confirm): `game-mc/screen`, `game-mc/appbar`,
     `game-mc/prompt`, `game-mc/options`. KHÔNG hoist node-literal sau dynamic key; key phải là `const` tĩnh.
   - `game-mc/prompt`: hiện là `Card`. **Hai lựa chọn — chọn 1, ghi rõ trong report:**
     - **(A) Giữ `Card`** (khuyến nghị cho prompt này — task là composition parity, không phải widget swap):
       gate B chỉ kiểm present/absent theo state, không assert MxCard variant. Ghi divergence `prompt` vào
       ledger (mục Divergences 1). KHÔNG đổi widget.
     - **(B) Đổi `Card` → `MxCard(variant: MxCardVariant.elevated)`** khớp gen.json: hợp lệ nếu muốn khép
       divergence prompt. Nếu chọn B, có thể thêm 1 vòng phụ trong test kiểu Template-A cho riêng `prompt`
       (assert variant elevated) — nhưng KHÔNG bắt buộc; gate chính vẫn B. Đổi widget dùng token, không hardcode.
   - `game-mc/options`: giữ `OutlinedButton` (đã ledger style + auto-advance). KHÔNG thêm color+icon feedback
     frame (đó là feature, ngoài scope; đã ledger là INTENDED).
   - Progress: FE `LinearProgressIndicator` — token-driven của Material; KHÔNG thêm key `game-mc/progress`
     (giữ gap, note). KHÔNG hardcode màu/spacing.
   - KHÔNG thêm node mới cho next/audio/edit (đã ledger INTENDED absence).
   - Divergence giữ nguyên → đã/đang vào intent-ledger.
4. **l10n**: các chuỗi user-facing của frame (`gameMultipleChoice`, `gameComplete`, `gamePlayAgain`,
   `gameDone`, `gameNotEnoughTitle`, `commonBack`, `libraryError`) đã dùng trong `game_screen.dart` — verify
   có **cả** `app_en.arb` và `app_vi.arb`. Nếu thêm/đổi bất kỳ chuỗi nào → thêm vào **cả hai** ARB cùng
   commit rồi regen l10n. KHÔNG copy mock copy từ kit ("Multiple choice", "Round complete!", "You answered
   5/5 correctly.", "Next round", "school/hospital/park/restaurant"…) vào app/test — luôn từ ARB / domain.
5. **Viết test** `test/presentation/features/game/game_mc_states_test.dart` — COPY cấu trúc
   `dashboard_states_test.dart` (Template B): đọc `game-mc.states.json`, tính `universe` = hợp các tập,
   `recipes` seed cho từng state, pump `GameScreen`, assert mỗi key trong universe: allowed → `findsOneWidget`
   (THIẾU nếu absent), ngoài allowed → `findsNothing` (THỪA nếu present).
   - Seed theo `game_session_test.dart`: insert `languagePair(ko→vi)` + `deck` + N `card` + `cardMeaning`.
   - `recipes`: `waiting` → seed ≥1 card (pump tới body); `complete` → seed 1 card rồi tap `Key('mcCorrect')`
     option đúng, pump → `_complete`. `correct`/`wrong` KHÔNG drive (comment lý do coverage gap — cùng node-set
     với waiting, FE không có feedback frame).
   - Pump: thử `pumpAndSettle`; nếu treo do `MxStateView.loading` → dùng vòng `for` pump 50ms như review.
   - Host: `MaterialApp(theme: AppTheme.light(), localizationsDelegates, supportedLocales,
     home: Scaffold(body: GameScreen(request: ...)))`.
   - Header test giải thích rõ: 2 state gated (`waiting`, `complete`), `correct`/`wrong` = coverage gap.
6. **Xóa skeleton** đã tiêu thụ: `tool/parity/contracts/game-mc.slots.skeleton.json` +
   `game-mc.states.skeleton.json` (skeleton là AUTO-PROPOSED, không ship — theo ghi chú `$skeleton`).
7. **Cập nhật queue**: đổi ô `game-mc` → `[x]` trong `docs/agent/kit-to-flutter/README.md` (nếu file đó
   liệt kê queue; giữ nhất quán tên).
8. **Doc parity**: task thuần style/composition-parity ⇒ nhiều khả năng không đổi business doc; nếu chọn (B)
   đổi `Card`→`MxCard` (đổi widget UI) → kiểm `docs/design/*` + `docs/ui-ux/ui-ux-contract.md`. Nếu chạm hành
   vi user-visible → update doc tương ứng cùng commit. Thường chỉ cần intent-ledger.

---

## Hard rules (vi phạm = task fail — trích `CLAUDE.md`)

- **Token-only**: không hardcode màu, radius, spacing, text style, duration, chuỗi user-facing. Dùng `Mx*` +
  theme token + `MxSpacing`.
- **Không vẽ lại/di chuyển UI** ngoài align key/token; divergence → ledger, KHÔNG tự ép FE về kit
  (prompt Card, options feedback).
- **Không node-literal hoist sau dynamic key**: mỗi `ValueKey('mx-node:...')` phải `const` gắn node tĩnh;
  không sinh key động theo index/state.
- **KHÔNG thêm node mới cho next/audio/edit/progress** (next/audio/edit đã ledger INTENDED absence).
- **l10n cả hai ARB**: mọi chuỗi mới vào `app_en.arb` **và** `app_vi.arb` cùng commit; regen l10n; KHÔNG sửa
  `lib/l10n/generated/**` tay.
- **KHÔNG copy MOCK COPY** từ kit spec vào app/test làm assert văn bản.
- **KHÔNG ship skeleton** làm curated; phải trim rồi xóa 2 skeleton.
- **KHÔNG bịa** `correct`/`wrong` state nếu FE không có feedback frame → giữ coverage gap và báo. Không viết
  test giả chỉ để có state.
- **KHÔNG chạm SRS/schedule** (D-007: game không đổi lịch; D-015: sai re-queue trong vòng).
- Không sửa generated (`*.g.dart`, `*.freezed.dart`, `game-mc.gen.json`, `docs/_generated/**`).
- Không thêm dependency mới (Stop & ask nếu cần).
- KHÔNG đánh dấu done nếu `node tool/verify/run.mjs --full` chưa xanh.

---

## Verification

```bash
node tool/verify/run.mjs --full
```

Phải PASS (ghi pass-marker mà pre-commit hook yêu cầu). Trong đó có test parity mới + freshness check của
specs + ledger check. Nếu `--full` fail hoặc bị skip → KHÔNG được báo done. Trong lúc dev có thể `--quick`
(không marker). Chạy riêng test mới để chắc:
`flutter test test/presentation/features/game/game_mc_states_test.dart`.

Sau khi verify PASS, TRƯỚC final report: fan-out song song `code-reviewer` (review working-tree diff — cho nó
`git add -N .` rồi `git diff`, KHÔNG commit trước) + `docs-drift-detector`. Gộp findings vào mục "Subagent
review". Fix blocker trước khi kết; liệt kê minor cho user. Bỏ fan-out (và nói lý do) nếu chỉ docs-only/trivial.

---

## Commit (2 commit + WBS)

**Commit 1** — contract + FE align + test:
```
test(parity): game-mc state-composition gate (waiting/complete) + curated states.json

- curate tool/parity/contracts/game-mc.states.json (2 gated states; correct/wrong coverage gap)
- curate tool/parity/contracts/game-mc.slots.json (prompt term slot) [hoặc: skipped — lý do]
- align FE game-mc keyed nodes (screen/appbar/prompt/options) [+ prompt Card→MxCard nếu chọn (B)]
- add test/presentation/features/game/game_mc_states_test.dart (Template B, copy dashboard_states_test)
- remove consumed skeletons (game-mc.slots.skeleton.json, game-mc.states.skeleton.json)

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>
```

**Commit 2** — docs/ledger + queue:
```
docs(parity): game-mc divergences (prompt Card, options feedback) → intent-ledger; mark game-mc done in queue

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>
```

**WBS** (bắt buộc, `CLAUDE.md` §WBS): thêm 1 dòng Commit Traceability Log (§10 của
`docs/project-management/wbs.md`), newest first:
`<8-char hash> · <YYYY-MM-DD> · <WBS IDs> · game-mc kit→flutter state-composition parity (Template B; waiting+complete gated, correct/wrong coverage gap)`.
Nếu WBS không đổi task breakdown, report ghi `WBS update: not needed — <reason>` (nhưng Commit Traceability
Log vẫn append nếu advance WP).

---

## Final report (đưa vào tin nhắn cuối)

```
## game-mc — kit→flutter DONE
- Template: B (state-composition) — lý do: prompt keyed là `Card` không `MxCard`; choices không keyed → không đủ điều kiện Template A.
- Gate-able keyed node (FE): prompt, options  [+ chrome screen/appbar loại khỏi gate]  [4 keyed total]
- Contracts: game-mc.states.json (+ game-mc.slots.json | slots skipped — lý do) curated; 2 skeleton deleted
- States gated: waiting (in-game body), complete (empty gate). Coverage gap: correct, wrong (cùng node-set với waiting; FE auto-advance, không có feedback frame)
- Divergences → intent-ledger: prompt (Card vs MxCard elevated), options (no post-answer color+icon feedback / auto-advance). [next/audio/edit đã có sẵn ledger]
- FE prompt: (A) giữ Card | (B) đổi MxCard elevated — <đã chọn>
- Identity-rollout gap (chưa keyed FE): game-mc/next, game-mc/audio, game-mc/edit, game-mc/progress, game-mc/choice-0..3
- l10n: gameMultipleChoice/gameComplete/gamePlayAgain/gameDone/gameNotEnoughTitle/commonBack đã có ở app_en.arb + app_vi.arb [no new keys | new keys: ...]
- Docs updated: <list | none — style/composition-parity only>
- WBS update: <line appended | not needed — reason>
- Verify: node tool/verify/run.mjs --full → PASS
- Subagent review: <blockers fixed | minor findings ...>
```
