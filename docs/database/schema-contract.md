# Database schema contract (v1)

> **Authoritative schema contract** for the local-first MemoX store (DT.0). This
> DOC is the source of truth for DT.1 (Drift schema & tables) — every table,
> column, index, and foreign key below **must** appear in the Drift schema, and
> DT.1 adds nothing this contract does not sanction. It maps every element to the
> business rule / `D-xxx` it serves (`docs/business/`, `docs/decision-tables/
> core-decision-table.md`) and mirrors the domain entities in `lib/domain/entities/`
> (DM.2).

## Scope & conventions

- **Engine**: SQLite via Drift (DT.1). Local-only in v1 — there is **no remote
  backend** (the "BE" is the app's own `domain` + `data` layers). Account sync
  (`D-027`) and per-record `updated_at` / tombstones are **deferred** — see
  [§Deferred](#deferred-not-in-the-v1-schema).
- **Primary keys**: text (`TEXT`) ULID/UUID strings, matching the domain
  `extension type` ids (`CardId`, `DeckId`, `LanguagePairId`, `CardMeaningId`,
  `StudySessionId`) — the store never invents an integer surrogate the domain
  can't name.
- **Timestamps**: stored as UTC epoch **microseconds** (`INTEGER`) unless noted;
  the domain supplies "now" through the injected `Clock` (determinism, DM.9). A
  nullable timestamp column means "not yet / not applicable" (e.g. an unscheduled
  card has `due_at = NULL`).
- **Booleans**: `INTEGER` 0/1.
- **Enums**: stored as their stable string name (not ordinal) so a reordering of
  the Dart enum never corrupts stored rows.
- **Deletes**: hard deletes with **`ON DELETE CASCADE`** down the ownership tree
  (`D-024`); v1 keeps no tombstones.
- **SQL location**: all SQL lives in Drift `*.drift` files (AGENTS.md) — this doc
  is prose, DT.1 is the schema, no inline SQL anywhere else.

## Entity → table map

| Domain entity (`lib/domain/entities/`) | Table |
| --- | --- |
| `LanguagePair` | `language_pairs` |
| `Deck` | `decks` |
| `Card` | `cards` |
| `CardMeaning` | `card_meanings` |
| `SrsState` + `BoxLevel` | `srs_state` |
| `ReviewLog` + `ReviewGrade` | `review_logs` (grade via the `review_outcome` domain, below) |
| `StudySession` + `StudyMode` | `study_sessions` |
| (engagement roll-up) | `daily_activity` |
| `ThemeSettings` · `DailyGoal` · `Reminder` · new/day · game/round | `settings` (key–value) |
| (backup bookkeeping) | `backup_metadata` |

---

## `language_pairs`

The learning↔native language pair (`D-030`). v1 ships a single active pair, but the
table is multi-row so DT can add pairs without a migration reshaping.

| Column | Type | Null | Notes / rule |
| --- | --- | --- | --- |
| `id` | TEXT PK | no | `LanguagePairId`. |
| `learning_language` | TEXT | no | Source (learning) language code/name; trimmed non-empty (`D-030`). |
| `native_language` | TEXT | no | Target (native) language; trimmed non-empty, **≠** `learning_language` case-insensitively (`D-030` → `ValidationFailure`, enforced in the domain; the store trusts validated input). |
| `is_active` | INTEGER(bool) | no | The one active pair drives the app (single-pair v1). Exactly one row is active. |
| `created_at` | INTEGER(µs) | no | Creation instant. |

- **Rules**: `D-030` (validation), `D-011` (a card's SRS is single-direction —
  the pair defines the display direction but the schedule is one shared
  `srs_state`, not per-direction).
- **Indexes**: unique partial index on `is_active` where `is_active = 1` (at most
  one active pair).

---

## `decks`

Self-nesting deck tree (nested decks; the folder concept was removed in the v1
pivot, `D-022`). A parent node covers its whole subtree recursively for queues and
counts (`D-009`, BR-6).

| Column | Type | Null | Notes / rule |
| --- | --- | --- | --- |
| `id` | TEXT PK | no | `DeckId`. |
| `name` | TEXT | no | Trimmed non-empty (deck-management validation). |
| `parent_id` | TEXT FK→`decks.id` | **yes** | `NULL` = root deck (`Deck.isRoot`). Self-referencing FK, **`ON DELETE CASCADE`** so deleting a deck removes its subtree (`D-024`). |
| `language_pair_id` | TEXT FK→`language_pairs.id` | no | Owning pair. `ON DELETE CASCADE`. |
| `created_at` | INTEGER(µs) | no | For "date created" sort (`D-023`). |
| `sort_index` | INTEGER | no | Manual order within a parent (stable list ordering). |

- **Rules**: `D-009` (recursive subtree queue), `D-024` (cascade delete of the
  subtree: child decks + cards + meanings + srs_state), `D-023` (sort by name /
  created / last-studied), `D-022` (folders removed — decks nest directly).
- **Indexes**: `idx_decks_parent` on `parent_id` (tree walks); the recursive
  subtree read is a CTE in the deck DAO (DT.3).

---

## `cards`

A study card — a term plus ≥1 meaning, belonging to exactly one deck (BR-1).

| Column | Type | Null | Notes / rule |
| --- | --- | --- | --- |
| `id` | TEXT PK | no | `CardId`. |
| `deck_id` | TEXT FK→`decks.id` | no | Owning deck (BR-1). `ON DELETE CASCADE` (`D-024`). |
| `term` | TEXT | no | The learning-language side; trimmed non-empty (BR-2). |
| `hidden` | INTEGER(bool) | no | Set-aside flag (`D-006`). A hidden card is **excluded** from the due queue, new queue, and due counts (`D-006`, BR-8) but **included** in search (`D-028`). |
| `audio_ref` | TEXT | **yes** | Pronunciation audio reference; `NULL` until audio generation ships (deferred — DT.7 speaks live, no stored file). |
| `grammatical_gender` | TEXT | **yes** | Optional gender note. |
| `created_at` | INTEGER(µs) | no | "Date created" sort (`D-023`); import stamps it. |

- **Rules**: `D-006` (hidden excluded from queues/counts), `D-028` (hidden still
  in search), `D-020` (same term in a deck is a **soft** duplicate warning — never
  blocked, so **no** unique constraint on `(deck_id, term)`), `D-024` (cascade),
  `D-019`/`D-028` (search matches `term`).
- **Indexes**: `idx_cards_deck` on `deck_id`; a term index supporting search
  (`D-019`) — see [search](#search-d-019--d-028).

---

## `card_meanings`

One meaning block per row (`Nghĩa`, BR-3) — a card may hold several, one per
language.

| Column | Type | Null | Notes / rule |
| --- | --- | --- | --- |
| `id` | TEXT PK | no | `CardMeaningId`. |
| `card_id` | TEXT FK→`cards.id` | no | Owning card. `ON DELETE CASCADE` (a deleted card takes its meanings, `D-024`). |
| `language` | TEXT | no | Meaning language; trimmed non-empty (BR-3). |
| `content` | TEXT | no | Meaning text; trimmed non-empty (BR-3). Search matches this column (`card_meaning.content`, `D-019`). |
| `sort_index` | INTEGER | no | Order of meanings on a card (the "first" meaning is the primary shown in games/review). |

- **Rules**: BR-2 (a card needs ≥1 meaning — enforced by the domain/`SaveCard`,
  the store keeps the invariant by cascade + app logic), `D-019`/`D-028` (search
  matches `content`), `D-024` (cascade).
- **Indexes**: `idx_meanings_card` on `card_id`; a content index for search.

---

## `srs_state`

The Leitner scheduling position of a card — **one row per card**, single-direction
(`D-011`). Absent/`box 0` = a brand-new, unscheduled card.

| Column | Type | Null | Notes / rule |
| --- | --- | --- | --- |
| `card_id` | TEXT PK, FK→`cards.id` | no | 1:1 with `cards`. `ON DELETE CASCADE` (`D-024`). |
| `box` | INTEGER | no | Leitner box `0..8` (`BoxLevel`): `0` = new/unscheduled, `1` = first scheduled (`D-002`), `8` = mastered (`D-005`). A `CHECK (box BETWEEN 0 AND 8)`. |
| `due_at` | INTEGER(µs) | **yes** | Next review instant. `NULL` for a new card (box 0) and for a **mastered** card (box 8) that leaves the schedule (BR-5). `isDue(now)` = `due_at != NULL AND due_at <= now`. |
| `last_reviewed_at` | INTEGER(µs) | **yes** | Last grade instant; `NULL` before the first review. |

- **Box → due interval (days)** for boxes 1..7: **1 · 3 · 7 · 14 · 30 · 60 · 120**
  (the scheduler stamps `due_at = now + interval`, `SrsScheduler.intervalDays`);
  box 0 and box 8 are off-schedule (`due_at = NULL`).
- **Rules**: `D-002` (new → box 1 on graduating the 5-stage learn), `D-003`
  (correct → box k+1), `D-004` (wrong → box k−1, floor box 1), `D-005` (box 8 +
  correct → stays 8), `D-011` (one shared state regardless of display direction),
  `D-017` (a NewLearn abandoned before all 5 stages stays new — **no** `srs_state`
  row written / stays box 0), `D-007`/`D-013`/`D-014` (Game/Review/Player leave
  `srs_state` unchanged).
- **Indexes**: `idx_srs_due` on `(due_at)` — the due-queue read filters
  `due_at <= now` and joins non-hidden cards (`D-001`, `D-006`).

---

## `review_logs`

Append-only history of graded reviews — feeds accuracy/history stats. A row is
written on every DueReview grade (`GradeCard`), never mutated.

| Column | Type | Null | Notes / rule |
| --- | --- | --- | --- |
| `id` | TEXT PK | no | Log id. |
| `card_id` | TEXT FK→`cards.id` | no | Graded card. `ON DELETE CASCADE`. |
| `grade` | TEXT (`review_outcome`) | no | The stored `ReviewGrade` name — one of the **`review_outcome`** domain: **`pass`** (Đúng → promote, BR-3) or **`fail`** (Sai → demote, BR-4). Binary in v1 — no ease-factor grades. |
| `reviewed_at` | INTEGER(µs) | no | Grade instant — the **same** instant `GradeCard` stamps on `srs_state.last_reviewed_at` so the two writes agree. |

- **`review_outcome`** (domain enum `ReviewGrade`, stored as string): `pass` \|
  `fail`. This is the "review_outcome" the contract Notes call out — it is a stored
  **value** on `review_logs.grade`, not a separate table (a lookup table would add
  a join for a closed two-value set).
- **Rules**: `D-003`/`D-004`/`D-005` (the grade that drove the box move), accuracy
  stats (statistics spec). Practice modes record **no** log (`D-007`).
- **Indexes**: `idx_review_logs_card` on `card_id`; `idx_review_logs_at` on
  `reviewed_at` (accuracy-over-time).

---

## `study_sessions`

A finished counting session — only **"Lặp lại" (dueReview)** and **"Học"
(newLearn)** create one (`D-010`, BR-5); practice modes never do.

| Column | Type | Null | Notes / rule |
| --- | --- | --- | --- |
| `id` | TEXT PK | no | `StudySessionId`. |
| `deck_id` | TEXT FK→`decks.id` | no | The node studied (covers its subtree, BR-6, `D-009`). `ON DELETE CASCADE`. |
| `mode` | TEXT (`StudyMode`) | no | `due_review` \| `new_learn` — the two counting activities. |
| `started_at` | INTEGER(µs) | no | Session start; its calendar day is the `daily_activity` bucket. |
| `duration_minutes` | INTEGER | no | Minutes studied — summed into the day (`D-010`). |
| `words_studied` | INTEGER | no | Distinct cards studied — summed into the day (`D-010`). |

- **Rules**: `D-010` (only DueReview/NewLearn count; Game/Review/Player excluded),
  `D-007` (practice records nothing), `D-009` (parent node covers subtree).
- **Indexes**: `idx_sessions_started` on `started_at` (day roll-up).

---

## `daily_activity`

The per-day study roll-up (`daily_activity`) — the engagement source for the
dashboard, streak, and stats heatmap (`D-021`, `D-010`). One row per calendar day
(machine-local day).

| Column | Type | Null | Notes / rule |
| --- | --- | --- | --- |
| `day` | INTEGER(µs, midnight UTC of the local day) PK | no | The calendar-day bucket key. |
| `minutes` | INTEGER | no | Sum of the day's session minutes (`D-010`). |
| `words` | INTEGER | no | Sum of the day's session words (`D-010`). |

- **Rules**: `D-010` (accumulation of counting sessions), `D-021` (a day "meets"
  the goal when `minutes ≥ minutesTarget` **or** `words ≥ wordsTarget` →
  `streak +1`; a missed day resets the streak to 0). The streak itself is a **read
  model** derived from this history (`streakFromHistory`), not a stored column in
  v1 — see [§Deferred](#deferred-not-in-the-v1-schema).
- **Indexes**: PK on `day` is the lookup (activityOn / history range).

---

## `settings`

A single key–value store for app-wide preferences (the settings/personalization
surface). Modeled as `(key, value)` rows so DT can add a preference without a
migration; the DAO exposes typed getters/setters and `watch*` streams.

| Column | Type | Null | Notes |
| --- | --- | --- | --- |
| `key` | TEXT PK | no | Stable preference key. |
| `value` | TEXT | no | Serialized value (string/number/JSON per key). |

**Keys the DAO must cover** (each a live `watch*` in `SettingsRepository` /
`SettingsService`):

| Key | Value | Serves |
| --- | --- | --- |
| `theme.mode` | `light`\|`dark`\|`system` | `ThemeSettings.mode` (personalization). |
| `theme.accent` | `brand`\|`warm`\|`cool` | `ThemeSettings.accent`. |
| `theme.font_scale` | `small`\|`medium`\|`large` | `ThemeSettings.fontScale`. |
| `goal.minutes_target` | INTEGER \| null | `DailyGoal.minutesTarget` (`D-021`). |
| `goal.words_target` | INTEGER \| null | `DailyGoal.wordsTarget` (`D-021`). |
| `srs.new_cards_per_day` | INTEGER (default **20**) | `D-018` new-per-day cap. |
| `game.words_per_round` | INTEGER (default **5**) | `D-008` game round size. |
| `game.random` | bool | `D-008` random selection toggle. |
| `reminder.hour` / `reminder.minute` | INTEGER | `Reminder` time. |
| `reminder.weekdays` | JSON int set | `Reminder.weekdays` (empty = reminder off). |
| `deck.sort_criteria` / `deck.sort_dir` | enum / asc·desc | `D-023` list sort. |
| `search.status_filter` | new·due·mastered | `D-028` search status filter. |
| `import.separator` / `export.format` / `export.include_srs` | enum/bool | `D-025` / `D-026` import-export options. |

- **Rules**: `D-008`, `D-018`, `D-021`, `D-023`, `D-025`, `D-026`, `D-028`;
  personalization (theme/accent/font-scale); reminder scheduling.

---

## `backup_metadata`

Local backup/restore bookkeeping for the v1 **local** backup file (`D-027` snapshot
level). No cloud in v1 — a backup is a local file/blob the user creates and
restores (`BackupRestoreService.createBackup` / `restoreBackup`).

| Column | Type | Null | Notes |
| --- | --- | --- | --- |
| `id` | TEXT PK | no | Backup record id. |
| `schema_version` | INTEGER | no | The DB schema version the backup was written at (guards restore across `D T.2` migrations). |
| `created_at` | INTEGER(µs) | no | When the backup was taken — the **snapshot mark** used for last-write-wins at snapshot level (`D-027`). |
| `last_restored_at` | INTEGER(µs) | **yes** | When a backup was last restored; `NULL` if never. |
| `note` | TEXT | **yes** | Optional user/label note. |

- **Rules**: `D-027` (v1 = **snapshot-level last-write-wins** by the backup's
  modified mark; per-record `updated_at` + tombstones are **deferred**). Restore
  copy/format handling is the local-persistence path (no cloud/offline-sync
  wording).

---

## Search (`D-019` / `D-028`)

Global search tokenizes the query on whitespace; **each** token must match either
`cards.term` **or** `card_meanings.content` (AND across tokens, `D-019`), and the
result set **includes hidden cards** with an optional status filter (new / due /
mastered, `D-028`). Implementation: `LIKE`-based token matching over `term` +
`content` in the search DAO (DT.3); a status filter joins `srs_state.box`. (An
FTS5 virtual table is an optional DT optimization, not required by this contract.)

## Referential integrity summary

```
language_pairs 1──∞ decks (parent_id self-FK, cascade subtree)
decks 1──∞ cards ──∞ card_meanings          (cascade on deck/card delete, D-024)
cards 1──1 srs_state                        (cascade, D-024)
cards 1──∞ review_logs                      (cascade)
decks 1──∞ study_sessions                   (cascade)
study_sessions ──▶ daily_activity           (roll-up by started_at day, D-010)
settings (k/v)      backup_metadata         (standalone)
```

Every FK is **`ON DELETE CASCADE`** so deleting a deck removes its subtree of
child decks, cards, meanings, and srs_state (`D-024`); deleting a card removes its
meanings, srs_state, and review_logs.

## Deferred (not in the v1 schema)

- **Account sync / cloud** (`D-027` beyond snapshot LWW): per-record `updated_at`,
  tombstones, and a conflict-merge log are **deferred** — v1 backup is a local
  snapshot. (`account-sync` task is `[~]`.)
- **Premium** (`D-012`): no entitlement/paywall columns in v1.
- **Persisted audio** (`card.audio_ref` population): the column exists but stays
  `NULL` in v1 (TTS is live-only, DT.7).
- **Stored streak column**: the streak is derived from `daily_activity`
  (`streakFromHistory`) in v1, not stored; a materialized streak is a later
  optimization.
- **`review_outcome` as a lookup table**: kept as a stored string value on
  `review_logs.grade` (closed 2-value set); promote to a table only if grades gain
  attributes.

## Coverage self-check

All tables named in the DT.0 Notes are present: **language_pairs · decks
(self-FK) · cards · card_meanings · srs_state · review_logs (+ review_outcome
value) · study_sessions · daily_activity · settings · backup_metadata**. Decision
rows mapped: **D-001–D-011, D-013–D-021, D-023–D-026, D-028, D-030**. Deferred by
design: **D-012 (Premium), D-022 (folders removed), D-027 (sync beyond snapshot)**.
Rows `D-007/D-013/D-014` are honored as **"no write"** contracts (practice modes
touch no `srs_state` / `review_logs` / `study_sessions`).
