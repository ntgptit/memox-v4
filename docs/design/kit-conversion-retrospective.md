# Kit → Flutter: Retrospective & Playbook

> Tài liệu tổng kết **quy trình chuyển đổi UI kit (JSX) sang Flutter** của MemoX V4 —
> từ cách thiết kế kit, qua từng bước đồng bộ sang Flutter, đến lý do vì sao lần
> rebuild này (main) đạt độ trung thành với kit cao hơn hẳn lần đầu
> (`backup/pre-flutter-reset-2026-07-02`). Viết để tái sử dụng cho các dự án
> kit→Flutter sau: mỗi bước có **Cách làm · Nguyên nhân · Giải thích · Điểm cần chú ý**.

---

## 0. Bối cảnh — hai lần convert, một bài học

Repo này chứa **hai lần** convert cùng một kit:

| | Lần 1 (branch `backup/pre-flutter-reset-2026-07-02`) | Lần 2 (main hiện tại) |
|---|---|---|
| Chiều quy trình | Viết FE trước → **retrofit** parity vào sau | Đọc kit trước → **sinh** FE từ kit |
| Xử lý lệch kit | Ghi vào `intent-ledger.json` (sổ nợ, chấp nhận) | **STOP** — sửa kit hoặc dừng chờ người |
| Token layer | Chép tay từ CSS + "lời hứa giữ sync" | Máy sinh (`gen_tokens.mjs`) + `--check` gate chặn merge |
| Cấu trúc màn hình | Nguyên khối (dashboard 637 dòng, component private) | Component-per-file **trùng tên** component kit |
| Test state | Gate hậu kiểm, nhiều state thành "gap" | Mỗi state test light+dark **ngay lúc build màn** |

Kết luận đứng trước, chi tiết đứng sau:

> **Lần 1 thất thế không phải vì code kém, mà vì viết code trước rồi mới hỏi kit.
> Lần 2 hỏi kit trước rồi mới viết code — và thay mọi "lời hứa đồng bộ" bằng
> máy sinh + gate chặn merge.**

---

## 1. Toàn cảnh pipeline

```
        KIT (nguồn chân lý duy nhất)                     FLUTTER
┌─────────────────────────────────────┐   ┌─────────────────────────────────────┐
│ tokens/*.css  (9 file --memox-*)    │──▶│ lib/core/theme/mx_*.dart (GENERATED)│  A1→B1
│ components/{core,navigation,       }│──▶│ presentation/shared/{primitives,    │  A2→B3
│             surfaces}/Mx*.jsx       │   │                      composites}/   │      B4
│ ui_kits/memox-app/_features/<scr>/  │──▶│ presentation/features/<scr>/        │  A3→B6
│   <Screen>.jsx + components/*.jsx   │   │   screens/ + widgets/ + providers/  │
│ specs/<scr>.md   (DOM spec máy xuất)│──▶│ (input đọc bắt buộc khi viết code)  │  A4
│ shots/<scr>--<state>--{light,dark}  │──▶│ (đối chiếu thị giác per state)      │  A4
└─────────────────────────────────────┘   └─────────────────────────────────────┘
              ▲                                          │
              │  design-sync (push repo → Claude Design) │  node tool/verify/run.mjs
              └── .githooks/{pre-push,post-merge}        └─ tokens --check + analyze + test
```

Nguyên tắc xuyên suốt (AGENTS.md):
1. **Kit là nguồn chân lý** cho mọi giá trị thị giác — FE lệch thì sửa kit, không vá Dart.
2. **Không hand-edit code generated** — token mirror là máy sinh, commit, có gate.
3. **Không magic value trong UI** — chỉ `Mx*` token; **string từ ARB**, không hardcode.
4. **Mọi "lời hứa" phải có gate** — nếu một quy tắc chỉ sống bằng kỷ luật con người, sớm muộn nó cũng bị vi phạm.

---

## PHẦN A — THIẾT KẾ KIT (để convert được, kit phải "convert-ready")

### A1. Token CSS là tầng 0 — mọi giá trị thị giác có tên

**Cách làm.** Toàn bộ giá trị thị giác sống trong 9 file CSS dưới
`docs/design/MemoX Design System/tokens/`:

```
colors.css  typography.css  spacing.css  radius.css  elevation.css
size.css    icon-size.css   stroke.css   motion.css
```

Mỗi giá trị là một custom property `--memox-<role>` **đặt tên theo vai trò ngữ nghĩa**
(`--memox-text-secondary`, `--memox-radius-control`, `--memox-space-5`…), không theo
giá trị thô (`--gray-600`). Kit JSX **chỉ** tham chiếu token, không bao giờ viết hex/px
trực tiếp trong component.

**Nguyên nhân.** Muốn máy dịch được kit sang nền tảng khác thì "ngôn ngữ chung" phải
là token có tên. Nếu JSX viết `#6b7280` thì bên Flutter chỉ có thể chép mù; nếu JSX viết
`var(--memox-text-secondary)` thì bên Flutter có đích ánh xạ 1:1 (`mx.textSecondary`).

**Giải thích.** Tên-theo-vai-trò còn cho phép **đổi theme không đổi cấu trúc**: light/dark
chỉ là hai bảng giá trị của cùng một tập tên. Spec exporter (A4) cũng nhờ đó ghi được
"node này màu `text-tertiary`" thay vì một mã hex vô danh.

**Điểm cần chú ý.**
- **CSS là nguồn chân lý, không phải manifest.** `_ds_manifest.json` chỉ liệt kê một phần
  file (bỏ sót size/icon-size/stroke/motion) — generator phải parse CSS trực tiếp.
  Bài học thật: nếu tin manifest, 4 nhóm token đã bị bỏ rơi.
- Token **không dùng đến** cũng phải xử lý minh bạch: generator có SKIP-list tường minh,
  và **abort** khi gặp token mới chưa được emitter nào tiêu thụ — token mới không bao giờ
  lọt qua thầm lặng (xem B1).

### A2. Ba tầng một chiều: tokens → components → ui_kits

**Cách làm.** Kit chia 3 tầng, phụ thuộc **một chiều**:
- `tokens/` — giá trị.
- `components/{core,navigation,surfaces}/` — component dùng chung (`MxButton.jsx`,
  `MxChip.jsx`, `MxSwitch.jsx`…), mỗi component kèm `.d.ts` (contract props) và
  `.prompt.md` (ghi chú cho agent convert).
- `ui_kits/memox-app/` — màn hình của app, **compose** từ components + tokens.

**Nguyên nhân.** Tầng nào bên kit thì bên Flutter có tầng tương ứng — cấu trúc kit
chính là **kế hoạch build** của Flutter: tokens → `lib/core/theme/`; components →
`presentation/shared/`; ui_kits → `presentation/features/`. Phase build I→T→P→K→H→S
của WBS đi đúng thứ tự này.

**Giải thích.** Một chiều nghĩa là component không được "với xuống" định nghĩa giá trị
riêng, màn hình không được chế component riêng nếu tầng dưới đã có. Nhờ vậy con số cần
convert hữu hạn: ~25 shared component convert **một lần**, mọi màn chỉ là phép ghép.

**Điểm cần chú ý.**
- `.d.ts` cạnh `.jsx` là hợp đồng props — bên Flutter constructor của `Mx*` phản chiếu
  đúng tập props này (variant/size/tone/block…), giúp review "đủ chưa" bằng diff hai file.
- `.prompt.md` per-component là chỗ ghi ý đồ không nhìn thấy trong code (hành vi focus,
  ngữ nghĩa disabled…) — đọc nó trước khi convert component.

### A3. `_features/<screen>/` — mỗi màn một thư mục, JSX khai báo state machine

**Cách làm.** Mỗi màn hình app là một thư mục:

```
_features/game-recall/
  GameRecall.jsx        ← composition + STATE MACHINE ở header comment
  components/
    TermCard.jsx        ← component chỉ màn này dùng
    MeaningPanel.jsx
_shared/                ← ActionCallout, ConfirmDialog… (nhiều màn dùng, chưa đủ "core")
```

Header của mỗi screen JSX **liệt kê states tường minh**:
```jsx
/* MemoX — Game: Recall. States: before-reveal · revealed · complete
   Feature-local components: components/{TermCard,MeaningPanel}.jsx */
```
và component nhận `{ state = 'before-reveal' }` để render từng trạng thái.

**Nguyên nhân.** Đây là thay đổi kiến trúc quan trọng nhất giữa hai lần convert.
Kit cũ là các file screen phẳng (`DashboardApp.jsx`, `Review.jsx`… nằm chung một mặt) —
không nói cho người convert biết *cái gì là local*, *có bao nhiêu state*. Kit mới làm
**đơn vị công việc trùng với đơn vị cấu trúc**: 1 thư mục = 1 task convert = 1 PR.

**Giải thích.** Ba câu hỏi đắt nhất khi convert một màn là: (1) màn này gồm những khối
nào? (2) khối nào dùng chung, khối nào riêng? (3) có những trạng thái nào phải cover?
Cấu trúc `_features` trả lời cả ba **bằng filesystem**, trước khi ai đọc một dòng code.

**Điểm cần chú ý.**
- State machine ở header là **hợp đồng test**: bên Flutter, mỗi state trong danh sách đó
  phải có test render (light+dark). Thiếu state nào phải ghi "gap" có lý do, không im lặng.
- Component local đặt **tên trùng** file Dart sẽ sinh ra (`TermCard.jsx` →
  `term_card.dart`) — ánh xạ tồn tại ở mức tên file, không cần bảng tra riêng.
- Mock copy trong JSX (`"học"`, `"school"`, `"7/20"`) là **dữ liệu minh họa, không phải
  copy chuẩn** — bên Flutter mọi chữ lấy từ ARB. Spec exporter cũng in cảnh báo này.

### A4. Kit render được → máy xuất shots + DOM specs

**Cách làm.** `ui_kits/memox-app/index.html` render được toàn bộ màn hình + state thật
trong browser. Từ bản render đó, tooling xuất ra hai sản phẩm **máy đọc được**:
- `shots/<screen>--<state>--{light,dark}.png` — 234 ảnh chuẩn (khung phone 390×780).
- `specs/<screen>.md` — **DOM spec** per màn: mỗi node kèm `abs:[x,y WxH]` /
  `rel:[x,y WxH]`, layout (`flex:col gap:20`), padding/margin, **token** cho màu/chữ
  (`color:text-tertiary`, `font:13/700/20`), và **ordered diff** giữa các state.

**Nguyên nhân.** Ảnh chỉ giúp người *nhìn*; spec giúp agent *đo*. "Khoảng cách giữa card
và nút là bao nhiêu?" — không đoán từ PNG nữa, đọc `rel:` trong spec. "State revealed khác
before-reveal chỗ nào?" — đọc ordered diff, không so hai ảnh bằng mắt.

**Giải thích.** Đây là điểm biến "trung thành với kit" từ **cảm nhận** thành **kiểm chứng
được**. Chi phí đoán = nguồn lệch lớn nhất của lần convert 1; spec triệt tiêu phần lớn
chi phí đó.

**Điểm cần chú ý.**
- Spec có `.source-hash` — verify gate mode `--docs` phát hiện spec **cũ** so với kit
  (sửa kit mà quên re-export → gate đỏ).
- Spec ghi `mx:<Mx>` khi node map được về shared component, và **cố tình để trống**
  (`mx:?`) khi không chắc — *không đoán hộ*; hex trần không match token cũng được giữ
  nguyên như một "gap" thay vì được làm tròn. Nguyên tắc: **công cụ không được che
  sự không chắc chắn của chính nó**.
- Số liệu trong spec đo trên **light theme**; dark chỉ remap token — vì vậy chỉ cần
  1 bộ tọa độ, 2 bảng màu.

---

## PHẦN B — ĐỒNG BỘ SANG FLUTTER (từng bước, theo đúng thứ tự đã chạy)

### B1. Tier-0: sinh token mirror bằng máy (`tool/design/gen_tokens.mjs`)

**Cách làm.** Script Node parse 9 file CSS, emit `lib/core/theme/mx_*.dart`
(MxColors light+dark, MxTypography, MxSpacing, MxRadius, MxSizes/MxStroke/MxIconSize,
elevation, motion). File sinh ra **được commit** (khác build_runner output vốn gitignore),
header ghi `GENERATED — DO NOT EDIT BY HAND`. Chế độ `--check` regenerate trong bộ nhớ và
diff với bản đã commit — lệch là exit non-zero. `--check` chạy trong **mọi** mode của
verify gate và CI.

**Nguyên nhân.** Lần 1, `mx_colors.dart` chép tay kèm doc-comment *"keep the two in sync
when a token changes"* — một lời hứa. Lời hứa không scale: kit đổi 1 giá trị là Flutter
lệch âm thầm. Máy sinh + gate biến drift từ "có thể xảy ra" thành "không thể merge".

**Giải thích.** Vì sao commit file generated? Vì nó **không có build step** ở phía app
(không cần chạy Node để build Flutter), phải **diff được** trong PR review, và là input
của `--check`. Đây là ngoại lệ có chủ đích của quy tắc "generated thì gitignore".

**Điểm cần chú ý.**
- **Drift guard nội bộ:** mọi `--memox-*` parse được phải được đúng 1 emitter tiêu thụ
  hoặc nằm trong SKIP-list; token mới chưa xử lý → generator **abort**. Không bao giờ có
  token "lọt lưới".
- **CRLF/Windows:** so sánh byte sẽ false-positive nếu Git convert line-ending —
  `.gitattributes` pin `lib/core/theme/mx_*.dart` và `tool/design/*.mjs` là `eol=lf`.
- Token đơn vị web (px, letter-spacing theo em) phải quy đổi có quy tắc ghi rõ trong
  generator (vd. `letterSpacing = fontSize * trackingTight`).

### B2. Ráp theme: `ColorScheme` + `MxTheme` extension — hai kênh có chủ đích

**Cách làm.** `app_theme.dart` ráp token vào 2 kênh: các vai trò Material hiểu được thì
seed vào `ColorScheme` (primary, onSurface, error…); các vai trò Material **không** biểu
đạt được (success/warning/info, cặp `*Soft/on*Soft`, surface tiers, divider, state
overlay…) đi qua `ThemeExtension MxTheme`. Widget đọc `Theme.of(context)` /
`MxTheme.of(context)` — **không import file màu trực tiếp**.

**Nguyên nhân.** Nếu nhét hết vào ColorScheme sẽ phải "mượn vai" (dùng `tertiary` cho
success…) — mất ngữ nghĩa, sau này không ai hiểu. Nếu bỏ ColorScheme hoàn toàn thì mất
integration với Material widget (ripple, disabled mặc định…). Hai kênh giữ được cả hai.

**Điểm cần chú ý.** Một giá trị chỉ nên sống ở **một** kênh; khi widget cần
`scheme.primary` đừng thêm bản sao `mx.primary` (lần 2 từng gặp lỗi compile vì gọi
`mx.primary` không tồn tại — đúng thiết kế: primary thuộc ColorScheme).

### B3. Primitives (Phase P): convert ~component core một-đối-một, đúng idiom Flutter

**Cách làm.** Mỗi component `components/core/*.jsx` thành một file
`presentation/shared/primitives/mx_*.dart`, props phản chiếu `.d.ts`
(variant/size/tone/block/danger…). Kèm widget test per variant per theme.

**Nguyên nhân.** Màn hình chỉ trung thành với kit nếu **viên gạch** trung thành trước.
Convert primitives trước còn ép mọi màn sau *phải* compose thay vì tự vẽ.

**Giải thích — điểm tinh tế nhất: "trung thành" ≠ "chép nguyên văn".** JSX của kit dùng
shortcut web (`div onClick`, disabled chỉ là class mờ, icon ligature làm label). Prompt
convert cấm port các shortcut này và bắt build **đúng chuẩn Flutter**:
- Surface tương tác = `InkWell` + `Semantics(button: true)` (được focus + Enter/Space free);
- Disabled = `onPressed: null` **thật** (không chỉ mờ đi);
- Control icon-only **bắt buộc** `semanticLabel` từ ARB — không bao giờ là tên icon;
- Touch target ≥ `MxSpacing.minTouchTarget` (48) kể cả khi visual nhỏ hơn (Material
  padded tap target).

Tức là: **trung thành với hợp đồng thị giác của kit, nhưng đúng ngữ nghĩa nền tảng đích.**
Gate V.5 (a11y) sau đó xác nhận bằng `androidTapTargetGuideline` / `labeledTapTargetGuideline`.

**Điểm cần chú ý.** Copy hiển thị **do caller truyền vào** (từ ARB) — primitive không sở
hữu string nào, nhờ đó không dính l10n và tái dùng được ở mọi màn.

### B4. Composites (K) + Gallery gate (H)

**Cách làm.** Các khối ghép (MxCard, MxAppBar, MxScaffold, MxEmptyState, MxListRow,
MxActionCallout, ConfirmDialog…) convert tiếp từ `components/{navigation,surfaces}` +
`_shared/`. Sau đó dựng **ComponentGallery** — một màn nội bộ render *mọi* shared widget
ở *mọi* variant — và gate: gallery render cả 2 theme **không exception**, đủ mặt từng
component type.

**Nguyên nhân.** Gallery là "hợp đồng tồn tại" của tầng shared: component nào gãy
(thiếu token, đổi tên, throw) thì đỏ **trước khi** màn hình nào kịp dùng nó. Nó cũng là
fallback cấu trúc khi pixel-golden bị chặn (xem Phần D).

**Điểm cần chú ý.** MxScaffold là chỗ "đóng khung" mọi màn — quyết định responsive
(cap `maxContentWidth`, center trên màn lớn) làm **một lần ở đây** là mọi màn hưởng
(V.6 đã chứng minh: sửa 1 file, 21 màn được cap).

### B5. Domain + Fakes seam (DM, đặc biệt DM.9) — cho FE chạy trước BE

**Cách làm.** Toàn bộ tầng domain (entities, repository interface, use case, SRS engine)
viết trước, thuần Dart. `data/providers/data_providers.dart` là **seam DI** — mọi màn chỉ
biết provider. DM.9 cung cấp **fakes in-memory + FakeHarness** (store seed sẵn, clock cố
định) để mọi screen test pump qua override.

**Nguyên nhân.** Nếu màn hình phải đợi Drift thì convert UI nghẽn theo backend. Seam
cho hai track chạy **song song**: 21 màn build + test xong trên fakes, rồi DT.5 lật seam
sang Drift **không đổi một dòng screen nào** — đã chứng minh khi flip: chỉ 1 test harness
phải sửa, 0 screen.

**Điểm cần chú ý.**
- Provider chưa có impl thật thì **throw "must be overridden"** thay vì trả stub im lặng —
  quên override là biết ngay.
- Clock phải injectable từ ngày đầu (`Clock` interface) — mọi test SRS/streak
  deterministic; đây cũng thành policy tầng data về sau.

### B6. Screens (Phase S): prompt máy sinh, mỗi màn một vòng lặp

Đây là bước "convert" đúng nghĩa, và là nơi khác biệt lớn nhất với lần 1.

**Cách làm.** `tool/design/gen_task_prompts.mjs` sinh 1 prompt/màn
(`docs/agent/build/s16-game-recall.md`…), mỗi prompt gồm:
1. **Inputs — READ ALL IN FULL:** đường dẫn đích danh `<Screen>.jsx`, từng
   `components/*.jsx` local, `specs/<screen>.md`, `shots/<screen>--*`.
2. **Output paths:** `screens/`, `widgets/` (đúng số component local), `providers/`, test.
3. **Steps:** enumerate states → build component local (token-only, compose Mx*) →
   provider `@riverpod` gọi use case (chạy trên fakes) → compose màn, string từ ARB →
   test **mọi state** (light+dark) → verify → ledger.
4. **Quy tắc STOP:** *"FE structure diverges from the kit → STOP (possible drift)"*;
   state không drive được → **document gap, không fabricate**.

Vòng lặp tự trị chạy: 1 firing = 1 màn = 1 branch = 1 PR merge, gate xanh mới được tick.

**Nguyên nhân — từng quyết định:**
- *Vì sao prompt máy sinh?* Để **không màn nào bị convert bằng trí nhớ**. Mọi màn nhận
  cùng khuôn yêu cầu, chỉ khác inputs — chất lượng không phụ thuộc "hôm đó agent nhớ gì".
- *Vì sao enumerate states trước?* State machine ở header JSX là hợp đồng; liệt kê trước
  thì thiếu state là **nhìn thấy được** trong PR (dòng "gap + lý do"), không phải phát
  hiện sau 3 tháng.
- *Vì sao component-per-file trùng tên kit?* Khi kit đổi `MeaningPanel.jsx`, grep ra ngay
  `meaning_panel.dart`. Ánh xạ là **cấu trúc**, không phải tài liệu phụ.
- *Vì sao STOP thay vì ledger?* Lần 1 cho phép "divergence → intent-ledger" — sổ nợ đó
  không bao giờ được trả (settings *"kit model ≠ FE rows, not 1:1 mappable"* nằm đó mãi).
  STOP ép quyết định lệch phải xảy ra **lúc rẻ nhất**: trước khi code đông cứng.

**Điểm cần chú ý.**
- **State controller trong provider, không `setState`** — nhờ vậy "state test" là test
  provider thuần + widget pump, nhanh và bền, không phải integration test mong manh.
- TextEditingController là ngoại lệ hợp lệ (không phải app state) —
  ConsumerStatefulWidget chỉ để own controller, logic vẫn ở provider.
- Mỗi màn PHẢI kết thúc bằng **ledger row** (kit node → Dart symbol → test → PR) và đoạn
  "gaps/notes" **trung thực** — gap được ghi là gap, không được im lặng, không được bịa
  cho có (nhiều lần: audio "Playing…" transient, per-session accuracy không tồn tại,
  app-bar options không có menu v1 → omit kèm lý do a11y).

### B7. Ledger + WBS: dấu vết hai chiều

**Cách làm.** `docs/project-management/wbs.md §Ledger` giữ một dòng cho mỗi kit-node /
D-xxx: node → Dart symbol → test → task → PR. Kèm đoạn gaps/notes per task.

**Nguyên nhân.** Ledger trả lời hai câu hỏi kiểm toán: *"node này của kit nằm đâu trong
Flutter?"* và *"file Dart này sinh ra từ đâu, ai test nó?"*. Khi kit đổi, ledger là bản đồ
ảnh hưởng.

**Điểm cần chú ý.** Ledger phải đủ **ngay trong commit implement** — bài học lần 1: ledger
thiếu bị reviewer chặn, tốn 2 PR vá.

### B8. Verify gate — một lệnh, mọi lời hứa

**Cách làm.** `node tool/verify/run.mjs` = codegen freshness (build_runner) +
`gen_tokens --check` + spec freshness + `dart analyze` + `flutter test`. CI (ubuntu)
chạy đúng lệnh này mỗi PR/push. Có mode `--quick` (khi iterate) và `--docs`.

**Nguyên nhân.** Một gate duy nhất nghĩa là **không có đường vòng**: agent hay người đều
phải qua cùng một cửa; không có chuyện "chạy thiếu check X". Wiring của gate còn được
tự-test (`design_sync_gate_test`) để không ai gỡ `--check` ra khỏi gate một cách âm thầm.

**Điểm cần chú ý.** Gate phải **rẻ** (vài chục giây quick mode) — gate đắt sẽ bị né.

### B9. design-sync: giữ kit hai đầu khớp nhau

**Cách làm.** Hooks `.githooks/pre-push` + `post-merge` đẩy thay đổi kit trong repo lên
Claude Design (push một chiều repo → remote); chạy headless bằng
`MSYS_NO_PATHCONV=1 claude -p "/design-sync"`. Log chi tiết ở `.design-sync/NOTES.md`;
quy trình đầy đủ ở `docs/design/design-sync-workflow.md`.

**Điểm cần chú ý.** Session agent không có design-auth TTY phải prefix
`MEMOX_SKIP_DESIGN_SYNC=1` cho `git push/pull` trên main, nếu không nested CLI treo.
`MSYS_NO_PATHCONV=1` là bắt buộc trên Git Bash/Windows (không có nó, `/design-sync`
bị rewrite thành đường dẫn Windows).

### B10. DT: lật seam sang Drift — bằng chứng seam đúng

**Cách làm.** Chuỗi DT.0→DT.7: schema contract (doc trước code) → persistence-safety
policy (+ test skeleton) → tables → migrations → DAOs → repositories + mappers → DI flip
→ seeder → service adapters. Screens **không đổi**.

**Nguyên nhân đưa vào tài liệu này.** Nó chứng minh giá trị của B5: convert UI đúng cách
thì backend đến sau **không chạm** vào UI. Ai nghi ngờ chi phí của seam/fakes, đây là
số liệu: flip toàn bộ 21 màn sang DB thật = 1 PR, 0 dòng screen thay đổi.

---

## PHẦN C — VÌ SAO LẦN NÀY TỐT HƠN: 5 NGUYÊN NHÂN GỐC

1. **Đảo chiều quy trình.** Lần 1: code → soi kit → vá. Lần 2: kit → spec → code.
   Mọi thứ khác (STOP-on-drift, component trùng tên, state-first test) đều là hệ quả
   của cú đảo chiều này.

2. **Cơ giới hóa nguồn chân lý.** Token: máy sinh + `--check`. Spec: máy xuất +
   source-hash. State: khai báo trong JSX → bắt buộc test. Ở lần 1 các liên kết này
   là lời hứa/quy ước; lần 2 chúng là **code chạy được và gate chặn merge**.

3. **Đơn vị công việc = đơn vị cấu trúc kit.** `_features/<screen>/` ⇔ 1 prompt ⇔
   1 branch ⇔ 1 PR ⇔ 1 nhóm ledger rows. Không còn "convert đợt lớn rồi rà lại".

4. **Nền móng theo tầng, đúng thứ tự.** Token → theme → primitives → composites →
   gallery gate → rồi mới màn hình. Lần 1 màn hình tự vẽ nhiều khối (dashboard 637 dòng
   với `_DashboardNote` private); lần 2 màn chỉ compose khối đã được gate.

5. **Trung thực có cấu trúc với cái không làm được.** Gap phải được *ghi ra* (ledger
   notes), lệch phải *dừng lại* (STOP), môi trường không cho phép phải *block có hồ sơ*
   (V.1 golden). Sự trung thực này chính là thứ giữ cho "parity" còn ý nghĩa — một bộ
   test xanh trên nền gap im lặng là parity giả.

*(Ghi nhận công bằng: phần lớn tooling — spec exporter, shots, parity contracts — do
chính lần 1 xây. Lần 2 thắng nhờ đổi **vị trí** của chúng trong quy trình: từ hậu kiểm
sang tiền đề.)*

---

## PHẦN D — BẪY ĐÃ GẶP & CÁCH NÉ (trả học phí rồi, đừng trả lại)

| Bẫy | Triệu chứng | Cách né |
|---|---|---|
| Tin `_ds_manifest.json` | 4 nhóm token bị bỏ sót | Parse CSS trực tiếp; manifest chỉ tham khảo |
| CRLF trên Windows | `gen_tokens --check` false-positive; `.wasm` hỏng | `.gitattributes`: `eol=lf` cho generated/tool, `binary` cho asset |
| Kit tách node / FE gộp node | states.json lệch giữa hai phía | states theo **kit derivation**; FE composition verify bằng test riêng |
| Mock copy trong JSX | Chữ kit lọt vào app | Mọi string từ ARB; spec exporter in cảnh báo "MOCK COPY" |
| State kit không drive được trên FE | `error` state với Result-based notifier không bao giờ throw | Document gap trong ledger, đừng "chế" cho testable |
| Ledger thiếu trong commit impl | Reviewer chặn, tốn PR vá | Ledger row là một mục trong Definition of Done |
| Pixel golden đa nền tảng | Golden tạo trên Windows đỏ trên Linux CI | Golden font-dependent chỉ generate trên nền tảng chuẩn (CI); local dùng gate cấu trúc (gallery + state test) |
| Divergence "ghi sổ rồi thôi" | intent-ledger thành nghĩa địa | STOP-on-drift: sửa kit hoặc chờ người quyết, ngay lúc convert |
| `dart:ffi`/`dart:io` lọt vào web | `flutter build web` gãy vì import `drift/native` | Mọi executor (kể cả `.memory()` cho test) sau conditional import |

---

## PHẦN D.5 — PROPS PARITY: GÁC TRỤC API BẰNG `.d.ts` (bổ sung sau convert)

> Sau khi convert xong, ta thêm một trục gate nữa: **contract props typed**. Mỗi
> component kit có một `<Component>.d.ts` (interface props), và một checker so nó
> với **constructor widget Flutter**. Trước đó "props có khớp không" chỉ là
> đọc-JSX-nhớ-đủ-không; giờ nó là **gate chặn merge**. Kế hoạch đầy đủ:
> [`docs/agent/props-parity/WBS.md`](../agent/props-parity/WBS.md); công cụ:
> [`tool/parity/README.md`](../../tool/parity/README.md).

**Cách làm.** 3 phase: **P0** dựng checker (`props_check.mjs`) + config alias
(`props_map.json`) một lần, **hiệu chuẩn trên 15 shared component đã có sẵn cả
`.d.ts` lẫn widget** (chứng minh checker đúng trước khi mass-author); **P1** author
`.d.ts` cho 68 component còn lại theo từng feature (1 feature = 1 firing = 1 PR),
mỗi cái chạy checker rồi resync widget HOẶC ghi exception; **P2** lật checker sang
`--strict` **blocking** trong verify gate + test wiring-guard + doc/ledger.

**Nguyên nhân / Giải thích.** `.d.ts` đóng ba thứ mà JSX để mở: (1) **không gian
giá trị enum** (`variant?: 'a'|'b'`), (2) **optional/required/default**, (3)
**ý định từng prop** (JSDoc). Với leaf stateless, đó gần như toàn bộ hợp đồng.
Nhưng nó **chỉ gác trục API** — tên prop, enum, optionality — **KHÔNG** gác thị
giác (padding/màu/layout/state); đó vẫn là việc của DOM spec. Nói rõ giới hạn này
để không ai kỳ vọng sai.

**Kết quả.** 83 component (68 author + 15 shared) · **0 undeclared drift** ·
`props_check --strict` xanh. Đáng chú ý: **không phải resync widget Flutter nào** —
các widget viết tay trong lần-2 vốn đã khớp contract (chỉ khác ở các idiom/fixture
được ghi exception). Đây là bằng chứng định lượng cho luận điểm "hỏi kit trước rồi
mới viết code": FE sinh-từ-kit khớp API kit gần như tuyệt đối.

**Điểm cần chú ý (bài học riêng của trục props):**
- **Exception phải typed + đóng, không phải sổ nợ.** Reason nằm trong tập đóng
  (`web-only`, `enum-base-expansion`, `flutter-idiom`, `deferred-screen`,
  `flutter-only`, `fixture-parameterized`, `flutter-helper`); checker **fail nếu
  reason lạ hoặc thiếu `note`** — chính là cách né lại vết xe `intent-ledger` lần 1.
- **Fixture tĩnh là một lớp lớn.** Nhiều component kit hardcode nội dung mẫu (친구,
  "Linh Tran") + node id để generator parity thấy DOM thật; Flutter tham số hoá
  chúng → `fixture-parameterized`. Không phải drift.
- **Idiom nền tảng ≠ drift.** `disabled`→`onPressed:null`, string-state→`bool`,
  object `g`→field rời, controller/onChanged của TextField, dialog→`show()` helper
  / hàm tự do → `flutter-idiom` / `flutter-helper`.
- **Trùng tên khác dir** (`game-recall/TermCard` vs `review/TermCard`): checker map
  theo **feature dir**, không chỉ tên class.
- **Enum forwarded qua file khác** (ResultHero.tone → MxIconTileTone) suýt lọt —
  parser chỉ đọc enum cùng file. Phải index enum toàn `lib/` mới bắt được. Đây là
  false-negative điển hình chỉ lộ ra khi lật gate sang blocking.
- **Bug parser đã trả học phí:** tách statement `.d.ts` phải tôn trọng `;` lồng
  trong `{}` (object type) và không nhầm `>` trong `=>`; keyword `required` chỉ là
  modifier đầu token, không phải field tên `required`.

---

## PHẦN E — CHECKLIST RÚT GỌN CHO DỰ ÁN KIT→FLUTTER SAU

**Thiết kế kit (trước khi viết dòng Flutter nào):**
- [ ] Mọi giá trị thị giác là token có tên vai trò; JSX không hex/px trần.
- [ ] 3 tầng một chiều: tokens → shared components (+`.d.ts`) → screens.
- [ ] Mỗi màn 1 thư mục: `<Screen>.jsx` (header ghi states) + `components/` local.
- [ ] Kit render được → xuất shots per state per theme + DOM spec có tọa độ/token/diff.

**Hạ tầng đồng bộ:**
- [ ] Token generator + `--check` trong một verify gate duy nhất, chạy cả CI.
- [ ] Spec/shots có freshness hash trong gate.
- [ ] Seam DI + fakes + harness trước màn hình đầu tiên; provider chưa có impl thì throw.

**Convert:**
- [ ] Thứ tự: theme → primitives → composites → gallery gate → screens.
- [ ] Mỗi màn: 1 prompt (inputs đích danh) = 1 branch = 1 PR; component local trùng tên kit.
- [ ] Enumerate states từ JSX; test mọi state light+dark; gap ghi lý do.
- [ ] STOP khi FE buộc phải lệch cấu trúc kit — sửa kit, đừng vá Dart.
- [ ] Ledger row + gaps/notes ngay trong commit implement.
- [ ] A11y đúng idiom nền tảng đích, không port shortcut web.

**Sau convert:**
- [ ] Backend lật qua seam, chứng minh 0 dòng screen đổi.
- [ ] Sweep verification: invariants domain, integration data, E2E qua provider thật,
      a11y, responsive — mỗi thứ một task có ledger.
- [ ] **Props parity**: mỗi component kit có `.d.ts` (interface props); checker so
      với constructor Flutter, `--strict` blocking trong gate; lệch có chủ đích là
      exception **typed + reason đóng** (không phải sổ nợ). Gác trục API, không gác
      thị giác. Xem PHẦN D.5.
