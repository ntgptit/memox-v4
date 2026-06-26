# tool/scaffold — new-project skeleton generator

Generates the **Claude Code working skeleton** for a new project: a `CLAUDE.md`
contract, a `docs/` source-of-truth tree of fill-in-the-blank templates, the
`tool/` chain (`verify` + `doc_guard` + `prompt_gen`), review sub-agents, and git
hooks.

The point: when you later hand a task to Claude Code, the information architecture
already exists, so the agent **fills the right blanks** instead of re-inventing the
whole structure each session. Every generated doc carries `<!-- FILL: ... -->`
markers showing exactly what to supply.

This mirrors the architecture MemoX itself runs on (docs-as-source-of-truth +
doc_guard + verify pass-marker + sub-agent fan-out), generalized and made
stack-agnostic.

## Usage

```bash
node tool/scaffold/run.mjs <target-dir> [options]
```

| Option | Default | Meaning |
| --- | --- | --- |
| `--name "<Name>"` | target dir name | human project name |
| `--slug <slug>` | derived from name | kebab-case id |
| `--stack <id>` | `generic` | `generic` · `flutter` · `node-ts` · `spring-boot` · `python` |
| `--src <dir>` | per-stack | source root override |
| `--force` | off | overwrite existing files |
| `--dry-run` | off | print the plan, write nothing |
| `--list` | — | list the template inventory and exit |

### Examples

```bash
node tool/scaffold/run.mjs ../my-app --name "My App" --stack node-ts
node tool/scaffold/run.mjs ../svc --name "Orders" --stack spring-boot --dry-run
node tool/scaffold/run.mjs . --stack flutter --force      # scaffold in place
node tool/scaffold/run.mjs x --list                        # see what it emits
```

## What it generates

```
CLAUDE.md                  AGENTS.md                 GETTING-STARTED.md
.githooks/{pre-commit,pre-push}
.claude/settings.json      .claude/agents/{code-reviewer,docs-drift-detector,test-engineer,solution-architect}.md
tool/verify/{run.mjs,verify.config.json}            tool/doc_guard/run.mjs
tool/prompt_gen/run.mjs    tool/README.md
docs/  README, MANIFEST, _generated/{repo-map,where-is},
       architecture/, stack/, business/{index,glossary,_feature-template,system,navigation},
       contracts/{error,types,code-style,usecase-contracts/_template,repository-contracts/_template},
       decision-tables/, database/{schema,migration,storage-boundaries},
       design/{_screen-template,design-language}, state/, testing/, quality/{performance,observability},
       ui-ux/{ui-ux-contract,l10n-copy-contract}, checklist/{implementation,recursive-agent-review},
       agent/{agent-task-template,orchestration}, project-management/wbs.md, acceptance-criteria/_template.md
```

`tool/verify/verify.config.json` is generated from `--stack` (the real build/test
chain); everything else is a template with token substitution
(`{{PROJECT_NAME}}`, `{{STACK}}`, `{{SRC_DIR}}`, `{{DATE}}`, …).

## How to extend

Templates live under `tool/scaffold/templates/` and mirror the target tree 1:1. Add
a file there → it ships. Add a stack to the `STACKS` table in
`tool/scaffold/run.mjs` to seed a new verify chain.

## After generating

The target's `GETTING-STARTED.md` has the one-time setup and the fill-in order.
