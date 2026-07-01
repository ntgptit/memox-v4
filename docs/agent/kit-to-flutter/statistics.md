# kit → Flutter conversion prompt — **statistics**

> SELF-CONTAINED. Everything the executing agent needs is in this file. Do not
> require prior context. Vietnamese OK trong phần giải thích; code/keys giữ nguyên.

---

## PROMPT ID

`kit-to-flutter/statistics` · FE screen: `lib/presentation/features/statistics/screens/statistics_screen.dart`

Goal: **KHÔNG chuyển đổi lại UI** (màn đã tồn tại). Nhiệm vụ là **đóng chốt parity
identity + per-state composition** cho màn statistics: curate 2 contract JSON từ
skeleton, hoàn thiện `ValueKey` identity trên FE cho đúng tập node kit khai báo,
đồng bộ l10n cả 2 ARB, viết **1 parity test** theo template đã chọn, xoá skeleton.

---

## Baseline

```bash
git checkout main
git pull --ff-only
git checkout -b claude/kit-to-flutter-statistics
```

Xác nhận đang sạch (`git status` clean) trước khi bắt đầu.

---

## Required reading (đọc trước, đúng các file này)

- `docs/design/MemoX Design System/ui_kits/memox-app/specs/statistics.md` — token-resolved DOM per state (loaded / scope-switch / insufficient / loading).
- `tool/parity/contracts/statistics.gen.json` — keyed node identity (key/component/variant). **Source of truth cho tập node.**
- `tool/parity/contracts/statistics.slots.skeleton.json` — slot skeleton (role heuristic — VERIFY). Đừng ship as-is.
- `tool/parity/contracts/statistics.states.skeleton.json` — per-state node membership (superset, có chrome — phải trim).
- FE: `lib/presentation/features/statistics/screens/statistics_screen.dart`
- Notifier/providers: `lib/presentation/features/statistics/viewmodels/statistics_notifier.dart` (`statsScopeProvider`, `statisticsProvider(scope)`), `lib/app/di/statistics_providers.dart`, `lib/domain/models/statistics_summary.dart`.
- REFERENCE template (COPY từ đây): **`test/presentation/features/engagement/dashboard_states_test.dart`** (Template B — state composition). Đọc kèm `test/presentation/features/statistics/statistics_screen_test.dart` để lấy đúng pump/seed cho `statisticsProvider` (seeded in-memory Drift DB).
- Curated examples để bắt chước format JSON: `tool/parity/contracts/dashboard.slots.json`, `tool/parity/contracts/dashboard.states.json`.
- l10n: `lib/l10n/app_en.arb`, `lib/l10n/app_vi.arb` (các key `stats*` đã tồn tại — xem mục l10n bên dưới).
- `docs/ui-ux/ui-ux-contract.md`, `docs/checklist/implementation-checklist.md`.

---

## CHOSEN template + why

**Template B — state-composition** (copy `dashboard_states_test.dart`).

Lý do:
- `statistics.gen.json` có 2 node `MxCard` (`streak-current` variant `primarySoft`,
  `streak-longest` variant `muted`) **nhưng FE KHÔNG key chúng** — grep FE chỉ thấy
  7 key: `screen`, `appbar`, và 5 section-head card (`accuracy-head`, `leitner-head`,
  `weekly-head`, `heatmap-head`, `overview-head`). Không có MxCard body node nào được
  key. ⇒ Template A (identity+variant+slot MxTextRole per keyed MxCard) **không có
  đối tượng để gate** → không phù hợp.
- Điều màn statistics thực sự cần gate là **per-state composition**: state `loaded`
  vs `insufficient` vs `loading` render tập section khác nhau; `accuracy-head` chỉ
  xuất hiện khi `summary.hasReviews`. Đó chính xác là thứ Template B bắt (THỪA/THIẾU),
  còn set-level key gate (`fe_node_usage`) không thấy.

Tập MxCard chưa key (`streak-current`, `streak-longest`) ghi vào **intent-ledger** như
identity-rollout gap, KHÔNG cố nhồi Template A.

---

## Gate-able (keyed) node list

Các node **đang** có `ValueKey` trong FE (grep `mx-node:statistics/` trong FE):

| node id | FE widget | ghi chú |
| --- | --- | --- |
| `mx-node:statistics/screen` | `Column` root (`MxScaffold` trong kit) | chrome |
| `mx-node:statistics/appbar` | `Padding` bọc `MxSegmentedControl` | **lệch**: key `appbar` đặt trên vùng scope-control, không phải title. Xem intent-ledger. |
| `mx-node:statistics/overview-head` | `_StatsCard` head | body, **luôn** render (data state) |
| `mx-node:statistics/accuracy-head` | `_StatsCard` head | body, **chỉ** khi `summary.hasReviews` |
| `mx-node:statistics/leitner-head` | `_StatsCard` head | body |
| `mx-node:statistics/weekly-head` | `_StatsCard` head | body — **title lệch** (xem ledger) |
| `mx-node:statistics/heatmap-head` | `_StatsCard` head | body — **title lệch** (xem ledger) |

Section-head card là đơn vị gate của Template B cho màn này. Sau khi curate
`statistics.states.json`, các node BODY được gate là 5 head trên (screen/appbar là
chrome — loại khỏi `states.json`, theo đúng dashboard.states.json).

**Node kit khai báo nhưng FE CHƯA key** (⇒ intent-ledger, không gate ngay):
`scope`, `streak-current`, `streak-longest`, `heatmap`, `weekly`, `leitner`,
`accuracy`, `overview`, `ov-0`, `ov-1`, `ov-2`. FE dựng đủ các block này (`_OverviewCard`,
`_Accuracy`, `_BarList`, `_Heatmap`, `_Stat`) nhưng chưa gắn `ValueKey` tương ứng.

---

## Divergences → intent-ledger

Ghi vào phần "Intent ledger" của báo cáo cuối. **KHÔNG tự ý sửa FE để khớp mock kit
về mặt copy/binding** — kit dùng mock copy, string thật lấy từ ARB (xem MEMORY: Kit is
source of truth cho *style/identity*, string vẫn từ ARB).

1. **`appbar` key đặt sai vị trí ngữ nghĩa.** Kit: `appbar` = large title "Stats".
   FE: `ValueKey('mx-node:statistics/appbar')` nằm trên `Padding` bọc
   `MxSegmentedControl` (vùng scope), còn large title do shell/route bao ngoài. →
   Intent: giữ nguyên (title thuộc shell), key `appbar` hiện là proxy cho vùng
   header-controls. Ghi rõ là chủ ý, không đổi trong PR này.
2. **`scope` chưa được key.** FE có `MxSegmentedControl` (This pair / All) nhưng
   không gắn `ValueKey('mx-node:statistics/scope')`. → **Nên bổ sung** (thấp rủi ro):
   key wrapper của segmented control = `scope`. Nếu bổ sung, thêm vào `states.json`
   cả `loaded`/`scope-switch`/`insufficient` (scope luôn hiện, kể cả insufficient —
   xem spec state insufficient vẫn render `segmented`).
3. **`weekly-head` title lệch.** Kit: "Time per week / min / day". FE:
   `statsForecastTitle` = "Due in the next 7 days" (dùng `_BarList` với
   `summary.dueForecast`). → Intent: FE cố ý map node `weekly-head` sang biểu đồ
   **due-forecast** thay vì time-per-week (không có nguồn time-per-week trong domain
   hiện tại). Ghi ledger — **không** đổi copy sang mock kit.
4. **`heatmap-head` title lệch.** Kit: "Study calendar / last 14 weeks". FE:
   `statsHeatmapTitle` = "Activity (12 weeks)". → Intent: khác biệt về window (12 vs
   14) và wording; FE là nguồn thật. Ghi ledger.
5. **`streak-current` / `streak-longest` (MxCard) chưa render/khóa.** FE hoàn toàn
   không có 2 card streak trong `_StatsBody`. → Identity-rollout + **feature gap**:
   màn statistics FE chưa có khối "current streak / longest". Ghi ledger là THIẾU so
   với kit (đừng tự implement streak card trong PR parity này — ngoài scope; nếu muốn
   làm, tách WBS riêng).
6. **`overview` body nodes (`ov-0/1/2`) chưa key.** FE `_OverviewCard` render 3
   `_Stat` (pairs/decks/words) nhưng: (a) không gắn key `ov-0/1/2`; (b) label là
   pairs/decks/words, kit là total/mastered/due. → Ledger: binding divergence + chưa
   key. Chỉ key `overview-head` được giữ. Không đổi binding.
7. **`accuracy` nội dung khác kit.** Kit: donut "88% / accuracy". FE: linear progress
   + `statsAccuracyDetail`. `accuracy-head` chỉ render khi `hasReviews`. → Ledger.

**Quy tắc:** trong PR này chỉ (a) bổ sung key `scope` nếu low-risk, (b) KHÔNG thêm
key cho các block chưa tồn tại/feature-gap. Mọi lệch còn lại → ledger, không sửa.

---

## State-map (cách drive từng state)

Provider: `statisticsProvider(scope)` (family theo `StatsScope`), scope từ
`statsScopeProvider` (mặc định `currentPair`). FE rẽ nhánh:
`stats.when(loading / error / data(summary))`, trong `data`:
`summary.hasEnoughData ? _StatsBody : _StatsInsufficient`; trong `_StatsBody`,
`accuracy-head` chỉ khi `summary.hasReviews`.

`hasEnoughData == words > 0` (số card visible > 0). `hasReviews == accuracyTotal > 0`
(có review answer). Pump = seeded in-memory Drift DB + `_FixedClock` (copy y hệt
`statistics_screen_test.dart`), `pumpWidget(host())` rồi `pumpAndSettle()`.

| kit state | cách drive (seed) | tập BODY node gate (curate vào `states.json`) |
| --- | --- | --- |
| `loaded` | seed ≥1 card visible + ≥1 review answer (để `hasReviews` bật) → `overview-head`, `accuracy-head`, `leitner-head`, `weekly-head`, `heatmap-head` | 5 head |
| `scope-switch` | như `loaded` (spec chỉ đảo trạng thái selected segment; tập node = `loaded`) | = `loaded` |
| `insufficient` | DB rỗng / 0 visible card → `_StatsInsufficient` | tập rỗng head (không head nào); FE render `Key('statsInsufficient')` |
| `loading` | future `statisticsProvider` chưa resolve (pump 1 frame, **không** `pumpAndSettle`) → `_StatsSkeleton` | tập rỗng head |

Lưu ý seeding (theo `get_statistics_test.dart` + `statistics_screen_test.dart`):
- 1 pair + 1 deck + ≥1 `card` (visible) ⇒ `hasEnoughData`.
- Để `hasReviews`: cần review answers (`accuracyTotal>0`). Kiểm tra `StatsDao` /
  `daily_activity` / bảng review-answer nguồn của `accuracyCorrect/Total` (xem
  `StatisticsRepositoryImpl`, `stats_dao.dart`) và seed đúng bảng đó. Nếu không seed
  được review-answer dễ dàng → tách 2 case: (i) data-without-reviews (accuracy-head
  THIẾU — hợp lệ theo `hasReviews`), (ii) full-loaded (accuracy-head có). Ghi lựa
  chọn vào test comment.

**Coverage gap** (ghi vào `$curated` của `states.json`, giống review/dashboard):
- `scope-switch` không phải node-set riêng (identical với `loaded`) → liệt kê nhưng
  drive chung recipe `loaded`.
- `loading` chỉ có skeleton, không keyed body node → không gate node nào (chỉ đảm bảo
  0 head render). Có thể bỏ khỏi vòng gate node hoặc assert tập rỗng.

---

## Workflow (theo thứ tự)

1. **Curate `tool/parity/contracts/statistics.slots.json`** từ
   `statistics.slots.skeleton.json`:
   - Chỉ giữ slot cho các node FE **thực sự key** (5 head + tuỳ chọn `scope`).
   - `role`: VERIFY theo `MxText` FE dùng (head title: `MxText.title` → xác nhận role
     tương ứng trong `mx_text.dart`; caption bodySmall). Sửa role heuristic sai.
   - `l10n`: điền key ARB thật (không để `TODO`): `statsOverviewTitle`,
     `statsAccuracyTitle`, `statsBoxTitle` (leitner), `statsForecastTitle` (weekly),
     `statsHeatmapTitle`. Ghi `$curated` giải thích các divergence (weekly/heatmap
     title lệch mock, xem ledger). Mirror format `dashboard.slots.json`.
2. **Curate `tool/parity/contracts/statistics.states.json`** từ
   `statistics.states.skeleton.json`:
   - Trim chrome (`screen`, `appbar`) — theo đúng note của skeleton và
     `dashboard.states.json` (chỉ giữ BODY state-driven node).
   - `loaded` & `scope-switch` = `{overview-head, accuracy-head, leitner-head,
     weekly-head, heatmap-head}`.
   - `insufficient` = `[]` (không head; hoặc chỉ `scope` nếu bạn key `scope` và nó
     thật sự render ở insufficient — spec cho thấy `segmented` vẫn render).
   - `loading` = `[]`.
   - Viết `$curated` nêu rõ: state scope, tại sao trim chrome, coverage gap
     (`scope-switch` = `loaded`, `loading` skeleton-only).
3. **Align/complete FE identity** trong `statistics_screen.dart`:
   - Xác nhận 5 head key khớp `states.json`.
   - (Tuỳ chọn, low-risk) thêm `key: const ValueKey('mx-node:statistics/scope')` cho
     wrapper `MxSegmentedControl`. Nếu thêm → cập nhật `slots.json` + `states.json`
     (scope có mặt ở `loaded`/`scope-switch`/`insufficient`).
   - **KHÔNG** thêm key/feature cho `streak-*`, `ov-*`, `heatmap`, `weekly`,
     `leitner`, `accuracy` body (ledger). Không đổi copy/binding.
4. **l10n cả 2 ARB**: các key `stats*` đã có trong `app_en.arb` **và** `app_vi.arb` —
   xác nhận đủ (không thêm mới trừ khi bạn key node cần string mới; màn này thường
   không cần). Nếu chạm ARB, chạy gen l10n theo checklist.
5. **Parity test** — tạo
   `test/presentation/features/statistics/statistics_states_test.dart` bằng cách
   **copy `dashboard_states_test.dart`** rồi thay:
   - đọc `tool/parity/contracts/statistics.states.json`;
   - `home: const Scaffold(body: StatisticsScreen())` + import statistics screen;
   - `host()`/`_FixedClock`/seed lấy từ `statistics_screen_test.dart` (Drift in-mem,
     pair+deck; thêm card để bật `hasEnoughData`, seed review-answer cho `loaded`);
   - `recipes` map: `insufficient` → no card; `loaded`/`scope-switch` → seed card
     (+review); `loading` → pump 1 frame, assert 0 head (không `pumpAndSettle`);
   - vòng lặp `universe = states.values.expand(...).toSet()`, assert
     `findsOneWidget` cho allowed, `findsNothing` cho phần còn lại (THỪA/THIẾU),
     reason có `THỪA`/`THIẾU` như bản dashboard.
6. **Xoá skeleton**: `git rm tool/parity/contracts/statistics.slots.skeleton.json
   tool/parity/contracts/statistics.states.skeleton.json`.

---

## Hard rules

- KHÔNG sửa file generated (`*.g.dart`, `lib/l10n/generated/**`, `docs/_generated/**`).
- KHÔNG hardcode route/màu/text-style/duration/chuỗi người dùng — string từ ARB, token từ theme.
- KHÔNG thêm dependency mới.
- KHÔNG đổi copy/binding của FE để khớp mock kit (mock ≠ contract). Divergence → ledger.
- KHÔNG tự implement feature còn thiếu (streak card, overview total/mastered/due, donut accuracy) trong PR parity này.
- Test mới KHÔNG được có node THỪA/THIẾU khi chạy — phải xanh thật.
- Ship `statistics.slots.json` + `statistics.states.json` (đã curate), **không** ship skeleton.
- Tuân thủ layering & doc-parity của `CLAUDE.md`.

---

## Verification

```bash
node tool/verify/run.mjs --full
```

Phải PASS (viết pass-marker cho pre-commit hook). Nếu bước nào skip/fail → báo rõ
bước + lý do, không claim done.

Sau khi verify PASS, trước khi báo cáo: fan-out `code-reviewer` (review working-tree
diff) + `docs-drift-detector`, gộp findings vào mục "Subagent review".

---

## Commit (2 commits + WBS)

**Commit 1 — contracts + FE identity:**
```
feat(parity): statistics — curate slots/states + FE ValueKey identity

- curate statistics.slots.json / statistics.states.json from skeleton
- (opt) key scope segmented control
- delete statistics.{slots,states}.skeleton.json
```
**Commit 2 — parity test:**
```
test(parity): statistics — per-state composition gate (Template B)
```

Mỗi commit chạm WBS phải append dòng vào **§10 Commit Traceability Log** của
`docs/project-management/wbs.md`:
`<8-char hash> · <YYYY-MM-DD> · <WBS IDs> · <one-line summary>` (append-only, mới nhất
trên cùng). Kiểm tra WBS có work package cho parity/statistics; nếu không đổi phạm vi,
ghi `WBS update: not needed — <reason>`.

Kết thúc mỗi commit message bằng:
```
Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>
```

---

## Final report format

```
## statistics — kit→flutter parity

### Template: B (state-composition)  ·  ref: dashboard_states_test.dart

### Contracts
- statistics.slots.json  — <#node curated>
- statistics.states.json — states: loaded / scope-switch / insufficient / loading
- skeletons deleted: yes

### FE identity
- keyed nodes gated: <list>
- scope keyed: <yes/no>

### Intent ledger (divergences, NOT fixed)
- <7 mục ở trên, mỗi mục 1 dòng: node · kit vs FE · quyết định>

### Coverage gaps
- scope-switch = loaded (không node-set riêng)
- loading = skeleton-only (0 keyed body node)
- <case accuracy-head phụ thuộc hasReviews nếu tách>

### Verify
- node tool/verify/run.mjs --full → PASS/FAIL (+ bước nếu fail)

### Subagent review
- code-reviewer: <...>
- docs-drift-detector: <...>

### Docs updated
- <list>  |  WBS: <traceability line hoặc "not needed — reason">
```
