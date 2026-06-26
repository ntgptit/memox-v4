# CLAUDE.md — MemoX V4

<!-- FILL: one-line description of what MemoX V4 is. -->
MemoX V4 — <project one-liner>. Stack: Flutter / Dart 3.

`docs/` is the **source of truth** for behavior, schema, routes, and UI contract.
When `docs/` and code conflict, DO NOT silently pick one. Report the mismatch, or
update both in the same commit.

## 🔴 Doc-code parity rule (read first, always applies)

**Every commit that changes code must keep docs in sync with code.** If a code
change affects anything specified in `docs/`, you MUST update the docs **in the
SAME commit**, not "later".

Why: docs drift silently, and a future Claude Code session then implements from a
stale spec. This rule exists to stop drift at the source.

### Pre-commit parity check (mandatory, never skip)

Before finishing a task, answer in order:

1. **User-visible behavior change?** (flow, dialog copy, button order, empty
   states, validation message, error handling, navigation)
   → update the matching business / wireframe doc.
2. **Schema / persistence change?** (column, index, migration, storage key, file
   path, encoding)
   → update `docs/database/schema-contract.md` + `docs/database/migration-contract.md` + `docs/database/storage-boundaries.md`.
3. **Route / navigation change?** → update `docs/business/navigation/navigation-flow.md` + the route constants.
4. **Core-domain rule change?** <!-- FILL: name your project's algorithmic core, e.g. pricing, scoring, scheduling. -->
   → update the matching `docs/business/**` spec + decision table.
5. **Rule / edge case / validation change?** → update the matching doc. NEVER quietly relax/tighten a documented rule.
6. **New testable branch?** → add/update a row in `docs/decision-tables/core-decision-table.md` and write the test.
7. **Moved an item Specified ↔ Implemented?** → update the status table in `docs/business/system/overview.md`.
8. **Behavior changed but old docs still describe the old way?** → fix ALL refs (`node tool/doc_guard/run.mjs terms <old>`). Leave nothing inconsistent.

If unsure whether something needs updating, **default to yes**. A redundant update
costs less than drift.

## WBS maintenance rule

`docs/project-management/wbs.md` is the source of truth for task breakdown.

- Any task that creates, deletes, renames, splits, merges, re-scopes, or completes
  a feature must check whether the WBS is affected and update it in the same commit.
- If the WBS is not affected, the final report must say: `WBS update: not needed — <reason>`.

### Commit traceability rule

Every commit that creates, advances, or completes a WBS work package MUST append a
line to the **Commit Traceability Log (§10 of `docs/project-management/wbs.md`)** in
the same commit: `<8-char hash> · <YYYY-MM-DD> · <WBS IDs> · <one-line summary>`.
Append-only, newest first.

## Code change → required docs (trigger map)

Map of code-change kind → docs you MUST check (not "may"). Fill the source globs to
match your layout; the right column is what to keep in sync.

| Code change | Mandatory check & update |
| --- | --- |
| `lib/**` domain entities | the entity's business doc + `docs/business/glossary.md` |
| `lib/**` use cases / services | matching business doc + decision table |
| `lib/**` repository / data layer | `docs/contracts/repository-contracts/*` + `docs/database/schema-contract.md` |
| route / navigation constants | `docs/business/navigation/navigation-flow.md` |
| UI screens | matching `docs/design/*` + `docs/ui-ux/ui-ux-contract.md` |
| schema / migration | `docs/database/{schema,migration,storage-boundaries}-*.md` + decision table |
| new dependency | **Stop and ask. Approval needed.** |
| theme / design tokens | `docs/ui-ux/ui-ux-contract.md` |
<!-- FILL: add one row per code area that has a doc contract. -->

If a change hits several rows, check them all.

### Drift detection (when you pick up a task)

Before coding, read the related docs (see "Required reading"). If docs already lag
code (column exists but undocumented, behavior differs from doc):

1. **Stop.** Do not continue.
2. Report:
   ```
   DRIFT DETECTED:
   - Code file: lib/...
   - Doc file: docs/...
   - Mismatch: <specifics>
   - Suggested fix: <update doc / update code / needs user decision>
   ```
3. Wait for the user before continuing.

## Required reading by task

**Universal (every task):** `docs/_generated/repo-map.md`, `docs/_generated/where-is.md`,
`docs/business/index.md`, `docs/business/glossary.md`, `docs/contracts/error-contract.md`,
`docs/contracts/types-catalog.md`, `docs/contracts/code-style.md`.

| Task type | Read first |
| --- | --- |
| Add/change use case | `docs/contracts/usecase-contracts/_template.md` + business spec + decision rows |
| Add/change repository | `docs/contracts/repository-contracts/_template.md` |
| Add/change screen | `docs/design/_screen-template.md` + `docs/ui-ux/ui-ux-contract.md` |
| Add/change route | `docs/business/navigation/navigation-flow.md` |
| Schema change | `docs/database/schema-contract.md`, `docs/database/migration-contract.md` |
| State / provider | `docs/state/state-management-contract.md` |
| Writing tests | `docs/testing/test-strategy.md` |
| Perf-sensitive | `docs/quality/performance-contract.md` |
| Adding a log site | `docs/quality/observability-contract.md` |
| User-facing string | `docs/ui-ux/l10n-copy-contract.md` |
| Giving a task to an agent | `docs/agent/agent-task-template.md` |
| Delegating to sub-agents | `docs/agent/orchestration.md` |
| Reviewing code | `docs/checklist/recursive-agent-review.md` |
| Completing a task | `docs/checklist/implementation-checklist.md` |
<!-- FILL: add domain-specific rows. -->

## Path convention for cross-references (canonical)

Backtick refs to another file MUST be **repo-root absolute, no leading slash**:

```
✓  `docs/business/<area>/<file>.md`   `lib/...`   `CLAUDE.md`
✗  /docs/...   ../docs/...   bare-filename.md   <area>/<file>.md   (missing docs/ prefix)
```

`doc_guard check` enforces this. Fix any non-conforming ref in the same commit.

## Hard rules (violation = task fail)

- NO committing code without running the Pre-commit parity check.
- NO implementing from assumptions when a doc contract exists.
- NO editing generated files. <!-- FILL: list your generated globs, e.g. *.g.dart, generated/** -->
- NO hardcoding routes, colors, text styles, durations, or user-facing strings.
- NO new shared widget/component when an existing one fits.
- NO schema/persistence change without migration + schema docs + migration docs + test in the same commit.
- NO marking a doc item Implemented before the code is really implemented and tested.
- NO keeping persistent data only in memory.
- NO bypassing the layering: <!-- FILL: e.g. UseCase → Repository → DAO -->.
- NO inward→outward imports: domain imports nothing outward; presentation never imports data directly.
- NO new route without updating route constants AND `docs/business/navigation/navigation-flow.md` in the same commit.
- NO leaving a doc referencing an old term/route/field after a rename.
- NO marking a task "done" before the Pre-commit parity check passes.
- NO running verification steps loose — everything goes through `node tool/verify/run.mjs` (it writes the pass-marker the pre-commit hook requires).

## Mandatory workflow

1. Read related docs ("Required reading").
2. Inspect the source files those docs name.
3. **Drift check** — docs match code? If not, stop and report.
4. Confirm acceptance criteria when the spec is unclear.
5. Implement by layer: entity → contract → use case → state → UI.
6. **Pre-commit parity check** (8 steps above).
7. Update related docs (mandatory, same commit).
8. Update the decision table if you added/changed a branch.
9. Run `node tool/verify/run.mjs` per `docs/checklist/implementation-checklist.md`.
10. **Auto-review fan-out** (below): after verify PASS, before reporting, fan out to review sub-agents.
11. Report per the checklist, including a "Docs updated" section and the verify result.

## Auto-delegation (subagent fan-out)

After a code task and `node tool/verify/run.mjs` PASS, **before the final report**,
fan out in parallel (one turn, multiple `Agent` calls):

- `code-reviewer` — review the working-tree diff (have it run `git add -N .` then `git diff`), not whole files; do not commit first.
- `docs-drift-detector` — catch remaining doc-code drift.

Fold findings into a `Subagent review` section. Fix blockers before finishing; list
minor findings for the user. Skip fan-out (and say why) for docs-only or trivial
changes, or when verify is not yet green.

## Stack reference

- Flutter / Dart 3
<!-- FILL: frameworks, state management, persistence, routing, i18n, design system. -->

## Verification commands

```text
node tool/verify/run.mjs --quick     # INNER LOOP while developing — fast, no marker
node tool/verify/run.mjs --full      # end of code task — full chain + tests, writes pass-marker
node tool/verify/run.mjs --docs      # end of docs-only task, writes pass-marker
node tool/doc_guard/run.mjs check    # docs/process lint (also runs inside verify --docs)
node tool/doc_guard/run.mjs generate # regenerate docs/_generated/repo-map.md
```

The pre-commit hook (`--check-marker`) rejects commits without a matching pass-marker.

## When in doubt

- Prefer the minimal, structurally correct change over a broad refactor.
- Prefer a redundant doc update over skipping the parity check.
- If a task would violate a hard rule, stop and confirm with the user first.
- If you find drift the task didn't ask you to fix, still report it.
