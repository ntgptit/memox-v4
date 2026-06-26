# MemoX V4 — getting started with this skeleton

This repo was scaffolded as a **khung xương** (skeleton): the information
architecture, contracts, and tooling are in place so that when you hand a task to
Claude Code it only *fills the right blanks* instead of brainstorming the whole
structure from scratch.

Every doc with `<!-- FILL: ... -->` markers is a stub waiting for content.

## One-time setup

```bash
git init
git config core.hooksPath .githooks          # enable the verify pass-marker gate
node tool/doc_guard/run.mjs generate          # build docs/_generated/repo-map.md
node tool/verify/run.mjs --docs               # confirm the chain runs end-to-end
```

Then tune `tool/verify/verify.config.json` for your real build/test commands
(it was seeded for stack = Flutter / Dart 3).

## Fill-in order (do not skip ahead)

1. **`CLAUDE.md`** — replace every `<!-- FILL -->`: project one-liner, the
   trigger map rows for your code areas, hard rules, stack reference.
2. **`docs/architecture/overview.md`** + **`docs/stack/stack.md`** — the shape of
   the system and the chosen technologies.
3. **`docs/business/glossary.md`** + **`docs/business/index.md`** — name the
   domain terms once, reuse everywhere.
4. **`docs/contracts/*`** — error taxonomy, shared types, code style.
5. Per feature: copy the templates
   - `docs/business/_feature-template.md` → `docs/business/<area>/<feature>.md`
   - `docs/contracts/usecase-contracts/_template.md` → `.../<entity>.md`
   - `docs/contracts/repository-contracts/_template.md` → `.../<entity>-repository.md`
   - `docs/design/_screen-template.md` → `docs/design/screens/<screen>.md`
   - add a row to `docs/decision-tables/core-decision-table.md`
   - add the work package to `docs/project-management/wbs.md`
6. **`docs/database/*`** — only when you introduce persistence.

## The daily loop

`node tool/prompt_gen/run.mjs "<task>" [WBS-ID] [--type screen|usecase|repo|schema|route]`
prints a ready-to-paste task prompt that already points at the right reading list
and the verify/report steps. Paste it, let Claude Code fill the blanks, then it
self-verifies through `tool/verify`.

## What enforces all this

- `tool/doc_guard` — fails if a doc references a file/path that does not exist, or
  breaks the path convention.
- `tool/verify` — single entry for every check; a PASS writes a marker bound to the
  tree state.
- `.githooks/pre-commit` — refuses commits without a valid marker.
- `.claude/agents/*` — review sub-agents the main agent fans out to after a change.
