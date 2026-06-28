import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox_v4/app/di/clock_provider.dart';
import 'package:memox_v4/app/di/database_provider.dart';
import 'package:memox_v4/core/util/clock.dart';
import 'package:memox_v4/data/datasources/local/connection/database_connection.dart';
import 'package:memox_v4/data/datasources/local/drift/app_database.dart'
    show
        AppDatabase,
        CardCompanion,
        CardMeaningCompanion,
        DeckCompanion,
        LanguagePairCompanion;
import 'package:memox_v4/domain/types/game_scope.dart';
import 'package:memox_v4/domain/types/game_type.dart';
import 'package:memox_v4/presentation/features/game/viewmodels/game_session_notifier.dart';

class _FixedClock implements Clock {
  const _FixedClock(this._ms);
  final int _ms;
  @override
  DateTime now() => DateTime.fromMillisecondsSinceEpoch(_ms);
  @override
  DateTime nowUtc() => now().toUtc();
}

void main() {
  late AppDatabase db;
  late ProviderContainer container;
  late int deckId;

  setUp(() async {
    db = AppDatabase.forTesting(openInMemoryDatabase());
    final pairId = await db
        .into(db.languagePair)
        .insert(
          LanguagePairCompanion.insert(sourceLang: 'ko', targetLang: 'vi'),
        );
    deckId = await db
        .into(db.deck)
        .insert(DeckCompanion.insert(pairId: pairId, name: 'Deck'));
    container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        clockProvider.overrideWithValue(const _FixedClock(0)),
      ],
    );
  });
  tearDown(() async {
    container.dispose();
    await db.close();
  });

  Future<int> card() async {
    final id = await db
        .into(db.card)
        .insert(CardCompanion.insert(deckId: deckId, term: 't', createdAt: 1));
    await db
        .into(db.cardMeaning)
        .insert(
          CardMeaningCompanion.insert(cardId: id, lang: 'vi', content: 'm'),
        );
    return id;
  }

  Future<GameSessionState> open(GameRequest request) {
    container.listen(gameSessionProvider(request), (_, _) {});
    return container.read(gameSessionProvider(request).future);
  }

  test('D-008: a round uses at most game_words_per_round cards', () async {
    for (var i = 0; i < 8; i++) {
      await card();
    }
    final state = await open(
      GameRequest(
        nodeId: deckId,
        type: GameType.recall,
        scope: GameScope.all,
        random: false,
      ),
    );
    expect(state.cards, hasLength(5));
  });

  test(
    'D-015: a wrong answer re-queues; the round ends when all are correct',
    () async {
      final c1 = await card();
      final c2 = await card();
      final request = GameRequest(
        nodeId: deckId,
        type: GameType.recall,
        scope: GameScope.all,
        random: false,
        wordsPerRound: 2,
      );
      await open(request);
      final notifier = container.read(gameSessionProvider(request).notifier);

      notifier.markWrong(c1);
      expect(
        container.read(gameSessionProvider(request)).value!.isComplete,
        isFalse,
      );

      notifier.markCorrect(c2);
      notifier.markCorrect(c1);
      expect(
        container.read(gameSessionProvider(request)).value!.isComplete,
        isTrue,
      );
    },
  );

  test('D-007: finishing a game leaves srs_state untouched', () async {
    final c1 = await card();
    final request = GameRequest(
      nodeId: deckId,
      type: GameType.recall,
      scope: GameScope.all,
      random: false,
    );
    await open(request);
    container.read(gameSessionProvider(request).notifier).markCorrect(c1);

    expect(
      container.read(gameSessionProvider(request)).value!.isComplete,
      isTrue,
    );
    expect(await db.select(db.srsState).get(), isEmpty);
  });
}
