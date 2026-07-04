# Gaps loop — open questions & blockers

The loop appends here when a unit is BLOCKED (needs a human decision with no safe
default, or can't be made green honestly). Resolve, then the human removes the id
from `BLOCKED.txt` so a later firing retries it.

## Open

### G.02 — statistics "This pair / All" scope-switch — BLOCKED (needs an architectural decision)

**Blocker.** Implementing real pair-scoped stats requires reversing a *deliberate,
frozen* v1 design — there is no safe default I can pick autonomously:

- `DeckRepository` is **FROZEN (R4)** ("Frozen once screens code against it") — I
  must not add a `watchRoots({pairId})`-style method to it.
- The `Deck` **entity is deliberately minimal** — its doc states it carries only
  `id` / `name` / `parentId` by design; it does **not** expose `languagePairId`
  even though the `decks` table has the FK. So the provider cannot filter roots by
  pair without enriching the entity + mapper (and touching the `save` path).
- **The whole app is currently pair-agnostic**: both `library_providers.dart:89`
  and `statistics_providers.dart` read `decks.watchChildren(null)` = **all roots
  across all pairs**, with no pair filter anywhere. So scoping stats *alone* to
  "This pair" would be **inconsistent** with the library (which still shows all
  pairs), and would surprise the user.

**What I tried.** Traced deck↔pair from the table (`decks.languagePairId` FK exists)
up through the DAO (`watchChildren` has no pair WHERE), the frozen repo interface,
and the minimal entity. Confirmed no existing active-pair deck query to reuse.

**What I need (pick one):**
1. **Approve enriching the domain** — add `languagePairId` to the `Deck` entity +
   mapper (interface stays frozen; entity gains a backward-compatible field), and
   apply "This pair" scoping **app-wide** (library + stats + games) for consistency.
   Bigger, but the honest fix. → then I implement it as its own change.
2. **Stats-only, cosmetic-honest** — add the segmented control but have both
   segments show the same (all-pairs) data in v1, with a note that per-pair scoping
   lands when the app becomes multi-pair-aware. (Low value; a control that does
   nothing.)
3. **Leave deferred** — keep the documented v1 gap as-is (recommended until the app
   actually needs multi-pair scoping).

Default taken: **none** — blocked, loop continued to the next unit. The stats donut
already shows *mastery* (a real number), so nothing is broken; only the pair toggle
is absent.

> **Shared root with G.05:** both need the *same* decision — whether to enrich the
> deliberately-minimal `Deck` entity beyond `id`/`name`/`parentId`. Deciding once
> unblocks the data-model side of both.

### G.05 — library sort "Date created" + "Last studied" — BLOCKED (data model)

**Blocker.** The kit SortSheet offers 4 orders; Flutter has 2 (`alphaAsc`,
`alphaDesc`). The two missing ones can't be added with a safe autonomous default:

- **Date created** — the `decks` table *has* a `createdAt` column, but the `Deck`
  entity **deliberately omits it** ("carries no created/last-studied columns, so
  this entity has none"). Sorting by it means enriching the entity + mapper (and
  touching 22 `Deck.create` call sites) — **the same minimal-entity reversal
  blocked for G.02**.
- **Last studied** — there is **no per-deck last-studied data anywhere** (only
  global day-totals; no per-deck review timestamp). This needs a new schema column
  + a write on every review to record it — real tracking infra, not a sort tweak.

**What I tried.** Confirmed the sort lives in `library_providers._sort` over
`LibraryNode`; traced date-created to the table column the entity hides, and
searched the whole tree for any per-deck last-studied field (none exists).

**What I need (pick one):**
1. **Enrich `Deck`** (add `createdAt`, resolving the shared G.02/G.05 entity
   decision) → I implement **Date created**. **Last studied** stays deferred until
   per-deck review tracking exists.
2. **Add per-deck last-studied tracking** (schema column + review write path) →
   both orders become drivable.
3. **Leave deferred** — keep the two alpha orders (recommended for v1).

Default taken: **none** — blocked. Alphabetical A→Z / Z→A both work; nothing is
broken, only the two extra orders are absent.

## Notes (non-blocking)

- **G.08 accent live re-theming — deferred (design-system, not Flutter).** Font
  scale now applies live app-wide (shipped). Accent does not: the token system is
  single-accent — `AccentColor {brand,warm,cool}` exists but only `brand` has a
  generated color token. Making accent live needs the **kit** to define warm/cool
  accent token sets and regenerate `mx_*.dart` (which must not be hand-edited).
  Accent stays persisted + previewed until that kit change happens. Not a Flutter
  gap; out of the gaps-loop scope.
