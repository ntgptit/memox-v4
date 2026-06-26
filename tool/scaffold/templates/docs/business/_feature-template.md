# Feature: <name>

> Copy this file to `docs/business/<area>/<feature>.md`. Delete this line.

**Status:** Specified <!-- Specified | Implemented (only flip to Implemented with code + tests) -->
**Owner:** <who>
**Related:** decision rows <ids> · `docs/contracts/usecase-contracts/<entity>.md` · WBS <id>

## Purpose

<!-- FILL: one paragraph — what user problem this solves. -->

## User-visible behavior

<!-- FILL: the happy path as numbered steps. Be concrete about copy, order, transitions. -->

1. ...

## States

| State | Trigger | What the user sees |
| --- | --- | --- |
| loading | | |
| loaded (empty) | | |
| loaded (data) | | |
| error | | |

## Rules & edge cases

<!-- FILL: validation, limits, ordering, conflicts. Each rule that can branch -> a decision-table row. -->

- ...

## Out of scope (explicitly)

<!-- FILL: what this feature intentionally does NOT do, so nobody re-litigates it. -->

- ...

## Source files

<!-- FILL: the {{SRC_DIR}}/... files that implement this, once they exist. -->

## Related

- `docs/contracts/usecase-contracts/_template.md` — the use case contract
- `docs/decision-tables/core-decision-table.md` — add the testable branches
- `docs/acceptance-criteria/_template.md` — acceptance criteria
- `docs/design/_screen-template.md` — the screen spec
