# Work breakdown structure — MemoX V4

> Baseline reviewed: 4879608 (2026-06-26)

Source of truth for task breakdown and allocation. Any task that creates, renames,
splits, merges, re-scopes, defers, or completes a work package updates this file in
the same commit (CLAUDE.md WBS rule).

## 1. Work packages

| WBS ID | Work package | Depends on | Status | Spec |
| --- | --- | --- | --- | --- |
| W1 | Nền: kiến trúc + core (error/types/router/theme/DI) | — | Done | `docs/architecture/overview.md` |
| W2 | Thẻ (Card) CRUD + nghĩa đa trường | W1 | Done | `docs/business/flashcard/flashcard-management.md` |
| W3 | SRS 8-box Leitner | W2 | Done | `docs/business/srs/srs-review.md` |
| W4 | Học & 5 lối vào (NewLearn 5 chặng) | W3, W5 | Done | `docs/business/study/study-flow.md` |
| W5 | 4 game luyện | W2 | Done | `docs/business/game/game-modes.md` |
| W6 | Bộ thẻ (cây lồng nhau) | W2 | Done | `docs/business/deck/deck-management.md` |
| W7 | Tìm kiếm | W2 | Done | `docs/business/search/global-search.md` |
| W8 | Nhập / Xuất | W6 | Done | `docs/business/import-export/import-export.md` |
| W9 | Thống kê | W3, W11 | Done | `docs/business/statistics/statistics.md` |
| W10 | Tài khoản & Đồng bộ Google | W1 | Partial (cấu trúc + LWW snapshot + tests; GCP/OAuth config = human gap) | `docs/business/account-sync/account-sync.md` |
| W11 | Gắn kết / streak | W4 | Done | `docs/business/engagement/dashboard-engagement.md` |
| W12 | Cài đặt & Backup cục bộ | W1 | Done | `docs/business/settings/settings.md` |
| W13 | Theme (personalization) | W12 | Done | `docs/business/personalization/personalization.md` |

Status ∈ Planned / In-progress / Blocked / Done. **W1 Done** (nền kiến trúc + core:
error/types/router/theme/DI đã code & test); **W2 Done** (Card CRUD + nghĩa đa trường +
editor; audio TTS xong sau ở gap-fill 3c847223); **W6 Done** (cây bộ thẻ tự lồng + library home + deck detail +
tổng hợp đệ quy); **W3 Done** (engine SRS 8 ô Leitner — scheduler + queue + cap, BE-only);
**W5 Done** (4 game + picker, luyện thuần không đổi SRS); **W4 Done** (5 lối vào + Play menu +
NewLearn/DueReview/Review/Player/result + daily_activity); **W7 Done** (tìm kiếm term+nghĩa +
lọc trạng thái); **W11 Done** (dashboard Today: hoạt động + mục tiêu + streak D-021);
**W9 Done** (thống kê: tổng quan + ô Leitner + dự báo + hoạt động, phạm vi cặp↔toàn app);
**W12 Done** (cài đặt k-v + game/SRS/mục tiêu, sao lưu/khôi phục JSON; lịch nhắc lưu được,
lên lịch OS hoãn); **W13 Done** (cá nhân hoá: chế độ màu + màu nhấn + cỡ chữ, áp dụng live).
**Toàn bộ S0 + W2–W13 đã code & test. W8 Done (nhập/xuất). W10 Partial**: cấu trúc đồng
bộ (CloudSyncService + SyncNow LWW snapshot + Drive REST/sign-in + tests) đã xong; chỉ còn
**human gap** = cấu hình GCP/OAuth (client id, bật Drive API, file OAuth theo nền tảng) —
xem §10 + NIGHT-LOG.

**S0 (nền tiếp theo, tiền đề mọi feature) Done:** app shell (`StatefulShellRoute` +
bottom nav 4 tab + Drawer cặp ngôn ngữ) + Drift `language_pair` (DAO/repo/usecases:
list·create·remove·setActive·swapDisplay) + ngữ cảnh cặp keepAlive + l10n (vi/en) +
DI. Codegen Riverpod hoãn (xung đột `drift_dev`, xem `docs/stack/stack.md`).

> **Pivot v1 (2026-06-28):** bỏ khái niệm **Thư mục** — bộ thẻ **tự lồng nhau** (cây) đảm
> nhiệm việc tổ chức. W6 (Thư mục) cũ bị xoá; **W7–W14 cũ dồn xuống W6–W13**. Phụ thuộc đã
> remap. Chi tiết: `docs/business/deck/deck-management.md`.

## 2. Map sang dòng quyết định

| WBS | Dòng quyết định (core-decision-table) |
| --- | --- |
| W2 | D-006, D-020 |
| W3 | D-002, D-003, D-004, D-005, D-011, D-018 |
| W4 | D-001, D-007, D-009, D-010, D-016, D-029 |
| W5 | D-008, D-013, D-015 |
| W6 | D-023, D-024 |
| W7 | D-019, D-028 |
| W8 | D-025, D-026 |
| W10 | D-027 |
| W11 | D-010, D-021 |
| W12 | D-012 (Premium — hoãn v1) |

## 10. Commit Traceability Log

Append-only, newest first. One line per commit that touches a WBS work package:
`<8-char hash> · <YYYY-MM-DD> · <WBS IDs> · <summary>`.

- 3adc4c82 · 2026-06-29 · W4 · parity loop màn 9/22 (player): key 8 node (screen/appbar/card/prev/playpause/next/replay/close; thêm nút prev/next skip thủ công); 3 exempt (speed/options→auto-play tối giản v1, text-size→/theme); extend verify parity
- 98d99b7d · 2026-06-29 · W4 · parity loop màn 8/22 (review): key 8 node (screen/appbar/meaning/term/prev/next/study-now/back-deck); 6 exempt (edit/edit-cancel/edit-save/audio/options→duyệt read-only D-007 + sửa qua editor; text-size→/theme global); extend verify parity
- 5dc40d10 · 2026-06-29 · W4 · parity loop màn 7/22 (study-session): key 6 node sở hữu màn (screen/appbar/card/next/exit-cancel/exit-ok); 10 exempt (reveal/check/hint/options/due-next/due-relearn→game widget chung game-*; resume-*/save-error-*→1 message state v1); extend verify parity
- 13ab5a66 · 2026-06-29 · W7 · parity loop màn 6/22 (search): key 3/3 node (screen/appbar/dock; đổi searchField→search/dock + cập nhật test); 0 exempt; extend verify parity cho search
- 5936c6ee · 2026-06-29 · W12 · parity loop màn 5/22 (settings): key settings/screen+appbar; 2 exempt (profile→app local không có account, srs-notif-switch→màn /reminder riêng); extend verify parity cho settings
- aa59387f · 2026-06-29 · W9 · parity loop màn 4/22 (statistics): key 7 node (screen/appbar/overview-head/accuracy-head/leitner-head/weekly-head/heatmap-head; thêm headKey vào _StatsCard; weekly→due-forecast 7 ngày) + 2 exempt (streak-current/longest→dashboard); extend verify parity cho statistics
- 7b833db0 · 2026-06-29 · W6 · parity loop màn 3/22 (deck-detail): key 10 node contract (screen/appbar/menu/add/empty-add/empty-subdeck/empty-import/retry/deck-delete-cancel/ok) + thêm empty Add-word/Import + error retry; 7 intent-ledger exception (card delete/audio→editor, reset→engine SRS, search-dock→/search, move-apply→áp dụng khi chạm đích); extend verify parity cho deck-detail
- 29ba5597 · 2026-06-29 · W6 · parity loop màn 2/22 (library): key 7 node contract (screen/appbar/search-btn/sort-btn/create/empty-deck/retry) + 3 intent-ledger exception (overflow→drawer, search-dock→/search, empty-add→cần deck); extend verify parity_fe_keys cho library; cập nhật library_screen_test
- 271ba4ea · 2026-06-29 · S0,W11 · design-kit nav restructure + parity pipeline: MxBottomNav 5 mục (Add center action) + Review FAB (Today) + MxAppBar large (ngày+lời chào trong app bar) + notifications/avatar mở drawer; dashboard re-key theo node kit (mx-node:dashboard/*) + empty-state Start studying; thêm tool/parity (parity_contract+parity_fe_keys vào verify) + intent-ledger ghi divergence (scaffold gộp vào shared AppShell) + tool/ui_kit_shots (shots+specs baseline) + tool/golden_diff; docs nav-flow + 02-dashboard; +l10n; cập nhật app_boot/dashboard/inputs_nav test
- ebda365b · 2026-06-28 · design-system · dựng lại Dashboard (Today) bám sát mockup kit (Dashboard.jsx): thẻ TODAY primary hero, GoalRing, lưới streak/mastered 2 cột, Continue studying + danh sách deck đến hạn (Review); MxText kế thừa màu DefaultTextStyle (đọc đúng onPrimary trên card primary); +l10n, cập nhật dashboard test
- 458a6e9a · 2026-06-28 · design-system · Phase 5 HOÀN TẤT — toàn bộ 16/16 màn hình migrate sang Mx widget (study/game/deck/game_picker/search/statistics/dashboard/library/flashcard_editor + cụm settings); guard lỗi 541→362, no_raw_scaffold/switch/chip/snackbar→0, no_direct_text_theme 81→7 (dư nằm trong tầng widget Mx); cập nhật flashcard_editor_screen_test (FilledButton→MxButton)
- 643ae577 · 2026-06-28 · design-system · Phase 5 migrate màn hình sang Mx widget (5/16): reminder+theme (a939c2a4), settings (fa1aea57), import+export (643ae577) — Scaffold/AppBar→MxScaffold/MxAppBar, button→MxButton, switch→MxSwitch, chip→MxChip, SegmentedButton→MxSegmentedControl, snackbar→MxSnackbar, textTheme→MxText; giữ key+behavior; còn 11 màn (6 có test)
- 21ac799e · 2026-06-28 · design-system · xây tầng shared widget (W14): font Plus Jakarta Sans wire (eeadac73); 16 component design-kit + text/state/feedback — surfaces (aab4e399: MxScaffold/MxAppBar/MxCard/MxSectionHeader/MxIconTile), core (b79ae6ec: MxButton/MxChip/MxSwitch/MxSegmentedControl/MxBadge/MxAvatar), inputs+nav (eefce1c2: MxTextField/MxSearchField/MxIconButton/MxFab/MxBottomNav), text+async+feedback (21ac799e: MxText/MxStateView/MxSnackbar); token-only + doc-header guard + smoke test; migrate màn hình (Phase 5) để sau
- 0dd4a5db · 2026-06-28 · platform · chạy được trên web: connection conditional native(dart:ffi)↔web(Drift WASM) + assets web/sqlite3.wasm + web/drift_worker.dart.js; conditionalize dart:io ở backup + file-save (web stub); `flutter build web` PASS, `flutter run -d chrome` chạy; export/local-backup degrade trên web (xem web/README-drift.md)
- 5863e973 · 2026-06-28 · W8,W10,W11 · fix Tier-C của code-verification-guard (ruleset memox): type-check jsonDecode (backup+Drive), tách FileSaveService (export screen bỏ dart:io), MxRadius.fieldRadius, MxSpacing.space12; phân loại A/B/C trong NIGHT-LOG
- da1c28cf · 2026-06-28 · release · CI gate (`.github/workflows/ci.yml` chạy verify --full trên push/PR) + `docs/checklist/release-readiness.md` (build-config TODO + human gap GCP + smoke-test thiết bị)
- 5db02f4a · 2026-06-28 · W9,W10 · hoàn tất 2 mục hoãn của review: gộp sign-in orchestration (SyncNowUseCase là nguồn duy nhất, notifier retry khi signInRequired) + bound query thống kê (heatmap windowed trong SQL, totals lifetime qua SUM riêng)
- 461747c7 · 2026-06-28 · W9,W10 · harden (4/4) test depth + doc: +6 test error-path SyncNow (isSignedIn/remoteMeta/serialize/download/deserialize + tie), +1 test GoogleDrive not-configured (MockClient không gọi mạng), doc statistics ghi rõ accuracy chỉ tính DueReview (186 test)
- 68ea6971 · 2026-06-28 · W4,W10 · harden (3/4) cleanup: bỏ StudySessionState.revealed + reveal() chết, SyncNow dùng valueOrNull thay cast
- 9e150ff9 · 2026-06-28 · W8,W12 · harden (2/4) UX: màn import/export báo lỗi khi Err (l10n transferError), export dùng Separator.comma.char, LocalNotificationService bỏ lên lịch khi bị từ chối quyền
- cebab9c1 · 2026-06-28 · W8,W12 · harden (1/4) perf: ExportCardsUseCase dùng CardRepository.listByIds (bỏ N+1 subtree), BackupRepository.deserialize multi-row INSERT theo chunk + validate tên cột; +1 test subtree
- 2edd575e · 2026-06-28 · W4,W7,W9,W10 · sửa theo review đệ quy 8 sub-agent: Study chấm đúng cardId+requeue (mirror GameSession; fix MatchingGame chấm sai thẻ), search escape ký tự LIKE (%/_), ComputeStreak.longest parse UTC (DST), backup deserialize chặn wipe khi JSON rỗng, Drive cache fileId sau khi upload xong, SyncNow stamp lastSync từ server modifiedTime; +4 test (177); doc parity (nav-flow bỏ route /settings/account, index Specified→Implemented, tables.drift schema_version 2)
- 30b4d56b · 2026-06-28 · W10 · đồng bộ Google Drive (cấu trúc): CloudSyncService + GoogleDriveSyncService (sign-in google_sign_in 7 + Drive REST appDataFolder qua http) + SyncNowUseCase (LWW mức snapshot qua cloud_last_sync_at, tái dùng backup serialize/deserialize) + tile /settings + tests (push/pull/LWW/signed-out faked); BackupRepository thêm serialize/deserialize + snapshot gồm review_outcome (sửa thiếu từ W9); dep http; HUMAN GAP = cấu hình GCP/OAuth client id + platform — W10 Partial
- 1d1e5072 · 2026-06-28 · W7 · tìm kiếm khớp đa từ-khoá AND (tách token theo khoảng trắng; mỗi token khớp term hoặc nghĩa) trong SearchDao — cải tiến recall không đổi schema; FTS5 đánh giá & hoãn đúng theo spec (LIKE tới khi perf cần); test multi-token + docs global-search (BR-1/AC-4/status) + D-019 (sửa luôn ref cột nghĩa cũ sang `card_meaning.content`)
- 7ef989e4 · 2026-06-28 · W9 · hoàn tất metric còn thiếu của W9: độ chính xác ôn (bảng `review_outcome` schema v2 — migration 1→2 + test), heatmap hoạt động 12 tuần, streak dài nhất (ComputeStreak.longest → dashboard W11); ReviewOutcomeDao/Repository ghi khi chấm DueReview; StatsDao.accuracy → StatisticsSummary; schema/migration/storage docs cùng commit
- 4b97f51c · 2026-06-28 · W13 · cá nhân hoá theme (chế độ màu sáng/tối/hệ thống + màu nhấn brand/warm/cool từ token sẵn có + cỡ chữ nhỏ/vừa/lớn) áp dụng live qua MemoXApp + lưu settings W12; AppTheme nhận accent re-seed ColorScheme; ThemeScreen /settings/theme có test persist/reload — bước build cuối, S0+W2–W13 xong
- c48fe360 · 2026-06-28 · W12 · cài đặt k-v (SettingsRepository read/write + GetSettings/UpdateSetting) + UI; số từ/ván feed game (D-008) qua route; mục tiêu ngày kích hoạt dashboard W11; sao lưu/khôi phục JSON cục bộ (BackupRepository raw-SQL) có test; lịch nhắc lưu được (lên lịch OS hoãn — gated dep); không khoá Premium (D-012)
- ac8fbfb8 · 2026-06-28 · W9 · thống kê (tổng quan thư viện + phân bố ô Leitner + dự báo đến hạn 7 ngày + hoạt động 14 ngày) phạm vi cặp↔toàn app; read-model trên card/srs_state/daily_activity (StatsDao + GetStatisticsUseCase) có test; biểu đồ dựng từ token/primitive, KHÔNG thêm dep chart; StatisticsScreen thay placeholder tab Stats
- c3e78e43 · 2026-06-28 · W4 · NewLearn chặng 2–5 dùng game thật W5 qua RoundController (RoundState + RoundActions ở `lib/presentation/features/game/round.dart`); widget game nhận round+actions (bỏ phụ thuộc provider trực tiếp); study & game notifier implement RoundActions; không đổi SRS/behavior tài liệu
- de8d09a5 · 2026-06-28 · W8 · nhập/xuất CSV/Excel/clipboard (D-025/D-026 có test): ImportCardsUseCase (map cột + soft-dup D-020) + ExportCardsUseCase (subtree + SRS option) không phụ thuộc plugin; TableCodec (csv 8 + excel 4) ở lớp data; màn import/export mở từ deck-detail; deps file_picker/csv/excel đã duyệt
- 3c847223 · 2026-06-28 · W2 · phát âm thuật ngữ (TTS): TtsService (interface) + FlutterTtsService (lớp data) + DI; nút loa kết nối ở thẻ; dep flutter_tts đã duyệt
- a5d55cc3 · 2026-06-28 · W12 · lên lịch thông báo nhắc học thật: NotificationService + ReminderScheduler + LocalNotificationService (flutter_local_notifications 22 + timezone) đồng bộ từ settings nhắc; deps đã duyệt
- a7e7ff4b · 2026-06-28 · W8,W10,W12 · thêm thư viện đã duyệt cho gap-fill round (file_picker/csv/excel/google_sign_in/googleapis/flutter_secure_storage/flutter_local_notifications/timezone/flutter_tts/flutter_timezone); giữ drift pin <2.34 để bật @riverpod codegen
- cbeedf0a · 2026-06-28 · W11 · dashboard Today (hoạt động + mục tiêu + streak) thay placeholder S0; DailyGoal/Streak VO + ComputeStreakUseCase (D-021) có test; daily_activity.allForPair + SettingsRepository (đọc mục tiêu, W12 ghi); dayKey util dùng chung với finalize(W4); EngagementNotifier keepAlive
- ca16842e · 2026-06-28 · W7 · tìm kiếm thẻ theo term + nghĩa (D-019), gồm thẻ ẩn + lọc trạng thái (D-028) có test; DAO card⨝deck⨝srs (meaning qua EXISTS); v1 LIKE (FTS/index hoãn); route /search + nút 🔍 thư viện
- b63ec88c · 2026-06-28 · W4 · 5 lối vào học (Play menu + NewLearn 5 chặng + DueReview + Review + Player + result); tích hợp SRS(W3)+game(W5)+deck subtree(W6) + daily_activity; D-001/009/010/016/017/002/007 có test; chặng game NewLearn dùng self-grade gộp (follow-up)
- 41c0f0f5 · 2026-06-28 · W5 · 4 game (Ghép đôi/Đoán/Nhớ lại/Điền) + picker; luyện thuần KHÔNG đổi SrsState (D-007); round ≤5 thẻ (D-008), sai→học lại (D-015), picker 4 game (D-013) có test; không bảng mới
- 9412f488 · 2026-06-28 · W3 · engine SRS 8 ô Leitner (scheduler + grade + due/new queue + cap D-018); D-002..D-005/D-011/D-018 có test; `srs_state` đã có ở v1 (không migration); BE-only (UI học = W4)
- 1f891c7e · 2026-06-28 · W6 · cây bộ thẻ tự lồng + library home + deck detail; tổng hợp đệ quy (words/hidden/due/mastered/%); D-023/D-024/BR-3 có test; `deck` + index đã có ở v1 (không migration); sort created/last-studied dùng proxy (id / max ngày-học cây con)
- 081ffc74 · 2026-06-28 · W2 · Card CRUD + nghĩa đa trường + editor (D-006/D-020/BR-2 có test); `card`/`card_meaning` đã có ở schema v1 (không migration); audio TTS hoãn (dep ngoài stack)
- 8d715f83 · 2026-06-28 · S0 (nền) · app shell (StatefulShellRoute + bottom nav + Drawer) + `language_pair` (Drift DAO/repo/usecases) + ngữ cảnh cặp keepAlive + l10n vi/en; Riverpod codegen hoãn (xung đột `drift_dev`)
- 36f9b503 · 2026-06-28 · W1 · base code nền: design token + theme M3 đầy đủ + responsive (MxScreenSize/breakpoints) + utils chung (Result/Clock/logger) + hạ tầng Drift (schema v1 viết SQL `.drift`)
- f63a2855 · 2026-06-28 · W6 (W7–W14 cũ→W6–W13) · pivot: bỏ Thư mục; bộ thẻ tự lồng (nested deck); xoá folder spec; renumber WBS + remap deps
- ead20623 · 2026-06-28 · W1 · scaffold foundation (error/types/router/theme/DI); align overview.md to tool/flutter_arch; W1 → Done
- adfb86aa · 2026-06-27 · W1–W14 · populate WBS; fill contract/architecture/index stubs (AI-agent readiness)
- 4879608 · 2026-06-26 · — · initial business specs + skeleton import

## Related

- `docs/business/index.md` — features being tracked
- `docs/business/system/overview.md` — implementation status
