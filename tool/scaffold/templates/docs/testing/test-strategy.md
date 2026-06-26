# Test strategy — {{PROJECT_NAME}}

Catch the bug **class**, not the instance: push prevention to the lowest layer and
add the cheapest automatic gate that covers the whole class.

## Layers

| Layer | Tests | Runs in verify |
| --- | --- | --- |
| unit | use cases, repositories, read models, error mapping | `--code` / `--full` |
| integration | data sources, migrations | `--full` |
| UI / widget | screen states + key actions | `--full` |
| visual / golden | one per state (if a golden gate exists) | `--full` |

<!-- FILL: adjust names to {{STACK}}. -->

## Bug-class gate map

| Bug class | Prevent (lowest layer) | Detect (gate) |
| --- | --- | --- |
| wrong result / count / sort | repository contract | unit test on read model |
| behavior / navigation / state | use case + store contract | interaction test per decision row |
| boundary / null / error | error contract | unit test |
| visual regression | shared component invariant + tokens | golden per state |
| contract drift | — | doc_guard + a contract assertion test |

## Rules

- Every decision-table row that a change touches gets a test asserting its Then.
- Prefer one focused test per branch over broad end-to-end tests.
- Don't regenerate goldens to silence an unexplained diff.

## Related

- `docs/decision-tables/core-decision-table.md` — rows that need tests
- `docs/checklist/implementation-checklist.md` — when to run them
