# Screen state matrix

**One authoritative table per screen listing every state that must be built.**
Derived from the kit shots (`docs/design/MemoX Design System/ui_kits/memox-app/shots/`
— filenames encode `<screen>--<state>--<theme>.png`) cross-checked against the
per-screen specs and the business rules. Each Phase-S task (`S.01`…`S.21`) builds
**exactly** the rows for its screen — no happy-path-only screens.

> `S.22 account-sync` is **deferred in v1** (D-027); its shots exist but are not
> built. Rows for it are omitted here.

## Canonical state kinds

Every row is tagged with one kind. A screen only lists the kinds it actually has.

| Kind | Meaning |
| --- | --- |
| `loading` | data is being fetched (skeletons / spinner). |
| `empty` | no content yet — a first-run/empty-collection `MxEmptyState`. |
| `filtered-empty` | a query/scope returned nothing (distinct copy from `empty`). |
| `error` | load failed — a retryable error surface (`Failure` → `AsyncValue.error`). |
| `success` | the normal loaded content. |
| `partial` | loaded but a sub-state changes the render (goal met, streak reset…). |
| `overlay` | a menu / sheet / picker / dropdown over the screen. |
| `destructive` | a confirm dialog for a data-loss action (`showMxConfirmDialog`). |
| `validation` | inline field validation / soft-duplicate warning. |
| `persistence` | a save/finalize in-flight or its failure (retry surface). |
| `interaction` | a transient in-activity state (selected / correct / wrong / revealed…). |
| `nav` | a state whose purpose is to route elsewhere. |

**Rule:** the state's copy + error messages come from ARB; every error state is
both surfaced to the user (localized) **and** logged. Cite the `D-xxx` a state
enforces so the screen's tests cover it.

---

## S.01 · dashboard  (engagement)

Spec `dashboard.md` · shots `dashboard--*`.

| State | Kind | Shows | D-xxx |
| --- | --- | --- | --- |
| `loading` | loading | activity/goal/streak skeletons | — |
| `empty` | empty | no activity yet — prompt to start learning | — |
| `loaded` | success | today's minutes + words, goal, current + longest streak | D-010 |
| `goal-met` | partial | goal reached → streak advances | D-021 |
| `streak-reset` | partial | a missed day zeroed the current streak | D-021 |

## S.02 · library  (deck-management)

Spec — · shots `library--*`. Toolbar (search/sort/create) renders in **all**
states (FE↔kit divergence, `tool/parity/intent-ledger.json`).

| State | Kind | Shows | D-xxx |
| --- | --- | --- | --- |
| `loading` | loading | deck-tree skeletons | — |
| `empty` | empty | no decks — create the first deck | — |
| `error` | error | load failed — retry | — |
| `loaded` | success | root deck list (name · counts · progress · due badge) | D-023 |
| `search-active` | success | in-library card search results | D-019 |
| `sort-menu` | overlay | alphabetical / created / last-studied ± direction | D-023 |
| `overflow-menu` | overlay | per-deck actions (rename / move / delete) | D-024 |
| `pair-picker` | overlay | switch the active language pair | D-030 |
| `play-sheet` | overlay | the 5 study entry points for a deck | — |
| `drawer` | nav | opens the app drawer | — |

## S.03 · deck-detail

Spec `deck-detail.md` · shots `deck-detail--*`.

| State | Kind | Shows | D-xxx |
| --- | --- | --- | --- |
| `loading` | loading | card-list skeletons | — |
| `empty` | empty | deck has no cards — add / import | — |
| `error` | error | load failed — retry | — |
| `loaded` | success | cards (term · meaning · status badge · hidden dim) | D-006 |
| `search` | success | in-deck search | D-019 |
| `no-results` | filtered-empty | search matched nothing | D-019 |
| `add-menu` | overlay | add card / import | — |
| `deck-menu` | overlay | rename / move / delete deck | — |
| `card-actions` | overlay | edit / hide / delete a card | D-006 |
| `move` | overlay | move the deck (cycle-free target picker) | — |
| `delete-confirm` | destructive | delete a card (cascade meanings + SRS) | D-024 |
| `deck-delete-confirm` | destructive | delete the deck + whole subtree | D-024 |
| `reset-confirm` | destructive | reset the deck's SRS progress | — |

## S.04 · search  (global-search)

Spec — · shots `search--*`.

| State | Kind | Shows | D-xxx |
| --- | --- | --- | --- |
| `empty-recent` | empty | no query yet — recent searches | — |
| `loading` | loading | searching | — |
| `results` | success | matches (term+meaning, incl. hidden) | D-019, D-028 |
| `filtered` | success | results narrowed by a status filter | D-028 |
| `no-results` | filtered-empty | query matched nothing | D-019 |

## S.05 · settings

Spec — · shots `settings--*`.

| State | Kind | Shows | D-xxx |
| --- | --- | --- | --- |
| `loaded` | success | grouped settings list | — |
| `group-expanded` | success | an expanded settings group | — |
| `value-picker` | overlay | pick a value (e.g. game words / day) | D-008 |

## S.06 · drawer

Spec `drawer.md` · shots `drawer--*`.

| State | Kind | Shows | D-xxx |
| --- | --- | --- | --- |
| `open` | success | pairs + nav destinations | — |
| `add-language` | overlay | create a language pair | D-030 |
| `remove-language` | destructive | remove a pair (+ its content) | D-030 |

## S.07 · reminder

Spec — · shots `reminder--*`.

| State | Kind | Shows | D-xxx |
| --- | --- | --- | --- |
| `off` | success | reminders disabled | — |
| `on` | success | enabled — time + weekdays | — |
| `time-picker` | overlay | pick the reminder time | — |

## S.08 · theme  (personalization)

Spec — · shots `theme--*`.

| State | Kind | Shows | D-xxx |
| --- | --- | --- | --- |
| `light` | success | light mode preview | — |
| `dark` | success | dark mode preview | — |
| `accent-size` | success | accent-colour + font-size choices | — |

## S.09 · statistics

Spec — · shots `statistics--*`.

| State | Kind | Shows | D-xxx |
| --- | --- | --- | --- |
| `loading` | loading | chart skeletons | — |
| `loaded` | success | heatmap · box distribution · forecast · accuracy | D-010 |
| `insufficient` | empty | not enough data yet | — |
| `scope-switch` | overlay | selected-pair ↔ whole-app scope | — |

## S.10 · import  (import-export)

Spec — · shots `import--*`.

| State | Kind | Shows | D-xxx |
| --- | --- | --- | --- |
| `source` | success | pick file / paste + separator | D-025 |
| `mapping` | success | map term / meaning columns | D-025 |
| `preview` | success | parsed rows before writing | D-025 |
| `dup-warning` | validation | soft-duplicate count (still allowed) | D-020 |
| `done` | success | import complete summary | — |

## S.11 · export  (import-export)

Spec `export.md` · shots `export--*`.

| State | Kind | Shows | D-xxx |
| --- | --- | --- | --- |
| `config` | success | format + include-SRS options | D-026 |
| `exporting` | persistence | export in progress | — |
| `done` | success | export complete | D-026 |

## S.12 · flashcard-editor  (flashcard-management)

Spec `flashcard-editor.md` · shots `flashcard-editor--*`.

| State | Kind | Shows | D-xxx |
| --- | --- | --- | --- |
| `create` | success | new card form | — |
| `edit` | success | editing an existing card | — |
| `multi-meaning` | success | multiple meaning blocks | — |
| `audio` | success | TTS pronounce control | — |
| `duplicate` | validation | soft-duplicate term warning | D-020 |
| `validation` | validation | missing required term / meaning | — |

## S.13 · game-picker  (study-flow / game-modes)

Spec `game-picker.md` · shots `game-picker--*`.

| State | Kind | Shows | D-xxx |
| --- | --- | --- | --- |
| `default` | success | the four games | — |
| `not-enough` | empty | deck lacks enough words to play | — |
| `scope-dropdown` | overlay | choose the deck/subtree scope | — |

## S.14 · game-matching

Spec `game-matching.md` · shots `game-matching--*`.

| State | Kind | Shows | D-xxx |
| --- | --- | --- | --- |
| `playing` | success | the matching board | D-008 |
| `selected` | interaction | a tile is selected | — |
| `correct` | interaction | a correct pair | — |
| `wrong` | interaction | a wrong pair → re-queued | D-015 |
| `almost` | partial | near the end of the round | — |
| `complete` | success | round finished | — |

## S.15 · game-mc  (multiple choice)

Spec `game-mc.md` · shots `game-mc--*`.

| State | Kind | Shows | D-xxx |
| --- | --- | --- | --- |
| `waiting` | success | question + options | D-008 |
| `correct` | interaction | correct choice revealed | — |
| `wrong` | interaction | wrong choice → re-queued | D-015 |
| `complete` | success | round finished | — |

## S.16 · game-recall

Spec — · shots `game-recall--*`.

| State | Kind | Shows | D-xxx |
| --- | --- | --- | --- |
| `before-reveal` | success | prompt, answer hidden | — |
| `revealed` | interaction | answer shown | — |
| `remembered` | interaction | self-graded correct | — |
| `forgot` | interaction | self-graded wrong → re-queued | D-015 |
| `complete` | success | round finished | — |

## S.17 · game-typing

Spec — · shots `game-typing--*`.

| State | Kind | Shows | D-xxx |
| --- | --- | --- | --- |
| `waiting` | success | prompt + input | D-008 |
| `typing` | interaction | user typing | — |
| `hint` | interaction | a hint revealed | — |
| `correct` | interaction | exact answer | — |
| `wrong` | interaction | wrong → re-queued | D-015 |
| `complete` | success | round finished | — |

## S.18 · review  (browse mode)

Spec — · shots `review--*`. Browsing does **not** change the SRS schedule.

| State | Kind | Shows | D-xxx |
| --- | --- | --- | --- |
| `browsing` | success | flip through term ↔ meaning | — |
| `audio` | interaction | pronounce the term | — |
| `editing` | overlay | inline card edit | — |
| `end` | success | reached the last card | — |

## S.19 · player  (auto-play)

Spec — · shots `player--*`. Player does **not** change the schedule.

| State | Kind | Shows | D-xxx |
| --- | --- | --- | --- |
| `playing` | success | auto-advancing with audio | D-014 |
| `paused` | interaction | playback paused | — |
| `speed` | overlay | playback-speed picker | — |
| `end` | success | playlist finished | — |

## S.20 · study-session  (study-flow — the SRS core UI)

Spec — · shots `study-session--*`. The 5-stage new-learn + due-review.

| State | Kind | Shows | D-xxx |
| --- | --- | --- | --- |
| `due-review` | success | one due card, self-grade | D-016, D-003, D-004 |
| `stage1-review` | success | new-learn stage 1 (review) | D-002 |
| `stage2-matching` | success | new-learn stage 2 | D-002 |
| `stage3-choice` | success | new-learn stage 3 | D-002 |
| `stage4-recall` | success | new-learn stage 4 | D-002 |
| `stage5-typing` | success | new-learn stage 5 → card enters box 1 | D-002 |
| `relearn` | interaction | wrong answer re-queues the card | D-015 |
| `resume` | persistence | resume a partially-done session | — |
| `resume-error` | error | resume failed — retry | — |
| `answer-save-error` | persistence | grade save failed — retry, don't lose progress | D-007 |
| `exit` | destructive | leave mid-session (new cards stay `new`) | D-017 |

## S.21 · study-result

Spec — · shots `study-result--*`.

| State | Kind | Shows | D-xxx |
| --- | --- | --- | --- |
| `finalizing` | persistence | writing the session outcome | — |
| `finalize-error` | error | finalize failed | — |
| `retry-finalize` | persistence | retry the failed finalize | — |
| `standard` | success | session summary + "Continue" (reruns the mode) | D-029 |
| `goal-met` | partial | day's goal reached this session | D-021 |
| `goal-missed` | partial | goal not yet reached | D-021 |
| `many-wrong` | partial | many cards missed — encouragement copy | — |

---

## Gaps / notes

- `S.22 account-sync` shots exist (`signed-out/signed-in/syncing/offline/conflict`)
  but the feature is **deferred (D-027)** — not built in v1.
- Overlay/menu states (`*-menu`, `*-picker`, `*-dropdown`, `*-sheet`) reuse the
  shared `MxSheet` / `showMxConfirmDialog` / menu composites; each screen wires its
  own copy from ARB.
- Every `error` / `*-save-error` / `*-error` row must route a `Failure` →
  `AsyncValue.error` to a localized retry surface **and** log it (AGENTS.md error
  contract) — this is the "local-persistence (save/load)" column of the brief.
