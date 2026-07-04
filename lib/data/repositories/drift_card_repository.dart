import 'package:drift/drift.dart';
import 'package:memox_v4/core/error/failure.dart';
import 'package:memox_v4/core/error/result.dart';
import 'package:memox_v4/core/utils/clock.dart';
import 'package:memox_v4/data/datasources/local/app_database.dart';
import 'package:memox_v4/data/datasources/local/dao/card_dao.dart';
import 'package:memox_v4/data/models/mappers/card_mapper.dart';
import 'package:memox_v4/data/models/mappers/time_mapper.dart';
import 'package:memox_v4/domain/entities/card.dart';
import 'package:memox_v4/domain/entities/ids.dart';
import 'package:memox_v4/domain/repositories/card_repository.dart';
import 'package:memox_v4/domain/usecases/library/card_search_usecase.dart';

/// Drift-backed [CardRepository] (DT.4). A card's write spans two tables
/// (`cards` + `card_meanings`), so `save` runs in a transaction (all-or-nothing,
/// persistence-safety Policy 1). `watchByDeck` joins both tables so it re-emits
/// on either change. Deleting a card cascades its meanings/srs/logs (D-024).
class DriftCardRepository implements CardRepository {
  DriftCardRepository(this._db, this._clock);

  final AppDatabase _db;
  final Clock _clock;

  CardDao get _dao => _db.cardDao;

  @override
  Stream<List<Card>> watchByDeck(DeckId deckId) {
    final query = _db.select(_db.cards).join([
      leftOuterJoin(
          _db.cardMeanings, _db.cardMeanings.cardId.equalsExp(_db.cards.id)),
    ])
      ..where(_db.cards.deckId.equals(deckId.value))
      ..orderBy([
        OrderingTerm(expression: _db.cards.createdAt),
        OrderingTerm(expression: _db.cards.id),
        OrderingTerm(expression: _db.cardMeanings.sortIndex),
        OrderingTerm(expression: _db.cardMeanings.id),
      ]);
    return query.watch().map((rows) {
      // A map literal is insertion-ordered, so the assembled cards keep row order.
      final grouped = <String, (CardRow, List<CardMeaningRow>)>{};
      for (final row in rows) {
        final card = row.readTable(_db.cards);
        final meaning = row.readTableOrNull(_db.cardMeanings);
        final entry = grouped.putIfAbsent(card.id, () => (card, []));
        if (meaning != null) entry.$2.add(meaning);
      }
      return [for (final (card, meanings) in grouped.values) cardFromRows(card, meanings)];
    });
  }

  @override
  Future<Result<Card>> getById(CardId id) => guardAsync(() async {
        final row = await _dao.getById(id.value);
        // ignore: only_throw_errors -- reason: NotFoundFailure is MemoX's domain error type; thrown inside guardAsync which catches it and returns Err(failure) as a Result
        if (row == null) throw NotFoundFailure('No card ${id.value}');
        final meanings = await _dao.meaningsFor([id.value]);
        return cardFromRows(row, meanings);
      });

  @override
  Future<Result<Card>> save(Card card) => guardAsync(() async {
        await _db.transaction(() async {
          final existing = await _dao.getById(card.id.value);
          final createdAt =
              existing?.createdAt ?? dateTimeToMicros(_clock.now())!;
          await _db.into(_db.cards).insertOnConflictUpdate(
                CardsCompanion.insert(
                  id: card.id.value,
                  deckId: card.deckId.value,
                  term: card.term,
                  createdAt: createdAt,
                  hidden: Value(card.hidden),
                  audioRef: Value(card.audioRef),
                  grammaticalGender: Value(card.grammaticalGender),
                ),
              );
          await (_db.delete(_db.cardMeanings)
                ..where((m) => m.cardId.equals(card.id.value)))
              .go();
          for (final (index, meaning) in card.meanings.indexed) {
            await _db.into(_db.cardMeanings).insert(
                  CardMeaningsCompanion.insert(
                    id: meaning.id.value,
                    cardId: card.id.value,
                    language: meaning.language,
                    content: meaning.text,
                    sortIndex: Value(index),
                  ),
                );
          }
        });
        return card;
      });

  @override
  Future<Result<void>> delete(CardId id) => guardAsync(() async {
        await (_db.delete(_db.cards)..where((c) => c.id.equals(id.value))).go();
      });

  @override
  Future<Result<void>> setHidden(CardId id, {required bool hidden}) =>
      guardAsync(() async {
        final updated = await (_db.update(_db.cards)
              ..where((c) => c.id.equals(id.value)))
            .write(CardsCompanion(hidden: Value(hidden)));
        // ignore: only_throw_errors -- reason: NotFoundFailure is MemoX's domain error type; thrown inside guardAsync which catches it and returns Err(failure) as a Result
        if (updated == 0) throw NotFoundFailure('No card ${id.value}');
      });

  @override
  Future<Result<List<Card>>> search(String query, {DeckId? within}) =>
      guardAsync(() async {
        final tokens = CardSearchUseCase.tokenize(query);
        if (tokens.isEmpty) return const <Card>[];
        final scope = within == null
            ? null
            : await _db.deckDao.subtreeIds(within.value);
        final rows = await _dao.search(tokens, withinIds: scope);
        return _assemble(rows);
      });

  /// Batch-load meanings for [rows] and assemble entities, preserving row order.
  Future<List<Card>> _assemble(List<CardRow> rows) async {
    if (rows.isEmpty) return const [];
    final meanings = await _dao.meaningsFor([for (final r in rows) r.id]);
    final byCard = <String, List<CardMeaningRow>>{};
    for (final m in meanings) {
      (byCard[m.cardId] ??= []).add(m);
    }
    return [for (final row in rows) cardFromRows(row, byCard[row.id] ?? const [])];
  }
}
