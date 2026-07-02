# S.07 — reminder

> **Loop task** (screen). Self-contained — execute fully in one iteration, then tick `S.07` in `docs/agent/build/README.md`. One task per iteration.
>
> Size **M** · Deps **Phase K + DM.8** · Branch `build/s07`


## Goal

Build the **reminder** screen + its 2 feature-local component(s), composed from the shared `Mx*` widgets, rendering **DM.8** use-case state via `@riverpod` providers, matching the kit for every state.

## Inputs — READ ALL IN FULL

- `docs/design/MemoX Design System/ui_kits/memox-app/_features/reminder/Reminder.jsx` — screen composition (components, states, state machine).
- Feature-local components (build here):
  - `docs/design/MemoX Design System/ui_kits/memox-app/_features/reminder/components/TimeCol.jsx`
  - `docs/design/MemoX Design System/ui_kits/memox-app/_features/reminder/components/TimePickerSheet.jsx`
- `docs/design/MemoX Design System/ui_kits/memox-app/specs/reminder.md` — contract (states, copy, behaviour).
- `docs/design/MemoX Design System/ui_kits/memox-app/shots/reminder--*--{light,dark}.png` — visual reference per state.
- Shared widgets in `lib/presentation/shared/{primitives,composites}/`
- Domain use cases: `lib/domain/usecases/` (**DM.8**)

## Output

- `lib/presentation/features/reminder/screens/reminder_screen.dart`
- `lib/presentation/features/reminder/providers/*.dart` — `@riverpod` notifier(s) (own mutation; call use cases)
- `lib/presentation/features/reminder/widgets/*.dart` — the 2 feature-local component(s)
- `test/presentation/features/reminder/*_test.dart`

## Steps

1. **Baseline**: `git checkout main && git pull`, `git checkout -b build/s07`.
2. Read `Reminder.jsx` → enumerate **states** (screen + `specs/reminder.md` + `shots/` filenames) and the components each renders.
3. Build feature-local components (token-only; compose shared `Mx*`).
4. Build the `@riverpod` provider(s) calling **DM.8** use cases (use in-memory fakes until DT.5 lands); render with `AsyncValue.when`.
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
- [ ] **Parity / correctness** — UI matches the kit for every state; domain matches the v1 rules in `docs/business/` with edge cases.
- [ ] **Decision Table** — every `D-xxx` row in `docs/decision-tables/core-decision-table.md` this task touches has a covering test; cite the `D-xxx` id(s) in the Ledger. (Deferred rows: D-012 Premium, D-022 REMOVED, D-027 sync.)
- [ ] **Ledger** — row(s) added to `docs/project-management/wbs.md §Ledger` (kit/D-xxx node → Dart symbol → test).
- [ ] **Gates green** — `node tool/verify/run.mjs` passes (codegen freshness + `gen_tokens --check` + analyze + test). (I.0 not done yet → fall back to the raw commands.)

## Verify (must pass before commit)

```bash
node tool/verify/run.mjs          # full gate: codegen freshness + gen_tokens --check + analyze + test
node tool/verify/run.mjs --quick  # analyze + test only (fast, while iterating)
node tool/verify/run.mjs --docs   # doc/spec freshness + gen_tokens --check only
```

> Until **I.0** creates the runner, fall back to the raw commands:
> `dart run build_runner build --delete-conflicting-outputs && node tool/design/gen_tokens.mjs --check && dart analyze lib test && flutter test`.

## STOP conditions (do not push through)

- Source is **ambiguous or looks wrong** / a business or structural **drift** needs a human decision → STOP, report the exact mismatch, wait.
- A kit state / product rule is **undrivable or underspecified** → document as a gap in §Ledger, don't fabricate.
- **Verify fails** and you cannot fix at root cause → STOP, report the failing step + output.

## Finish

1. Commit(s): implementation + test(s). End messages with the Co-Authored-By trailer.
2. Push `build/s07`; open a PR; merge to main; `git checkout main && git pull`.
   > From an agent session without a design-authorized TTY, prefix: `MEMOX_SKIP_DESIGN_SYNC=1 git push …`.
3. Tick `S.07` → `[x]` in `docs/agent/build/README.md`, small commit.