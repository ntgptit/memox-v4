# Agent task template — {{PROJECT_NAME}}

The shape of every task handed to Claude Code (or a sub-agent). Generate a filled
copy with `node tool/prompt_gen/run.mjs "<task>" [WBS-ID] [--type ...]`.

```markdown
# Task: <title>  [<WBS-ID>]

## Stack
{{STACK}}. State management + persistence per docs/stack/stack.md.

## Required reading (read BEFORE coding)
- docs/_generated/repo-map.md, docs/_generated/where-is.md
- docs/business/index.md, docs/business/glossary.md
- docs/contracts/{error-contract,types-catalog,code-style}.md
- <task-specific docs per CLAUDE.md "Required reading by task">

## Drift check
Compare those docs to current code. If docs lag, STOP and report (DRIFT DETECTED).

## Acceptance criteria
- [ ] <testable criterion>  (source: docs/acceptance-criteria/<feature>.md)

## Implement
Layer order: entity → contract → use case → state → UI. Reuse shared
components/tokens. No magic values.

## Parity (same commit)
Run the 8-step Pre-commit parity check. Update every doc the change touches + WBS.

## Verify
Inner loop: node tool/verify/run.mjs --quick
End: node tool/verify/run.mjs --full   (writes pass-marker)

## Report
Files changed · Docs updated (file + reason) · Verify result · Out-of-scope notes.
```

## Rules for writing a task

- Name the exact docs to read — don't make the agent guess.
- Give testable acceptance criteria, not vibes.
- State the state-management tech explicitly every time.

## Related

- `docs/agent/orchestration.md` — fan-out to sub-agents
- `docs/checklist/implementation-checklist.md` — the completion checklist
