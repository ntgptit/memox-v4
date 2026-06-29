# NIGHT-LOG — unattended build issues

Append-only journal for the overnight loop (`prompts/RUN-LOOP.md` → Overnight driver).
The loop does **not** ask — every problem, decision, or skipped part is recorded here and
the loop continues. Read this in the morning to see what merged and what needs a human.

Entry format:

```
## <YYYY-MM-DD HH:mm> · <step id, e.g. W8> · <DONE | BLOCKED | NOTE>
- What: <what happened>
- Where: <file / area>
- Error: <key excerpt, if any>
- Action: <committed+pushed <hash> / parked via git stash / safe default applied>
- Suggested fix: <for the human>
```

DONE entries can be a single line: `## <ts> · <step> · DONE · <hash> · <one-line summary>`.

---

<!-- The overnight loop appends below this line. -->

## 2026-06-28 · GAP item 4/8 · W4 RoundController · DONE · c3e78e43 · verify --full GREEN (162 tests)

- What: closed the W4 "simplified self-grade" gap. New RoundState + RoundActions (presentation/features/game/round.dart). The 4 game widgets now take (RoundState, RoundActions) instead of GameRequest + reading the game provider → decoupled. GameSessionNotifier + StudySessionNotifier both implements RoundActions (study delegates markCorrect/markWrong to grade()). GameScreen builds RoundState + passes the notifier. StudySessionScreen: NewLearn stage 1 = learn, stages 2–5 embed the real games (Ghép đôi/Đoán/Nhớ lại/Điền); DueReview = recall pass. D-002/D-015/D-017 logic unchanged.
- Tests (+2): a game widget grades via a fake RoundActions (proves decoupling) + recall reveal→grade. Existing game/study notifier tests unaffected (they test notifiers, not widgets — so the widget refactor broke nothing).
- The earlier W4 NIGHT-LOG "NewLearn game-stages simplified" note is now superseded — NewLearn uses the real games.
- Next: GAP item 5 = W9 accuracy + heatmap + longest-streak (needs a review_outcome table + Drift MIGRATION (bump schemaVersion) + schema/migration docs + recording outcomes in grade/game answers).

## 2026-06-28 · GAP item 3/8 · W8 import/export · DONE · de8d09a5 · verify --full GREEN (160 tests)

- What: full CSV/Excel/clipboard import+export. BE plugin-free + testable: ImportCardsUseCase (map term/meaning columns, skip header, soft-dup D-020 counted not blocked), ExportCardsUseCase (deck or subtree → header + rows, optional box/due_at). TableCodec (data) wraps csv 8 (CsvDecoder/CsvEncoder) + excel 4 (XLSX). FE: ImportScreen (/deck/:id/import — file_picker or paste → separator/header/column pickers → preview → import) + ExportScreen (/deck/:id/export — subtree+SRS toggles + format → save to documents or clipboard), reachable from deck-detail AppBar.
- Tests (+8): D-025/D-026 use cases + TableCodec CSV & XLSX round-trips (excel is pure Dart → round-trip unit-tested).
- Gotcha logged: csv resolved to 8.0.0 (NOT 6) — v8 API is CsvDecoder/CsvEncoder, not CsvToListConverter. file_picker 8 prints a harmless federated-plugin warning. File pick itself (file_picker) is the only untestable edge.
- Next: GAP item 4 = W4 RoundController — extract a shared round controller so NewLearn stages 2–5 reuse the real game widgets instead of the unified self-grade.

## 2026-06-28 · GAP item 2/8 · Audio/TTS · DONE · 3c847223 · verify --full GREEN (152 tests)

- What: TtsService interface (domain) + FlutterTtsService (flutter_tts: stop→setLanguage→speak, blank=no-op) behind an interface; @riverpod ttsServiceProvider. Flashcard editor audio button speaks the term in the pair's source language (was "coming soon"); PlayerScreen speaks each term as it auto-advances + a manual speaker button.
- Tests (+2): editor speak wiring via fake TtsService (term + source lang; blank no-op).
- Human gap: actual speech is device-only (platform channel, not unit-testable); audio-FILE generation/storage (card.audio_ref) still deferred — only live TTS read is done.
- Next: GAP item 3 = W8 import/export (file_picker + csv + excel).

## 2026-06-28 · GAP item 1/8 · W12 reminders OS firing · DONE · a5d55cc3 · verify --full GREEN (150 tests)

- What: completed the deferred W12 reminder firing. NotificationService interface (domain) + LocalNotificationService (flutter_local_notifications 22 + timezone + flutter_timezone) scheduling one weekly notification per selected weekday (dayOfWeekAndTime), lazy init + permission request, behind an interface. Pure ReminderScheduler.nextFireTimes (unit-tested). SettingsNotifier.setReminder now calls notificationService.sync(reminder, title, body); ReminderScreen dropped "coming soon" → active hint + threads l10n. AndroidManifest: boot/post-notification permissions + plugin receivers.
- Tests (+4): scheduler fire-time logic + setReminder→sync wiring (fake service).
- Human gap: on-device firing needs the runtime POST_NOTIFICATIONS grant (handled by requestPermission on enable). iOS works via the plugin (no extra manifest). Verified the Dart side green; actual OS delivery is device-only (not unit-testable).
- Next: GAP item 2 = Audio/TTS (flutter_tts) — TtsService abstraction + wire editor/player/game speaker.

## 2026-06-28 · GAP-FILL ROUND · deps unblocked (user granted blanket approval)

User approved adding all gated libraries + asked to complete every deferred point. Deps added + pushed (a7e7ff4): file_picker^8/csv^8/excel^4 (W8), google_sign_in^7/googleapis^16/flutter_secure_storage^10 (W10), flutter_local_notifications^22/timezone^0.11 (W12), flutter_tts^4 (audio). All resolve with the analyzer-9 stack. WORK QUEUE (one per iteration, verify --full green + push each):

1. **W12 reminders (OS firing)** — NotificationService abstraction (flutter_local_notifications + timezone init); schedule/cancel from the persisted Reminder on settings change; permission request; remove the "coming soon" notice. Test the schedule-computation/wiring via the abstraction (the plugin call is thin; OS firing not unit-testable).
2. **Audio/TTS** — TtsService abstraction (flutter_tts); wire the editor audio control + player + game "speaker" (term → speak). Test the service contract; UI buttons trigger it.
3. **W8 import/export** — full per docs/business/import-export (D-025 import: file_picker pick + csv/excel parse + separator + preview + soft-dup D-020; D-026 export csv/excel/clipboard + optional SRS). Screens 21-import/22-export from Library overflow.
4. **W4 RoundController** — extract a RoundController interface (pending/current/markCorrect/markWrong) implemented by GameSessionNotifier + StudySessionNotifier; parameterise the 4 game widgets by it; NewLearn stages 2–5 reuse the real games instead of the unified self-grade.
5. **W9 metrics** — add a `review_outcome` table (card_id, ts, correct, mode) + MIGRATION (v→v+1) + schema/migration docs; record outcomes in DueReview grade + game answers; then build accuracy donut + full activity heatmap + longest-streak (extend ComputeStreak).
6. **W7 FTS** — optional: FTS5 virtual table + triggers (migration) replacing LIKE, OR leave as documented perf-deferral if migration risk outweighs the win.
7. **W10 Google account-sync** — google_sign_in + googleapis(Drive). Sign-in + upload/download the local JSON backup to Drive appDataFolder; secure-storage for tokens. NOTE: real OAuth needs the user's GCP client config (android/ios) — build the structure + abstract the auth; flag the platform-config step as the human gap.
8. **Code-review pass** — run `code-reviewer` + `docs-drift-detector` over the cumulative gap-fill diff; fix blockers.

Rules unchanged: verify ONLY via tool/verify; verify --full green before push; docs parity each commit; WBS §10 traceability; per dep already approved. After item 8 (or when all done/blocked), write FINAL SUMMARY + stop.

## 2026-06-28 · W13 (13-W13-personalization) · DONE · 4b97f51c · theme mode, accent & font size, verify --full GREEN

- What: BE — ThemePrefs + AccentChoice (brand/warm/cool mapped to existing tokens, no new colors) + FontScale (small/medium/large) in core/theme; AppTheme.light/dark now take an accent and re-seed the ColorScheme primary/surfaceTint; PersonalizationNotifier (keepAlive) reads/writes theme_mode/accent_color/font_scale via the W12 settings store. FE — ThemeScreen (/settings/theme) with mode + accent + font-size selectors + live preview; MemoXApp is now a ConsumerWidget so themeMode/accent/MediaQuery.textScaler apply live with no restart (AC-1/AC-2); the settings "Theme" row opens it (was a coming-soon snackbar).
- Where: lib/core/theme/{theme_prefs,app_theme}, lib/presentation/features/personalization/{viewmodels,screens}, lib/app/memox_app.dart, app_router + route_paths (/settings/theme), settings_screen theme link, core/constants/settings_keys (theme keys).
- Verify: `node tool/verify/run.mjs --full` → PASS (doc_guard, analyze, format, 146 tests). Pushed origin main.

## 2026-06-28 · FINAL SUMMARY · overnight build pack COMPLETE — loop stopped

Every buildable step in prompts/00-INDEX.md is merged; only gated steps remain. Main is clean and green at the W13 docs commit. Per-step status + commit hashes:

- S0 foundation/shell — DONE (8d715f8)
- W2 flashcard management — DONE (081ffc7)
- W6 library/decks — DONE (1f891c7)
- W3 SRS 8-box Leitner — DONE (9412f48)
- W5 games — DONE (41c0f0f)
- W4 study flows (NewLearn/DueReview/Review/Player + daily_activity) — DONE (b63ec88)
- W7 search (term+meaning, filters) — DONE (ca16842)
- W11 engagement (Today dashboard + goal + streak) — DONE (cbeedf0a)
- W9 statistics (overview + Leitner + forecast + activity, scope toggle) — DONE (ac8fbfb8)
- W12 settings + local backup/restore (+ reminder schedule persistence) — DONE (c48fe360)
- W13 personalization (theme mode + accent + font size, live) — DONE (4b97f51c)
- W8 import/export — BLOCKED (ecd795c) — needs file_picker + csv + excel (not in stack.md)
- W10 account-sync (Google) — BLOCKED — needs google_sign_in + googleapis + secure-storage (not in stack.md)

GATED DEFERRALS NEEDING APPROVAL (add dep to pubspec + docs/stack/stack.md in the same commit, then implement):
1. W8 import/export — file_picker, csv, excel (a clipboard-only subset is feasible without deps — see the W8 BLOCKED note).
2. W10 account-sync — google_sign_in, googleapis, flutter_secure_storage.
3. W12 reminder OS notification scheduling — flutter_local_notifications, timezone (the reminder SCHEDULE already persists; only the firing is deferred).

Test suite: 146 tests passing. Each merged step kept docs in sync (CLAUDE.md parity) and recorded a WBS §10 traceability line. The loop has no further eligible work and has stopped — no wakeup scheduled. Approve any gated dep above to resume that step.

## 2026-06-28 · W12 (12-W12-settings) · DONE · c48fe360 · settings, local backup & reminders, verify --full GREEN

- What: BE — SettingsKeys (all schema keys) + Reminder VO + AppSettings snapshot; SettingsRepository/DAO extended (readAll/write/remove) + GetSettings/UpdateSetting use cases; BackupRepository (JSON snapshot of every table via raw SQL, restore replaces rows in one transaction, parents-first); SettingsNotifier (keepAlive) persists each change, refreshes the W11 dashboard goal on goal change, backup/restore via the existing path_provider. FE — SettingsScreen (/settings from drawer): game (words/round + random), SRS (boxes read-only 8, new/day), daily goal (minutes/words), reminder link, auto-backup + backup/restore buttons, theme link→W13. ReminderScreen (/settings/reminder): enable + time picker + weekday chips + "coming soon" notice. D-008: game picker sources words/round + random from settings and threads them through the gamePlay route.
- Where: lib/domain/{types/reminder,models/app_settings,repositories/{settings,backup}_repository,usecases/settings}, lib/data/{daos/settings_dao,repositories/{settings,backup}_repository_impl}, lib/app/di/settings_providers, lib/presentation/features/settings, app_router + route_paths (/settings,/settings/reminder), app_drawer (Settings→/settings), game_picker_screen + route (D-008).
- Verify: `node tool/verify/run.mjs --full` → PASS (doc_guard, analyze, format, 142 tests). Pushed origin main.

## 2026-06-28 · W12 · BLOCKED(partial) · dep:flutter_local_notifications,timezone — reminder OS scheduling deferred

- What: the reminder SCHEDULE (time + weekdays + enabled) persists and round-trips, but actually firing a local notification at that time needs flutter_local_notifications + timezone, which are NOT in docs/stack/stack.md (W12 prompt dependency gate). Per loop rule 4, not added. The reminder screen shows a "notifications coming soon" notice; the schedule is stored so it can be activated once the deps are approved.
- Suggested fix: approve + add flutter_local_notifications + timezone to pubspec + stack.md (same commit), then add a NotificationScheduler that reads the persisted Reminder and schedules/cancels OS notifications (request permission per BR-4).
- Next eligible: step 13 = W13 (13-W13-personalization.md) — dep W12 (now Done) → BUILD next. Likely theme picker + word-display personalization (settings links to it). Read its prompt + docs/business/personalization + design screens. After W13, only W8 + W10 (gated deps) remain → write the FINAL SUMMARY to NIGHT-LOG and STOP the loop (omit ScheduleWakeup).

## 2026-06-28 · W9 (10-W9-statistics) · DONE · ac8fbfb8 · learning stats with scope toggle, verify --full GREEN

- What: BE — StatsScope (current pair / all app) + StatisticsSummary read-model; StatsDao aggregates over card/srs_state/daily_activity (library counts, Leitner box distribution box0=new, scheduled due_at list, daily activity), hidden-excluded, scoped by pair or all-app; StatisticsRepository + GetStatisticsUseCase buckets the 7-day due forecast + 14-day activity window vs the injected clock. FE — StatisticsScreen replaces the Stats placeholder: scope SegmentedButton, overview (pairs/decks/words + mastered %), box + forecast bars, 14-day activity bars, loading/insufficient/error states; charts hand-rolled from Mx* tokens (NO charting dep). StatsScopeNotifier + autoDispose-family StatisticsNotifier(scope).
- Where: lib/domain/{types/stats_scope,models/statistics_summary,usecases/statistics}, lib/data/{daos/stats_dao,repositories/statistics_repository_impl}, lib/app/di/statistics_providers, lib/presentation/features/statistics, app_router Stats branch.
- Verify: `node tool/verify/run.mjs --full` → PASS (doc_guard, analyze, format, 135 tests). Pushed origin main.

## 2026-06-28 · W9 · NOTE · deferred metrics; charts hand-rolled (no dep)

- What: per the W9 dependency gate (charting package not in stack.md), all charts are built from primitives/tokens (FractionallySizedBox bars + LinearProgressIndicator) — no fl_chart/dep added. Deferred from the spec's metric catalogue: full calendar heatmap (showed a 14-day activity bar instead), accuracy donut (no persisted correct/total — study accuracy is computed in-session only, never stored; needs a review-outcomes table to implement), and longest-streak (W11 only computes current streak). These are additive and can land when the data exists.
- Next eligible: step 11 = W12 (settings) — dep W1 (Done) → BUILD next. Reminders need GATED flutter_local_notifications/timezone → build the settings store + UI WITHOUT reminders, INCLUDING the daily_goal_minutes/words WRITE that activates W11's goal (extend SettingsRepository with writeInt + add SettingsNotifier — the state-mgmt contract already has a SettingsNotifier row). Either omit the reminder UI or render it disabled with a NIGHT-LOG BLOCKED(dep) note for just that sub-feature. Then W13 (dep W12). W8/W10 remain BLOCKED (gated deps).

## 2026-06-28 · W11 (09-W11-engagement) · DONE · cbeedf0a · today dashboard, daily goal & streak, verify --full GREEN

- What: BE — DailyGoal (met = minutes OR words) + Streak value objects; ComputeStreakUseCase (D-021: consecutive met days back from today; today-in-progress not a miss; gap/miss → 0; no goal → 0). Added DailyActivityRepository.allForPair (streak history) + a minimal SettingsRepository reading daily_goal_minutes/words (W12 owns writes). Shared dayKey() util now used by FinalizeStudySession (W4) + streak so the daily_activity key format is identical. EngagementNotifier (keepAlive) composes activity + goal + streak + library due/mastered into EngagementSummary. FE — DashboardScreen replaces the Today placeholder: greeting/date, activity (time+words), goal ring (met/none states), streak card, shortcuts (continue → Library, due count, mastered %), loading skeleton + error/retry.
- Where: lib/domain/{types/daily_goal,types/streak,models/engagement_summary,usecases/engagement}, lib/data/{daos/settings_dao,repositories/settings_repository_impl,...daily_activity}, lib/app/di/settings_providers, lib/core/{util/day_key,constants/settings_keys}, lib/presentation/features/engagement, app_router Today branch.
- Verify: `node tool/verify/run.mjs --full` → PASS (doc_guard, analyze, format, 130 tests). Pushed origin main.

## 2026-06-28 · W11 · NOTE · goal needs W12 to be useful; no nightly close job

- What: until W12 (settings) writes daily_goal_minutes/words, the goal is unset → the dashboard shows the "set a goal" hint and streak stays 0 (D-021 streak logic is fully tested via the use case with explicit goals). There is no background midnight job in v1 — the streak is computed on demand from the daily_activity history vs the goal, which yields the same result. Continue/due shortcuts navigate to the Library tab (study-from-dashboard deferred).
- Next eligible: step 10 = W9 (10-W9-statistics.md) — dep W3 (Done) + W11 (now Done), NO gated dep → BUILD next. Then W12 (settings; reminders need GATED flutter_local_notifications/timezone → build settings store+UI incl. the daily-goal write that unlocks W11's goal, BLOCK only the reminder part), then W13 (dep W12). W8/W10 remain BLOCKED (gated deps).

## 2026-06-28 · W8 (08-W8-import-export) · BLOCKED · dep:file_picker,csv,excel

- What: W8 (CSV/Excel/clipboard import & export) requires `file_picker` + `csv` + `excel` to pick/parse files. Its own prompt has an explicit "⚠ Dependency gate (NOT in stack.md → STOP & ask)". These deps are NOT in `docs/stack/stack.md`. Per loop rule 4 / hard rule (new dependency needs approval), NOT implemented this run.
- Where: prompts/08-W8-import-export.md; docs/stack/stack.md (deps absent).
- Action: nothing changed in the tree (no stash needed); WBS W8 stays Planned; skipping to the next buildable step (W11).
- Suggested fix: approve + add `file_picker`/`csv`/`excel` to `pubspec.yaml` + `docs/stack/stack.md` (same commit), then implement per `docs/business/import-export/import-export.md` (D-025 import separator/preview/soft-dup; D-026 export CSV/Excel/clipboard + optional SRS). NOTE: a clipboard-only subset (paste/copy text via Flutter's built-in `Clipboard`, manual CSV split/join) is feasible WITHOUT any gated dep — could be a partial W8 if file/Excel support is deferred; left for a human decision to avoid overstating W8 completion.

## 2026-06-28 · W7 (07-W7-search) · DONE · ca16842e · term + meaning search with filters, verify --full GREEN

- What: BE — SearchResult model (derives CardStatus vs clock), SearchRepository (Drift DAO card⨝deck⨝srs; meaning matched via EXISTS → one row per card; includes hidden — D-028; scoped to active pair, optional subtree), SearchCardsUseCase (term+meaning — D-019). FE — SearchScreen (/search) with field+clear, status filter chips, empty-recent/results/no-results/loading states; hidden dimmed + eye-off; tap → W2 editor; recent kept in session; search button added to library toolbar.
- Where: lib/domain/{models,usecases/search}, lib/data/{...search}, lib/presentation/features/search, lib/app/router, library_screen toolbar.
- Verify: `node tool/verify/run.mjs --full` → PASS (doc_guard, analyze, format, 122 tests). Pushed origin main.

## 2026-06-28 · W7 · NOTE · No index (v1 LIKE); next is GATED W8

- What: search uses case-insensitive LIKE over card/card_meaning — no FTS/index added (deferred until the performance contract requires it on large libraries). No schema change/migration.
- Next eligible: step 8 W8 (08-W8-import-export.md) needs file_picker/csv/excel which are NOT in docs/stack/stack.md → must log BLOCKED(dep:file_picker,csv,excel) + git stash + commit the NIGHT-LOG via verify --docs + skip. Then step 9 W11 (09-W11-engagement.md, dep W4 Done) is the next BUILDABLE step (Today dashboard / daily goal / streak — reuse dailyActivityRepository from W4; settings keys daily_goal_minutes/words for the goal; no gated dep).

## 2026-06-28 · W4 (06-W4-study) · DONE · b63ec88c · five study entries + NewLearn/DueReview/review/player/result, verify --full GREEN

- What: BE — StudyEntry, PlayMenu, DailyActivity entity+repo (Drift, cumulative), deckRepository.subtreeCardIds (D-009 recursive), use cases buildPlayMenu (D-001/D-016 gating), buildStudyQueue (reuses W3 due/new queues), finalizeStudySession (D-010 activity only for due/new). StudySessionNotifier: NewLearn 5 stages → scheduleNewCard box1 only on completion (D-002), quit→new (D-017), DueReview grades SRS (W3), wrong→re-queue (D-015). FE — play menu sheet (from deck-detail ⋮ Play), StudySessionScreen (stages + exit dialog + inline result), ReviewScreen, PlayerScreen (auto-play timer, no SRS). Routes study/review/player.
- Where: lib/domain/{entities,models,types,usecases/study}, lib/data/{...daily_activity}, lib/presentation/features/study, lib/app/router, deck_detail_screen (Play action).
- Verify: `node tool/verify/run.mjs --full` → PASS (doc_guard, analyze, format, 116 tests). Pushed origin main.

## 2026-06-28 · W4 · NOTE · NewLearn game-stages simplified; audio deferred

- What: the 4 NewLearn game stages (Ghép đôi/Đoán/Nhớ lại/Điền, stages 2-5) currently render a unified SELF-GRADE flow (show term → reveal → Đã quên/Nhớ được) rather than embedding the actual W5 game widgets. Reason: the W5 widgets (MatchingGame etc.) bind to GameSessionNotifier(GameRequest); reusing them inside a NewLearn stage needs a shared "round provider" abstraction so a widget can be driven by either the game or study notifier. The 5-stage progression + completion→box1 + wrong→relearn logic IS correct and tested (D-002/D-015/D-017); only the per-stage UI variety is simplified.
- Suggested fix: extract a `RoundController` interface (pending/current/markCorrect/markWrong) that both GameSessionNotifier and StudySessionNotifier implement, and parameterise the 4 game widgets by it; then NewLearn stages 2-5 reuse them directly. Player audio/TTS still deferred (dep outside stack).
- Next eligible: W7 (07-W7-search.md), dep W2 (Done).

## 2026-06-28 · W5 (05-W5-game) · DONE · 41c0f0f5 · four practice games + picker, verify --full GREEN

- What: BE — GameType/GameScope types, GameCard, BuildGameRoundUseCase (scope filter + count cap D-008 + deterministic shuffle), EvaluateTypingUseCase (1-typo tolerant). FE — GamePickerScreen (/game/:nodeId, D-013) + GameScreen (/game/:nodeId/play) + 4 game widgets (matching/multiple-choice/recall/typing); GameSessionNotifier (family) with wrong→re-queue and round-complete-when-all-correct (D-015). Games NEVER touch srs_state (D-007).
- Where: lib/domain/{models,types,usecases/game}, lib/presentation/features/game, lib/app/router.
- Verify: `node tool/verify/run.mjs --full` → PASS (doc_guard, analyze, format, 110 tests). Pushed origin main.

## 2026-06-28 · W5 · NOTE · Audio deferred; direct cards; entry point is W4

- What: audio/loa in the game designs needs a TTS dep outside docs/stack/stack.md → deferred. Games draw from the node's DIRECT visible cards (cardRepository.listByDeck); recursive subtree gathering is a study-flow concern deferred to W4. The "Một trò chơi" entry from a node's Play menu also lands with W4 — for now games are reached via the /game/:nodeId route.
- Action: NEXT eligible is W4 (06-W4-study.md) — now unblocked (W3✓, W5✓, W6✓). W4 wires NewLearn (5 stages → SRS schedule), DueReview (grade), Review/Player, the Play menu, and the study result; it composes the W3 SRS engine + W5 games + W6 deck subtree, and adds daily-activity. Consider adding a deckRepo subtreeCardIds helper there for recursive study/game gathering.

## 2026-06-28 · W3 (04-W3-srs) · DONE · 9412f488 · 8-box Leitner scheduling engine, verify --full GREEN

- What: BE-only (no screen). SrsState entity; LeitnerBox (0..8, +1 cap 8 / −1 floor 1) + BoxInterval (1·3·7·14·30·60·120; 0/8 unscheduled) + LastResult (stored); pure SrsScheduler (scheduleNewCard D-002, applyGrade D-003/4/5); SrsRepository (Drift DAO/mapper/impl, one row per card D-011, card⨝srs join for queues); use cases scheduleNewCard/gradeCard/buildDueQueue/buildNewQueue(cap D-018)/computeDueCount. Clock injected for due_at.
- Where: lib/domain/{entities,services,types,usecases/srs}, lib/data/{datasources/local/daos,repositories}, lib/app/di/srs_providers.dart.
- Verify: `node tool/verify/run.mjs --full` → PASS (doc_guard, analyze, format, 96 tests). Pushed origin main.

## 2026-06-28 · W3 · NOTE · No migration; queues take card-id sets

- What: srs_state already in schema v1; stored last_result encoding 'correct'/'wrong' matches schema-contract → no migration. The queue use cases (due/new) operate on a candidate card-id SET (the subtree is gathered by the deck repo, W6) and exclude hidden via the card⨝srs join — W4 study composes deckRepo (subtree cards) + these SRS use cases. The W6 deck recursive stats already read srs_state, so scheduled cards now light up due/mastered counts.
- Suggested fix: when W4 builds NewLearn, read the new_cards_per_day setting (W12) for the buildNewQueue limit; for now callers pass kDefaultNewCardsPerDay (20).

## 2026-06-28 · W6 (03-W6-deck-tree) · DONE · 1f891c7e · self-nesting deck tree (library + deck detail), verify --full GREEN

- What: BE — Deck entity (self-nests via parent_deck_id), DeckNode/DeckStats read-models, SortBy/SortDirection, DeckRepository (Drift DAO/mapper/impl) with recursive aggregate stats (words/hidden/due/mastered/%, due/mastered read srs_state vs injected clock), use cases (getLibraryTree, getDeckNode, create/rename/move[cycle-reject]/delete[cascade], pure sortDeckNodes). FE — library home (replaces S0 placeholder) + deck detail (push /deck/:id) with states, MxDeckTile, sort sheet, create/rename/move/delete dialogs; reuses the W2 editor. LibraryNotifier (autoDispose) + DeckDetailNotifier (family).
- Where: lib/{domain,data,app/di,presentation/features/deck}, lib/presentation/shared/widgets/mx_deck_tile.dart, lib/app/router.
- Verify: `node tool/verify/run.mjs --full` → PASS (doc_guard, analyze, format, 84 tests). Pushed origin main.

## 2026-06-28 · W6 · NOTE · No migration — deck table predates W6

- What: `deck` (self-FK parent_deck_id) + index idx_deck_tree already exist in schema v1 (W1 tables.drift), so W6 added no table/column and needs no migration.

## 2026-06-28 · W6 · NOTE · Deck sort proxies + limited move targets (schema gap)

- What: D-023 sorts decks by alphabet/createdAt/lastStudied, but the `deck` table has neither a created_at nor a last_studied_at column. Sort "createdAt" uses the deck id (autoincrement insertion proxy); "lastStudied" uses the subtree's max card.last_studied_at. Move destinations are limited to the top level + existing root decks (cycle-safe by construction; the repo still enforces BR-3).
- Action: documented in docs/business/deck/deck-management.md status + docs/domain/types/sort.dart. Deeper move targets, card-list sort, and in-deck search deferred to later steps (W7 search). Recursive stats computed in Dart (fine for v1 per-pair data; a SQL recursive CTE is the optimization if libraries get large — perf-contract).

## 2026-06-28 · W2 (02-W2-flashcard) · DONE · 081ffc74 · card CRUD + multi-field meanings, verify --full GREEN

- What: BE — Card/CardMeaning entities, CardDraft, CardStatus (derived), CardRepository (Drift DAO/mapper/impl), use cases (create/update with BR-2 validation, delete cascade, toggleHidden, checkSoftDuplicate, getCard), Clock + DI. FE — flashcard editor screen (create/edit) with Save-gating, inline validation state, D-020 soft-duplicate banner, multi-meaning + gender + hidden; route flashcardEditor (/deck/:id/card).
- Where: lib/{domain,data,app/di,presentation/features/flashcard}, lib/app/router.
- Verify: `node tool/verify/run.mjs --full` → PASS (doc_guard, analyze, format, 71 tests). Pushed origin main.

## 2026-06-28 · W2 · NOTE · Audio/TTS deferred (dep:flutter_tts)

- What: editor design state 6 (audio generation) needs a TTS package outside docs/stack/stack.md.
- Action: editor renders the audio control but it shows "coming soon"; `card.audio_ref` stays null. "View existing" on the dup banner likewise deferred (needs a card list, W6). Logged per loop rule 4 (no unapproved dep).
- Suggested fix: add flutter_tts to stack.md (needs approval), then wire term→audio generation + playback.

## 2026-06-28 · W2 · NOTE · No migration — card/card_meaning predate W2

- What: `card` + `card_meaning` (and all v1 tables) were created in schema v1 by W1's tables.drift, so W2 added no table/column and needs no migration. migration-contract already lists them under 0→1.

## 2026-06-28 · W2 · NOTE · Editor viewmodel as ConsumerStatefulWidget; native lang from active pair

- What: Riverpod @riverpod codegen stays deferred (S0 toolchain conflict), and the form is controller-driven, so the editor orchestrates use cases from a ConsumerStatefulWidget (validation RULES live in the use cases; the widget only maps results to field errors). The native meaning's language is resolved from the active pair (S0) rather than a deck→pair join, since there is no deck navigation yet (W6).

## 2026-06-28 · S0 (01-S0-app-shell-language-pair) · DONE · 8d715f83 · app shell + language_pair + l10n, verify --full GREEN

- What: BE — Drift `language_pair` DAO/repo + mapper + use cases (list, getPairContext, create [D-030], remove, setActive, swapDisplayDirection); pair context persisted via `settings` keys `active_pair_id`/`display_swapped`. FE — `StatefulShellRoute` shell (Today/Library/Stats/Profile + center Add) + language Drawer (menu / add-language / remove-language) wired to a keepAlive notifier; l10n vi/en.
- Where: lib/{domain,data,app/di,presentation}/…language_pair, lib/presentation/shared/navigation, lib/l10n.
- Verify: `node tool/verify/run.mjs --full` → PASS (doc_guard, analyze, format, 54 tests). Pushed origin main.

## 2026-06-28 · S0 · NOTE · Riverpod codegen deferred

- What: `riverpod_generator` pins `source_gen ^2` / `analyzer 7–8`, conflicting with `drift_dev 2.34` (`source_gen ^3` / `analyzer 10–12`); `riverpod_generator ^3` forces `flutter_riverpod ^3` (stack pins ^2).
- Action: kept `flutter_riverpod ^2.6.1`; hand-wrote a keepAlive `AsyncNotifier` instead of `@riverpod`. Documented in docs/stack/stack.md + docs/state/state-management-contract.md.
- Suggested fix: re-enable codegen when `drift_dev`/`analyzer` are bumped (analysis_options note anticipates analyzer ^12 / riverpod 3.3.x).

## 2026-06-28 · S0 · NOTE · W1 baseline analyzer infos cleared

- What: `flutter analyze` exits non-zero on info lints; W1 foundation code carried 16 (the last verify marker was docs-scope, so W1 code never cleared the code gate).
- Action: `dart fix --apply` removed them (prefer_expression_function_bodies / prefer_const / sort_pub_dependencies) so S0's `verify --full` is green. No behavior change.

## 2026-06-28 · S0 · NOTE · Shell route shape reconciled with nav doc

- What: 23-drawer + the S0 prompt name a 5-slot bottom nav (Today·Library·Add·Stats·Profile); navigation-flow.md modeled stats/settings as push routes.
- Action: implemented 4 tab branches (Today/Library/Stats/Profile) + center Add as a FAB action; added `today`/`profile` routes; updated navigation-flow.md in the same commit. Secondary drawer items (Import/Export/Theme/Settings/FAQ/Email/Sync) show "coming soon" until W8–W13.

## 2026-06-28 · S0 · NOTE · analysis_options.yaml skip-worktree restored

- What: the curated `analysis_options.yaml` is a working-tree override hidden via git `skip-worktree` (HEAD carries the default template). The bit was cleared mid-session (a flutter/dart index refresh), surfacing it as modified.
- Action: re-set `git update-index --skip-worktree analysis_options.yaml` so the tree reads clean for the next iteration; did NOT commit it (respecting the local-override intent).

## 2026-06-28 · S0 · NOTE · Subagent review fan-out skipped

- What: unattended cost-sensitive loop — per-step `code-reviewer` + `docs-drift-detector` fan-out skipped to keep the night moving.
- Action: relied on `doc_guard` + `flutter analyze` (strict ruleset) + `dart format` + 54 tests, all green. Re-run a manual review pass in the morning if desired.

## 2026-06-28 · W9 · GAP-FILL item 5/8 — accuracy + heatmap + longest streak

- Commit: `7ef989e4` (feat) — verify --full GREEN (doc_guard, analyze, format, 167 tests; +5).
- **Schema v1→2 (CLAUDE.md hard rule satisfied):** new `review_outcome` table (id, card_id FK, pair_id FK, ts, correct, mode) + index `idx_review_outcome_pair_ts`. `schemaVersion` 1→2; `onUpgrade(from<2)` creates the table + index. Migration test `test/data/datasources/local/drift/migration_v2_test.dart` (drop table → onUpgrade → table back, v1 data untouched). Docs: schema-contract (table + v2), migration-contract (1→2 row), storage-boundaries — all same commit.
- **Accuracy:** ReviewOutcomeDao/Repository (+DI); StudySessionNotifier records an outcome on every DueReview grade. StatsDao.accuracy → StatsRaw/StatisticsSummary (accuracyCorrect/Total + ratio). Stats screen shows a review-accuracy card (only when hasReviews). Tests: accuracy = 2/3, empty scope = 0.
- **Heatmap:** activity window 14→84 days; `_Heatmap` widget (Wrap of token-shaded squares, no chart dep) replaces the 14-day bars.
- **Longest streak:** `ComputeStreakUseCase.longest` (max consecutive met run over history) → EngagementSummary.longestStreak → dashboard streak card. Test: 3-run with a gap → 3; no goal → 0.
- Recording scope decision: only DueReview grades recorded (NewLearn has multiple attempts per card → noisy); `mode` column keeps the door open for newLearn later.
- WBS §10: traceability line added. NIGHT-LOG: this entry.
- NEXT (item 6/8): W7 FTS (optional) — full-text search over term+meaning. If FTS5 in the bundled sqlite is unavailable/awkward under Drift without a dep bump, fall back to the existing LIKE search and log it; this item is OPTIONAL, so keep it small and green.

## 2026-06-28 · W7 · GAP-FILL item 6/8 — multi-token search (FTS deferred)

- Commit: `1d1e5072` (feat) — verify --full GREEN (doc_guard, analyze, format, 168 tests; +1).
- **FTS5 decision: evaluated → DEFERRED.** The spec (global-search §0/§8) already states v1 uses LIKE and defers FTS/index "until perf needs it" with a <200ms NFR. FTS5 under Drift would require a `CREATE VIRTUAL TABLE … USING fts5` + content-sync triggers + backfill + a schema **v2→3** migration (schemaVersion bump + onUpgrade + schema/migration docs + migration test — same hard rule as item 5). That is disproportionate for an OPTIONAL item the spec deliberately defers; card counts in a vocab app are small enough that LIKE meets the NFR. So no schema change.
- **Shipped instead (low-risk, real quality win):** multi-token AND matching in `SearchDao` — query split on whitespace; each token must match `term` OR a meaning, AND-ed across tokens (D-019). "xin chào" now finds a card whose term holds one token and meaning the other. A single token is identical to the old substring match → no regression. Empty/whitespace query returns empty defensively.
- Docs (same commit): global-search BR-1 (multi-token), AC-4, status; decision-table D-019 (also corrected the stale `card_meaning.text` → `.content` reference).
- WBS §10 + NIGHT-LOG updated.
- NEXT (item 7/8): **W10 Google Drive sync** — build what's buildable behind interfaces (sync service/repository + DI + a settings entry point + serialize/merge using the existing backup JSON), and FLAG the GCP OAuth client-id / platform config (google_sign_in setup, Drive API enablement, SHA-1, plist/entitlements) as the HUMAN GAP rather than faking credentials. Keep verify GREEN; no real network calls in tests (fake the remote behind the interface). deps google_sign_in/googleapis/flutter_secure_storage already added in step 0.

## 2026-06-28 · W10 · GAP-FILL item 7/8 — Google Drive sync (structure; GCP = human gap)

- Commit: `30b4d56b` (feat) — verify --full GREEN (doc_guard, analyze, format, 173 tests; +5).
- **Built (code + tests, behind interfaces, no real network):**
  - Domain: `CloudSyncService` (interface) + `RemoteSnapshotMeta`/`SyncOutcome` types + `SyncNowUseCase`.
  - `SyncNowUseCase` policy = **snapshot-level last-writer-wins** (D-027): remote.modifiedAt > settings `cloud_last_sync_at` ⇒ pull+restore, else push; never-synced device adopts existing remote. Reuses `BackupRepository.serialize()/deserialize(json)` (added; backup/restore now delegate to them).
  - **Bonus fix:** the backup snapshot was missing `review_outcome` (introduced W9) — added to `_tables` + a serialize/deserialize round-trip test. So cloud sync + local backup now carry stats too.
  - Data: `GoogleDriveSyncService` — REAL google_sign_in 7 sign-in/lightweight/signOut + Drive REST (appDataFolder) over `http` (multipart-free: create metadata then PATCH media; list by name for meta; GET alt=media for download); Drive file id cached in secure storage. Guarded by `CloudSyncConfig.isConfigured` (empty clientId ⇒ clear "not configured" `NetworkFailure`, never calls Google).
  - DI: `sync_providers` (cloudSyncConfig/cloudSyncService/syncNow, keepAlive). Override `cloudSyncConfigProvider` to inject a real client id.
  - UI: "Đồng bộ Google Drive" tile in `/settings` → `SettingsNotifier.syncNow` (sign-in-if-needed → SyncNow; a pull invalidates library + dashboard like a restore). l10n vi/en.
  - Tests (+5): SyncNow push (no remote) / pull (remote newer) / push (remote older = local latest) / signed-out → signInRequired, with a faked remote; backup review_outcome round-trip.
  - New dep: `http ^1.2.0` (approved blanket).
- **🔴 HUMAN GAP (cannot be done from code — the only thing left for real sync):**
  1. GCP project with **Drive API enabled**.
  2. **OAuth client id** → put in `CloudSyncConfig.clientId` (or `--dart-define=GOOGLE_OAUTH_CLIENT_ID` + override `cloudSyncConfigProvider` at the composition root).
  3. Per-platform OAuth: Android SHA-1 + `google-services.json`; iOS URL scheme + `Info.plist`; desktop OAuth client.
  Until then the service is inert by design (reports "not configured"); the app stays fully offline-capable.
- v1 limitation kept honest: LWW is whole-snapshot, not per-record (MemoX has no per-row update clock); per-record merge + delete tombstones deferred (account-sync §10/§12).
- WBS §10 + W10 status (Planned→Partial) + the stale "W8/W10 BLOCKED" note (W8 was Done) updated. Docs: account-sync §12, D-027, overview, schema-contract, storage-boundaries.
- NEXT (item 8/8, FINAL): **code-review pass** — run the `code-reviewer` + `docs-drift-detector` subagents over the gap-fill diff (this round: items 1–7). Fold findings into NIGHT-LOG, fix any blockers (keep verify GREEN), then write the FINAL SUMMARY and STOP (omit ScheduleWakeup).

## 2026-06-28 · GAP-FILL ROUND — FINAL SUMMARY (item 8/8: code-review pass + close-out)

The unattended gap-fill round is COMPLETE. All 8 queue items done; main is green at `9e963064`.

### What shipped (8 items)
1. **Deps** (`a7e7ff4b`) — approved libraries for W8/W10/W12/audio; drift pinned <2.34 to keep @riverpod codegen.
2. **W12 reminders** (`a5d55cc3`) — real OS notification scheduling (flutter_local_notifications 22 + timezone) behind NotificationService/ReminderScheduler.
3. **Audio/TTS** (`3c847223`) — TtsService + FlutterTtsService + speaker button.
4. **W8 import/export** (`de8d09a5`) — CSV/Excel/clipboard import+export (D-025/D-026), plugin-free use cases + TableCodec.
5. **W4 RoundController** (`c3e78e43`) — NewLearn stages 2–5 use the real W5 game widgets via RoundState/RoundActions; widgets decoupled from providers.
6. **W9 metrics** (`7ef989e4`) — review_outcome table (**schema v1→2 migration** + test), review accuracy, 12-week heatmap, longest streak.
7. **W7 search** (`1d1e5072`) — multi-token AND search; FTS5 evaluated and deferred per spec.
8. **W10 Google Drive sync** (`30b4d56b`) — CloudSyncService + GoogleDriveSyncService (google_sign_in 7 + Drive REST + secure storage) + SyncNowUseCase (snapshot-level LWW) + settings tile; **structure done, GCP config = human gap**.
   + review fixes (`9e963064`).

Each item: `node tool/verify/run.mjs --full` GREEN before push. Test count grew ~from the round start to **173** passing. Two-commit pattern throughout (feat → docs). All schema changes obeyed the CLAUDE.md hard rule (schemaVersion + onUpgrade + schema/migration docs + migration test, same commit).

### Code-review pass (item 8) — subagents
- **code-reviewer:** 1 runtime BLOCKER (sync service missing `_ensureInit()` before google_sign_in calls) — FIXED in `9e963064`. Praised RoundController, the idempotent v1→v2 migration, the not-configured sync guard, LWW correctness, and injection-safe multi-token search.
- **docs-drift-detector:** doc_guard clean; found 4 doc drifts — all FIXED in `9e963064`: 4 missing WBS §10 lines, study-flow status Specified→Implemented, WBS "audio TTS hoãn" narrative, and a literal old-column-name in a changelog line.

### Minor findings logged (NOT blockers — for a future pass)
- `export_cards.dart` subtree export does N+1 `getById` per card → add a bulk `getByIds`.
- `export_screen.dart` / `import_screen.dart` swallow `Err` results with no UI feedback → add an error message branch.
- `study_session_notifier` markCorrect/markWrong ignore the passed `cardId` (always grade `session.current`) → guard or document the RoundActions deviation.
- `local_notification_service.sync()` calls `cancelAll()` before `requestPermission()` → if denied, schedules are lost.
- Statistics heatmap uses a `Wrap` (reflows mid-week on narrow phones) → consider a fixed 7-column grid.
- `'dueReview'` string literal in study notifier → promote to a named constant.
- migration_v2_test could additionally assert pre-existing rows survive onUpgrade (currently checks table presence + new insert).

### 🔴 Human gaps remaining (cannot be done from code — need device/account/cloud config)
- **W10 cloud sync:** GCP project + Drive API enabled + OAuth client id (`CloudSyncConfig`/`--dart-define`) + per-platform OAuth (Android SHA-1 + google-services.json, iOS URL scheme + Info.plist, desktop). Until then sync is inert by design.
- **W12 reminders / Audio TTS:** real device verification of OS notification delivery + TTS voices (unit-wired + faked here; not run on a device).
- Real-device run of the Drive REST happy path once credentials exist.

### Status
S0 + W2–W9, W11–W13 implemented & tested. W8 Done. **W10 Partial** (structure + tests; GCP config = human gap). Loop STOPPED (no further wakeup scheduled).

## 2026-06-28 · 8-SUBAGENT RECURSIVE REVIEW (post-round) + fixes

User requested a recursive review of the whole gap-fill round with 8 sub-agents. Ran them read-only over `04656999..HEAD` (the 7 items), each a distinct lens per `docs/checklist/recursive-agent-review.md`: security-auditor, performance-auditor, test-engineer, refactoring-specialist, solution-architect, docs-drift-detector, debugger, code-reviewer.

### Fixed (commit `2edd575e`, verify --full GREEN, 177 tests +4) — convergent findings
- **W4 study grade-wrong-card (HIGH; debugger + test-engineer + architect + code-reviewer):** `StudySessionNotifier.markCorrect/markWrong` ignored the passed `cardId`/`requeue` and always graded the queue head. In a NewLearn **MatchingGame** stage, matching a non-head pair graded the wrong card (and re-queued wrong matches). Now honors cardId+requeue, mirroring the correct GameSessionNotifier. +2 tests. Also extracted `ReviewOutcomeMode.dueReview` constant.
- **W7 search wildcard injection of meaning (debugger):** typed `%`/`_` acted as LIKE wildcards. Now escaped with `ESCAPE '\'`. +1 test.
- **W9 longest-streak DST (debugger):** `_parseDay` used local midnight → `inDays` mis-count across spring-forward. Now UTC midnight. +1 test.
- **W10/backup data-loss guards (security + debugger):** `deserialize` now rejects a snapshot missing the root table (was: empty `{}` → DELETE-all → wipe). `GoogleDriveSyncService` caches the Drive file id only after the media PATCH succeeds (was: cached early → failed first upload leaves an empty file the next sync pulls). `SyncNowUseCase` stamps lastSync from the server's modifiedTime (was: local clock → push↔pull ping-pong under clock skew).
- **Tests/docs:** migration_v2_test now seeds rows before onUpgrade and asserts survival (data-preservation). Doc parity: tables.drift schema_version 1→2 comment; navigation-flow dropped the non-existent `/settings/account` route (sync is an inline settings tile); business/index statuses Specified→Implemented (W10 alpha); removed dead `statsActivityTitle` l10n key.

### Deferred (logged; not blocking — bigger or needs a product decision)
- **Perf — export N+1** (`export_cards.dart` subtree fetches getById per card): add a bulk `CardRepository.listByIds` + one `meaningsForCards`. Medium effort (repository contract change).
- **Perf — restore per-row INSERT** (`backup_repository_impl.deserialize`): batch multi-row INSERT / Drift `batch()` for large datasets.
- **Perf — stats `_activity`/`_accuracy` unbounded** for "all app" scope: push an 84-day / pair window into SQL as history grows.
- **Arch — sign-in orchestration split** (`SettingsNotifier.syncNow` pre-checks sign-in that `SyncNowUseCase` also handles): consolidate to one seam.
- **UX — import/export screens swallow `Err`** with no feedback: add an error message branch.
- **UX — `LocalNotificationService.sync` requests permission on every save**: request once on first-enable.
- **Security (hardening) — backup deserialize column-name interpolation**: validate column names against an allow-list/regex (data is the user's own backup/Drive, so lower risk; root-table guard already added).
- **Cleanup** — `sync_now` `(x as Ok).value` after Err-guard → `valueOrNull`; dead `StudySessionState.revealed`/`reveal()`; export_screen hardcoded `','` → `Separator.comma.char`.
- **Doc decision** — record that accuracy stats are dueReview-only (NewLearn game grades not recorded), per architect note.
- **Test depth** — sync error-path coverage, GoogleDriveSyncService not-configured guard test, export subtree/hidden coverage.

### Verdicts
No layer-boundary violations (architect). Security: no hardcoded creds, no SQL-value injection; the fixed guards close the restore-path risks. doc_guard clean. Net: the round's architecture is sound; the convergent correctness bugs are fixed; the deferred items are improvements, not blockers.

## 2026-06-28 · HARDEN follow-ups (from 8-agent review) — 4 commits, all verify --full GREEN

User chose "harden review follow-ups". Worked the deferred items in 4 verified commits (186 tests, +8 from 178):
1. `cebab9c1` **Perf** — ExportCardsUseCase subtree now uses `CardRepository.listByIds` (one bulk cardsByIds + meaningsForCards, re-ordered) instead of 2N getById queries; BackupRepository.deserialize inserts via chunked multi-row INSERT (chunk 200) + validates column names are plain identifiers (closes the restore-path injection note too). +1 export-subtree test.
2. `9e150ff9` **UX** — import/export screens show `transferError` (vi/en) on an Err result instead of silently no-op'ing; export uses `Separator.comma.char`; LocalNotificationService.sync skips scheduling when permission is denied (was ignoring the result).
3. `68ea6971` **Cleanup** — removed dead `StudySessionState.revealed` + `reveal()` (recall game owns its local `_revealed`); SyncNow uses `valueOrNull` instead of `(x as Ok).value` casts.
4. `461747c7` **Test depth + doc** — +6 SyncNow error-path tests (each Err branch + equal-timestamp tie) + 1 GoogleDrive not-configured guard test (MockClient asserts no network); statistics doc clarifies accuracy is DueReview-only in v1.

### Still deferred (intentionally not done — low value for single-user v1 / needs on-device)
- Stats `_activity`/`_accuracy` unbounded "all-app" scan: add an 84-day / pair window in SQL once history grows (low urgency for one user).
- Sign-in orchestration split (`SettingsNotifier.syncNow` vs `SyncNowUseCase`): a refinement; current flow + the granted-check work correctly.
- On-device verification of notifications/TTS/Drive (human gap; no real GCP creds).

Net: every convergent review finding is now either fixed or explicitly deferred with a reason. main green.

## 2026-06-28 · Deferred items + release prep (user: "đồng ý tất cả")

### Deferred review items finished (`5db02f4a`, verify --full GREEN, 186 tests)
- **Sync sign-in orchestration:** `SyncNowUseCase` is the single sign-in-state authority; `SettingsNotifier.syncNow` calls it and only runs interactive `signIn` + retries once on `signInRequired` (removed the duplicate isSignedIn pre-check).
- **Stats query bounding:** the heatmap query is now windowed in SQL (`day >= cutoff`) instead of fetching all daily_activity and trimming in Dart. Caught a coupling trap — `totalSeconds/totalWords` were summed from the same rows, so they'd have silently become 84-day totals. Fixed by adding a separate `_activityTotals` SUM aggregate, keeping totals lifetime. Both reads now bounded; results unchanged.

### Release prep (`da1c28cf`)
- **CI gate** `.github/workflows/ci.yml`: runs `node tool/verify/run.mjs --full` (doc_guard + analyze + format + tests) on push to main + PRs. Flutter 3.41.7 + Node 22 + libsqlite3 for the Drift host tests. *First run should be watched* — sqlite/host specifics on ubuntu CI may need a tweak (can't trigger Actions from here).
- **`docs/checklist/release-readiness.md`**: build-config TODOs + the W10 GCP human gap + a device smoke-test checklist for the platform-channel features (notifications/TTS/file-picker/secure-storage/Drive) that unit tests only fake.
- App identity already real: `com.memox.memox_v4` / `com.memox.memoxV4`, `version 1.0.0+1`.

### Remaining = human-only (documented, not code)
- App display name (`memox_v4` → brand), icons/splash assets, Android/iOS signing keys, GCP/OAuth for sync, and the on-device smoke pass. All in `docs/checklist/release-readiness.md`.

main green. Feature-complete v1 + hardened + CI + release checklist; the rest needs assets/credentials/a device.

## 2026-06-28 · code-verification-guard (ruleset memox) triage — A/B/C

Ran `python code-verification-guard/guard/run.py check --project . --ruleset memox` → 523 errors / 138 warnings. This is an ASPIRATIONAL design-system/convention spec far stricter than the real gate (`tool/verify` is green). Root cause: the `Mx*` UI-kit + flutter_hooks + shared utils the guard assumes were **never built** (only mx_deck_tile/mx_placeholder exist; no MxScaffold/MxButton/...; no hooks dep). So most errors = "code doesn't use a UI-kit that doesn't exist", not "bad code".

### Tier A — guard bugs / false-positives → fix the GUARD, not code (~80)
- `no_async_value_or_null` (42): text-matches `.valueOrNull` and flags **`Result.valueOrNull`** (e.g. `export_cards.dart`, a domain use case with no AsyncValue). Scope the rule to AsyncValue / exclude domain+data.
- `guard.config.missing_target_path` (24) + `rule_without_targets` (16): rules point at non-existent files (route_placeholder.dart, mx_text_field.dart, study_repo_impl.dart). Stale config.
- `hooks.*` (~5): no flutter_hooks dep — convention not adopted.
- `no_debug_print` (logger.dart:85): flags `developer.log` inside the **AppLogger wrapper itself** (the approved sink) — should exempt the logger file.

### Tier B — convention/design-system not implemented; valid intent but = a big WP, NOT a piecemeal fix (~360)
- All `no_raw_*` widgets + `no_raw_scaffold`/`use_mx_scaffold_family` + `no_direct_scaffold_messenger`: require Mx* widgets that don't exist.
- `no_direct_text_theme` (81) + `no_raw_text_style` (2): require an Mx text-style API. NOTE: these two are **coupled** — "fixing" no_raw_text_style with `textTheme.copyWith` would create a no_direct_text_theme error. Needs the text API first.
- `string_normalization_via_string_utils` (35), `use_shared_navigation_extension` (17): require shared utils/extensions not adopted.
- `no_stateful_widget_in_features` (28) + `no_set_state` (46): project deliberately uses StatefulWidget/setState for game widgets; guard wants hooks.
- `usecase_file_suffix` (38) + `usecase_class_suffix` (2): project names use cases without the `_usecase` suffix throughout.
→ Recommendation: decide as a project — build the Mx design-system as a new WP, or downgrade these rules to `warning` until it exists.

### Tier C — genuinely fixable now → DONE (commit `5863e973`)
- `no_blind_json_decode_cast` (3→0): backup + Drive now `is Map` type-check jsonDecode.
- `presentation_no_dart_io_imports` (1→0): extracted `FileSaveService` (domain) + `LocalFileSaveService` (data) + DI; export screen no longer imports dart:io.
- `no_hardcoded_radius` (2→0): `MxRadius.fieldRadius`.
- `no_raw_spacing_value` (2→1): dashboard 96 → `MxSpacing.space12`. Left statistics 120 (no matching token — rule over-reaches for a component dimension).
- Left as guard-over-strict (not fixed): `i18n.no_hardcoded_strings` (3 — all numeric labels `${i+1}`/box-count/`$percent%`, not translatable prose); `no_raw_duration_value` (player 3s — no motion token exists + it's a behavior cadence, out of the rule's own stated scope).

verify --full GREEN (186 tests). Errors 523→518 net.

## 2026-06-28 · Web support (flutter run -d chrome) — fixed

User couldn't run `flutter run -d chrome --web-port 3000`. Two distinct causes:

1. **Compile blocker (real):** the app's Drift DB used `NativeDatabase` → `dart:ffi`/`dart:io`, which can't compile for web (`flutter build web` failed: "Dart library 'dart:ffi' is not available on this platform"). Fixed by making the DB backend platform-conditional:
   - `connection/database_connection.dart` now `export 'connection_unsupported.dart' if (dart.library.io) 'connection_native.dart' if (dart.library.js_interop) 'connection_web.dart'`.
   - Native keeps NativeDatabase; web uses `WasmDatabase.open(databaseName:'memox', sqlite3Uri:'sqlite3.wasm', driftWorkerUri:'drift_worker.dart.js')`.
   - Web assets committed: `web/sqlite3.wasm` (sqlite3 2.9.4, curled from the release) + `web/drift_worker.dart.js` (compiled from `web/drift_worker.dart` = `WasmDatabase.workerMainForOpen()`, matching drift 2.31.0). Regeneration documented in `web/README-drift.md`. `.js.deps`/`.js.map` gitignored.
   - The other two `dart:io` sites conditionalized too: `path_file.dart` (backup/restore) + `file_saver.dart` (export) — native impls off-web, throw-stubs on web. Tests still use the native in-memory db on the VM.
   - Result: `flutter build web` → `√ Built build\web`; `flutter run -d chrome` reaches "Flutter run key commands" (serving). Commit `0dd4a5db`, verify --full GREEN (186 tests).

2. **Port 3000 in use (environment):** after the compile was fixed, the run failed to bind 3000 (`errno 10048`) — a stale process (likely a prior hung `flutter run`) held it. Freed it; rerun served fine. If it recurs, kill the listener on 3000 (`Get-NetTCPConnection -LocalPort 3000` → Stop-Process) or use a different `--web-port`.

### Web limitations (documented in web/README-drift.md)
- File export + local file backup/restore throw on web (no browser filesystem) — use cloud sync there.
- Notifications/TTS depend on browser support.
- Web isn't yet in the release-readiness target list; this enables dev/preview on web.

## 2026-06-28 · Design system — shared widget library built (Phase 0–4)

User: `lib/presentation/shared` had no real widgets and the theme wasn't fully on the design kit. Assessment: tokens (mx_colors/typography/radius/spacing/sizes/elevation) + app_theme were actually faithful to `docs/design/MemoX Design System/tokens/*`; the real gaps were (a) the brand font wasn't wired, and (b) the 16 design-kit components weren't built.

Built across 5 commits (each token-only + guard doc-header + smoke test, verify --full GREEN):
- `eeadac73` **Phase 0 font** — wired Plus Jakarta Sans (asset + pubspec); app was rendering in platform sans.
- `aab4e399` **surfaces** — MxScaffold, MxAppBar, MxCard, MxSectionHeader, MxIconTile.
- `b79ae6ec` **core controls** — MxButton (5 variants), MxChip, MxSwitch, MxSegmentedControl, MxBadge, MxAvatar.
- `eefce1c2` **inputs+nav** — MxTextField, MxSearchField (MxSearchDock), MxIconButton, MxFab, MxBottomNav.
- `21ac799e` **text+async+feedback** — MxText (the text-role API centralizing TextTheme access), MxStateView (loading/empty/error), MxSnackbar.

All 16 design-kit components + the text/state/feedback helpers now live under `lib/presentation/shared/widgets/{surfaces,buttons,inputs,display,navigation,states,feedback}/`. My new widgets pass the guard's `shared_widget_doc` rules (doc-header format matches the fixture).

### Guard delta + two follow-ups
- `missing_target_path` for mx_text_field/mx_search_field: resolved (files exist).
- Guard total errors rose slightly (518→541): building the wrapper layer ADDS no_raw_*/no_direct_text_theme hits **inside the Mx widgets themselves** — e.g. MxFab must call FloatingActionButton, MxAppBar/MxButton style via TextTheme. The guard doesn't exempt the design-system implementation layer. **Recommended Tier-A guard fix:** scope `no_raw_*` / `no_direct_text_theme` to exclude `lib/presentation/shared/widgets/**` (the layer whose job is to wrap raw primitives). MxText then becomes the only sanctioned TextTheme reader.
- 25 `shared_widget_doc` warnings remain on 5 PRE-EXISTING shared widgets (MxResponsiveBuilder, MxDeckTile, MxPlaceholder, …) that predate this format — add structured headers when convenient.

### Remaining = Phase 5 (separate)
Migrate the ~20 feature screens to use the Mx widgets (replaces raw Material + direct TextTheme) — this is what actually clears the bulk of the guard's 523 screen-level errors. Not started.

## 2026-06-28 · Phase 5 — screen migration to Mx widgets (in progress: 5/16)

Migrating feature screens off raw Material onto the design-system widgets. Pattern (per screen): Scaffold→MxScaffold, AppBar→MxAppBar, Filled/Outlined/Elevated→MxButton, IconButton→MxIconButton, FloatingActionButton→MxFab, Switch/SwitchListTile→MxSwitch row, FilterChip/ChoiceChip→MxChip, SegmentedButton→MxSegmentedControl, ScaffoldMessenger/SnackBar→MxSnackbar, `.when(loading/error)`→MxStateView, `Text(style: textTheme.X)`→MxText.role. Keys + behavior preserved; verify --full GREEN per batch.

Done (3 commits):
- `a939c2a4` reminder + theme (no test).
- `fa1aea57` settings (18 raw → ~0).
- `643ae577` import + export.

Remaining 11 screens: deck_detail (10), study_session (7), review (6), library* (6), game (5), player (4), statistics* (4), search* (4), dashboard* (4), game_picker* (2), flashcard_editor* (16). (* = has a widget test → migrate carefully, keep the asserted text/keys/types; e.g. a test using `find.byType(FilledButton)` must switch to `find.byType(MxButton)`).

Dropdowns (DropdownButtonFormField) kept as-is — no Mx dropdown component in the kit yet. TimePicker kept (platform dialog).

## 2026-06-28 · Phase 5 COMPLETE — all 16 screens migrated to Mx widgets

Finished the screen migration (8 commits total). Every feature screen now composes the design-system widgets instead of raw Material:
- a939c2a4 reminder+theme · fa1aea57 settings · 643ae577 import+export · e42c0fab study(session/review/player) · e839160c deck-detail+game · 9466a5a3 game-picker+search · e49fb36e statistics+dashboard · 458a6e9a library+flashcard-editor.

Guard impact: total errors 541 → **362**. Screen-level rules cleared:
- no_raw_scaffold 14→0, no_raw_switch 7→0, no_raw_chip 4→0, no_raw_snackbar 5→0, no_direct_scaffold_messenger →0.
- no_raw_app_bar 14→1 (search keeps an AppBar-hosted TextField), no_raw_icon_button 14→1.
- **no_direct_text_theme 81→7**, no_raw_button 49→14 — the residual is INSIDE the Mx widget implementations (MxAppBar/MxButton/MxText must read TextTheme / wrap raw primitives) + the 4 game widgets (matching/recall/typing/multiple_choice, which are gameplay widgets, not screens).

### Migration notes / decisions
- Kept raw where no Mx equivalent exists: DropdownButton(FormField), showTimePicker, showModalBottomSheet sort sheet, AlertDialog/showDeckActions sheets, LinearProgressIndicator. The search field stays in a raw AppBar (MxAppBar takes a String title, not a TextField).
- Kept the flashcard-editor term/meaning TextFields raw: the widget test calls `enterText(find.byKey(...))` which needs an EditableText, so the key must stay on the TextField, not an MxTextField wrapper.
- Test update: `flashcard_editor_screen_test` cast `editorSave` to FilledButton → MxButton. Other screen tests assert text/keys/icons (not widget types) → unaffected.
- All keys + behaviour preserved; verify --full GREEN per batch.

### Remaining (small, optional follow-ups)
1. **Tier-A guard exemption** (recommended): scope `no_raw_*` / `no_direct_text_theme` to exclude `lib/presentation/shared/widgets/**` (the design-system layer's job is to wrap raw primitives) → the residual ~362 drops sharply and the count reflects real feature-code violations only.
2. Migrate the 4 game widgets (matching/recall/typing/multiple_choice) to MxText/MxButton/MxCard if desired (they're gameplay, lower priority).
3. Add structured doc-headers to the 5 legacy shared widgets (MxDeckTile/MxPlaceholder/MxResponsiveBuilder…).

## PARITY LOOP (per-screen node parity to design kit) — started 2026-06-29

Self-paced /loop: ONE screen per iteration → add `ValueKey('mx-node:<screen>/<node>')`
to FE widgets matching the kit contract (`tool/parity/contracts/*.gen.json`); for
deliberate architectural divergences add a documented `tool/parity/intent-ledger.json`
exception (cite a doc); extend the verify `parity_fe_keys` gate with the screen;
`node tool/parity/fe_node_usage.mjs --check --screen <X>` must be clean; verify --full
GREEN; commit+push; then ScheduleWakeup to continue.

- DONE: dashboard (271ba4ea) · library (29ba5597 — 7 keyed, 3 exempt) · deck-detail
  (7b833db0 — 10 keyed +empty Add/Import +error retry, 7 exempt: card delete/audio→editor,
  reset→engine, search-dock→/search, move-apply→tap-to-apply) · statistics (aa59387f —
  7 keyed, 2 exempt: streak-current/longest→dashboard) · settings (5936c6ee — screen/appbar
  keyed, 2 exempt: profile→no-account, srs-notif-switch→/reminder screen) · search (13ab5a66 —
  3/3 keyed screen/appbar/dock, 0 exempt) · study-session (5dc40d10 — 6 keyed screen/appbar/
  card/next/exit-cancel/exit-ok, 10 exempt: in-game controls→game widgets, resume/save-error→1 msg) ·
  review (98d99b7d — 8 keyed, 6 exempt: edit/audio/options→editor read-only D-007, text-size→/theme) ·
  player (3adc4c82 — 8 keyed +prev/next mới, 3 exempt: speed/options→minimal v1, text-size→/theme) ·
  study-result (736f7276 — 3 keyed, 6 exempt) · game-picker (03f9ffcb — 4/4 keyed, 0 exempt) · game-matching (821f4801 — switch tĩnh phủ 4 game, 2 exempt) · game-mc (f11f0e55 — 2 keyed, 3 exempt) · game-recall (873ef1c0 — 5 keyed, 4 exempt) · game-typing (64dc72dc — 5 keyed, 2 exempt) [xong cụm 4 game] · flashcard-editor (2556f999 — 8/8 keyed, 0 exempt) · import (68ac4773 — 6 keyed, 1 exempt) · export (fa260bb4 — 5 keyed, 2 exempt) · reminder (df7eeb99 — 4 keyed, 1 exempt) · theme (aafa7dbc — 6/6 keyed, 0 exempt) · account (2bac4026 — 1 keyed, 7 exempt) · drawer (ae41628b — 5 keyed add/remove screens+confirm, 2 exempt: pair-0/1-del→delete theo id).
- QUEUE: 0 — XONG.
  player · study-result · game-picker · game-matching · game-mc · game-recall · game-typing ·
  flashcard-editor · import · export · reminder · theme · account-sync · drawer.
- NEXT ITERATION = (không còn — loop dừng).


### FINAL SUMMARY — PARITY LOOP HOÀN TẤT (2026-06-29)
- **22/22 màn** kit có node-parity với FE: dashboard(shell) · library · deck-detail · statistics · settings · search · study-session · review · player · study-result · game-picker · game-matching · game-mc · game-recall · game-typing · flashcard-editor · import · export · reminder · theme · account · drawer.
- `node tool/parity/fe_node_usage.mjs --check` (mọi màn): **186 node kit · 122 keyed · 0 missing · 0 orphan · 64 exempt**.
- 64 exempt đều có doc trong `tool/parity/intent-ledger.json` (divergence kiến trúc thật: shared shell/scaffold, control trong game widget dùng chung, audio/edit ở editor, các tính năng v1 chưa có, account = human gap GCP).
- `verify` enforce parity_fe_keys cho cả 22 màn; mọi commit verify --full GREEN, push origin main, không lần nào push đỏ.
- ~20 commit feat(parity) + ~20 commit docs(parity-loop). Loop chạy cadence 1 phút, mỗi vòng 1 màn.
- Cải tiến phụ kèm theo: nút prev/next cho player, Add-word/Import/retry empty&error state cho deck-detail, go-deck cho import, headKey cho _StatsCard, super.key cho _Preview, MxText kế thừa màu DefaultTextStyle.

## STYLE-PARITY (tầng 2 — màu/cỡ/bo góc, spec-vs-spec không pixel) — 2026-06-29
Ý tưởng user: gen spec từ Flutter render tree (per mx-node, token-aware) rồi diff với kit spec — robust hơn so ảnh.
- Tool: test/parity/fe_spec_export_test.dart (walk render tree → fe-specs/<màn>.json, màu→--memox-* token, ghi khi MEMOX_EXPORT_SPEC=1) + tool/parity/spec_diff.mjs (diff per node, --check gate, đọc styleExempt từ intent-ledger).
- ÁP DỤNG library (3eaf0f55): spec_diff library --check = **0 mismatch** (5 OK + 1 documented).
  Fix FE do tool chỉ ra: MxButton radius pill→control(12); MxIconButton icon 20(space5)→22(MxIconSize.md). styleExempt: library/create (ghost vs primary +).
- NEXT (nếu nhân rộng): mỗi màn dựng harness pump đủ state → export → spec_diff → fix/ledger → wire spec_diff --check vào verify cho màn đó. Khi đủ 22 màn, verify chặn cả lệch style.

## STYLE-PARITY LOOP — bắt đầu 2026-06-29
Gate `style_parity` đã nối vào verify (run_style_parity.mjs → spec_diff <màn> --check cho các màn trong SCREENS). Mỗi vòng 1 màn:
1. Thêm harness pump màn vào test/parity/fe_spec_export_test.dart (dùng _pumpAndExport; seed data + route args để node hiện).
2. `MEMOX_EXPORT_SPEC=1 flutter test test/parity/fe_spec_export_test.dart` + `node tool/parity/spec_diff.mjs <màn>`.
3. Mỗi DIFF: **sửa FE cho khớp token kit** (mặc định — kit is source of truth) HOẶC thêm styleExempt (intent-ledger) cho divergence có chủ đích (kèm source).
4. Thêm <màn> vào SCREENS trong tool/parity/run_style_parity.mjs.
5. spec_diff <màn> --check = 0 mismatch; dart format; verify --full GREEN (đã gồm style_parity); commit+push; NIGHT-LOG/WBS §10; schedule.
- DONE: library (3eaf0f55) · search (93bfc353 — dock→filled pill) · reminder (da8b1b2f — time→chip) · theme (dfe8e29f — _Preview→flat) · settings (643c5a47 — appbar large) · statistics (38a84765 — heads→card) · flashcard-editor (b93aaad4 — **fix MxButton label contrast** (chữ foreground thay onSurface); harness build child sau seed (deckId); exempt hidden-switch/add-meaning/audio-play) · export (44c2572c — exempt switch/button-font) · import (9b9074bd — appbar/screen OK) · deck-detail (65458ff5 — add FAB khớp) · study-session (0df12bc1 — term→48) · review (0869555f — term/meaning) · player (77f04229 — card MxCard) · study-result (cb22dea1 — drive finished) · game-picker (823c2a00 — exempt scope) · game-matching (25ea449c — screen/appbar) · game-mc (20baa7d9 — prompt→48) · game-recall (9d746b1e — term→48) · game-typing (389c834f — meaning→bodySmall tertiary; exempt check/hint Material button) [4-game DONE].
- QUEUE (3): account · drawer · dashboard.
- NEXT = account.
