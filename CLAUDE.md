# CLAUDE.md

**The full agent contract for this repo is [AGENTS.md](AGENTS.md) — read it first.**
It is tool-agnostic and authoritative; this file only surfaces the essentials and
Claude-specific notes so nothing critical is missed.

## Non-negotiables (see AGENTS.md for the rest)

1. **Never hand-edit `lib/core/theme/mx_*.dart`** — generated. Change the kit CSS,
   run `node tool/design/gen_tokens.mjs`; `--check` is the gate.
2. **Kit is the source of truth** for visuals (`docs/design/MemoX Design System/`,
   frozen/synced). Don't patch Dart to diverge — fix the kit and `/design-sync`.
3. **No raw `Color(0x..)`/px in UI** — use `Mx*` tokens + the `MxTheme` extension.
   **Strings from ARB**, never hardcoded.
4. **Layer contracts** (clean arch): feature UI must not import `data/`/`dart:io`;
   go through `@riverpod` providers → domain use cases. Local-first, **no remote
   backend** in v1 — "BE" = the app's `domain` + `data` layers.
5. **Verify before "done"**: the single gate `node tool/verify/run.mjs`
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
