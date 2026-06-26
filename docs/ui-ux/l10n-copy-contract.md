# Copy / l10n contract — MemoX V4

Every user-facing string is a defined key — never hardcoded in features (hard rule).

## Where strings live

ARB ở `lib/l10n/` (`app_en.arb`, `app_vi.arb`); sinh accessor bằng `gen_l10n`
(`flutter gen-l10n`), dùng `AppLocalizations.of(context)`. Thêm key vào **cả hai** ARB.

## Rules

- Add a key, reference it; no inline literals in UI code.
- Key names are semantic (`folder.delete.confirm`, not `text1`).
- Every failure that reaches the user (`docs/contracts/error-contract.md`) has a key.
- Each new key is referenced from the screen/feature doc that introduced it.
- Run the project's l10n generation step (through `tool/verify`) after adding keys.

## Voice

Ngắn gọn, đời thường, không jargon. Dùng đúng thuật ngữ ở `docs/business/glossary.md`.
Ngôn ngữ chính: Tiếng Việt (+ English).

## Related

- `docs/contracts/error-contract.md` — copy for failures
- `docs/ui-ux/ui-ux-contract.md` — UI rules
