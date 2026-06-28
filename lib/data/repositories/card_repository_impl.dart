import 'package:memox_v4/core/error/failure.dart';
import 'package:memox_v4/core/util/clock.dart';
import 'package:memox_v4/data/datasources/local/daos/card_dao.dart';
import 'package:memox_v4/data/datasources/local/drift/app_database.dart'
    show CardData, CardMeaningData;
import 'package:memox_v4/data/mappers/card_mapper.dart';
import 'package:memox_v4/domain/entities/card.dart';
import 'package:memox_v4/domain/models/card_draft.dart';
import 'package:memox_v4/domain/repositories/card_repository.dart';
import 'package:memox_v4/domain/types/result.dart';

/// Drift-backed [CardRepository]. Maps storage errors to [PersistenceFailure] at
/// this boundary (`docs/contracts/error-contract.md`).
class CardRepositoryImpl implements CardRepository {
  const CardRepositoryImpl(this._dao, this._clock);

  final CardDao _dao;
  final Clock _clock;

  @override
  Future<Result<List<Card>>> listByDeck(
    int deckId, {
    bool includeHidden = true,
  }) async {
    try {
      final cards = await _dao.cardsByDeck(
        deckId,
        includeHidden: includeHidden,
      );
      if (cards.isEmpty) return const Ok(<Card>[]);
      final meanings = await _dao.meaningsForCards(
        cards.map((c) => c.id).toList(growable: false),
      );
      final byCard = <int, List<CardMeaningData>>{};
      for (final m in meanings) {
        (byCard[m.cardId] ??= <CardMeaningData>[]).add(m);
      }
      return Ok(
        cards
            .map((c) => mapCard(c, byCard[c.id] ?? const <CardMeaningData>[]))
            .toList(growable: false),
      );
    } catch (e) {
      return Err(PersistenceFailure(message: 'list cards', cause: e));
    }
  }

  @override
  Future<Result<Card?>> getById(int id) async {
    try {
      final card = await _dao.cardById(id);
      if (card == null) return const Ok(null);
      final meanings = await _dao.meaningsForCard(id);
      return Ok(mapCard(card, meanings));
    } catch (e) {
      return Err(PersistenceFailure(message: 'get card', cause: e));
    }
  }

  @override
  Future<Result<List<Card>>> listByIds(
    List<int> ids, {
    bool includeHidden = true,
  }) async {
    try {
      if (ids.isEmpty) return const Ok(<Card>[]);
      final cards = await _dao.cardsByIds(ids, includeHidden: includeHidden);
      if (cards.isEmpty) return const Ok(<Card>[]);
      final meanings = await _dao.meaningsForCards(
        cards.map((c) => c.id).toList(growable: false),
      );
      final byCard = <int, List<CardMeaningData>>{};
      for (final m in meanings) {
        (byCard[m.cardId] ??= <CardMeaningData>[]).add(m);
      }
      final byId = <int, CardData>{for (final c in cards) c.id: c};
      return Ok(<Card>[
        for (final id in ids)
          if (byId[id] case final card?)
            mapCard(card, byCard[id] ?? const <CardMeaningData>[]),
      ]);
    } catch (e) {
      return Err(PersistenceFailure(message: 'list cards by ids', cause: e));
    }
  }

  @override
  Future<Result<Card>> create(CardDraft draft) async {
    try {
      final orderIndex = await _dao.cardCount(draft.deckId);
      final id = await _dao.createWithMeanings(
        deckId: draft.deckId,
        term: draft.term,
        gender: draft.gender,
        audioRef: draft.audioRef,
        hidden: draft.hidden,
        orderIndex: orderIndex,
        createdAt: _clock.now().millisecondsSinceEpoch,
        meanings: _meaningInputs(draft),
      );
      return _loadOk(id);
    } catch (e) {
      return Err(PersistenceFailure(message: 'create card', cause: e));
    }
  }

  @override
  Future<Result<Card>> update(int id, CardDraft draft) async {
    try {
      await _dao.updateWithMeanings(
        id: id,
        term: draft.term,
        gender: draft.gender,
        audioRef: draft.audioRef,
        hidden: draft.hidden,
        meanings: _meaningInputs(draft),
      );
      return _loadOk(id);
    } catch (e) {
      return Err(PersistenceFailure(message: 'update card', cause: e));
    }
  }

  @override
  Future<Result<void>> delete(int id) async {
    try {
      await _dao.deleteCard(id);
      return const Ok<void>(null);
    } catch (e) {
      return Err(PersistenceFailure(message: 'delete card', cause: e));
    }
  }

  @override
  Future<Result<void>> setHidden(int id, {required bool hidden}) async {
    try {
      await _dao.setHidden(id, hidden);
      return const Ok<void>(null);
    } catch (e) {
      return Err(PersistenceFailure(message: 'set hidden', cause: e));
    }
  }

  @override
  Future<Result<bool>> termExists(
    int deckId,
    String term, {
    int? excludingCardId,
  }) async {
    try {
      return Ok(
        await _dao.termExists(deckId, term, excludingCardId: excludingCardId),
      );
    } catch (e) {
      return Err(PersistenceFailure(message: 'term exists', cause: e));
    }
  }

  @override
  Future<Result<int>> visibleCount(int deckId) async {
    try {
      return Ok(await _dao.visibleCount(deckId));
    } catch (e) {
      return Err(PersistenceFailure(message: 'visible count', cause: e));
    }
  }

  Future<Result<Card>> _loadOk(int id) async {
    final card = await _dao.cardById(id);
    if (card == null) {
      return const Err(NotFoundFailure(message: 'card not found after write'));
    }
    final meanings = await _dao.meaningsForCard(id);
    return Ok(mapCard(card, meanings));
  }

  List<MeaningInput> _meaningInputs(CardDraft draft) => draft.meanings
      .map((m) => (lang: m.lang, content: m.content))
      .toList(growable: false);
}
