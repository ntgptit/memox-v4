# C1.15 — MxSearchDock

> **Loop task** (reusable component). Self-contained — execute fully in one iteration, then tick `C1.15` in `docs/agent/build/README.md`. One task per iteration.
>
> Size **M** · Deps **Phase F** · Branch `build/c115`


## Goal

Build the Flutter widget **MxSearchDock** mirroring the kit component, driven entirely by design tokens + the theme (Tier 1).

## Inputs — READ ALL IN FULL (do not infer)

- `docs/design/MemoX Design System/components/navigation/MxSearchDock.d.ts` — the typed prop contract (variants, sizes, flags).
- `docs/design/MemoX Design System/components/navigation/MxSearchDock.prompt.md` — the one-paragraph intent + JSX usage examples.
- `docs/design/MemoX Design System/components/navigation/MxSearchDock.jsx` — the class→CSS mapping (which base class + modifiers).
- `docs/design/MemoX Design System/components.css` — the base class + modifier styling for **MxSearchDock** (find its selector block).
- `lib/core/theme/` — the tokens + `MxTheme` extension to consume.

## Output

- `lib/presentation/shared/widgets/navigation/mx_search_dock.dart` — the widget.
- `test/presentation/shared/widgets/mxsearchdock_test.dart` — its test.

## Steps

1. **Baseline**: `git checkout main && git pull`, `git checkout -b build/c115`.
2. Read the `.d.ts` → derive the constructor: every prop → a param; every string-union → a Dart `enum`; flags → `bool`.
3. Read `.jsx` + the `components.css` slice → map each variant/modifier to token-based styling (colour, radius, shadow, padding, type). Use the theme; **no raw values**.
4. Reproduce **every variant/size/state** the contract lists (e.g. MxButton: primary/secondary/outline/ghost/contrast × sm/lg × icon/trailing/block/danger/disabled).
5. Widget + golden test: render each variant in light+dark; assert token values reach the tree.
6. Run Verify; add `§Ledger` row(s); Finish.

## Notes

- The kit name + base class are **frozen contract** — keep the Dart name `MxSearchDock` and its variant identifiers aligned to the kit.
- Strings come from ARB, not the widget.
- If the `.d.ts` lists a variant the CSS has no styling for, note it in `§Ledger` — don't invent.

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
2. Push `build/c115`; open a PR; merge to main (`--merge --delete-branch`); `git checkout main && git pull`.
   > When pushing from an agent session without a design-authorized TTY, prefix: `MEMOX_SKIP_DESIGN_SYNC=1 git push …`.
3. Tick `C1.15` → `[x]` in `docs/agent/build/README.md`, small commit.