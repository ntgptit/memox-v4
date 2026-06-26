# Implementation checklist — {{PROJECT_NAME}}

Run before reporting a code task done.

## Build

- [ ] Read the required docs for this task type (CLAUDE.md "Required reading").
- [ ] Drift check passed (docs match code) — or drift reported and resolved.
- [ ] Implemented by layer: entity → contract → use case → state → UI.
- [ ] No magic values, no hardcoded routes/colors/strings/durations.
- [ ] Reused existing shared components/tokens; no needless new abstractions.
- [ ] Layer boundaries respected (no reverse imports).

## Parity (same commit)

- [ ] Pre-commit parity check (8 steps in CLAUDE.md) answered.
- [ ] Business / decision-table / schema / route / status docs updated as needed.
- [ ] Renamed terms swept (`node tool/doc_guard/run.mjs terms <old>`).
- [ ] WBS updated, or report says `WBS update: not needed — <reason>`.
- [ ] Commit Traceability Log line appended if a work package advanced.

## Verify

- [ ] `node tool/verify/run.mjs --full` (or `--docs` for docs-only) PASSED — marker written.
- [ ] `node tool/doc_guard/run.mjs check` clean.

## Review

- [ ] Fanned out to `code-reviewer` + `docs-drift-detector`; blockers fixed.

## Report

- [ ] Files changed · Docs updated (file + reason) · Verify result · Out-of-scope notes.

## Related

- `docs/checklist/recursive-agent-review.md` — the review pass
- `docs/agent/agent-task-template.md` — the task envelope
- `docs/testing/test-strategy.md` — test layers
