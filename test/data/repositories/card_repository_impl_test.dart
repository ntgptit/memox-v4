import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:memox_v4/core/util/clock.dart';
import 'package:memox_v4/data/datasources/local/connection/database_connection.dart';
import 'package:memox_v4/data/datasources/local/daos/card_dao.dart';
import 'package:memox_v4/data/datasources/local/drift/app_database.dart'
    show AppDatabase, DeckCompanion, LanguagePairCompanion, SrsStateCompanion;
import 'package:memox_v4/data/repositories/card_repository_impl.dart';
import 'package:memox_v4/domain/entities/card_meaning.dart';
import 'package:memox_v4/domain/models/card_draft.dart';
import 'package:memox_v4/domain/types/result.dart';

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
  late CardRepositoryImpl repository;
  late int deckId;

  setUp(() async {
    db = AppDatabase.forTesting(openInMemoryDatabase());
    repository = CardRepositoryImpl(CardDao(db), const _FixedClock(1000));
    final pairId = await db
        .into(db.languagePair)
        .insert(
          LanguagePairCompanion.insert(sourceLang: 'ko', targetLang: 'vi'),
        );
    deckId = await db
        .into(db.deck)
        .insert(DeckCompanion.insert(pairId: pairId, name: 'Deck'));
  });
  tearDown(() => db.close());

  CardDraft draft(
    String term, {
    bool hidden = false,
    List<CardMeaning>? meanings,
  }) => CardDraft(
    deckId: deckId,
    term: term,
    hidden: hidden,
    meanings:
        meanings ??
        const <CardMeaning>[CardMeaning(lang: 'vi', content: 'nghĩa')],
  );

  test('create persists the card, its meaning, and clock createdAt', () async {
    final card = (await repository.create(draft('안녕'))).valueOrNull!;
    expect(card.term, '안녕');
    expect(card.createdAt, 1000);
    expect(card.orderIndex, 0);
    expect(card.meanings, hasLength(1));
    expect(card.meanings.first.content, 'nghĩa');
  });

  test(
    'D-006: hidden cards drop out of visibleCount and filtered lists',
    () async {
      await repository.create(draft('a'));
      final b = (await repository.create(draft('b'))).valueOrNull!;
      await repository.setHidden(b.id, hidden: true);

      expect((await repository.visibleCount(deckId)).valueOrNull, 1);
      expect(
        (await repository.listByDeck(deckId, includeHidden: false)).valueOrNull,
        hasLength(1),
      );
      expect((await repository.listByDeck(deckId)).valueOrNull, hasLength(2));
    },
  );

  test(
    'D-020: duplicate term is detected (case-insensitive) but not blocked',
    () async {
      await repository.create(draft('mesa'));
      expect((await repository.termExists(deckId, 'MESA')).valueOrNull, isTrue);

      final dup = await repository.create(draft('mesa'));
      expect(dup.valueOrNull, isNotNull);
      expect((await repository.listByDeck(deckId)).valueOrNull, hasLength(2));
    },
  );

  test('delete cascades to meanings and srs_state', () async {
    final card = (await repository.create(draft('x'))).valueOrNull!;
    await db
        .into(db.srsState)
        .insert(SrsStateCompanion.insert(cardId: Value(card.id)));

    await repository.delete(card.id);

    expect((await repository.listByDeck(deckId)).valueOrNull, isEmpty);
    expect(await db.select(db.cardMeaning).get(), isEmpty);
    expect(await db.select(db.srsState).get(), isEmpty);
  });

  test('update replaces fields and the meaning set', () async {
    final card = (await repository.create(
      draft(
        'old',
        meanings: const <CardMeaning>[CardMeaning(lang: 'vi', content: 'cũ')],
      ),
    )).valueOrNull!;

    final updated = (await repository.update(
      card.id,
      CardDraft(
        deckId: deckId,
        term: 'new',
        meanings: const <CardMeaning>[
          CardMeaning(lang: 'vi', content: 'mới'),
          CardMeaning(lang: 'en', content: 'new-en'),
        ],
      ),
    )).valueOrNull!;

    expect(updated.term, 'new');
    expect(updated.meanings, hasLength(2));
    expect(updated.meanings.first.content, 'mới');
  });
}
