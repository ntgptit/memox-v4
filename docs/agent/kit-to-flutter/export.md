# Kit → Flutter conversion prompt — **export**

> SELF-CONTAINED. Đọc hết file này rồi thực thi tuần tự. Không cần đọc file prompt nào khác.
> Nhiệm vụ: đóng **state-composition parity gate** cho màn `export` (KHÔNG vẽ lại UI —
> UI đã có sẵn; việc ở đây là **curate contract + viết 1 test composition** theo Template B).
> Nếu gặp DRIFT hoặc DIVERGENCE cần người quyết → DỪNG, báo theo mẫu `DRIFT DETECTED` (`CLAUDE.md`), chờ.

---

## PROMPT ID

`kit-to-flutter/export` · screen `export` · feature `import_export` · 3 kit states (`config` / `exporting` / `done`).
FE: `lib/presentation/features/import_export/screens/export_screen.dart` (`ExportScreen`, `ConsumerStatefulWidget`, ctor `{ required int deckId }`).

---

## Baseline

```bash
git checkout main
git pull --ff-only
git checkout -b claude/kit-to-flutter-export
```

Không bắt đầu khi working tree bẩn. Xác nhận `node tool/verify/run.mjs --quick` xanh trước khi sửa.

---

## Required reading (đọc trước khi code — CHỈ đúng các file này)

Universal (theo `CLAUDE.md`): `docs/_generated/repo-map.md`, `docs/_generated/where-is.md`,
`docs/business/index.md`, `docs/business/glossary.md`, `docs/contracts/error-contract.md`,
`docs/contracts/types-catalog.md`, `docs/contracts/code-style.md`.

Screen-specific:
- `docs/design/MemoX Design System/ui_kits/memox-app/specs/export.md` — token-resolved DOM, 3 state (base `config` + `exporting` + `done`, cả hai state sau là "full — differs too much from base").
- `tool/parity/contracts/export.gen.json` — 7 keyed node (key/component/variant). **KHÔNG sửa** (generated). Trong đó chỉ **1 MxCard**: `mx-node:export/progress` (variant `elevated`) — xem cảnh báo Template.
- `tool/parity/contracts/export.slots.skeleton.json` — slot skeleton (superset, AUTO-PROPOSED).
- `tool/parity/contracts/export.states.skeleton.json` — per-state node membership (SUPERSET, phải trim).
- FE: `lib/presentation/features/import_export/screens/export_screen.dart`.
- Business spec (behavior gốc): `docs/business/import-export/import-export.md` (D-026 — export deck cards → CSV/Excel/clipboard, tùy chọn subtree + SRS state).
- **Reference test cần COPY (Template B):** `test/presentation/features/engagement/dashboard_states_test.dart`.
- Curated mẫu để bắt chước format: `tool/parity/contracts/dashboard.states.json`, `dashboard.slots.json`.
- Contrast (KHÔNG áp dụng ở đây — chỉ để hiểu vì sao LOẠI Template A): `test/presentation/features/study/review_parity_test.dart` + `tool/parity/contracts/review.slots.json` / `review.states.json`.
- Ledger hiện có: `tool/parity/intent-ledger.json` (đã có 4 mục cho `export`: 2 `exceptions` = save/share behavior; 2 `coverageExempt`-style = incl-srs-switch / do-export style). Append, không sửa mục cũ.

**Drift check trước khi code (bắt buộc):** đây là màn export flow — FE (`_export()`) ghi file trực tiếp
qua `FileSaveService` (hoặc clipboard), KHÔNG có bước generate→share/save tách rời như kit `done` state.
Điều này đã được ghi nhận là **INTENDED** trong ledger (`export/save`, `export/share`). Nếu bạn thấy FE mâu thuẫn
`docs/business/import-export/import-export.md` ở HÀNH VI (không chỉ layout) → DỪNG, báo `DRIFT DETECTED`, chờ người.
Ở đây spec = "export writes file directly, no separate share/save" và FE khớp → OK, tiếp tục. **Layout khác kit là
DIVERGENCE có chủ đích (ledger), KHÔNG phải drift** — xem mục Divergences.

---

## CHOSEN template: **B — state-composition** (KHÔNG phải Template A)

**Vì sao B, không A — đây là điểm mấu chốt của prompt này:**

`export.gen.json` có **đúng 1 node `MxCard`**: `mx-node:export/progress` (variant `elevated`). Template A
(`review_parity_test.dart`) vòng qua các node và với node `component == 'MxCard'` thì gọi
`tester.widget<MxCard>(finder)` để đọc `.variant`. **NHƯNG trong FE, `mx-node:export/progress` được key trên một
`Text` (dòng ~119 của `export_screen.dart`), KHÔNG phải `MxCard`** — nó là dòng thông báo `_message`
(kết quả export: `exportCopied` / `exportSavedTo(path)` / `transferError`), không phải thẻ progress `elevated` của kit.

→ Nếu chạy Template A, khi tới `export/progress` nó sẽ `tester.widget<MxCard>(find.byKey(...))` trên một `Text` ⇒
**CRASH** (type-cast/`widget<MxCard>` fail), không phải một assert-fail sạch. Vì node MxCard duy nhất của màn này
lại được FE hiện thực bằng `Text`, Template A **không dùng được**. Đúng khuôn là **assert tập keyed node render
CHÍNH XÁC theo từng state** (thừa = THỪA, thiếu = THIẾU), không đọc `.variant` của widget cụ thể — y hệt
`dashboard_states_test.dart`.

> Ghi cảnh báo này (progress = Text không MxCard → Template A crash → chọn B) vào `$curated` header của
> `export.states.json` và vào intent-ledger, để session sau không thử lại Template A.

---

## Gate-able node list (keyed trong FE — đã xác minh bằng grep `mx-node:export/` trong `lib/`)

Grep cho ra ĐÚNG 5 literal keyed sau trong `export_screen.dart`:

| key | component (gen.json) | variant (gen) | FE hiện tại (thực) | ghi chú |
| --- | --- | --- | --- | --- |
| `mx-node:export/screen` | MxScaffold | null | ✓ `MxScaffold` (dòng 75) | chrome — loại khỏi gate-set |
| `mx-node:export/appbar` | MxAppBar | null | ✓ `MxAppBar` (dòng 77) | chrome — loại khỏi gate-set |
| `mx-node:export/incl-srs-switch` | MxSwitch | null | ✓ `MxSwitch` (dòng 95) | body control, có ở `config` |
| `mx-node:export/do-export` | MxButton | primary | ✓ `MxButton` (dòng 112) | body action, có ở `config` |
| `mx-node:export/progress` | **MxCard** (elevated) | elevated | ⚠ **`Text`** (dòng 119) — DIVERGENCE | render khi `_message != null` sau export |

**Node phân biệt state thực sự chỉ có 2:** `do-export`/`incl-srs-switch` (state `config`) và `progress`
(hiện sau khi bấm export). `screen`/`appbar` là chrome luôn hiện ⇒ **loại khỏi gate-set** (theo mẫu dashboard).

### Node trong gen.json NHƯNG chưa key trong FE (identity-rollout gap — ghi nhận, KHÔNG ép)

`export.gen.json` còn 2 node chưa có literal key trong FE: `mx-node:export/save` (MxButton ghost),
`mx-node:export/share` (MxButton primary). Cả hai thuộc kit `done` state — FE **không hiện thực** (ledger đã ghi:
export ghi file trực tiếp, không có share/save button). → **GAP, INTENDED** (không rollout key mới trong task này).

Nhiều `id:` trong spec (`export/scope`, `export/format-csv|xlsx|copy`, `export/sep-0..2`, `export/incl-srs`,
`export/bar`, `export/done`, `export/back`) là **kit CSS id**, KHÔNG phải keyed `mx:` component trong gen.json và
KHÔNG có trong FE (FE dùng `DropdownButtonFormField` + `ListTile` + `MxSwitch` thay cho segmented/format-card/chips).
→ tất cả là identity-rollout gap / layout divergence, liệt kê trong report.

---

## Per-state node SET (curate cho `export.states.json`)

Từ `export.states.skeleton.json` (superset), **trim**: bỏ chrome (`screen`/`appbar`/`back`), bỏ node kit-only
chưa keyed trong FE (`scope`, `format-*`, `sep-*`, `incl-srs`, `bar`, `done`, `save`, `share`). Giữ lại đúng
tập keyed FE THỰC render theo từng state.

FE thực có **2 nhánh render phân biệt được ở tầng identity**:
- **config** = trạng thái mặc định (chưa export): body render `incl-srs-switch` + `do-export` (+ subtree switch
  keyed `Key('exportSubtree')` — KHÔNG phải `mx-node:` literal, bỏ qua). `progress` absent.
- **result** (≈ kit `done`/`exporting` gộp) = sau khi bấm export, `_message != null`: `progress` (Text) hiện
  THÊM vào cuối list; `incl-srs-switch` + `do-export` **vẫn còn** (FE không thay body, chỉ append dòng message).

Tập gate đề xuất (chỉ node keyed FE, đã bỏ chrome):

```jsonc
{
  "config": ["mx-node:export/incl-srs-switch", "mx-node:export/do-export"],
  "result": ["mx-node:export/incl-srs-switch", "mx-node:export/do-export", "mx-node:export/progress"]
}
```

> Vì `incl-srs-switch`/`do-export` xuất hiện trong CẢ 2 tập → chúng KHÔNG phân biệt state. Node **thực sự phân
> biệt** chỉ là `progress` (chỉ `result`). Universe = hợp 2 tập; assert `progress` **absent** ở `config` và
> **present** ở `result` — ĐÓ là chỗ gate bắt được THỪA (message rò rỉ vào config) / THIẾU (không hiện sau export).

**Không có `export.slots.json`?** — CÂN NHẮC, mặc định **BỎ QUA** (ghi lý do trong report): các keyed node FE là
control (`MxSwitch`, `MxButton`) không mang keyed MxText slot cần bind role/l10n; `progress` là `Text` thuần
(role không phải `MxText`). Nếu muốn phủ text, đó là việc của prompt/parity khác. KHÔNG tạo file rỗng. (So với
dashboard có `dashboard.slots.json` vì các MxCard mang nhiều MxText slot — export không có cấu trúc đó ở FE.)

---

## State-map: state nào drive được / state nào là coverage gap

| kit state | drivable trong FE? | cách drive | node-set FE |
| --- | --- | --- | --- |
| `config` | ✅ | pump `ExportScreen(deckId)` với DB seed (1 deck + N card); KHÔNG bấm export → `_message == null` | `incl-srs-switch`, `do-export` |
| `done` (≈ FE `result`) | ✅ | pump `config` rồi `tester.tap(find.byKey(ValueKey('mx-node:export/do-export')))` + pump vài nhịp → `_message` set → `progress` (Text) hiện | `incl-srs-switch`, `do-export`, `progress` |
| `exporting` | ⚠️ **coverage gap** | kit có `progress` card (spinner `sync` + bar `export/bar`) trong lúc export ĐANG chạy. FE KHÔNG render trạng thái "đang export" trung gian: `_export()` là 1 `Future` chạy thẳng, chỉ set `_message` KHI XONG. Không có node phân biệt cho lúc-đang-chạy ⇒ không drive được ổn định. | — (rơi thẳng vào `result`) |

→ **Gate 2 state:** `config`, `result`. **1 state là coverage gap:** `exporting` (FE không có transient
progress UI; `export/bar` không tồn tại trong FE). Ghi rõ trong `$curated` header của `export.states.json` và
trong header test (giống `review_parity_test` giải thích state không map).

> Nếu khi code phát hiện `result` KHÔNG drive được sạch (vd `_export()` gọi `FileSaveService` thật ném lỗi trong
> test env) → override provider để `_export()` chạy được tới `setState(_message=...)`: seed DB + override
> `fileSaveServiceProvider` (và/hoặc `exportCardsProvider`, `tableCodecProvider`) bằng fake trả path/rows sạch,
> theo `import_export_providers.dart`. Nếu vẫn không sạch → hạ `result` xuống coverage gap, chỉ gate `config`
> (1 state), báo rõ trong report. ĐỪNG viết test giả chỉ để có `result`.

---

## Divergences → intent-ledger (`tool/parity/intent-ledger.json`, append — KHÔNG ép FE về kit)

Ledger đã có 4 mục export (save/share `exceptions`; incl-srs-switch/do-export style). **Append** các mục MỚI sau
(giữ đúng format: `exceptions[]` cho FE-side behavior khác kit, mỗi mục cần `source`). Không sửa mục cũ.

1. **`export/progress` = Text, không MxCard** — kit: `progress` là `MxCard` elevated (spinner + "Exporting…" + bar).
   FE: key trên một `Text` hiển thị message kết quả (`exportCopied`/`exportSavedTo`/`transferError`). Lý do:
   FE không có transient exporting card; message là feedback sau khi xong. → INTENDED. `exceptionKind: behavior`,
   `source: docs/business/import-export/import-export.md`. **Đây là mục quan trọng nhất** (giải thích vì sao Template A).
2. **`exporting` state / `export/bar` thiếu** — kit có progress card + progress bar lúc đang export; FE không
   render transient progress. → GAP, INTENDED (v1 export đồng bộ, không progress UI).
3. **FORMAT card / scope segmented / separator chips thiếu** — kit `config` có segmented (`export/scope`),
   format-card 3 dòng (`csv`/`xlsx`/`copy`), separator chips (`sep-0..2`). FE dùng
   `DropdownButtonFormField<TransferFormat>` cho format + `ListTile` scope subtree + `MxSwitch` — layout khác hẳn.
   → INTENDED (v1 dùng control chuẩn design-system, không segmented/chip kit). Không gate literal các node này.
4. **`ExportingCard` / `FormatList` không tồn tại trong FE** — các composed widget kit (thẻ progress, list format)
   không có widget FE tương ứng. → GAP.

Nếu bất kỳ mục nào thực chất là **BUG** (không phải chủ ý) → **DỪNG**, báo `DRIFT DETECTED`, chờ người. Không tự
sửa UI trong prompt này.

---

## Workflow (thực thi tuần tự, mỗi bước một layer)

1. **Curate `tool/parity/contracts/export.states.json`** từ `export.states.skeleton.json`: chỉ 2 state
   `config`/`result`, chỉ node keyed FE (`incl-srs-switch`, `do-export`, `progress`), bỏ chrome
   `screen`/`appbar`/`back` và mọi node kit-only. Thêm `$curated` header (bắt chước `dashboard.states.json`) nêu:
   (a) `progress` = Text không MxCard ⇒ Template A crash ⇒ dùng Template B; (b) `exporting` là coverage gap
   (FE không có transient progress UI); (c) chrome loại khỏi gate.
2. **`export.slots.json`: BỎ QUA** — ghi lý do trong report (không có keyed MxText slot; control + Text thuần).
   Không tạo file rỗng.
3. **Align FE** `export_screen.dart` nếu cần cho parity identity — nhưng **tối thiểu**: 5 key hiện có đã đúng
   chính tả (grep confirm). KHÔNG đổi layout để khớp kit (segmented/chip/format-card) — đó là divergence có chủ
   đích. KHÔNG hardcode màu/spacing/route/string. Nếu FE có hardcode nào (vd string thẳng) → sửa dùng ARB/token
   cùng commit. KHÔNG thêm node/hành vi mới (share/save/exporting) — ngoài scope style-parity.
4. **l10n**: các key export FE dùng (`exportTitle`, `exportScopeSubtree`, `exportIncludeSrs`, `exportFormat`,
   `exportRun`, `exportCopied`, `exportSavedTo`, `transferError`) đã có ở **cả** `app_en.arb` và `app_vi.arb`
   (đã verify). Nếu bạn thêm/đổi bất kỳ chuỗi user-facing nào → thêm vào **cả hai** ARB cùng lúc rồi regen l10n.
   KHÔNG copy MOCK COPY từ kit spec ("Exporting…", "Exported 320 cards", "This deck", "Incl. sub-decks",
   "CSV/.csv file"…) vào app/test.
5. **Viết test composition** `test/presentation/features/import_export/export_states_test.dart`:
   COPY cấu trúc `dashboard_states_test.dart` — đọc `export.states.json`, tính `universe = hợp các state-set`,
   `recipes` seed cho từng state, pump `ExportScreen(deckId)`, assert mỗi key trong `universe`:
   allowed → `findsOneWidget` (THIẾU nếu absent), ngoài allowed → `findsNothing` (THỪA nếu present).
   - Seed: theo pattern `review_parity_test.dart` seed helper (insert `languagePair` ko→vi + `deck` + N `card`),
     override `databaseProvider` + `clockProvider(_FixedClock)`. Nếu `result` cần chạy `_export()` sạch → override
     `fileSaveServiceProvider`/`exportCardsProvider`/`tableCodecProvider` bằng fake (xem `import_export_providers.dart`).
   - `recipes`:
     - `config`: seed deck+cards, pump, **KHÔNG** tap export.
     - `result`: seed, pump, `tester.tap(find.byKey(const ValueKey('mx-node:export/do-export')))`, rồi pump
       vòng `for` vài nhịp 50ms (KHÔNG `pumpAndSettle` nếu có future treo) tới khi `_message` set → `progress` hiện.
   - Header test giải thích rõ: `exporting` là coverage gap; `progress` là Text (Template B lý do).
6. **Xóa skeleton** đã tiêu thụ: `export.states.skeleton.json` **và** `export.slots.skeleton.json`
   (skeleton là AUTO-PROPOSED, không ship — theo ghi chú `$skeleton` trong file). Vì bỏ qua slots.json, vẫn xóa
   `export.slots.skeleton.json` (đã tiêu thụ = đã quyết định bỏ qua) — ghi lý do trong commit.
7. **Cập nhật queue**: đổi `[ ] 19-export.md` → `[x]` trong `docs/agent/kit-to-flutter/README.md`.
8. **Doc parity**: task thuần style-parity/contract — nhiều khả năng chỉ cần intent-ledger + queue. Nếu chạm
   behavior user-visible / route → update `docs/business/import-export/import-export.md` cùng commit. Xác nhận
   rồi ghi rõ trong report (mục "Docs updated").

---

## Hard rules (vi phạm = task fail — trích `CLAUDE.md`)

- KHÔNG vẽ lại / di chuyển UI trong prompt này; chỉ curate contract + viết test. Divergence → ledger, không tự sửa.
- **Template B, KHÔNG Template A** (progress = Text không MxCard ⇒ A crash). Không đọc `.variant` của `progress`.
- KHÔNG hardcode route/màu/text-style/duration/string; string lấy từ ARB (`lib/l10n/`), style/spacing từ token/`MxSpacing`.
- KHÔNG copy MOCK COPY từ kit spec vào app/test làm assert văn bản.
- KHÔNG ship skeleton làm curated; phải trim rồi xóa cả 2 skeleton.
- KHÔNG bịa state (`exporting`) nếu không drive được sạch → để coverage gap và báo. KHÔNG viết test fake để có `result`.
- **l10n cả hai ARB**: mọi chuỗi mới vào `app_en.arb` **và** `app_vi.arb` cùng commit; regen l10n; không sửa `lib/l10n/generated/**` tay.
- KHÔNG sửa generated (`*.g.dart`, `*.freezed.dart`, `export.gen.json`, `lib/l10n/generated/**`, `docs/_generated/**`).
- KHÔNG thêm dependency mới (Stop & ask nếu cần). KHÔNG thêm hành vi share/save/exporting (ngoài scope).
- KHÔNG bypass layering (UseCase → Repository → DataSource) — task này không đụng data layer, chỉ presentation + contract + test.

---

## Verification

```bash
node tool/verify/run.mjs --full
```

Phải XANH (ghi pass-marker mà pre-commit hook yêu cầu; trong đó có test parity mới + freshness check của specs).
Nếu đỏ hoặc bị skip → KHÔNG được báo done, sửa rồi chạy lại. Trong lúc dev có thể `--quick` (không marker).
Chạy riêng test mới để chắc: `flutter test test/presentation/features/import_export/export_states_test.dart`.

Sau khi verify PASS, **TRƯỚC final report**: fan-out song song `code-reviewer` (review working-tree diff — cho nó
`git add -N . && git diff`, đừng commit trước) + `docs-drift-detector`. Gộp kết quả vào mục "Subagent review";
fix blocker trước khi kết.

---

## Commit (2 commit + WBS)

**Commit 1** — contract + test:
```
test(parity): export state-composition gate (config/result) + curated states.json

- curate tool/parity/contracts/export.states.json (2 gated states; exporting = coverage gap)
- add test/presentation/features/import_export/export_states_test.dart (Template B, copy dashboard_states_test)
- remove consumed skeletons (export.states.skeleton.json, export.slots.skeleton.json)
- export.slots.json intentionally skipped (no keyed MxText slot; progress is a Text, controls only)
- Template B not A: export/progress is keyed on a Text, not the kit's MxCard → A would crash

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>
```

**Commit 2** — docs/ledger + queue:
```
docs(parity): export divergences → intent-ledger; mark export done in kit-to-flutter queue

- intent-ledger: progress=Text (not MxCard), exporting/bar gap, format/scope/separator layout divergence
- mark [x] 19-export.md in docs/agent/kit-to-flutter/README.md

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>
```

**WBS** (bắt buộc, `CLAUDE.md` §WBS): append 1 dòng vào **Commit Traceability Log (§10 của
`docs/project-management/wbs.md`)**, newest first:
`<8-char hash> · <YYYY-MM-DD> · <WBS IDs> · export kit→flutter state-composition parity (Template B; config/result gated, exporting gap)`.
Nếu WBS task breakdown không bị ảnh hưởng → report ghi `WBS update: not needed — <reason>` (nhưng Commit
Traceability Log vẫn append nếu advance một WP).

---

## Final report format (đưa vào tin nhắn cuối)

```
## export — kit→flutter DONE
- Template: B (state-composition) — lý do: node MxCard duy nhất (export/progress) được FE key trên một Text, không phải MxCard ⇒ Template A crash khi tester.widget<MxCard>()
- Gate-able keyed node (FE): incl-srs-switch (MxSwitch), do-export (MxButton), progress (Text)  [+ chrome screen/appbar loại khỏi gate]
- Contracts: export.states.json curated (2 gated states); export.slots.json BỎ QUA (control + Text, không có keyed MxText slot); 2 skeleton deleted
- States driven: config (chưa export), result (sau khi tap do-export → progress hiện). Coverage gap: exporting (FE không có transient progress UI; export/bar không tồn tại)  [hoặc chỉ config nếu result không drive sạch — nêu rõ]
- Divergences → intent-ledger: progress=Text vs MxCard(elevated); exporting/bar gap; format(dropdown)/scope(ListTile)/separator layout ≠ kit segmented/chip; ExportingCard+FormatList không có FE
- Identity-rollout gap (chưa key trong FE): export/save, export/share, export/scope, export/format-csv|xlsx|copy, export/sep-0..2, export/incl-srs, export/bar, export/done, export/back
- l10n: exportTitle/exportScopeSubtree/exportIncludeSrs/exportFormat/exportRun/exportCopied/exportSavedTo/transferError đã có ở app_en.arb + app_vi.arb [no new keys | new keys: ...]
- Docs updated: <list | none — style-parity only>
- WBS update: <line appended | not needed — reason>
- Verify: node tool/verify/run.mjs --full → PASS
- Subagent review: <blockers fixed | minor findings ...>
```
