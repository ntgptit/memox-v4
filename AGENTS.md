# AGENTS.md

This project's working contract for AI agents lives in **`CLAUDE.md`**. Read it
first. The short version:

- `docs/` is the source of truth; keep docs and code in sync **in the same commit**.
- Refs to files use repo-root-absolute paths, no leading slash (see CLAUDE.md
  "Path convention").
- All verification goes through `node tool/verify/run.mjs` (it writes the
  pass-marker the pre-commit hook requires). Do not run analyzers/tests/linters
  loose.
- Before finishing a code task: run the Pre-commit parity check, then fan out to
  the review sub-agents under `.claude/agents/`.
