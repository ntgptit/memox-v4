# M3 Compliance Audit — MemoX Design System vs Material 3

> **Mục đích.** Tài liệu chuẩn đối chiếu **Material 3** cho design system MemoX —
> làm cơ sở QUYẾT ĐỊNH trước khi fix code (per yêu cầu 2026-07-06). Bổ trợ cho bản
> UI-UX Audit tổng ([audit/UI-UX Audit.html](MemoX%20Design%20System/audit/UI-UX%20Audit.html),
> vốn trộn M3 + HIG + foundations); tài liệu này tách riêng trục M3, đo **giá trị
> thật** từ `components.css` / `tokens/*` (trích dẫn dòng), phán theo 3 mức:
>
> - **PASS** — đạt spec M3.
> - **CUSTOM-OK** — lệch spec nhưng là bản sắc DS có chủ đích, M3 cho phép
>   (M3 là hệ *tuỳ biến được*: shape/type scale riêng hợp lệ miễn giữ nguyên tắc).
> - **FAIL** — vi phạm nguyên tắc cứng (accessibility/usability) → phải fix.
>
> Mỗi FAIL có mã `M3-x`, map về finding audit gốc (G-x) nếu trùng. Các lệch cần
> người quyết có mã `Đ-M3-x` ở §10.

**Trạng thái đã fix trước audit này:** G1 contrast (PR #213) — các cặp màu dưới
đây đã đạt AA, không liệt lại.

---

## 1. Color system

| Hạng mục | M3 | MemoX (đo) | Verdict |
|---|---|---|---|
| Role model (primary/on-primary/container…) | bắt buộc cặp role | token `--memox-<role>` / `on-<role>` / `<role>-soft` / `on-<role>-soft` — map 1:1 vào `ColorScheme` (app_theme.dart, `useMaterial3: true`) | **PASS** |
| Contrast AA | 4.5:1 / 3:1 | đã đạt sau G1 (đo script, PR #213) | **PASS** |
| Dynamic color (Android 12+) | optional | không dùng — palette thương hiệu cố định | **CUSTOM-OK** (ghi nhận, không bắt buộc) |
| Tonal elevation dark | surface sáng dần theo elevation | dark có bậc `surface-sunken → bg → muted → surface → raised` theo lightness | **PASS** (cách đạt khác — bằng token bậc, không phải tint overlay) |

## 2. Typography

| Hạng mục | M3 | MemoX (đo) | Verdict |
|---|---|---|---|
| Type scale | 15 role (display→label); giá trị tuỳ biến được | scale riêng 12/13/15/17/20/24/30/38/48 (`tokens/typography.css`) | **CUSTOM-OK** |
| Label floor | label-small 11sp *được phép* nhưng phải 4.5:1 | **11px hardcode** tại `.bottom-nav__item` (components.css:525, kèm idle màu tertiary) và `.badge` (:605) — không qua token | **FAIL → M3-2** (= G7) |
| Font | tuỳ biến | Plus Jakarta Sans nhất quán 2 phía | **PASS** |

## 3. Shape

| Hạng mục | M3 | MemoX (đo) | Verdict |
|---|---|---|---|
| Shape scale | 0/4/8/12/16/28/full — tuỳ biến được | 6/10/14/18/24/28 + card 20 / tile 16 / control 12 / pill (`tokens/radius.css`) | **CUSTOM-OK** (tròn hơn M3 một bậc — bản sắc DS, nhất quán) |
| Dialog | 28dp | `MxRadius.xl` = 24 (dialogTheme) | **CUSTOM-OK** (Đ-M3-3 nếu muốn theo spec) |
| Bottom sheet top | 28dp | `radius-2xl` = 28 | **PASS** |

## 4. Elevation & shadow

| Hạng mục | M3 | MemoX (đo) | Verdict |
|---|---|---|---|
| Elevation levels | 0–5 + surface tint | 5 shadow token (sm/card/lg/fab/nav, `tokens/elevation.css`) casts màu brand; không surface-tint | **CUSTOM-OK** — hệ shadow riêng nhất quán, dark dùng bậc surface (§1) |
| Focus indicator | rõ ràng, đủ tương phản | `--memox-ring-focus` 3px, token hoá | **PASS** |

## 5. State layers

| Hạng mục | M3 | MemoX (đo) | Verdict |
|---|---|---|---|
| Hover | 8% | light **4.5%** / dark 6% (colors.css:67,132) | **CUSTOM-OK, lưu ý** — nhạt hơn M3; mobile-first nên hover ít gặp (Đ-M3-1) |
| Pressed | 12% (M3 ripple ~10–12%) | light **9%** / dark 11% | **CUSTOM-OK, lưu ý** (Đ-M3-1) |
| Selected container | 12–16% | 10% light / 24% dark | **CUSTOM-OK** |
| Disabled | 38% content / 12% container | `state-disabled` 26% | **CUSTOM-OK, lưu ý** — kiểm tra đọc được khi áp lên text (Đ-M3-1) |

## 6. Layout & touch target — **nhóm FAIL chính**

M3: vùng chạm **≥ 48×48dp** (visual được phép nhỏ hơn, mở rộng bằng hit-area).
Đo từ components.css (khớp UI-UX audit G2, có hiệu chỉnh):

| Control | Đo | M3 target | Verdict |
|---|---|---|---|
| `.btn` base | min-height 48 (`--memox-touch-min`, :228) | 48 | **PASS** |
| `.icon-btn` base | 48×48 (:328) | 48 | **PASS** |
| `.btn--sm` | min-height **40** (`size-sm`, :256; audit đo render 38) | 48 | **FAIL → M3-1** |
| `.icon-btn--sm` | **36×36** (:359) | 48 | **FAIL → M3-1** |
| `.chip` | height **34** (:556) | 48 | **FAIL → M3-1** (visual 32-34 hợp lệ M3 chip — chỉ thiếu hit-area) |
| `.switch` | 52×**32** (:651) — đúng spec visual M3 | 48 hit | **FAIL → M3-1** |
| `.segmented__seg` | min-height **38** (:705) | 48 | **FAIL → M3-1** |
| `.section-head__action` | ~41×**20** (audit G2) | 48 | **FAIL → M3-1** |
| App-bar avatar (tap → profile) | **32** (audit G2) | 48 | **FAIL → M3-1** |
| Theme swatch | **40** (audit G2) | 48 | **FAIL → M3-1** |
| FAB | 60 (fab-size token) | 56 spec | **CUSTOM-OK** (to hơn spec) |
| FAB che content | — | body pad-bottom 96 < nav72+FAB60+16 ≈ 148 | **FAIL → M3-3** (= G6) |

## 7. Components vs spec M3

| Component | M3 spec | MemoX (đo) | Verdict |
|---|---|---|---|
| Top app bar (small) | 64dp | `appbar-height` 64 | **PASS** |
| Top app bar (large) | 152dp M3 / tuỳ biến | `appbar-lg` min 112 | **CUSTOM-OK** |
| Navigation bar | **80dp** | `bottom-nav-height` **72** | **CUSTOM-OK, lưu ý** (Đ-M3-2: 72 + label 11px là nguồn gộp của G7) |
| Search bar | 56dp | search-dock **52** (:464) | **CUSTOM-OK** |
| Switch | 52×32 | 52×32 | **PASS** (visual) |
| Badge (large) | 16dp, label 11sp | 20px, 11px | **CUSTOM-OK** (11px đi qua M3-2 vì contrast/floor) |
| Dialog actions | text buttons phải | ghost Cancel + filled confirm, phải | **PASS** |
| Destructive semantics | error role cho hành động phá huỷ | dialog xoá đúng; **"Leave" phiên học = primary** | **FAIL → M3-4** (= G5) |
| Iconography | Material Symbols, icon thật | Material Symbols Rounded ✓; nhưng "✓" unicode trong badge (G8) | **FAIL (NIT) → M3-5** |
| Progress indicators | linear/circular chuẩn | ProgressBar + Ring custom token-hoá; **pattern không thống nhất giữa flow** (G3) | **CUSTOM-OK về visual; G3 là consistency nội bộ** |

## 8. Motion

| Hạng mục | M3 | MemoX (đo) | Verdict |
|---|---|---|---|
| Easing | standard `cubic-bezier(0.2,0,0,1)` + accel/decel | trùng chính xác (`tokens/motion.css`) | **PASS** (định nghĩa) |
| Duration | short/medium/long 50–600ms | 80/140/220/320 + flash/pulse | **PASS** (định nghĩa) |
| **Wiring** | — | components.css chỉ có **10 transition**, đa số hardcode `0.16s ease`, KHÔNG dùng token (gen_tokens từng prune duration-* vì "unused") | **FAIL (kỹ thuật) → M3-6** — motion token định nghĩa mà không được tiêu thụ |

## 9. Backlog fix (thứ tự đề xuất)

| Mã | Việc | Nguồn | Tầng sửa |
|---|---|---|---|
| **M3-1** | Hit-area ≥48 cho 8 control (§6) — pseudo-element/padding, GIỮ visual | G2 | component (kit CSS + `Mx*` Flutter: `materialTapTargetSize`/`InkResponse` radius/padding) |
| **M3-2** | Bỏ 11px hardcode: nav label + badge → token ≥12px; idle nav label màu secondary | G7 | token+component |
| **M3-3** | Body pad-bottom ≈148 trên màn có FAB | G6 | component (app__body/FAB modifier + MxScaffold) |
| **M3-4** | "Leave" exit-dialog → danger; "Sign out" hạ tone + confirm | G5 | screen (2 chỗ) |
| **M3-5** | "✓" unicode → Material symbol / soft badge "Done" | G8 | component nhỏ |
| **M3-6** | Wire motion token vào transition trong components.css (+ Flutter dùng MxMotion tương ứng) | audit này | component |

## 10. Cần người quyết (không fix trước khi chốt)

| Mã | Câu hỏi | **Quyết định (chốt 2026-07-06)** |
|---|---|---|
| Đ-M3-1 | State-layer nhạt hơn M3 (hover 4.5% vs 8%, pressed 9% vs 12%, disabled 26% vs 38%) — nâng theo M3 hay giữ bản sắc "mềm"? | **GIỮ** — bản sắc DS, mobile-first ít hover |
| Đ-M3-2 | Nav bar 72 vs M3 80 — nâng hay giữ? | **NÂNG 80** — theo spec M3 (`--memox-bottom-nav-height` 72→80, gộp vào M3-2) |
| Đ-M3-3 | Dialog radius 24 vs M3 28 | **GIỮ 24** — scale DS nhất quán |

## 11. Kết luận

Nền tảng (color roles, tonal dark, shape/type scale riêng, easing, iconography,
app bar, sheet, switch visual) **đạt hoặc lệch-có-chủ-đích hợp lệ**. Vi phạm
cứng còn lại tập trung ở **M3-1 (touch target)** — rộng nhất, và 5 mục nhỏ
M3-2…M3-6. Fix hết backlog §9 (giữ nguyên 3 quyết định mặc định §10) thì hệ
thống **thoả mãn M3** ở mức guideline-hard-rules; các mục CUSTOM-OK được ghi
nhận là bản sắc DS, không phải nợ.
