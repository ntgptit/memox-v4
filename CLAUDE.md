# CLAUDE.md

**The full agent contract for this repo is [AGENTS.md](AGENTS.md) — read it first.**
It is tool-agnostic and authoritative; this file only surfaces the essentials and
Claude-specific notes so nothing critical is missed.

## Non-negotiables (see AGENTS.md for the rest)

1. **Never hand-edit generated code.** Token mirrors `lib/core/theme/mx_*.dart`
   are generated (change the kit CSS → `node tool/design/gen_tokens.mjs`; `--check`
   gates them) and committed. **build_runner outputs (`*.g.dart`/`*.drift.dart`/
   `*.freezed.dart`) are `.gitignore`d** — regenerated via `dart run build_runner
   build`, never committed, and **don't read them** (wasted tokens — read the
   hand-written source with the `part` directive instead).
2. **Kit is the source of truth** for visuals (`docs/design/MemoX Design System/`,
   frozen/synced). Don't patch Dart to diverge — fix the kit and `/design-sync`.
   **KIT-FIRST IS MANDATORY:** every Flutter **UI** change (new control / menu item
   / picker, visual state, layout, icon, copy placement) requires the kit to define
   it **first** — investigate the kit (a kit-parity sub-agent) before editing any
   Flutter UI; if the kit lacks it, update the kit + `/design-sync`, *then* build
   Flutter to match **exactly**. Never Flutter-only UI. Non-visual changes (data /
   domain / provider / behavior / persistence / a11y) are exempt. Enforced by the
   `PreToolUse` guard `tool/hooks/kit-first-guard.mjs`. Full rule: AGENTS.md §Golden
   rules #2.
3. **No raw `Color(0x..)`/px in UI** — use `Mx*` tokens + the `MxTheme` extension.
   **Strings from ARB**, never hardcoded.
4. **Layer contracts** (clean arch): feature UI must not import `data/`/`dart:io`;
   go through `@riverpod` providers → domain use cases. Local-first, **no remote
   backend** in v1 — "BE" = the app's `domain` + `data` layers.
5. **Coding conventions** (see AGENTS.md): **Riverpod Annotation owns all state —
   `setState` banned in feature UI**; **SQL only in `*.drift` files** (no inline
   SQL); no magic values, **no unnecessary `else`** (early return/throw/overwrite);
   all text + error messages via l10n; error handling serves **both** end-user
   (localized surface) **and** dev (logging + reporting), errors flow
   `Failure`→`AsyncValue.error`, never swallowed.
6. **Verify before "done"**: the single gate `node tool/verify/run.mjs`
   (created in WBS I.0; wraps codegen freshness + `gen_tokens --check` + analyze +
   test). Only I.0 may bootstrap with raw commands. Report skipped/failed gates
   honestly.

## Build workflow

Plan: [`docs/project-management/wbs.md`](docs/project-management/wbs.md). Per-task
loop prompts: [`docs/agent/build/`](docs/agent/build/README.md). Run with `/loop`
— it picks the next `[ ]` task by phase + deps. **S.01 dashboard is the pilot.**

## Claude-specific notes

- **Pushing from this session**: the `pre-push` hook spawns `/design-sync`, which
  hangs without a design-authorized TTY. Prefix agent pushes with
  `MEMOX_SKIP_DESIGN_SYNC=1 git push …` (not `--no-verify`).
- **Design-sync headless**:
  `MSYS_NO_PATHCONV=1 claude -p "/design-sync" --dangerously-skip-permissions` —
  the `MSYS_NO_PATHCONV=1` is required on Git Bash/Windows.
- Prefer the `flutter-full-app` skill for app-architecture work.
