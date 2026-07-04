import 'package:memox_v4/core/error/result.dart';
import 'package:memox_v4/domain/entities/ids.dart';
import 'package:memox_v4/domain/entities/language_pair.dart';
import 'package:memox_v4/domain/entities/reminder.dart';
import 'package:memox_v4/domain/entities/study_session.dart';
import 'package:memox_v4/domain/entities/theme_settings.dart';
import 'package:memox_v4/domain/services/audio_service.dart';
import 'package:memox_v4/domain/services/backup_restore_service.dart';
import 'package:memox_v4/domain/services/daily_activity_service.dart';
import 'package:memox_v4/domain/services/import_export_file_service.dart';
import 'package:memox_v4/domain/services/language_pair_service.dart';
import 'package:memox_v4/domain/services/reminder_notification_service.dart';
import 'package:memox_v4/domain/services/settings_service.dart';

/// In-memory [SettingsService] holding theme + game settings.
class FakeSettingsService implements SettingsService {
  ThemeSettings _theme = const ThemeSettings();
  int _gameWords = 5;
  bool _srsDueNotifications = false;

  @override
  Stream<ThemeSettings> watchTheme() => Stream.value(_theme);

  @override
  Future<Result<void>> saveTheme(ThemeSettings settings) async {
    _theme = settings;
    return const Ok<void>(null);
  }

  @override
  Stream<int> watchGameWordsPerRound() => Stream.value(_gameWords);

  @override
  Future<Result<void>> saveGameWordsPerRound(int count) async {
    _gameWords = count;
    return const Ok<void>(null);
  }

  @override
  Stream<bool> watchSrsDueNotifications() => Stream.value(_srsDueNotifications);

  @override
  Future<Result<void>> saveSrsDueNotifications(bool enabled) async {
    _srsDueNotifications = enabled;
    return const Ok<void>(null);
  }
}

/// In-memory [LanguagePairService].
class FakeLanguagePairService implements LanguagePairService {
  final List<LanguagePair> _pairs = [];
  LanguagePairId? _selected;

  @override
  Stream<List<LanguagePair>> watchAll() => Stream.value(List.unmodifiable(_pairs));

  @override
  Stream<LanguagePairId?> watchSelected() => Stream.value(_selected);

  @override
  Future<Result<void>> select(LanguagePairId id) async {
    _selected = id;
    return const Ok<void>(null);
  }

  @override
  Future<Result<LanguagePair>> add(LanguagePair pair) async {
    _pairs.add(pair);
    _selected ??= pair.id;
    return Ok(pair);
  }

  @override
  Future<Result<void>> remove(LanguagePairId id) async {
    _pairs.removeWhere((pair) => pair.id.value == id.value);
    return const Ok<void>(null);
  }
}

/// In-memory [DailyActivityService].
class FakeDailyActivityService implements DailyActivityService {
  final Map<DateTime, ({int minutes, int words})> _byDay = {};

  DateTime _day(DateTime dt) => DateTime.utc(dt.year, dt.month, dt.day);

  @override
  Future<Result<void>> record(StudySession session) async {
    final day = _day(session.startedAt);
    final current = _byDay[day] ?? (minutes: 0, words: 0);
    _byDay[day] = (
      minutes: current.minutes + session.durationMinutes,
      words: current.words + session.wordsStudied,
    );
    return const Ok<void>(null);
  }

  @override
  Future<Result<({int minutes, int words})>> activityOn(DateTime day) async =>
      Ok(_byDay[_day(day)] ?? (minutes: 0, words: 0));

  @override
  Stream<Map<DateTime, ({int minutes, int words})>> watchHistory() =>
      Stream.value(Map.unmodifiable(_byDay));
}

/// No-op [ReminderNotificationService] (grants permission, records nothing).
class FakeReminderNotificationService implements ReminderNotificationService {
  @override
  Future<Result<bool>> hasPermission() async => const Ok(true);
  @override
  Future<Result<bool>> requestPermission() async => const Ok(true);
  @override
  Future<Result<void>> schedule(Reminder reminder) async => const Ok<void>(null);
  @override
  Future<Result<void>> cancelAll() async => const Ok<void>(null);
}

/// Records the last spoken text so tests can assert TTS was invoked.
class FakeAudioService implements AudioService {
  String? lastSpoken;

  @override
  Future<Result<void>> speak(String text, {required String languageCode}) async {
    lastSpoken = text;
    return const Ok<void>(null);
  }

  @override
  Future<Result<void>> stop() async => const Ok<void>(null);
}

/// In-memory [ImportExportFileService] with a fake clipboard.
class FakeImportExportFileService implements ImportExportFileService {
  String clipboard = '';
  String? pickedFileContent;
  String? lastWritten;

  @override
  Future<Result<String?>> pickTextFile() async => Ok(pickedFileContent);

  @override
  Future<Result<void>> writeTextFile({
    required String suggestedName,
    required String content,
  }) async {
    lastWritten = content;
    return const Ok<void>(null);
  }

  @override
  Future<Result<String>> readClipboard() async => Ok(clipboard);

  @override
  Future<Result<void>> writeClipboard(String text) async {
    clipboard = text;
    return const Ok<void>(null);
  }
}

/// No-op [BackupRestoreService].
class FakeBackupRestoreService implements BackupRestoreService {
  @override
  Future<Result<String>> createBackup() async => const Ok('memory://backup.json');
  @override
  Future<Result<void>> restoreBackup(String source) async => const Ok<void>(null);
}
