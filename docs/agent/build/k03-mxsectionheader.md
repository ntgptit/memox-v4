# K.03 — MxSectionHeader

> **Loop task** (composite component). Self-contained — execute fully in one iteration, then tick `K.03` in `docs/agent/build/README.md`. One task per iteration.
>
> Size **S–L** · Deps **Phase T** · Branch `build/k03`


## Goal

Build the Flutter widget **MxSectionHeader** mirroring the kit component, driven entirely by design tokens + `MxTheme` (composite layer).

## Inputs — READ ALL IN FULL (do not infer)

- `docs/design/MemoX Design System/components/surfaces/MxSectionHeader.d.ts` — typed prop contract (variants, sizes, flags).
- `docs/design/MemoX Design System/components/surfaces/MxSectionHeader.prompt.md` — intent + JSX usage examples.
- `docs/design/MemoX Design System/components/surfaces/MxSectionHeader.jsx` — class→CSS mapping.
- `docs/design/MemoX Design System/components.css` — the base class + modifier styling for **MxSectionHeader**.
- `lib/core/theme/` — tokens + `MxTheme` extension.

## Output

- `lib/presentation/shared/composites/mx_section_header.dart`
- `test/presentation/shared/composites/mx_section_header_test.dart`

## Steps

1. **Baseline**: `git checkout main && git pull`, `git checkout -b build/k03`.
2. Read the `.d.ts` → constructor: each prop → param; string-union → Dart `enum`; flags → `bool`.
3. Read `.jsx` + the `components.css` slice → map each variant/modifier to token styling via the theme. **No raw `Color(0x..)`/px.**
4. Reproduce **every** variant/size/state the contract lists.
5. Widget + golden test: each variant in light+dark; assert token values reach the tree.
6. Run Verify; add §Ledger row(s); Finish.

## Notes

- Composite: compose primitives; feature-independent; no provider usage.
- Kit name + base class are **frozen contract** — keep `MxSectionHeader` + variant identifiers aligned.
- Strings from ARB. If `.d.ts` lists a variant the CSS never styles, note it in §Ledger — don't invent.

## Definition of Done

- [ ] **Built** at the output path(s), respecting the layer contracts (foundation token-only · primitives no business logic · feature UI no data/ imports).
- [ ] **Analyzes** — `dart analyze lib test` → 0 issues; codegen (build_runner) up to date.
- [ ] **Tested** at the right level — domain = pure unit · data = Drift integration · primitives/composites = widget+golden (light+dark) · screens = provider-state widget tests + golden vs `shots/*.png`.
- [ ] **Parity / correctness** — UI matches the kit for every state; domain matches [[memox-v1-product-decisions]] with edge cases.
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
2. Push `build/k03`; open a PR; merge to main; `git checkout main && git pull`.
   > From an agent session without a design-authorized TTY, prefix: `MEMOX_SKIP_DESIGN_SYNC=1 git push …`.
3. Tick `K.03` → `[x]` in `docs/agent/build/README.md`, small commit.