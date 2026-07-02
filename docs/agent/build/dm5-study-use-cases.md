# DM.5 — Study use cases

> **Loop task** (domain (BE core)). Self-contained — execute fully in one iteration, then tick `DM.5` in `docs/agent/build/README.md`. One task per iteration.
>
> Size **M** · Deps **DM.3,DM.4** · Branch `build/dm5`


## Goal

Due queue, start/resume session, grade card, finish session, goal+streak update.

## Inputs — read first

- `lib/domain/usecases/srs/`
- `docs/design/MemoX Design System/ui_kits/memox-app/specs/{study-session,study-result,review,player}.md`

## Output

- `lib/domain/usecases/study/*.dart`

## Steps

1. **Baseline**: `git checkout main && git pull`, branch.
2. Read the product rules ([[memox-v1-product-decisions]]) + reference-app domain ([[reference-app-lexilize-domain]]) + the relevant kit `specs/*.md`.
3. Model as **pure Dart** — no Flutter, no Drift imports. Immutable, `Result`-returning.
4. Exhaustive **unit tests** (deterministic, edge cases). This is BE core — correctness first.
5. Run Verify; add §Ledger rows; Finish.

## Definition of Done

- [ ] **Built** at the output path(s), respecting the layer contracts (foundation token-only · primitives no business logic · feature UI no data/ imports).
- [ ] **Analyzes** — `dart analyze lib test` → 0 issues; codegen (build_runner) up to date.
- [ ] **Tested** at the right level — domain = pure unit · data = Drift integration · primitives/composites = widget+golden (light+dark) · screens = provider-state widget tests + golden vs `shots/*.png`.
- [ ] **Parity / correctness** — UI matches the kit for every state; domain matches [[memox-v1-product-decisions]] with edge cases.
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
2. Push `build/dm5`; open a PR; merge to main; `git checkout main && git pull`.
   > From an agent session without a design-authorized TTY, prefix: `MEMOX_SKIP_DESIGN_SYNC=1 git push …`.
3. Tick `DM.5` → `[x]` in `docs/agent/build/README.md`, small commit.