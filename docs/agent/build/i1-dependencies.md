# I.1 — Dependencies

> **Loop task** (infrastructure). Self-contained — execute fully in one iteration, then tick `I.1` in `docs/agent/build/README.md`. One task per iteration.
>
> Size **S** · Deps **—** · Branch `build/i1`


## Goal

Add and pin the v1 stack dependencies.

## Inputs — read first

- `pubspec.yaml`
- `docs/project-management/wbs.md (Architecture)`

## Output

- `pubspec.yaml`

## Steps

1. **Baseline**: `git checkout main && git pull`, `git checkout -b build/i1`.
2. Read the inputs above in full.
3. Implement the goal, respecting layer contracts; tokens only for any visual value.
4. Test per the Definition of Done.
5. Run Verify.
6. Finish (commit → PR → merge → tick).

## Notes

- flutter_riverpod + riverpod_annotation + riverpod_generator
- drift + drift_flutter + sqlite3_flutter_libs
- go_router
- equatable or freezed
- build_runner + custom_lint + riverpod_lint
- flutter_localizations + intl. Pin versions; run pub get.

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
2. Push `build/i1`; open a PR; merge to main; `git checkout main && git pull`.
   > From an agent session without a design-authorized TTY, prefix: `MEMOX_SKIP_DESIGN_SYNC=1 git push …`.
3. Tick `I.1` → `[x]` in `docs/agent/build/README.md`, small commit.