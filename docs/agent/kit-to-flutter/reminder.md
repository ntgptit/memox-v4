# Kit → Flutter conversion prompt — **reminder**

> SELF-CONTAINED. Đọc hết file này rồi thực thi tuần tự. Không cần đọc prompt nào khác.
> Nhiệm vụ: đóng **state-composition parity gate** cho màn `reminder` (KHÔNG vẽ lại UI —
> UI đã có sẵn; việc ở đây là **curate contract + viết 1 test composition** theo Template B).
> Nếu gặp DRIFT hoặc DIVERGENCE cần người quyết → DỪNG, báo theo mẫu `DRIFT DETECTED` trong
> `CLAUDE.md`, chờ.

---

## PROMPT ID

`kit-to-flutter/reminder` · screen `reminder` · feature `settings` · 3 kit state (`on` / `off` / `time-picker`).
FE: `lib/presentation/features/settings/screens/reminder_screen.dart`.

---

## Baseline

```bash
git checkout main
git pull --ff-only
git checkout -b claude/kit-to-flutter-reminder
```

Không bắt đầu khi working tree bẩn. Xác nhận `node tool/verify/run.mjs --quick` xanh trước khi sửa.

---

## Required reading (đọc trước khi code)

Universal (theo `CLAUDE.md`): `docs/_generated/repo-map.md`, `docs/_generated/where-is.md`,
`docs/business/index.md`, `docs/business/glossary.md`, `docs/contracts/error-contract.md`,
`docs/contracts/types-catalog.md`, `docs/contracts/code-style.md`.

Screen-specific — CHỈ đọc đúng các file này:
- `docs/design/MemoX Design System/ui_kits/memox-app/specs/reminder.md` — token-resolved DOM, base `on` + 2 diff (`off`, `time picker`).
- `tool/parity/contracts/reminder.gen.json` — **5 keyed node** (key/component/variant). **KHÔNG sửa** (generated). Đã xác minh: chỉ **1 MxCard** (`reminder/time`, variant `elevated`).
- `tool/parity/contracts/reminder.slots.skeleton.json` — slot skeleton (SUPERSET) → chỉ dùng để curate; xem mục slots.
- `tool/parity/contracts/reminder.states.skeleton.json` — per-state node membership (SUPERSET, gồm chrome + node chưa keyed) → phải trim.
- FE: `lib/presentation/features/settings/screens/reminder_screen.dart` (`ConsumerWidget`, watch `settingsProvider`).
- `lib/presentation/features/settings/viewmodels/settings_notifier.dart` + `lib/domain/types/reminder.dart` — driver state (enabled / hour / minute / weekdays).
- **Reference test cần COPY (Template B):** `test/presentation/features/engagement/dashboard_states_test.dart`.
- Curated mẫu để bắt chước format: `tool/parity/contracts/dashboard.states.json`, `tool/parity/contracts/dashboard.slots.json`.
- Contrast (KHÔNG áp dụng ở đây, chỉ để hiểu vì sao loại): `test/presentation/features/study/review_parity_test.dart` (Template A, MxCard-per-state identity).
- Ledger đích: `tool/parity/intent-ledger.json` (mảng `exceptions`, keyed theo `screen`+`node`).

**Drift check trước khi code:** reminder là màn settings W12 (enable + time + weekday → schedule OS notification). Spec = card toggle + card time + chip weekday; FE khớp về hành vi (toggle bật/tắt, time picker, chip weekday). Chỗ lệch DUY NHẤT là **render shape** của node `reminder/time` (mục 5) — đó là DIVERGENCE có chủ ý (ledger), KHÔNG phải bug. Nếu bạn phát hiện lệch **hành vi** (vd time picker đổi lịch SRS, hoặc weekday sai domain) → DỪNG, báo `DRIFT DETECTED`, chờ.

---

## CHOSEN template: **B — state-composition** (KHÔNG phải Template A)

**Vì sao B (dứt khoát):** `reminder.gen.json` liệt kê 1 node MxCard là `mx-node:reminder/time`
(variant `elevated`). NHƯNG trong FE, `reminder/time` **KHÔNG** phải `MxCard` — nó là một
`Container` thường (`reminder_screen.dart:66`, decoration `BoxDecoration` + `MxRadius.cardRadius`,
child `MxText`). Template A vòng `tester.widget<MxCard>(finder)` để đọc `.variant` ⇒ **sẽ CRASH**
(cast `Container` → `MxCard` fail) ngay khi chạm node này. Vì node MxCard duy nhất trong gen.json
lại không phải MxCard thật ở FE, **không có node MxCard keyed nào để Template A vòng qua** ⇒ Template A
vô nghĩa và không an toàn ở màn này.

→ Đúng khuôn là **assert tập keyed node render CHÍNH XÁC theo từng state** (thừa = THỪA,
thiếu = THIẾU) — y hệt `dashboard_states_test.dart` (Template B, không cast MxCard, chỉ
`find.byKey(ValueKey(...))` → `findsOneWidget` / `findsNothing`).

> Divergence `reminder/time` = Container-not-MxCard được ghi vào intent-ledger (mục 5), KHÔNG ép FE
> về MxCard trong task này.

---

## Gate-able node list (keyed trong FE — đã xác minh bằng grep)

Grep `mx-node:reminder/` trong `lib/` cho ra ĐÚNG 4 literal keyed sau (FE hiện tại):

| key | gen.json component/variant | FE thực tế (citation) | vai trò |
| --- | --- | --- | --- |
| `mx-node:reminder/screen` | MxScaffold / null | ✓ `MxScaffold` (`reminder_screen.dart:28`) | chrome (mọi state) |
| `mx-node:reminder/appbar` | MxAppBar / null | ✓ `MxAppBar` (`reminder_screen.dart:30`) | chrome (mọi state) |
| `mx-node:reminder/time-edit` | MxIconButton / null | ⚠ `ListTile` (`reminder_screen.dart:63`) — divergence (mục 5) | body — chỉ enabled khi `on` |
| `mx-node:reminder/time` | MxCard / elevated | ⚠ `Container` (`reminder_screen.dart:67`) — divergence (mục 5) | body |

**Node trong gen.json / spec NHƯNG chưa keyed ở FE (identity-rollout gap — ghi nhận, KHÔNG ép):**
- `reminder/picker-done` (gen.json, MxButton primary) — nút "Done" của bottom-sheet picker; FE dùng
  `showTimePicker` (Material dialog, `reminder_screen.dart:143`) → **không có** node keyed này.
- `reminder/toggle` + `reminder/toggle-switch` (spec) — công tắc bật/tắt; FE render `ListTile` +
  `MxSwitch(key: Key('reminderEnable'))` (`reminder_screen.dart:53-61`), **không** keyed `mx-node:reminder/toggle*`.
- `reminder/days` + `reminder/day-0..6` (spec) — cụm chip weekday; FE render `Wrap` + `MxChip`
  **không keyed** literal (`reminder_screen.dart:87-110`), sinh động qua vòng `for day in 1..7`.
- `reminder/back` (spec) — nút back trong appbar; do `MxAppBar` sở hữu, không keyed riêng.
- `reminder/picker-scrim` / `reminder/picker-sheet` — overlay bottom-sheet của kit; FE dùng
  `showTimePicker` overlay-of-framework → không keyed.

→ Liệt kê nguyên các gap này trong **final report** (mục "Identity-rollout gap"). **KHÔNG** rollout key
mới cho toggle/day/picker trong task này (đây là task style/composition-parity, không phải feature/identity rollout).

---

## Divergences → `tool/parity/intent-ledger.json` (KHÔNG ép FE về kit)

Ledger dùng mảng `exceptions`, mỗi mục khớp theo `screen == "reminder"` AND node prefix. Append (giữ
format hiện có: `screen`, `node`, `kind:"*"`, `verdict:"exception"`, `exceptionKind`, `reason`, `source`).
Đây là chệch **có chủ ý** — không sửa FE cho khớp kit ở các điểm này:

1. **`reminder/time` = Container, không phải MxCard.** Kit model card time là `MxCard` (elevated); FE render
   `Container` + `BoxDecoration(color: surface, borderRadius: MxRadius.cardRadius)` bọc `MxText`
   (`reminder_screen.dart:66-81`). Lý do: FE đặt time-value làm `trailing` của một `ListTile` (hàng
   settings), không phải card độc lập full-width như kit. `exceptionKind:"structure"`,
   `reason:"fe renders reminder/time as a ListTile trailing Container (settings-row layout), not a standalone MxCard"`,
   `source:` doc settings/reminder tương ứng (vd `docs/business/**` reminder spec — trỏ đúng doc đang mô tả màn này).
2. **`reminder/time-edit` = ListTile, không phải MxIconButton.** Kit là `MxIconButton` (icon schedule); FE là
   `ListTile` (title + trailing time Container, `onTap` mở `showTimePicker`, `reminder_screen.dart:62-85`). Lý do:
   cả hàng là target chỉnh giờ, không tách riêng icon-button. `exceptionKind:"structure"`,
   `reason:"fe uses a full ListTile row (tap-to-edit) instead of a standalone MxIconButton for reminder/time-edit"`.
3. **Time value = `MxTextRole.labelLarge`, không phải `displayLarge`.** Kit mock "13:00" là `font:38/800`
   (skeleton đề xuất `displayLarge`); FE render `MxText(reminder.timeText, role: MxTextRole.labelLarge, color: textTertiary)`
   (`reminder_screen.dart:76-80`). Đây là **slot binding thật của FE** (giống review sửa meaning → bodySmall):
   curate `reminder.slots.json` theo FE truth (`labelLarge`), ghi 1 dòng note trong `$curated`, **KHÔNG** cần
   entry ledger (đây là role, không phải component/behavior divergence).

Nếu bất kỳ mục nào thực chất là **BUG** (không phải chủ ý) → DỪNG, báo `DRIFT DETECTED`, chờ. Không tự sửa UI.

Sau khi ghi ledger, các divergence này KHÔNG được làm fail parity test (test B chỉ assert present/absent
theo key `find.byKey`, KHÔNG cast MxCard/MxIconButton nên Container/ListTile vẫn pass).

---

## State-map: state nào drive được / state nào là coverage gap

FE là `ConsumerWidget` watch `settingsProvider` → `settings.when(...)` → `_body(...)` đọc `Reminder`
(`enabled` / `hour` / `minute` / `weekdays`). Pump pattern: **giống `dashboard_states_test.dart`** —
seed Drift in-memory + override `databaseProvider` (+ `clockProvider` nếu cần) → `pumpWidget(host)` →
`pumpAndSettle`. `on`/`off` được drive bằng cách seed `settings` row (`reminder_enabled` hoặc key tương
đương mà `settingsProvider` đọc) hoặc bằng `SettingsCompanion` giống dashboard seed. Đọc `settings_notifier.dart`
để biết đúng storage key / cách seed `Reminder(enabled: ...)` trước khi viết `recipes`.

| kit state | driver | drive được trong FE? | cách drive | node-set body (khác biệt) |
| --- | --- | --- | --- | --- |
| `on` | `reminder.enabled == true` | ✅ | seed settings để `reminder.enabled = true` | `reminder/time` + `reminder/time-edit` (enabled) + hint block |
| `off` | `reminder.enabled == false` | ✅ | seed settings để `reminder.enabled = false` (hoặc DB rỗng = default) | `reminder/time` + `reminder/time-edit` (disabled) — **cùng tập keyed node** |
| `time-picker` | overlay `showTimePicker` | ❌ coverage gap | Kit là bottom-sheet keyed (`picker-scrim`/`picker-sheet`/`picker-done`); FE dùng `showTimePicker` (Material dialog framework-owned), **không** render node keyed nào → không có node-set phân biệt để gate | — (không keyed) |

**Kết luận state phân biệt được:** `on` và `off` **render CÙNG tập keyed literal** (`reminder/time`,
`reminder/time-edit` — hai node này có mặt ở cả hai; sự khác biệt `on`↔`off` chỉ là `enabled` flag +
opacity + hint block, KHÔNG đổi tập keyed node). Vì `screen`/`appbar` là chrome (loại khỏi gate, giống
dashboard), **không có node body nào phân biệt `on` vs `off`** ở tầng keyed identity.

→ **Đây chính là coverage gap mà contract này phải phơi ra minh bạch**, KHÔNG che giấu:
- `time-picker` = **coverage gap** (overlay framework-owned, không keyed) — documented-not-driven.
- `on` vs `off` **không phân biệt được ở tầng keyed node-set** — cả hai giữ cùng tập; test gate chỉ khẳng
  định `reminder/time` + `reminder/time-edit` **present** ở cả `on` và `off` (chrome absent-check không áp).

> QUAN TRỌNG (bài học `style-parity-blind-spots`): ĐỪNG over-claim là đã "gate" phân biệt `on/off`.
> Ở tầng identity/composition FE hiện tại **không** phân biệt được (khác biệt nằm ở `enabled`/opacity, không
> ở node-set). Ghi rõ trong `$curated` + header test + report. Nếu muốn gate thật sự phân biệt `on/off`,
> phải rollout key cho toggle-switch + hint hoặc assert `enabled` prop — **ngoài scope** task này; note là
> future work.

---

## Per-state node SET (curate cho `reminder.states.json`)

Từ `reminder.states.skeleton.json`, **trim** SUPERSET (bỏ chrome `screen`/`appbar` không do body điều khiển —
theo mẫu dashboard; bỏ mọi node chưa keyed ở FE: `toggle*`, `day-*`, `days`, `back`, `picker-*`) xuống tập
BODY keyed literal mà FE THỰC render. Tập gate đề xuất:

```jsonc
{
  "$curated": "Per-state BODY keyed-node set for reminder — CHỈ node có ValueKey literal trong reminder_screen.dart (chrome screen/appbar loại khỏi gate như dashboard; toggle/day/picker chưa keyed → identity-rollout gap, xem intent-ledger + reminder.md). FE `on` và `off` render CÙNG tập keyed node (reminder/time + reminder/time-edit); khác biệt on↔off chỉ là `enabled`/opacity/hint, KHÔNG đổi node-set ⇒ không phân biệt được ở tầng composition (documented). `time-picker` là overlay showTimePicker (Material dialog framework-owned, không keyed) ⇒ coverage gap, không drive. Cross-checked bởi reminder_states_test.dart.",
  "screen": "reminder",
  "states": {
    "on":  ["mx-node:reminder/time", "mx-node:reminder/time-edit"],
    "off": ["mx-node:reminder/time", "mx-node:reminder/time-edit"]
  }
}
```

- `time-picker` **KHÔNG** đưa vào states (không có keyed node) — ghi coverage gap trong `$curated` + report.
- Vì `on`/`off` cùng tập, `universe` = hợp = 2 node; assert cả hai present ở cả hai state. Gate này bắt được
  regression **THIẾU** (một node biến mất) hoặc **THỪA** (node lạ xuất hiện) so với bộ keyed literal — đó là
  giá trị của layer này ở màn cùng-node-set (giống dashboard bắt goal/streak leak vào empty).

**`reminder.slots.json`** (giữ hay bỏ — quyết định + ghi rõ report):
- Node keyed literal ở FE chỉ có `reminder/time` (Container mang 1 `MxText`) và `reminder/time-edit`
  (ListTile). `reminder/time` có **1 text slot** = time value → curate 1 dòng:
  `{ "name": "timeValue", "role": "labelLarge", "bind": "reminder.timeText" }` (labelLarge = FE truth, KHÔNG
  phải kit mock displayLarge; bind = domain value, KHÔNG l10n).
- Skeleton còn đề xuất slot cho `toggle`/`days`/`day-*`/`appbar` — **BỎ** (những node đó chưa keyed ở FE, không
  gate được; text của chúng lấy từ ARB qua `MxText`/`ListTile` title nhưng không có keyed node để bind slot).
- Nếu muốn tối giản như `review.slots.json` (chỉ giữ slot có node keyed) → giữ đúng 1 slot `reminder/time`.
  Thêm `$curated` note: labelLarge = FE truth, scope = màn settings reminder, các slot khác bỏ vì node chưa keyed.

> Test B (dashboard-style) **không** assert slot role (nó chỉ assert present/absent). Slots.json ở đây là
> tài liệu FE-truth (như dashboard.slots.json tồn tại song song test states). Nếu muốn cũng assert role của
> `reminder/time`.timeValue, có thể thêm 1 vòng phụ `find.descendant(... MxText role labelLarge ...)` giống
> nhánh SLOTS trong `review_parity_test.dart` (optional). Mặc định: giữ test bám sát dashboard (composition-only)
> + slots.json làm tài liệu.

---

## Workflow (thực thi tuần tự, mỗi bước một layer)

1. **Curate `tool/parity/contracts/reminder.states.json`** từ skeleton theo block JSONC mục trên: chỉ 2 state
   `on`/`off`, chỉ 2 node keyed literal `reminder/time` + `reminder/time-edit`, bỏ chrome + node chưa keyed.
   `$curated` note nêu rõ: on/off cùng node-set (không phân biệt ở composition), time-picker = coverage gap.
2. **Curate `tool/parity/contracts/reminder.slots.json`** (giữ 1 slot `reminder/time`.timeValue = `labelLarge` /
   bind `reminder.timeText`; bỏ slot node chưa keyed). `$curated` note: labelLarge = FE truth không phải kit mock.
   Nếu quyết định BỎ hẳn slots.json (theo mẫu library) → ghi lý do rõ trong report; đừng ship file rỗng.
3. **Align FE** `reminder_screen.dart` — xác nhận identity ValueKey đúng chính tả (grep đã confirm 4 key). KHÔNG
   thêm node mới cho toggle/day/picker. Divergence (time=Container, time-edit=ListTile) giữ nguyên → đã vào ledger.
   KHÔNG hardcode màu/spacing/text-style/duration/string; đã dùng token (`MxSpacing`, `MxRadius`, `MxTheme` colors,
   `MxText role`). Xác nhận không có magic value mới.
4. **l10n**: các key FE dùng (`settingsGroupReminder`, `reminderEnable`, `reminderTimeLabel`, `reminderActiveHint`,
   `reminderNotificationTitle`, `reminderNotificationBody`, `weekdayMon..Sun`) đã có **cả** `app_en.arb` và
   `app_vi.arb` (đã verify). Nếu thêm/đổi bất kỳ chuỗi user-facing nào → thêm vào **cả hai** ARB cùng lúc rồi regen.
   KHÔNG copy mock copy từ kit ("Study reminders", "REMINDER TIME", "13:00", "Pick reminder time", "Done"…) vào
   app/test — luôn từ ARB / domain value.
5. **Viết test composition** `test/presentation/features/settings/reminder_states_test.dart` — **COPY cấu trúc**
   `test/presentation/features/engagement/dashboard_states_test.dart`, đổi:
   - đọc `tool/parity/contracts/reminder.states.json` (không phải dashboard);
   - `host()` dựng `ReminderScreen()` trong `MaterialApp` (kèm `localizationsDelegates` + `supportedLocales` như
     dashboard host);
   - `recipes` = `{ 'on': () => seed enabled=true, 'off': () => seed enabled=false }` — seed qua `SettingsCompanion`
     / `settings_notifier` truth (đọc `settings_notifier.dart` để lấy đúng storage key cho `reminder.enabled`);
   - `pumpAndSettle` (màn này không có loading spinner treo — `settings.when` resolve nhanh; nếu bị treo thì đổi
     sang vòng `for` pump 50ms như review, ghi lý do);
   - header test giải thích rõ: on/off cùng node-set (documented), time-picker coverage gap (giống review/library
     header giải thích state không map).
6. **Xóa 2 skeleton** đã tiêu thụ: `tool/parity/contracts/reminder.slots.skeleton.json` +
   `tool/parity/contracts/reminder.states.skeleton.json` (skeleton là AUTO-PROPOSED, không ship — theo ghi chú
   `$skeleton`; giống review/dashboard/library không còn skeleton).
7. **Cập nhật queue**: đổi `[ ] 15-reminder.md` → `[x]` trong `docs/agent/kit-to-flutter/README.md` (dòng 33).

---

## Hard rules (vi phạm = task fail — trích `CLAUDE.md`)

- **Template B bắt buộc** ở màn này: `reminder/time` là Container, KHÔNG cast `widget<MxCard>` (crash). Chỉ
  present/absent theo `find.byKey`.
- **Token-only**: không hardcode màu, radius, spacing, text style, duration, chuỗi user-facing. Dùng `Mx*` +
  theme token + `MxSpacing`/`MxRadius`.
- **Không node-literal hoist sau dynamic key**: mỗi `ValueKey('mx-node:...')` phải `const`, gắn node tĩnh; không
  sinh key động theo index/state.
- **Divergence → intent-ledger** (`reminder/time` Container, `reminder/time-edit` ListTile), KHÔNG ép FE về kit.
  Nếu là BUG → DỪNG, báo, chờ.
- **KHÔNG over-claim** đã gate phân biệt `on/off`: ở tầng keyed node-set chúng giống nhau — ghi rõ documented gap
  (bài học `style-parity-blind-spots`).
- **l10n cả hai ARB**: mọi chuỗi mới vào `app_en.arb` **và** `app_vi.arb` cùng commit; regen l10n; không sửa
  `lib/l10n/generated/**` tay. Không copy mock copy từ kit.
- **KHÔNG ship skeleton làm curated**; trim rồi xóa 2 skeleton.
- **KHÔNG bịa** `time-picker` state (không drive được sạch) → giữ coverage gap, báo rõ. Không viết test giả chỉ để
  có state.
- Không sửa file generated (`*.g.dart`, `*.freezed.dart`, `reminder.gen.json`, `docs/_generated/**`).
- Không thêm dependency mới (Stop & ask nếu cần).
- Không đổi hành vi SRS/schedule của reminder (W12: chỉ lên lịch notification, không đổi lịch review SRS).
- Doc-code parity: task thuần style/composition-parity ⇒ nhiều khả năng `WBS update: not needed` + không đổi
  business doc (ngoài ledger). Chạy Pre-commit parity check 8 bước; nếu chạm behavior user-visible → update doc
  cùng commit.

---

## Verification

```bash
node tool/verify/run.mjs --full
```

Phải PASS (ghi pass-marker mà pre-commit hook yêu cầu; gồm test parity mới + freshness check của specs). Nếu
`--full` fail hoặc bị skip → KHÔNG được báo done. Trong lúc dev có thể `--quick` (không marker). Chạy riêng test
mới để chắc: `flutter test test/presentation/features/settings/reminder_states_test.dart`.

Sau khi verify PASS, TRƯỚC final report: fan-out song song `code-reviewer` (review working-tree diff — cho nó
`git add -N .` rồi `git diff`, không commit trước) + `docs-drift-detector`. Gộp kết quả vào mục "Subagent review".
Fix blocker trước khi kết; liệt kê minor findings cho user.

---

## Commit (2 commit + WBS)

**Commit 1** — contract + test:
```
test(parity): reminder state-composition gate (on/off) + curated states.json

- curate tool/parity/contracts/reminder.states.json (2 states; on/off same node-set documented, time-picker coverage gap)
- curate tool/parity/contracts/reminder.slots.json (reminder/time timeValue = labelLarge FE-truth) [hoặc: skipped — nêu lý do]
- add test/presentation/features/settings/reminder_states_test.dart (Template B, copy dashboard_states_test)
- remove consumed skeletons (reminder.slots.skeleton.json, reminder.states.skeleton.json)

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>
```

**Commit 2** — docs/ledger + queue:
```
docs(parity): reminder divergences → intent-ledger; mark reminder done in kit-to-flutter queue

- intent-ledger: reminder/time (Container not MxCard), reminder/time-edit (ListTile not MxIconButton)
- mark [x] 15-reminder.md in docs/agent/kit-to-flutter/README.md

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>
```

**WBS** (bắt buộc, `CLAUDE.md` §WBS): thêm dòng Commit Traceability Log (§10 của
`docs/project-management/wbs.md`), newest first:
`<8-char hash> · <YYYY-MM-DD> · <WBS IDs> · reminder kit→flutter state-composition parity (Template B; on/off gated, time-picker gap, time/time-edit → intent-ledger)`.
Nếu WBS task breakdown không bị ảnh hưởng, report ghi: `WBS update: not needed — <reason>` (nhưng Commit
Traceability Log vẫn append nếu advance/complete WP).

---

## Final report format

```
## reminder — kit→flutter DONE
- Template: B (state-composition) — lý do: node MxCard duy nhất (reminder/time) render là Container ở FE ⇒ Template A crash on widget<MxCard>
- Gate-able keyed node (FE): reminder/time (Container), reminder/time-edit (ListTile)  [chrome screen/appbar loại khỏi gate]
- Contracts: reminder.states.json curated (on/off); reminder.slots.json curated (time labelLarge) [hoặc skipped — lý do]; 2 skeleton deleted
- States gated: on, off (CÙNG node-set — không phân biệt ở tầng composition, documented). Coverage gap: time-picker (showTimePicker overlay framework-owned, không keyed); on-vs-off distinction (khác biệt = enabled/opacity/hint, không đổi node-set)
- Divergences → intent-ledger: reminder/time (Container vs MxCard), reminder/time-edit (ListTile vs MxIconButton); reminder/time text role labelLarge (FE-truth vs kit displayLarge — slots.json, no ledger)
- Identity-rollout gap (chưa keyed FE): reminder/toggle, reminder/toggle-switch, reminder/days, reminder/day-0..6, reminder/back, reminder/picker-scrim, reminder/picker-sheet, reminder/picker-done
- l10n: settingsGroupReminder/reminderEnable/reminderTimeLabel/reminderActiveHint/weekday* đã có ở app_en.arb + app_vi.arb [no new keys | new keys: ...]
- Docs updated: <list | none — style/composition-parity only>
- WBS update: <line appended | not needed — reason>
- Verify: node tool/verify/run.mjs --full → PASS
- Subagent review: <blockers fixed | minor findings ...>
```
