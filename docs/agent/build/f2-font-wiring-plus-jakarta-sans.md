# F.2 — Font wiring (Plus Jakarta Sans)

> **Loop task** (foundation). Self-contained — execute fully in one iteration, then tick `F.2` in `docs/agent/build/README.md`. One task per iteration.
>
> Size **S** · Deps **F.1** · Branch `build/f2`


## Goal

Register the variable font so MxTypography.fontFamily renders real glyphs.

## Inputs — read first

- `docs/design/MemoX Design System/fonts/PlusJakartaSans[wght].ttf`
- `docs/design/MemoX Design System/tokens/typography.css (@font-face, weights 200–800)`
- `pubspec.yaml`

## Output

- `pubspec.yaml (fonts:)`
- `lib/fonts/ or assets ref`

## Steps

1. **Baseline**: `git checkout main && git pull`, `git checkout -b build/f2`.
2. Read the inputs above in full.
3. Implement the goal. Tokens only; no hardcoded visual values.
4. Test per the Definition of Done.
5. Run Verify.
6. Finish (commit → PR → merge → tick).

## Notes

- Variable font: one file, weights 400–800 used. Confirm bold/extrabold render distinctly in a golden.

## Definition of Done

- [ ] **Built** at the output path(s); tokens only — no raw `Color(0x..)`/px literals (use `MxColors`/`MxSpacing`/`MxRadius`/`MxTypography`/`MxShadows`).
- [ ] **Analyzes** — `dart analyze lib test` → 0 issues.
- [ ] **Tested** — widget/golden proving structure + token values reach the tree, light **and** dark where theme-varying, for every kit state.
- [ ] **Parity** — matches the kit reference (`.jsx` render / `shots/*.png`) for every state; deviations documented in `wbs.md §Ledger`, not silent.
- [ ] **Ledger** — row(s) added to `docs/project-management/wbs.md §Ledger` (kit node → Dart symbol → test).
- [ ] **Gates green** — `node tool/design/gen_tokens.mjs --check` + `flutter test` pass.

## Verify (must pass before commit)

```bash
node tool/design/gen_tokens.mjs --check
dart analyze lib test
flutter test
```

## STOP conditions (do not push through)

- The kit is **ambiguous or looks wrong** / a business or structural **drift** needs a human decision → STOP, report the exact mismatch, wait.
- A kit state is **undrivable** from the Flutter side → document as a gap in `§Ledger`, don't fabricate.
- **Verify fails** and you cannot fix at root cause → STOP, report the failing step + output.

## Finish

1. Two commits: (a) implementation, (b) test(s). End messages with the Co-Authored-By trailer.
2. Push `build/f2`; open a PR; merge to main (`--merge --delete-branch`); `git checkout main && git pull`.
   > When pushing from an agent session without a design-authorized TTY, prefix: `MEMOX_SKIP_DESIGN_SYNC=1 git push …`.
3. Tick `F.2` → `[x]` in `docs/agent/build/README.md`, small commit.