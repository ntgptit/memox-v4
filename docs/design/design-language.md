# Design language — MemoX V4

The taste contract: judgment rules that live outside any single mock. Paste this
into a prompt when handing a UI task to an agent.

## Tokens (single source)

Token sống ở `lib/core/theme/` (Material 3 `ThemeData` + `ThemeExtension`): bảng màu
(`ColorScheme` + accent từ personalization), spacing scale (4/8/12/16/24), radius,
typography (`TextTheme`). UI dùng `Theme.of(context)` — không giá trị thô.

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
