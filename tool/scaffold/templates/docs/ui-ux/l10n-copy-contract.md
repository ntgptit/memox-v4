# Copy / l10n contract — {{PROJECT_NAME}}

Every user-facing string is a defined key — never hardcoded in features (hard rule).

## Where strings live

<!-- FILL: the i18n mechanism for {{STACK}} (resource files, ARB, JSON catalogs)
     and where new keys are added. -->

## Rules

- Add a key, reference it; no inline literals in UI code.
- Key names are semantic (`folder.delete.confirm`, not `text1`).
- Every failure that reaches the user (`docs/contracts/error-contract.md`) has a key.
- Each new key is referenced from the screen/feature doc that introduced it.
- Run the project's l10n generation step (through `tool/verify`) after adding keys.

## Voice

<!-- FILL: tone (concise, plain, no jargon), capitalization, terminology aligned to glossary. -->

## Related

- `docs/contracts/error-contract.md` — copy for failures
- `docs/ui-ux/ui-ux-contract.md` — UI rules
