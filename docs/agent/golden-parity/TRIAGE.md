# Visual-parity triage — kit ↔ Flutter (2026-07-07)

First triage of the `tool/visual-diff` output (G.2). Goal: for the highest
divergences, separate **real Flutter bugs** from **noise** (content / scrim / AA)
and **stale kit shots**. Method: read each kit shot beside its Flutter golden and
compare directly.

## Outcome 1 — FIXED: icons were tofu in every golden

`test/flutter_test_config.dart` loaded the text font (Plus Jakarta Sans) but not
**MaterialIcons**, so every icon rendered as a `□` box in goldens. Text was
faithful; icons were not — and the tofu polluted the visual diff badly (e.g.
`deck-detail--deck-menu--light` 55.6% → dropped out of the worst list once icons
render). Fixed by loading every font in the built asset manifest (incl.
MaterialIcons, bundled via `uses-material-design: true`). This makes **all**
goldens faithful, not just the ones triaged here.

## Outcome 2 — STALE KIT SHOT (Flutter is correct): `dashboard--empty`

The kit shot `dashboard--empty--{light,dark}` still shows the **old** design — a
greeting ("Good evening, Linh") + an empty Today card (00:00 / 0 words). Flutter
correctly renders the **new onboarding** design (Start your first deck · Create a
deck / Import from a file · How MemoX works) that was built into the kit earlier
this engagement (task: "Redesign kit dashboard empty state"). The kit **source**
was updated but the **shot was never re-exported**, so it lags the JSX.

→ Not a Flutter bug. The shot needs re-exporting from Claude Design. The Flutter
`dashboard--not-studied` golden (which has **no** kit shot) is the state the stale
`empty` shot actually depicts — the kit's state naming lags Flutter's split of
`empty` (onboarding) vs `not-studied`. Same "changed this engagement but shot not
refreshed" risk applies to other screens touched recently (search textfield
borders, screen gutter/padding, greeting split).

## Outcome 3 — NOISE: different seeded content (the bulk of the residual score)

The goldens seed different data than the kit shots, so the background diverges —
heavily in **light** (the scrim lets content show through) and negligibly in
**dark** (the dark scrim flattens both). This is the whole story behind the
light/dark asymmetry on the overlay states:

| state | light | dark | cause |
|---|---|---|---|
| `deck-detail--add-menu` | 62% | 4.6% | Flutter deck = **Food** (leaf, 3 cards); kit = **Korean Basics** (sub-decks + cards) |
| `deck-detail--card-actions` | 61% | 4.2% | same background-content mismatch |
| `dashboard--loaded/goal-met/streak-reset` | ~19% | ~19% | greeting/name/date/counts differ ("Good evening, Linh · Sat 27 Jun" vs "Good morning · Fri 3 Jul") |

Not Flutter bugs. To sharpen the signal either (a) seed the goldens with the same
deck/content the kit shot uses, or (b) export each fixture's `contentMask` rects to
JSON so `diff.mjs` can exclude them. `contentMask` is only worthwhile where the
divergence is *localized* (a name, a date); where the **entire** background differs
(add-menu), seed-alignment is the real fix.

## Outcome 4 — CANDIDATE (low severity): deck-detail menu icon tiles

The deck-detail action menus (`add-menu`, `card-actions`, `deck-menu`) wrap each
row's icon in a coloured `MxIconTile`; the kit shot uses a plain line icon. Visible
in light, hidden in dark (a subtle tile on a dark sheet ≈ the kit). Real but small,
and entangled with the content noise above so it can't be isolated from the score
alone. Flag for a dedicated kit-first pass (confirm the kit's intended menu-row
treatment, then align) — not fixed here.

## Verdict

No structural/layout Flutter bugs in the top offenders. The score is driven by, in
order: (1) tofu icons **[fixed]**, (2) different seeded content **[noise]**, (3) a
stale `dashboard--empty` shot **[re-export]**, (4) a minor menu-tile styling
divergence **[flag]**. The visual diff is doing its job — it surfaced a genuine
golden-fidelity bug (icons) and a stale-shot drift on the first pass.

## Follow-ups (not blocking)

1. Re-seed the ubuntu ratchet baseline after the icon-font fix (the committed
   baseline predates it) — trigger `goldens` → `seed_baseline` on main.
2. Re-export the stale kit shots for screens changed this engagement (dashboard
   empty/onboarding, search, padding) via Claude Design.
3. Optional: align golden seeds to kit-shot content, or add a `contentMask` → JSON
   export for localized-content states.
4. Optional kit-first pass on the deck-detail menu icon-tile treatment.
