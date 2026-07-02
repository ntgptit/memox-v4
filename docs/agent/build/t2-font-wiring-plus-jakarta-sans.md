# T.2 — Font wiring (Plus Jakarta Sans)

> **Loop task** (theme / UI foundation). Self-contained — execute fully in one iteration, then tick `T.2` in `docs/agent/build/README.md`. One task per iteration.
>
> Size **S** · Deps **I.1** · Branch `build/t2`


## Goal

Register the variable font so MxTypography.fontFamily renders real glyphs.

## Inputs — read first

- `docs/design/MemoX Design System/fonts/PlusJakartaSans[wght].ttf`
- `docs/design/MemoX Design System/tokens/typography.css`

## Output

- `pubspec.yaml`

## Steps

1. **Baseline**: `git checkout main && git pull`, `git checkout -b build/t2`.
2. Read the inputs above in full.
3. Implement the goal, respecting layer contracts; tokens only for any visual value.
4. Test per the Definition of Done.
5. Run Verify.
6. Finish (commit → PR → merge → tick).

## Notes

- Confirm 400–800 render distinctly (golden).

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
2. Push `build/t2`; open a PR; merge to main; `git checkout main && git pull`.
   > From an agent session without a design-authorized TTY, prefix: `MEMOX_SKIP_DESIGN_SYNC=1 git push …`.
3. Tick `T.2` → `[x]` in `docs/agent/build/README.md`, small commit.