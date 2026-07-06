# Visual parity — kit ↔ Flutter (`tool/visual-diff`)

Diffs each **Flutter screen golden** against the frozen **kit shot** of the same
`<screen>--<state>--<theme>.png` name. The kit shots
(`docs/design/MemoX Design System/ui_kits/memox-app/shots/`) are exported at
390×780 — the exact size the goldens render at — so the kit shot is the
visual-parity source of truth. This is the G.2 half of the golden-parity WBS; the
golden coverage itself (114/114 states) is owned by `tool/golden/scaffold.mjs`.

## Why perceptual, not exact

Kit shots are browser-rendered; goldens are Skia-rendered. Anti-aliasing and font
hinting differ pixel-for-pixel even when the screens are visually identical, and
the goldens deliberately seed **different content** (names, dates, counts) than
the kit shots. So a straight pixel-equality check is meaningless. `diff.mjs` ports
pixelmatch's YIQ colour delta: sub-threshold differences don't count, so only real
divergences (missing element, wrong colour/layout, absent state) raise a state's
mismatch %. Dependency-free (PNG decode/encode via `node:zlib`) per repo convention.

## Usage

```bash
# 1. render the goldens (ephemeral; never committed)
flutter test --tags golden-parity --update-goldens

# 2. rank every state by divergence, worst-first
node tool/visual-diff/diff.mjs

# a browsable report (kit | flutter | red-diff), worst 24 states
node tool/visual-diff/diff.mjs --html build/visual-parity/report.html

# only some states
node tool/visual-diff/diff.mjs --filter statistics
```

Flags: `--kit <dir>` `--goldens <dir>` `--threshold <0..1>` (perceptual colour
tolerance, default 0.1) `--html <path>` `--html-top <N>` `--filter <substr>`
`--limit <N>`.

## Gating (CI ratchet) — G.3

Absolute pixel parity across renderers is impossible, so CI does **not** gate on a
fixed threshold. Instead `.github/workflows/goldens.yml` (ubuntu):

1. renders the goldens, then runs the diff with
   `--baseline tool/visual-diff/baseline.json --tolerance 3 --fail-over 92`;
2. **ratchet** — fails only when a state diverges **more** than its recorded
   baseline + tolerance (catches a regression that pulls a screen away from the
   kit; accepts the existing cross-renderer + content noise);
3. **catastrophic gate** — `--fail-over 92` fails a blank/errored/mis-sized screen
   (~100% on any renderer — platform-independent);
4. uploads the HTML report as an artifact.

`baseline.json` is **platform-specific** (Skia render), so it must be written from
ubuntu, never a dev machine. Seed/refresh it after a reviewed visual change via the
workflow's `workflow_dispatch` → `seed_baseline` input (runs `--write-baseline` and
commits). Until it is seeded the ratchet is skipped (non-fatal) and only the
catastrophic gate is active.

Not wired into `tool/verify/run.mjs`: that gate runs on dev machines (Windows),
where Skia renders differently and the diff would be noise. Visual parity is a
CI-only (ubuntu) concern.
