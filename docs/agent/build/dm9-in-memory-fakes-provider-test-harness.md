# DM.9 — In-memory fakes + provider test harness

> **Loop task** (domain (BE core)). Self-contained — execute fully in one iteration, then tick `DM.9` in `docs/agent/build/README.md`. One task per iteration.
>
> Size **M** · Deps **DM.3,DM.8** · Branch `build/dm9`


## Goal

In-memory fake implementations of every repository + service, a fake clock, deterministic fake IDs, a seeded fake SRS/due queue, and a ProviderScope-override harness — so Phase S screens build + test against fakes WITHOUT waiting for Drift (DT). This is the seam that makes FE/BE parallel real.

## Inputs — read first

- `lib/domain/repositories/ (DM.3)`
- `lib/domain/services/ (DM.8)`
- `lib/domain/usecases/srs/ (DM.4)`

## Output

- `lib/data/fakes/*.dart`
- `test/harness/provider_harness.dart`

## Steps

1. **Baseline**: `git checkout main && git pull`, `git checkout -b build/dm9`.
2. Implement fake Deck/Card/Review/Settings repos + services entirely in memory (seedable), an injectable `Clock`, deterministic ID generator, and a seeded due-queue.
3. Build a `providerHarness` / override bundle so a widget test can pump any screen with fakes via `ProviderScope(overrides: …)`.
4. Unit-test the fakes; provide a smoke widget test proving a screen renders on fakes.
5. Run Verify; add §Ledger row(s); Finish.

## Notes

- Fakes live in `data/fakes` (they implement domain contracts) but stay test-friendly. DT.5 later swaps them for Drift-backed providers — same contract, no screen change.

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
2. Push `build/dm9`; open a PR; merge to main; `git checkout main && git pull`.
   > From an agent session without a design-authorized TTY, prefix: `MEMOX_SKIP_DESIGN_SYNC=1 git push …`.
3. Tick `DM.9` → `[x]` in `docs/agent/build/README.md`, small commit.