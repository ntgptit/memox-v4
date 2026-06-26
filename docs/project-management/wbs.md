# Work breakdown structure — MemoX V4

> Baseline reviewed: <commit> (<date>)

Source of truth for task breakdown and allocation. Any task that creates, renames,
splits, merges, re-scopes, defers, or completes a work package updates this file in
the same commit (CLAUDE.md WBS rule).

## 1. Work packages

| WBS ID | Work package | Depends on | Status | Spec |
| --- | --- | --- | --- | --- |
| 1.0 | <epic> | — | Planned | `docs/business/<area>/<feature>.md` |
| 1.1 | <task> | 1.0 | Planned | |

<!-- FILL: Status ∈ Planned / In-progress / Blocked / Done. Keep dependency order honest. -->

## ... (more sections as the project grows)

## 10. Commit Traceability Log

Append-only, newest first. One line per commit that touches a WBS work package:
`<8-char hash> · <YYYY-MM-DD> · <WBS IDs> · <summary>`.

- <hash> · 2026-06-26 · — · scaffolded WBS from skeleton

## Related

- `docs/business/index.md` — features being tracked
- `docs/business/system/overview.md` — implementation status
