# Props-Parity WBS — `.d.ts` contract → props_check gate → Flutter resync

> **Mục tiêu.** Cho MỌI component kit một **contract props typed** (`.d.ts`), dựng
> một **gate `props_check`** so contract đó với constructor Flutter, và **resync**
> Flutter cho khớp — biến "độ chính xác props" từ *đọc-JSX-nhớ-đủ-không* thành
> *gate chặn merge*. Tài liệu này là bản kế hoạch đầy đủ để chạy loop **không sót
> task**. Đọc kèm: [`kit-conversion-retrospective.md`](../../design/kit-conversion-retrospective.md)
> (vì sao props chỉ chính xác trục API, không chính xác trục visual).

---

## 0. Phạm vi & nguyên tắc

**Trong phạm vi.**
- Author `.d.ts` cho **65 component local** (`_features/*/components/*.jsx`) + **3
  `_shared`** (ActionCallout, ConfirmDialog, StatusCardRow) — tổng **68**.
- Dựng `tool/parity/props_check.mjs` + config alias + wire vào verify gate.
- Resync constructor Flutter cho khớp `.d.ts` (thêm prop thiếu / đủ enum / đúng
  optional-default) HOẶC ghi **exception có lý do typed**.

**Ngoài phạm vi (không đụng).**
- 15 shared core/nav/surfaces **đã có `.d.ts`** → chỉ dùng làm **tập hiệu chuẩn**
  cho checker (F.2), không author lại.
- **Visual fidelity** (padding/màu/layout/state) — đó là việc của DOM spec, KHÔNG
  phải props. `props_check` **chỉ** gate API surface (tên prop, giá trị enum,
  optional/required). Nói rõ giới hạn này trong doc để không ai kỳ vọng sai.
- **account-sync** (S.22 deferred): author `.d.ts` (để kit đủ contract) nhưng
  **resync Flutter = N/A** (chưa có widget) — đánh dấu deferred, không tạo widget.

**Nguyên tắc bất biến (kế thừa AGENTS.md + retrospective).**
1. **Kit là nguồn chân lý.** `.d.ts` phản ánh JSX + hành vi thật; Flutter chỉnh
   theo `.d.ts`, KHÔNG sửa `.d.ts` cho khớp Flutter.
2. **Lệch có chủ đích phải là exception typed**, hẹp, review được — KHÔNG phải sổ
   nợ mở (bài học lần 1: `intent-ledger` thành nghĩa địa).
3. **Mọi lời hứa có gate.** props_check phải chạy trong `tool/verify/run.mjs` + CI,
   và có wiring-guard test để không bị gỡ âm thầm.

---

## 1. Định nghĩa "3 bước" & ĐƠN VỊ LOOP

Một **firing của loop = xử lý trọn 1 UNIT** (mặc định = **1 feature dir**, tức tất
cả `components/*.jsx` dưới một `_features/<screen>/`; `_shared` là 1 unit). Mỗi unit
chạy trọn 3 bước:

- **Bước 1 — Author `.d.ts`:** cho từng component trong unit, viết `<Component>.d.ts`
  cạnh `.jsx`: `export interface <Name>Props { … }` trích từ **JSX destructuring
  signature** + default + hành vi/CSS + intent (JSDoc mỗi prop). Union đóng cho enum
  (`tone?: 'primary'|'warning'|…`). Web-only props (`node`,`className`,`children`,
  `onClick`,`type`) vẫn khai báo (đúng kit) nhưng đánh dấu alias/drop ở config.
- **Bước 2 — `props_check`:** chạy `node tool/parity/props_check.mjs --only <unit>`;
  nó diff prop-set `.d.ts` ↔ param-set constructor Flutter (sau khi áp alias), báo
  drift.
- **Bước 3 — Resync Flutter:** với mỗi drift → sửa constructor Flutter (thêm prop
  thiếu / đủ giá trị enum / đúng optional-default) **HOẶC** ghi exception typed vào
  `props-parity.exceptions.json`. Chạy lại tới khi `props_check --only <unit>` xanh +
  `node tool/verify/run.mjs` xanh.

> **Vì sao unit = feature dir, không phải từng component?** 68 component × PR riêng
> là quá nhiều PR vụn. Gộp theo feature (2–9 component/feature) cho PR mạch lạc
> (~23 firing), mỗi PR review được, khớp "1 task/firing" của loop.

---

## 2. Kiến trúc: 3 contract song song (props chỉ là 1)

```
KIT component  ──►  Flutter widget
   ├─ .d.ts (API contract)      → constructor params      ◄── props_check gate (WBS này)
   ├─ .jsx body + CSS (visual)  → build() body + tokens    ◄── DOM spec / gallery (đã có)
   └─ header "States: …"        → provider state machine   ◄── per-state widget test (đã có)
```

`props_check` **chỉ** gác mũi tên thứ nhất. Không cố gác visual/state bằng props.

---

## 3. PHASE P0 — FOUNDATION (một lần, TRƯỚC khi vào loop)

Bắt buộc xong P0 mới chạy P1. Đừng để loop "build lại checker 23 lần".

| ID | Task | Output | Definition of Done |
|---|---|---|---|
| **F.0** | **Mapping/alias config** | `tool/parity/props_map.json` | Chứa: (a) **file alias** kit↔flutter khi tên lệch (bảng §5.1); (b) **prop-name alias** (`children→label/child`, `onClick→onPressed`, `text→text`…); (c) **prop drop-list** web-only (`node,className,type,key`); (d) **type map** (`string(icon)→IconData`, `boolean→bool`, union→enum); (e) **enum-value alias** (`sm→small,lg→large`, base→`medium`). Schema có comment. |
| **F.1** | **`props_check.mjs` (advisory)** | `tool/parity/props_check.mjs` | Parse `.d.ts` (interface props: name, optional?, union values) + Flutter ctor (named params: name, `required`?, default, enum type + values). Áp alias/drop từ F.0. Diff → in **MISSING_IN_FLUTTER / EXTRA_IN_FLUTTER / ENUM_MISMATCH / OPTIONALITY_MISMATCH**. Cờ `--only <feature|component>`. **Advisory:** exit 0 kể cả có drift (chưa chặn gate). |
| **F.2** | **Hiệu chuẩn trên 15 shared** | (config tinh chỉnh) | Chạy `props_check` trên 15 shared **đã có `.d.ts` + Flutter**. Mọi drift còn lại phải là **exception typed hợp lệ** (vd `MxButton.size sm/lg → small/medium/large` = `enum-base-expansion`; `type/node/className` = `web-only`). Ghi các exception này vào `props-parity.exceptions.json`. Sau F.2, shared = **0 drift chưa giải thích** → chứng minh checker + alias đúng trước khi mass-author. |
| **F.3** | **Exception schema + queue + WBS** | `props-parity.exceptions.json`, `docs/agent/props-parity/{QUEUE.md,DONE.txt}`, WBS này | Exception schema (§6). QUEUE.md render bảng §4 với ô `[ ]`. DONE.txt rỗng. Commit + merge P0. |

**Điểm chú ý P0.**
- **Parser `.d.ts` không cần TypeScript compiler** — regex/AST nhẹ đủ (interface là
  cú pháp đơn giản, ổn định). Nhưng phải xử lý: union nhiều dòng, JSDoc xen giữa,
  `?:` optional, `ReactNode`/`() => void` (drop).
- **Parser constructor Flutter:** đọc block `const <Class>({ … })` + phần `final`
  fields + `enum <X> { … }` trong cùng file. Cẩn thận named vs positional
  (`super.executor`), default value, `required`.
- **F.2 là cửa an toàn:** nếu checker báo drift sai trên shared (vốn đã đúng), tức
  alias sai → sửa F.0, KHÔNG "nhắm mắt" thêm exception. Exception chỉ cho lệch
  **thật sự có chủ đích**.

---

## 4. PHASE P1 — LOOP QUEUE (đầy đủ 23 unit, không sót)

Mỗi hàng = 1 firing = 1 branch = 1 PR. `Flutter dir` là nơi resync. `#comp` = số
component phải author `.d.ts`. Thứ tự chạy: **§8**.

| # | Unit (feature) | Kit components → Flutter widget (alias nếu lệch) | #comp | Ghi chú |
|---|---|---|---|---|
| C.01 | `_shared` | ActionCallout→`action_callout` · ConfirmDialog→`confirm_dialog` · StatusCardRow→`status_card_row` | 3 | composites; nhiều màn dùng → làm sớm |
| C.02 | game-recall | TermCard→`term_card` · MeaningPanel→`meaning_panel` | 2 | POC (đã build kỹ) → validate loop trước |
| C.03 | game-typing | CharCompare→`char_compare` · InputBox→`input_box` | 2 | |
| C.04 | game-mc | PromptCard→`prompt_card` | 1 | |
| C.05 | game-matching | Tile→`tile` | 1 | Tile là styled div (không NS) |
| C.06 | game-picker | GameOption→`game_option` · ScopeCard→`scope_card` · ScopeSheet→`scope_sheet` | 3 | |
| C.07 | player | Dots→`dots` · PlayerCard→`player_card` | 2 | |
| C.08 | review | MeaningCard→`meaning_card` · TermCard→`term_card` | 2 | ⚠ TermCard trùng tên game-recall — khác dir, khác props |
| C.09 | study-result | Cta→`cta` · FinalizingView→`finalizing_view` · ResultHero→`result_hero` · StreakGoalCard→`streak_goal_card` | 4 | |
| C.10 | study-session | PromptCard→`prompt_card` · Stage{Review,Matching,Choice,Recall,Typing}→`stage_*` · ExitDialog→`exit_dialog` · AnswerSaveErrorDialog→`answer_save_error_dialog` · ResumeErrorState→`resume_error_state` | 9 | unit lớn nhất |
| C.11 | dashboard | ContinueCard→**`continue_deck_card`** · GoalCard→`goal_card` · StreakCard→`streak_card` · TodaySummary→**`today_summary`** | 4 | 2 alias tên |
| C.12 | deck-detail | DeckHeader→`deck_header` · DeckMenu→`deck_menu` · DeleteConfirmDialog→`delete_confirm_dialog` · FlashcardRow→`flashcard_row` · SubDeckCard→`sub_deck_card` | 5 | |
| C.13 | library | ContextBar→`context_bar` · LibraryHeader→`library_header` · OverflowMenuSheet→`overflow_menu_sheet` · PairPickerSheet→`pair_picker_sheet` · PlaySheet→`play_sheet` · SortSheet→`sort_sheet` | 6 | ⚠ Flutter có `library_node_card` KHÔNG có trong kit → orphan Flutter (§11) |
| C.14 | drawer | DrawerItem→`drawer_item` · DrawerPanel→`drawer_panel` · LangCard→`lang_card` · RemoveLanguageDialog→`remove_language_dialog` | 4 | |
| C.15 | search | Chips→**`search_chips`** · ResultRow→`result_row` | 2 | ⚠ Flutter `search_app_bar` orphan (§11) |
| C.16 | flashcard-editor | DupBanner→`dup_banner` · Field→`field` | 2 | |
| C.17 | import | SourceCard→`source_card` · Table→**`import_table`** | 2 | alias tránh clash `Table` |
| C.18 | export | ExportingCard→`exporting_card` · FormatList→`format_list` | 2 | |
| C.19 | reminder | TimeCol→`time_col` · TimePickerSheet→`time_picker_sheet` | 2 | |
| C.20 | settings | Profile→**`profile_card`** · ValuePickerSheet→`value_picker_sheet` | 2 | alias tên |
| C.21 | statistics | Bars→`bars` · Donut→`donut` · Heatmap→`heatmap` | 3 | |
| C.22 | theme | AccentPicker→`accent_picker` · PreviewCard→`preview_card` | 2 | |
| C.23 | account-sync | ProfileCard · SignInCard · SyncBlock | 3 | **Flutter = N/A (S.22 deferred)**: author `.d.ts` xong, resync bỏ qua, ghi exception `deferred-screen` cho cả unit |

**Tổng: 23 unit · 68 component `.d.ts`.**

---

## 5. Bảng ALIAS (web → Flutter) — dùng ở F.0 + khi author `.d.ts` + khi resync

### 5.1 File alias (tên component lệch)
| Kit | Flutter file/class |
|---|---|
| `dashboard/ContinueCard` | `continue_deck_card.dart` / `ContinueDeckCard` |
| `dashboard/TodaySummary` | `today_summary.dart` / `TodaySummary` |
| `import/Table` | `import_table.dart` / `ImportTable` |
| `search/Chips` | `search_chips.dart` / `SearchChips` |
| `_shared/SelectSheet` | `composites/select_sheet.dart` / `MxSelectSheet` |
| `_shared/ProfileCard` | `composites/profile_card.dart` / `MxProfileCard` |
| *(còn lại)* | snake_case của PascalCase (mặc định) |

### 5.2 Prop-name alias (áp cho MỌI component)
| Kit prop (web) | Flutter param | Ghi chú |
|---|---|---|
| `children` (text) | `label` hoặc `child`/`text` | tùy component — text→`label`/`text`, node con→`child` |
| `onClick` | `onPressed` / `onTap` | button→`onPressed`, row/tile→`onTap` |
| `icon: string` | `icon: IconData` | tên Material Symbol → `Icons.*` |
| `node`, `className`, `key`, `type` | *(drop)* | web-only, không map |

### 5.3 Enum-value alias
| Kit union | Flutter enum |
|---|---|
| `size: 'sm' \| 'lg'` (base ngầm) | `enum …Size { small, medium, large }` (base→`medium`) |
| `tone/variant: '…'` | `enum …Tone/…Variant { … }` khớp từng giá trị |

> Alias này là **input của checker**, đồng thời là **quy ước khi viết `.d.ts`** để
> hai bên nhất quán. Bất kỳ alias mới phát sinh trong loop → thêm vào `props_map.json`
> (không hardcode trong từng test).

---

## 6. EXCEPTION SCHEMA (`props-parity.exceptions.json`)

Cho lệch **có chủ đích**, hẹp, review được. KHÔNG phải sổ nợ.

```jsonc
{
  "component": "core/MxButton",           // kit path
  "prop": "size",                          // hoặc "*" cho cả component
  "reason": "enum-base-expansion",         // enum thuộc tập REASONS đóng
  "note": "kit 'sm|lg' + base → Flutter small/medium/large; base state = medium"
}
```

**REASONS (đóng — thêm reason mới phải sửa checker + review):**
- `web-only` — prop chỉ có nghĩa trên web (`node/className/type/children-as-node`).
- `enum-base-expansion` — kit bỏ qua giá trị "base", Flutter đặt tên (`medium`).
- `flutter-idiom` — đổi tên theo idiom nền tảng (`onClick→onPressed`).
- `deferred-screen` — component thuộc màn deferred (account-sync), chưa có Flutter.
- `flutter-only` — widget Flutter không có counterpart kit (§11 orphan) → không gate
  bằng `.d.ts`, ghi để checker bỏ qua chứ không báo EXTRA.

**Điểm chú ý:** exception phải **cụ thể tới prop** (trừ `deferred-screen`/`flutter-only`
dùng `"*"`). Một exception `"*"/reason:"flutter-idiom"` là **red flag** (đang giấu drift).

---

## 7. DEFINITION OF DONE

**Per component (`.d.ts`):**
- [ ] `<Component>.d.ts` cạnh `.jsx`, `export interface <Name>Props`.
- [ ] Mọi prop trong JSX signature có mặt; union đóng cho enum; `?:` đúng optional.
- [ ] JSDoc 1 dòng cho prop mang intent (đặc biệt biến thể/tone).
- [ ] Không bịa prop kit không có; web-only vẫn khai (checker sẽ drop).

**Per unit (firing):**
- [ ] Mọi component trong unit có `.d.ts` (bước 1).
- [ ] `node tool/parity/props_check.mjs --only <unit>` → **0 drift chưa giải thích**
  (mọi lệch còn lại có exception typed) (bước 2).
- [ ] Constructor Flutter đã resync (thêm prop/đủ enum/đúng optional) hoặc exception
  ghi rõ (bước 3).
- [ ] `node tool/verify/run.mjs` xanh (analyze + test không vỡ do đổi constructor).
- [ ] **Nếu resync thêm prop mới vào widget** → widget đó phải còn test (thêm/มก test
  nếu prop đổi hành vi); string mới (nếu có) từ ARB.
- [ ] Ledger row(s) trong `wbs.md §Ledger` (kit component → .d.ts → Flutter class →
  props_check) + ghi gap/exception.
- [ ] Commit → PR → merge → tick ô trong QUEUE.md + append DONE.txt.

**Per phase P2 (seal):**
- [ ] `props_check` chuyển sang **BLOCKING** trong `tool/verify/run.mjs` (exit≠0 khi
  có drift chưa exception).
- [ ] Wiring-guard test (giống `design_sync_gate_test`) khẳng định props_check nằm
  trong gate.
- [ ] Doc cập nhật (retrospective + 1 mục "props parity" trong web/design docs).

---

## 8. THỨ TỰ CHẠY & lý do

1. **P0 trước hết** (F.0→F.3). Không có checker thì bước 2/3 vô nghĩa.
2. **C.01 `_shared`** → composites nhiều màn dùng, sửa sớm giảm lan.
3. **C.02 game-recall → C.10 study-session** (nhóm game/study) → toàn stateless leaf,
   Flutter counterpart sạch 1:1 → **hiệu chuẩn loop** trên ca dễ trước.
4. **C.11 dashboard → C.15 library** → có **alias tên** + **orphan Flutter** → xử lý
   sau khi loop đã ổn.
5. **C.16 → C.22** → còform/list/sheet, ít biến thể.
6. **C.23 account-sync CUỐI** → deferred, chỉ author `.d.ts` + exception, không resync.

> Nguyên tắc: **ca sạch/gate mạnh trước, ca lệch/deferred sau** — giống lần convert 2.

---

## 9. STOP CONDITIONS (dừng unit, ghi BLOCKED, KHÔNG dừng cả loop)

- **Drift là visual, không phải props.** props_check báo khớp nhưng render lệch kit
  → **KHÔNG** phải việc của task này; ghi note "visual drift → DOM spec", tiếp tục.
- **Kit component KHÔNG map được sang 1 constructor Flutter** (bị inline vào screen,
  hoặc 1 kit comp = nhiều widget) → ghi exception `flutter-only`/note, **đừng** ép
  tạo widget mới chỉ để khớp checker.
- **`.d.ts` mâu thuẫn với JSX** (prop dùng trong body mà signature không khai) → đây
  là lỗi KIT → **STOP unit**, báo, chờ người (đúng nguyên tắc kit-là-nguồn-chân-lý,
  không tự đoán).
- **Resync đòi đổi hành vi widget** (không chỉ thêm prop) → có nguy cơ vỡ parity
  visual/state → STOP, báo, chờ.
- **verify không xanh được** sau nỗ lực trung thực → BLOCKED + QUESTIONS entry.

---

## 10. PHASE P2 — SEAL (sau khi hết queue P1)

| ID | Task | DoD |
|---|---|---|
| Z.0 | props_check → **blocking** trong verify gate | full gate chạy props_check, đỏ khi drift chưa exception |
| Z.1 | wiring-guard test | `test/tooling/props_check_gate_test.dart` đọc `run.mjs` khẳng định props_check được gọi |
| Z.2 | docs + ledger tổng | mục "Props parity" trong retrospective; ledger đủ 23 unit |

---

## 11. RỦI RO & EDGE CASE (để loop KHÔNG sót)

1. **Orphan Flutter (widget không có kit component):** `library/library_node_card`,
   `search/search_app_bar`. → exception `flutter-only` (checker bỏ qua, không báo
   EXTRA). Ghi vào exceptions ngay ở F.2/F.3 để loop không vấp.
2. **Trùng tên khác dir:** `game-recall/TermCard` vs `review/TermCard` — hai `.d.ts`
   khác nhau, hai widget khác dir. Checker phải map theo **dir + tên**, không chỉ tên.
3. **Component "styled div" (không NS):** `game-matching/Tile` là div thuần → props
   ít, `.d.ts` vẫn viết (text + trạng thái). Không bỏ sót vì "nó chỉ là div".
4. **Component inline trong screen (nếu có):** nếu 1 kit comp không có file widget
   riêng mà bị inline → checker không có constructor để so → exception
   `flutter-only`/note, KHÔNG tạo widget giả.
5. **Sheet/Dialog:** nhiều sheet Flutter là `show*Sheet()` helper, không phải widget
   có constructor props → xác định "surface có constructor" hay "helper" ở bước 1;
   helper thì so chữ ký hàm thay vì constructor.
6. **enum default = base:** kit thường bỏ giá trị base (`size` không set = base);
   Flutter đặt tên (`medium`). Luôn map base→named-default, ghi `enum-base-expansion`,
   đừng báo drift.
7. **Prop kit là ReactNode (slot):** `children`/`action` nhận node con → Flutter là
   `Widget child`/`Widget? action`. Type map `ReactNode→Widget`, không drop.
8. **CRLF/Windows:** `.d.ts` mới + `props_map.json` + exceptions → thêm `eol=lf` cho
   `**/*.d.ts` và `tool/parity/*` trong `.gitattributes` (tránh false-positive nếu
   checker so byte).
9. **Số PR lớn (23):** dùng nhánh `build/props-<unit>`; đừng làm trên main (bài học đã
   có). Prefix `MEMOX_SKIP_DESIGN_SYNC=1` cho push/pull main.
10. **Đừng để checker "tự khớp" bằng cách nới alias bừa:** alias mới chỉ thêm khi nó
    là quy ước THẬT (áp nhiều component), không phải để im 1 ca. Alias 1-lần = mùi
    exception, dùng exception thay vì alias.

---

## 12. LOOP PROTOCOL (mỗi firing)

```
STEP 1  Reset sạch main: MEMOX_SKIP_DESIGN_SYNC=1 git checkout -f main && … pull
STEP 2  Nếu chưa xong P0 (F.0–F.3) → làm task P0 kế tiếp, hết P0 mới sang P1.
        P1: đọc QUEUE.md, chọn unit [ ] đầu tiên KHÔNG trong BLOCKED, deps P0=done.
STEP 3  Hết unit [ ] (trừ deferred/blocked) → sang P2 (Z.0–Z.2). Hết P2 → append
        "✅ PROPS-PARITY COMPLETE" vào QUESTIONS.md, push, dừng loop (CronDelete).
STEP 4  Nhánh build/props-<unit>. Chạy 3 bước (author .d.ts → props_check --only →
        resync/exception). Tôn trọng AGENTS.md (không magic value, string ARB,
        @riverpod-no-setState nếu chạm provider).
STEP 5  node tool/verify/run.mjs PHẢI xanh (advisory props_check ở P1; blocking ở P2).
STEP 6  Commit (Co-Authored-By: Claude) → push -u → gh pr create → merge --delete-branch
        → tick QUEUE.md + DONE.txt → gen prompts nếu có → checkout main && pull.
BLOCKED/STOP: append <unit> vào BLOCKED.txt + entry QUESTIONS.md (## Open), push, hết
        firing. KHÔNG bao giờ dừng cả loop cho 1 unit; chỉ STEP 3 dừng loop.
```

---

## 13. TÓM TẮT ĐỂ KHÔNG SÓT

- **P0 (4 task):** F.0 config · F.1 checker advisory · F.2 hiệu chuẩn shared · F.3 queue.
- **P1 (23 unit / 68 `.d.ts`):** C.01–C.23 theo thứ tự §8; mỗi unit = 3 bước + DoD §7.
- **P2 (3 task):** Z.0 blocking · Z.1 wiring-guard · Z.2 docs/ledger.
- **Đầu ra:** 68 `.d.ts` mới · `tool/parity/props_check.mjs` + `props_map.json` +
  `props-parity.exceptions.json` · gate blocking + test · Flutter constructors khớp
  contract hoặc có exception typed · ledger + docs đầy đủ.
- **Cái KHÔNG làm:** không sửa `.d.ts` theo Flutter; không gate visual; không tạo
  widget giả cho account-sync; không nới alias để giấu drift.
