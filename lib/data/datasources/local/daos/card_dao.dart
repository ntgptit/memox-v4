import 'package:drift/drift.dart';
import 'package:memox_v4/data/datasources/local/drift/app_database.dart';

/// A meaning to persist with a card (language + free text).
typedef MeaningInput = ({String lang, String content});

/// Typed access to the `card` + `card_meaning` tables. Returns Drift rows;
/// mapping to domain entities is the repository's job. Card create/update run in
/// a transaction so a card and its meanings persist atomically.
class CardDao {
  const CardDao(this._db);

  final AppDatabase _db;

  Future<List<CardData>> cardsByDeck(int deckId, {bool includeHidden = true}) {
    final query = _db.select(_db.card)
      ..where((t) => t.deckId.equals(deckId))
      ..orderBy(<OrderClauseGenerator<Card>>[
        (t) => OrderingTerm(expression: t.orderIndex),
      ]);
    if (!includeHidden) {
      query.where((t) => t.hidden.equals(false));
    }
    return query.get();
  }

  Future<CardData?> cardById(int id) =>
      (_db.select(_db.card)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<List<CardMeaningData>> meaningsForCard(int cardId) => (_db.select(
    _db.cardMeaning,
  )..where((t) => t.cardId.equals(cardId))).get();

  Future<List<CardMeaningData>> meaningsForCards(List<int> cardIds) {
    if (cardIds.isEmpty) return Future.value(const <CardMeaningData>[]);
    return (_db.select(
      _db.cardMeaning,
    )..where((t) => t.cardId.isIn(cardIds))).get();
  }

  /// Number of cards in a deck (including hidden) — the next `order_index`.
  Future<int> cardCount(int deckId) async {
    final count = _db.card.id.count();
    final query = _db.selectOnly(_db.card)
      ..addColumns(<Expression<Object>>[count])
      ..where(_db.card.deckId.equals(deckId));
    final row = await query.getSingle();
    return row.read(count) ?? 0;
  }

  /// Number of non-hidden cards in a deck (D-006).
  Future<int> visibleCount(int deckId) async {
    final count = _db.card.id.count();
    final query = _db.selectOnly(_db.card)
      ..addColumns(<Expression<Object>>[count])
      ..where(_db.card.deckId.equals(deckId) & _db.card.hidden.equals(false));
    final row = await query.getSingle();
    return row.read(count) ?? 0;
  }

  /// Whether [term] (case-insensitive) already exists in the deck, optionally
  /// ignoring one card (the one being edited).
  Future<bool> termExists(
    int deckId,
    String term, {
    int? excludingCardId,
  }) async {
    final count = _db.card.id.count();
    var predicate =
        _db.card.deckId.equals(deckId) &
        _db.card.term.lower().equals(term.toLowerCase());
    if (excludingCardId != null) {
      predicate = predicate & _db.card.id.equals(excludingCardId).not();
    }
    final query = _db.selectOnly(_db.card)
      ..addColumns(<Expression<Object>>[count])
      ..where(predicate);
    final row = await query.getSingle();
    return (row.read(count) ?? 0) > 0;
  }

  Future<int> createWithMeanings({
    required int deckId,
    required String term,
    required String? gender,
    required String? audioRef,
    required bool hidden,
    required int orderIndex,
    required int createdAt,
    required List<MeaningInput> meanings,
  }) => _db.transaction(() async {
    final cardId = await _db
        .into(_db.card)
        .insert(
          CardCompanion.insert(
            deckId: deckId,
            term: term,
            createdAt: createdAt,
            gender: Value(gender),
            audioRef: Value(audioRef),
            hidden: Value(hidden),
            orderIndex: Value(orderIndex),
          ),
        );
    await _insertMeanings(cardId, meanings);
    return cardId;
  });

  Future<void> updateWithMeanings({
    required int id,
    required String term,
    required String? gender,
    required String? audioRef,
    required bool hidden,
    required List<MeaningInput> meanings,
  }) => _db.transaction(() async {
    await (_db.update(_db.card)..where((t) => t.id.equals(id))).write(
      CardCompanion(
        term: Value(term),
        gender: Value(gender),
        audioRef: Value(audioRef),
        hidden: Value(hidden),
      ),
    );
    await (_db.delete(_db.cardMeaning)..where((t) => t.cardId.equals(id))).go();
    await _insertMeanings(id, meanings);
  });

  Future<void> deleteCard(int id) =>
      (_db.delete(_db.card)..where((t) => t.id.equals(id))).go();

  Future<void> setHidden(int id, bool hidden) => (_db.update(
    _db.card,
  )..where((t) => t.id.equals(id))).write(CardCompanion(hidden: Value(hidden)));

  Future<void> _insertMeanings(int cardId, List<MeaningInput> meanings) async {
    for (final meaning in meanings) {
      await _db
          .into(_db.cardMeaning)
          .insert(
            CardMeaningCompanion.insert(
              cardId: cardId,
              lang: meaning.lang,
              content: meaning.content,
            ),
          );
    }
  }
}
