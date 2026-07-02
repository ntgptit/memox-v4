# DM.4 — SRS engine (8-box single-direction)

> **Loop task** (domain (BE core)). Self-contained — execute fully in one iteration, then tick `DM.4` in `docs/agent/build/README.md`. One task per iteration.
>
> Size **L** · Deps **DM.2** · Branch `build/dm4`


## Goal

The scheduler: 8-box single-direction progression + 20-new-cards/day intake + due calculation + grade→box transition.

## Inputs — read first

- `docs/business/srs/srs-review.md (the 8-box Leitner spec)`
- `docs/business/study/study-flow.md`

## Output

- `lib/domain/usecases/srs/*.dart`

## Steps

1. **Baseline**: `git checkout main && git pull`, branch.
2. Read the authoritative v1 product rules in `docs/business/` (start at `index.md`; this task names its specific spec) + the relevant kit `specs/*.md` for UI shape. If a rule is not stated in-repo, **STOP and ask** — do not invent domain behaviour.
3. Model as **pure Dart** — no Flutter, no Drift imports. Immutable, `Result`-returning.
4. Exhaustive **unit tests** (deterministic, edge cases). This is BE core — correctness first.
5. Run Verify; add §Ledger rows; Finish.

## Notes

- This is the product core — a bug is silent data damage. Property/exhaustive tests before any screen consumes it. Pure & deterministic (no Date.now — inject a clock).

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
2. Push `build/dm4`; open a PR; merge to main; `git checkout main && git pull`.
   > From an agent session without a design-authorized TTY, prefix: `MEMOX_SKIP_DESIGN_SYNC=1 git push …`.
3. Tick `DM.4` → `[x]` in `docs/agent/build/README.md`, small commit.