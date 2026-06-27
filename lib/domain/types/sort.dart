/// Sort criteria for library/deck lists (`docs/contracts/types-catalog.md`,
/// D-023). `createdAt`/`lastStudied` apply to cards directly; for decks they use
/// proxies (insertion id, max subtree study time) since the `deck` table holds
/// neither column — see `docs/business/deck/deck-management.md`.
enum SortBy { alphabet, createdAt, lastStudied }

enum SortDirection { asc, desc }
