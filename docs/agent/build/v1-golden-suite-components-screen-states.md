# V.1 — Golden suite (components + screen states)

> **Loop task** (verification). Self-contained — execute fully in one iteration, then tick `V.1` in `docs/agent/build/README.md`. One task per iteration.
>
> Size **L** · Deps **Phase C1,S** · Branch `build/v1`


## Goal

A golden per component + per screen-state, light+dark — the real parity gate at the component layer.

## Inputs — read first

- `test/`
- `docs/design/MemoX Design System/ui_kits/memox-app/shots/*.png`

## Output

- `test/golden/**`

## Steps

1. **Baseline**: `git checkout main && git pull`, `git checkout -b build/v1`.
2. Read the inputs above in full.
3. Implement the goal. Tokens only; no hardcoded visual values.
4. Test per the Definition of Done.
5. Run Verify.
6. Finish (commit → PR → merge → tick).

## Notes

- Verify at the ~18-component + per-state layer, NOT per-pixel-per-screen (avoids the old blind spot).

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
2. Push `build/v1`; open a PR; merge to main (`--merge --delete-branch`); `git checkout main && git pull`.
   > When pushing from an agent session without a design-authorized TTY, prefix: `MEMOX_SKIP_DESIGN_SYNC=1 git push …`.
3. Tick `V.1` → `[x]` in `docs/agent/build/README.md`, small commit.