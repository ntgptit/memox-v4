# S.06 — drawer

> **Loop task** (screen). Self-contained — execute fully in one iteration, then tick `S.06` in `docs/agent/build/README.md`. One task per iteration.
>
> Size **M** · Deps **Phase C1** · Branch `build/s06`


## Goal

Build the **drawer** screen + its 4 feature-local component(s), composed from the Tier-1 `Mx*` widgets, matching the kit for every state.

## Inputs — READ ALL IN FULL

- `docs/design/MemoX Design System/ui_kits/memox-app/_features/drawer/Drawer.jsx` — the screen composition (which components, which states, the state machine).
- Feature-local components (build these here, not in Phase C1):
  - `docs/design/MemoX Design System/ui_kits/memox-app/_features/drawer/components/DrawerItem.jsx`
  - `docs/design/MemoX Design System/ui_kits/memox-app/_features/drawer/components/DrawerPanel.jsx`
  - `docs/design/MemoX Design System/ui_kits/memox-app/_features/drawer/components/LangCard.jsx`
  - `docs/design/MemoX Design System/ui_kits/memox-app/_features/drawer/components/RemoveLanguageDialog.jsx`
- `docs/design/MemoX Design System/ui_kits/memox-app/specs/drawer.md` — the contract (states, copy, behaviour).
- `docs/design/MemoX Design System/ui_kits/memox-app/shots/drawer--*--{light,dark}.png` — the visual reference for **every** state.
- Tier-1 widgets in `lib/presentation/shared/widgets/` + tokens/theme.

## Output

- `lib/presentation/features/drawer/drawer_screen.dart`
- `lib/presentation/features/drawer/widgets/*.dart` — the 4 feature-local component(s).
- `test/presentation/features/drawer/*_test.dart`

## Steps

1. **Baseline**: `git checkout main && git pull`, `git checkout -b build/s06`.
2. Read `Drawer.jsx` → enumerate the **states** (from the screen + `specs/drawer.md` + the `shots/` filenames) and which components each state renders.
3. Build the feature-local components (token-only, compose Tier-1 `Mx*`).
4. Compose the screen; wire each state; strings from ARB.
5. Test **every state** in light+dark (golden vs the matching `shots/*.png`); assert the node set / key components render per state.
6. Run Verify; add `§Ledger` rows; Finish.

## Notes

- Reuse Tier-1 components; only build genuinely screen-specific pieces locally.
- Some kit states may be **undrivable** (error/loading behind a Result notifier) → document as a gap, don't fake.
- If the FE composition genuinely diverges from the kit structure → **STOP** (possible drift), report.

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
2. Push `build/s06`; open a PR; merge to main (`--merge --delete-branch`); `git checkout main && git pull`.
   > When pushing from an agent session without a design-authorized TTY, prefix: `MEMOX_SKIP_DESIGN_SYNC=1 git push …`.
3. Tick `S.06` → `[x]` in `docs/agent/build/README.md`, small commit.