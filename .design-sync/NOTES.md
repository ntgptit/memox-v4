# design-sync notes

Target project: `MemoX Design System_v4` (`2ffa54ae-10eb-49b1-b005-d253b54a5711`), owner Giap Nguyen.
Local source of truth: `docs/design/MemoX Design System/` (hand-authored / off-script layout — no runnable converter or Storybook in this repo).

## Sync of 2026-07-02 (HEAD bd50005)
- Design dir was byte-identical to the prior `lastSyncedCommit` (25b119a); no source changed. Content spot-check (`MxButton.jsx`) confirmed remote copies were already current. **0 uploads.**
- Removed **19 stale remote orphans** left by an earlier (pre-repo-reset) sync, from before `ui_kits/memox-app` was refactored from flat screen files into `_features/**` + `index.html`:
  - 15 flat `*.jsx` (DashboardApp, Export, FlashcardEditor, FolderApp, GameMatching, GameTyping, Import, Library01, LibraryApp, Player, Reminder, Review, Search, Settings, Statistics)
  - 4 numbered prototype HTMLs (`01 Library Prototype`, `01 Library`, `02 Dashboard Prototype`, `03 Folder Detail Prototype`)
- **Intentionally kept** `templates/memox-dashboard/.thumbnail` — it is an app-generated preview for the still-present `MemoxDashboard.dc.html` template, not a stale source file (never tracked in git).
- Re-armed `_ds_needs_recompile` so the app rebuilds its card index and drops any orphan cards.

## Sync of 2026-07-03 (HEAD ad480d7)
- Design dir byte-identical since prior `lastSyncedCommit` (bd50005); only `.design-sync/` bookkeeping changed in between. **0 uploads, 0 deletions.**
- Structural diff (local tree vs `list_files`): local 445 files all present remote; remote is an exact superset with the 2 expected app-generated extras (`templates/memox-dashboard/.thumbnail`, `_ds_needs_recompile`). Shots parity 234==234.
- Content spot-check `components/core/MxButton.jsx`: identical (md5 match after CRLF→LF normalize; local is CRLF, remote LF — cosmetic, not a drift, same state as prior 0-upload sync).
- No plan opened / no sentinel re-arm — with zero writes/deletes the app card index is already correct.

## Standing facts for next sync
- No `_ds_sync.json` anchor is produced for this hand-authored layout, so each sync re-verifies by comparing the local tree against `list_files` (this is expected/correct).
- Shots parity check: `ui_kits/memox-app/shots/` = 234 files, matched exactly.
