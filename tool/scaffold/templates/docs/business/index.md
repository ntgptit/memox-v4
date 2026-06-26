# Business specs — {{PROJECT_NAME}}

The behavior source of truth. One folder per domain area, one `.md` per feature.

## Features

| Area | Feature | Spec | Status |
| --- | --- | --- | --- |
| <area> | <feature> | `docs/business/<area>/<feature>.md` | Specified / Implemented |

<!-- FILL: list every feature. Mirror the implementation status in docs/business/system/overview.md. -->

## How to add a feature spec

1. Copy `docs/business/_feature-template.md` to `docs/business/<area>/<feature>.md`.
2. Add any new domain terms to `docs/business/glossary.md`.
3. Add the testable branches to `docs/decision-tables/core-decision-table.md`.
4. Add the work package to `docs/project-management/wbs.md`.

## Related

- `docs/business/glossary.md` — domain terms
- `docs/business/_feature-template.md` — start a new feature spec
- `docs/decision-tables/core-decision-table.md` — testable branches
- `docs/project-management/wbs.md` — work breakdown
