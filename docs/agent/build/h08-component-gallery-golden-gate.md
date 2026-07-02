# H.08 — Component gallery + golden gate

> **Loop task** (component gallery gate). Self-contained — execute fully in one iteration, then tick `H.08` in `docs/agent/build/README.md`. One task per iteration.
>
> Size **M** · Deps **Phase P,K,H** · Branch `build/h08`


## Goal

A gallery screen rendering all 25 shared widgets (P+K+H) in light+dark with a golden each — the lock before the 22 screens so UI cannot drift from the kit per-screen.

## Inputs — read first

- `lib/presentation/shared/primitives/`
- `lib/presentation/shared/composites/`
- `docs/design/MemoX Design System/guidelines/`

## Output

- `lib/presentation/shared/screens/component_gallery.dart`
- `test/golden/gallery/**`

## Steps

1. **Baseline**: `git checkout main && git pull`, `git checkout -b build/h08`.
2. Build a gallery screen showing every P/K/H widget in its variants/states.
3. Golden per widget in light **and** dark; wire into the golden suite.
4. Run Verify; add §Ledger row(s); Finish.

## Notes

- Do NOT start Phase S until this gate is green — it proves the shared layer matches the kit before screens consume it.

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
2. Push `build/h08`; open a PR; merge to main; `git checkout main && git pull`.
   > From an agent session without a design-authorized TTY, prefix: `MEMOX_SKIP_DESIGN_SYNC=1 git push …`.
3. Tick `H.08` → `[x]` in `docs/agent/build/README.md`, small commit.