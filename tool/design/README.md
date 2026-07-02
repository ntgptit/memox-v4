# tool/design — Tier-0 design-token generator

Turns the design kit's **frozen CSS tokens** into their Dart mirrors under
`lib/core/theme/`. This is Tier 0 of the kit→Flutter pipeline: the layer that
was previously hand-typed (and hand-verified with mirror tests) is now a single
deterministic command with **zero per-token AI cost**.

## Why this exists

The token layer is pure key→value data. Transcribing it by hand — reading
`#4f46e5` out of CSS and typing `Color(0xFF4F46E5)` into Dart, times 135
tokens, across light + dark — is mechanical work that produced real drift bugs.
A generator does it exactly, every time.

## Usage

```bash
node tool/design/gen_tokens.mjs          # regenerate lib/core/theme/mx_*.dart
node tool/design/gen_tokens.mjs --check  # fail (exit 1) if any file is stale
```

Run the generator whenever the kit's `tokens/*.css` change (e.g. after a
`/design-sync` pull). Use `--check` in CI / a pre-commit hook so the Dart can
never silently drift from the CSS.

## Source of truth: CSS, not the manifest

Input is the nine `tokens/*.css` files under
`docs/design/MemoX Design System/tokens/` — the kit's declared single source of
truth. **Not** `_ds_manifest.json`: that compiled artifact only covers the five
files in its `globalCssPaths` and silently omits `size.css`, `icon-size.css`,
`stroke.css`, `motion.css`, and the `--memox-palette-*` accents. Parsing CSS is
complete; parsing the manifest would lose ~30 tokens.

## What it emits (116 used tokens → 6 files)

| Output | From | Shape |
|---|---|---|
| `mx_colors.dart` | `colors.css` | `MxColors` (immutable) + `.light` / `.dark`; palette accents + `seed` as static consts |
| `mx_typography.dart` | `typography.css` | `MxTypography` — sizes, weights, line-heights, letter-spacing (em) |
| `mx_spacing.dart` | `spacing.css` | `MxSpacing` — 4px scale + layout rhythm |
| `mx_radius.dart` | `radius.css` | `MxRadius` — scale + role aliases + `BorderRadius` helpers |
| `mx_elevation.dart` | `elevation.css` | `MxShadows` (immutable) + `.light` / `.dark` `List<BoxShadow>` |
| `mx_sizes.dart` | `size.css`, `icon-size.css`, `stroke.css` | `MxSizes` / `MxIconSize` / `MxStroke` |

## Prune: mirror only what the kit uses

The kit *declares* 135 tokens but its components + screens only *use* 116. A
token is kept iff it is referenced by some kit file outside `tokens/` (a
component's CSS/JSX, an assembled `ui_kits/` screen, `styles.css`…); the rest
are dropped from the Dart so the theme layer mirrors what actually renders, not
every value the kit happens to declare. The **kit CSS is never edited** — it
stays the frozen source of truth; only the Dart output is trimmed.

Currently pruned (19): all of `motion.css` (durations + easings — the static
kit doesn't animate, so no `mx_motion.dart` is emitted), `space-0`/`space-9..12`,
`letter-spacing-{normal,caps}`, `line-height-{snug,relaxed}`, `radius-field`,
`scrim`, `state-disabled`. If the Flutter app later needs one (e.g. motion for
transitions), it becomes used the moment something references it — or add it to
a keep-list. Every run logs exactly what it pruned.

Color conversion: `#hex` and `rgb()/rgba()` → `Color(0xAARRGGBB)` with
`alpha = round(a·255)` (matches the prior hand-verified values exactly). CSS
`box-shadow` layers → `BoxShadow`; a 4-value ring (`0 0 0 1px`) → zero-blur
`BoxShadow(spreadRadius: 1)`.

## Drift guard

Every `--memox-*` property parsed from the CSS must be consumed by exactly one
emitter, or the run aborts listing the orphans. So a **new** kit token can never
slip in unmirrored and unnoticed. Genuinely-derived tokens with no standalone
Dart literal (`--memox-ring-focus`, the `--memox-font-*` family stack) are in an
explicit `SKIP` set with a documented reason.

## Where it fits

```
/design-sync (pull kit)  →  tokens/*.css change
        →  node tool/design/gen_tokens.mjs   ← Tier 0 (this)  ← pure code, no AI
        →  Tier 1: components read MxColors/MxSpacing/… (AI, once per component)
        →  Tier 2: screens compose verified components
```

Regeneration is theme-invariant and idempotent: same CSS in → identical Dart out.
