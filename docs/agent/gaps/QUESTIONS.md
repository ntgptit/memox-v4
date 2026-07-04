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
