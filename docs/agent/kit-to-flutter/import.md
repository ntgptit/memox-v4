# Kit → Flutter conversion prompt — **import**

> SELF-CONTAINED. Đọc hết file này rồi thực thi tuần tự. Không cần đọc file prompt nào khác.
> Nhiệm vụ: đóng **state-composition parity gate** cho màn `import` (KHÔNG vẽ lại UI — UI đã có
> sẵn; việc ở đây là **curate contract + viết 1 test composition** theo Template B, + align
> `ValueKey` identity + l10n hai ARB).
> Nếu gặp DRIFT hoặc DIVERGENCE cần người quyết → DỪNG, báo theo mẫu `DRIFT DETECTED` của
> `CLAUDE.md`, chờ.

---

## PROMPT ID

`kit-to-flutter/import` · screen `import` · feature `import_export` · 5 kit states
(`source` / `mapping` / `preview` / `dup-warning` / `done`).
FE: `lib/presentation/features/import_export/screens/import_screen.dart`.

---

## Baseline

```bash
git checkout main
git pull --ff-only
git checkout -b claude/kit-to-flutter-import
```

Không bắt đầu khi working tree bẩn. Xác nhận `node tool/verify/run.mjs --quick` xanh trước khi sửa.

---

## Required reading (đọc trước khi code)

Universal (theo `CLAUDE.md`): `docs/_generated/repo-map.md`, `docs/_generated/where-is.md`,
`docs/business/index.md`, `docs/business/glossary.md`, `docs/contracts/error-contract.md`,
`docs/contracts/types-catalog.md`, `docs/contracts/code-style.md`.

Screen-specific — CHỈ đọc đúng các file này:
- `docs/design/MemoX Design System/ui_kits/memox-app/specs/import.md` — token-resolved DOM, 5 state
  (`source` là base; `mapping` / `preview` / `dup-warning` / `done` là full-diff).
- `tool/parity/contracts/import.gen.json` — 7 keyed node (key/component/variant). **Đã xác minh: 0 MxCard.** KHÔNG sửa (generated).
- `tool/parity/contracts/import.slots.skeleton.json` — slot skeleton (SUPERSET, chỉ curate nếu có keyed text; xem dưới).
- `tool/parity/contracts/import.states.skeleton.json` — per-state node membership (SUPERSET, phải trim).
- FE: `lib/presentation/features/import_export/screens/import_screen.dart`.
- **Reference test cần COPY (Template B):** `test/presentation/features/engagement/dashboard_states_test.dart`.
- Curated mẫu để bắt chước format: `tool/parity/contracts/dashboard.states.json`, `dashboard.slots.json`.
- Contrast (KHÔNG áp dụng ở đây, chỉ để hiểu vì sao loại B thay vì A):
  `test/presentation/features/study/review_parity_test.dart` (Template A, MxCard-rich),
  `tool/parity/contracts/review.states.json`, `review.slots.json`.
- Business doc của màn: `docs/business/**` import-export (D-025). Xác nhận hành vi FE = soft-dup
  (đếm trùng, **không chặn**) khớp doc; kit `dup-warning` là 1 callout cảnh báo, không block.

**Drift check trước khi code (BẮT BUỘC, đọc kỹ):** Kit vẽ `import` là **wizard 5 bước** (mỗi state
là 1 màn khác hẳn: chọn nguồn → map cột → preview → cảnh báo trùng → done). **FE hiện tại KHÔNG
phải wizard** — nó là **1 màn cuộn dọc duy nhất** (`ListView`), điều khiển bởi `_rows == null` và
`_result == null`:
- chưa có dữ liệu → chỉ hiện 2 nút nguồn (`importPickFile` / `importPaste`);
- có `_rows` → **inline** hiện separator dropdown + header switch + 2 column-picker + preview 5 dòng
  + nút `import/do-import` (KHÔNG có bước preview riêng, KHÔNG có `to-preview`);
- có `_result` → hiện dòng kết quả `importDone(...)` + nút `import/go-deck`;
- có `_error` → hiện dòng lỗi.

Đây là **divergence kiến trúc có chủ đích của FE v1** (single-screen thay vì wizard), KHÔNG phải bug
→ ghi vào intent-ledger (mục "Divergences"), **KHÔNG** tự vẽ lại thành wizard trong prompt này. Nếu
bạn cho rằng single-screen mâu thuẫn business doc (vd doc bắt buộc bước dup-warning chặn import) →
DỪNG, báo DRIFT, chờ người. Mặc định: FE single-screen = intended, test theo hành vi FE THỰC.

---

## CHOSEN template: **B — state-composition** (KHÔNG phải Template A)

**Vì sao B:** `import.gen.json` có **0 node `MxCard`**. 7 node của nó là:
`MxScaffold` (`import/screen`), `MxAppBar` (`import/appbar`),
`MxButton` primary (`import/do-import`, `import/go-deck`, `import/to-preview`),
`MxIconButton` (`import/map-term-pick`, `import/map-meaning-pick`).
Các **SourceCard** (CSV/Excel/Paste) và **preview Table** trong kit là markup tuỳ biến (`card` /
`div repeat`), KHÔNG map sang `MxCard` keyed literal — chúng là node động/custom, không có identity
cố định để gate kiểu review.

→ Không có slot MxCard cố định để gate kiểu Template A. Đúng khuôn là **assert tập keyed node render
CHÍNH XÁC theo từng state** (thừa = THỪA, thiếu = THIẾU) — y hệt `dashboard_states_test.dart`.

> KHÔNG dùng Template A: import không có MxCard keyed; thân màn là control/flow, không phải card-centric.

---

## Gate-able node list (keyed trong FE — đã xác minh bằng grep)

`grep mx-node:import/ lib/` cho ĐÚNG 6 literal keyed sau (import_screen.dart):

| key | component (gen) | variant | FE hiện tại (dòng) | render trong state (FE) |
| --- | --- | --- | --- | --- |
| `mx-node:import/screen` | MxScaffold | null | ✓ `MxScaffold` (L122) | mọi state (chrome) |
| `mx-node:import/appbar` | MxAppBar | null | ✓ `MxAppBar` (L124) | mọi state (chrome) |
| `mx-node:import/map-term-pick` | MxIconButton | null | ⚠ `DropdownButtonFormField<int>` (L181) — divergence | khi có `_rows` (≈ mapping) |
| `mx-node:import/map-meaning-pick` | MxIconButton | null | ⚠ `DropdownButtonFormField<int>` (L190) — divergence | khi có `_rows` (≈ mapping) |
| `mx-node:import/do-import` | MxButton | primary | ✓ `MxButton` (L203) | khi có `_rows` (≈ preview) |
| `mx-node:import/go-deck` | MxButton | primary | ✓ `MxButton` (L217) | khi có `_result` (≈ done) |

> LƯU Ý sự thật FE quan trọng cho test:
> - `map-term-pick`, `map-meaning-pick`, `do-import` **cùng render** trong một khối
>   `if (rows != null && rows.isNotEmpty)` → chúng xuất hiện **đồng thời**, KHÔNG phân biệt được
>   `mapping` vs `preview` (FE gộp mapping+preview vào 1 khối inline). ⇒ FE chỉ có **2 node-set body
>   phân biệt được**: {có `_rows`} và {có `_result`}.
> - `go-deck` chỉ render khi `_result != null` → node thực sự phân biệt state `done`.

**Node trong gen.json NHƯNG không keyed / không tồn tại ở FE (identity-rollout gap):**
- `mx-node:import/to-preview` — kit là nút "Continue" ở cuối bước `mapping` để sang `preview`. FE
  KHÔNG có bước preview riêng ⇒ **không có nút này** trong FE. Gap.

**Node keyed trong SPEC (states.skeleton) nhưng KHÔNG có trong gen.json và KHÔNG keyed ở FE:**
`import/back`, `import/source-0`, `import/source-1`, `import/source-2`, `import/paste`,
`import/sep-0..2`, `import/map-term`, `import/map-meaning`, `import/dup-warning`, `import/done`.
Đây là node kit-only (SourceCard, separator chip, dup callout, done panel). FE render tương đương
bằng widget KHÁC, key KHÁC (`Key('import')`, `Key('importPickFile')`, `Key('importPaste')`,
`Key('importResult')`, `Key('importError')`) — KHÔNG phải literal `mx-node:import/*`. ⇒ identity gap,
liệt kê trong report, KHÔNG ép thêm key mới trừ khi cũng thêm hành vi thật (ngoài scope style-parity).

---

## Per-state node SET (curate cho `import.states.json`)

Từ `import.states.skeleton.json`, **trim** SUPERSET (bỏ chrome `screen`/`appbar` — theo mẫu
dashboard/review, chrome KHÔNG state-driven; bỏ node kit-only chưa keyed ở FE) xuống tập BODY do
state điều khiển mà FE THỰC render bằng literal `mx-node:import/*`.

Chỉ **2 node-set body ổn định** trong FE hiện tại. Ánh xạ kit-state → FE:

```jsonc
{
  "source":      [],
  "mapping":     ["mx-node:import/map-term-pick", "mx-node:import/map-meaning-pick", "mx-node:import/do-import"],
  "preview":     ["mx-node:import/map-term-pick", "mx-node:import/map-meaning-pick", "mx-node:import/do-import"],
  "dup-warning": ["mx-node:import/map-term-pick", "mx-node:import/map-meaning-pick", "mx-node:import/do-import"],
  "done":        ["mx-node:import/go-deck"]
}
```

Giải thích để đưa vào `$curated` note:
- `source` = trạng thái ban đầu (`_rows == null`): **không có** keyed body node nào (2 nút nguồn
  `importPickFile`/`importPaste` dùng `Key(...)` FE-only, không phải `mx-node:*`) → tập rỗng. Universe
  của các state khác đều phải **absent** ở `source` → đây là chỗ gate bắt THỪA (vd `do-import` rò rỉ
  vào state source).
- `mapping` / `preview` / `dup-warning` **cùng node-set** trong FE: cả ba đều là trạng thái "đã có
  `_rows`", FE render inline mapping+preview+button cùng lúc. FE KHÔNG phân biệt được 3 kit-state này
  ⇒ chỉ **1 state driveable thực** (đặt tên `mapping` để drive; `preview`/`dup-warning` giữ trong JSON
  cho đủ bộ documented nhưng **không drive riêng** — coverage gap, ghi rõ). dup-warning callout
  (`import/dup-warning`) là node kit-only chưa keyed ở FE ⇒ không nằm trong set.
- `done` = có `_result` (`import/go-deck`).

> Node THỰC SỰ phân biệt state: `go-deck` (chỉ `done`) và cụm {map-term-pick, map-meaning-pick,
> do-import} (chỉ khi có `_rows`, absent ở `source`/`done`). Universe = hợp các tập; assert cụm rows
> absent ở `source`+`done`, và `go-deck` absent ở `source`+`mapping`. ĐÓ là nơi gate bắt THỪA.

**`import.slots.json`: BỎ QUA.** Các keyed node ở màn này là control (button/icon-button), KHÔNG mang
keyed text slot cần bind role/l10n. Text nguồn (CSV/Excel/Paste labels), separator chip, preview cell,
done copy đều nằm trong widget kit-only hoặc FE-only key (không keyed literal) ⇒ không gate qua slots
ở màn này. Skeleton `import.slots.skeleton.json` chỉ liệt kê text của node kit-only (source-0..2,
paste) — KHÔNG có node keyed FE nào mang text slot. → **KHÔNG tạo** `import.slots.json`; ghi rõ lý do
trong report (giống library đã bỏ qua slots).

---

## State-map: state nào drive được / state nào là coverage gap

FE là 1 `ConsumerStatefulWidget` điều khiển bởi `_rows` / `_result` / `_error`. Pump theo mẫu
`dashboard_states_test.dart`: override `databaseProvider` (+ `clockProvider` nếu cần) với Drift
in-memory, seed `languagePair` + `deck`, `pumpWidget(host(deckId))`, `pumpAndSettle`. Vì `source`/`done`
phụ thuộc state nội bộ (`_rows`, `_result`) KHÔNG thể set trực tiếp từ ngoài, xem cột "cách drive".

| kit state | drive được trong FE? | cách drive | node-set |
| --- | --- | --- | --- |
| `source` | ✅ | pump màn với deck seed, KHÔNG tương tác → `_rows == null` | `[]` (tập rỗng — mọi keyed body absent) |
| `mapping` | ✅ | cần có `_rows`. **Drive bằng paste**: đặt clipboard qua `Clipboard.setData` / `SystemChannels.platform` mock rồi tap `Key('importPaste')`, HOẶC (sạch hơn) override `tableCodecProvider` + bơm rows. Sau khi `_rows` set → khối inline hiện | `{map-term-pick, map-meaning-pick, do-import}` |
| `preview` | ⚠️ | = cùng node-set với `mapping` (FE gộp). Không phân biệt được ⇒ **không drive riêng** | (= mapping) |
| `dup-warning` | ⚠️ | callout `import/dup-warning` không keyed ở FE; soft-dup đếm nhưng UI cảnh báo chưa có node keyed ⇒ **coverage gap** | (= mapping) |
| `done` | ✅ | sau khi có `_rows`, gọi import (tap `import/do-import`) với deck seed → `_result` set → `go-deck` hiện. Nếu drive qua UI khó ổn định, có thể seed rows + tap do-import và `pumpAndSettle` | `{go-deck}` |

**Gate:** `source`, `mapping` (đại diện cho mapping/preview/dup-warning), `done`.
**Coverage gap:** `preview` (cùng node-set mapping — FE không tách bước), `dup-warning` (callout chưa
keyed ở FE). Ghi rõ trong header test (giống `review_parity_test` giải thích state không map) và trong
`$curated` note của `import.states.json`.

> Nếu khi code phát hiện KHÔNG drive được `mapping` hoặc `done` sạch bằng seed/override/tap
> (vd paste cần platform channel khó mock, hoặc `do-import` cần async settle không ổn định) → thử
> đường override provider (`tableCodecProvider` bơm `_rows` trực tiếp không có; nếu vậy dùng
> `Clipboard`/`SystemChannels.platform` mock cho paste). Nếu vẫn không sạch → hạ state đó xuống
> coverage gap và báo rõ trong report. **ĐỪNG viết test giả (fake) chỉ để có state.**

---

## Divergences → intent-ledger

Ghi các mục sau vào intent-ledger dự án đang dùng (`tool/parity/intent-ledger.json` — append, giữ
format hiện có; nếu chưa có mục `import` → tạo entry theo cấu trúc các screen khác). Mỗi mục:
`screen · node · kit-nói-gì · FE-làm-gì · lý do giữ`. **KHÔNG** sửa FE để khớp kit ở các điểm này:

1. **Single-screen thay vì wizard** — kit `import` là wizard 5 bước (source→mapping→preview→
   dup-warning→done, mỗi bước 1 màn); FE là 1 `ListView` cuộn, hiện inline theo `_rows`/`_result`.
   → INTENDED (v1 single-screen), test theo hành vi FE thực. Reason:
   `"fe import = single scrolling screen (rows/result driven), not a 5-step wizard"`.
2. **`import/map-term-pick` / `import/map-meaning-pick`** — kit `MxIconButton` (nút mở picker cột);
   FE dùng `DropdownButtonFormField<int>` (đã gắn đúng `ValueKey`). → INTENDED (dropdown chọn cột thay
   vì icon-button + sheet). Reason: `"fe column pick = DropdownButtonFormField, kit = MxIconButton picker"`.
3. **SourceCard (CSV/Excel/Paste)** — kit là 3 `card` + 1 paste textarea keyed
   (`source-0..2`, `paste`); FE là **2 nút** `importPickFile` (secondary) + `importPaste` (outline),
   dùng file picker + clipboard, KHÔNG có textarea paste inline, KHÔNG có 3 card riêng. → INTENDED
   (v1 gọn: 1 nút file cho cả csv/xlsx, 1 nút paste). Reason: `"fe source = 2 buttons (pick file + paste), kit = 3 source cards + textarea"`.
4. **dup-warning ActionCallout** — kit là 1 callout `import/dup-warning` (warning-soft, "N cards
   already exist — import anyway?"); FE **soft-dup** đếm trùng và báo trong `importDone(count, dup)`
   sau khi import, KHÔNG có callout chặn/hỏi trước. → INTENDED (soft-dup không block, D-025). Reason:
   `"fe soft-dup counts duplicates in result line, kit shows a pre-import warning callout"`.
5. **`import/to-preview` thiếu** — kit có nút "Continue" chuyển mapping→preview; FE không có bước
   preview riêng ⇒ không có nút. → GAP (không phải màn này giải quyết).
6. **Separator / header** — kit `mapping` có separator chip (`sep-0..2`); FE dùng
   `DropdownButtonFormField<Separator>` + `MxSwitch` header, không keyed literal. → INTENDED (control
   khác), không gate.

Nếu bất kỳ mục nào thực chất là **BUG** (không phải chủ ý, mâu thuẫn business doc) → **DỪNG**, báo
DRIFT theo `CLAUDE.md` và chờ người. Không tự sửa UI trong prompt này.

---

## Workflow (thực thi tuần tự, mỗi bước một layer)

1. **Curate `tool/parity/contracts/import.states.json`** từ skeleton theo bảng mục "Per-state node
   SET": 5 state key (`source`/`mapping`/`preview`/`dup-warning`/`done`), chỉ node keyed FE, bỏ chrome
   `screen`/`appbar` và node kit-only. Thêm `$curated` header (bắt chước `dashboard.states.json` /
   `review.states.json`) giải thích: `source` = tập rỗng (2 nút nguồn dùng key FE-only);
   mapping/preview/dup-warning cùng node-set (FE gộp inline, chỉ drive `mapping`; preview/dup-warning =
   documented coverage gap); `done` = `go-deck`.
2. **`import.slots.json`: BỎ QUA** — không tạo file (kể cả rỗng). Ghi lý do trong report (không có
   keyed text slot; text nằm ở node kit-only / key FE-only).
3. **Align FE** `import_screen.dart` — CHỈ khi cần để test drive được và giữ token-only:
   - Xác nhận 6 `ValueKey('mx-node:import/*')` hiện có đúng chính tả (grep đã confirm 6 node).
   - KHÔNG thêm node/wizard mới; KHÔNG đổi single-screen thành wizard (divergence #1 đã vào ledger).
   - KHÔNG hardcode màu/spacing/text-style/duration/string; FE hiện dùng `Mx*` + `MxSpacing` — giữ
     nguyên. Nếu thấy hardcode → sửa về token cùng commit (ghi trong report).
   - KHÔNG hoist node-literal sau dynamic key.
4. **l10n (cả hai ARB)** — các key màn dùng: `importTitle`, `importPickFile`, `importPaste`,
   `importSeparator`, `importHasHeader`, `importTermColumn`, `importMeaningColumn`, `importPreview`,
   `importRun`, `importDone`, + `commonBack`, `transferError`. Đã có trong `lib/l10n/app_en.arb`
   (verify). **Bắt buộc kiểm tra `lib/l10n/app_vi.arb` có ĐỦ các key này**; nếu thiếu key nào →
   thêm bản dịch vào `app_vi.arb` (và `app_en.arb` nếu thiếu) **cùng commit**, regen l10n
   (`lib/l10n/generated/**` — KHÔNG sửa tay). KHÔNG copy MOCK COPY từ kit ("Import cards",
   "CSV file", "안녕하세요"…) vào app/test.
5. **Viết test composition** `test/presentation/features/import_export/import_states_test.dart`:
   COPY cấu trúc `dashboard_states_test.dart` (đọc `import.states.json`, tính `universe`, `recipes`
   drive từng state, pump `ImportScreen(deckId: ...)`, assert mỗi key trong universe: allowed →
   `findsOneWidget` (THIẾU nếu absent), ngoài allowed → `findsNothing` (THỪA nếu present)).
   - Seed Drift in-memory: `languagePair` (ko→vi) + `deck` (theo `review_parity_test`/
     `library_screen_test`); `ImportScreen` cần `deckId`.
   - `recipes`: `source` = pump không tương tác; `mapping` = drive để có `_rows` (paste qua
     `Clipboard`/`SystemChannels.platform` mock, HOẶC cách sạch nhất bạn tìm được); `done` = có `_rows`
     rồi tap `Key('mx-node:import/do-import')` + `pumpAndSettle`. `preview`/`dup-warning` KHÔNG có trong
     `recipes` (comment lý do coverage gap — cùng node-set mapping / callout chưa keyed).
   - Header test giải thích rõ coverage gap (giống `review_parity_test` giải thích `editing`/`audio`).
6. **Xóa skeleton** đã tiêu thụ: `tool/parity/contracts/import.states.skeleton.json` **và**
   `tool/parity/contracts/import.slots.skeleton.json` (skeleton là AUTO-PROPOSED, không ship — theo
   ghi chú `$skeleton`; slots skeleton bỏ nhưng vẫn xóa vì đã quyết định không curate).
7. **Cập nhật queue**: đổi ô `import` → done trong `docs/agent/kit-to-flutter/README.md` (giữ nhất
   quán tên file/màn) cùng commit.
8. **Doc parity**: nếu có divergence ảnh hưởng behavior đã ghi ở `docs/business/**` (import-export
   D-025) hoặc `docs/design/**`, cập nhật cùng commit. Thường chỉ cần intent-ledger (task thuần
   style-parity). Nếu single-screen mâu thuẫn business doc → xem Drift check, DỪNG & báo.

---

## Hard rules (vi phạm = task fail — trích `CLAUDE.md`)

- KHÔNG vẽ lại/di chuyển UI; KHÔNG đổi single-screen FE thành wizard. Chỉ curate contract + viết test
  + align key + l10n. Divergence → intent-ledger, không tự sửa UI.
- **Token-only**: không hardcode màu, radius, spacing, text style, duration, chuỗi user-facing. Dùng
  `Mx*` widget + theme token + `MxSpacing`.
- **l10n cả hai ARB**: mọi key user-facing phải có ở `app_en.arb` **và** `app_vi.arb` cùng commit;
  regen l10n; KHÔNG sửa `lib/l10n/generated/**` tay. KHÔNG copy mock copy từ kit vào app/test.
- KHÔNG ship skeleton làm curated; phải trim ra bản chính rồi **xóa cả 2 skeleton**.
- KHÔNG bịa state nếu không drive được sạch → hạ xuống coverage gap và báo.
- KHÔNG node-literal hoist sau dynamic key; mỗi `ValueKey('mx-node:...')` là `const` gắn đúng node tĩnh.
- KHÔNG sửa file generated (`*.g.dart`, `*.freezed.dart`, `import.gen.json`,
  `lib/l10n/generated/**`, `docs/_generated/**`).
- KHÔNG thêm dependency mới (Stop & ask nếu cần).
- KHÔNG đổi hành vi import/soft-dup (D-025: đếm trùng, không block).
- KHÔNG đánh dấu done nếu `node tool/verify/run.mjs --full` chưa xanh.

---

## Verification

```bash
node tool/verify/run.mjs --full
```

Phải XANH (ghi pass-marker mà pre-commit hook yêu cầu; gồm test parity mới + freshness check của
specs). Nếu đỏ hoặc bị skip → sửa, KHÔNG commit vòng qua, KHÔNG báo done. Trong lúc dev có thể
`--quick` (không marker). Chạy riêng test mới cho chắc:
`flutter test test/presentation/features/import_export/import_states_test.dart`.

Sau khi verify PASS, **TRƯỚC final report**: fan-out song song (1 lượt, nhiều `Agent` call)
`code-reviewer` (review working-tree diff — cho nó chạy `git add -N . && git diff`) +
`docs-drift-detector`. Gộp findings vào mục "Subagent review". Sửa blocker trước khi kết.

---

## Commit (2 commit + WBS)

**Commit 1** — contract + test + FE align + l10n:
```
test(parity): import state-composition gate (source/mapping/done) + curated states.json

- curate tool/parity/contracts/import.states.json (Template B; source/mapping/done gated,
  preview/dup-warning documented coverage gap)
- add test/presentation/features/import_export/import_states_test.dart (copy dashboard_states_test)
- remove consumed skeletons (import.states.skeleton.json, import.slots.skeleton.json)
- import.slots.json intentionally skipped (no keyed text slot; source/preview are kit-only markup)
- align import_screen.dart ValueKey identity + l10n parity (app_en/app_vi)

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>
```

**Commit 2** — docs/ledger + queue:
```
docs(parity): import divergences → intent-ledger; mark import done in kit-to-flutter queue

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>
```

**WBS** (bắt buộc, `CLAUDE.md` §WBS): thêm dòng Commit Traceability Log (§10 của
`docs/project-management/wbs.md`), newest first:
`<8-char hash> · <YYYY-MM-DD> · <WBS IDs> · import kit→flutter state-composition parity (Template B; source/mapping/done gated, preview/dup-warning coverage gap)`.
Nếu WBS breakdown không đổi, report ghi `WBS update: not needed — <reason>` (nhưng Commit
Traceability Log vẫn append khi advance WP).

---

## Final report format (đưa vào tin nhắn cuối)

```
## import — kit→flutter DONE
- Template: B (state-composition) — lý do: 0 MxCard trong import.gen.json (source cards + preview table là markup kit-only)
- Gate-able keyed node (FE, grep): map-term-pick, map-meaning-pick, do-import, go-deck (+ chrome screen/appbar loại khỏi gate)  [6 keyed / 4 body-gated]
- Contracts: import.states.json curated; import.slots.json BỎ QUA (không có keyed text slot); 2 skeleton deleted
- Gated states: source (empty set), mapping (map picks + do-import), done (go-deck)
- Coverage gap: preview (cùng node-set mapping — FE gộp inline, không tách bước), dup-warning (soft-dup, callout chưa keyed ở FE)
- Divergences → intent-ledger: single-screen vs wizard, column pick=Dropdown vs MxIconButton, source=2 buttons vs 3 cards+textarea, dup=result-line vs pre-import callout, to-preview thiếu, separator=Dropdown+Switch
- Identity-rollout gap (chưa key ở FE): import/back, import/to-preview, import/source-0..2, import/paste, import/sep-0..2, import/map-term, import/map-meaning, import/dup-warning, import/done
- l10n: importTitle/importPickFile/importPaste/importSeparator/importHasHeader/importTermColumn/importMeaningColumn/importPreview/importRun/importDone/commonBack/transferError — app_en + app_vi parity [no new keys | new keys: ...]
- Docs updated: <list | none — style-parity only>
- WBS: <line appended | not needed — reason>
- Verify: node tool/verify/run.mjs --full → PASS
- Subagent review: <blockers fixed | minor findings ...>
```
