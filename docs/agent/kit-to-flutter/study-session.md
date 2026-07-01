# Kit → Flutter — study-session (màn W5 study)

> PROMPT ID: `kit-to-flutter/study-session` · feature `study` · Template **A** (review-style, per-state MxCard identity)
> FE file: `lib/presentation/features/study/screens/study_session_screen.dart`
> Self-contained. Đọc hết trước khi code. Nếu gặp DRIFT hoặc DIVERGENCE cần người quyết → DỪNG, báo, chờ.
> Nhiệm vụ: đóng **per-state parity gate** cho `study-session` (KHÔNG vẽ lại UI — UI đã có sẵn;
> việc ở đây là **curate contract + align ValueKey identity + viết 1 test parity** theo Template A).

---

## 1. Baseline

```bash
git checkout main
git pull --ff-only
git checkout -b claude/kit-to-flutter-study-session
```

Xác nhận working tree sạch và `node tool/verify/run.mjs --quick` xanh trước khi sửa.

## 2. Required reading (CHỈ đọc đúng các file này)

Screen-specific:
- `docs/design/MemoX Design System/ui_kits/memox-app/specs/study-session.md` — token-resolved DOM theo 10 state (base `stage1-review` + 9 diff/full).
- `tool/parity/contracts/study-session.gen.json` — 16 keyed node (key + component + variant). **KHÔNG sửa** (generated).
- `tool/parity/contracts/study-session.slots.skeleton.json` — slot role đề xuất (superset) → curate thành `study-session.slots.json`.
- `tool/parity/contracts/study-session.states.skeleton.json` — node membership theo state (superset, gồm cả chrome + node chưa key ở FE) → curate thành `study-session.states.json`.
- FE: `lib/presentation/features/study/screens/study_session_screen.dart` (grep `mx-node:study-session`).
- Reference TEST để COPY (Template A — mẫu chọn): `test/presentation/features/study/review_parity_test.dart`.
- Reference TEST tương phản (Template B — chỉ để hiểu vì sao KHÔNG dùng): `test/presentation/features/engagement/dashboard_states_test.dart`.
- Test hiện có (khuôn seed/pump domain): `test/presentation/features/study/study_session_test.dart` — pattern seed pair+deck+card, drive qua `studySessionProvider(StudyRequest)` + `grade()`.
- Curated mẫu để bắt chước format: `tool/parity/contracts/review.slots.json`, `review.states.json`, `dashboard.slots.json`, `dashboard.states.json`.
- Ledger: `tool/parity/intent-ledger.json` — **đã có sẵn** nhiều mục `study-session` (mục 5).
- Contract nền (`CLAUDE.md` universal): `docs/business/glossary.md`, `docs/contracts/code-style.md`, `docs/ui-ux/ui-ux-contract.md`, `docs/business/study/study-flow.md`.

**Drift check trước khi code:** study-session = NewLearn (5 stage) + DueReview (1 recall pass, chấm SRS D-014/D-007).
Spec chốt: stage 1 là learn pass (term+meaning), stage 2–5 và DueReview reuse **game widget thật** (W5:
matching / multiple-choice / recall / typing) drive qua `RoundActions`. FE (`study_session_screen.dart:112-126`)
khớp: chỉ stage 1 render `MxCard` keyed `study-session/card` + `study-session/next`; các stage khác trả
`MatchingGame / MultipleChoiceGame / RecallGame / TypingGame`. Nếu FE mâu thuẫn spec ở **hành vi**
(vd stage-1 bị ghi là chấm SRS, hoặc DueReview render lại 5 stage) → DỪNG, báo theo mẫu `DRIFT DETECTED`
trong `CLAUDE.md`, chờ. Ở đây spec khớp FE → OK, tiếp tục.

## 3. Template đã chọn: **A (review-style)** — vì sao

`study-session.gen.json` có **đúng 1 node `MxCard`**: `mx-node:study-session/card` (variant `elevated`), và node
đó **đã được key bằng `ValueKey` trong FE** (`study_session_screen.dart:135`, trong `_learnStage`). Có MxCard keyed
⇒ dùng **Template A**: với mỗi state, assert node `MxCard` keyed → identity + variant + từng slot `MxTextRole` render
(present) / không render (absent). Copy nguyên `review_parity_test.dart`, đổi `review` → `study-session` và đổi cách
seed/reach state (mục 6–7).

> KHÔNG dùng Template B (dashboard state-composition): study-session **có** MxCard keyed (card-centric ở stage 1),
> không phải màn thuần list/overlay như library/dashboard. Template A đúng khuôn vì gate node MxCard này bật/tắt
> theo state (chỉ present ở stage1-review, absent ở mọi stage game).

## 4. Gate-able node (đã key trong FE — grep xác nhận)

Grep `mx-node:study-session` trong `lib/` cho ra ĐÚNG **6** literal keyed node:

| key | component (gen) | variant (gen) | FE hiện tại | FE citation |
| --- | --- | --- | --- | --- |
| `mx-node:study-session/screen` | MxScaffold | null | ✓ MxScaffold (chrome) | `:84` |
| `mx-node:study-session/appbar` | MxAppBar | null | ✓ MxAppBar (chrome) | `:86` |
| `mx-node:study-session/card` | **MxCard** | **elevated** | ✓ MxCard (padding lg) — **gate node chính Template A**, CHỈ render ở stage-1 learn | `:135` |
| `mx-node:study-session/next` | MxButton | primary | ✓ MxButton (block, default=primary) — CHỈ render ở stage-1 learn | `:149` |
| `mx-node:study-session/exit-cancel` | MxButton | ghost | ✓ MxButton ghost (trong `AlertDialog` khi `_onExit()` ở NewLearn) | `:61` |
| `mx-node:study-session/exit-ok` | MxButton | primary | ✓ MxButton (default=primary) trong exit dialog | `:67` |

> **Chỉ `mx-node:study-session/card` là MxCard** → là node duy nhất Template A vòng qua (`if component != 'MxCard' continue`).
> `next` / `exit-cancel` / `exit-ok` là identity đã key nhưng KHÔNG phải MxCard ⇒ test A **không** assert variant cho chúng
> ở vòng MxCard; chúng được phủ ở tầng state-membership (`study-session.states.json`) nếu bạn muốn — nhưng vì Template A
> chỉ thực chất assert MxCard, hãy note rõ coverage (giống player.md mục 6).

### Node trong gen.json NHƯNG chưa key / không tồn tại ở FE → identity-rollout gap (ghi nhận, KHÔNG ép)

Các node sau có trong `study-session.gen.json` nhưng **đã có mục exception trong `intent-ledger.json`** (mục 5) hoặc là
chrome do game-widget/overlay khác sở hữu — KHÔNG rollout key mới trong task style-parity này:

- `study-session/reveal`, `study-session/check`, `study-session/hint`, `study-session/options` — controls của stage 2–5,
  do **game widget** cung cấp với identity `game-*` (đã verify: `typing_game.dart` key `game-typing/hint|check`;
  `recall_game.dart` key `game-recall/reveal`; `multiple_choice_game.dart` key `game-mc/options`). Đã có exception ledger.
- `study-session/due-next`, `study-session/due-relearn` — DueReview grading do `RecallGame` cung cấp (`game-recall/*`). Ledger: `node: "due"`.
- `study-session/resume-back`, `study-session/resume-retry` — v1 KHÔNG có màn resume (ledger `node: "resume"`).
- `study-session/save-error-back`, `study-session/save-error-retry` — v1 gộp mọi lỗi load/persist thành 1 message state (ledger `node: "save-error"`).
- `study-session/progress` — kit là span "16%"; FE render `LinearProgressIndicator(value: state.progress)` KHÔNG key ⇒ gap
  (khác cả widget lẫn identity — determinate bar, không có % text node). Note gap.
- `study-session/close`, `study-session/options` (appbar) — FE dùng `MxIconButton(key: Key('studyExit'), ...)` cho nút close
  (key **domain** `studyExit`, KHÔNG phải `mx-node:study-session/close`); không có nút options ở FE. Note gap; KHÔNG re-key.

Liệt kê nguyên các gap này trong **final report** (mục "Identity-rollout gap"). KHÔNG rollout key mới cho game-owned
controls / progress / close trong task này trừ khi thêm hành vi thật — đây là task style-parity, không phải feature.

## 5. Divergence → `tool/parity/intent-ledger.json` (KHÔNG ép về kit)

**QUAN TRỌNG:** `intent-ledger.json` **ĐÃ CÓ SẴN** đầy đủ các mục `study-session` cần thiết — ĐỌC TRƯỚC, ĐỪNG thêm trùng.
Các mục hiện có (screen `study-session`): `reveal`, `check`, `hint`, `options`, `due`, `resume`, `save-error` (mảng `exceptions`),
và `styleExempt` cho `study-session/next`.font (label 20px kit → labelLarge 15px FE). Xem nội dung để hiểu lý do giữ.

Hành động của bạn:
1. **KHÔNG thêm mục mới** trừ khi bạn phát hiện một divergence THẬT chưa được ghi. Với 6 keyed node ở mục 4, không có
   divergence component/variant mới (card=MxCard elevated ✓, next=MxButton primary ✓, exit-cancel=ghost ✓, exit-ok=primary ✓ —
   khớp gen.json). ⇒ **kỳ vọng: 0 mục ledger mới.**
2. Nếu bạn phát hiện divergence chưa có (vd FE render `card` variant khác `elevated`) → đó có thể là **BUG**, KHÔNG phải
   "chệch có chủ đích": DỪNG, báo theo mẫu DRIFT, chờ người. Không tự sửa UI, không tự thêm ledger để "hợp thức hoá".
3. Slot `study-session/card`: kit mock có 4 dòng (term 48/800, divider, meaning 30/700, "noun · a place of learning" 15/400).
   FE `_learnStage` render `MxText(term, role: displayLarge)` + `MxText(meaning, role: bodyLarge)` — **KHÔNG** có dòng
   part-of-speech, meaning là `bodyLarge` (không phải kit mock `displaySmall`/30/700). Đây là **FE truth binding**, không phải
   drift — curate `study-session.slots.json` theo FE (`displayLarge` + `bodyLarge`), ghi 1 dòng `$curated` note, KHÔNG cần ledger.

## 6. State-map (10 kit state → cách drive FE tới đúng node-set)

FE là 1 `ConsumerStatefulWidget` drive bởi `studySessionProvider(StudyRequest)` (async). Pump pattern: **kết hợp**
`review_parity_test.dart` (host `pumpWidget` + vòng `for` pump 50ms, KHÔNG `pumpAndSettle` vì có `MxStateView.loading`)
và seed domain của `study_session_test.dart` (seed `languagePair` ko→vi + `deck` + N `card`, override `databaseProvider` +
`clockProvider(_FixedClock)`). Drive stage bằng `StudyRequest(entry: newLearn|dueReview)` + gọi `grade()` để nhảy stage.

Nhắc lại kiến trúc FE: `state.stageIndex` 0..4 với NewLearn (0=learn card, 1=matching, 2=mc, 3=recall, 4=typing);
DueReview luôn là `RecallGame`. `MxCard(study-session/card)` chỉ render ở `stageIndex==0` NewLearn.

| kit state | FE reach được? | Cách reach | Node-set FE (MxCard scope) |
| --- | --- | --- | --- |
| `stage1-review` | ✓ | seed **1 card**, `entry: newLearn`, `stageIndex==0` → `_learnStage()` | `study-session/card` **present** |
| `stage2-matching` | ✓ (card absent) | từ stage1, `grade(true)` cho tới `stageIndex==1` → `MatchingGame` | `study-session/card` **absent** (game body, `game-matching/*`) |
| `stage3-choice` | ✓ (card absent) | drive tới `stageIndex==2` → `MultipleChoiceGame` | `study-session/card` **absent** (`game-mc/*`) |
| `stage4-recall` | ✓ (card absent) | drive tới `stageIndex==3` → `RecallGame` | `study-session/card` **absent** (`game-recall/*`) |
| `stage5-typing` | ✓ (card absent) | drive tới `stageIndex==4` → `TypingGame` | `study-session/card` **absent** (`game-typing/*`) |
| `due-review` | ✓ (card absent) | seed 1 card + srs row, `entry: dueReview` → `RecallGame` | `study-session/card` **absent** (kit key `card` ở đây là game recall card → `game-recall/*`, KHÔNG phải `study-session/card`) |
| `relearn` | ✗ coverage gap | FE re-queue sai trong stage (D-015), KHÔNG có node-set "relearn" phân biệt keyed ở study-session scope (banner "review this word" không key) | — |
| `exit` | ⚠ một phần | `entry: newLearn`, tap close → `_onExit()` mở `AlertDialog` với `exit-cancel`+`exit-ok`. Overlay này KHÔNG phải MxCard ⇒ Template A **không** gate nó ở vòng MxCard | `exit-cancel`, `exit-ok` (non-MxCard) |
| `resume-error` | ✗ coverage gap | v1 KHÔNG có resume prompt (ledger). Không reach được | — |
| `answer-save-error` | ✗ coverage gap | v1 gộp lỗi thành 1 message state (`_message`), KHÔNG có save-error dialog keyed (ledger). Không reach được | — |

**Node thực sự phân biệt state ở tầng MxCard = chỉ `study-session/card`**: present ở `stage1-review`, absent ở mọi stage
game + due-review. Đó là chỗ Template A bắt được THỪA (card leak vào stage game) / THIẾU (card mất ở stage1).

### Quyết định curate `study-session.states.json`

Đặt state key theo cái FE reach được ở tầng MxCard, giống review/player (chrome appbar/screen/progress/close **loại khỏi**
node-set — chỉ giữ BODY MxCard-scope node để Template A vòng qua):

```jsonc
{
  "stage1-review":   ["mx-node:study-session/card"],
  "stage2-matching": [],
  "stage3-choice":   [],
  "stage4-recall":   [],
  "stage5-typing":   [],
  "due-review":      []
}
```

- `stage1-review` = state duy nhất có MxCard `study-session/card`.
- `stage2..5` + `due-review` = MxCard absent (game body). `[]` ⇒ test A assert `study-session/card` **findsNothing** ở các
  state này (state-differentiated identity — đây là gate chính).
- `relearn` / `resume-error` / `answer-save-error` / `exit`: **KHÔNG đưa vào states.json** hoặc đưa vào như documented
  coverage-gap (không drive) — theo mẫu review (`editing`/`audio` giữ cho đủ, note gap). Khuyến nghị: chỉ ship 6 state
  drive được ở trên; ghi 4 state gap trong `$curated` note + header test + report. `exit` là overlay non-MxCard ⇒ Template A
  không gate; nếu muốn gate `exit-cancel`/`exit-ok` cần vòng phụ non-MxCard (optional, giống dashboard set) — để bám sát
  Template A, giữ review-style là đủ, note coverage.

## 7. Workflow (theo thứ tự, mỗi bước một layer)

1. **Curate `tool/parity/contracts/study-session.slots.json`** từ `study-session.slots.skeleton.json`:
   - `mx-node:study-session/card`: `[{ "name": "term", "role": "displayLarge", "bind": "card.term" }, { "name": "meaning", "role": "bodyLarge", "bind": "card.meaning" }]`
     — sửa từ skeleton (meaning `displaySmall` → FE truth `bodyLarge`); bỏ dòng "noun · a place of learning" (FE không render
     part-of-speech); `bind` = user content, KHÔNG l10n.
   - Bỏ khỏi slots các node skeleton không thuộc MxCard (`progress`, `screen`, `next`) — Template A chỉ vòng MxCard.
   - Thêm `$curated` note: meaning=bodyLarge là FE truth (không phải kit mock 30/700), không có POS line, scope = 1-card learn stage.
2. **Curate `tool/parity/contracts/study-session.states.json`** từ skeleton theo bảng mục 6: 6 state drive được, mỗi state chỉ
   giữ MxCard-scope node (`stage1-review` = `[card]`, còn lại `[]`). Chrome (`appbar/screen/progress/close/options`) + non-MxCard
   (`next/exit-*/game-owned`) **loại khỏi** node-set. Thêm `$curated` note: giải thích 4 state gap (relearn / exit / resume-error /
   answer-save-error) và lý do (game re-queue không keyed / overlay non-MxCard / không tồn tại ở v1 — cite ledger).
3. **Align FE** `study_session_screen.dart` — xác nhận (KHÔNG thêm node mới):
   - 6 key hiện có đúng chính tả (grep đã confirm: `screen:84`, `appbar:86`, `card:135`, `next:149`, `exit-cancel:61`, `exit-ok:67`).
   - Card render bằng `MxCard` + token (`padding: MxCardPadding.lg`), text bằng `MxText` role token — KHÔNG hardcode màu/spacing/style.
   - `next` là `MxButton(block: true)` (default variant = primary, khớp gen). Divergence `next`.font đã ở styleExempt — KHÔNG sửa.
   - KHÔNG re-key `progress` (LinearProgressIndicator), `close` (Key('studyExit')), hay game-owned controls (giữ gap, note).
   - KHÔNG hoist node-literal sau dynamic key; mỗi `ValueKey('mx-node:...')` là `const`, gắn node tĩnh.
4. **l10n**: các key learn-stage đã có **cả** `app_en.arb` + `app_vi.arb` (đã verify: `studyContinue`, `studyStageReview`,
   `studyDueReview`, `gameMatching`, `gameMultipleChoice`, `gameRecall`, `gameTyping`, `studyExitTitle`, `studyExitBody`,
   `commonCancel`, `studyExitConfirm`). Nếu thêm/đổi bất kỳ chuỗi user-facing nào → thêm vào **cả hai** ARB cùng lúc rồi regen l10n.
   KHÔNG copy MOCK COPY từ kit ("학교"/"school"/"noun · a place of learning"/"Leave the session?"…) vào app/test.
5. **Viết test** `test/presentation/features/study/study_session_parity_test.dart` — COPY `review_parity_test.dart`, đổi:
   - đường dẫn contract `review.*` → `study-session.*`;
   - import + host dựng `StudySessionScreen(nodeId: deckId, entry: ...)` thay `ReviewScreen` (constructor cần `nodeId` + `entry` —
     xem FE `:30-42`); seed pair ko→vi + deck + N card `term:'학교'` (giống `study_session_test.dart` seed + `review_parity_test` host);
   - drive state: `stage1-review` = seed 1 card + `entry: StudyEntry.newLearn`, pump vòng `for` 50ms (card present). Với các state
     stage game (`stage2..5`, `due-review`): cần đẩy `stageIndex`/entry để card absent — hai lối:
       (a) **đơn giản, khuyến nghị**: với `due-review` seed `entry: dueReview` (+ srs row như `study_session_test` D-007) → card absent
       ngay; với `stage2..5` gọi `ref.read(studySessionProvider(req).notifier).grade(true)` đủ số lần để lên đúng `stageIndex`
       trước/giữa các nhịp pump (dùng `tester.element(...)` / `ProviderScope.containerOf` để lấy container, hoặc host giữ tham chiếu
       notifier như pattern `study_session_test`). Nếu drive từng stage quá phức tạp trong widget test → (b) **gộp**: chỉ gate
       `stage1-review` (card present) + 1 state game bất kỳ đạt được sạch (card absent) + `due-review` (card absent), hạ các stage
       còn lại xuống documented coverage-gap và GHI RÕ trong header test + report. KHÔNG viết assertion giả chỉ để có state.
   - Template A vòng `if (node['component'] != 'MxCard') continue;` ⇒ test chỉ thực chất assert `study-session/card` present ở
     `stage1-review`, absent ở các state `[]`. Note rõ: `next`/`exit-*` không phải MxCard nên KHÔNG bị test A gate (coverage note).
   - pump vòng `for` (KHÔNG `pumpAndSettle`).
6. **Xoá 2 skeleton**: `study-session.slots.skeleton.json` + `study-session.states.skeleton.json` sau khi curate ra bản chính
   (giống review/dashboard/library — skeleton là AUTO-PROPOSED, không ship).
7. **Cập nhật queue**: đổi ô tương ứng `study-session` → `[x]` trong `docs/agent/kit-to-flutter/README.md` cùng commit.

## 8. Hard rules (vi phạm = task fail)

- **KHÔNG vẽ lại/di chuyển UI** trong prompt này; chỉ curate contract + xác nhận ValueKey + viết test. Divergence THẬT → DỪNG/báo, không tự sửa.
- **Token-only**: không hardcode màu, radius, spacing, text style, duration, chuỗi user-facing. Dùng `Mx*` widget + theme token + `MxSpacing`.
- **Không node-literal hoist sau dynamic key**: mỗi `ValueKey('mx-node:...')` phải là `const`, gắn node tĩnh; không sinh key theo index/state.
- **intent-ledger ĐÃ CÓ SẴN** mục study-session — KHÔNG thêm trùng; kỳ vọng 0 mục mới. Không thêm ledger để hợp thức hoá một BUG.
- **l10n cả hai ARB**: mọi chuỗi mới vào `app_en.arb` **và** `app_vi.arb` cùng commit; regen l10n; không sửa `lib/l10n/generated/**` tay.
- **KHÔNG copy MOCK COPY** từ kit spec vào app/test làm assert văn bản (kit không mang l10n key).
- Không sửa file generated (`*.g.dart`, `*.freezed.dart`, `study-session.gen.json`, `docs/_generated/**`, `lib/l10n/generated/**`).
- Không thêm dependency mới (Stop & ask nếu cần).
- **KHÔNG đổi hành vi SRS/schedule** (D-002/D-007/D-014/D-015/D-017: NewLearn chỉ lên box 1 sau đủ 5 stage; DueReview chấm SRS).
  Task này thuần style-parity ⇒ không chạm notifier/logic.
- **KHÔNG ship skeleton làm curated**; trim rồi xoá 2 skeleton.
- **KHÔNG bịa state** không drive được sạch (relearn/resume-error/answer-save-error) → hạ xuống coverage-gap và báo.
- Doc-code parity: task thuần style-parity ⇒ nhiều khả năng `WBS update: not needed` + không đổi business doc; xác nhận rồi ghi rõ.
  Nếu chạm behavior/route user-visible → update doc tương ứng cùng commit.

## 9. Verification

```bash
node tool/verify/run.mjs --full
```

Phải PASS (viết pass-marker cho pre-commit hook). Gồm test parity mới + freshness check của specs. Nếu `--full` fail hoặc bị
skip → KHÔNG được báo done. Trong lúc dev có thể `--quick` (không marker) và chạy riêng
`flutter test test/presentation/features/study/study_session_parity_test.dart`.

Sau khi verify PASS, TRƯỚC final report: fan-out song song `code-reviewer` (review working-tree diff — cho nó chạy
`git add -N . && git diff`, KHÔNG commit trước) + `docs-drift-detector`. Gộp findings vào mục "Subagent review", fix blocker trước khi kết.

## 10. Commit (2 commit + WBS)

**Commit 1** — impl (contract + FE align + test):
```
feat(parity): style-parity — study-session — Template A, card gate (stage1 present / stages+due absent)

- curate tool/parity/contracts/study-session.slots.json (card: term displayLarge + meaning bodyLarge, FE truth)
- curate tool/parity/contracts/study-session.states.json (6 drivable states; relearn/exit/resume/save-error coverage gap)
- add test/presentation/features/study/study_session_parity_test.dart (Template A, copy review_parity_test)
- remove consumed skeletons (study-session.{slots,states}.skeleton.json)
- confirm 6 keyed nodes (screen/appbar/card/next/exit-cancel/exit-ok); game-owned controls stay game-* (intent-ledger)

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>
```

**Commit 2** — WBS trace + queue:
```
docs(parity): mark study-session done in kit-to-flutter queue + WBS traceability

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>
```
- Append 1 dòng vào Commit Traceability Log (§10 `docs/project-management/wbs.md`), newest first:
  `<8-char hash> · 2026-07-01 · <WBS IDs> · style-parity study-session (Template A; card stage1-gate, stages+due absent, 4 states coverage gap; ledger unchanged)`.
- Đổi ô `study-session` → `[x]` trong `docs/agent/kit-to-flutter/README.md` (cùng commit impl hoặc trace).
- Nếu WBS không đổi task breakdown, report ghi `WBS update: not needed — <reason>` (Commit Traceability Log vẫn append nếu advance WP).

## 11. Final report format

```
## study-session — kit→flutter DONE
- Template: A (review-style, MxCard identity per-state)
- Gate-able nodes (keyed FE): screen, appbar, card(MxCard elevated), next, exit-cancel, exit-ok  [6]  (chỉ card là MxCard → node gate chính)
- Contracts: study-session.slots.json + study-session.states.json curated; 2 skeleton deleted
- States driven: stage1-review (card present) · stage2-matching/stage3-choice/stage4-recall/stage5-typing/due-review (card absent — game body)
- Coverage gap (4): relearn (re-queue không keyed), exit (overlay non-MxCard — Template A không gate), resume-error + answer-save-error (không tồn tại ở v1)
- Divergences → intent-ledger: 0 mục mới (study-session đã có sẵn: reveal/check/hint/options/due/resume/save-error + styleExempt next.font)
- Identity-rollout gap (chưa key/không FE): reveal, check, hint, options, due-next, due-relearn, resume-*, save-error-*, progress, close, appbar-options
- l10n: studyContinue/studyStageReview/studyDueReview/game*/studyExit*/commonCancel đã có ở app_en.arb + app_vi.arb [no new keys | new keys: ...]
- Docs updated: <list | none — style-parity only>
- WBS update: <line appended | not needed — reason>
- Verify: node tool/verify/run.mjs --full → PASS
- Subagent review: <blockers fixed | minor findings ...>
```
