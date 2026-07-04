# State-parity audit (trục ③: kit `States:` ↔ Flutter state machine)

> Props-parity (trục ①) gác **API surface**; DOM-spec/token gate (trục ②) gác
> **visual**. This audit covers the **third axis — behaviour/state**: for every
> state each kit screen declares in its `States:` header, does the Flutter
> provider/widget actually handle it? Read-only sweep of 22 screens (account-sync
> excluded — deferred, no Flutter). ~90 states total.

## Verdict

**~90 kit states across 22 screens — every one is either IMPLEMENTED or
MODELED-DIFFERENTLY, except 5 items (3 MISSING, 2 PARTIAL).** Crucially, **all 5
are documented, reasoned v1 deferrals** (recorded in the WBS ledger + provider
comments at build time) — **none is a silent conversion loss.** The conversion
dropped nothing unknowingly.

"MODELED-DIFFERENTLY" = handled, just not as a discrete state: `loading/error` →
`AsyncValue`, `empty` → `isEmpty` branch, a menu/sheet → `showMxSheet`, a
transient correct/wrong → a per-answer result field, a separate route (search,
drawer) → its own screen.

## The 5 gaps (all documented v1 deferrals)

| # | Screen / state | Kind | What's absent | Why deferred (documented at) |
|---|---|---|---|---|
| 1 | study-result / **many-wrong** | MISSING | "Review N cards" error-tone result + the per-session correct% stat | **Undrivable in v1**: no per-session accuracy / wrong-count store (only day totals). `ResultHead` has no `manyWrong`; the 3rd stat shows "of goal" instead. `wbs.md:677-680` (S.21) |
| 2 | deck-detail / **reset-confirm** | MISSING | Per-card "reset progress" action + confirm dialog | "Reset progress (**no v1 use case**)" — intentionally omitted. `deck_menu.dart:8`, `wbs.md:871` |
| 3 | statistics / **scope-switch** | MISSING | "This pair / All" segmented control | Documented v1 gap (no pair↔content scoping). `statistics_providers.dart:62-65` |
| 4 | study-result / **retry-finalize** | PARTIAL | `FinalizingView(retry:true)` variant is never routed to | S.20 commits SRS **during** the flow, so there is no separate finalize step to retry — the `AsyncValue.loading` FinalizingView covers the read. `wbs.md:680-682` |
| 5 | settings / **group-expanded** | PARTIAL | SRS detail sub-page (Leitner boxes, intervals, due-notifications switch) — no drill-in | Rendered as one static info row; sub-page deferred. `settings_screen.dart:28` |

## Behaviour-fidelity notes (state IS implemented; only the depth is limited — NOT state gaps)

- **player / speed** — rate is selectable but not applied to the TTS engine (`player_providers.dart:16-18`).
- **import / mapping** — column mapping fixed A→term / B→meaning (no picker) (`import_providers.dart:83-85`).
- **library / sort** — only alphabetical ordering (no date-created / last-studied).
- **search / recents** — session-only (no persistent store).
- **theme / accent-size** — accent + font-scale are persisted + previewed, but not live app-wide re-themed (single-accent token system) (`theme_providers.dart:42-43`).
- **game-matching / correct** — `MatchTone.correct` skin exists but the screen never emits it (a correct pair collapses straight to `matched`, skipping the flash). Cosmetic.

## Per-group result

| Group | Screens | Gaps |
|---|---|---|
| Games | game-matching, game-mc, game-picker, game-recall, game-typing | none |
| Study | study-session (clean), **study-result** | many-wrong (MISSING), retry-finalize (PARTIAL) |
| Nav/Data | dashboard, library, search (clean), **statistics**, **deck-detail** | scope-switch (MISSING), reset-confirm (MISSING) |
| Content | review, player, flashcard-editor, import, export | none (multi-meaning IS implemented via `showSecondary`) |
| Utility | drawer, reminder, theme (clean), **settings** | group-expanded (PARTIAL) |

## Bottom line

All three kit↔Flutter axes are now accounted for:
- **① API (props)** — 83 components, 0 undeclared drift, blocking gate.
- **② Visual (tokens/DOM)** — token gate + DOM spec (done earlier).
- **③ Behaviour (states)** — ~90 states covered; the only 5 non-implemented are
  documented v1 scope decisions with recorded root causes, **not drift**.

If v1 scope is to be widened, the highest-value candidates are #1 (many-wrong —
needs a per-session accuracy store first) and #5 (settings SRS sub-page). #2/#3
are explicitly "no v1 use case". #4 is architecturally unnecessary (no separate
finalize step exists to retry).
