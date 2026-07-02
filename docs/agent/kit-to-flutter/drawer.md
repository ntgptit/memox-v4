# Kit → Flutter conversion prompt — **drawer**

> SELF-CONTAINED. Đọc hết file này rồi thực thi tuần tự. Không cần đọc file prompt nào khác.
> Nhiệm vụ: đóng **state-composition parity gate** cho `drawer` (KHÔNG vẽ lại UI — UI đã có
> sẵn; việc ở đây là **curate contract + viết/extend 1 test composition** theo Template B).
> Nếu gặp DRIFT hoặc DIVERGENCE cần người quyết → DỪNG, báo theo mẫu `DRIFT DETECTED`
> trong `CLAUDE.md`, chờ người.

---

## PROMPT ID

`kit-to-flutter/drawer` · screen `drawer` · **KHÔNG phải màn thường** — đây là **navigation
drawer dùng chung của app shell** + hai luồng add / remove language. 3 kit state:
`open` / `add-language` / `remove-language`.

**FE (đã resolve):** `lib/presentation/shared/navigation/app_drawer.dart` — 1
`ConsumerStatefulWidget` (`AppDrawer`) điều khiển bởi enum `_DrawerView { menu, addLanguage,
removeLanguage }`. Test hiện có: `test/presentation/shared/navigation/app_drawer_test.dart`.

> **Lưu ý drawer là component dùng chung (không phải 1 route/screen):** khác mọi màn khác trong
> queue, drawer KHÔNG có route riêng và KHÔNG render qua `MxScaffold`. Nó là `Drawer` gắn vào
> `Scaffold.drawer` của shell. Hệ quả cho parity (đọc kỹ, ảnh hưởng cả template lẫn cách pump):
> - Không seed "màn" qua router; host test dựng `Scaffold(drawer: AppDrawer())` rồi
>   `openDrawer()` (đúng như `app_drawer_test.dart` đang làm — TÁI SỬ DỤNG helper đó).
> - State `open` (menu) không phải overlay MxScaffold mà là **panel trượt** trong `Drawer`;
>   `add-language`/`remove-language` là **cùng widget** đổi `_view`, KHÔNG phải push route mới.
> - Vì cùng 1 widget đổi `_view`, cả 3 state reach được **trong cùng 1 test host** chỉ bằng
>   `tester.tap` vào menu item (không cần router / seed lại DB giữa state).

---

## Baseline

```bash
git checkout main
git pull --ff-only
git checkout -b claude/kit-to-flutter-drawer
```

Không bắt đầu khi working tree bẩn. Xác nhận `node tool/verify/run.mjs --quick` xanh trước khi sửa.

---

## Required reading (CHỈ đọc đúng các file này)

Universal (theo `CLAUDE.md`): `docs/_generated/repo-map.md`, `docs/_generated/where-is.md`,
`docs/business/index.md`, `docs/business/glossary.md`, `docs/contracts/error-contract.md`,
`docs/contracts/types-catalog.md`, `docs/contracts/code-style.md`.

Screen-specific:
- `docs/design/MemoX Design System/ui_kits/memox-app/specs/drawer.md` — token-resolved DOM, 3 state
  (base `open` + `add-language` + `remove-language`, mỗi cái là full tree vì khác nhau nhiều).
- `tool/parity/contracts/drawer.gen.json` — 7 keyed node (key/component/variant). **Đã xác minh: 0 MxCard.** **KHÔNG sửa** (generated).
- `tool/parity/contracts/drawer.slots.skeleton.json` — slot skeleton (chỉ dùng để hiểu; xem "slots" bên dưới).
- `tool/parity/contracts/drawer.states.skeleton.json` — per-state node membership (SUPERSET, phải trim).
- FE: `lib/presentation/shared/navigation/app_drawer.dart`.
- **Test hiện có — KHUÔN seed/pump, sẽ EXTEND (không tạo file mới thay thế):**
  `test/presentation/shared/navigation/app_drawer_test.dart` — đã có `_host(db)` (dựng
  `Scaffold(drawer: AppDrawer())`), `_openDrawer(tester)` (gọi `openDrawer()` + `pumpAndSettle`),
  `_seedPair(db)` (insert `languagePair ko→vi`), và đã drive cả 3 view (menu / add / remove).
- **Reference test cần COPY structure (Template B):** `test/presentation/features/engagement/dashboard_states_test.dart`
  (đọc states.json, tính `universe = ∪ allowed`, per-state assert allowed→`findsOneWidget` /
  ngoài allowed→`findsNothing`).
- Curated mẫu để bắt chước format contract: `tool/parity/contracts/dashboard.states.json`.
- Contrast (KHÔNG áp dụng ở đây, chỉ để hiểu vì sao loại): `test/presentation/features/study/review_parity_test.dart`
  (Template A, MxCard-rich — drawer không có MxCard nên KHÔNG dùng).
- Ledger (đã có sẵn mục drawer — đọc trước khi thêm): `tool/parity/intent-ledger.json`.

**Drift check trước khi code:** drawer là language-pair switcher + secondary nav hub
(`docs/design/screens/23-drawer.md`, `docs/business/navigation/navigation-flow.md`). FE hiện tại:
menu liệt kê pair + `drawerAddLanguage`/`drawerRemoveLanguage`, các mục khác (import/export/stats/
theme/faq/email/sync) là `_comingSoonTile`, `settings` là `_navTile` → route thật. Nếu FE mâu thuẫn
spec ở HÀNH VI (vd doc nói add-language push route riêng nhưng FE đổi `_view` in-place, hay ngược lại)
→ DỪNG, báo. Ở đây FE = in-place `_view` switch, khớp mô tả "add/remove-language flows" → OK, tiếp tục.

---

## CHOSEN template: **B — state-composition** (KHÔNG phải Template A)

**Vì sao B:**
1. `drawer.gen.json` có **0 node `MxCard`**. 7 node của nó là:
   `MxScaffold` (`drawer/add-screen`, `drawer/remove-screen`),
   `MxButton` (`drawer/add-confirm` primary, `drawer/remove-cancel` ghost, `drawer/remove-ok` primary-JSX/render-danger — bg:error),
   `MxIconButton` (`drawer/pair-0-del`, `drawer/pair-1-del`).
   Không có MxCard cố định để gate kiểu review → không dùng Template A.
2. Đây là component-with-modes (menu ↔ add ↔ remove) — đúng khuôn assert **tập keyed node render
   CHÍNH XÁC theo từng state** (thừa = THỪA, thiếu = THIẾU), y hệt `dashboard_states_test.dart`.

> Note component-not-screen: kit model `add-screen`/`remove-screen` là `MxScaffold`, nhưng FE là
> `Drawer` (component dùng chung) đổi `_view` bằng `ListView` có `ValueKey`, KHÔNG bọc MxScaffold.
> Điều này KHÔNG đổi lựa chọn template (vẫn B) — chỉ đổi cách pump (dùng host `Scaffold(drawer:…)`
> + `openDrawer()` như test hiện có, không seed qua router). Ghi divergence "scaffold factored into
> shared Drawer" vào ledger (mục dưới).

---

## Gate-able node list (keyed literal `mx-node:drawer/` trong FE — đã xác minh bằng grep)

Grep `mx-node:drawer/` trong `lib/` cho ra **ĐÚNG 5 literal keyed** (`app_drawer.dart`):

| key | component (gen) | variant (gen) | FE hiện tại | render trong state |
| --- | --- | --- | --- | --- |
| `mx-node:drawer/add-screen` | MxScaffold | null | `ListView` (view=addLanguage) — **KHÔNG bọc MxScaffold** (divergence) | `add-language` |
| `mx-node:drawer/add-confirm` | MxButton | primary | `FilledButton` (Material, không MxButton) | `add-language` |
| `mx-node:drawer/remove-screen` | MxScaffold | null | `ListView` (view=removeLanguage) — **KHÔNG bọc MxScaffold** (divergence) | `remove-language` |
| `mx-node:drawer/remove-cancel` | MxButton | ghost | `TextButton` trong `AlertDialog` (chỉ hiện khi bấm delete 1 pair) | `remove-language` (dialog con) |
| `mx-node:drawer/remove-ok` | MxButton | primary (JSX attr; render = `.btn.danger` → bg:error) | `FilledButton` **destructive** trong `AlertDialog` (bg:error/on-error khớp kit `.btn.danger`, PR #30; chỉ hiện khi bấm delete 1 pair) | `remove-language` (dialog con) |

**Node trong gen.json NHƯNG KHÔNG keyed literal ở FE (identity-rollout gap / divergence):**
- `mx-node:drawer/pair-0-del`, `mx-node:drawer/pair-1-del` — kit là 2 hàng mẫu cố định với nút delete
  theo index. FE render 1 nút delete cho MỖI pair, keyed **động** `Key('removeTile-<id>')`, **không**
  theo index cố định → **đã có mục sẵn trong intent-ledger** (`screen:drawer node:pair- exceptionKind:behavior`,
  source `docs/business/navigation/navigation-flow.md`). Không gate literal `pair-0/1-del`.

**Node kit `open` state (panel menu) hoàn toàn KHÔNG keyed literal `mx-node:` trong FE:**
`drawer/overlay`, `drawer/panel`, `drawer/item-0..9` (Add language / Remove language / Import /
Export / Stats / Theme / Settings / FAQ / Email us / Sync). FE render các mục này bằng `ListTile`
với key riêng KHÔNG-`mx-node:`:
- `Key('drawerAddLanguage')` (= kit `drawer/item-0`), `Key('drawerRemoveLanguage')` (= kit `drawer/item-1`).
- `Key('pairTile-<id>')` (pair rows — động), `Key('swapDirection')` (nút swap trên active pair).
- Các mục còn lại (Import/Export/Stats/Theme/Settings/FAQ/Email/Sync) **KHÔNG có key** — là
  `_comingSoonTile` / `_navTile`.
→ `open` state có **0 node keyed literal `mx-node:drawer/`** ⇒ **KHÔNG gate được qua contract
`mx-node:` universe** (xem state-map: `open` là coverage gap cho gate `mx-node:`, nhưng vẫn được
`app_drawer_test.dart` phủ bằng key `drawerAddLanguage`/`drawerRemoveLanguage`/`pairTile-*`).

---

## Per-state node SET (curate cho `drawer.states.json`)

Từ `drawer.states.skeleton.json` **trim** SUPERSET xuống **CHỈ node keyed literal `mx-node:drawer/`
mà FE THỰC render**, bỏ:
- chrome kit-only không có ở FE: `drawer/overlay`, `drawer/panel` (open không dựng qua các node này),
  `drawer/add-appbar`/`drawer/add-back`/`drawer/remove-appbar`/`drawer/remove-back` (FE dùng
  `_viewHeader` với `Key('addBack')`/`Key('removeBack')` — không `mx-node:` literal),
  `drawer/remove-scrim`/`drawer/remove-dialog` (kit inline dialog; FE là `AlertDialog` Material),
  `drawer/learn-lang`/`drawer/native-lang` (kit card; FE là `DropdownButton` với
  `Key('addLanguageSource')`/`Key('addLanguageTarget')` — không `mx-node:` literal).
- `drawer/item-0..9` (kit menu items) — FE không key literal.
- `drawer/pair-0`/`drawer/pair-1`/`drawer/pair-0-del`/`drawer/pair-1-del` — FE dùng key động (ledger).

Tập gate đề xuất cho `drawer.states.json` (chỉ node keyed literal FE):

```jsonc
{
  "$curated": "State-composition parity for the shared AppDrawer (component, not a route). Only literal mx-node:drawer/ keys the FE renders are listed; kit chrome (overlay/panel/appbars/scrim/dialog/cards/menu items) and dynamic-keyed nodes (pair rows via removeTile-<id>, menu items via drawerAddLanguage/…) are excluded — see intent-ledger.json (drawer). 'open' is a coverage gap for this mx-node universe (0 literal mx-node: keys; covered instead by app_drawer_test key assertions). remove-cancel/remove-ok live in a Material AlertDialog reached by tapping a pair's delete — drive them only if the test taps delete; otherwise keep remove-language to the screen container.",
  "screen": "drawer",
  "states": {
    "open": [],
    "add-language": ["mx-node:drawer/add-screen", "mx-node:drawer/add-confirm"],
    "remove-language": ["mx-node:drawer/remove-screen"]
  }
}
```

> QUYẾT ĐỊNH về `remove-cancel`/`remove-ok`: chúng KHÔNG ở body `remove-language` mà nằm trong
> `AlertDialog` chỉ hiện khi tap nút delete của 1 pair. **Hai lựa chọn — chọn (A) mặc định:**
> - **(A) Giữ `remove-language` = chỉ `remove-screen`** (dialog buttons = coverage gap ở tầng
>   state-set; documented). Đơn giản, không phụ thuộc pump dialog. → khuyến nghị.
> - **(B) Thêm `remove-cancel`/`remove-ok` vào `remove-language`** VÀ trong test, sau khi vào
>   remove view thì `tester.tap(find.byIcon(Icons.delete_outline))` để mở dialog rồi mới assert.
>   Chỉ chọn nếu muốn gate 2 nút dialog; cần seed ≥1 pair (đã có `_seedPair`).
> Nếu chọn (A), note rõ trong `$curated` + report là dialog buttons chưa gate ở state-set.

> `open: []`: universe không có node nào của `open` ⇒ test sẽ chỉ assert "mọi key trong universe
> đều absent khi ở menu view". Điều này VẪN có giá trị: bắt lỗi THỪA (vd `add-screen`/`remove-screen`
> rò rỉ vào menu). Nếu muốn `open` có node dương để assert present, cần rollout literal key cho menu
> (đụng widget — xem identity-rollout note); mặc định KHÔNG làm trong task này.

**`drawer.slots.json`: BỎ QUA (không tạo).** Các keyed node ở đây là control (button / scaffold
container), không mang keyed text slot cần bind role/l10n. Menu-item label, pair label, dialog copy…
đều nằm ở node KHÔNG-`mx-node:` (dynamic/coming-soon tiles) hoặc trong `AlertDialog` — không thuộc
universe `mx-node:` này. → ghi rõ lý do bỏ qua trong report; KHÔNG tạo file rỗng.

---

## State-map: state nào drive được / state nào là coverage gap

FE là **cùng 1 `AppDrawer`** đổi `_view`; cả 3 state reach trong 1 host bằng tap (không router).
Pump pattern: **tái sử dụng `app_drawer_test.dart`** — `_host(db)` + `_openDrawer(tester)` +
`_seedPair(db)`, rồi `tester.tap(find.byKey(const Key('drawerAddLanguage')))` /
`Key('drawerRemoveLanguage')` + `pumpAndSettle`.

| kit state | drivable? | cách drive (dựa trên `app_drawer_test.dart`) | node-set FE (mx-node universe) |
| --- | --- | --- | --- |
| `open` (menu) | ⚠️ | `_openDrawer` → view=menu | **0 literal `mx-node:`** → coverage gap cho gate mx-node (phủ bằng `drawerAddLanguage`/`drawerRemoveLanguage`/`pairTile-*` ở test hiện có). Universe assert: mọi mx-node absent. |
| `add-language` | ✅ | tap `drawerAddLanguage` → view=addLanguage | `add-screen`, `add-confirm` |
| `remove-language` | ✅ | seed ≥1 pair (`_seedPair`) → tap `drawerRemoveLanguage` → view=removeLanguage | `remove-screen` (+ `remove-cancel`/`remove-ok` chỉ nếu chọn (B) và tap delete) |

→ **Gate 2 state có node dương:** `add-language`, `remove-language`. **`open` là coverage gap ở
tầng `mx-node:` universe** (0 literal key), nhưng KHÔNG phải lỗ hổng test tổng thể vì
`app_drawer_test.dart` đã assert `drawerAddLanguage`/`drawerRemoveLanguage`/`pairTile-*` present ở
menu. Ghi rõ lý do gap ngay trong header test (giống review_parity_test giải thích state không map).

> `remove-language` cần seed pair để hiện `drawerRemoveLanguage` (FE ẩn mục này khi `pairs.isEmpty`,
> xem `app_drawer.dart:114`). Dùng `_seedPair`. Nếu bỏ seed thì mục remove KHÔNG hiện → không reach
> được view → đó là hành vi đúng (empty), không phải gap.

---

## Divergences → `tool/parity/intent-ledger.json` (đã có sẵn — KIỂM TRA trước khi thêm)

Ledger **đã có** các mục drawer sau (KHÔNG thêm trùng):
- `exceptions[]`: `screen:drawer node:pair- kind:* behavior` — "FE keys delete per-pair dynamically
  (removeTile-<id>), not fixed pair-0/pair-1", source `docs/business/navigation/navigation-flow.md`.
- `styleExempt[]`: `drawer/add-confirm field:r` (Material FilledButton stadium radius vs kit r:12),
  `drawer/add-confirm field:font` (labelLarge 15px vs kit 20px). Source
  `docs/business/navigation/navigation-flow.md`.

**Cần THÊM (nếu chưa có) — append, giữ format hiện có, mỗi mục kèm `source`:**
1. `exceptions[]` — `screen:drawer node:add-screen` / `node:remove-screen`, `exceptionKind:behavior`:
   kit model add/remove là `MxScaffold` (drawer/add-screen, drawer/remove-screen); FE factor scaffold
   vào shared `AppDrawer` (`Drawer` + `_view` ListView), nên node mang `ValueKey` trên `ListView`
   container, KHÔNG bọc MxScaffold. Source: `lib/presentation/shared/navigation/app_drawer.dart`.
   (Tương tự mẫu dashboard `screen` exception — scaffold factored into shared shell.)
2. `exceptions[]` — `screen:drawer node:overlay`/`node:panel` (hoặc `node:item-`), `behavior`:
   kit `open` state dựng overlay + panel + menu items (item-0..9) với identity riêng; FE render menu
   bằng `ListTile` dùng key domain (`drawerAddLanguage`, `pairTile-<id>`) hoặc coming-soon tiles
   không key, không theo node-identity kit → `open` không có literal `mx-node:` để gate.
   Source: `docs/business/navigation/navigation-flow.md`.
3. (nếu chọn (A) cho dialog) `exceptions[]` — `screen:drawer node:remove-cancel`/`node:remove-ok`,
   hoặc gộp `node:remove-dialog`, `behavior`: kit inline dialog trong body remove; FE dùng Material
   `AlertDialog` mở khi tap delete 1 pair, nên 2 nút không ở body state-set (gate qua tap, hoặc để
   coverage gap). Source: `docs/business/navigation/navigation-flow.md`.

Style/component divergence bổ sung (nếu spec_diff bắt) → `styleExempt[]`:
- `drawer/remove-cancel` / `drawer/remove-ok`: kit `MxButton` ghost/primary; FE là `TextButton` /
  `FilledButton` Material (default). Nếu spec_diff báo bg/r/font khác → thêm mục `field:*` với reason
  "FE remove dialog uses Material AlertDialog TextButton/FilledButton, not MxButton", source
  `docs/business/navigation/navigation-flow.md`. **Chỉ thêm khi spec_diff thực sự fail** — đừng thêm
  preemptive.

Nếu bất kỳ mục nào thực chất là **BUG** (không phải chủ ý) → **DỪNG**, báo mẫu DRIFT, chờ người.
Không tự sửa UI trong prompt này.

---

## Identity-rollout note (menu items, pair rows, headers, dropdowns, dialog)

FE cố tình dùng key **domain** thay vì literal `mx-node:` cho:
- menu items (`drawerAddLanguage`, `drawerRemoveLanguage`, coming-soon tiles không key),
- pair rows (`pairTile-<id>` động), remove rows (`removeTile-<id>` động),
- view header back buttons (`addBack`/`removeBack`), language dropdowns
  (`addLanguageSource`/`addLanguageTarget`).

Vì phần lớn là danh sách động / key domain có sẵn test coverage (`app_drawer_test.dart`), **mặc định
CHẤP NHẬN gap** — KHÔNG rollout literal `mx-node:` mới cho chúng trong task style-parity này. Nếu muốn
`open` có node dương gate được, đó là thay đổi rollout key (đụng widget dùng chung `AppDrawer`) →
cân nhắc rủi ro, cập nhật doc, ghi WBS; **không làm trừ khi bạn cũng thêm hành vi thật**.

---

## Workflow (thực thi tuần tự, mỗi bước một layer)

1. **Curate `tool/parity/contracts/drawer.states.json`** từ skeleton theo bảng mục "Per-state node
   SET": 3 state `open` (rỗng) / `add-language` / `remove-language`, chỉ node keyed literal FE,
   thêm `$curated` header (bắt chước `dashboard.states.json`) giải thích: drawer là component không
   phải route; open=coverage gap; dialog buttons lựa chọn (A)/(B); dynamic + coming-soon tiles loại
   khỏi universe.
2. **`drawer.slots.json`: BỎ QUA** — ghi lý do trong report (không có keyed text slot; label/copy ở
   node không-`mx-node:`). Không tạo file rỗng.
3. **Align FE** `app_drawer.dart` — chỉ xác nhận 5 key literal hiện có đúng chính tả (grep đã confirm):
   `add-screen`, `add-confirm`, `remove-screen`, `remove-cancel`, `remove-ok`. KHÔNG thêm node/key mới
   cho menu/pair/header/dropdown (giữ gap). KHÔNG hardcode màu/spacing/text-style/route/string. Nếu
   phát hiện hardcode token vi phạm khi đọc → sửa tối thiểu về token (nhưng đừng đổi layout).
   > Divergence (add-screen/remove-screen không bọc MxScaffold; dialog = AlertDialog Material) GIỮ
   > NGUYÊN → đã/đưa vào intent-ledger. Đây là task style-parity, không phải feature/refactor.
4. **l10n**: các chuỗi drawer (`drawerAddLanguage`, `drawerRemoveLanguage`, `drawerLanguagesTitle`,
   `drawerLanguagesEmpty`, `drawerImport`/`drawerExport`/`drawerStatistics`/`drawerTheme`/
   `drawerSettings`/`drawerFaq`/`drawerSendEmail`/`drawerSync`, `drawerActivityTitle`,
   `activityMinutes`/`activityWords`, `addLanguageTitle`/`addLanguageLearning`/`addLanguageNative`/
   `addLanguageSubmit`/`addLanguageErrorEmpty`/`addLanguageErrorSame`, `removeLanguageTitle`/
   `removeLanguageEmpty`/`removeLanguageConfirmTitle`/`removeLanguageConfirmBody`, `commonCancel`/
   `commonDelete`/`commonBack`/`comingSoon`/`swapDirectionTooltip`) **đã có ở CẢ `app_en.arb` +
   `app_vi.arb`** (đã verify). Task này KHÔNG cần thêm key mới. Nếu bạn thêm/đổi bất kỳ chuỗi
   user-facing nào → thêm vào **cả hai** ARB cùng lúc rồi regen l10n; KHÔNG copy mock copy từ kit
   ("TODAY'S ACTIVITY", "12:45", "24 words", "한국어 → English", "1240 cards"…) vào app/test.
5. **Test — EXTEND `test/presentation/shared/navigation/app_drawer_test.dart`** (KHÔNG tạo file
   parity riêng — tái dùng host/helper sẵn có; đây là chỗ khác biệt so với player/library dùng file
   `*_states_test.dart` mới):
   - Thêm phần đọc `drawer.states.json` + tính `universe` + vòng per-state y **structure**
     `dashboard_states_test.dart` (allowed→`findsOneWidget`, ngoài allowed→`findsNothing`).
   - Drive state bằng helper hiện có: `_host(db)` + `_openDrawer` + `_seedPair`, rồi tap
     `Key('drawerAddLanguage')` / `Key('drawerRemoveLanguage')` để vào từng view; `open` = ngay sau
     `_openDrawer` (không tap).
   - Nếu chọn (B) cho dialog: sau khi vào remove view, tap `find.byIcon(Icons.delete_outline)` để mở
     `AlertDialog` rồi assert `remove-cancel`/`remove-ok`.
   - Header comment: giải thích drawer là shared component (không route); `open` là coverage gap cho
     `mx-node:` universe (0 literal key) nhưng đã được phủ bởi các test `Key('drawer…')`/`pairTile-*`
     có sẵn trong CHÍNH file này; pair/menu dùng key động (ledger).
   - GIỮ 3 test hiện có trong file (menu lists / add view / remove view) — chỉ THÊM block state-composition.
6. **Xóa skeleton** đã tiêu thụ: `tool/parity/contracts/drawer.slots.skeleton.json` và
   `drawer.states.skeleton.json` (skeleton là AUTO-PROPOSED, không ship — theo ghi chú `$skeleton`).
   (Slots skeleton bị xóa dù ta không tạo `drawer.slots.json` — skeleton không được để lại; ghi rõ
   trong report là "slots.json cố tình bỏ qua, slots.skeleton đã xóa".)
7. **Cập nhật queue**: đổi `[ ] 20-drawer.md` → `[x]` trong `docs/agent/kit-to-flutter/README.md`
   (queue dùng tên `20-drawer.md`; file prompt này là `drawer.md` — giữ nhất quán, đánh dấu đúng dòng
   drawer).
8. **Doc parity** (`CLAUDE.md` §Pre-commit parity): task thuần style-parity/contract + test ⇒ nhiều
   khả năng không đổi business doc; nếu có divergence chạm behavior đã ghi ở `docs/business/**` /
   `docs/design/screens/23-drawer.md` thì cập nhật cùng commit (thường chỉ cần intent-ledger). Xác
   nhận rồi ghi rõ trong report.

---

## Hard rules (vi phạm = task fail — trích `CLAUDE.md`)

- KHÔNG vẽ lại / di chuyển UI trong prompt này; chỉ curate contract + extend test. Divergence → ledger,
  không tự sửa FE về kit (add-screen/remove-screen scaffold, dialog Material, add-confirm radius/font).
- **Token-only**: KHÔNG hardcode route/màu/radius/spacing/text-style/duration/string; string từ ARB
  (`lib/l10n/`).
- KHÔNG copy MOCK COPY từ kit spec vào app/test làm assert văn bản.
- KHÔNG ship skeleton làm curated; phải trim `drawer.states.json` rồi XÓA cả 2 skeleton.
- KHÔNG bịa state/dialog assert nếu không drive được sạch → hạ xuống coverage gap và báo (đừng viết
  test giả để có `open` node dương).
- KHÔNG sửa generated (`*.g.dart`, `*.freezed.dart`, `drawer.gen.json`, `lib/l10n/generated/**`,
  `docs/_generated/**`).
- KHÔNG thêm dependency mới (Stop & ask nếu cần).
- KHÔNG đánh dấu done nếu `node tool/verify/run.mjs --full` chưa xanh.
- Nếu rollout literal key cho menu/pair (option đụng `AppDrawer` dùng chung) → cân nhắc rủi ro, cập
  nhật doc, không phá test màn khác; mặc định KHÔNG làm.

---

## Verification

```bash
node tool/verify/run.mjs --full
```

Phải XANH (ghi pass-marker mà pre-commit hook yêu cầu; gồm test extend + freshness check của specs +
spec_diff/parity). Nếu đỏ → sửa, không commit vòng qua. Trong lúc dev có thể `--quick` (không marker).
Chạy riêng test để chắc:
`flutter test test/presentation/shared/navigation/app_drawer_test.dart`.

Sau khi verify PASS, TRƯỚC final report: fan-out song song `code-reviewer` (review working-tree diff —
cho nó chạy `git add -N .` rồi `git diff`, KHÔNG commit trước) + `docs-drift-detector`. Gộp kết quả
vào mục "Subagent review". Sửa blocker trước khi xong; liệt kê minor cho user.

---

## Commit (2 commit + WBS)

**Commit 1** — contract + test:
```
test(parity): drawer state-composition gate (add/remove-language) + curated states.json

- curate tool/parity/contracts/drawer.states.json (add-language + remove-language gated; 'open' coverage gap — 0 literal mx-node: keys)
- extend test/presentation/shared/navigation/app_drawer_test.dart with the state-composition gate (Template B, structure from dashboard_states_test)
- remove consumed skeletons (drawer.states.skeleton.json, drawer.slots.skeleton.json)
- drawer.slots.json intentionally skipped (no keyed text slot; menu/pair use domain/dynamic keys)

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>
```

**Commit 2** — docs/ledger + queue:
```
docs(parity): drawer divergences → intent-ledger; mark drawer done in kit-to-flutter queue

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>
```

**WBS** (bắt buộc, `CLAUDE.md` §WBS + §Commit traceability): append 1 dòng vào Commit Traceability Log
(§10 của `docs/project-management/wbs.md`), newest first:
`<8-char hash> · <YYYY-MM-DD> · <WBS IDs> · drawer kit→flutter state-composition parity (add/remove gated; open coverage gap; pair/scaffold/dialog → intent-ledger)`.
Nếu task breakdown WBS không đổi, report ghi `WBS update: not needed — <reason>` (nhưng Commit
Traceability Log vẫn append nếu advance WP).

---

## Final report (đưa vào tin nhắn cuối)

```
## drawer — kit→flutter DONE
- Component note: drawer is the SHARED AppDrawer (Scaffold.drawer), NOT a route/MxScaffold — pumped via Scaffold(drawer:AppDrawer())+openDrawer(), 3 views on one widget (_view switch)
- Template: B (state-composition) — reason: 0 MxCard in drawer.gen.json
- Gate-able keyed nodes (literal mx-node: in FE): add-screen, add-confirm, remove-screen, remove-cancel, remove-ok  [5]
- Gated states: add-language (add-screen+add-confirm), remove-language (remove-screen[+ dialog buttons if option B])
- Coverage gap: open (menu) — 0 literal mx-node: keys; covered by existing Key('drawerAddLanguage'/'drawerRemoveLanguage'/'pairTile-*') assertions in app_drawer_test [1 state]
- Contracts: drawer.states.json curated; drawer.slots.json intentionally skipped (no keyed text slot); 2 skeletons deleted
- Divergences → intent-ledger: pair-* dynamic key (pre-existing), add-confirm radius+font styleExempt (pre-existing), add-screen/remove-screen scaffold-in-shared-Drawer (added), open menu identity (added), remove dialog = Material AlertDialog (added / option A gap)
- Test: extended app_drawer_test.dart (kept 3 existing tests + added state-composition block)
- l10n: all drawer/add/remove keys already in app_en.arb + app_vi.arb [no new keys]
- Docs updated: <list | none — style-parity only, intent-ledger only>
- WBS: <line appended | not needed — reason>
- Verify: node tool/verify/run.mjs --full → PASS
- Subagent review: <blockers fixed | minor findings ...>
```
```
