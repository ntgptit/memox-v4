# Screen briefs — business intent & copy keys

One `NN-<screen>.md` per screen. These are **human design briefs**: context,
layout intent, the states to cover, the Flutter mapping (target architecture),
and the **ARB copy keys** each screen needs.

## What these are (and aren't)

- **Use them for**: business intent, per-screen state semantics, and the copy-key
  lists when wiring l10n. They carry meaning the kit's machine specs deliberately
  omit (the kit says "MOCK COPY — never use; source from ARB").
- **Not the build spec.** The authoritative, executable build instructions are
  the loop prompts in [`docs/agent/build/`](../../agent/build/README.md) (which
  point at the kit's own `specs/*.md` + `shots/*.png`). Where they disagree, the
  **kit + build prompts win**; open an issue rather than following a brief.
- Paths here target the WBS architecture
  ([`docs/project-management/wbs.md`](../../project-management/wbs.md) §Architecture).

## Index

`03` (folder) is intentionally absent — folders were dropped for nested decks
(2026-06-28). `19-account-sync` is deferred in v1.

| # | Screen | Build prompt |
| --- | --- | --- |
| 01 | library | `s02-library` |
| 02 | dashboard | `s01-dashboard` |
| 04 | deck-detail | `s03-deck-detail` |
| 05 | flashcard-editor | `s12-flashcard-editor` |
| 06 | study-session | `s20-study-session` |
| 07 | game-picker | `s13-game-picker` |
| 08 | game-matching | `s14-game-matching` |
| 09 | game-multiple-choice | `s15-game-mc` |
| 10 | game-recall | `s16-game-recall` |
| 11 | game-typing | `s17-game-typing` |
| 12 | review | `s18-review` |
| 13 | player | `s19-player` |
| 14 | study-result | `s21-study-result` |
| 15 | search | `s04-search` |
| 16 | statistics | `s09-statistics` |
| 17 | settings | `s05-settings` |
| 18 | reminder | `s07-reminder` |
| 19 | account-sync | ⊘ deferred |
| 20 | theme | `s08-theme` |
| 21 | import | `s10-import` |
| 22 | export | `s11-export` |
| 23 | drawer | `s06-drawer` |
