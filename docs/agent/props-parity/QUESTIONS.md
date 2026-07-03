# Props-Parity — open questions & blockers

The loop appends here when a unit is BLOCKED (STEP 5/6 failure, a kit/JSX
contradiction, or verify can't be made green). Each entry: **id · exact blocker ·
fallback/what was skipped · what's needed from the human**. Resolved items move to
`## Resolved` with the resolution. An empty `## Open` means the loop is healthy.

## Status

**✅ PROPS-PARITY COMPLETE** — all 30 tasks done (P0 F.0–F.3 · P1 C.01–C.23 · P2
Z.0–Z.2). BLOCKED: _(none — nothing was ever blocked)_. Final gate:
`node tool/parity/props_check.mjs --strict` → 83 components · 0 undeclared drift ·
192 typed exceptions · PASS, and it is now blocking in `tool/verify/run.mjs`
(wiring-guarded by `test/tooling/props_check_gate_test.dart`). No Flutter resync
was needed across all 23 feature units. The loop has stopped itself.

## Open

_(none)_

## Resolved

_(none)_

## Notes (non-blocking observations surfaced during the loop)

- **C.09 study-result/Cta — Flutter `ResultHead` lacks a `many-wrong` state.** The
  kit `Cta` has three states: default, `goal-missed`, and `many-wrong` (a "Review N
  cards" primary CTA). Flutter's `ResultHead` enum is `{standard, goalMet,
  goalMissed}` and its `Cta` switch has no `many-wrong` branch — so the
  review-wrong-answers CTA isn't implemented. This is a **behavioral/feature gap**,
  not a props-parity blocker (the `state`→`head` mapping is a typed flutter-idiom
  exception), so the loop continued. Worth a product decision: implement the
  many-wrong CTA in Flutter, or drop it from the kit.
