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
| 3 | search · results/filtered | search input shows a purple border; kit is plain | FIX | todo |
| 4 | statistics · loaded/scope-switch (dark) | heatmap dots too pale/low-contrast in dark | FIX? | todo (verify) |
| 5 | deck-detail · add-menu | header "ADD" vs kit "ADD TO ‹deck›" (deck name dropped) | FIX? | todo (verify) |
| 6 | study-session · stage3/5 | progress shown as n/N bar; kit shows a % header | FIX? | todo (verify kit intent) |
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
