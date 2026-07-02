# I.0 — Verify runner bootstrap

> **Loop task** (infrastructure). Self-contained — execute fully in one iteration, then tick `I.0` in `docs/agent/build/README.md`. One task per iteration.
>
> Size **M** · Deps **—** · Branch `build/i0`


## Goal

Create the single build-loop gate `tool/verify/run.mjs` that every later task calls instead of raw commands. 23 kit specs already reference it.

## Inputs — read first

- `tool/design/gen_tokens.mjs`
- `docs/design/MemoX Design System/ui_kits/memox-app/specs/ (freshness check refs)`

## Output

- `tool/verify/run.mjs`

## Steps

1. **Baseline**: `git checkout main && git pull`, `git checkout -b build/i0`.
2. Write `tool/verify/run.mjs` (Node) as the umbrella gate. Modes: no-arg = FULL (codegen freshness `dart run build_runner build` + git-clean check, `node tool/design/gen_tokens.mjs --check`, `dart analyze lib test`, `flutter test`); `--quick` = analyze + test only; `--docs` = doc/spec freshness + `gen_tokens --check` only. Exit non-zero on the first failing step; print which step failed.
3. This task is the ONLY one whose Verify uses raw commands (bootstrap exception) — everything after calls `node tool/verify/run.mjs`.
4. Test the runner on the current repo (should pass: tokens up to date, analyze clean).
5. Finish (commit → PR → merge → tick).

## Notes

- Do not duplicate command lists elsewhere — this file is the single source for the gate.
- Until this lands, tasks fall back to the raw commands; after it, they must call the runner.

## Definition of Done

- [ ] **Built** at the output path(s), respecting the layer contracts (foundation token-only · primitives no business logic · feature UI no data/ imports).
- [ ] **Conventions** (AGENTS.md) — state via **@riverpod only, no `setState`** in feature UI · **SQL only in `*.drift`** (no inline SQL) · no magic values, **no unnecessary `else`** (early return/throw/overwrite) · all text + error messages via l10n · errors flow `Failure` → `AsyncValue.error`, shown localized to the user **and** logged/reported for devs, never swallowed.
- [ ] **Analyzes** — `dart analyze lib test` → 0 issues; codegen (build_runner) up to date.
- [ ] **Tested** at the right level — domain = pure unit · data = Drift integration · primitives/composites = widget+golden (light+dark) · screens = provider-state widget tests + golden vs `shots/*.png`.
- [ ] **Parity / correctness** — UI matches the kit for every state; domain matches the v1 rules in `docs/business/` with edge cases.
- [ ] **Decision Table** — every `D-xxx` row in `docs/decision-tables/core-decision-table.md` this task touches has a covering test; cite the `D-xxx` id(s) in the Ledger. (Deferred rows: D-012 Premium, D-022 REMOVED, D-027 sync.)
- [ ] **Ledger** — row(s) added to `docs/project-management/wbs.md §Ledger` (kit/D-xxx node → Dart symbol → test).
- [ ] **Gates green** — `node tool/verify/run.mjs` passes (codegen freshness + `gen_tokens --check` + analyze + test).

## Verify (must pass before commit)

```bash
node tool/verify/run.mjs          # full gate: codegen freshness + gen_tokens --check + analyze + test
node tool/verify/run.mjs --quick  # analyze + test only (fast, while iterating)
node tool/verify/run.mjs --docs   # doc/spec freshness + gen_tokens --check only
```

## STOP conditions (do not push through)

- Source is **ambiguous or looks wrong** / a business or structural **drift** needs a human decision → STOP, report the exact mismatch, wait.
- A kit state / product rule is **undrivable or underspecified** → document as a gap in §Ledger, don't fabricate.
- **Verify fails** and you cannot fix at root cause → STOP, report the failing step + output.

## Finish

1. Commit(s): implementation + test(s). End messages with the Co-Authored-By trailer.
2. Push `build/i0`; open a PR; merge to main; `git checkout main && git pull`.
   > From an agent session without a design-authorized TTY, prefix: `MEMOX_SKIP_DESIGN_SYNC=1 git push …`.
3. Mark done: append `I.0` to `docs/agent/build/DONE.txt`, run `node tool/design/gen_task_prompts.mjs` (renders `[x]` in the queue), commit.