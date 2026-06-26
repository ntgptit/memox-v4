# Recursive agent review — MemoX V4

How to review a change (yourself, or via the review sub-agents). Anchor on the
**working-tree diff**, not whole files.

## Pre-review

- `git add -N . && git diff` — the full uncommitted change (edits + new files).
- Read the change's spec/decision rows and tests first; they reveal intent.

## Axes

1. Correctness — matches spec/decision row; edge/null/error paths; tests verify real behavior.
2. Readability — names per `docs/contracts/code-style.md`; early return; no magic values.
3. Architecture — existing patterns; right abstraction; boundaries intact.
4. Security — input validated; no secrets in code/logs.
5. Performance — no N+1/unbounded; see `docs/quality/performance-contract.md`.

## Gates

- Doc-code parity (CLAUDE.md trigger map) — flag any drift.
- No edits to generated files; no hardcoded values.
- Verified through `node tool/verify/run.mjs` (loose runs write no marker).

## Verdict

`APPROVE` only with no Critical issues and no unresolved parity violation. Every
Critical/Important finding carries a specific fix. If uncertain, say so — don't guess.

## Related

- `docs/checklist/implementation-checklist.md` — the completion gate
- `docs/contracts/code-style.md` — readability axis
- `docs/contracts/error-contract.md` — correctness axis
