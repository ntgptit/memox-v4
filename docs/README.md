# MemoX V4 docs

`docs/` is the **source of truth** for behavior, schema, routes, and UI. Code must
match it; when they conflict, fix both in the same commit (see `CLAUDE.md`).

## Map

| Folder | Holds |
| --- | --- |
| `_generated/` | machine-built indexes (`repo-map.md`, `where-is.md`) — never hand-edit |
| `architecture/` | system shape, layering, module boundaries |
| `stack/` | chosen technologies and versions |
| `business/` | per-feature behavior specs + `glossary.md` (the domain language) |
| `contracts/` | error taxonomy, shared types, code style, use-case & repository contracts |
| `decision-tables/` | testable branch behavior, one row per branch |
| `database/` | schema, migration, storage-boundary contracts |
| `design/` | screen specs + design language |
| `state/` | state-management contract |
| `ui-ux/` | UI/UX contract + copy/l10n contract |
| `testing/` | test strategy and layer map |
| `quality/` | performance + observability contracts |
| `checklist/` | implementation + review checklists |
| `agent/` | task template + sub-agent orchestration |
| `project-management/` | `wbs.md` — work breakdown + commit traceability log |
| `acceptance-criteria/` | per-feature acceptance criteria |

## Rules

- Backtick refs use repo-root-absolute paths, no leading slash (CLAUDE.md "Path convention").
- `node tool/doc_guard/run.mjs check` lints these docs; keep it green.
- Templates are the files named `_template.md` / `_feature-template.md` / `_screen-template.md` — copy, don't edit in place.

## Related

- `docs/MANIFEST.md` — reading order for a cold session
- `docs/business/index.md` — the feature list + status
- `docs/architecture/overview.md` — layering & boundaries
- `docs/contracts/error-contract.md` — failure taxonomy
