# Visual-parity convergence log

Living ledger for the recursive **compare → fix → review** loop: diff each Flutter
golden against the kit shot (`tool/visual-diff` + direct image reads), fix real
divergences kit-first, regenerate, re-review, repeat until a full sweep is dry.

Persist EVERY finding here so context survives across loop iterations.

## Disposition legend
- **FIX** — visual/layout/styling bug, Flutter has the impl → fix to match kit.
- **DEFER-STALE** — kit shot predates a Flutter change; Flutter is correct → needs a Claude Design re-export (design-side, not a Flutter fix).
- **DEFER-V1** — kit shows a feature v1 defers (e.g. Sync = no backend); adding it = dead UI → product decision, not a blind fix.
- **DEFER-CONTENT** — different seed data / test-font glyph coverage; not an app bug.
- **DONE** — fixed + regenerated + reviewed against kit.

## Status board

| # | screen · state | finding (kit vs flutter) | disp | status |
|---|---|---|---|---|
| 1 | reminder · on; editor · gender | interactive MxChip stretched full-width in a Wrap → chips stacked vertical | FIX | **DONE** (#246) |
| 2 | deck-detail/library/game-picker · menus | sheet rows tiled MxListRow vs kit plain-icon MenuItem | FIX | **DONE** (#246) |
| 3 | search · results/filtered | search input shows a purple border; kit is plain | ~~FIX~~ | **NON-BUG** — kit `.search-dock--focused` has the ring; golden captured focus vs kit's unfocused shot |
| 4 | statistics · loaded/scope-switch (dark) | heatmap dots too pale/low-contrast in dark | DEFER-CONTENT | Flutter seeds 5 days → sparse grid; empty-cell faintness dominates. Layout + scope toggle match. Re-verify with a dense seed |
| 5 | deck-detail · add-menu | header "ADD" vs kit "ADD TO ‹deck›" (deck name dropped) | FIX | **DONE** — new `deckDetailAddToTitle`; sheet now "Add to ‹deck›" (verified) |
| 6 | study-session · stage3/5 | progress shown as n/N bar; kit shows a % header | ~~FIX~~ | **NON-BUG** — kit `ProgressHeader` = bar + "{done}/{total}", same as Flutter (agent misread bar-fill % as label) |
| 7 | drawer · open | Flutter missing FAQ / Email us / Sync items + "Menu" label | DEFER-V1 | noted (Sync = no v1 backend; confirm FAQ/Email) |
| 8 | import · mapping | Flutter has an extra "first row is header" toggle not in kit | DEFER-V1 | noted (Flutter-ahead — add to kit or drop) |
| 9 | theme · accent | kit shows 6 accent swatches; Flutter shows 3 | DEFER-V1 | noted (is v1 palette 3 or 6?) |
| 10 | review · browsing/editing | Flutter missing "TT"/format + menu top-bar controls | DEFER-V1 | noted (likely v1-simplified) |
| 11 | dashboard · empty | kit shot = old not-studied; Flutter = new onboarding | DEFER-STALE | noted (re-export shot) |
| 12 | study-session · * | Korean term renders as tofu boxes in goldens | DEFER-CONTENT | noted (Plus Jakarta lacks CJK; could add a CJK fallback font to the test loader) |
| 13 | drawer · add-language | selector shows placeholder; kit shows a chosen language | DEFER-CONTENT | noted (no pair seeded) |
| 14 | settings · value-picker | radio-row styling nuance | FIX? | todo (partly addressed by MxMenuItem #2 — re-check) |

## Iteration notes
(newest first — What / verified / fix / review result)

### Iteration 1 (2026-07-07) — verified the "likely real" batch (#3–#6)
Read each kit↔golden pair + kit source. Result: **1 real bug of 4** (the rest were
kit-correct once checked against the source — a good sign the app is faithful now
that the 2 systemic bugs + icon font are fixed).
- #3 search purple border → NON-BUG: kit `.search-dock--focused` adds the same
  ring; the golden captured the focused field (drive typed a query) while the kit
  results shot is unfocused. Optional: unfocus the fixture for a resting-state shot.
- #4 statistics heatmap "pale in dark" → CONTENT: the fixture records 5 days, so
  the grid is nearly empty vs the kit's dense one; the empty-cell colour dominates.
  Layout + scope toggle match. Re-check contrast with a dense seed before calling
  it a bug.
- #5 add-menu header → FIXED: kit sheet is "Add to ‹deck›" (DeckDetail.jsx), Flutter
  showed just "Add". Added `deckDetailAddToTitle`; verified the golden now reads
  "ADD TO FOOD" with plain icons.
- #6 study-session progress → NON-BUG: the kit `ProgressHeader(done,total)` renders
  a bar + "{done}/{total}" — identical to Flutter's MxProgressHeader; the agent
  misread the bar-fill percentage as the label.
