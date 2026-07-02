# Screen: <name>

> Copy to `docs/design/screens/<screen>.md`. Delete this line.

**Route:** `/<path>` (see `docs/business/navigation/navigation-flow.md`)
**Mock:** <link/path to the design reference, if any>
**Business spec:** `docs/business/<area>/<feature>.md`

## States (map EVERY one — a missing state is a parity failure)

| State | Condition | Layout |
| --- | --- | --- |
| loading | | |
| loaded (data) | | |
| loaded (empty) | | |
| error | | |
| <search no-results / offline / ...> | | |

## Element map

| Mock element | Component to use | Plan | Scope |
| --- | --- | --- | --- |
| <header> | <existing shared component> | | Current / Future / Rejected |

<!-- FILL: every visible element. Reuse shared components + tokens; no hardcoded
     colors/spacing/typography in feature widgets (hard rule). -->

## Behavior

- <!-- FILL: tap targets, transitions, what each action triggers. -->

## Tests

- one test per state above (loaded/empty/loading/error) + key actions.
- a visual/golden test per state if the project has a golden gate.

## Related

- `docs/ui-ux/ui-ux-contract.md` — cross-screen UI rules
- `docs/design/design-language.md` — the taste contract
- `docs/business/_feature-template.md` — the feature behind the screen
