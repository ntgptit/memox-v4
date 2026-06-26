# UI/UX contract — MemoX V4

Cross-screen UI rules that every screen inherits. Screen-specific layout lives in
`docs/design/screens/*` and `docs/design/_screen-template.md`.

## Tokens & components

- Use design tokens for all color/spacing/radius/typography — no raw values in features (hard rule).
- Reach for an existing shared component before building one.
- Tokens & components inventory: `docs/design/design-language.md`.

## Required states (every screen)

loading · loaded(data) · loaded(empty) · error · (search-no-results / offline where relevant).
A state that exists in the design but not the implementation is a parity failure.

## Interaction

- One primary action per screen.
- Destructive actions confirm.
- Touch targets meet the platform minimum.

## Accessibility

- Semantic labels on interactive elements.
- Sufficient contrast in light and dark.
- Layout survives larger text scale without overflow.

Flutter cụ thể: **Material 3**; theme sáng/tối/hệ thống + cỡ chữ theo `personalization`
(`docs/business/personalization/personalization.md`); responsive bằng `LayoutBuilder`/breakpoint;
tôn trọng `MediaQuery.textScaler`; nhãn ngữ nghĩa bằng `Semantics`. UI do người dùng tự
thiết kế — doc này chỉ ràng buộc bất biến (states, token, a11y).

## Related

- `docs/design/design-language.md` — tokens & taste
- `docs/design/_screen-template.md` — per-screen spec
- `docs/ui-ux/l10n-copy-contract.md` — user-facing strings
