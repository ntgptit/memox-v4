# Design language — MemoX V4

The taste contract: judgment rules that live outside any single mock. Paste this
into a prompt when handing a UI task to an agent.

## Tokens (single source)

<!-- FILL: where tokens live (colors, spacing, radius, typography) and their names.
     UI must use tokens, never raw values (hard rule). -->

## Principles

- Consistency over novelty: reuse the existing component for a job before making a new one.
- Hierarchy: one primary action per screen; secondary actions are visually quieter.
- Density and spacing follow the token scale, not eyeballed pixels.
- Light and dark must both be readable.

## Shared components

| Component | Use for | Don't use raw |
| --- | --- | --- |
| <Card component> | grouped content | raw card |
| <Button component> | actions | raw button |

<!-- FILL: list the shared components so agents reach for them first. -->

## Anti-patterns

- Hardcoded colors/spacing/typography in feature code.
- A new shared component when an existing one fits.
- Replacing a mocked pattern with a different one without a documented reason.

## Related

- `docs/ui-ux/ui-ux-contract.md` — the UI contract
- `docs/design/_screen-template.md` — per-screen spec
