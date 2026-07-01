# Design language — MemoX V4

The taste contract: judgment rules that live outside any single mock. Paste this
into a prompt when handing a UI task to an agent.

## Tokens (single source)

Giá trị token là hợp đồng của design kit ở `docs/design/MemoX Design System/tokens/*.css`
(`--memox-*`, frozen). Lớp Flutter là **consumer hạ nguồn**: token được phản chiếu sang Dart ở
`lib/core/theme/`, đồng bộ tay khi kit đổi (tool `tool/parity/gen_tokens.mjs` còn *inert* — xem
ghi chú `$pointsAt` trong `tool/tool.config.json`).

| Token class (`lib/core/theme/`) | Nguồn CSS | Nội dung |
| --- | --- | --- |
| `MxColors` (`mx_colors.dart`) | `tokens/colors.css` | bảng màu ngữ nghĩa `light`/`dark` + accent palette + `seed` |
| `MxSpacing` (`mx_spacing.dart`) | `tokens/spacing.css` | thang 4px `space0..12` + nhịp layout (gutter, touch min) |
| `MxRadius` (`mx_radius.dart`) | `tokens/radius.css` | thang bo góc + alias vai trò + `BorderRadius` sẵn |
| `MxTypography` (`mx_typography.dart`) | `tokens/typography.css` | family, cỡ, weight, line-height, tracking (em) |
| `MxSizes`/`MxIconSize`/`MxStroke` (`mx_sizes.dart`) | `tokens/{size,icon-size,stroke}.css` | kích thước cố định, cỡ icon, độ rộng nét |
| `MxShadows` (`mx_elevation.dart`) | `tokens/elevation.css` | shadow `light`/`dark` |
| `MxMotion` (`mx_motion.dart`) | `tokens/motion.css` | thang duration + easing (standard / enter / exit) |

`AppTheme.light()/dark()` (`app_theme.dart`) dựng Material 3 `ThemeData` từ các token này
(`ColorScheme` + `TextTheme` + component themes). Các token Material không biểu diễn được
(màu ngữ nghĩa success/warning/info, surface tiers, shadow) đi kèm qua `ThemeExtension`
`MxTheme` (`mx_theme.dart`) — UI đọc bằng `MxTheme.of(context)`; màu/typography đọc qua
`Theme.of(context)`. Không giá trị thô trong feature.

## Responsive

Thiết kế là **phone-first**; layout co giãn theo lớp kích thước màn hình thay vì kéo
giãn layout điện thoại. Token + helper:

- `MxScreenSize` + `MxBreakpoints` (`lib/core/theme/mx_breakpoints.dart`) — 4 lớp
  `compact / medium / expanded / large` (ngưỡng 600 · 840 · 1200), gutter và
  `maxContentWidth` theo lớp.
- `lib/presentation/shared/layouts/responsive.dart` — `context.mxScreenSize` /
  `context.responsive(...)` (đọc theo cửa sổ), `MxResponsiveBuilder` (đọc theo ràng buộc
  cục bộ qua `LayoutBuilder`), `MxContentBounds` (giới hạn bề rộng đọc được + gutter).
- `ThemeData.visualDensity = adaptivePlatformDensity` — gọn hơn trên desktop/web.
- Luôn tôn trọng `MediaQuery.textScaler`; layout phải sống được khi cỡ chữ lớn.

## Principles

- Consistency over novelty: reuse the existing component for a job before making a new one.
- Hierarchy: one primary action per screen; secondary actions are visually quieter.
- Density and spacing follow the token scale, not eyeballed pixels.
- Light and dark must both be readable.

## Shared components

Widget dùng chung đặt tiền tố `Mx` (planned):

| Component | Use for | Don't use raw |
| --- | --- | --- |
| `MxNodeTile` | dòng thư mục/bộ thẻ (đếm + % + due) | `ListTile` thô |
| `MxFlashcard` | mặt thẻ (term/nghĩa + audio) | `Card` thô |
| `MxPrimaryButton` | hành động chính | `ElevatedButton` thô |
| `MxActionSheet` | menu hành động (Play) | `showModalBottomSheet` thô |
| `MxConfirmDialog` | xác nhận xoá | `AlertDialog` thô |
| `MxProgressRing` | vòng tiến độ + badge due | — |
| `MxEmptyState` | trạng thái rỗng | — |

## Anti-patterns

- Hardcoded colors/spacing/typography in feature code.
- A new shared component when an existing one fits.
- Replacing a mocked pattern with a different one without a documented reason.

## Related

- `docs/ui-ux/ui-ux-contract.md` — the UI contract
- `docs/design/_screen-template.md` — per-screen spec
