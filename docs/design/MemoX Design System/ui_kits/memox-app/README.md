# MemoX — App UI Kit

A high-fidelity, click-through recreation of the MemoX mobile app (local-first flashcard / spaced-repetition study). Every screen is assembled **only** from the `Mx*` component family — no loose card/button/layout markup — and rendered through all of its states in **light + dark**.

## Open

`index.html` is the gallery. Each **row** is one screen; a **stepper** cycles its states; each state is framed in a phone-sized **device frame** with a **label**, shown in both themes.

## Screens & states

- **Dashboard.jsx** — `dashboard/screen`. States: `loaded` (due summary, streak/accuracy, deck list), `empty`, `loading` (skeleton).
- **Library.jsx** — `library/screen`. States: `loaded`, `no-results`, `empty`, `loading`.
- **StudySession.jsx** — `study-session/screen`. States: `front` (prompt), `back` (revealed + Again/Hard/Good/Easy), `done` (session summary).
- **Settings.jsx** — `settings/screen`. State: `loaded` (profile, preference switches, study segmented control).

`kit-helpers.jsx` holds kit-only composites built from primitives + tokens (`ProgressBar`, `Skeleton`, `EmptyState`, `DeckRow`) and exports them to `window`.

## Identity contract

Every meaningful node carries a stable `data-mx-node="<screen>/<node>"` — e.g. `dashboard/due-summary`, `library/search-dock`, `study-session/progress`. These are semantic anchors: keep the id on the equivalent node through any redesign; new nodes get new ids; never reuse or delete an id. Shared primitives receive their `data-mx-node` from the call site (passed as the `node` prop).

## Load order (important)

`_ds_bundle.js` (plain) → `kit-helpers.jsx` → screen modules → gallery. Screens read components from `window.MemoXDesignSystem_2ffa54` and export themselves to `window`.

## Note

This is a **recreation/scaffold** for prototyping, not production code — interactions are cosmetic (state stepping, switches/segments), and copy is realistic placeholder.
