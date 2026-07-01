# Kit → Flutter conversion prompt — **flashcard-editor**

> SELF-CONTAINED. Đọc hết file này rồi thực thi tuần tự. Không cần đọc file prompt nào khác.
> Nhiệm vụ: đóng **state-composition parity gate** cho màn `flashcard-editor` (KHÔNG vẽ lại UI —
> UI đã có; việc ở đây là **curate contract + viết 1 test composition** theo Template B).
> Nếu gặp DRIFT hoặc DIVERGENCE cần người quyết → DỪNG, báo theo mẫu `DRIFT DETECTED` trong
> `CLAUDE.md`, chờ người. Không tự sửa UI trong prompt này.

---

## PROMPT ID

`kit-to-flutter/flashcard-editor` · screen `flashcard-editor` · feature `flashcard` · 6 kit state(s).
FE: `lib/presentation/features/flashcard/screens/flashcard_editor_screen.dart` — **FORM** screen
(`ConsumerStatefulWidget`, states create / edit / validation / duplicate / multi-meaning / audio).

---

## 1. Baseline

```bash
git checkout main
git pull --ff-only
git checkout -b claude/kit-to-flutter-flashcard-editor
```

Không bắt đầu khi working tree bẩn. Xác nhận `node tool/verify/run.mjs --quick` xanh trước khi sửa.

## 2. Required reading (đọc trước khi code)

Universal (theo `CLAUDE.md`): `docs/_generated/repo-map.md`, `docs/_generated/where-is.md`,
`docs/business/index.md`, `docs/business/glossary.md`, `docs/contracts/error-contract.md`,
`docs/contracts/types-catalog.md`, `docs/contracts/code-style.md`.

Screen-specific — CHỈ đọc đúng các file này:
- `docs/design/MemoX Design System/ui_kits/memox-app/specs/flashcard-editor.md` — token-resolved DOM,
  base `create` + 5 diff (edit / validation / duplicate / multi-meaning / audio).
- `tool/parity/contracts/flashcard-editor.gen.json` — 8 keyed node (key/component/variant). **KHÔNG sửa** (generated). **Đã xác minh: 0 MxCard.**
- `tool/parity/contracts/flashcard-editor.slots.skeleton.json` — slot skeleton (superset).
- `tool/parity/contracts/flashcard-editor.states.skeleton.json` — per-state node membership (SUPERSET, phải trim).
- FE: `lib/presentation/features/flashcard/screens/flashcard_editor_screen.dart`.
- **Reference test cần COPY (Template B):** `test/presentation/features/engagement/dashboard_states_test.dart`.
- Curated mẫu để bắt chước format: `tool/parity/contracts/dashboard.states.json`.
- Contrast (KHÔNG áp dụng ở đây, chỉ để hiểu vì sao loại): `test/presentation/features/study/review_parity_test.dart` (Template A, MxCard-rich).
- Business truth về form editor + soft-dup D-020: `docs/business/flashcard/flashcard-management.md`.
- Ledger đang dùng: `tool/parity/intent-ledger.json` (đã có sẵn 3 mục `styleExempt` cho flashcard-editor — xem mục 5).

**Drift check trước khi code:** editor là form create/edit; Save disabled tới khi có term + primary
meaning; soft-dup (D-020) **cảnh báo chứ không chặn** (banner + "Add anyway" / "View existing").
FE (`_canSave`, `_save`, `_addAnyway`, `_buildDuplicateBanner`) khớp mô tả này → OK, tiếp tục.
Nếu FE mâu thuẫn spec ở hành vi (vd: dup **chặn** save; validation chặn typing) → DỪNG, báo DRIFT.

## 3. CHOSEN template: **B — state-composition** (KHÔNG phải Template A)

**Vì sao B:** `flashcard-editor.gen.json` có **0 node `MxCard`**. Đây là **form** — 8 node của nó là
`MxScaffold` (`.../screen`), `MxAppBar` (`.../appbar`), `MxButton` (`.../save` primary,
`.../add-meaning` ghost, `.../dup-add` primary, `.../dup-view` ghost),
`MxIconButton` (`.../audio-play`), `MxSwitch` (`.../hidden-switch`). Các field (Term/Meaning) là
`TextField` với `InputDecoration`, không phải MxCard/MxTextField keyed literal. Không có slot MxCard
cố định để gate kiểu review.

→ Đúng khuôn là **assert tập keyed node render CHÍNH XÁC theo từng state** (thừa = THỪA,
thiếu = THIẾU) — y hệt `dashboard_states_test.dart`. KHÔNG dùng Template A (không có MxCard để vòng).

## 4. Gate-able node list (keyed trong FE — đã xác minh bằng grep)

Grep `mx-node:flashcard-editor/` trong `lib/` cho ra ĐÚNG 8 literal keyed sau (đối chiếu `.gen.json`):

| key | component (gen) | variant (gen) | FE hiện tại (dòng) | render trong state |
| --- | --- | --- | --- | --- |
| `mx-node:flashcard-editor/screen` | MxScaffold | null | ✓ MxScaffold (`:272`) | mọi state (chrome) |
| `mx-node:flashcard-editor/appbar` | MxAppBar | ghost | ✓ MxAppBar (`:274`) | mọi state (chrome) |
| `mx-node:flashcard-editor/save` | MxButton | primary | ✓ MxButton sm (`:284`) | mọi state (chrome, trong appbar trailing) |
| `mx-node:flashcard-editor/add-meaning` | MxButton | ghost | ✓ MxButton ghost sm (`:313`) | create/edit/validation/duplicate/audio (body) |
| `mx-node:flashcard-editor/hidden-switch` | MxSwitch | null | ✓ MxSwitch (`:333`) | body (mọi state có form) |
| `mx-node:flashcard-editor/audio-play` | MxIconButton | null | ⚠ MxButton **outline** ("Speak") (`:432`) — divergence, mục 5 | body |
| `mx-node:flashcard-editor/dup-add` | MxButton | primary | ✓ MxButton ghost sm (`:463`) | **CHỈ `duplicate`** (banner) |
| `mx-node:flashcard-editor/dup-view` | MxButton | ghost | ✓ MxButton ghost sm (`:470`) | **CHỈ `duplicate`** (banner) |

> **Node phân biệt state duy nhất = `dup-add` + `dup-view`** (chỉ có khi `_duplicateTerm != null`).
> `save` / `add-meaning` / `hidden-switch` / `audio-play` render ở MỌI state có form → KHÔNG phân biệt
> state; chúng vào universe nhưng không turn được THỪA. `screen` + `appbar` là chrome →
> theo mẫu dashboard/library, **loại khỏi tập gate** (không state-driven bởi body).

**Node trong `.gen.json`? — không.** `.gen.json` chỉ liệt kê đúng 8 node trên (không có `dup-warning`
trong gen). Nhưng `.states.skeleton.json` **có** `mx-node:flashcard-editor/dup-warning` (banner) và
`mx-node:flashcard-editor/meaning-2` (secondary meaning row) từ spec diff. Xử lý ở mục 6 + mục 7.

### Identity-rollout gap (nodes trong spec/skeleton nhưng CHƯA key literal `mx-node:` trong FE)

Ghi nguyên bộ này trong **final report** (mục "Identity-rollout gap"). KHÔNG rollout key mới trong task
này (đây là style/state-parity, không phải feature) trừ khi bạn cũng thêm hành vi thật.

- `mx-node:flashcard-editor/cancel` — kit là Cancel text-button; FE dùng `MxIconButton(Icons.close)`
  keyed `Key('editorClose')` (NON-mx) (`:275`) → identity chưa rollout literal `.../cancel`. Gap.
- `mx-node:flashcard-editor/term` / `.../meaning` — kit là field-block; FE là `TextField` keyed
  `Key('editorTermField')` (`:299`) / `Key('editorMeaningField')` (`:370`) (NON-mx). Gap (khác cả
  identity lẫn widget — form field vs kit block). Xem divergence mục 5 (keyboardType).
- `mx-node:flashcard-editor/gender` + `gender-0..3` — kit là label + 4 chip keyed; FE render
  `_buildGenderChips` = `Wrap` của `MxChip` **không key** (`:406`). Gap (chips chưa keyed).
- `mx-node:flashcard-editor/audio` — kit là field-block "Audio"; FE là `_buildAudioRow` (Row label +
  nút) không key ở container (chỉ nút con `audio-play` keyed). Gap.
- `mx-node:flashcard-editor/hidden` — kit là container card; FE render `ListTile` không key (chỉ
  `hidden-switch` con keyed) (`:328`). Gap.
- `mx-node:flashcard-editor/dup-warning` — banner container; FE keyed `Key('editorDuplicateBanner')`
  (NON-mx) (`:445`). Gap (identity chưa rollout literal, nhưng 2 nút con `dup-add`/`dup-view` ĐÃ keyed
  → dùng chúng làm proxy cho state `duplicate`).
- `mx-node:flashcard-editor/meaning-2` — secondary meaning row (kit `multi-meaning`); FE build động qua
  `_buildMeaningFields` loop (`:343`), field phụ **không key literal**. Gap (danh sách động, giống
  deck-tile ở library).

## 5. Divergences → `tool/parity/intent-ledger.json`

**Đã có sẵn** trong `intent-ledger.json > styleExempt` (KHÔNG thêm trùng):
1. `flashcard-editor/hidden-switch` field `*` — MxSwitch custom-paint, exporter không đọc bg/color/font/r.
2. `flashcard-editor/add-meaning` field `*` — kit surface-chip; FE ghost MxButton (low-emphasis).
3. `flashcard-editor/audio-play` field `*` — kit circular surface chip (r:9999); FE outline MxButton "Speak".

**Cần THÊM** (append; giữ format hiện có — `exceptions[]` cho behavior/identity, `styleExempt[]` cho style):

4. **`exceptions[]`** — `screen: flashcard-editor`, `node: audio-play`, `exceptionKind: "component"`,
   reason: `"kit models audio-play as MxIconButton (icon-only volume_up); the FE uses a labelled outline MxButton ('Speak') for a clearer affordance in the form, consistent with the design-system button variants."`,
   source: `docs/business/flashcard/flashcard-management.md`. (Đây là chệch COMPONENT có chủ đích — test
   composition chỉ assert present/absent theo key, KHÔNG assert component, nên divergence này không làm
   fail gate; ghi ledger để node_audit/spec_diff biết là intended.)
5. **`exceptions[]`** — `screen: flashcard-editor`, `node: term`, `exceptionKind: "behavior"`,
   reason: `"kit field-block is identity-only; the FE Term field is a Material TextField that MUST declare keyboardType/IME for the source language (Korean term entry) — see keyboardType note below."`,
   source: `docs/business/flashcard/flashcard-management.md`.

> **KeyboardType note (ghi vào ledger reason của mục 5, và nêu trong report):** kit spec KHÔNG khai báo
> `keyboardType` cho input nào (flat DOM không mang thuộc tính IME). FE **nên khai báo rõ**:
> - **Term** field: nhập ở source language (vd Korean) → cần IME ngôn ngữ nguồn. FE hiện KHÔNG set
>   `keyboardType` (mặc định `TextInputAction.next`). → ghi là **intended-to-declare**: nếu chạm field
>   này, thêm `keyboardType: TextInputType.text` (IME theo `_sourceLang()`; Flutter không có
>   per-locale keyboardType token nên để `TextInputType.text` + để IME hệ điều hành theo locale).
> - **Meaning** field: free text (multiline, `minLines:2 maxLines:5`) → `keyboardType: TextInputType.multiline`.
> Đây là **coverage gap của kit** (kit không nói IME) → FE là source of truth; KHÔNG cần sửa nếu task
> thuần state-parity, nhưng PHẢI ghi note trong ledger + report. Nếu bạn có chạm 2 field (vd khi align
> ValueKey), tranh thủ khai báo `keyboardType` cho đúng — token-only, không hardcode.

Nếu bất kỳ mục nào thực chất là **BUG** (không phải chủ ý) → **DỪNG**, báo DRIFT, chờ người.

## 6. State-map (kit state → cách drive FE tới đúng node-set)

FE là 1 `ConsumerStatefulWidget` điều khiển bởi `_termController`, `_meanings[]`, `_gender`, `_hidden`,
`_showTermError` / `_showMeaningError`, `_duplicateTerm`, `_loading`. Node-set BODY chỉ đổi khi
`_duplicateTerm != null` (hiện banner → `dup-add` + `dup-view`). Các state kit khác chỉ đổi **nội dung /
text / errorText / icon / số field**, KHÔNG đổi tập keyed literal node.

| kit state | FE reach được? | Cách drive | Node-set BODY (keyed literal) |
| --- | --- | --- | --- |
| `create` | ✅ | pump `FlashcardEditorScreen(deckId)` (cardId null) | `add-meaning`, `hidden-switch`, `audio-play` |
| `edit` | ✅ (= create node-set) | pump `FlashcardEditorScreen(deckId, cardId)` seed 1 card | = create (chỉ title + prefill khác, KHÔNG đổi node-set) |
| `validation` | ⚠️ (= create node-set) | gõ term rồi xoá / gõ meaning rồi xoá → `_showTermError`/`_showMeaningError` = errorText INLINE, không đổi node identity | = create → **coverage gap** (không phân biệt node-set) |
| `duplicate` | ✅ | seed 1 card term X vào deck; mở editor create, nhập term X, bấm Save → `CheckSoftDuplicateUseCase` true → `_duplicateTerm=X` → banner | create-set **+ `dup-add` + `dup-view`** |
| `multi-meaning` | ⚠️ | bấm `add-meaning` → thêm 1 `_MeaningField` phụ (dynamic, KHÔNG key literal `meaning-2`) | = create node-set → **coverage gap** (field phụ key động) |
| `audio` | ⚠️ (= create node-set) | kit chỉ đổi ICON `audio-play` (volume_up→sync "Generating…"); FE `audio-play` là nút Speak tĩnh, icon không đổi identity | = create → **coverage gap** (chỉ đổi nội dung/icon) |

**Kết luận gate:** **2 state phân biệt được** ổn định: `create` (baseline, không banner) và `duplicate`
(có banner → 2 nút dup). `edit`/`validation`/`multi-meaning`/`audio` **cùng node-set với `create`** →
là coverage gap (documented-not-differentiated), ghi rõ trong header test + `$curated`.

> Vì sao gate vẫn có giá trị dù chỉ 2 state: universe = hợp {add-meaning, hidden-switch, audio-play,
> dup-add, dup-view}. Assert `dup-add`/`dup-view` **absent** ở `create` và **present** ở `duplicate` —
> ĐÓ là chỗ gate bắt được THỪA (banner leak vào form sạch) / THIẾU (banner mất khi có dup).

### Curate `flashcard-editor.states.json` (trim skeleton → chỉ node BODY keyed FE, bỏ chrome)

```jsonc
{
  "create":    ["mx-node:flashcard-editor/add-meaning", "mx-node:flashcard-editor/hidden-switch", "mx-node:flashcard-editor/audio-play"],
  "duplicate": ["mx-node:flashcard-editor/add-meaning", "mx-node:flashcard-editor/hidden-switch", "mx-node:flashcard-editor/audio-play", "mx-node:flashcard-editor/dup-add", "mx-node:flashcard-editor/dup-view"]
}
```

- Bỏ `screen`/`appbar`/`save` khỏi tập gate (chrome; `save` sống trong appbar trailing → không
  state-driven bởi body). Giống dashboard loại `appbar`/`quick-review`, library loại `screen`/`appbar`.
- `$curated` header phải nêu rõ: 4 kit state `edit`/`validation`/`multi-meaning`/`audio` = **cùng
  node-set với `create`** (coverage gap — chỉ khác text/errorText/icon/số field động), và `meaning-2` /
  `dup-warning` / gender-chips không được gate literal (identity chưa rollout / key động).

## 7. slots.json — **BỎ QUA** (ghi rõ lý do trong report)

`flashcard-editor.slots.skeleton.json` liệt kê text của label/field/chip, nhưng các keyed literal FE ở
đây là **control** (button/icon-button/switch) không mang keyed text-slot cần bind role/l10n; các label
form (Term/Meaning/Gender/Audio/Hide) render qua `MxText.label` / `InputDecoration.labelText` /
`ListTile.title` **không key** literal. → **KHÔNG tạo `flashcard-editor.slots.json`** (đừng ship file
rỗng). Nếu muốn phủ text field/label, đó là việc của prompt identity-rollout khác (cần key literal cho
`term`/`meaning`/`gender-*` trước). Text nội dung (user term/meaning) là dữ liệu người dùng, KHÔNG l10n.

## 8. Workflow (thực thi tuần tự, mỗi bước một layer)

1. **Curate `tool/parity/contracts/flashcard-editor.states.json`** từ `.states.skeleton.json` theo mục 6:
   chỉ 2 state `create`/`duplicate`, chỉ node keyed FE, bỏ chrome. Thêm `$curated` header (bắt chước
   `dashboard.states.json`) giải thích 4 state còn lại là coverage gap + lý do (cùng node-set với create).
2. **`flashcard-editor.slots.json`: BỎ QUA** — ghi lý do (mục 7). Không tạo file rỗng.
3. **Align FE** `flashcard_editor_screen.dart` — xác nhận 8 ValueKey literal đúng chính tả (grep đã
   confirm). Mỗi `ValueKey('mx-node:...')` phải `const` gắn đúng node tĩnh; KHÔNG sinh key động theo
   index/state; KHÔNG hoist node-literal sau dynamic key. **KHÔNG** rollout key mới cho
   cancel/term/meaning/gender/audio/hidden/dup-warning/meaning-2 trong task này (ngoài scope). Nếu chạm
   Term/Meaning field → khai báo `keyboardType` đúng (mục 5): Term = `TextInputType.text` (IME nguồn),
   Meaning = `TextInputType.multiline`. KHÔNG hardcode màu/spacing/string — dùng `Mx*` + token + `MxSpacing`.
4. **l10n**: mọi key user-facing của màn (`editorTitleNew/editorTitleEdit/editorSave/editorTermLabel/
   editorTermHint/editorMeaningHint/editorAddMeaning/editorGenderLabel/editorAudioLabel/editorHiddenLabel/
   editorHiddenSubtitle/editorErrorTermRequired/editorErrorMeaningRequired/editorDuplicateMessage/
   editorDuplicateAddAnyway/editorDuplicateViewExisting/editorSaveError/audioSpeak/genderMasculine/
   genderFeminine/genderNeuter/comingSoon/commonCancel`) **đã có ĐỦ ở cả `lib/l10n/app_en.arb` và
   `lib/l10n/app_vi.arb`** (đã verify — no new key expected). Nếu thêm/đổi bất kỳ chuỗi nào → thêm vào
   **cả hai** ARB cùng lúc rồi regen l10n; KHÔNG sửa `lib/l10n/generated/**` tay. KHÔNG copy mock copy
   từ kit ("Enter a word…", "안녕하세요", "A card … already exists"…) vào app/test.
5. **Viết test composition** `test/presentation/features/flashcard/flashcard_editor_states_test.dart`:
   COPY cấu trúc `dashboard_states_test.dart`. Đọc `flashcard-editor.states.json`, tính `universe`,
   `recipes` seed cho từng state, pump `FlashcardEditorScreen`, assert mỗi key trong universe:
   allowed → `findsOneWidget` (THIẾU nếu absent), ngoài allowed → `findsNothing` (THỪA nếu present).
   Seed pattern giống review test: Drift in-memory (`languagePair` ko→vi + `deck` + card khi cần),
   override `databaseProvider` + `clockProvider(_FixedClock)`; host = `MaterialApp` + `Scaffold(body:
   FlashcardEditorScreen(deckId: deckId))`.
   - `create`: pump editor **deckId only** (cardId null), DB có deck rỗng. Pump vòng `for` 50ms (initState
     `_meanings.add(_primaryField)` không async — nhưng nếu isEditing thì `_loadCard` async → tránh
     `pumpAndSettle` nếu có `MxStateView.loading`; ở `create` không load nên có thể pump vài nhịp).
   - `duplicate`: seed 1 card term `'학교'` vào deck; pump editor create; `enterText` vào term field
     (`Key('editorTermField')`) = `'학교'`; `enterText` meaning field = 1 giá trị (để `_canSave`); pump;
     bấm Save (`find.byKey(ValueKey('mx-node:flashcard-editor/save'))`); pump → `_duplicateTerm` set →
     banner + `dup-add`/`dup-view` render. Assert composition.
   - Header test giải thích 4 state coverage gap (giống review_parity_test giải thích state không map).
6. **Xóa skeleton** đã tiêu thụ: `tool/parity/contracts/flashcard-editor.states.skeleton.json` **và**
   `tool/parity/contracts/flashcard-editor.slots.skeleton.json` (skeleton là AUTO-PROPOSED, không ship).
7. **Cập nhật queue**: đổi `[ ] 04-flashcard-editor.md` → `[x]` trong `docs/agent/kit-to-flutter/README.md`.
8. **Doc parity**: task thuần state-parity → nhiều khả năng chỉ cần intent-ledger (mục 5) + queue.
   Nếu có divergence chạm behavior đã ghi ở `docs/business/**` → update cùng commit. Xác nhận rồi ghi rõ.

## 9. Hard rules (vi phạm = task fail — trích `CLAUDE.md`)

- KHÔNG vẽ lại/di chuyển UI trong prompt này; chỉ curate contract + viết test. Divergence → ledger, không tự sửa.
- **Token-only**: KHÔNG hardcode màu, radius, spacing, text style, duration, chuỗi user-facing. Dùng
  `Mx*` widget + theme token + `MxSpacing`. String lấy từ ARB (`lib/l10n/`).
- **Không node-literal hoist sau dynamic key**; mỗi `ValueKey('mx-node:...')` là `const` tĩnh; không sinh key động.
- KHÔNG copy MOCK COPY từ kit spec vào app/test làm assert văn bản.
- KHÔNG ship skeleton làm curated; phải trim rồi XÓA cả 2 skeleton.
- KHÔNG bịa state/`duplicate` nếu không drive được sạch → hạ xuống coverage gap và báo. ĐỪNG viết test giả.
- KHÔNG rollout key literal mới cho cancel/term/meaning/gender/audio/hidden/dup-warning/meaning-2 (ngoài
  scope style-parity) trừ khi kèm hành vi thật + doc.
- KHÔNG sửa generated (`*.g.dart`, `*.freezed.dart`, `flashcard-editor.gen.json`, `lib/l10n/generated/**`, `docs/_generated/**`).
- KHÔNG thêm dependency mới (Stop & ask nếu cần).
- KHÔNG đổi hành vi soft-dup D-020 (cảnh báo, không chặn) hay validation (Save disabled, không chặn typing).
- KHÔNG đánh dấu done nếu `node tool/verify/run.mjs --full` chưa xanh.

## 10. Verification

```bash
node tool/verify/run.mjs --full
```

Phải PASS (viết pass-marker cho pre-commit hook). Trong đó có test parity mới + freshness check của specs.
Nếu `--full` fail hoặc bị skip → KHÔNG được báo done. Trong lúc dev có thể `--quick` (không marker).
Chạy riêng test mới để chắc: `flutter test test/presentation/features/flashcard/flashcard_editor_states_test.dart`.

Sau khi verify PASS, TRƯỚC final report: fan-out song song `code-reviewer` (review working-tree diff) +
`docs-drift-detector`. Gộp kết quả vào mục "Subagent review". Sửa blocker trước khi xong. (Bỏ fan-out
nếu diff thuần docs/contract + 1 test — nêu lý do.)

## 11. Commit (2 commit + WBS)

**Commit 1** — contract + test:
```
test(parity): flashcard-editor state-composition gate (create/duplicate) + curated states.json

- curate tool/parity/contracts/flashcard-editor.states.json (2 gated states; 4 coverage gaps documented)
- add test/presentation/features/flashcard/flashcard_editor_states_test.dart (Template B, copy dashboard_states_test)
- remove consumed skeletons (flashcard-editor.states.skeleton.json, flashcard-editor.slots.skeleton.json)
- flashcard-editor.slots.json intentionally skipped (no keyed text slot; form labels unkeyed)

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>
```

**Commit 2** — docs/ledger + queue:
```
docs(parity): flashcard-editor divergences → intent-ledger; mark done in kit-to-flutter queue

- add audio-play (component) + term (keyboardType note) exceptions to intent-ledger.json
- mark 04-flashcard-editor.md [x] in docs/agent/kit-to-flutter/README.md

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>
```

**WBS** (bắt buộc, `CLAUDE.md` §WBS): append 1 dòng Commit Traceability Log (§10 của
`docs/project-management/wbs.md`), newest first:
`<8-char hash> · <YYYY-MM-DD> · <WBS IDs> · flashcard-editor kit→flutter state-composition parity (Template B; create/duplicate gated, edit/validation/multi-meaning/audio coverage gap, audio-play+keyboardType → intent-ledger)`.
Nếu WBS task breakdown không đổi, report ghi `WBS update: not needed — <reason>` (nhưng Commit
Traceability Log vẫn append nếu advance WP).

## 12. Final report format

```
## flashcard-editor — kit→flutter DONE
- Template: B (state-composition) — lý do: 0 MxCard trong flashcard-editor.gen.json (FORM screen)
- Gate-able keyed node (FE): add-meaning, hidden-switch, audio-play, dup-add, dup-view  [+ chrome screen/appbar/save loại khỏi gate]  [5 body]
- Contracts: flashcard-editor.states.json curated (2 gated states); slots.json intentionally skipped; 2 skeleton deleted
- Gated states: create (no banner), duplicate (banner → dup-add/dup-view)
- Coverage gap (4): edit (= create node-set, chỉ title+prefill), validation (errorText inline, không đổi node), multi-meaning (field phụ key động), audio (chỉ đổi icon audio-play)
- Identity-rollout gap (chưa key literal trong FE): cancel, term, meaning, gender+gender-0..3, audio(container), hidden(container), dup-warning, meaning-2
- Divergences → intent-ledger: audio-play (MxButton outline vs MxIconButton — component) + term keyboardType note (kit không khai IME; FE nên: Term=text/IME nguồn, Meaning=multiline) [+ 3 styleExempt đã có: hidden-switch, add-meaning, audio-play]
- l10n: tất cả key editor* + gender*/audioSpeak/comingSoon/commonCancel đã có ở app_en.arb + app_vi.arb [no new keys]
- Docs updated: <intent-ledger + queue | none khác — state-parity only>
- WBS update: <line appended | not needed — reason>
- Verify: node tool/verify/run.mjs --full → PASS
- Subagent review: <blockers fixed | minor findings | skipped — reason>
```
