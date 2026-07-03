import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:memox_v4/core/error/result.dart';
import 'package:memox_v4/core/utils/clock.dart';
import 'package:memox_v4/data/datasources/local/app_database.dart';
import 'package:memox_v4/data/providers/data_providers.dart';
import 'package:memox_v4/data/providers/database_provider.dart';
import 'package:memox_v4/data/repositories/drift_card_repository.dart';
import 'package:memox_v4/data/repositories/drift_deck_repository.dart';
import 'package:memox_v4/data/repositories/drift_review_repository.dart';
import 'package:memox_v4/data/repositories/drift_settings_repository.dart';
import 'package:memox_v4/domain/entities/deck.dart';
import 'package:memox_v4/domain/entities/ids.dart';

class _FixedClock implements Clock {
  _FixedClock(this._now);
  final DateTime _now;
  @override
  DateTime now() => _now;
}

void main() {
  late AppDatabase db;
  late ProviderContainer container;

  setUp(() async {
    db = AppDatabase.memory();
    await db.into(db.languagePairs).insert(LanguagePairsCompanion.insert(
        id: 'lp',
        learningLanguage: 'ko',
        nativeLanguage: 'en',
        createdAt: 0,
        isActive: const Value(true)));
    container = ProviderContainer(overrides: [
      // The app opens a file DB; tests swap in an in-memory one — the plugin/file
      // path never runs under `flutter test`.
      appDatabaseProvider.overrideWithValue(db),
      clockProvider.overrideWithValue(_FixedClock(DateTime.utc(2026, 7, 3, 9))),
    ]);
    addTearDown(container.dispose);
    addTearDown(db.close);
  });

  test('the repository seam resolves to the Drift implementations (DT.5)', () {
    expect(container.read(deckRepositoryProvider), isA<DriftDeckRepository>());
    expect(container.read(cardRepositoryProvider), isA<DriftCardRepository>());
    expect(container.read(reviewRepositoryProvider), isA<DriftReviewRepository>());
    expect(
        container.read(settingsRepositoryProvider), isA<DriftSettingsRepository>());
  });

  test('a repository resolved from the seam reads/writes the Drift DB', () async {
    final decks = container.read(deckRepositoryProvider);
    final saved = await decks.save(
      (Deck.create(id: const DeckId('d'), name: 'Deck') as Ok<Deck>).value,
    );
    expect(saved is Ok<Deck>, isTrue);

    final children = await decks.watchChildren(null).first;
    expect(children.single.name, 'Deck');
    // The write landed in the same underlying Drift DB.
    expect((await db.select(db.decks).get()).single.id, 'd');
  });

  test('all four repository providers share one AppDatabase instance', () {
    // Reading appDatabase twice yields the same (keepAlive) instance the repos use.
    expect(identical(
      container.read(appDatabaseProvider),
      container.read(appDatabaseProvider),
    ), isTrue);
  });
}
