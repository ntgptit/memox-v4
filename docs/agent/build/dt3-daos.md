# DT.3 — DAOs

> **Loop task** (data (Drift)). Self-contained — execute fully in one iteration, then tick `DT.3` in `docs/agent/build/README.md`. One task per iteration.
>
> Size **M** · Deps **DT.1** · Branch `build/dt3`


## Goal

Queries: due-cards, term+meaning search, deck tree, stats aggregations.

## Inputs — read first

- `lib/data/datasources/local/`

## Output

- `lib/data/datasources/local/dao/*.dart`

## Steps

1. **Baseline**: `git checkout main && git pull`, branch.
2. Read the domain entities/repositories (DM.2/DM.3) this implements against.
3. Implement in the **data layer only**; keep Drift row models separate from domain entities (map at the boundary).
4. Run `dart run build_runner build --delete-conflicting-outputs` for Drift codegen.
5. **Integration test** against an in-memory Drift DB.
6. Run Verify; add §Ledger rows; Finish.

## Definition of Done

- [ ] **Built** at the output path(s), respecting the layer contracts (foundation token-only · primitives no business logic · feature UI no data/ imports).
- [ ] **Analyzes** — `dart analyze lib test` → 0 issues; codegen (build_runner) up to date.
- [ ] **Tested** at the right level — domain = pure unit · data = Drift integration · primitives/composites = widget+golden (light+dark) · screens = provider-state widget tests + golden vs `shots/*.png`.
- [ ] **Parity / correctness** — UI matches the kit for every state; domain matches the v1 rules in `docs/business/` with edge cases.
- [ ] **Ledger** — row(s) added to `docs/project-management/wbs.md §Ledger`.
- [ ] **Gates green** — `gen_tokens --check` + `dart analyze` + `flutter test` + codegen check.

## Verify (must pass before commit)

```bash
dart run build_runner build --delete-conflicting-outputs
node tool/design/gen_tokens.mjs --check
dart analyze lib test
flutter test
```

## STOP conditions (do not push through)

- Source is **ambiguous or looks wrong** / a business or structural **drift** needs a human decision → STOP, report the exact mismatch, wait.
- A kit state / product rule is **undrivable or underspecified** → document as a gap in §Ledger, don't fabricate.
- **Verify fails** and you cannot fix at root cause → STOP, report the failing step + output.

## Finish

1. Commit(s): implementation + test(s). End messages with the Co-Authored-By trailer.
2. Push `build/dt3`; open a PR; merge to main; `git checkout main && git pull`.
   > From an agent session without a design-authorized TTY, prefix: `MEMOX_SKIP_DESIGN_SYNC=1 git push …`.
3. Tick `DT.3` → `[x]` in `docs/agent/build/README.md`, small commit.