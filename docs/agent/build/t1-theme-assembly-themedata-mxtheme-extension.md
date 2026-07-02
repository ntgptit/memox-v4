# T.1 — Theme assembly (ThemeData + MxTheme extension)

> **Loop task** (theme / UI foundation). Self-contained — execute fully in one iteration, then tick `T.1` in `docs/agent/build/README.md`. One task per iteration.
>
> Size **L** · Deps **I.3** · Branch `build/t1`


## Goal

ThemeData light/dark from tokens + a ThemeExtension for roles Material cannot express.

## Inputs — read first

- `lib/core/theme/mx_*.dart`
- `docs/design/MemoX Design System/components.css`
- `docs/design/MemoX Design System/readme.md (VISUAL FOUNDATIONS)`

## Output

- `lib/core/theme/app_theme.dart`
- `lib/core/theme/mx_theme.dart`

## Steps

1. **Baseline**: `git checkout main && git pull`, `git checkout -b build/t1`.
2. Read the inputs above in full.
3. Implement the goal, respecting layer contracts; tokens only for any visual value.
4. Test per the Definition of Done.
5. Run Verify.
6. Finish (commit → PR → merge → tick).

## Notes

- ColorScheme.fromSeed(MxColors.seed) then override with tokens.
- MxTheme carries: surface{,Muted,Raised,Sunken}, *Soft semantic pairs, state overlays, focusRing, MxShadows, radii; lerp + copyWith.

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
2. Push `build/t1`; open a PR; merge to main; `git checkout main && git pull`.
   > From an agent session without a design-authorized TTY, prefix: `MEMOX_SKIP_DESIGN_SYNC=1 git push …`.
3. Tick `T.1` → `[x]` in `docs/agent/build/README.md`, small commit.