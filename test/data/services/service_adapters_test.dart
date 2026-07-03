import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:memox_v4/core/error/result.dart';
import 'package:memox_v4/core/utils/clock.dart';
import 'package:memox_v4/data/datasources/local/app_database.dart';
import 'package:memox_v4/data/services/device_services.dart';
import 'package:memox_v4/data/services/drift_daily_activity_service.dart';
import 'package:memox_v4/data/services/drift_language_pair_service.dart';
import 'package:memox_v4/data/services/drift_settings_service.dart';
import 'package:memox_v4/domain/entities/ids.dart';
import 'package:memox_v4/domain/entities/language_pair.dart';
import 'package:memox_v4/domain/entities/study_mode.dart';
import 'package:memox_v4/domain/entities/study_session.dart';
import 'package:memox_v4/domain/entities/theme_settings.dart';

class _FixedClock implements Clock {
  _FixedClock(this._now);
  final DateTime _now;
  @override
  DateTime now() => _now;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  final clock = _FixedClock(DateTime.utc(2026, 7, 3, 9));

  setUp(() => db = AppDatabase.memory());
  tearDown(() => db.close());

  T ok<T>(Result<T> r) => (r as Ok<T>).value;

  group('DriftSettingsService', () {
    test('theme round-trips (defaults, then persisted)', () async {
      final svc = DriftSettingsService(db);
      final def = await svc.watchTheme().first;
      expect(def.mode, ColorMode.system);
      expect(def.accent, AccentColor.brand);

      ok(await svc.saveTheme(const ThemeSettings(
          mode: ColorMode.dark,
          accent: AccentColor.warm,
          fontScale: FontScale.large)));
      final saved = await svc.watchTheme().first;
      expect(saved.mode, ColorMode.dark);
      expect(saved.accent, AccentColor.warm);
      expect(saved.fontScale, FontScale.large);
    });

    test('game words-per-round defaults to 5 then persists (D-008)', () async {
      final svc = DriftSettingsService(db);
      expect(await svc.watchGameWordsPerRound().first, 5);
      ok(await svc.saveGameWordsPerRound(8));
      expect(await svc.watchGameWordsPerRound().first, 8);
    });
  });

  group('DriftLanguagePairService', () {
    LanguagePair pair(String id, String learn, String native) =>
        (LanguagePair.create(
          id: LanguagePairId(id),
          learningLanguage: learn,
          nativeLanguage: native,
        ) as Ok<LanguagePair>)
            .value;

    test('add, select, watchSelected, watchAll', () async {
      final svc = DriftLanguagePairService(db, clock);
      ok(await svc.add(pair('a', 'ko', 'vi')));
      ok(await svc.add(pair('b', 'en', 'vi')));
      expect((await svc.watchAll().first).map((p) => p.id.value),
          containsAll(['a', 'b']));

      expect(await svc.watchSelected().first, isNull);
      ok(await svc.select(const LanguagePairId('b')));
      expect((await svc.watchSelected().first)?.value, 'b');

      // Selecting another flips activity (only one active).
      ok(await svc.select(const LanguagePairId('a')));
      expect((await svc.watchSelected().first)?.value, 'a');
    });

    test('remove drops the pair', () async {
      final svc = DriftLanguagePairService(db, clock);
      ok(await svc.add(pair('a', 'ko', 'vi')));
      ok(await svc.remove(const LanguagePairId('a')));
      expect(await svc.watchAll().first, isEmpty);
    });
  });

  group('DriftDailyActivityService', () {
    StudySession session(String id, int minutes, int words) => StudySession(
          id: StudySessionId(id),
          deckId: const DeckId('d'),
          mode: StudyMode.newLearn,
          startedAt: DateTime.utc(2026, 7, 3, 9),
          durationMinutes: minutes,
          wordsStudied: words,
        );

    test('record folds sessions into the day roll-up (D-010)', () async {
      // A session references a deck (FK), so seed the deck + its pair first.
      await db.into(db.languagePairs).insert(LanguagePairsCompanion.insert(
          id: 'lp', learningLanguage: 'ko', nativeLanguage: 'vi', createdAt: 0));
      await db.into(db.decks).insert(DecksCompanion.insert(
          id: 'd', name: 'Deck', languagePairId: 'lp', createdAt: 0));

      final svc = DriftDailyActivityService(db);
      ok(await svc.record(session('s1', 6, 3)));
      ok(await svc.record(session('s2', 4, 2)));

      final today = await svc.activityOn(DateTime.utc(2026, 7, 3, 20));
      expect(ok(today), (minutes: 10, words: 5));

      final history = await svc.watchHistory().first;
      expect(history.values.single, (minutes: 10, words: 5));
    });
  });

  group('device adapters (deferred/no-op)', () {
    test('audio speak/stop succeed as no-ops', () async {
      const audio = NoopAudioService();
      expect(await audio.speak('학교', languageCode: 'ko') is Ok, isTrue);
      expect(await audio.stop() is Ok, isTrue);
    });

    test('reminders report no permission and no-op schedule', () async {
      const svc = NoopReminderNotificationService();
      expect(ok(await svc.hasPermission()), isFalse);
      expect(ok(await svc.requestPermission()), isFalse);
    });

    test('clipboard round-trips; file export is unavailable', () async {
      final clip = <String, Object?>{};
      TestWidgetsFlutterBinding.ensureInitialized()
          .defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, (call) async {
        if (call.method == 'Clipboard.setData') {
          clip['text'] = (call.arguments as Map)['text'];
        }
        if (call.method == 'Clipboard.getData') {
          return {'text': clip['text']};
        }
        return null;
      });
      addTearDown(() => TestWidgetsFlutterBinding.ensureInitialized()
          .defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null));

      const svc = ClipboardImportExportFileService();
      ok(await svc.writeClipboard('hello'));
      expect(ok(await svc.readClipboard()), 'hello');
      expect(ok(await svc.pickTextFile()), isNull);
      expect(
          await svc.writeTextFile(suggestedName: 'x.csv', content: 'a') is Err,
          isTrue);
    });

    test('backup/restore report unavailable (D-027 deferred)', () async {
      const svc = DeferredBackupRestoreService();
      expect(await svc.createBackup() is Err, isTrue);
      expect(await svc.restoreBackup('src') is Err, isTrue);
    });
  });
}
