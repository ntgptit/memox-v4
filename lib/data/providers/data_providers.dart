import 'package:memox_v4/core/utils/clock.dart';
import 'package:memox_v4/data/providers/database_provider.dart';
import 'package:memox_v4/data/repositories/drift_card_repository.dart';
import 'package:memox_v4/data/repositories/drift_deck_repository.dart';
import 'package:memox_v4/data/repositories/drift_review_repository.dart';
import 'package:memox_v4/data/repositories/drift_settings_repository.dart';
import 'package:memox_v4/domain/repositories/card_repository.dart';
import 'package:memox_v4/domain/repositories/deck_repository.dart';
import 'package:memox_v4/domain/repositories/review_repository.dart';
import 'package:memox_v4/domain/repositories/settings_repository.dart';
import 'package:memox_v4/domain/services/audio_service.dart';
import 'package:memox_v4/domain/services/backup_restore_service.dart';
import 'package:memox_v4/domain/services/daily_activity_service.dart';
import 'package:memox_v4/domain/services/import_export_file_service.dart';
import 'package:memox_v4/domain/services/language_pair_service.dart';
import 'package:memox_v4/domain/services/reminder_notification_service.dart';
import 'package:memox_v4/domain/services/settings_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'data_providers.g.dart';

/// The dependency-injection seam between features and the data layer. Screens
/// depend only on these providers, so swapping fakes → Drift never touches a
/// screen. The **repositories** are wired to their Drift-backed implementations
/// over [appDatabaseProvider] (DT.5); tests override them with the in-memory
/// fakes (DM.9 harness). The **device/plugin services** still have no default —
/// they land with the DT.7 adapters and stay override-only until then.
const _mustOverride =
    'This service must be overridden — fakes in tests (DM.9), device adapters in the app (DT.7).';

/// The app clock. Defaults to the real wall clock; tests override with a
/// [FakeClock] for deterministic time.
@riverpod
Clock clock(Ref ref) => const SystemClock();

@riverpod
DeckRepository deckRepository(Ref ref) => DriftDeckRepository(
      ref.watch(appDatabaseProvider),
      ref.watch(clockProvider),
    );

@riverpod
CardRepository cardRepository(Ref ref) => DriftCardRepository(
      ref.watch(appDatabaseProvider),
      ref.watch(clockProvider),
    );

@riverpod
ReviewRepository reviewRepository(Ref ref) => DriftReviewRepository(
      ref.watch(appDatabaseProvider),
      ref.watch(clockProvider),
    );

@riverpod
SettingsRepository settingsRepository(Ref ref) =>
    DriftSettingsRepository(ref.watch(appDatabaseProvider));

@riverpod
SettingsService settingsService(Ref ref) => throw UnimplementedError(_mustOverride);

@riverpod
LanguagePairService languagePairService(Ref ref) =>
    throw UnimplementedError(_mustOverride);

@riverpod
DailyActivityService dailyActivityService(Ref ref) =>
    throw UnimplementedError(_mustOverride);

@riverpod
ReminderNotificationService reminderNotificationService(Ref ref) =>
    throw UnimplementedError(_mustOverride);

@riverpod
AudioService audioService(Ref ref) => throw UnimplementedError(_mustOverride);

@riverpod
ImportExportFileService importExportFileService(Ref ref) =>
    throw UnimplementedError(_mustOverride);

@riverpod
BackupRestoreService backupRestoreService(Ref ref) =>
    throw UnimplementedError(_mustOverride);
