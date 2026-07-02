# DT.1 — Drift schema & tables

> **Loop task** (data (Drift)). Self-contained — execute fully in one iteration, then tick `DT.1` in `docs/agent/build/README.md`. One task per iteration.
>
> Size **L** · Deps **DT.0** · Branch `build/dt1`


## Goal

Implement every table in the schema contract: language_pairs, decks (self-referencing tree), cards, card_meanings, srs_state, review_logs, review_outcome, study_sessions, daily_activity, settings, backup metadata — with indices for due-queue + term/meaning search.

## Inputs — read first

- `docs/database/schema-contract.md (DT.0)`
- `lib/domain/entities/`

## Output

- `lib/data/datasources/local/*.dart`
- `lib/data/models/*.dart`

## Steps

1. **Baseline**: `git checkout main && git pull`, branch.
2. Read the domain entities/repositories (DM.2/DM.3) this implements against.
3. Implement in the **data layer only**; keep Drift row models separate from domain entities (map at the boundary).
4. Run `dart run build_runner build --delete-conflicting-outputs` for Drift codegen.
5. **Integration test** against an in-memory Drift DB.
6. Run Verify; add §Ledger rows; Finish.

## Notes

- Table set must match DT.0 exactly. Deck tree = self FK; cascade delete covers sub-decks + cards + meanings + srs_state (D-024).

## Definition of Done

- [ ] **Built** at the output path(s), respecting the layer contracts (foundation token-only · primitives no business logic · feature UI no data/ imports).
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
2. Push `build/dt1`; open a PR; merge to main; `git checkout main && git pull`.
   > From an agent session without a design-authorized TTY, prefix: `MEMOX_SKIP_DESIGN_SYNC=1 git push …`.
3. Tick `DT.1` → `[x]` in `docs/agent/build/README.md`, small commit.