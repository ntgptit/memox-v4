# DT.0.1 — Persistence safety policy

> **Loop task** (data (Drift)). Self-contained — execute fully in one iteration, then tick `DT.0.1` in `docs/agent/build/README.md`. One task per iteration.
>
> Size **M** · Deps **DT.0** · Branch `build/dt01`


## Goal

A DB-safety policy doc + test skeletons BEFORE Drift impl — for a local-first SRS app a DB bug is the worst failure. Locks the patterns DT.1–DT.4 must follow.

## Inputs — read first

- `docs/database/schema-contract.md (DT.0)`
- `docs/decision-tables/core-decision-table.md (D-024 cascade)`

## Output

- `docs/database/persistence-safety.md`
- `test/data/_skeletons/*.dart`

## Steps

1. **Baseline**: `git checkout main && git pull`, branch.
2. Read the business specs in `docs/business/` + `docs/decision-tables/core-decision-table.md` + the domain entities (DM.2) this doc must cover.
3. Write the doc (Markdown). Map every element to the rule / `D-xxx` it serves; no dangling links.
4. Self-check: every required item is covered and every reference resolves.
5. Run `node tool/verify/run.mjs --docs`; add §Ledger row(s); Finish.

## Notes

- Cover: transaction/rollback pattern for multi-table writes (+ a rollback test skeleton); migration-test skeleton; deterministic ordering policy; local-day/clock injection policy (no wall-clock in queries); soft-delete/cascade behaviour — each backed by a decision-table row (D-024).
- This is a doc + test-skeleton task; the real Drift work is DT.1+.

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
2. Push `build/dt01`; open a PR; merge to main; `git checkout main && git pull`.
   > From an agent session without a design-authorized TTY, prefix: `MEMOX_SKIP_DESIGN_SYNC=1 git push …`.
3. Mark done: append `DT.0.1` to `docs/agent/build/DONE.txt`, run `node tool/design/gen_task_prompts.mjs` (renders `[x]` in the queue), commit.