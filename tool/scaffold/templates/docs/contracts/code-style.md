# Code style — {{PROJECT_NAME}}

Naming and structure rules the reviewer enforces. Keep this short and absolute.

## Naming

- Semantic names; one responsibility per class/file.
- <!-- FILL: casing per layer, file naming, test naming for {{STACK}}. -->

## Structure

- Early return; no unnecessary `else`; fail fast.
- No magic values — named constants/tokens only.
- No business logic in controllers/UI.
- Functions do one thing; extract when a block needs a comment to explain "what".

## Errors & results

- Return/propagate failures via the taxonomy in `docs/contracts/error-contract.md`.
- <!-- FILL: your result/error idiom, e.g. Result<T,E> / exceptions / Either. -->

## Imports

- Respect the layering in `docs/architecture/overview.md`. No reverse imports.

## Comments

- Comment "why", not "what". Match the density of surrounding code.

## Related

- `docs/contracts/error-contract.md` — result/error idiom
- `docs/contracts/types-catalog.md` — shared types
- `docs/architecture/overview.md` — layer boundaries
