# `_shared/` — app-level composites used by 2+ screens

Components here are **app-level composites** (assembled from `Mx*` primitives +
helpers) that are reused by **two or more** screens. This folder is **not** a junk
drawer:

## Current members

| Composite | Spec | Used by |
| --- | --- | --- |
| `ConfirmDialog` (`window.ConfirmDialog`) | `ConfirmDialog.md` | study-session, deck-detail, drawer (6 sites) |

## Admission rule (strict)

- A component may live in `_shared/` **only when it is used by ≥ 2 screens.**
- Used by exactly one screen → it belongs in that screen's
  `_features/<screen>/components/`, not here.
- A reusable **design-system primitive** (the `Mx*` family) is not an app composite
  — it stays in `docs/design/MemoX Design System/components/`.
- Tiny cross-screen helpers can stay in `../kit-helpers.jsx` (the compatibility
  layer). Promote one into its own `_shared/*.jsx` file once it grows beyond a
  small helper.

## File shape

Same IIFE convention as screens: read `window.MemoXDesignSystem_2ffa54` + existing
`window.*` helpers, assign `window.<Name>`, and load it from `index.html` **after**
`kit-helpers.jsx` and **before** the screen entries (so screens can consume it).

When promoting a component from a feature folder into `_shared/`, update its single
source file, add the `<script>` tag to `index.html`, and keep `data-mx-node` ids
unchanged.
