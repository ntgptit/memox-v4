import 'package:memox_v4/core/utils/clock.dart';
import 'package:memox_v4/data/providers/database_provider.dart';
import 'package:memox_v4/data/repositories/drift_card_repository.dart';
import 'package:memox_v4/data/repositories/drift_deck_repository.dart';
import 'package:memox_v4/data/repositories/drift_review_repository.dart';
import 'package:memox_v4/data/repositories/drift_settings_repository.dart';
import 'package:memox_v4/data/services/device_services.dart';
import 'package:memox_v4/data/services/drift_daily_activity_service.dart';
import 'package:memox_v4/data/services/drift_language_pair_service.dart';
import 'package:memox_v4/data/services/drift_recent_search_service.dart';
import 'package:memox_v4/data/services/drift_settings_service.dart';
import 'package:memox_v4/domain/repositories/card_repository.dart';
import 'package:memox_v4/domain/repositories/deck_repository.dart';
import 'package:memox_v4/domain/repositories/review_repository.dart';
import 'package:memox_v4/domain/repositories/settings_repository.dart';
import 'package:memox_v4/domain/services/audio_service.dart';
import 'package:memox_v4/domain/services/backup_restore_service.dart';
import 'package:memox_v4/domain/services/daily_activity_service.dart';
import 'package:memox_v4/domain/services/import_export_file_service.dart';
import 'package:memox_v4/domain/services/language_pair_service.dart';
import 'package:memox_v4/domain/services/recent_search_service.dart';
import 'package:memox_v4/domain/services/reminder_notification_service.dart';
import 'package:memox_v4/domain/services/settings_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'data_providers.g.dart';

/// The dependency-injection seam between features and the data layer. Screens
/// depend only on these providers, so swapping fakes → Drift never touches a
/// screen. The **repositories** (DT.5) and **services** (DT.7) are wired to their
/// Drift-backed / device-adapter implementations over [appDatabaseProvider];
/// tests override them with the in-memory fakes (DM.9 harness).

/// The app clock. Defaults to the real wall clock; tests override with a
/// [FakeClock] for deterministic time.
@riverpod
Clock clock(Ref ref) => const SystemClock();

@Riverpod(keepAlive: true)
DeckRepository deckRepository(Ref ref) => DriftDeckRepository(
  ref.watch(appDatabaseProvider),
  ref.watch(clockProvider),
);

@Riverpod(keepAlive: true)
CardRepository cardRepository(Ref ref) => DriftCardRepository(
  ref.watch(appDatabaseProvider),
  ref.watch(clockProvider),
);

@Riverpod(keepAlive: true)
ReviewRepository reviewRepository(Ref ref) => DriftReviewRepository(
  ref.watch(appDatabaseProvider),
  ref.watch(clockProvider),
);

@Riverpod(keepAlive: true)
SettingsRepository settingsRepository(Ref ref) =>
    DriftSettingsRepository(ref.watch(appDatabaseProvider));

@Riverpod(keepAlive: true)
SettingsService settingsService(Ref ref) =>
    DriftSettingsService(ref.watch(appDatabaseProvider));

@Riverpod(keepAlive: true)
RecentSearchService recentSearchService(Ref ref) =>
    DriftRecentSearchService(ref.watch(appDatabaseProvider));

@Riverpod(keepAlive: true)
LanguagePairService languagePairService(Ref ref) => DriftLanguagePairService(
  ref.watch(appDatabaseProvider),
  ref.watch(clockProvider),
);

@Riverpod(keepAlive: true)
DailyActivityService dailyActivityService(Ref ref) =>
    DriftDailyActivityService(ref.watch(appDatabaseProvider));

// The device-plugin services below are DT.7 adapters. TTS, notifications, the
// file picker/share sheet, and local backup have no plugin in this build, so
// their adapters are documented no-op/deferred (clipboard is real) — the seam is
// satisfied and a real plugin adapter drops in without touching a screen.
@Riverpod(keepAlive: true)
ReminderNotificationService reminderNotificationService(Ref ref) =>
    const NoopReminderNotificationService();

@Riverpod(keepAlive: true)
AudioService audioService(Ref ref) => const NoopAudioService();

@Riverpod(keepAlive: true)
ImportExportFileService importExportFileService(Ref ref) =>
    const ClipboardImportExportFileService();

@Riverpod(keepAlive: true)
BackupRestoreService backupRestoreService(Ref ref) =>
    const DeferredBackupRestoreService();
