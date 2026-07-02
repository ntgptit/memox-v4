# K.10 — ConfirmDialog

> **Loop task** (composite component). Self-contained — execute fully in one iteration, then tick `K.10` in `docs/agent/build/README.md`. One task per iteration.
>
> Size **S–L** · Deps **Phase T** · Branch `build/k10`


## Goal

Build the Flutter widget **ConfirmDialog** mirroring the kit component, driven entirely by design tokens + `MxTheme` (composite layer).

## Inputs — READ ALL IN FULL (do not infer)

- `docs/design/MemoX Design System/ui_kits/memox-app/_shared/ConfirmDialog.d.ts` — typed prop contract (variants, sizes, flags).
- `docs/design/MemoX Design System/ui_kits/memox-app/_shared/ConfirmDialog.prompt.md` — intent + JSX usage examples.
- `docs/design/MemoX Design System/ui_kits/memox-app/_shared/ConfirmDialog.jsx` — class→CSS mapping.
- `docs/design/MemoX Design System/components.css` — the base class + modifier styling for **ConfirmDialog**.
- `lib/core/theme/` — tokens + `MxTheme` extension.

## Output

- `lib/presentation/shared/composites/confirm_dialog.dart`
- `test/presentation/shared/composites/confirm_dialog_test.dart`

## Steps

1. **Baseline**: `git checkout main && git pull`, `git checkout -b build/k10`.
2. Read the `.d.ts` → constructor: each prop → param; string-union → Dart `enum`; flags → `bool`.
3. Read `.jsx` + the `components.css` slice → map each variant/modifier to token styling via the theme. **No raw `Color(0x..)`/px.**
4. Reproduce **every** variant/size/state the contract lists.
5. Widget + golden test: each variant in light+dark; assert token values reach the tree.
6. Run Verify; add §Ledger row(s); Finish.

## Notes

- Composite: compose primitives; feature-independent; no provider usage.
- Kit name + base class are **frozen contract** — keep `ConfirmDialog` + variant identifiers aligned.
- Strings from ARB. If `.d.ts` lists a variant the CSS never styles, note it in §Ledger — don't invent.

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
2. Push `build/k10`; open a PR; merge to main; `git checkout main && git pull`.
   > From an agent session without a design-authorized TTY, prefix: `MEMOX_SKIP_DESIGN_SYNC=1 git push …`.
3. Tick `K.10` → `[x]` in `docs/agent/build/README.md`, small commit.