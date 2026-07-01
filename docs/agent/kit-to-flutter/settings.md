# Kit → Flutter — SETTINGS conversion prompt

> **PROMPT ID:** `kit-to-flutter/settings` (queue item `22-settings.md`)
> Self-contained. Chuyển **một** màn: `settings`. KHÔNG chuyển màn khác.
> Ngôn ngữ làm việc: Việt/Anh đều được. Mọi path repo-root tuyệt đối (không leading slash).

---

## 0. Baseline

```bash
git checkout main
git pull --ff-only              # nếu remote có cập nhật
git checkout -b claude/kit-to-flutter-settings
```

- FE file: `lib/presentation/features/settings/screens/settings_screen.dart`
- Feature: `settings`
- Provider watched: `settingsProvider` (`SettingsNotifier`, keepAlive) trong
  `lib/presentation/features/settings/viewmodels/settings_notifier.dart`
- Test đích: `test/presentation/features/settings/settings_parity_test.dart` (TẠO MỚI)

---

## 1. Required reading (đọc trước khi code)

Bắt buộc, theo thứ tự:

1. `docs/design/MemoX Design System/ui_kits/memox-app/specs/settings.md`
   — DOM đã resolve token, 3 state: `loaded` / `group-expanded` / `value-picker`.
2. `tool/parity/contracts/settings.gen.json` — 4 node có identity:
   `settings/appbar` (MxAppBar), `settings/profile` (MxCard/elevated),
   `settings/screen` (MxScaffold), `settings/srs-notif-switch` (MxSwitch).
3. `tool/parity/contracts/settings.slots.skeleton.json` — slot đề xuất (SUPERSET, phải cắt).
4. `tool/parity/contracts/settings.states.skeleton.json` — membership node theo state (SUPERSET, phải cắt).
5. FE file ở trên + `settings_notifier.dart`.
6. **Reference test (COPY cái này):**
   `test/presentation/features/engagement/dashboard_states_test.dart` (**Template B** —
   state-composition trên TẬP node keyed). KHÔNG copy `review_parity_test.dart` (Template A)
   — xem §3 lý do.
7. Curated mẫu: `tool/parity/contracts/dashboard.states.json`, `dashboard.slots.json`.
8. Universal reading của CLAUDE.md: `docs/business/glossary.md`,
   `docs/contracts/code-style.md`, `docs/ui-ux/ui-ux-contract.md`,
   `docs/ui-ux/l10n-copy-contract.md`.

**Kit is source of truth** cho *style/identity*; nhưng nội dung/nhóm setting của FE là
sản phẩm thật (D-012, W10/W13) — xem intent-ledger §4. Strings luôn từ ARB, không copy mock.

---

## 2. CHOSEN TEMPLATE — **B (state-composition on the keyed node SET)** + why

**Chọn Template B** (giống `dashboard_states_test.dart`), KHÔNG dùng Template A.

Lý do (cụ thể cho settings):

- Template A (review) gate **từng MxCard**: identity + variant + slot-role. Nhưng ở
  settings, node MxCard duy nhất là `settings/profile` — và **FE hoàn toàn không có
  profile card** (grep: `mx-node:settings/profile` không xuất hiện trong `lib/`). FE là
  `ListView` phẳng gồm `_GroupHeader` + `ListTile` + `_StepperRow`, không phải MxCard →
  Template A không có gì để gate.
- Cái gate được ở settings là **membership của tập node theo state** (node nào render ở
  state `loaded`) → đúng hình dạng Template B: pump state, assert FE body render **đúng**
  tập keyed node (thừa = THỪA, thiếu = THIẾU).
- Chỉ 1 MxSwitch (`settings/srs-notif-switch`) tồn tại trong kit nhưng KHÔNG có trong FE
  (FE có `MxSwitch` cho Game random / Auto backup, khác semantic) → không map (xem §4).

---

## 3. Gate-able (keyed) node list

Sau khi align FE (xem §5), **chỉ** những node sau được key + gate ở state `loaded`.
Đây là các hàng setting FE THẬT SỰ có (không phải mock groups của kit):

| Node id (ValueKey) | FE widget | Ghi chú |
| --- | --- | --- |
| `mx-node:settings/screen` | `MxScaffold` | ĐÃ keyed — giữ nguyên |
| `mx-node:settings/appbar` | `MxAppBar` | ĐÃ keyed — giữ nguyên |
| `mx-node:settings/g-wordsPerRound` | `_StepperRow` (Game words/round) | thêm ValueKey vào row wrapper |
| `mx-node:settings/g-gameRandom` | `ListTile` (Game random switch) | thêm ValueKey |
| `mx-node:settings/g-boxCount` | `ListTile` (Leitner box count) | thêm ValueKey |
| `mx-node:settings/g-newPerDay` | `_StepperRow` (New/day) | thêm ValueKey |
| `mx-node:settings/g-goalMinutes` | `_StepperRow` (Goal minutes) | thêm ValueKey |
| `mx-node:settings/g-goalWords` | `_StepperRow` (Goal words) | thêm ValueKey |
| `mx-node:settings/g-reminder` | `ListTile` `settingsReminderRow` | thêm ValueKey (giữ Key cũ nếu test khác dùng) |
| `mx-node:settings/g-autoBackup` | `ListTile` (Auto backup switch) | thêm ValueKey |
| `mx-node:settings/g-sync` | `ListTile` `mx-node:account/sync` | ĐÃ có ValueKey `account/sync` — giữ, KHÔNG đổi (account-sync là màn riêng, item 16) |
| `mx-node:settings/g-theme` | `ListTile` `settingsThemeRow` | thêm ValueKey |

> Danh sách này là **curate của bạn** — kit's `settings/g-0..g-8` (Language, Word display,
> Voice, Cloud sync…) là mock groups KHÔNG khớp FE. Đừng key theo id kit; key theo hàng FE
> thật, với id `settings/g-<feName>` ổn định. Ghi rõ ánh xạ này vào `settings.slots.json`
> header comment.

**`account/sync`**: hàng sync đã mang `ValueKey('mx-node:account/sync')` (thuộc màn 16).
KHÔNG rename thành `settings/…`; ở states.json dùng đúng key `mx-node:account/sync` cho row sync.

---

## 4. Divergences → intent-ledger

Ghi vào header `$curated` của `settings.slots.json` + `settings.states.json`, và (nếu là
divergence hành vi) tuân doc-parity rule của CLAUDE.md.

1. **Profile card thiếu (`settings/profile`, MxCard/elevated).** Kit có card avatar+tên+email
   ở đầu. FE không render → cố ý (không có auth/profile trong v1). → **KHÔNG map**, KHÔNG key.
   Ledger: "profile card = kit mock; FE v1 không có màn account/profile (D-012)."
2. **Groups khác nhau (nội dung).** Kit mock = Language / Word display / Spaced repetition /
   Game / Voice | Reminders / Backup / Cloud sync / Theme. FE thật = Game / SRS / Goal /
   Reminder / Backup / Sync / Theme. → gate theo **FE groups**, không theo mock. Ledger:
   "kit groups là mock copy; FE groups là product thật (W10 sync, W13 theme, D-012 no premium)."
3. **ListRow = `ListTile`/`_StepperRow`, KHÔNG phải MxCard.** Kit vẽ mỗi hàng trong card
   `bg:surface r:20`. FE dùng `ListTile` phẳng + `_GroupHeader`. → divergence layout đã tồn tại
   & chấp nhận (kit-is-source-of-truth áp cho *style token* của widget, không ép cấu trúc card
   list). Ledger: "row container = ListTile (Material), không MxCard; chấp nhận, style qua theme."
4. **Value pill / stepper.** Kit hiện value bằng `<span>` + chevron mở bottom-sheet picker.
   FE hiện value bằng `_StepperRow` (nút +/−) inline, hoặc `ListTile.trailing` Text. →
   divergence tương tác (stepper vs picker). Ledger: "value chỉnh bằng stepper inline, không
   bottom-sheet picker."
5. **MxSwitch `settings/srs-notif-switch`.** Kit switch = "Due notifications" trong nhóm SRS.
   FE không có switch đó (reminder là màn riêng W15). FE có MxSwitch cho Game random & Auto
   backup — semantic khác. → **KHÔNG map** node kit switch. Ledger như trên.

> Nếu bất kỳ divergence nào là **hành vi user-visible chưa có trong docs**, DỪNG và báo theo
> DRIFT block của CLAUDE.md thay vì tự quyết.

---

## 5. State-map

FE watch `settingsProvider` → `AsyncValue<AppSettings>`:
`loading` → `MxStateView.loading()`; `error` → `SizedBox.shrink()`; `data` → `_body`.

| Kit state | Drivable trong FE? | Cách drive | Quyết định |
| --- | --- | --- | --- |
| `loaded` | ✅ | seed drift `settings` table (hoặc để trống → `AppSettings()` mặc định), pump, `pumpAndSettle` | **GATE** — tập node §3 |
| `group-expanded` | ❌ | Kit "expand" 1 group ra full sub-settings (Leitner boxes / intervals / due-notif switch). FE không có mô hình expand-in-place; các sub-setting đó là màn/route riêng | **COVERAGE GAP** — ghi vào states.json, không gate |
| `value-picker` | ❌ | Kit = bottom-sheet overlay chọn "N words". FE dùng `_StepperRow` inline, không mở bottom sheet | **COVERAGE GAP** — ghi vào states.json, không gate |

→ Chỉ **1 state gate được** (`loaded`). Hai state kia là **coverage gap** có chủ đích (giống
`editing`/`audio` của review): liệt kê trong `settings.states.json` với node set kit-đề-xuất
để hồ sơ đầy đủ, nhưng test CHỈ pump `loaded`.

**Pump harness** (theo `dashboard_states_test.dart` + `settings_notifier_test.dart`):

```dart
Widget host(AppDatabase db) => ProviderScope(
  overrides: [databaseProvider.overrideWithValue(db)],
  child: MaterialApp(
    theme: AppTheme.light(),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: const Scaffold(body: SettingsScreen()),
  ),
);
```

Seed `loaded`: `AppDatabase.forTesting(openInMemoryDatabase())` + (tuỳ chọn) insert vài
`SettingsCompanion` row để value khác mặc định — nhưng membership node KHÔNG đổi theo value,
nên seed rỗng là đủ cho state `loaded`. `SettingsScreen` không cần `clockProvider`/`languagePair`
để render body (khác dashboard). Dùng `pumpAndSettle()`.

---

## 6. Workflow (thứ tự bắt buộc)

1. **Curate `tool/parity/contracts/settings.slots.json`** từ skeleton:
   - Xoá mọi slot của mock group (g-0..g-8 Language/Voice/…).
   - Giữ/đặt slot cho các node §3 (label role từ FE: `_GroupHeader` = `labelLarge`;
     `ListTile.title` = bodyMedium tương đương). `l10n` = ARB key thật (xem §7), KHÔNG "TODO".
   - Header `$curated`: nêu intent-ledger §4 (profile bỏ, groups theo FE, ListTile not MxCard).
2. **Curate `tool/parity/contracts/settings.states.json`** từ skeleton:
   - `loaded`: tập node §3 (10–12 keyed body node) — đây là tập test gate.
   - `group-expanded`, `value-picker`: giữ node kit-đề-xuất + đánh dấu trong header là
     **coverage gap không drive** (giống review `editing`/`audio`).
   - Loại chrome khỏi tập gate nếu theo convention dashboard (appbar/screen là shell) — hoặc
     giữ và cho vào `allowed` mọi state; chọn 1 cách và nhất quán với test.
3. **Align FE theo ValueKey identity:** thêm `key: const ValueKey('mx-node:settings/g-…')`
   vào từng row §3 (`_StepperRow` cần nhận `Key? key` truyền lên `ListTile`; `_GroupHeader`
   KHÔNG cần key vì không gate header). Giữ nguyên `settings/screen`, `settings/appbar`,
   `account/sync`. KHÔNG bịa MxCard/profile/switch không có.
   - `_StepperRow` hiện chỉ có `keyPrefix` cho nút +/−. Thêm param `rowKey`/`super.key` để
     wrapper `ListTile` mang ValueKey node.
4. **l10n cả 2 ARB:** nếu thêm string mới → thêm vào `lib/l10n/app_en.arb` **và**
   `app_vi.arb` (cùng key). Đa số string đã tồn tại (`settingsGroupGame`, `settingsBoxCount`,
   `settingsGroupReminder`, `drawerTheme`, `settingsSyncTitle`…) → không thêm mới, chỉ verify.
   Chạy gen l10n nếu ARB đổi.
5. **Parity test** — tạo `test/presentation/features/settings/settings_parity_test.dart`
   **COPY cấu trúc `dashboard_states_test.dart`**:
   - Đọc `settings.states.json`, build `states` map + `universe`.
   - `recipes` chỉ 1 entry: `'loaded': () async {}` (seed rỗng đủ). KHÔNG thêm recipe cho
     `group-expanded`/`value-picker` (coverage gap — test không pump chúng; comment rõ như
     review test comment `editing`/`audio`).
   - Với state `loaded`: pump host, `pumpAndSettle`, loop `universe` → allowed ⇒ `findsOneWidget`
     (THIẾU), else ⇒ `findsNothing` (THỪA).
   - `find.byKey(ValueKey(key))` khớp `mx-node:settings/…` (và `mx-node:account/sync`).
6. **Xoá 2 skeleton:** `git rm tool/parity/contracts/settings.slots.skeleton.json`
   `tool/parity/contracts/settings.states.skeleton.json` (đã thay bằng bản curated).
7. **Verify:** `node tool/verify/run.mjs --full`.
8. **Auto-review fan-out** (sau verify PASS, trước report): `code-reviewer` (diff) +
   `docs-drift-detector`. Fold findings.

---

## 7. l10n keys (đã có trong ARB — verify, đừng bịa key mới)

`settingsGroupGame`, `settingsWordsPerRound`, `settingsGameRandom`, `settingsGroupSrs`,
`settingsBoxCount`, `settingsNewPerDay`, `settingsGroupGoal`, `settingsGoalMinutes`,
`settingsGoalWords`, `settingsNotSet`, `settingsGroupReminder`, `settingsReminderSummaryOff`,
`settingsGroupBackup`, `settingsAutoBackup`, `settingsBackupNow`, `settingsRestore`,
`settingsSyncTitle`, `settingsSyncSubtitle`, `drawerTheme`, `drawerSettings`.
Nếu thiếu key nào khi align → thêm cả en+vi cùng commit.

---

## 8. Hard rules (vi phạm = fail)

- KHÔNG tạo MxCard/profile/switch không tồn tại trong FE chỉ để khớp kit mock. FE là truth
  về *nội dung*; kit là truth về *style token* của widget đã có.
- KHÔNG copy mock string ("Language", "linh@memox.app", "5 words/round") vào app — string từ ARB.
- KHÔNG hardcode route/color/textstyle/duration/string.
- KHÔNG đổi/xoá `ValueKey('mx-node:account/sync')` — thuộc màn account-sync (item 16).
- KHÔNG key mock id `settings/g-0..g-8`; key theo hàng FE thật (`settings/g-<feName>`).
- KHÔNG gate `group-expanded` / `value-picker` — không drivable, chỉ ghi coverage gap.
- KHÔNG sửa file generated (`*.g.dart`, `lib/l10n/generated/**`).
- KHÔNG commit thiếu pass-marker (`node tool/verify/run.mjs --full` phải xanh).
- Nếu phát hiện divergence hành vi user-visible chưa có trong docs → **DỪNG**, báo DRIFT, chờ người.

---

## 9. Verification

```bash
node tool/verify/run.mjs --full
```

Chỉ báo "done" khi marker xanh. Nếu bước nào skip/fail → nêu rõ bước + lý do.

---

## 10. Commit (2 commit + WBS)

**Commit 1 — contracts + test (parity infra):**
```
test(parity): settings — curate slots/states + loaded-state parity gate

- curate settings.slots.json / settings.states.json from skeleton
- settings_parity_test.dart (Template B, gate state `loaded`)
- delete *.skeleton.json
- intent-ledger: profile card bỏ, groups theo FE, ListTile not MxCard,
  group-expanded/value-picker = coverage gap (không drivable)
```

**Commit 2 — FE align:**
```
feat(parity): settings — align ListRows with mx-node:settings/* ValueKeys

- key Game/SRS/Goal/Reminder/Backup/Sync/Theme rows
- _StepperRow nhận node key; giữ account/sync, screen, appbar
```

**WBS:** cập nhật `docs/project-management/wbs.md` — thêm dòng Commit Traceability Log §10
(`<hash> · <YYYY-MM-DD> · <WBS IDs> · settings style-parity`). Nếu WBS không đổi scope,
report ghi `WBS update: not needed — <reason>`.

Sau cả 2 commit: `git push -u origin claude/kit-to-flutter-settings`.

---

## 11. Final report (mẫu)

```
SETTINGS kit→Flutter — DONE
- Template: B (state-composition), 1 state gate (loaded)
- Keyed body nodes: <N> (list) ; account/sync giữ nguyên
- Divergences (intent-ledger): profile card bỏ, groups theo FE, ListTile≠MxCard,
  stepper≠picker, srs-notif-switch không map
- Coverage gaps: group-expanded, value-picker (không drivable trong FE hiện tại)
- Docs updated: settings.slots.json, settings.states.json (+ intent-ledger); skeletons deleted
- Verify: node tool/verify/run.mjs --full → PASS
- Subagent review: <folded findings>
- WBS: <line hoặc "not needed — reason">
```
