# Docs manifest — {{PROJECT_NAME}}

Reading order for a cold session, and what each doc answers.

1. `docs/_generated/repo-map.md` — where everything is (regenerate with `node tool/doc_guard/run.mjs generate`).
2. `docs/_generated/where-is.md` — feature → docs/source/tests/WBS lookup.
3. `docs/architecture/overview.md` — the layering and boundaries.
4. `docs/business/glossary.md` — the domain words.
5. `docs/business/index.md` — feature list + status.
6. `docs/contracts/{error-contract,types-catalog,code-style}.md` — the universal contracts.

Everything else is task-scoped — see CLAUDE.md "Required reading by task".

<!-- FILL: as the project grows, keep this list curated, not exhaustive. -->

## Related

- `docs/README.md` — docs map
- `docs/business/glossary.md` — the domain language
- `docs/architecture/overview.md` — the layering
- `docs/contracts/code-style.md` — naming & structure
