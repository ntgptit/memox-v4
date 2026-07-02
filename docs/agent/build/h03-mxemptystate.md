# H.03 — MxEmptyState

> **Loop task** (shared helper (composite)). Self-contained — execute fully in one iteration, then tick `H.03` in `docs/agent/build/README.md`. One task per iteration.
>
> Size **S** · Deps **Phase T** · Branch `build/h03`


## Goal

Build **MxEmptyState** — the Flutter port of the kit's `EmptyState` helper — as a reusable composite, token-driven. These helpers are reused across many screens; building them shared avoids per-screen re-derivation.

## Inputs — READ IN FULL

- `docs/design/MemoX Design System/ui_kits/memox-app/kit-helpers.jsx` — find `function EmptyState` (the exact styling + tokens).
- `docs/design/MemoX Design System/components.css` — any `.mxg-*` class it uses.
- `lib/core/theme/` — tokens + `MxTheme`.

## Output

- `lib/presentation/shared/composites/mx_empty_state.dart`
- `test/presentation/shared/composites/mx_empty_state_test.dart`

## Steps

1. **Baseline**: `git checkout main && git pull`, `git checkout -b build/h03`.
2. Read `function EmptyState` in `kit-helpers.jsx` → derive props + token-based styling. **No raw `Color(0x..)`/px.**
3. icon + title + text + optional action, centered. Every empty state.
4. Widget + golden test (light+dark, each tone/variant).
5. Run Verify; add §Ledger row(s); Finish.

## Notes

- Composite: compose primitives; feature-independent; no provider usage.
- Name it `MxEmptyState` (Mx-prefixed shared widget). Strings from ARB.

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
2. Push `build/h03`; open a PR; merge to main; `git checkout main && git pull`.
   > From an agent session without a design-authorized TTY, prefix: `MEMOX_SKIP_DESIGN_SYNC=1 git push …`.
3. Mark done: append `H.03` to `docs/agent/build/DONE.txt`, run `node tool/design/gen_task_prompts.mjs` (renders `[x]` in the queue), commit.