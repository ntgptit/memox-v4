# Kit → Flutter conversion prompt — **search** (màn 13)

> SELF-CONTAINED. Đọc hết file này rồi thực thi tuần tự. Không cần đọc file prompt nào khác.
> Nhiệm vụ: đóng **state-composition parity gate** cho màn `search` (KHÔNG vẽ lại UI từ đầu —
> UI đã có; việc ở đây là **curate contract + rollout ValueKey identity cho body + viết 1 test
> composition** theo Template B). Nếu gặp DRIFT hoặc DIVERGENCE cần người quyết → DỪNG, báo, chờ.

---

## PROMPT ID

`kit-to-flutter/search` · screen `search` · feature `search` · Template **B (state-composition)** · 5 kit states.
FE: `lib/presentation/features/search/screens/search_screen.dart`.

---

## 1. Baseline

```bash
git checkout main
git pull --ff-only
git checkout -b claude/kit-to-flutter-search
```

Không bắt đầu khi working tree bẩn. Xác nhận `node tool/verify/run.mjs --quick` xanh trước khi sửa.

---

## 2. Required reading (CHỈ đọc đúng các file này)

Universal (theo `CLAUDE.md`): `docs/_generated/repo-map.md`, `docs/_generated/where-is.md`,
`docs/business/index.md`, `docs/business/glossary.md`, `docs/contracts/error-contract.md`,
`docs/contracts/types-catalog.md`, `docs/contracts/code-style.md`.

Screen-specific:
- `docs/design/MemoX Design System/ui_kits/memox-app/specs/search.md` — token-resolved DOM, 5 state
  (base `empty recent` + `results` / `filtered` / `no results` / `loading`).
- `tool/parity/contracts/search.gen.json` — 3 keyed node (key/component/variant). **Đã xác minh: 0 MxCard.** KHÔNG sửa (generated).
- `tool/parity/contracts/search.slots.skeleton.json` — slot skeleton (chỉ text `RECENT` + 3 recent term mock).
- `tool/parity/contracts/search.states.skeleton.json` — per-state node membership (SUPERSET, phải trim).
- FE: `lib/presentation/features/search/screens/search_screen.dart`.
- State/domain: `lib/presentation/features/search/viewmodels/search_notifier.dart` (`SearchUiState`:
  `query`, `filter`, `searching`, `results`, `recent`).
- Business doc: `docs/business/search/global-search.md` (đọc để không đổi hành vi đã spec).
- **Reference test cần COPY (Template B):** `test/presentation/features/engagement/dashboard_states_test.dart`.
- Curated mẫu để bắt chước format: `tool/parity/contracts/dashboard.states.json`, `dashboard.slots.json`.
- Contrast (KHÔNG áp dụng ở đây, chỉ để hiểu vì sao loại): `test/presentation/features/study/review_parity_test.dart`
  (Template A, MxCard-rich) + `tool/parity/contracts/review.states.json` / `review.slots.json`.
- Ledger: `tool/parity/intent-ledger.json` (định dạng `exceptions[]`).

**Drift check trước khi code:** search là global search theo term+meaning + status filter chip
(`docs/business/search/global-search.md`, MEMORY: "search term+meaning"). FE khớp: `search()` gọi
`SearchCardsUseCase`, filter chip lọc theo `CardStatus`, recent giữ trong session (keepAlive). Nếu
phát hiện FE mâu thuẫn spec về HÀNH VI (vd: search đổi lịch SRS, recent persist xuống DB) → DỪNG, báo
theo mẫu `DRIFT DETECTED` trong `CLAUDE.md`. Ở đây hành vi khớp → tiếp tục.

---

## 3. CHOSEN template: **B — state-composition** (KHÔNG phải Template A)

**Vì sao B:** `search.gen.json` chỉ có **3 node và 0 node `MxCard`**:

| key | component | variant |
| --- | --- | --- |
| `mx-node:search/screen` | MxScaffold | null |
| `mx-node:search/appbar` | MxAppBar | null |
| `mx-node:search/dock` | MxSearchDock | null |

Không có MxCard keyed để gate kiểu review (Template A vòng qua từng MxCard) ⇒ **loại A**. Các "result
card" trong kit là node ĐỘNG (`search/result-0..2`), recent tile động (`search/recent-0..2`), filter
chip (`search/filter-0..3`) — không phải slot MxCard cố định. Đúng khuôn là **assert tập keyed body
node render CHÍNH XÁC theo từng state** (thừa = THỪA, thiếu = THIẾU) — y hệt `dashboard_states_test.dart`
/ `library` (cũng 0 MxCard).

---

## 4. Gate-able node — TÌNH TRẠNG FE HIỆN TẠI (grep đã xác minh)

Grep `mx-node:search` trong `lib/` cho ra ĐÚNG 3 literal keyed — TOÀN BỘ là chrome, KHÔNG có body node nào:

```
lib/.../search_screen.dart:47  ValueKey('mx-node:search/screen')   // MxScaffold (chrome)
lib/.../search_screen.dart:50  ValueKey('mx-node:search/appbar')   // AppBar (chrome)
lib/.../search_screen.dart:55  ValueKey('mx-node:search/dock')     // TextField search dock (chrome)
```

Grep `search/(back|clear|filter|result|recent|no-results|filters)` trong `lib/` → **0 match.**

> ⚠️ ĐÂY LÀ ĐIỂM QUAN TRỌNG NHẤT của màn này: **chưa có literal keyed BODY node nào.** 3 node đã key
> đều là chrome (`screen`/`appbar`/`dock`) — theo mẫu dashboard/library, chrome bị LOẠI khỏi tập gate
> vì không state-driven. Nếu chỉ giữ nguyên FE, tập gate state-composition sẽ RỖNG (không có node phân
> biệt state) → gate vô nghĩa. Vì vậy màn này bắt buộc **rollout một tập ValueKey literal tối thiểu cho
> body** để có node phân biệt được `empty-recent` ↔ `results` ↔ `no-results` (mục 6 + mục 8).

### Node body FE hiện render (chưa key) → cần rollout literal key

| kit node (states skeleton) | FE render hiện tại | key? | quyết định |
| --- | --- | --- | --- |
| `search/recent-0..2` (recent tile) | `_recent()` → `ListTile` per `state.recent` (dynamic list) | ✗ | **thêm 1 literal `search/recent` cho container list** (không key từng tile — list động) |
| `search/filters` + `search/filter-0..3` | `_filterChips()` → `Row` gồm 4 `MxChip` cố định | ✗ | **thêm literal `search/filters` cho hàng chip** (luôn hiện; xem divergence mục 5) |
| `search/result-0..2` (result card) | `_body()` → `ListView.builder` → `ListTile` key `searchResult-<cardId>` (dynamic) | ✗ (dynamic) | **thêm literal `search/results` cho container ListView** (không key từng tile — list động) |
| `search/no-results` (empty-state) | `_body()` → `MxContentBounds` + `Center(MxText(...))` | ✗ | **thêm literal `search/no-results`** |
| `search/back` | AppBar back (Material auto leading) | ✗ | GAP — không key (leading do Navigator cấp, ngoài scope) |
| `search/clear` | `suffixIcon` `IconButton(Icons.clear)` trong dock | ✗ | GAP — nằm trong `search/dock` (chrome), không tách node riêng; note |

> **Nguyên tắc rollout:** chỉ thêm literal key cho **container ổn định phân biệt state** (`search/recent`,
> `search/results`, `search/filters`, `search/no-results`), KHÔNG key từng phần tử list động (recent tile /
> result tile) — chúng là danh sách runtime, giữ key động sẵn có (`searchResult-<cardId>`). Đây đúng khuôn
> library (deck tile key động = identity-rollout gap chấp nhận được). KHÔNG hoist node-literal sau dynamic key.

---

## 5. Divergences → `tool/parity/intent-ledger.json` (KHÔNG ép FE về kit)

Append vào `exceptions[]` của `tool/parity/intent-ledger.json` (giữ nguyên format: `screen`/`node`/`kind`/
`verdict:"exception"`/`exceptionKind`/`reason`/`source`). **Không** sửa FE để khớp kit ở các điểm này:

1. **`search/filters` — filter chip luôn hiện.** Kit đặt filter chip CHỈ trong state có query (`results`/
   `filtered`/`no-results`), ẩn ở `empty recent`. FE `_filterChips()` được vẽ **luôn luôn** (trên cả recent).
   → INTENDED (thanh filter ổn định trên đầu body). `reason` mô tả rõ, `source: docs/business/search/global-search.md`.
   Test composition phản ánh HÀNH VI FE THỰC (filters có mặt ở mọi state — xem state-map), không phải kit lý tưởng.
2. **`search/clear` gộp trong dock.** Kit tách nút close (`search/clear`) thành node riêng trong app-bar.
   FE render nó là `suffixIcon` của TextField `search/dock` (không node riêng). → INTENDED, `source:
   lib/presentation/features/search/screens/search_screen.dart`. GAP identity (không có literal `search/clear`).
3. **`search/back` do Navigator cấp.** Kit key nút back; FE dùng AppBar leading mặc định (Material auto).
   → INTENDED, GAP identity. (Có thể để chung 1 entry `node:"back"` hoặc gộp note — tùy, giữ tối giản.)
4. **Result / recent tile dùng key động.** Kit `search/result-0..N` + `search/recent-0..N` (literal index);
   FE render list động (`searchResult-<cardId>` cho result, ListTile không key cho recent). → INTENDED
   (danh sách runtime), gate qua container literal (`search/results` / `search/recent`), không gate literal index.
   `source: lib/presentation/features/search/screens/search_screen.dart`.
5. **Slot text `RECENT` / result term-meaning-deck.** Skeleton slots là MOCK COPY (`안녕하세요`, `학교`…) —
   KHÔNG copy vào app/test. Label "RECENT" của FE = `l10n.searchRecent` (đã có ARB). → curate qua slots
   nếu cần, KHÔNG cần ledger (đây là binding, không phải divergence).

Nếu bất kỳ mục nào thực chất là **BUG** (không phải chủ ý) → **DỪNG**, báo theo mẫu DRIFT trong
`CLAUDE.md` và chờ người. Không tự sửa UI trong prompt này.

---

## 6. State-map (kit state → cách drive FE tới đúng node-set)

FE là `ConsumerStatefulWidget` điều khiển bởi `searchProvider` (`SearchUiState`). `_body()` phân nhánh:
- `state.searching == true` → `MxStateView.loading()` (loading);
- `query.trim().isEmpty` → `_recent()` (empty-recent nếu `recent` rỗng → `MxContentBounds` hint; nếu có recent → list);
- có query, `filtered` rỗng → `MxContentBounds` no-results (`search/no-results`);
- có query, `filtered` non-empty → `ListView.builder` result tiles (`search/results`).
`_filterChips()` (`search/filters`) LUÔN vẽ ở trên (divergence #1).

Pump pattern: **giống `dashboard_states_test.dart`** — seed Drift in-memory (languagePair + deck + N card),
override `databaseProvider` + `clockProvider(_FixedClock)`, `pumpWidget(host)`. Drive query/filter bằng cách
**bơm state qua provider** hoặc nhập text vào dock rồi pump. Vì `search()` là async (đọc use case), dùng
vòng `for` pump 50ms (KHÔNG `pumpAndSettle` nếu loading có thể spin) — hoặc `pumpAndSettle` nếu ổn định.

| kit state | FE reach được? | Cách drive | Node-set BODY (literal, sau rollout) |
| --- | --- | --- | --- |
| `empty-recent` | ✅ | provider mặc định (`query=''`, `recent` có ≥1 hoặc rỗng) | `search/filters`, `search/recent` (recent list; nếu rỗng → chỉ `filters` + hint, note) |
| `results` | ✅ | seed ≥1 card khớp; set query khớp term → `filtered` non-empty | `search/filters`, `search/results` |
| `no-results` | ✅ | set query KHÔNG khớp card nào → `filtered` rỗng | `search/filters`, `search/no-results` |
| `filtered` | ⚠️ | set query + `setFilter(CardStatus.x)` → cùng nhánh `results`/`no-results` (chỉ lọc list) | = `results` (KHÔNG khác node-set — chỉ đổi số tile trong `search/results`) → **coverage gap** cho node-identity |
| `loading` | ⚠️ | `searching==true` (giữa lúc async) — `MxStateView.loading` không có keyed body node phân biệt | **coverage gap** (skeleton, khó chốt ổn định) |

> **Ba state phân biệt được ở tầng node-identity:** `empty-recent` (recent), `results` (result list),
> `no-results` (empty state). `filtered` KHÔNG phải node-set riêng — nó dùng CÙNG nhánh `results`/`no-results`,
> chỉ khác nội dung list (filter chip đổi `bg`, số tile đổi) → giống player `paused` (cùng node-set) → coverage
> gap, documented-not-driven. `loading` = skeleton, coverage gap.

**Quyết định curate `search.states.json`** (chỉ node body literal FE, bỏ chrome `screen`/`appbar`/`dock`;
`filters` có mặt mọi state do divergence #1):

```jsonc
{
  "empty-recent": ["mx-node:search/filters", "mx-node:search/recent"],
  "results":      ["mx-node:search/filters", "mx-node:search/results"],
  "no-results":   ["mx-node:search/filters", "mx-node:search/no-results"],
  "filtered":     ["mx-node:search/filters", "mx-node:search/results"],
  "loading":      ["mx-node:search/filters"]
}
```

- `filtered` = clone của `results` (documented; test có thể drive nó như 1 case `results` có filter, HOẶC
  bỏ khỏi tập drive và ghi coverage gap — chọn 1, ghi rõ trong `$curated`).
- `loading` chỉ còn `filters` (không body-node phân biệt) → **để NGOÀI tập drive**, coverage gap.
- Node phân biệt thực sự: `recent` (chỉ `empty-recent`), `results` (chỉ `results`/`filtered`),
  `no-results` (chỉ `no-results`). Universe = hợp các tập; assert `results` absent ở `empty-recent`/
  `no-results`, `recent` absent ở `results`/`no-results`, `no-results` absent ở `empty-recent`/`results`
  → ĐÓ là chỗ gate bắt THỪA.

> Nếu khi code, `empty-recent` với `recent` RỖNG chỉ render hint (`MxContentBounds` không key) → hoặc (a)
> key luôn container recent (`search/recent`) kể cả khi rỗng để có node ổn định, hoặc (b) seed `recent`
> non-empty trong test. Chọn (b) đơn giản hơn (seed recent qua `_notifier.search()` 1 lần trước). Ghi rõ.

---

## 7. `search.slots.json` — curate tối giản (hoặc BỎ QUA, ghi lý do)

Skeleton slots chỉ có text `RECENT` (label) + 3 recent term MOCK. Các keyed body node ở đây là **container**
(list/empty-state), phần lớn không mang keyed text slot cố định cần bind role. Hai lựa chọn — ghi rõ trong report:

- **(A) Curate tối giản:** chỉ 1 slot cho `search/recent` label = `{ "name": "recent", "role": "labelMedium",
  "l10n": "searchRecent" }` (FE `MxText.label(l10n.searchRecent)`). Result/recent tile text là key động → không slot.
- **(B) BỎ QUA `search.slots.json`** (như library): các keyed node là container, text tile sống ở list động.
  Ghi lý do trong report; KHÔNG tạo file rỗng.

Mặc định **(B)** (bám library) trừ khi bạn muốn cover label `RECENT` role — khi đó dùng (A). KHÔNG copy mock
copy kit (`안녕하세요`, `학교`, `TOPIK I — Vocabulary`, `No matches`…) vào app/test.

---

## 8. Workflow (thực thi tuần tự, mỗi bước một layer)

1. **Align FE** `search_screen.dart` — rollout ValueKey literal cho body (mục 4):
   - `_filterChips()` container → `key: const ValueKey('mx-node:search/filters')`.
   - `_recent()` `ListView` → `key: const ValueKey('mx-node:search/recent')`.
   - `_body()` result `ListView.builder` → `key: const ValueKey('mx-node:search/results')`.
   - `_body()` no-results `MxContentBounds` → `key: const ValueKey('mx-node:search/no-results')`.
   - KHÔNG key từng recent/result tile (list động — giữ `searchResult-<cardId>`). KHÔNG hoist node-literal
     sau dynamic key. KHÔNG hardcode màu/spacing/text-style/duration/string — dùng `Mx*` + token + `MxSpacing`.
   - KHÔNG thêm node mới cho `search/back` / `search/clear` (ngoài scope; đã vào ledger là GAP).
2. **Curate `tool/parity/contracts/search.states.json`** từ skeleton theo bảng mục 6 (chrome
   `screen`/`appbar`/`dock` bị loại; `filters` mọi state; `filtered`/`loading` = documented gap). Thêm
   `$curated` header (bắt chước `dashboard.states.json`) giải thích: 3 state drive được, `filtered`=clone
   `results`, `loading`=skeleton gap, `filters` luôn hiện (divergence #1).
3. **`search.slots.json`**: theo mục 7 — (A) curate label `searchRecent` HOẶC (B) bỏ qua (ghi lý do). KHÔNG ship skeleton.
4. **l10n**: `searchHint`, `searchRecent`, `searchFilterAll`, `searchNoResults` đã có **cả** `app_en.arb` +
   `app_vi.arb` (đã verify). Filter chip khác dùng `cardStatusNew/Due/Mastered` (đã có). Nếu thêm/đổi chuỗi
   user-facing nào → thêm vào **CẢ HAI** ARB cùng lúc rồi regen l10n. KHÔNG sửa `lib/l10n/generated/**` tay.
5. **Viết test composition** `test/presentation/features/search/search_states_test.dart` — COPY cấu trúc
   `dashboard_states_test.dart`:
   - đọc `tool/parity/contracts/search.states.json`, tính `universe = hợp các tập`;
   - `recipes` seed + drive cho từng state (`empty-recent`: recent seed; `results`: card khớp + query;
     `no-results`: query không khớp; `filtered`: results + `setFilter`; `loading`: bỏ — gap);
   - pump `SearchScreen()` trong host (override `databaseProvider` + `clockProvider`), drive query qua
     `searchProvider.notifier.search(q)` / `setFilter`, pump vòng `for` 50ms (không `pumpAndSettle` nếu spin);
   - assert mỗi key trong universe: allowed → `findsOneWidget` (THIẾU nếu absent), ngoài allowed →
     `findsNothing` (THỪA nếu present);
   - header test giải thích rõ `filtered`/`loading` coverage gap + `filters` luôn hiện (giống review_parity
     giải thích state không map).
6. **Xóa skeleton** đã tiêu thụ: `tool/parity/contracts/search.slots.skeleton.json` +
   `search.states.skeleton.json` (skeleton là AUTO-PROPOSED, không ship).
7. **Cập nhật queue**: đổi `[ ] 13-search.md` → `[x]` trong `docs/agent/kit-to-flutter/README.md`.
8. **Doc parity**: nếu divergence ảnh hưởng behavior đã ghi ở `docs/business/search/global-search.md` →
   update cùng commit (thường chỉ cần intent-ledger; xác nhận rồi ghi rõ trong report).

---

## 9. Hard rules (vi phạm = task fail — trích `CLAUDE.md`)

- **Token-only:** KHÔNG hardcode màu, radius, spacing, text style, duration, chuỗi user-facing. Dùng `Mx*`
  widget + theme token + `MxSpacing`. String lấy từ ARB (`lib/l10n/`).
- **Rollout key đúng khuôn:** mỗi `ValueKey('mx-node:...')` là `const` gắn container tĩnh phân biệt state;
  KHÔNG sinh key động theo index/state; KHÔNG hoist node-literal sau dynamic key; KHÔNG key từng tile list động.
- **Divergence → intent-ledger**, KHÔNG ép FE về kit (filters luôn hiện, clear gộp dock, back Navigator,
  tile key động). Nếu là BUG chứ không phải chủ ý → DỪNG, báo mẫu DRIFT, chờ người.
- **KHÔNG copy MOCK COPY** từ kit spec vào app/test làm assert văn bản.
- **l10n cả hai ARB:** mọi chuỗi mới vào `app_en.arb` **và** `app_vi.arb` cùng commit; regen l10n.
- **KHÔNG ship skeleton** làm curated; phải trim rồi xóa 2 skeleton.
- **KHÔNG bịa** `filtered`/`loading` thành state riêng nếu không phân biệt được node-set sạch → hạ xuống
  coverage gap và báo. ĐỪNG viết test giả chỉ để có state.
- **KHÔNG sửa generated** (`*.g.dart`, `*.freezed.dart`, `search.gen.json`, `lib/l10n/generated/**`, `docs/_generated/**`).
- **KHÔNG thêm dependency** mới (Stop & ask nếu cần).
- **KHÔNG đổi hành vi search** đã spec (term+meaning, filter theo CardStatus, recent trong session) — task này thuần style/identity-parity.

---

## 10. Verification

```bash
node tool/verify/run.mjs --full
```

Phải PASS (ghi pass-marker cho pre-commit hook). Trong đó có test parity mới + freshness check của specs.
Nếu `--full` fail hoặc bị skip → KHÔNG được báo done. Trong lúc dev có thể `--quick` (không marker). Chạy
riêng test mới để chắc: `flutter test test/presentation/features/search/search_states_test.dart`.

Sau khi verify PASS, TRƯỚC final report: fan-out song song `code-reviewer` (review working-tree diff — cho
nó chạy `git add -N .` rồi `git diff`, không commit trước) + `docs-drift-detector`. Gộp findings vào mục
"Subagent review", fix blocker trước khi kết; liệt kê minor cho user.

---

## 11. Commit (2 commit + WBS)

**Commit 1** — FE identity rollout + contract + test:
```
test(parity): search state-composition gate (empty-recent/results/no-results) + body ValueKey rollout

- add literal ValueKey('mx-node:search/{filters,recent,results,no-results}') to search_screen.dart body
- curate tool/parity/contracts/search.states.json (3 gated states; filtered/loading coverage gaps documented)
- add test/presentation/features/search/search_states_test.dart (Template B, copy dashboard_states_test)
- search.slots.json: <curated searchRecent label | intentionally skipped — reason>
- remove consumed skeletons (search.slots.skeleton.json, search.states.skeleton.json)

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>
```

**Commit 2** — docs/ledger + queue:
```
docs(parity): search divergences → intent-ledger; mark search done in kit-to-flutter queue

- intent-ledger: filters-always-shown, clear-in-dock, back-navigator, dynamic tile keys
- README queue: 13-search → [x]

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>
```

**WBS** (bắt buộc, `CLAUDE.md` §WBS): append 1 dòng vào Commit Traceability Log (§10 của
`docs/project-management/wbs.md`), newest first:
`<8-char hash> · <YYYY-MM-DD> · <WBS IDs> · search kit→flutter state-composition parity (Template B; empty-recent/results/no-results gated, filtered/loading gap)`.
Nếu WBS task breakdown không đổi, report ghi: `WBS update: not needed — <reason>` (nhưng Commit
Traceability Log vẫn append nếu advance WP).

---

## 12. Final report format

```
## search — kit→flutter DONE
- Template: B (state-composition) — lý do: 0 MxCard trong search.gen.json (chỉ MxScaffold/MxAppBar/MxSearchDock)
- FE identity rollout: added literal keys search/{filters,recent,results,no-results} (body); chrome screen/appbar/dock đã có sẵn
- Gate-able keyed body nodes: filters, recent, results, no-results  [+ chrome screen/appbar/dock loại khỏi gate]
- Contracts: search.states.json curated; search.slots.json (<curated | skipped — reason>); 2 skeleton deleted
- Gated states: empty-recent (recent), results (result list), no-results (empty state)  [3]
- Coverage gap: filtered (cùng node-set với results — chỉ lọc list/đổi chip), loading (MxStateView skeleton, không keyed body node)  [2]
- Divergences → intent-ledger: filters-always-shown, clear-in-dock, back-navigator, dynamic tile keys (searchResult-<id>)
- Identity-rollout gap (không key trong FE): search/back, search/clear, result/recent tile động
- l10n: searchHint/searchRecent/searchFilterAll/searchNoResults + cardStatus* đã có ở app_en.arb + app_vi.arb [no new keys | new: ...]
- Docs updated: <list | none — style/identity-parity only>
- WBS update: <line appended | not needed — reason>
- Verify: node tool/verify/run.mjs --full → PASS
- Subagent review: <blockers fixed | minor findings ...>
```
