# Sub-agent orchestration — MemoX V4

When to fan out to sub-agents, how to scope them, and the anti-patterns.

## Available sub-agents (`.claude/agents/`)

| Agent | Use for | When |
| --- | --- | --- |
| `code-reviewer` | senior diff review (5 axes + gates) | after a code task, post-verify |
| `docs-drift-detector` | doc-code drift sweep | after a code task, post-verify |
| `test-engineer` | test plan + coverage gaps | before/after writing tests |
| `solution-architect` | design + atomic task breakdown | DESIGN/PLAN phase |

## Auto fan-out (standing rule)

After a **code** task and `node tool/verify/run.mjs` PASS, before the final report,
spawn `code-reviewer` + `docs-drift-detector` **in parallel** (one turn, multiple
calls). Fold findings into a `Subagent review` section. Fix blockers; list minor
findings. Skip (and say why) for docs-only/trivial changes or when verify isn't green.

## Scoping rules

- Review sub-agents anchor on the **working-tree diff** (`git add -N . && git diff`) — do NOT commit first.
- Give each sub-agent a self-contained prompt; it has no memory of this session.
- Sequential when one's output feeds the next; parallel when independent.

## Anti-patterns

- Spawning an agent to do a 2-minute inline task.
- Committing before review (pushes unreviewed code into history).
- Fan-out before verify is green.

## Related

- `docs/agent/agent-task-template.md` — the task envelope
- `docs/checklist/recursive-agent-review.md` — what reviewers check
