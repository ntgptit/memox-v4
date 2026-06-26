# Core decision table — {{PROJECT_NAME}}

One row per testable behavior branch. This is the bridge between specs and tests:
every row should have a test, and every behavioral test should trace to a row.

| ID | Given (state/input) | When (action) | Then (expected) | Spec | Test |
| --- | --- | --- | --- | --- | --- |
| D-001 | <precondition> | <event> | <outcome> | `docs/business/<area>/<feature>.md` | `test/...` |

<!-- FILL: add a row whenever you add/change a branch (CLAUDE.md parity step 6).
     Keep IDs stable and append-only so tests can cite them. -->

## Conventions

- IDs are stable and append-only (`D-NNN`). Don't renumber.
- A row is "covered" only when a test asserts exactly its Then for its Given/When.
- Removing a behavior: mark the row `REMOVED` with the commit, don't delete it.

## Related

- `docs/business/_feature-template.md` — the feature behavior
- `docs/testing/test-strategy.md` — tests that cover rows
- `docs/acceptance-criteria/_template.md` — criteria per row
