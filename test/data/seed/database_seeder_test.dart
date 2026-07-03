import 'package:flutter_test/flutter_test.dart';

import 'package:memox_v4/core/utils/clock.dart';
import 'package:memox_v4/data/datasources/local/app_database.dart';
import 'package:memox_v4/data/seed/database_seeder.dart';

class _FixedClock implements Clock {
  _FixedClock(this._now);
  final DateTime _now;
  @override
  DateTime now() => _now;
}

void main() {
  late AppDatabase db;
  late DatabaseSeeder seeder;
  final clock = _FixedClock(DateTime.utc(2026, 7, 3, 9));

  setUp(() {
    db = AppDatabase.memory();
    seeder = DatabaseSeeder(db, clock);
  });
  tearDown(() => db.close());

  group('ensureFirstRun', () {
    test('creates the active pair + defaults and leaves a clean empty state',
        () async {
      await seeder.ensureFirstRun();

      final pair = (await db.select(db.languagePairs).get()).single;
      expect(pair.isActive, isTrue);
      expect(pair.learningLanguage, 'ko');
      expect(pair.nativeLanguage, 'vi');

      // A clean first run has no decks or cards.
      expect(await db.select(db.decks).get(), isEmpty);
      expect(await db.select(db.cards).get(), isEmpty);

      // Default preferences are seeded.
      final settings = {
        for (final row in await db.select(db.settings).get()) row.key: row.value,
      };
      expect(settings['srs.new_cards_per_day'], '20');
      expect(settings['goal.minutes_target'], '15');
      expect(settings['goal.words_target'], '20');
    });

    test('is idempotent — a second run adds no duplicate pair', () async {
      await seeder.ensureFirstRun();
      await seeder.ensureFirstRun();
      expect((await db.select(db.languagePairs).get()).length, 1);
    });
  });

  group('seedSampleData', () {
    test('seeds the dev deck tree with cards + a mix of SRS positions', () async {
      await seeder.seedSampleData();

      final decks = await db.select(db.decks).get();
      expect(decks.map((d) => d.name), containsAll(['Korean Basics', 'Food']));

      final cards = await db.select(db.cards).get();
      expect(cards.length, 3);

      final srs = {
        for (final row in await db.select(db.srsStates).get()) row.cardId: row,
      };
      // card-1 due (dueAt before "now"); card-2 scheduled ahead; card-3 new (no row).
      final now = clock.now().microsecondsSinceEpoch;
      expect(srs['seed-card-1']!.dueAt! < now, isTrue);
      expect(srs['seed-card-2']!.dueAt! > now, isTrue);
      expect(srs.containsKey('seed-card-3'), isFalse);
    });

    test('is idempotent — a second run adds no duplicate decks', () async {
      await seeder.seedSampleData();
      await seeder.seedSampleData();
      expect((await db.select(db.decks).get()).length, 2);
    });

    test('ensures the first-run pair before seeding decks', () async {
      await seeder.seedSampleData();
      expect((await db.select(db.languagePairs).get()).length, 1);
    });
  });
}
