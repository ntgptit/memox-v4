# S.06 — drawer

> **Loop task** (screen). Self-contained — execute fully in one iteration, then tick `S.06` in `docs/agent/build/README.md`. One task per iteration.
>
> Size **M** · Deps **Phase K** · Branch `build/s06`


## Goal

Build the **drawer** screen + its 4 feature-local component(s), composed from the shared `Mx*` widgets, rendering local UI state, matching the kit for every state.

## Inputs — READ ALL IN FULL

- `docs/design/MemoX Design System/ui_kits/memox-app/_features/drawer/Drawer.jsx` — screen composition (components, states, state machine).
- Feature-local components (build here):
  - `docs/design/MemoX Design System/ui_kits/memox-app/_features/drawer/components/DrawerItem.jsx`
  - `docs/design/MemoX Design System/ui_kits/memox-app/_features/drawer/components/DrawerPanel.jsx`
  - `docs/design/MemoX Design System/ui_kits/memox-app/_features/drawer/components/LangCard.jsx`
  - `docs/design/MemoX Design System/ui_kits/memox-app/_features/drawer/components/RemoveLanguageDialog.jsx`
- `docs/design/MemoX Design System/ui_kits/memox-app/specs/drawer.md` — contract (states, copy, behaviour).
- `docs/design/MemoX Design System/ui_kits/memox-app/shots/drawer--*--{light,dark}.png` — visual reference per state.
- Shared widgets in `lib/presentation/shared/{primitives,composites}/`

## Output

- `lib/presentation/features/drawer/screens/drawer_screen.dart`
- `lib/presentation/features/drawer/providers/*.dart` — `@riverpod` notifier(s) (own mutation; call use cases)
- `lib/presentation/features/drawer/widgets/*.dart` — the 4 feature-local component(s)
- `test/presentation/features/drawer/*_test.dart`

## Steps

1. **Baseline**: `git checkout main && git pull`, `git checkout -b build/s06`.
2. Read `Drawer.jsx` → enumerate **states** (screen + `specs/drawer.md` + `shots/` filenames) and the components each renders.
3. Build feature-local components (token-only; compose shared `Mx*`).
4. Wire local UI state via a provider/notifier — no logic in build().
5. Compose the screen; strings from ARB.
6. Test **every state** (light+dark golden vs `shots/*.png`; provider-state widget tests).
7. Run Verify; add §Ledger rows; Finish.

## Notes

- Reuse shared components; build only genuinely screen-specific pieces locally.
- Feature UI must **not** import `data/` or `dart:io` — go through providers → use cases.
- Undrivable kit states → document as a gap; if FE structure diverges from the kit → **STOP** (possible drift).

## Definition of Done

- [ ] **Built** at the output path(s), respecting the layer contracts (foundation token-only · primitives no business logic · feature UI no data/ imports).
- [ ] **Analyzes** — `dart analyze lib test` → 0 issues; codegen (build_runner) up to date.
- [ ] **Tested** at the right level — domain = pure unit · data = Drift integration · primitives/composites = widget+golden (light+dark) · screens = provider-state widget tests + golden vs `shots/*.png`.
- [ ] **Parity / correctness** — UI matches the kit for every state; domain matches the v1 rules in `docs/project-management/wbs.md` with edge cases.
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
2. Push `build/s06`; open a PR; merge to main; `git checkout main && git pull`.
   > From an agent session without a design-authorized TTY, prefix: `MEMOX_SKIP_DESIGN_SYNC=1 git push …`.
3. Tick `S.06` → `[x]` in `docs/agent/build/README.md`, small commit.