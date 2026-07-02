# S.03 — deck-detail

> **Loop task** (screen). Self-contained — execute fully in one iteration, then tick `S.03` in `docs/agent/build/README.md`. One task per iteration.
>
> Size **L** · Deps **Phase K,H + DM.6** · Branch `build/s03`


## Goal

Build the **deck-detail** screen + its 5 feature-local component(s), composed from the shared `Mx*` widgets, rendering **DM.6** use-case state via `@riverpod` providers, matching the kit for every state.

## Inputs — READ ALL IN FULL

- `docs/design/MemoX Design System/ui_kits/memox-app/_features/deck-detail/DeckDetail.jsx` — screen composition (components, states, state machine).
- Feature-local components (build here):
  - `docs/design/MemoX Design System/ui_kits/memox-app/_features/deck-detail/components/DeckHeader.jsx`
  - `docs/design/MemoX Design System/ui_kits/memox-app/_features/deck-detail/components/DeckMenu.jsx`
  - `docs/design/MemoX Design System/ui_kits/memox-app/_features/deck-detail/components/DeleteConfirmDialog.jsx`
  - `docs/design/MemoX Design System/ui_kits/memox-app/_features/deck-detail/components/FlashcardRow.jsx`
  - `docs/design/MemoX Design System/ui_kits/memox-app/_features/deck-detail/components/SubDeckCard.jsx`
- `docs/design/MemoX Design System/ui_kits/memox-app/specs/deck-detail.md` — contract (states, copy, behaviour).
- `docs/design/MemoX Design System/ui_kits/memox-app/shots/deck-detail--*--{light,dark}.png` — visual reference per state.
- Shared widgets in `lib/presentation/shared/{primitives,composites}/`
- Domain use cases: `lib/domain/usecases/` (**DM.6**)

## Output

- `lib/presentation/features/deck-detail/screens/deck_detail_screen.dart`
- `lib/presentation/features/deck-detail/providers/*.dart` — `@riverpod` notifier(s) (own mutation; call use cases)
- `lib/presentation/features/deck-detail/widgets/*.dart` — the 5 feature-local component(s)
- `test/presentation/features/deck-detail/*_test.dart`

## Steps

1. **Baseline**: `git checkout main && git pull`, `git checkout -b build/s03`.
2. Read `DeckDetail.jsx` → enumerate **states** (screen + `specs/deck-detail.md` + `shots/` filenames) and the components each renders.
3. Build feature-local components (token-only; compose shared `Mx*`).
4. Build the `@riverpod` provider(s) calling **DM.6** use cases (use in-memory fakes until DT.5 lands); render with `AsyncValue.when`.
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
2. Push `build/s03`; open a PR; merge to main; `git checkout main && git pull`.
   > From an agent session without a design-authorized TTY, prefix: `MEMOX_SKIP_DESIGN_SYNC=1 git push …`.
3. Tick `S.03` → `[x]` in `docs/agent/build/README.md`, small commit.