# Kit → Flutter conversion prompt — **theme**

> PROMPT ID: `kit-to-flutter/theme` · screen `theme` · feature `personalization` · Template **A** (review-style, MxCard identity) · 3 kit states (light / dark / accent-size).
> FE file: `lib/presentation/features/personalization/screens/theme_screen.dart`.
> SELF-CONTAINED. Đọc hết file này rồi thực thi tuần tự. Không cần đọc prompt nào khác.
> Nhiệm vụ: đóng **parity gate** cho màn `theme` (KHÔNG vẽ lại UI — UI đã có sẵn; việc ở đây là **curate contract + align ValueKey identity + viết 1 test parity** theo Template A). Nếu gặp DRIFT hoặc DIVERGENCE cần người quyết → DỪNG, báo, chờ.

---

## 1. Baseline

```bash
git checkout main
git pull --ff-only
git checkout -b claude/kit-to-flutter-theme
```

Không bắt đầu khi working tree bẩn. Xác nhận `node tool/verify/run.mjs --quick` xanh trước khi sửa.

## 2. Required reading (chỉ đọc đúng các file này)

Universal (theo `CLAUDE.md`): `docs/_generated/repo-map.md`, `docs/_generated/where-is.md`,
`docs/business/index.md`, `docs/business/glossary.md`, `docs/contracts/error-contract.md`,
`docs/contracts/types-catalog.md`, `docs/contracts/code-style.md`.

Screen-specific — CHỈ đọc đúng các file này:
- `docs/design/MemoX Design System/ui_kits/memox-app/specs/theme.md` — token-resolved DOM theo từng state (base `light` + diff `dark`, `accent size`).
- `tool/parity/contracts/theme.gen.json` — 6 keyed node (key + component + variant). **KHÔNG sửa** (generated).
- `tool/parity/contracts/theme.slots.skeleton.json` — slot role đề xuất (superset) → curate thành `theme.slots.json`.
- `tool/parity/contracts/theme.states.skeleton.json` — node membership theo state (superset) → curate thành `theme.states.json`.
- `lib/presentation/features/personalization/screens/theme_screen.dart` — FE hiện tại.
- `lib/presentation/features/personalization/viewmodels/personalization_notifier.dart` + `lib/core/theme/theme_prefs.dart` — provider + `ThemePrefs` (mode/accent/fontScale) để seed state trong test.
- Reference TEST để COPY (**Template A** — mẫu đã chọn): `test/presentation/features/study/review_parity_test.dart`.
- Reference TEST đối chiếu (Template B — chỉ để hiểu vì sao KHÔNG chọn): `test/presentation/features/engagement/dashboard_states_test.dart`.
- Curated mẫu để bắt chước format: `tool/parity/contracts/review.slots.json`, `review.states.json`, `dashboard.slots.json`, `dashboard.states.json`.
- Contract nền: `docs/ui-ux/ui-ux-contract.md`, `docs/contracts/code-style.md`, `docs/business/glossary.md`.

**Drift check trước khi code:** theme là màn personalization (`20-theme.md`): mode + accent + font size với live preview, apply app-wide immediately (BR-3) và persist. FE khớp spec ở hành vi (3 control + 1 preview). Nếu FE mâu thuẫn spec ở hành vi → DỪNG, báo theo mẫu `DRIFT DETECTED` trong `CLAUDE.md`. Ở đây spec = "mode/accent/size + live preview" và FE khớp → OK, tiếp tục.

## 3. Template đã chọn: **A (review-style)** — vì sao

`theme.gen.json` có node `mx-node:theme/preview` = `MxCard`, và node đó **đã được key bằng `ValueKey` trong FE** (`theme_screen.dart:115`, class `_Preview` → `MxCard`). Có MxCard keyed ⇒ dùng Template A: với mỗi state, assert từng MxCard keyed → identity + variant + từng slot MxTextRole render (present) / không render (absent). Copy nguyên `review_parity_test.dart`, đổi `review` → `theme` và đổi cách seed/reach state (mục 6).

> KHÔNG dùng Template B (dashboard-composition): theme có đúng 1 MxCard keyed (`theme/preview`) luôn render ⇒ gate identity/variant của card đó là đúng khuôn A. Body còn lại là section-head (text) + control (segmented/chip) — không phải list/overlay nhiều state như library/dashboard.

## 4. Gate-able node (keyed trong FE — grep xác nhận)

Grep `mx-node:theme/` trong `lib/presentation/features/personalization/screens/theme_screen.dart` cho tập literal keyed sau:

| key | component (gen) | variant (gen) | FE hiện tại | citation |
| --- | --- | --- | --- | --- |
| `mx-node:theme/screen` | MxScaffold | null | ✓ MxScaffold | `theme_screen.dart:29` |
| `mx-node:theme/appbar` | MxAppBar | null | ✓ MxAppBar (`title: l10n.drawerTheme`) | `theme_screen.dart:31` |
| `mx-node:theme/mode-head` | MxSectionHeader | null | ⚠ `MxText.title(l10n.themeModeLabel)` (divergence — mục 5) | `theme_screen.dart:40` |
| `mx-node:theme/accent-head` | MxSectionHeader | null | ⚠ `MxText.title(l10n.themeAccentLabel)` (divergence — mục 5) | `theme_screen.dart:68` |
| `mx-node:theme/size-head` | MxSectionHeader | null | ⚠ `MxText.title(l10n.themeFontLabel)` (divergence — mục 5) | `theme_screen.dart:88` |
| `mx-node:theme/preview` | MxCard | **elevated** | ⚠ `MxCard(variant: flat)` (VARIANT MISMATCH — mục 5) — **gate node chính của Template A** | `theme_screen.dart:115` + `:144` |

**Chỉ `mx-node:theme/preview` là MxCard** → là node duy nhất Template A vòng qua (giống review chỉ vòng MxCard). Các node khác (screen/appbar/*-head) là identity đã có key nhưng không phải MxCard → test A không assert variant cho chúng ở vòng MxCard; chúng được phủ ở tầng state-membership (`theme.states.json`).

### Node trong gen.json/kit NHƯNG chưa key literal trong FE → identity-rollout gap (ghi nhận, không ép)

Kit có nhiều node control keyed literal mà FE render bằng key ĐỘNG hoặc không key:
- `mx-node:theme/back` — appbar back; FE để `MxAppBar` tự render (không key literal riêng). Gap.
- `mx-node:theme/mode-control` / `mx-node:theme/size-control` — kit là `segmented`; FE render `MxSegmentedControl` **không** key literal `mx-node:...` (`theme_screen.dart:43`, `:91`). Gap (widget đúng, identity chưa rollout).
- `mx-node:theme/accent-0..5` — kit là 6 nút màu keyed literal; FE render `MxChip` với key ĐỘNG `Key('accent-${accent.name}')` (`theme_screen.dart:130`) và **chỉ 3 chip** (brand/warm/cool) chứ không 6. Gap (dynamic key + số lượng khác — divergence, mục 5).
- `mx-node:theme/mode`, `mx-node:theme/accent`, `mx-node:theme/size` — kit là container `div` bọc head+control; FE không có 1 wrapper keyed literal (dùng `MxText.title` + control trực tiếp trong `ListView`). Gap.

Liệt kê nguyên các gap này trong **final report** (mục "Identity-rollout gap"). KHÔNG rollout key mới cho control/accent-swatch trong task này trừ khi bạn cũng thêm hành vi thật — đây là task style-parity, không phải feature.

## 5. Divergence → `tool/parity/intent-ledger.json` (KHÔNG ép về kit)

Ghi các mục sau vào `tool/parity/intent-ledger.json` (append, giữ format hiện có; nếu file chưa có mục theme → tạo entry theo cấu trúc các screen khác). **Không** sửa FE để khớp kit ở các điểm này — đây là chệch có chủ đích. Mỗi mục: `screen · node · kit-nói-gì · FE-làm-gì · lý do giữ`.

1. **VARIANT MISMATCH — `mx-node:theme/preview`**: kit variant `elevated` (`theme.gen.json` default), FE `MxCard(variant: MxCardVariant.flat)` (`theme_screen.dart:144`). Lý do: preview card cố ý PHẲNG để không cạnh tranh thị giác với card chính (nó chỉ là ô demo bên trong list). Ledger reason: `"fe preview = flat (demo surface, not an elevated primary card), kit = elevated"`.
   > ⚠ **BẮT BUỘC**: nếu KHÔNG ghi ledger mục này, Template A sẽ assert `variant == 'elevated'` cho `theme/preview` và test FAIL vì FE là `flat`. Test A phải đọc ledger để cho phép variant-override (giống cách review/player test skip variant khi có ledger entry). Xem mục 7 bước 5.
2. **CONTENT divergence — slot `theme/preview`**: kit mock preview là mẫu học `학교` / `school` / nút `Study now` (label `PREVIEW`). FE render `MxText.title(l10n.themePreview)` + `MxText.body(l10n.themePreviewBody)` + `MxButton(label: title)` + icon lửa (`theme_screen.dart:144-164`). → curate `theme.slots.json` theo **FE truth** (title `titleMedium` bind `l10n:themePreview`, body `bodyMedium` bind `l10n:themePreviewBody`), **KHÔNG** copy mock `학교`/`school`/`Study now` vào slots hay test. Đây là slot binding thực của FE, không phải drift — ghi 1 dòng note trong `$curated` của slots.json, cũng append 1 mục ledger content. Ledger reason: `"fe preview content = l10n themePreview/themePreviewBody, kit = 학교/school sample copy"`.
3. **Section-head component — `theme/mode-head` / `theme/accent-head` / `theme/size-head`**: kit `MxSectionHeader`, FE `MxText.title(...)` (`theme_screen.dart:38,66,86`). Lý do: FE dùng `MxText.title` đơn giản cho head 1 dòng (không có trailing action như MxSectionHeader). → INTENDED. Ledger reason: `"fe section heads = MxText.title (single-line label), kit = MxSectionHeader"`. (Template A chỉ vòng MxCard ⇒ không assert component cho các head này; ledger để tài liệu hoá, không ảnh hưởng gate.)
4. **Accent swatches — số lượng & key**: kit 6 nút màu keyed literal `theme/accent-0..5`; FE 3 `MxChip` (brand/warm/cool) key động `accent-<name>` (`theme_screen.dart:71-84,130`). Lý do: v1 chỉ phơi 3 accent choice (`AccentChoice.brand/warm/cool`), không 6 palette. → INTENDED. Ledger reason: `"fe accent = 3 MxChip (AccentChoice brand/warm/cool, dynamic key), kit = 6 literal swatches"`.
5. **Mode/size control — segmented không key literal**: kit `segmented` keyed `theme/mode-control` + `theme/size-control`; FE `MxSegmentedControl` không key literal. Lý do: control render qua widget chung, chưa rollout `mx-node` key. → GAP (không phải bug). Ledger reason: `"fe mode/size = MxSegmentedControl without literal mx-node key (identity not rolled out)"`.

Sau khi ghi ledger, các divergence này KHÔNG được làm fail parity test (test A chỉ assert identity/variant/slot cho MxCard = `theme/preview`, với variant-override từ ledger).

## 6. State-map (kit state → cách drive FE tới đúng node-set)

FE là 1 `ConsumerWidget` đọc `ref.watch(personalizationProvider).value ?? const ThemePrefs()` (`theme_screen.dart:26-27`). 3 kit state (`light`, `dark`, `accent size`) **chỉ đổi giá trị `ThemePrefs`** (mode/accent/fontScale) — chúng REMAP token màu (light↔dark), đổi accent active, đổi font scale. **Node-set/identity KHÔNG đổi** giữa các state: `theme/preview` (MxCard) luôn render, các head luôn render, control luôn render. Đây là điểm mấu chốt: **theme's states KHÔNG node-distinct**.

| kit state | FE reach được? | Cách reach | Node-set FE | phân biệt được ở tầng identity? |
| --- | --- | --- | --- | --- |
| `light` | ✓ | pump `personalizationProvider` override = `ThemePrefs(mode: light)` (hoặc default) | `theme/preview` + heads + controls | — (base) |
| `dark` | ⚠ coverage gap | override `ThemePrefs(mode: dark)` → chỉ REMAP token màu; **cùng node-set** với light, `theme/preview` vẫn present. Không đổi identity/variant. | (= light) | ✗ (token remap only) |
| `accent-size` | ⚠ coverage gap | override `ThemePrefs(accent: warm, fontScale: large)` → đổi accent active + font scale; **cùng node-set**, `theme/preview` vẫn present, chỉ nội dung scale to hơn. | (= light) | ✗ (value change only) |

**Kết luận:** cả 3 state đều render **cùng node-set** — `theme/preview` present ở tất cả. Theme KHÔNG có state phân biệt được ở tầng node identity (khác review `browsing`/`end`, khác library `loaded`/`empty`/`error`). Vì vậy:

- **Gate được:** `theme/preview` present ở mọi state (identity + variant-flat-via-ledger + 2 slot title/body render). Đây là gate identity ổn định.
- `dark` + `accent-size` = **coverage gap ở tầng node-set** (chúng là token/value remap, không đổi membership). Vẫn drive được (pump với `ThemePrefs` tương ứng) để chứng minh `theme/preview` present ở cả 3, nhưng KHÔNG assert khác biệt node giữa chúng — vì không có.

**Quyết định curate `theme.states.json`:** đặt 3 state key theo cái FE reach được, tất cả cùng chứa `theme/preview` (giống review giữ `browsing` với `review/term`+`review/meaning`). Vì node-set giống nhau, `$curated` note phải nêu RÕ: theme states không node-distinct — chúng đổi ThemePrefs (token/accent/size), preview present ở cả ba; gate ở đây là "preview MxCard identity ổn định qua mọi ThemePrefs", không phải state-composition.

```jsonc
{
  "light":       ["mx-node:theme/preview"],
  "dark":        ["mx-node:theme/preview"],
  "accent-size": ["mx-node:theme/preview"]
}
```

- Chrome (`screen`/`appbar`) và các head (`mode-head`/`accent-head`/`size-head`) KHÔNG liệt kê — theo mẫu review/dashboard chỉ giữ BODY MxCard-scope node để test Template A vòng qua.
- 3 state giữ để đủ bộ (documented) nhưng **không node-distinct** — pump 3 ThemePrefs khác nhau, assert `theme/preview` present ở cả ba (chứng minh identity ổn định qua remap). Ghi rõ coverage-gap note trong `$curated`.

> Lưu ý Template A vòng `if (node.component != 'MxCard') continue;` ⇒ test chỉ thực chất assert `theme/preview`. Vì 3 state cùng chứa nó, test = "preview present + variant(flat via ledger) + slots title/body ở mọi ThemePrefs". Đó là lý do phải note coverage rõ: theme không có state absent-node để bắt THỪA/THIẾU.

## 7. Workflow (theo thứ tự, mỗi bước một layer)

1. **Curate `tool/parity/contracts/theme.slots.json`** từ `theme.slots.skeleton.json`:
   - `mx-node:theme/preview`: `{ "name": "title", "role": "titleMedium", "bind": "l10n:themePreview" }`, `{ "name": "body", "role": "bodyMedium", "bind": "l10n:themePreviewBody" }` — **FE truth** (từ `theme_screen.dart:149,151` `MxText.title(title)` + `MxText.body(body)`; title=`l10n.themePreview`, body=`l10n.themePreviewBody` truyền vào `_Preview`). KHÔNG copy skeleton `학교`/`school`/`Study now`/`PREVIEW` (đó là mock copy kit).
   - Bỏ khỏi slots các node control/head không phải MxCard (test A không vòng qua). Giữ tối giản như `review.slots.json` (chỉ slot của MxCard được gate).
   - Thêm `$curated` note: giải thích preview content = l10n themePreview/themePreviewBody (FE truth, KHÔNG phải kit sample), và variant flat (không elevated) — cross-ref intent-ledger.
2. **Curate `tool/parity/contracts/theme.states.json`** từ skeleton theo bảng mục 6: 3 state `light`/`dark`/`accent-size`, mỗi state chỉ `["mx-node:theme/preview"]`, bỏ chrome + heads. `$curated` note nêu rõ: theme states KHÔNG node-distinct (token/accent/size remap, preview present ở cả ba); gate là identity ổn định của preview MxCard qua mọi ThemePrefs; không có node absent để bắt THỪA/THIẾU ⇒ coverage-gap tự nhiên của màn setting.
3. **Align FE** `theme_screen.dart` từ `Mx*` + token, mỗi node đã key có `ValueKey('mx-node:...')`:
   - Xác nhận 6 key literal hiện có đúng chính tả (grep đã confirm: screen/appbar/mode-head/accent-head/size-head/preview). KHÔNG hoist node-literal sau dynamic key. KHÔNG đổi `MxChip` key động `accent-<name>` thành literal (đó là identity-rollout, ngoài scope).
   - `_Preview` giữ nguyên `MxCard(variant: MxCardVariant.flat)` — divergence đã vào ledger, KHÔNG đổi thành elevated.
   - KHÔNG thêm node/key mới cho control/accent-swatch (ngoài scope style-parity). KHÔNG hardcode màu/spacing/text-style.
4. **l10n**: các key `drawerTheme`, `themeModeLabel`, `themeModeSystem/Light/Dark`, `themeAccentLabel`, `themeAccentBrand/Warm/Cool`, `themeFontLabel`, `themeFontSmall/Medium/Large`, `themePreview`, `themePreviewBody` — verify **đã có cả** `app_en.arb` và `app_vi.arb` trước khi dùng trong slots/test. Nếu thiếu bên nào → thêm vào **cả hai** ARB cùng lúc rồi regen l10n (`node tool/verify/run.mjs` regen). Không copy mock copy từ kit (`학교`, `school`, `Study now`, `PREVIEW`, `Color mode`, `Accent color`, `Text size`…) vào app/test — luôn từ ARB.
5. **Viết test** `test/presentation/features/personalization/theme_parity_test.dart` — COPY `review_parity_test.dart`, đổi:
   - đường dẫn contract `review.*` → `theme.*`;
   - import + host dựng `ThemeScreen()` (không cần deckId; chỉ cần override `personalizationProvider`);
   - **seed state qua `personalizationProvider`**: override provider trả `AsyncData(ThemePrefs(...))` cho từng state — `light`: `ThemePrefs()` (default) hoặc `mode: ThemeMode.light`; `dark`: `ThemePrefs(mode: ThemeMode.dark)`; `accent-size`: `ThemePrefs(accent: AccentChoice.warm, fontScale: FontScale.large)`. `_stateSeed = { 'light': ThemePrefs(...), 'dark': ..., 'accent-size': ... }`.
   - **VARIANT-OVERRIDE**: test phải đọc `intent-ledger.json` (như review/player) và cho `theme/preview` skip/override variant assert (FE `flat` vs gen `elevated`). Nếu `review_parity_test.dart` đã có cơ chế đọc ledger → tái dùng; nếu chưa, thêm: khi node có ledger entry variant-mismatch → assert theo FE variant (`flat`), không theo gen (`elevated`). Comment rõ.
   - pump: `MxScaffold`/`ListView` không async-spin nặng, nhưng theo mẫu review dùng vòng `for` pump 50ms thay `pumpAndSettle` để an toàn (preview + provider settle). Comment lý do.
   - assert slot: `theme/preview` render `MxText` role `titleMedium` (title) + `bodyMedium` (body) present ở cả 3 state.
   - Header test giải thích rõ: 3 state KHÔNG node-distinct (token/accent/size remap), gate = preview identity ổn định (giống review_parity_test giải thích state không map).
6. **Xoá 2 skeleton**: `theme.slots.skeleton.json` + `theme.states.skeleton.json` sau khi đã curate ra bản chính (skeleton là AUTO-PROPOSED, không ship — theo ghi chú `$skeleton` trong file; giống review/dashboard không còn skeleton).
7. **Cập nhật queue**: đổi ô theme `[ ]` → `[x]` trong `docs/agent/kit-to-flutter/README.md` cùng commit impl hoặc trace.

## 8. Hard rules (vi phạm = task fail)

- **Token-only**: không hardcode màu, radius, spacing, text style, duration, chuỗi user-facing. Dùng `Mx*` widget + theme token + `MxSpacing`.
- **Không node-literal hoist sau dynamic key**: mỗi `ValueKey('mx-node:...')` phải là `const` gắn đúng node tĩnh; không sinh key động theo index/state. Giữ `MxChip` key động `accent-<name>` nguyên (không ép literal).
- **Divergence → intent-ledger**, không ép FE về kit: preview variant `flat` (không elevated), preview content l10n (không sample), heads = MxText.title, accent = 3 MxChip, mode/size = MxSegmentedControl chưa key.
- **VARIANT phải qua ledger**: nếu không ghi ledger `theme/preview` flat, test A fail variant → BẮT BUỘC ghi ledger + test đọc ledger.
- **CONTENT theo FE truth**: slots bind `l10n:themePreview`/`themePreviewBody`, KHÔNG copy mock `학교`/`school`/`Study now` từ kit.
- **l10n cả hai ARB**: mọi chuỗi mới (nếu có) vào `app_en.arb` **và** `app_vi.arb` cùng commit; regen l10n; không sửa `lib/l10n/generated/**` tay.
- Không sửa file generated (`*.g.dart`, `*.freezed.dart`, `theme.gen.json`, `docs/_generated/**`, `lib/l10n/generated/**`).
- Không thêm dependency mới (Stop & ask nếu cần).
- Không ship skeleton làm curated; phải trim rồi xoá skeleton.
- Không đổi hành vi personalization (mode/accent/size apply immediately + persist, BR-3).
- Doc-code parity: nếu chạm hành vi user-visible / route → update doc tương ứng cùng commit (task này thuần style-parity ⇒ nhiều khả năng `WBS update: not needed` + không đổi business doc; xác nhận rồi ghi rõ).

## 9. Verification

```bash
node tool/verify/run.mjs --full
```

Phải PASS (viết pass-marker cho pre-commit hook). Trong đó có test parity mới + freshness check của specs. Nếu `--full` fail hoặc bị skip → KHÔNG được báo done. Trong lúc dev có thể `--quick` (không marker). Chạy riêng test mới để chắc: `flutter test test/presentation/features/personalization/theme_parity_test.dart`.

Sau khi verify PASS, TRƯỚC final report: fan-out song song `code-reviewer` (review diff working-tree — cho nó chạy `git add -N .` rồi `git diff`, không commit trước) + `docs-drift-detector`. Gộp findings vào mục "Subagent review", fix blocker trước khi kết.

## 10. Commit (2 commit + WBS)

**Commit 1** — impl: contracts curate (`theme.slots.json`, `theme.states.json`) + xoá 2 skeleton + FE align (nếu chạm) + test + (ARB nếu đổi) + intent-ledger.
```
feat(parity): style-parity — theme — Template A, preview MxCard identity (flat via ledger)

- curate tool/parity/contracts/theme.slots.json (preview title/body = l10n FE truth)
- curate tool/parity/contracts/theme.states.json (3 states, non-node-distinct — preview present in all)
- add test/presentation/features/personalization/theme_parity_test.dart (Template A, copy review_parity_test)
- intent-ledger: preview variant flat vs elevated, content l10n vs sample, heads/accent/segmented divergences
- remove consumed skeletons (theme.slots.skeleton.json, theme.states.skeleton.json)

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>
```

**Commit 2** — WBS trace + queue: append 1 dòng vào Commit Traceability Log (§10 `docs/project-management/wbs.md`), newest first, + đổi ô theme `[x]` trong `docs/agent/kit-to-flutter/README.md`.
```
<8-char hash> · 2026-07-01 · <WBS IDs> · style-parity theme (Template A; preview identity gated, dark/accent-size non-node-distinct, variant+content → intent-ledger)
```

Nếu WBS không bị ảnh hưởng về task breakdown, report ghi: `WBS update: not needed — <reason>` (nhưng Commit Traceability Log vẫn append nếu advance WP).

## 11. Final report format

```
## theme — kit→flutter DONE
- Template: A (review-style, MxCard identity per-state)
- Gate-able nodes (keyed): screen, appbar, mode-head, accent-head, size-head, preview(MxCard flat-via-ledger)  [6]  — only preview is MxCard (Template A gate node)
- Contracts: theme.slots.json + theme.states.json curated; 2 skeleton deleted
- States: light / dark / accent-size — all render SAME node-set (preview present in all). NON-node-distinct: dark = token remap, accent-size = value change. Coverage gap: dark + accent-size not node-distinguishable (setting screen, no absent-node)
- Divergences → intent-ledger: preview VARIANT (flat vs elevated), preview CONTENT (l10n themePreview/Body vs 학교/school sample), heads (MxText.title vs MxSectionHeader), accent (3 MxChip dynamic-key vs 6 literal swatches), mode/size (MxSegmentedControl unkeyed vs segmented)
- Identity-rollout gap (chưa key literal trong FE): theme/back, theme/mode-control, theme/size-control, theme/accent-0..5, theme/mode, theme/accent, theme/size
- l10n: drawerTheme/themeModeLabel/.../themePreview/themePreviewBody verified in app_en.arb + app_vi.arb [no new keys | new keys: ...]
- Docs updated: <list | none — style-parity only>
- WBS update: <line appended | not needed — reason>
- Verify: node tool/verify/run.mjs --full → PASS
- Subagent review: <blockers fixed | minor findings ...>
```
