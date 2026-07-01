# Kit → Flutter conversion prompt — **study-result**

> SELF-CONTAINED. Đọc hết file này rồi thực thi tuần tự. Không cần đọc file prompt nào khác.
> Nhiệm vụ: đóng **state-composition parity gate** cho màn `study-result` (KHÔNG vẽ lại UI —
> UI kết-thúc-phiên đã có sẵn trong `study_session_screen.dart`; việc ở đây là **curate contract
> + viết 1 test composition** theo Template B, và align identity/l10n theo FE truth).
> Nếu gặp DRIFT hoặc DIVERGENCE cần người quyết → DỪNG, báo theo mẫu `DRIFT DETECTED` trong
> `CLAUDE.md`, chờ.

---

## PROMPT ID

`kit-to-flutter/study-result` · screen `study-result` · feature `study` · 7 kit state(s).
FE: `lib/presentation/features/study/screens/study_session_screen.dart` — study-result **KHÔNG phải
route riêng**, nó là **nhánh finished** của study-session (`state.finished == true` → method
`_result(l10n, state)` render trong cùng `MxScaffold` của study-session).

Kit states: `standard` · `goal-met` · `goal-missed` · `many-wrong` · `finalizing` ·
`retry-finalize` · `finalize-error`.

---

## Baseline

```bash
git checkout main
git pull --ff-only
git checkout -b claude/kit-to-flutter-study-result
```

Không bắt đầu khi working tree bẩn. Xác nhận `node tool/verify/run.mjs --quick` xanh trước khi sửa.

---

## Required reading (đọc trước khi code)

Universal (theo `CLAUDE.md`): `docs/_generated/repo-map.md`, `docs/_generated/where-is.md`,
`docs/business/index.md`, `docs/business/glossary.md`, `docs/contracts/error-contract.md`,
`docs/contracts/types-catalog.md`, `docs/contracts/code-style.md`.

Screen-specific — CHỈ đọc đúng các file này:
- `docs/design/MemoX Design System/ui_kits/memox-app/specs/study-result.md` — token-resolved DOM,
  7 state (base `standard` + 3 diff `goal-met`/`goal-missed`/`many-wrong` + 3 full
  `finalizing`/`retry-finalize`/`finalize-error`).
- `tool/parity/contracts/study-result.gen.json` — 9 keyed node (key/component/variant).
  **Đã xác minh: có ĐÚNG 1 MxCard = `study-result/goal` (primarySoft) — nhưng FE KHÔNG key nó**
  (xem template decision). **KHÔNG sửa** (generated).
- `tool/parity/contracts/study-result.slots.skeleton.json` — slot skeleton (superset).
- `tool/parity/contracts/study-result.states.skeleton.json` — per-state node membership (SUPERSET, phải trim).
- FE: `lib/presentation/features/study/screens/study_session_screen.dart` — đọc kỹ method
  `_result()` (dòng ~159–198) + `grade()` / `_finalize()` trong
  `lib/presentation/features/study/viewmodels/study_session_notifier.dart`.
- Test pump-pattern hiện có (dùng làm khuôn seed/reach-finished): `test/presentation/features/study/study_session_test.dart`.
- **Reference test cần COPY (Template B):** `test/presentation/features/engagement/dashboard_states_test.dart`.
- Curated mẫu để bắt chước format: `tool/parity/contracts/dashboard.states.json`, `dashboard.slots.json`.
- Contrast (KHÔNG áp dụng ở đây, chỉ để hiểu vì sao loại): `test/presentation/features/study/review_parity_test.dart`
  (Template A, MxCard-rich) + `tool/parity/contracts/review.slots.json` / `review.states.json`.
- Intent-ledger: `tool/parity/intent-ledger.json` — **đã có sẵn** 7 mục `study-result`
  (`appbar`, `goal`, `review-wrong`, `later`, `finalize`, `continue.font`, `library.*`). Đọc trước.

**Drift check trước khi code:** study-result là finished-state của study-session; SRS được grade
tuần tự trong lúc phiên chạy (D-007 DueReview grade từng card; D-002 NewLearn schedule box 1 sau 5
stage), `_finalize()` cộng daily-activity (D-010) **đồng bộ** trong `grade()` — KHÔNG có surface
async loading/error. Spec kit vẽ `finalizing`/`retry`/`error` như một pha lưu-kết-quả riêng có thể
fail — FE **không có** pha đó (đã ghi ledger `finalize`). Đây là **divergence có chủ đích đã
document**, KHÔNG phải drift → tiếp tục. Nếu bạn phát hiện FE thực sự đã thêm surface finalize async
(khác mô tả này) → DỪNG, báo, vì contract/ledger sẽ cần cập nhật.

---

## CHOSEN template: **B — state-composition** (KHÔNG phải Template A)

**Vì sao B (dù gen.json có 1 MxCard):** `study-result.gen.json` có `study-result/goal` = `MxCard`
(`primarySoft`) — NHƯNG **FE không render và không key node goal** (goal/streak được surface ở
dashboard Today, không ở result — đã ghi intent-ledger `study-result/goal`). Grep `mx-node:study-result`
trong `lib/` cho ĐÚNG 3 key, **không có MxCard nào**:

```
study_session_screen.dart:161  mx-node:study-result/screen     (MxContentBounds)
study_session_screen.dart:181  mx-node:study-result/continue   (MxButton primary)
study_session_screen.dart:188  mx-node:study-result/library    (MxButton secondary)
```

→ Không có MxCard keyed để vòng kiểu review (Template A rỗng). Đúng khuôn là **assert tập keyed node
render CHÍNH XÁC theo state** (thừa = THỪA, thiếu = THIẾU) — y hệt `library_states`/`dashboard_states_test.dart`.

> KHÔNG dùng Template A: `_result()` không có MxCard keyed; các stat-card (`stat-0..2`) và goal-card
> của kit KHÔNG tồn tại trong FE (result chỉ report words + accuracy dạng MxText — ledger `goal`).

---

## Gate-able node list (keyed trong FE — đã xác minh bằng grep)

| key | component (gen) | variant (gen) | FE hiện tại | render trong state |
| --- | --- | --- | --- | --- |
| `mx-node:study-result/screen` | MxScaffold | null | `MxContentBounds` (bọc trong study-session's `MxScaffold`) — **divergence, ledger `appbar`** | finished (mọi biến thể) |
| `mx-node:study-result/continue` | MxButton | primary | ✓ MxButton (default = primary) | finished |
| `mx-node:study-result/library` | MxButton | ghost | ⚠ MxButton `secondary` (divergence — ledger `library.*`) | finished |

> **Sự thật FE (khác gen.json/kit):** `study-result/screen` không phải MxScaffold — result là nhánh
> body của study-session's scaffold (`study-session/screen` + `study-session/appbar` là chrome thật).
> Kit lại vẽ result như một app riêng có `study-result/appbar` + `study-result/close`. Đây là
> **divergence đã có ledger** (`study-result/appbar`, exceptionKind behavior — "result là finished-state
> của study-session, không phải route riêng"). ĐỪNG thêm `study-result/appbar` / `study-result/close`
> vào FE trong task này.

### Node trong gen.json NHƯNG KHÔNG keyed ở FE → identity-rollout / divergence gap (ghi nhận, KHÔNG ép)

- `mx-node:study-result/goal` (MxCard primarySoft) — goal/streak card; **không tồn tại trong FE
  result** (ledger `goal`: surface ở dashboard). GAP có chủ đích.
- `mx-node:study-result/review-wrong` (MxButton primary) — nút "review wrong"; v1 re-queue trong phiên
  (D-016), **không có** post-session wrong list (ledger `review-wrong`). GAP có chủ đích.
- `mx-node:study-result/later` (MxButton ghost) — nút "finish later"; v1 không defer phiên
  (ledger `later`). GAP có chủ đích.
- `mx-node:study-result/finalize-retry` + `mx-node:study-result/finalize-later` (MxButton) — recovery
  UI cho finalize-error; FE finalize đồng bộ, **không có** UI recovery (ledger `finalize`). GAP có chủ đích.
- Stat-card của kit (`study-result/stat-0..2`, `finalizing-stat-0..2`, `goal-bar`,
  `finalize-error`) — kit id, KHÔNG có trong `gen.json` như keyed component (chỉ là `card`/`div` trong
  spec DOM). FE result render words + accuracy bằng `MxText`, KHÔNG stat-card, KHÔNG key. GAP.

Liệt kê nguyên các gap này trong **final report** (mục "Identity-rollout / divergence gap"). KHÔNG
rollout key mới cho goal/review-wrong/later/finalize-* trong task này — đây là style-parity gate, không
phải feature; và các mục này đã là intended-divergence trong ledger.

---

## Per-state node SET (curate cho `study-result.states.json`)

Từ `study-result.states.skeleton.json`, **trim** SUPERSET (bỏ chrome `screen`/`appbar`/`close` không do
result-body điều khiển; bỏ node kit chưa keyed trong FE — goal/stat/finalize-*) xuống tập BODY keyed mà
FE THỰC render.

**FE reality:** `_result()` render **một node-set duy nhất bất kể goal-met / goal-missed / many-wrong** —
nó chỉ đổi text (`studyResultWords(count)` + `studyResultAccuracy(percent)`), KHÔNG đổi identity node.
Vì vậy 4 state kit `standard`/`goal-met`/`goal-missed`/`many-wrong` **ánh xạ về cùng 1 FE node-set**.
3 state `finalizing`/`retry-finalize`/`finalize-error` **không tồn tại** trong FE.

Tập gate đề xuất (chỉ node keyed FE, đã bỏ chrome; chỉ gate 1 state drivable + document phần còn lại là gap):

```jsonc
{
  "standard": ["mx-node:study-result/continue", "mx-node:study-result/library"]
}
```

- `standard` = phiên đã finished (words + accuracy + 2 nút). `continue` + `library` là 2 keyed body node.
- `goal-met` / `goal-missed` / `many-wrong` = **cùng node-set với `standard`** trong FE (chỉ khác text →
  không phân biệt được ở tầng identity). KHÔNG list riêng (thêm chỉ để "đủ" sẽ làm universe = giống
  standard, không gate thêm gì) — ghi rõ là coverage gap ở `$curated` note + header test.
- `finalizing` / `retry-finalize` / `finalize-error` = **không có trong FE** (finalize đồng bộ) →
  coverage gap.

> Vì chỉ có 1 state trong universe, gate này chủ yếu chốt: khi phiên finished, `continue`+`library`
> render (THIẾU nếu absent). Universe = {continue, library}. Đây là gate "identity ổn định của result
> body" — mỏng nhưng đúng FE truth; các state khác là gap được document, KHÔNG bịa.

### `study-result.slots.json` — quyết định

FE result có keyed **text binding thực** (khác library — library skip slots vì control-only):
- Tiêu đề `MxText.headline(l10n.studyResultTitle)` — headline role, l10n `studyResultTitle`.
- `MxText(l10n.studyResultWords(count))` — bodyMedium, bind `state.cards.length` (l10n plural).
- `MxText(l10n.studyResultAccuracy(percent))` — bodyMedium, bind `(accuracy*100).round()` (l10n).
- Nút `continue` label `studyContinue`; `library` label `studyToLibrary`.

**NHƯNG** 3 MxText tiêu đề/words/accuracy KHÔNG được key riêng (không có ValueKey), và Template B assert
theo **node-set** chứ không vòng slot theo MxCard. Do đó:
- **BỎ QUA `study-result.slots.json`** (giống library) — không có keyed text-slot node để bind role/l10n
  theo khuôn review. Ghi rõ lý do trong report. KHÔNG tạo file rỗng.
- Nếu muốn phủ text tiêu đề/words/accuracy: đó là việc của prompt/parity khác (cần key `study-result/title`
  / `.../summary` — chưa rollout). Ghi vào identity-rollout gap.

---

## State-map: state nào drive được / state nào là coverage gap

FE reach finished bằng cách **hoàn tất 1 phiên DueReview 1-card** (per WBS/pump note): seed 1 card +
`srs_state` due (`dueAt: 0`), mở `StudySessionScreen(nodeId: deckId, entry: StudyEntry.dueReview)`,
`RecallGame` render → tap reveal + "remembered" (grade correct) → `pending` rỗng → `_finalize` + `finished:true`
→ `_result()`. (Xem `study_session_test.dart` cho seed pattern; W3/D-007.)

| kit state | drivable trong FE? | cách drive | node-set FE |
| --- | --- | --- | --- |
| `standard` | ✅ | finish 1-card DueReview (seed srs due `dueAt:0`, reveal+remembered) | `continue`, `library` |
| `goal-met` | ⚠️ | FE result KHÔNG có node goal-met riêng — chỉ khác text; **cùng node-set standard** | (= standard) → **coverage gap** (identity không phân biệt) |
| `goal-missed` | ⚠️ | như trên — chỉ khác text | (= standard) → **coverage gap** |
| `many-wrong` | ⚠️ | FE result KHÔNG có nút review-wrong (ledger); chỉ khác text | (= standard) → **coverage gap** |
| `finalizing` | ❌ | `_finalize()` await đồng bộ trong `grade()`; KHÔNG có loading surface | — → **coverage gap** (không tồn tại FE) |
| `retry-finalize` | ❌ | không có retry loop trong FE | — → **coverage gap** |
| `finalize-error` | ❌ | finalize không expose error UI (ledger `finalize`) | — → **coverage gap** |

→ **Gate 1 state:** `standard`. **6 state là coverage gap** (goal-met/goal-missed/many-wrong = same FE
node-set; finalizing/retry-finalize/finalize-error = không tồn tại FE). Ghi thẳng trong header test
(giống `review_parity_test` giải thích state không map) và trong `$curated` note của states.json.

> Nếu khi code, reveal/remembered của `RecallGame` không phát ra grade sạch trong widget test (vd cần
> pump nhiều nhịp / gesture khó), thử drive qua notifier trực tiếp như `study_session_test.dart`
> (`notifier(request).grade(true)`) rồi `ref.watch` state finished, HOẶC pump vòng `for` 50ms như
> `review_parity_test` (KHÔNG `pumpAndSettle` nếu có spinner `MxStateView.loading`). Nếu vẫn không reach
> finished sạch → DỪNG, báo (đừng bịa test). Không được assert trên `_message`/loading branch.

---

## Divergences → intent-ledger (ĐÃ CÓ SẴN — chỉ verify, ĐỪNG ép FE về kit)

`tool/parity/intent-ledger.json` **đã chứa** 7 mục `study-result`. Đọc & xác nhận còn đúng; **KHÔNG**
sửa FE để khớp kit ở các điểm này:

1. `study-result/appbar` (behavior) — result là finished-state của study-session, không route riêng;
   reuse `study-session/appbar`. → không thêm appbar/close vào FE.
2. `study-result/goal` (behavior) — goal/streak surface ở dashboard, result chỉ words + accuracy.
3. `study-result/review-wrong` (behavior) — v1 re-queue trong phiên (D-016), không post-session wrong list.
4. `study-result/later` (behavior) — v1 không defer phiên.
5. `study-result/finalize` (behavior) — SRS grade đồng bộ khi phiên chạy; không finalize-later/retry UI.
6. `study-result/continue` (font) — kit label 20px; FE labelLarge 15px (fill/màu = primary khớp).
7. `study-result/library` (*) — kit accent-soft fill + primary-strong text; FE MxButton `secondary`
   (primary-soft / on-primary-soft) — design-system không có accent-soft button variant; emphasis
   (primary continue + soft library) khớp kit.

**Nếu tất cả 7 mục đã có và còn đúng → KHÔNG append gì mới.** Chỉ append/sửa ledger nếu bạn phát hiện
một divergence CHƯA được ghi (khó xảy ra). Sau khi verify, các divergence này KHÔNG được làm fail parity
test (test B chỉ assert node-set {continue, library}; không assert appbar/goal/review-wrong/later/finalize).

Nếu bất kỳ mục nào thực chất là **BUG** (không phải chủ ý) → **DỪNG**, báo mẫu DRIFT, chờ người. Không tự
sửa UI trong prompt này.

---

## Workflow (thực thi tuần tự, mỗi bước một layer)

1. **Curate `tool/parity/contracts/study-result.states.json`** từ skeleton: chỉ state `standard`, chỉ
   node keyed FE `study-result/continue` + `study-result/library` (bỏ chrome `screen`/`appbar`/`close`;
   bỏ goal/stat/finalize-* chưa keyed). Thêm `$curated` header (bắt chước `dashboard.states.json`) giải
   thích: goal-met/goal-missed/many-wrong = cùng FE node-set (chỉ khác text → gap); finalizing/retry/error
   = không tồn tại FE (finalize đồng bộ → gap); lý do từng cái.
2. **`study-result.slots.json`: BỎ QUA** — ghi lý do (result text tiêu đề/words/accuracy KHÔNG key riêng;
   không có keyed MxCard/text-slot node để bind role theo khuôn review). Không tạo file rỗng.
3. **Align FE** `study_session_screen.dart` (method `_result()`) — CHỈ khi cần cho identity, KHÔNG vẽ lại:
   - Xác nhận 3 key `study-result/screen|continue|library` đúng chính tả (grep confirm). KHÔNG hoist
     node-literal sau dynamic key; mỗi `ValueKey('mx-node:...')` là `const`.
   - `continue` = MxButton primary (default) — đúng; `library` = MxButton `secondary` (giữ, ledger).
   - KHÔNG thêm node mới cho goal/stat/appbar/close/review-wrong/later/finalize (ngoài scope + intended gap).
   - KHÔNG hardcode màu/spacing/text-style/duration; string từ ARB.
4. **l10n**: các key `studyResultTitle`, `studyResultWords`, `studyResultAccuracy`, `studyContinue`,
   `studyToLibrary` **đã có** trong `lib/l10n/app_en.arb` (đã verify). Nếu bạn thêm/đổi bất kỳ chuỗi
   user-facing nào → thêm vào **cả hai** `app_en.arb` **và** `app_vi.arb` cùng commit rồi regen l10n;
   KHÔNG sửa `lib/l10n/generated/**` tay. KHÔNG copy MOCK COPY từ kit spec ("Session complete",
   "You reviewed 24 cards…", "Keep studying", "12 days"…) vào app/test làm assert.
5. **Viết test composition** `test/presentation/features/study/study_result_states_test.dart`:
   COPY cấu trúc `dashboard_states_test.dart` (đọc `study-result.states.json`, tính `universe`,
   assert mỗi key trong universe: allowed → `findsOneWidget` (THIẾU nếu absent), ngoài allowed →
   `findsNothing` (THỪA nếu present)). **Reach state** bằng pump-pattern của `study_session_test.dart` +
   `review_parity_test.dart`:
   - seed Drift in-memory: `languagePair` (ko→vi) + `deck` + **1 card**; upsert `SrsState(cardId, box:1, dueAt:0)`
     để card DueReview đến hạn (dùng `SrsDao`/`SrsRepositoryImpl` như `study_session_test.dart`);
   - override `databaseProvider` + `clockProvider(_FixedClock)`;
   - `pumpWidget(host)` với `StudySessionScreen(nodeId: deckId, entry: StudyEntry.dueReview)`;
   - drive tới finished: hoặc (a) tap reveal + remembered trên `RecallGame` (pump vòng `for` 50ms), hoặc
     (b) đọc notifier `grade(true)` trực tiếp rồi pump — chọn cách reach finished sạch nhất;
   - Header test giải thích rõ 6 state coverage gap (goal-met/goal-missed/many-wrong cùng node-set;
     finalizing/retry/error không tồn tại FE) — giống `review_parity_test` giải thích state không map.
6. **Xóa skeleton** đã tiêu thụ: `tool/parity/contracts/study-result.states.skeleton.json` **và**
   `tool/parity/contracts/study-result.slots.skeleton.json` (skeleton là AUTO-PROPOSED, không ship —
   theo ghi chú `$skeleton`; slots skeleton xóa dù ta skip slots.json vì đã quyết định không dùng).
7. **Cập nhật queue**: đổi `[ ] 12-study-result.md` → `[x]` trong `docs/agent/kit-to-flutter/README.md`.
8. **Doc parity**: task thuần style-parity gate — thường chỉ cần intent-ledger (đã có). Nếu có divergence
   ảnh hưởng behavior đã ghi ở `docs/business/**` mà chưa document → cập nhật cùng commit. Chạy Pre-commit
   parity check 8 bước (`CLAUDE.md`) trước khi kết.

---

## Hard rules (vi phạm = fail — trích `CLAUDE.md`)

- KHÔNG vẽ lại/di chuyển UI trong prompt này; chỉ curate contract + viết test + align identity tối thiểu.
  Divergence → ledger (đã có), KHÔNG tự sửa FE về kit.
- KHÔNG thêm node kit không có trong FE (goal/stat/appbar/close/review-wrong/later/finalize-*) — intended gap.
- **Token-only**: không hardcode màu, radius, spacing, text style, duration, chuỗi user-facing.
  Dùng `Mx*` widget + theme token + `MxSpacing`.
- KHÔNG node-literal hoist sau dynamic key; mỗi `ValueKey('mx-node:...')` là `const` node tĩnh.
- KHÔNG copy MOCK COPY từ kit spec vào app/test; string lấy từ ARB (`lib/l10n/`).
- **l10n cả hai ARB**: mọi chuỗi mới vào `app_en.arb` **và** `app_vi.arb` cùng commit; regen l10n;
  không sửa `lib/l10n/generated/**` tay.
- KHÔNG ship skeleton làm curated; phải trim rồi xóa cả 2 skeleton.
- KHÔNG bịa state finalize/error nếu FE không có → coverage gap + báo. KHÔNG viết test giả để "đủ" 7 state.
- KHÔNG sửa generated (`*.g.dart`, `*.freezed.dart`, `study-result.gen.json`, `lib/l10n/generated/**`,
  `docs/_generated/**`).
- KHÔNG thêm dependency mới (Stop & ask nếu cần).
- KHÔNG đổi hành vi SRS/schedule (D-002/D-007/D-010/D-016): grade tuần tự, finalize đồng bộ — giữ nguyên.
- KHÔNG đánh dấu done nếu `node tool/verify/run.mjs --full` chưa xanh.

---

## Verification

```bash
node tool/verify/run.mjs --full
```

Phải XANH (ghi pass-marker mà pre-commit hook yêu cầu) — gồm test parity mới + freshness check của specs.
Nếu đỏ hoặc bị skip → sửa, KHÔNG commit vòng qua / KHÔNG báo done. Trong lúc dev có thể `--quick`
(không marker). Chạy riêng test mới để chắc:
`flutter test test/presentation/features/study/study_result_states_test.dart`.

Sau khi verify PASS, TRƯỚC final report: fan-out song song `code-reviewer` (review working-tree diff —
cho nó chạy `git add -N .` rồi `git diff`, KHÔNG commit trước) + `docs-drift-detector`. Gộp kết quả vào
mục "Subagent review". Sửa blocker trước khi xong; list minor findings cho user.

---

## Commit (2 commit + WBS)

**Commit 1** — contract + test + FE align:
```
test(parity): study-result state-composition gate (standard) + curated states.json

- curate tool/parity/contracts/study-result.states.json (1 gated state; 6 coverage gaps documented)
- add test/presentation/features/study/study_result_states_test.dart (Template B, copy dashboard_states_test)
- remove consumed skeletons (study-result.states.skeleton.json, study-result.slots.skeleton.json)
- study-result.slots.json intentionally skipped (result summary text not keyed; no keyed MxCard/text-slot node)

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>
```

**Commit 2** — queue + WBS trace:
```
docs(parity): mark study-result done in kit-to-flutter queue

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>
```

**WBS** (bắt buộc, `CLAUDE.md` §WBS): append 1 dòng vào Commit Traceability Log (§10 của
`docs/project-management/wbs.md`), newest first:
`<8-char hash> · 2026-07-01 · <WBS IDs> · study-result kit→flutter state-composition parity (Template B; standard gated, goal-met/goal-missed/many-wrong same node-set + finalizing/retry/error not-in-FE coverage gap)`.
Nếu WBS task-breakdown không bị ảnh hưởng, report ghi `WBS update: not needed — <reason>` (nhưng Commit
Traceability Log VẪN append nếu advance WP kit→flutter).

Đổi ô `[ ] 12-study-result.md` → `[x]` trong `docs/agent/kit-to-flutter/README.md` cùng commit 2.

---

## Final report (đưa vào tin nhắn cuối)

```
## study-result — kit→flutter DONE
- Template: B (state-composition) — lý do: 0 MxCard keyed trong FE (goal MxCard là intended gap, surface ở dashboard)
- Gate-able keyed node (FE): screen(MxContentBounds), continue(MxButton primary), library(MxButton secondary) [3]
  (chrome study-session/screen+appbar reuse; screen/appbar/close của kit loại khỏi gate)
- Contracts: study-result.states.json curated (1 state: standard); slots.json intentionally skipped; 2 skeleton deleted
- States driven: standard (finish 1-card DueReview, srs dueAt:0, reveal+remembered).
  Coverage gap [6]: goal-met/goal-missed/many-wrong (cùng FE node-set — chỉ khác text),
  finalizing/retry-finalize/finalize-error (không tồn tại FE — finalize đồng bộ)
- Divergences → intent-ledger (đã có 7 mục, verify không append): appbar, goal, review-wrong, later, finalize, continue.font, library.*
- Identity-rollout / divergence gap (kit node không key trong FE): goal, stat-0..2, goal-bar, review-wrong, later, finalize-retry, finalize-later, finalizing-stat-*, finalize-error, appbar, close
- l10n: studyResultTitle/studyResultWords/studyResultAccuracy/studyContinue/studyToLibrary đã có ở app_en.arb + app_vi.arb [no new keys | new keys: ...]
- Docs updated: <list | none — style-parity only; intent-ledger đã có>
- WBS update: <line appended | not needed — reason>
- Verify: node tool/verify/run.mjs --full → PASS
- Subagent review: <blockers fixed | minor findings ...>
```
