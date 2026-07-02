# S.05 — settings

> **Loop task** (screen). Self-contained — execute fully in one iteration, then tick `S.05` in `docs/agent/build/README.md`. One task per iteration.
>
> Size **M** · Deps **Phase K,H + DM.8** · Branch `build/s05`


## Goal

Build the **settings** screen + its 2 feature-local component(s), composed from the shared `Mx*` widgets, rendering **DM.8** use-case state via `@riverpod` providers, matching the kit for every state.

## Inputs — READ ALL IN FULL

- `docs/design/MemoX Design System/ui_kits/memox-app/_features/settings/Settings.jsx` — screen composition (components, states, state machine).
- Feature-local components (build here):
  - `docs/design/MemoX Design System/ui_kits/memox-app/_features/settings/components/Profile.jsx`
  - `docs/design/MemoX Design System/ui_kits/memox-app/_features/settings/components/ValuePickerSheet.jsx`
- `docs/design/MemoX Design System/ui_kits/memox-app/specs/settings.md` — contract (states, copy, behaviour).
- `docs/design/MemoX Design System/ui_kits/memox-app/shots/settings--*--{light,dark}.png` — visual reference per state.
- Shared widgets in `lib/presentation/shared/{primitives,composites}/`
- Domain use cases: `lib/domain/usecases/` (**DM.8**)

## Output

- `lib/presentation/features/settings/screens/settings_screen.dart`
- `lib/presentation/features/settings/providers/*.dart` — `@riverpod` notifier(s) (own mutation; call use cases)
- `lib/presentation/features/settings/widgets/*.dart` — the 2 feature-local component(s)
- `test/presentation/features/settings/*_test.dart`

## Steps

1. **Baseline**: `git checkout main && git pull`, `git checkout -b build/s05`.
2. Read `Settings.jsx` → enumerate **states** (screen + `specs/settings.md` + `shots/` filenames) and the components each renders.
3. Build feature-local components (token-only; compose shared `Mx*`).
4. Build the `@riverpod` provider(s) calling **DM.8** use cases (use in-memory fakes until DT.5 lands); render with `AsyncValue.when`.
5. Compose the screen; strings from ARB.
6. Test **every state** (light+dark golden vs `shots/*.png`; provider-state widget tests).
7. Run Verify; add §Ledger rows; Finish.

## Notes

- Reuse shared components; build only genuinely screen-specific pieces locally.
- **State via `@riverpod` only — no `setState`.** Render `AsyncValue` with `.when`; the **error** branch shows a localized user surface (inline/empty-error per the kit) AND the cause is logged/reported. Errors never swallowed.
- Feature UI must **not** import `data/` or `dart:io` — go through providers → use cases.
- **v1 scope**: no cloud/account sync — any kit "Cloud sync / Sync (alpha)" element renders as **local Backup / Restore** (or is omitted); save/load errors say **local persistence**, not cloud/offline sync. `account-sync` is deferred.
- Undrivable kit states → document as a gap; if FE structure diverges from the kit → **STOP** (possible drift).

## Accessibility (build it right — don't port JSX shortcuts)

The kit's JSX takes web a11y shortcuts (`div onClick`, `disabled` = class only,
icon ligature as the label). **Do NOT mirror those.** Build the proper accessible
Flutter widget:

- Interactive surfaces (cards/rows/tiles/options) = `InkWell`/`GestureDetector`
  wrapped in `Semantics(button: true, …)` — Flutter gives focus + Enter/Space
  free; never a bare tap on a plain container.
- Disabled = a **real** disabled state (e.g. `onChanged: null`, `onPressed: null`),
  not just a dimmed style; the control must not fire when disabled.
- Every icon-only button needs a `Semantics`/`tooltip` label **from ARB**
  (Back, Close, More options, Play audio, Clear search…) — never the Material
  icon name.
- Selection groups (segmented / choice) = `Semantics(inMutuallyExclusiveGroup:
  true, selected: …)` (radio semantics), each option individually addressable.
- Touch targets ≥ `MxSpacing.minTouchTarget` (48).

## Definition of Done

- [ ] **Built** at the output path(s), respecting the layer contracts (foundation token-only · primitives no business logic · feature UI no data/ imports).
- [ ] **Conventions** (AGENTS.md) — state via **@riverpod only, no `setState`** in feature UI · **SQL only in `*.drift`** (no inline SQL) · no magic values, **no unnecessary `else`** (early return/throw/overwrite) · all text + error messages via l10n · errors flow `Failure` → `AsyncValue.error`, shown localized to the user **and** logged/reported for devs, never swallowed.
- [ ] **Analyzes** — `dart analyze lib test` → 0 issues; codegen (build_runner) up to date.
- [ ] **Tested** at the right level — domain = pure unit · data = Drift integration · primitives/composites = widget+golden (light+dark) · screens = provider-state widget tests + golden vs `shots/*.png`.
- [ ] **Parity / correctness** — UI matches the kit for every state; domain matches the v1 rules in `docs/business/` with edge cases.
- [ ] **Decision Table** — every `D-xxx` row in `docs/decision-tables/core-decision-table.md` this task touches has a covering test; cite the `D-xxx` id(s) in the Ledger. (Deferred rows: D-012 Premium, D-022 REMOVED, D-027 sync.)
- [ ] **Ledger** — row(s) added to `docs/project-management/wbs.md §Ledger` (kit/D-xxx node → Dart symbol → test).
- [ ] **Gates green** — `node tool/verify/run.mjs` passes (codegen freshness + `gen_tokens --check` + analyze + test).

## Verify (must pass before commit)

```bash
node tool/verify/run.mjs          # full gate: codegen freshness + gen_tokens --check + analyze + test
node tool/verify/run.mjs --quick  # analyze + test only (fast, while iterating)
node tool/verify/run.mjs --docs   # doc/spec freshness + gen_tokens --check only
```

## STOP conditions (do not push through)

- Source is **ambiguous or looks wrong** / a business or structural **drift** needs a human decision → STOP, report the exact mismatch, wait.
- A kit state / product rule is **undrivable or underspecified** → document as a gap in §Ledger, don't fabricate.
- **Verify fails** and you cannot fix at root cause → STOP, report the failing step + output.

## Finish

1. Commit(s): implementation + test(s). End messages with the Co-Authored-By trailer.
2. Push `build/s05`; open a PR; merge to main; `git checkout main && git pull`.
   > From an agent session without a design-authorized TTY, prefix: `MEMOX_SKIP_DESIGN_SYNC=1 git push …`.
3. Tick `S.05` → `[x]` in `docs/agent/build/README.md`, small commit.