# Use case contract: <Entity>

> Copy to `docs/contracts/usecase-contracts/<entity>.md`. One file per entity; one
> section per use case. Delete this line.

## <VerbNounUseCase>

**Input:** <params + types>
**Output:** <success type> | failure from `docs/contracts/error-contract.md`
**Reads / writes:** <repositories touched>

### Preconditions

- <!-- FILL: what must be true before this runs. -->

### Behavior

1. <!-- FILL: numbered steps, including every branch. -->

### Postconditions / invariants

- <!-- FILL: what is guaranteed true after success. -->

### Failure modes

| Condition | Failure |
| --- | --- |
| <bad input> | ValidationFailure |
| <missing> | NotFoundFailure |

### Decision rows

<!-- FILL: link the branches to docs/decision-tables/core-decision-table.md row ids. -->

## Related

- `docs/contracts/error-contract.md` — failures returned
- `docs/contracts/types-catalog.md` — input/output types
- `docs/contracts/repository-contracts/_template.md` — repositories it depends on
- `docs/decision-tables/core-decision-table.md` — branch rows
- `docs/business/_feature-template.md` — the feature spec
