import 'package:memox_v4/core/utils/clock.dart';
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

/// The dependency-injection seam between features and the data layer. Repositories
/// and services are exposed as providers that must be **overridden** — with the
/// in-memory fakes in tests (DM.9 harness) and with the Drift-backed
/// implementations in the running app (DT.5). Screens depend only on these
/// providers, so swapping fakes → Drift never touches a screen.
const _mustOverride =
    'This provider must be overridden — fakes in tests (DM.9), Drift in the app (DT.5).';

/// The app clock. Defaults to the real wall clock; tests override with a
/// [FakeClock] for deterministic time.
@riverpod
Clock clock(Ref ref) => const SystemClock();

@riverpod
DeckRepository deckRepository(Ref ref) => throw UnimplementedError(_mustOverride);

@riverpod
CardRepository cardRepository(Ref ref) => throw UnimplementedError(_mustOverride);

@riverpod
ReviewRepository reviewRepository(Ref ref) =>
    throw UnimplementedError(_mustOverride);

@riverpod
SettingsRepository settingsRepository(Ref ref) =>
    throw UnimplementedError(_mustOverride);

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
