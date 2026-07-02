# I.10 — Architecture guard rules

> **Loop task** (infrastructure). Self-contained — execute fully in one iteration, then tick `I.10` in `docs/agent/build/README.md`. One task per iteration.
>
> Size **M** · Deps **I.2,I.3** · Branch `build/i10`


## Goal

Enforce the layer boundaries by code (lint + a guard test) so a feature can never quietly break the architecture.

## Inputs — read first

- `analysis_options.yaml`
- `AGENTS.md (layer contracts)`
- `lib/ tree`

## Output

- `analysis_options.yaml (import rules)`
- `test/architecture/layer_boundaries_test.dart`

## Steps

1. **Baseline**: `git checkout main && git pull`, `git checkout -b build/i10`.
2. Add import/boundary rules (custom_lint / a source-scanning test) for: `domain/` imports **no** `data/` / `presentation/` / Flutter; `presentation/` imports **no** Drift / datasource / plugin; routes use typed constants (no raw path strings); providers do **no** navigation side-effects; generated files (`mx_*.dart`, `*.g.dart`) are never hand-edited; user-facing text comes from ARB.
3. Prove each rule fails on a deliberate violation, then remove the violation.
4. Run Verify; add §Ledger row(s); Finish.

## Notes

- This is the gate that keeps 22 screens from eroding the layering.

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
2. Push `build/i10`; open a PR; merge to main; `git checkout main && git pull`.
   > From an agent session without a design-authorized TTY, prefix: `MEMOX_SKIP_DESIGN_SYNC=1 git push …`.
3. Tick `I.10` → `[x]` in `docs/agent/build/README.md`, small commit.