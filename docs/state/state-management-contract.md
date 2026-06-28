# State management contract — MemoX V4

How UI state is produced, scoped, and disposed. Keep providers/stores thin: they
orchestrate use cases, they don't hold business logic or the only copy of data.

## Choice

**Riverpod 3** — `@riverpod` codegen **đã bật** (drift ghim `<2.34` để chung analyzer 9,
xem `docs/stack/stack.md`). Notifier family/autoDispose (`StudySessionNotifier`,
`GameSessionNotifier`, `DeckDetailNotifier`, `LibraryNotifier`, `Statistics`) dùng
`@riverpod` (provider sinh ra **bỏ hậu tố `Notifier`** → `studySessionProvider`,
`gameSessionProvider`, `deckDetailProvider`, `libraryProvider`, `statisticsProvider`).
Notifier đơn (`LanguagePairNotifier`, `EngagementNotifier`, `SettingsNotifier`,
`PersonalizationNotifier`, `SearchNotifier`, `StatsScopeNotifier`) + `Provider` DI hiện vẫn
viết tay (`AsyncNotifierProvider`/`NotifierProvider`) — chuyển dần sang `@riverpod` được.
Riverpod 3: đọc giá trị async bằng `AsyncValue.value` (không còn `valueOrNull`). Trạng thái bất đồng bộ dùng `AsyncValue<T>`: `AsyncNotifier` cho màn/ngữ cảnh
có hành động (study/game/editor, cặp ngôn ngữ), `FutureProvider`/`StreamProvider` cho đọc
thuần. Một notifier cho một mối-quan-tâm; mặc định `autoDispose`, `keepAlive` cho state
xuyên màn. State chỉ **điều phối use case** — không chứa business logic, không giữ bản sao
dữ liệu duy nhất.

## Per-store contract

| Store / notifier | Owns | Reads (use cases) | Lifetime |
| --- | --- | --- | --- |
| `LanguagePairNotifier` | ngữ cảnh cặp (danh sách, cặp đang chọn, chiều hiển thị) | getPairContext, createLanguagePair, setActivePair, swapDisplayDirection, removeLanguagePair | keepAlive |
| `LibraryNotifier` | cây thư viện gốc của cặp đang chọn + sort + mutations deck | getLibraryTree, sortDeckNodes, create/rename/move/deleteDeck | autoDispose |
| `DeckDetailNotifier` | một node: bộ thẻ con (có stats) + thẻ trực tiếp | getDeckNode, listByDeck (+ mutations deck) | autoDispose (family theo deckId) |
| `StudySessionNotifier` | hàng đợi + thẻ hiện tại + chặng + tiến độ (NewLearn/DueReview) | buildStudyQueue, gradeCard, scheduleNewCard, finalizeStudySession | autoDispose (family theo StudyRequest) |
| `GameSessionNotifier` | ván game (N thẻ, hàng đợi học-lại, tiến độ) | buildGameRound (đọc card/srs, KHÔNG ghi SRS — D-007) | autoDispose (family theo GameRequest) |
| `SettingsNotifier` | cài đặt (game, SRS, mục tiêu, nhắc, tự-sao-lưu) + sao lưu/khôi phục | getSettings, updateSetting, backup/restore (BackupRepository) | keepAlive |
| `EngagementNotifier` | hoạt động ngày + mục tiêu + streak + tóm tắt thư viện | dailyActivity.forDay/allForPair, settings.readInt (mục tiêu), computeStreak, deck.libraryTree | keepAlive |
| `StatsScopeNotifier` | phạm vi thống kê đang chọn (cặp/toàn app) | — (UI state) | keepAlive |
| `Statistics` (`@riverpod`) | thống kê theo phạm vi (tổng quan, ô Leitner, dự báo, hoạt động) | getStatistics (đọc card/srs_state/daily_activity) | autoDispose (family theo StatsScope) |
| `PersonalizationNotifier` | theme (chế độ màu + màu nhấn + cỡ chữ) | settings.readAll, updateSetting | keepAlive |

## Rules

- State stores call use cases; they never touch repositories/data sources directly.
- Persistent data is never held only here — it has a home in `docs/database/storage-boundaries.md`.
- No side effects in build/render; no watching reactive state inside callbacks.
- Loading/error/empty are explicit states, not implicit nulls.

## Related

- `docs/architecture/overview.md` — where state sits
- `docs/contracts/error-contract.md` — loading/error states
- `docs/database/storage-boundaries.md` — data not held only in memory
