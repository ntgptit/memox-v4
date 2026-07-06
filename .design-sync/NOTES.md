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

## Sync of 2026-07-03 (HEAD 913b4c3)
- Design dir byte-identical since prior `lastSyncedCommit` (71e77fe); only merge +
  `.design-sync/` bookkeeping commits in between (`git diff 71e77fe..HEAD -- localDir` empty). **0 uploads, 0 deletions.**
- Structural diff (local tree vs `list_files`): 211 local non-shot files all present remote;
  234 shot pngs unchanged (git-clean since lastSynced, prior parity 234==234); only remote
  extra is the app-generated `templates/memox-dashboard/.thumbnail` (intentionally kept — preview
  for the still-present `MemoxDashboard.dc.html`, never a source file).
- Content spot-check `components/core/MxButton.jsx`: md5 identical after CRLF→LF normalize
  (`bd797a06…`). No external drift on remote.
- No plan opened / no sentinel re-arm — zero writes/deletes, app card index already correct.
- Advanced `lastSyncedCommit` 71e77fe → 913b4c3 (current HEAD) so the next sync diffs from here.

## Sync of 2026-07-06 (HEAD 3632ceb) — bidirectional reconcile
Prior 0-upload syncs (913b4c3, and lastSynced 8b4e8f6) advanced `lastSyncedCommit`
on false confidence: they diffed the local *git* tree (byte-stable) and spot-checked
only `MxButton`, so they **missed** that the remote was a genuinely OLD snapshot from
the pre-repo-reset design-sync CLI. Full structural + content diff this run found the
remote was on the **old fat-bundle CLI format** (261 KB `_ds_bundle.js` that embeds
every feature component; 15× `McPromptCard`/`RecallTermCard`) plus the pre-reset
per-feature `*.card.html` composites — while local uses the **new lean CLI**
(51 KB core-only bundle, no composites) and the `McPromptCard→PromptCard` /
`RecallTermCard→TermCard` rename. Sources/tokens/CSS/specs verified identical
(`.source-hash` 5e856457 match; `MxButton` md5 bd797a06 match; styles/components/
colors/kit-helpers/Dashboard all current). Drift was exactly the CLI-generated
assembly + the rename blast radius.

- **Uploaded 9** (the "5 local-newer" drifted same-path files + 4 renamed-new):
  `_ds_bundle.js`, `_ds_manifest.json`, `ui_kits/memox-app/index.html`,
  `_features/game-mc/GameMultipleChoice.jsx`, `_features/game-recall/GameRecall.jsx`,
  `_features/game-mc/components/PromptCard.{d.ts,jsx}`,
  `_features/game-recall/components/TermCard.{d.ts,jsx}`.
  (index.html + the 2 screen importers referenced the deleted McPromptCard/
  RecallTermCard — they MUST ship with the rename or the app breaks; that's why the
  set is 9, not 5.)
- **Deleted 27 stale orphans:** 23 `*.card.html` composites (22 feature + `_shared`)
  + `McPromptCard.{d.ts,jsx}` + `RecallTermCard.{d.ts,jsx}`.
- **Kept on remote (intentional):** `templates/memox-dashboard/.thumbnail`
  (app-generated), `audit/**` (19), `uploads/Screenshot_20260706_113525_Chrome.jpg`.
- **Pulled DOWN into localDir** (new design content the user wants local): `audit/`
  = `UI-UX Audit.html` + `_dts_list.txt` + `_sheets/01,03..17` (15 PNGs). **3 files
  could NOT be downloaded — `get_file` hard-caps at 256 KiB and these exceed it:**
  `audit/_sheets/02-library.png`, `audit/_sheets/17-edge-b.png`,
  `uploads/Screenshot_20260706_113525_Chrome.jpg`. They remain on the remote; fetch
  them manually from the project if a local copy is needed (no range/offset on the tool).
- Re-armed `_ds_needs_recompile` (before + after) so the app rebuilds its card index
  and drops the 23 orphan composite cards. Advanced `lastSyncedCommit` 8b4e8f6 → 3632ceb.
- **NEW standing fact:** never trust a git-only 0-upload verdict for this project — the
  remote can silently lag the repo across a reset/restore. A real sync must diff the
  remote `list_files` + content-hash the generated assembly (`_ds_bundle.js`,
  `_ds_manifest.json`, `index.html`) against local, not just git.

## Sync triggers (both PUSH, repo kit → Claude Design)
- **`.githooks/pre-push`** — on `git push` whose range touches `localDir`; runs
  `sync-design.mjs --no-record`.
- **`.githooks/post-merge`** (added 2026-07-03) — after `main` receives kit
  changes (covers server-side PR merges + agent pushes that bypass pre-push).
  Only on `main`; compares against `lastSyncedCommit`; runs `sync-design.mjs`
  (record mode, advances lastSyncedCommit). Warns if `claude` CLI absent.
- Both honor `MEMOX_SKIP_DESIGN_SYNC=1`. **Agent sessions (no design-auth TTY)
  must prefix BOTH `git push` and `git pull` on main** with it, or the nested
  `claude` hangs.

## Standing facts for next sync
- No `_ds_sync.json` anchor is produced for this hand-authored layout, so each sync re-verifies by comparing the local tree against `list_files` (this is expected/correct).
- Shots parity check: `ui_kits/memox-app/shots/` = 234 files, matched exactly.
- **Headless invocation (proven 2026-07-03):** `/design-sync` runs fully non-interactive as a nested CLI —
  `MSYS_NO_PATHCONV=1 claude -p "/design-sync" --dangerously-skip-permissions --max-turns 40`.
  The `MSYS_NO_PATHCONV=1` is REQUIRED on Git Bash / Windows: without it, Git Bash rewrites the `/design-sync`
  argument into a Windows path (`C:/Program Files/Git/design-sync`) before it reaches claude, so the slash
  command never runs and the nested session just asks "what do you want?". The nested CLI inherits the
  machine's own claude.ai design-system authorization (granted once via interactive `/design-login`), so no
  interactive terminal is needed per-run — this makes design-sync automatable from a hook/cron/agent Bash call.
  (Note: an agent session's own DesignSync *tool* may still lack design auth — delegate to this subprocess instead.)
