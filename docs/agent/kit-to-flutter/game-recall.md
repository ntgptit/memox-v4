# Kit → Flutter — game-recall

> PROMPT ID: `kit-to-flutter/game-recall` · screen `game-recall` · feature `game` · Template **A** (review-style, per-state MxCard identity).
> FE files: `lib/presentation/features/game/screens/game_screen.dart` (SHARED frame cho cả 4 game) + `lib/presentation/features/game/widgets/recall_game.dart` (thân recall).
> SELF-CONTAINED. Đọc hết file này rồi thực thi tuần tự. Không cần đọc prompt nào khác.
> Nhiệm vụ: đóng **per-state parity gate** cho `game-recall` — curate contract + align FE về Mx*/ValueKey identity + viết 1 test parity theo Template A. Nếu gặp DRIFT hoặc DIVERGENCE cần người quyết → DỪNG, báo theo mẫu `DRIFT DETECTED` trong `CLAUDE.md`, chờ.

---

## 1. Baseline

```bash
git checkout main
git pull --ff-only
git checkout -b claude/kit-to-flutter-game-recall
```

Không bắt đầu khi working tree bẩn. Xác nhận `node tool/verify/run.mjs --quick` xanh trước khi sửa.

## 2. Required reading (chỉ đọc đúng các file này)

Universal (theo `CLAUDE.md`): `docs/_generated/repo-map.md`, `docs/_generated/where-is.md`,
`docs/business/index.md`, `docs/business/glossary.md`, `docs/contracts/error-contract.md`,
`docs/contracts/types-catalog.md`, `docs/contracts/code-style.md`.

Screen-specific:
- `docs/design/MemoX Design System/ui_kits/memox-app/specs/game-recall.md` — token-resolved DOM theo 5 state (base `before reveal` + diff `revealed` / `forgot` / `remembered` / `complete`).
- `tool/parity/contracts/game-recall.gen.json` — 11 keyed node (key + component + variant). **KHÔNG sửa** (generated). **Đã xác minh: 2 node `MxCard` (`game-recall/term`, `game-recall/meaning`, cả hai variant `elevated`).**
- `tool/parity/contracts/game-recall.slots.skeleton.json` — slot role đề xuất (superset) → curate thành `game-recall.slots.json`.
- `tool/parity/contracts/game-recall.states.skeleton.json` — node membership theo state (superset) → curate thành `game-recall.states.json`.
- FE: `lib/presentation/features/game/screens/game_screen.dart` + `lib/presentation/features/game/widgets/recall_game.dart`.
- Reference TEST để COPY (**Template A** — mẫu chọn): `test/presentation/features/study/review_parity_test.dart`.
- Contrast (KHÔNG áp dụng, chỉ để hiểu vì sao loại B): `test/presentation/features/engagement/dashboard_states_test.dart` (Template B, 0-MxCard).
- Curated mẫu để bắt chước format: `tool/parity/contracts/review.slots.json`, `tool/parity/contracts/review.states.json` (+ đọc `dashboard.slots.json` / `dashboard.states.json` để thấy khác biệt).
- Seed/pump pattern có sẵn cho session game: `test/presentation/features/game/game_session_test.dart` (in-memory Drift + `databaseProvider`/`clockProvider` override; card + cardMeaning).
- Intent-ledger hiện có: `tool/parity/intent-ledger.json` (đã có sẵn 4 exception cho `game-recall`: next/options/audio/edit; và 1 styleExempt `game-recall/reveal`).

**Drift check trước khi code (BẮT BUỘC):** recall là practice game — KHÔNG chạm `srs_state` (D-007); "Forgot" chỉ re-queue trong vòng (D-015). FE `game_session_notifier.dart` khớp (markWrong requeue, markCorrect pop; không schedule). Nếu FE mâu thuẫn spec ở hành vi → DỪNG, báo. Ở đây khớp → tiếp tục.

> ⚠️ Đây là task **style-parity / identity**, KHÔNG phải feature. KHÔNG thêm hành vi mới (audio, edit, next-round manual, options menu). Divergence đã có chủ đích → ledger, không ép về kit.

## 3. Template đã chọn: **A (review-style)** — vì sao

`game-recall.gen.json` có **2 node `MxCard`** (`game-recall/term`, `game-recall/meaning`, variant `elevated`) và **cả hai đã được key bằng `ValueKey` trong FE** (`recall_game.dart:32` term, `:44` meaning). Có MxCard keyed ⇒ dùng **Template A**: với mỗi state, vòng qua từng node `MxCard`, assert identity + variant + từng slot MxTextRole render (present) / không render (absent). Copy nguyên `review_parity_test.dart`, đổi `review` → `game-recall` và đổi cách seed/reach state qua `GameScreen(request: GameRequest(type: recall))` (mục 6).

> KHÔNG dùng Template B (dashboard-composition): thân recall là card-centric có MxCard keyed, không phải list/overlay chỉ toàn control.

> ⚠️ NHƯNG có 1 điểm PHẢI xử lý trước: xem mục 5.1 — FE hiện key `term` trên `Card` (Material) và `meaning` trên `Text` **thô**, KHÔNG phải `MxCard`. Test A assert `tester.widget<MxCard>(finder).variant` ⇒ sẽ FAIL nếu widget không phải `MxCard`. Phải **align FE về `MxCard`** trước khi test A xanh (đây là nội dung chính của task, không phải divergence để bỏ qua).

## 4. Gate-able node (đã key trong FE — grep `mx-node:game-recall` đã xác nhận)

Grep cho 7 node đã key (2 ở `game_screen.dart`, 5 ở `recall_game.dart`):

| key | component (gen) | variant (gen) | FE hiện tại | file:line |
| --- | --- | --- | --- | --- |
| `mx-node:game-recall/screen` | MxScaffold | null | ✓ MxScaffold (dynamic key theo GameType) | `game_screen.dart:135` |
| `mx-node:game-recall/appbar` | MxAppBar | null | ✓ MxAppBar (dynamic key theo GameType) | `game_screen.dart:142` |
| `mx-node:game-recall/term` | **MxCard** | **elevated** | ⚠ **`Card` (Material) + `Text` displayLarge** — phải đổi sang MxCard (mục 5.1) | `recall_game.dart:32` |
| `mx-node:game-recall/meaning` | **MxCard** | **elevated** | ⚠ **`Text` bodyLarge thô** (chỉ khi `_revealed`) — phải đổi sang MxCard (mục 5.1) | `recall_game.dart:44` |
| `mx-node:game-recall/reveal` | MxButton | primary | ⚠ `FilledButton` (Material) — divergence styleExempt đã có | `recall_game.dart:50` |
| `mx-node:game-recall/forgot` | MxButton | null | ⚠ `OutlinedButton` (Material) | `recall_game.dart:59` |
| `mx-node:game-recall/remembered` | MxButton | null | ⚠ `FilledButton` (Material) | `recall_game.dart:70` |

**2 node Template A vòng qua = `game-recall/term` + `game-recall/meaning`** (giống review vòng term+meaning). Các node còn lại (reveal/forgot/remembered) là control đã key nhưng KHÔNG phải MxCard → test A KHÔNG assert variant cho chúng ở vòng MxCard; chúng được phủ ở tầng state-membership (`game-recall.states.json`) như node present/absent.

### Node trong gen.json NHƯNG chưa key / không tồn tại trong FE → gap (ghi nhận, KHÔNG ép)

Các node này ĐÃ có exception trong `tool/parity/intent-ledger.json` (không cần thêm mới):
- `mx-node:game-recall/back`, `mx-node:game-recall/options` — appbar action; FE `MxAppBar` chưa expose (back tự động của Navigator). Gap.
- `mx-node:game-recall/audio`, `mx-node:game-recall/edit` — nút trong term card của kit; FE không render (audio/edit sống ở flashcard editor). Ledger `game-recall/audio`, `game-recall/edit` đã có.
- `mx-node:game-recall/next` — nút "Next round" ở complete-state của kit; FE dùng cụm `gamePlayAgain` + `gameDone` (không manual next; ledger `game-recall/next` đã có). Gap.
- `mx-node:game-recall/progress` — kit là dải progress bar; FE render `LinearProgressIndicator` KHÔNG key (`game_screen.dart:55`) ⇒ gap (khác widget lẫn identity).
- `mx-node:game-recall/complete` — kit là container complete-state; FE render `_complete()` (celebration + play-again/done) trong `MxContentBounds` KHÔNG key ⇒ gap.

Liệt kê nguyên các gap này trong **final report** (mục "Identity-rollout gap"). KHÔNG rollout key mới cho appbar-actions/audio/edit/next/progress/complete trong task này (ngoài scope style-parity, và đã có ledger). KHÔNG thêm hành vi thật.

## 5. Divergence → xử lý

### 5.1 term/meaning: `Card`/`Text` → **PHẢI đổi về `MxCard`** (KHÔNG phải divergence — đây là task)

Kit + gen.json nói `game-recall/term` và `game-recall/meaning` là `MxCard` variant `elevated`. FE hiện render:
- `term`: `Card(key: ValueKey('mx-node:game-recall/term'), child: Padding(... Center(child: Text(term, displayLarge))))` — Material `Card`, không phải `MxCard`.
- `meaning`: `Text(meaning, key: ValueKey('mx-node:game-recall/meaning'), bodyLarge)` — `Text` thô, không có card surface.

→ **Align FE về `MxCard`** (import `lib/presentation/shared/widgets/surfaces/mx_card.dart`), giữ nguyên `ValueKey`, dùng `MxCardVariant.elevated`, nội dung text render qua `MxText` (role tương ứng — xem slots mục 7). Đây là điểm review đã làm cho `review/term`+`review/meaning` (xem `review.slots.json`); game-recall lặp lại y hệt. Test A assert `widget<MxCard>(finder).variant == elevated` ⇒ nếu vẫn để `Card`/`Text` sẽ crash `widget<MxCard>` (không tìm thấy MxCard) → phải đổi.

> Token-only: dùng `MxCard` + `MxText` + `MxSpacing`; KHÔNG hardcode màu/radius/shadow/spacing. Nếu term/meaning cần layout (icon audio/edit của kit) → KHÔNG thêm (audio/edit là gap có ledger); giữ card tối giản term-only / meaning-only đúng FE truth.

### 5.2 Divergence có chủ đích → `tool/parity/intent-ledger.json` (KHÔNG ép về kit)

Các mục dưới ĐÃ có sẵn trong ledger — **kiểm tra tồn tại, KHÔNG duplicate**. Chỉ thêm nếu thiếu:
1. `game-recall/next` (kit MxButton "Next round" ở complete; FE auto-advance + play-again/done). → ĐÃ có exception.
2. `game-recall/options` (kit options menu; FE không có). → ĐÃ có exception.
3. `game-recall/audio` (kit audio trong term; FE audio ở editor). → ĐÃ có exception.
4. `game-recall/edit` (kit edit trong term; FE edit ở editor). → ĐÃ có exception.
5. `game-recall/reveal` styleExempt (kit r:12 + 20px label; FE FilledButton stadium + labelLarge). → ĐÃ có trong `styleExempt`.

Node `forgot` / `remembered`: kit là `MxButton`, FE là `OutlinedButton` / `FilledButton` (Material). Nếu bạn KHÔNG đổi chúng về `MxButton` trong task này (giữ tối giản, chỉ đổi term/meaning về MxCard) → **thêm styleExempt** cho `game-recall/forgot` và `game-recall/remembered` (field `*`, reason: "FE recall grade dùng Material Outlined/FilledButton, kit dùng MxButton — nút game tối giản, fill/emphasis khớp", source `docs/business/game/game-modes.md`) để spec_diff không đỏ. Test A KHÔNG assert variant cho chúng (không phải MxCard), nên đây thuần là style-diff ledger. **Ưu tiên tối giản**: chỉ đổi term/meaning về MxCard (bắt buộc cho test A); forgot/remembered để nguyên + ledger styleExempt.

Nếu bất kỳ mục nào thực chất là **BUG** (không phải chủ ý) → DỪNG, báo mẫu DRIFT, chờ người. Không tự sửa UI ngoài phần term/meaning→MxCard.

## 6. State-map (kit state → cách drive FE tới đúng node-set)

FE: `GameScreen(request)` watch `gameSessionProvider(request)`; body = `Column(LinearProgressIndicator, Expanded(RecallGame(round, actions)))`. `RecallGame` là `StatefulWidget` với `_revealed` (bool). Pump pattern: **giống `review_parity_test.dart` / `game_session_test.dart`** — seed Drift in-memory (languagePair ko→vi + deck + N card **có cardMeaning**), override `databaseProvider` + `clockProvider(_FixedClock)`, `pumpWidget(host)` với `home: Scaffold(body: GameScreen(request: GameRequest(nodeId: deckId, type: GameType.recall, scope: GameScope.all, random: false)))`, rồi pump vài nhịp 50ms (session load queue async; KHÔNG `pumpAndSettle` nếu `MxStateView.loading` spin — dùng vòng `for` pump như review). Để tới `revealed`: `tester.tap(find.byKey(ValueKey('mx-node:game-recall/reveal')))` rồi pump.

| kit state | FE reach được? | Cách reach | Node-set FE (BODY, MxCard-scope) |
| --- | --- | --- | --- |
| `before-reveal` | ✓ | seed **1 card** (+meaning) → `_revealed=false` → term + reveal | `game-recall/term` (meaning ABSENT — chỉ render khi `_revealed`) |
| `revealed` | ✓ | reach before-reveal → **tap reveal** → `_revealed=true` → term + meaning + forgot/remembered | `game-recall/term`, `game-recall/meaning` |
| `forgot` | ✗ coverage gap | `forgot`/`remembered`/`revealed` render **CÙNG node-set** ở tầng identity (term + meaning + forgot + remembered). Kit phân biệt bằng feedback banner (warning-soft "You'll see this word again") + bg nút — nhưng FE KHÔNG có banner riêng: `markWrong` re-queue rồi `setState(_revealed=false)` (quay lại before-reveal ngay), KHÔNG có state trung gian "forgot đã grade nhưng còn hiển thị". ⇒ không phải node-set phân biệt được. | (= revealed) |
| `remembered` | ✗ coverage gap | như `forgot` — `markCorrect` rồi `_revealed=false`. Không có banner success-soft riêng trong FE. | (= revealed) |
| `complete` | ✗ coverage gap | Complete render bởi `GameScreen._complete()` (dùng chung 4 game) trong `MxContentBounds` **KHÔNG key** `game-recall/complete`/`game-recall/next`; FE dùng `gamePlayAgain`+`gameDone` không phải kit "Next round". Không có MxCard keyed. ⇒ không reach được ở tầng identity `game-recall/*`. | — (không MxCard) |

**Quyết định curate `game-recall.states.json`:** đặt state key theo cái FE reach được ở tầng identity, giống review (review gộp `editing`/`audio` là gap):

```jsonc
{
  "before-reveal": ["mx-node:game-recall/term"],
  "revealed":      ["mx-node:game-recall/term", "mx-node:game-recall/meaning"],
  "forgot":        ["mx-node:game-recall/term", "mx-node:game-recall/meaning"],
  "remembered":    ["mx-node:game-recall/term", "mx-node:game-recall/meaning"]
}
```

- `before-reveal` = có card, chưa reveal → chỉ `term` (meaning ABSENT — đây là chỗ test A bắt được state-differentiated identity: meaning `findsNothing` ở before-reveal, `findsOneWidget` ở revealed).
- `revealed` = term + meaning.
- `forgot` / `remembered` giữ để đủ bộ (documented) nhưng **KHÔNG drive** trong test (coverage gap — FE không có node-set phân biệt; ghi rõ trong `$curated` note giống review). Chúng có cùng node-set như `revealed`.
- `complete` = **KHÔNG liệt kê** (không có MxCard keyed `game-recall/*`; complete-state dùng chrome chung không key) → coverage gap, ghi trong `$curated`.
- Chrome (`screen`/`appbar`/`progress`) + control (`reveal`/`forgot`/`remembered`) KHÔNG liệt kê — chỉ giữ BODY MxCard-scope, đúng như `review.states.json` chỉ giữ `review/term`+`review/meaning`.

> Lưu ý Template A vòng `if (node['component'] != 'MxCard') continue;` ⇒ test chỉ thực chất assert `term` + `meaning`. Vì reveal/forgot/remembered không phải MxCard, chúng KHÔNG bị assert ở test A → note coverage rõ. Nếu muốn cũng gate present/absent cho control, thêm 1 vòng phụ non-MxCard (optional, giống dashboard state-set) — nhưng để bám sát Template A, giữ review-style là đủ.

**States trong test (drive được):** `before-reveal` (1 card, không tap) + `revealed` (1 card, tap reveal). `forgot`/`remembered` KHÔNG drive (comment lý do coverage gap). `complete` KHÔNG drive (không có MxCard `game-recall/*`).

## 7. Workflow (theo thứ tự, mỗi bước một layer)

1. **Curate `tool/parity/contracts/game-recall.slots.json`** từ `game-recall.slots.skeleton.json`:
   - `mx-node:game-recall/term`: `{ "name": "term", "role": "displayLarge", "bind": "card.term" }` (giữ như skeleton; bind = user content, KHÔNG l10n).
   - `mx-node:game-recall/meaning`: `{ "name": "meaning", "role": "bodyLarge", "bind": "card.meaning" }` (FE hiện render `bodyLarge` — giữ FE truth; skeleton chỉ có meaning-hint labelMedium của before-reveal, đó là MOCK COPY "Recall the meaning…" KHÔNG map l10n → bỏ, dùng meaning thực của revealed).
   - Bỏ `game-recall/reveal` slot ("Show") khỏi slots (reveal không phải MxCard, test A không vòng qua). Giữ tối giản như `review.slots.json`.
   - Thêm `$curated` note: giải thích term=displayLarge / meaning=bodyLarge (FE truth), scope = 1-card recall round, meaning chỉ render khi revealed.
2. **Curate `tool/parity/contracts/game-recall.states.json`** từ skeleton theo bảng mục 6 (chrome + control loại bỏ; `forgot`/`remembered` = documented-not-driven gap; `complete` = gap; `$curated` note nêu rõ: forgot/remembered cùng node-set như revealed, complete-state dùng chrome chung không key).
3. **Align FE** (đây là phần code chính):
   - `recall_game.dart`: đổi `term` từ `Card` → `MxCard(variant: MxCardVariant.elevated, key: ValueKey('mx-node:game-recall/term'), child: ... MxText(current.term, role: displayLarge))`. Đổi `meaning` từ `Text` → `MxCard(variant: MxCardVariant.elevated, key: ValueKey('mx-node:game-recall/meaning'), child: MxText(current.meaning, role: bodyLarge))`. Giữ nguyên `ValueKey` literal + `const` nơi có thể. KHÔNG hardcode padding/màu — dùng `MxSpacing` + variant token.
   - Giữ `reveal`/`forgot`/`remembered` như hiện tại (Material button + ledger styleExempt) TRỪ KHI bạn quyết đổi về `MxButton` (optional; nếu đổi → cập nhật ledger tương ứng, không để spec_diff đỏ). **Ưu tiên minimal: chỉ term/meaning→MxCard.**
   - KHÔNG thêm node mới (audio/edit/next/options/progress/complete key) — ngoài scope.
   - `game_screen.dart` (shared): KHÔNG đổi (screen/appbar key đã đúng; complete-state chung không key — gap). Chỉ chạm nếu cần import.
4. **l10n**: các key `gameShow` / `gameForgot` / `gameRemembered` / `gameComplete` / `gamePlayAgain` / `gameDone` / `gameRecall` **đã có** ở `lib/l10n/app_en.arb` (verify: có). Xác nhận cũng có ở `lib/l10n/app_vi.arb` trước khi dùng. Task này thuần đổi widget (Card→MxCard, Text→MxText) — **có thể KHÔNG thêm chuỗi mới**. Nếu thêm/đổi bất kỳ chuỗi user-facing nào → thêm vào **cả hai** ARB cùng lúc rồi regen l10n; KHÔNG sửa `lib/l10n/generated/**` tay. KHÔNG copy MOCK COPY từ kit ("친구", "friend", "a friend, companion", "Round complete!"…) vào app/test.
5. **Viết test** `test/presentation/features/game/game_recall_parity_test.dart` — COPY `review_parity_test.dart`, đổi:
   - đường dẫn contract `review.*` → `game-recall.*`;
   - import + host dựng `GameScreen(request: GameRequest(nodeId: deckId, type: GameType.recall, scope: GameScope.all, random: false))` thay `ReviewScreen`;
   - seed theo `game_session_test.dart` (languagePair ko→vi, 1 deck, N card `term:'학교'` + **cardMeaning** `content:'…'` — recall cần meaning để render);
   - state driver: `before-reveal` = seed 1 card, pump (không tap); `revealed` = seed 1 card, pump, **tap `mx-node:game-recall/reveal`**, pump. `_stateSeed` map hoặc 1 helper reach từng state; `forgot`/`remembered`/`complete` KHÔNG drive (comment coverage gap ngay trong header như review giải thích `editing`/`audio`);
   - pump vòng `for` 50ms (không `pumpAndSettle` nếu loading spin).
   - Vòng assert giữ nguyên Template A: chỉ node `component == 'MxCard'` → present/absent theo `states.json`, variant khớp gen, slot MxTextRole render.
6. **Xoá 2 skeleton**: `game-recall.slots.skeleton.json` + `game-recall.states.skeleton.json` sau khi curate ra bản chính (giống review/dashboard không còn skeleton — theo ghi chú `$skeleton`).
7. **Cập nhật queue**: đổi ô `game-recall` → done trong `docs/agent/kit-to-flutter/README.md` (nếu file queue tồn tại; giữ nhất quán tên).

## 8. Hard rules (vi phạm = task fail)

- **Token-only**: không hardcode màu, radius, spacing, text style, duration, chuỗi user-facing. Dùng `Mx*` widget (`MxCard`/`MxText`/`MxButton`) + theme token + `MxSpacing`.
- **term/meaning PHẢI là `MxCard` variant `elevated`** với `ValueKey` literal giữ nguyên — đây là điểm test A gate; để `Card`/`Text` = fail.
- **Không node-literal hoist sau dynamic key**: `screen`/`appbar` dùng dynamic key theo `GameType` trong `game_screen.dart` (đúng, không đổi); term/meaning là `const ValueKey` tĩnh — giữ vậy, KHÔNG sinh key động theo index/state.
- **Divergence → intent-ledger**, không ép FE về kit (next/options/audio/edit đã có; forgot/remembered nếu giữ Material → styleExempt).
- **KHÔNG bịa state**: `forgot`/`remembered`/`complete` không drive được sạch ở tầng identity → hạ xuống coverage gap + note, KHÔNG viết test giả để có state.
- **l10n cả hai ARB**: mọi chuỗi mới vào `app_en.arb` **và** `app_vi.arb` cùng commit; regen; không sửa `lib/l10n/generated/**` tay. KHÔNG copy mock copy từ kit.
- Không sửa file generated (`*.g.dart`, `*.freezed.dart`, `game-recall.gen.json`, `docs/_generated/**`).
- Không thêm dependency mới (Stop & ask nếu cần).
- Không đổi hành vi SRS/re-queue (D-007 game không schedule; D-015 forgot re-queue trong vòng).
- **KHÔNG đổi `game_screen.dart` chung theo cách phá 3 game còn lại** (matching/mc/typing dùng chung frame + `_complete()`); chỉ chạm `recall_game.dart`. Nếu buộc phải chạm frame → verify cả 4 game parity test không đỏ.
- Doc-code parity: task thuần style-parity/identity ⇒ nhiều khả năng `WBS update: not needed` + không đổi business doc; nếu đổi hành vi user-visible → update doc cùng commit. Xác nhận rồi ghi rõ.

## 9. Verification

```bash
node tool/verify/run.mjs --full
```

Phải PASS (viết pass-marker cho pre-commit hook). Trong đó có test parity mới + freshness check specs + spec_diff (kiểm ledger). Nếu `--full` fail hoặc bị skip → KHÔNG được báo done. Trong lúc dev có thể `--quick` (không marker). Chạy riêng cho chắc: `flutter test test/presentation/features/game/game_recall_parity_test.dart`.

Sau khi verify PASS, TRƯỚC final report: fan-out song song `code-reviewer` (review working-tree diff — cho nó chạy `git add -N .` rồi `git diff`, KHÔNG commit trước) + `docs-drift-detector`. Gộp findings vào mục "Subagent review"; fix blocker trước khi kết.

## 10. Commit (2 commit + WBS)

1. **impl**: FE align (term/meaning → MxCard/MxText) + contracts curate (`game-recall.slots.json`, `game-recall.states.json`) + xoá 2 skeleton + test + (ARB/ledger styleExempt nếu đổi).
   ```
   feat(parity): style-parity — game-recall — Template A, term/meaning MxCard gate + before-reveal/revealed states

   Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>
   ```
2. **WBS trace**: append 1 dòng vào Commit Traceability Log (§10 `docs/project-management/wbs.md`), newest first:
   ```
   <8-char hash> · <YYYY-MM-DD> · <WBS IDs> · style-parity game-recall (Template A; term/meaning MxCard gated, before-reveal/revealed driven, forgot/remembered/complete coverage gap)
   ```
   Đổi ô `game-recall` → done trong `docs/agent/kit-to-flutter/README.md` cùng commit impl hoặc trace. Nếu WBS task-breakdown không đổi, report ghi `WBS update: not needed — <reason>` (nhưng Commit Traceability Log vẫn append nếu advance WP).

## 11. Final report format

```
## game-recall — kit→flutter DONE
- Template: A (review-style, MxCard identity per-state) — vì gen.json có 2 MxCard (term, meaning) keyed trong FE
- Gate-able nodes (keyed): screen, appbar, term(MxCard elevated), meaning(MxCard elevated), reveal, forgot, remembered  [7]
- FE align: term Card→MxCard, meaning Text→MxCard (variant elevated); reveal/forgot/remembered giữ Material [+ styleExempt] | đổi MxButton
- Contracts: game-recall.slots.json + game-recall.states.json curated; 2 skeleton deleted
- States driven: before-reveal (term only), revealed (term+meaning after tap reveal). Coverage gap: forgot/remembered (same node-set as revealed — FE grade rồi về before-reveal, không banner riêng), complete (chrome chung _complete() không key game-recall/*, dùng playAgain/done không phải kit next)
- Divergences → intent-ledger: next/options/audio/edit (đã có exception) [+ forgot/remembered styleExempt nếu giữ Material]
- Identity-rollout gap (chưa key trong FE): game-recall/back, /options, /audio, /edit, /next, /progress, /complete
- l10n: gameShow/gameForgot/gameRemembered/gameComplete/gamePlayAgain/gameDone đã có ở app_en.arb + app_vi.arb [no new keys | new keys: ...]
- Docs updated: <list | none — style-parity only>
- WBS update: <line appended | not needed — reason>
- Verify: node tool/verify/run.mjs --full → PASS
- Subagent review: <blockers fixed | minor findings ...>
```
