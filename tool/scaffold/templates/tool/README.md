# {{PROJECT_NAME}} — agent tooling (`tool/`)

The deterministic backbone that keeps an AI agent on rails. Design principle:
**generated + linted indexes beat letting the agent re-explore or guess.**

The four token sinks these tools remove:

| Repetitive work | Tool |
| --- | --- |
| Re-exploring the repo each session | `doc_guard generate` → `docs/_generated/repo-map.md` |
| Checking whether docs lie about the code | `doc_guard check` |
| Remembering and running N verify commands in order | `verify` (one command, one table) |
| Hand-writing a task prompt for the dev loop | `prompt_gen` |

## verify — the single verification entry

```
node tool/verify/run.mjs --quick   # inner loop, fast, no marker
node tool/verify/run.mjs --full    # end of code task: full chain + tests, writes pass-marker
node tool/verify/run.mjs --docs    # end of docs task, writes pass-marker
node tool/verify/run.mjs --check-marker   # used by .githooks/pre-commit
```

The chain is data: `tool/verify/verify.config.json` (seeded for {{STACK}}). A PASS
writes `tool/verify/.last-pass.json` bound to the tree's content state; the
pre-commit hook rejects commits without a matching marker. Loose runs write no
marker, so they can't be committed.

## doc_guard — docs/process linter + index generator

```
node tool/doc_guard/run.mjs check        # path-ref existence + path convention + WBS hygiene
node tool/doc_guard/run.mjs generate     # (re)write docs/_generated/repo-map.md
node tool/doc_guard/run.mjs terms <old>  # find leftover refs after a rename
```

## prompt_gen — task prompt composer

```
node tool/prompt_gen/run.mjs "<task title>" [WBS-ID] [--type screen|usecase|repo|schema|route]
```

Prints a ready-to-paste task envelope (required reading + acceptance slot + workflow
+ verify + report). Fill the blanks, hand to Claude Code.

<!-- FILL: document any project-specific tools you add here. -->
