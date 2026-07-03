# Design-sync → regenerate → drift-gate loop

> The authoritative description of how a **UI-kit change flows into the app** and
> how CI guarantees the Dart token mirrors never drift from the kit (V.7). The kit
> is the source of truth for visuals (`docs/design/MemoX Design System/`); this
> doc ties the pull → regenerate → gate steps together and names the exact
> commands, files, and CI hook for each.

## The loop at a glance

```
   kit CSS/JSX (source of truth)
            │  ① edit tokens in the kit
            ▼
   node tool/design/gen_tokens.mjs          ② regenerate the Dart token mirrors
            │      → lib/core/theme/mx_*.dart  (committed, hand-edits forbidden)
            ▼
   node tool/design/gen_tokens.mjs --check  ③ drift gate — fails if the mirrors
            │                                   don't match the kit CSS
            ▼
   node tool/verify/run.mjs (local + CI)    ④ the single gate runs ③ every time
            │                                   (verify.yml → run.mjs → tokens())
            ▼
   .githooks/pre-push + post-merge          ⑤ push the kit back to Claude Design
                                               (design-sync) so the two agree
```

## ① Source of truth

The kit under `docs/design/MemoX Design System/` is frozen and authoritative for
every visual value — colors, typography, spacing, radius, elevation, size,
icon-size, stroke, motion, and the `--memox-palette-*` accents. **Never** hand-edit
a value in the Dart layer to diverge from the kit; fix the kit and regenerate. No
raw `Color(0x..)`/px in UI — only `Mx*` tokens (AGENTS.md).

## ② Regenerate the token mirrors

`node tool/design/gen_tokens.mjs` parses the kit's CSS token files and emits their
Dart mirrors into `lib/core/theme/mx_*.dart` (colors, typography, spacing, radius,
elevation, sizes, …). These files are **generated and committed** — they are the
one exception to "generated code is gitignored" (build_runner outputs are
gitignored; the token mirrors are not, because they have no build step and must be
diffable). **Do not hand-edit `mx_*.dart`** — the header of each says so.

The generator has its own **drift guard**: every `--memox-*` custom property parsed
from the CSS must be consumed by exactly one emitter (or be listed in `SKIP`); an
unconsumed token aborts the run — so a new kit token can never slip in unmirrored.

## ③ The drift gate

`node tool/design/gen_tokens.mjs --check` regenerates in memory and **compares**
against the committed `mx_*.dart`. It exits non-zero if they differ — i.e. if
someone changed the kit CSS without regenerating, or hand-edited a mirror. This is
the parity gate at the token layer.

## ④ CI wiring (the single gate)

There is one gate script, `tool/verify/run.mjs`, and the drift gate is a
first-class step in it (`tokens()` → `gen_tokens.mjs --check`), run in **both** the
full and `--docs` modes. CI (`.github/workflows/verify.yml`, `ubuntu-latest`) runs
`node tool/verify/run.mjs` on every pull request and push to `main`, so the drift
gate runs on CI automatically — no separate CI step is added (that would duplicate
the single-gate design). A **wiring guard** test
(`test/tooling/design_sync_gate_test.dart`) locks this: it fails if `run.mjs` stops
invoking `gen_tokens --check` or if `verify.yml` stops running the gate, so the
drift gate cannot be silently dropped.

## ⑤ Design-sync (push the kit back to Claude Design)

Two git hooks keep the remote Claude Design project in step with the repo kit
(both **push**, repo → Claude Design; see `.design-sync/NOTES.md` for the log):

- **`.githooks/pre-push`** — on a `git push` whose range touches the design dir;
  runs `sync-design.mjs --no-record`.
- **`.githooks/post-merge`** — after `main` receives kit changes (covers
  server-side PR merges + agent pushes that bypass pre-push); record mode, advances
  `lastSyncedCommit`.

Both honor `MEMOX_SKIP_DESIGN_SYNC=1`. **Agent sessions without a design-authorized
TTY must prefix both `git push` and `git pull` on `main`** with it, or the nested
`claude` hangs.

**Headless design-sync** (proven, from `.design-sync/NOTES.md`):

```bash
MSYS_NO_PATHCONV=1 claude -p "/design-sync" --dangerously-skip-permissions --max-turns 40
```

The `MSYS_NO_PATHCONV=1` is **required** on Git Bash / Windows — without it, Git Bash
rewrites the `/design-sync` argument into a Windows path before it reaches `claude`,
so the slash command never runs.

## When you touch a token

1. Edit the value in the **kit CSS** (source of truth).
2. `node tool/design/gen_tokens.mjs` — regenerate the Dart mirrors.
3. Commit the kit change **and** the regenerated `mx_*.dart` together.
4. `node tool/verify/run.mjs` — the drift gate (③) confirms they agree; analyze +
   tests confirm nothing broke.
5. Push — the design-sync hook (⑤) reconciles the remote Claude Design project.

If you forget step 2, the drift gate (③/④) red-lines locally and on CI before the
change can merge.
