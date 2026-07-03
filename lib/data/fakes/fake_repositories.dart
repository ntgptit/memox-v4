import 'package:memox_v4/core/error/failure.dart';
import 'package:memox_v4/core/error/result.dart';
import 'package:memox_v4/data/fakes/fake_store.dart';
import 'package:memox_v4/domain/entities/box_level.dart';
import 'package:memox_v4/domain/entities/card.dart';
import 'package:memox_v4/domain/entities/daily_goal.dart';
import 'package:memox_v4/domain/entities/deck.dart';
import 'package:memox_v4/domain/entities/deck_stats.dart';
import 'package:memox_v4/domain/entities/ids.dart';
import 'package:memox_v4/domain/entities/review_log.dart';
import 'package:memox_v4/domain/entities/srs_state.dart';
import 'package:memox_v4/domain/repositories/card_repository.dart';
import 'package:memox_v4/domain/repositories/deck_repository.dart';
import 'package:memox_v4/domain/repositories/review_repository.dart';
import 'package:memox_v4/domain/repositories/settings_repository.dart';
import 'package:memox_v4/domain/usecases/library/card_search.dart';

/// In-memory [DeckRepository] over a [FakeStore]. Screens (and the DM.5/DM.6 use
/// cases) run against this exactly as they will against the Drift-backed repo
/// (DT.5) — same contract.
class FakeDeckRepository implements DeckRepository {
  FakeDeckRepository(this._store);

  final FakeStore _store;

  @override
  Stream<List<Deck>> watchChildren(DeckId? parentId) async* {
    yield _childrenOf(parentId);
    await for (final _ in _store.onChange) {
      yield _childrenOf(parentId);
    }
  }

  List<Deck> _childrenOf(DeckId? parentId) => _store.decks.values
      .where((deck) => deck.parentId?.value == parentId?.value)
      .toList(growable: false);

  @override
  Future<Result<Deck>> getById(DeckId id) async {
    final deck = _store.decks[id.value];
    if (deck == null) return Err(NotFoundFailure('No deck ${id.value}'));
    return Ok(deck);
  }

  @override
  Future<Result<DeckStats>> statsFor(DeckId id) async {
    final subtree = _subtreeIds(id);
    var stats = DeckStats.empty;
    for (final card in _store.cards.values) {
      if (!subtree.contains(card.deckId.value)) continue;
      final box = _store.srsByCard[card.id.value]?.box;
      stats = stats +
          DeckStats(
            totalCards: 1,
            hiddenCount: card.hidden ? 1 : 0,
            dueCount: 0,
            masteredCount: box == BoxLevel.mastered ? 1 : 0,
          );
    }
    return Ok(stats);
  }

  @override
  Future<Result<Deck>> save(Deck deck) async {
    _store.decks[deck.id.value] = deck;
    _store.notify();
    return Ok(deck);
  }

  @override
  Future<Result<void>> delete(DeckId id) async {
    final subtree = _subtreeIds(id);
    _store.decks.removeWhere((key, _) => subtree.contains(key));
    _store.cards.removeWhere((key, card) => subtree.contains(card.deckId.value));
    _store.srsByCard.removeWhere(
      (cardId, _) => !_store.cards.containsKey(cardId),
    );
    _store.notify();
    return const Ok<void>(null);
  }

  Set<String> _subtreeIds(DeckId root) {
    final ids = <String>{root.value};
    var changed = true;
    while (changed) {
      changed = false;
      for (final deck in _store.decks.values) {
        final parent = deck.parentId?.value;
        if (parent != null && ids.contains(parent) && ids.add(deck.id.value)) {
          changed = true;
        }
      }
    }
    return ids;
  }
}

/// In-memory [CardRepository] over a [FakeStore].
class FakeCardRepository implements CardRepository {
  FakeCardRepository(this._store);

  final FakeStore _store;

  @override
  Stream<List<Card>> watchByDeck(DeckId deckId) async* {
    yield _inDeck(deckId);
    await for (final _ in _store.onChange) {
      yield _inDeck(deckId);
    }
  }

  List<Card> _inDeck(DeckId deckId) => _store.cards.values
      .where((card) => card.deckId.value == deckId.value)
      .toList(growable: false);

  @override
  Future<Result<Card>> getById(CardId id) async {
    final card = _store.cards[id.value];
    if (card == null) return Err(NotFoundFailure('No card ${id.value}'));
    return Ok(card);
  }

  @override
  Future<Result<Card>> save(Card card) async {
    _store.cards[card.id.value] = card;
    _store.notify();
    return Ok(card);
  }

  @override
  Future<Result<void>> delete(CardId id) async {
    _store.cards.remove(id.value);
    _store.srsByCard.remove(id.value);
    _store.notify();
    return const Ok<void>(null);
  }

  @override
  Future<Result<void>> setHidden(CardId id, {required bool hidden}) async {
    final card = _store.cards[id.value];
    if (card == null) return Err(NotFoundFailure('No card ${id.value}'));
    final updated = (Card.create(
      id: card.id,
      deckId: card.deckId,
      term: card.term,
      meanings: card.meanings,
      hidden: hidden,
      audioRef: card.audioRef,
      grammaticalGender: card.grammaticalGender,
    ) as Ok<Card>)
        .value;
    _store.cards[id.value] = updated;
    _store.notify();
    return const Ok<void>(null);
  }

  @override
  Future<Result<List<Card>>> search(String query, {DeckId? within}) async {
    final scope = within == null
        ? _store.cards.values
        : _store.cards.values.where((card) => card.deckId.value == within.value);
    return Ok(CardSearch.filter(scope, query));
  }
}

/// In-memory [ReviewRepository]: joins the store's cards + SRS state to build the
/// due/new queues and persist schedule changes.
class FakeReviewRepository implements ReviewRepository {
  FakeReviewRepository(this._store);

  final FakeStore _store;

  @override
  Stream<int> watchDueCount({DeckId? within}) async* {
    yield _dueCards(within: within, asOf: DateTime.now()).length;
    await for (final _ in _store.onChange) {
      yield _dueCards(within: within, asOf: DateTime.now()).length;
    }
  }

  List<Card> _dueCards({DeckId? within, required DateTime asOf}) {
    final scope = within == null ? null : _subtreeIds(within);
    return _store.cards.values.where((card) {
      if (card.hidden) return false;
      if (scope != null && !scope.contains(card.deckId.value)) return false;
      return _store.srsByCard[card.id.value]?.isDue(asOf) ?? false;
    }).toList(growable: false);
  }

  /// Deck ids in [root]'s subtree (root included) — mirrors the deck repo, so
  /// `within` scopes to a subtree per the contract, not a single deck node.
  Set<String> _subtreeIds(DeckId root) {
    final ids = <String>{root.value};
    var changed = true;
    while (changed) {
      changed = false;
      for (final deck in _store.decks.values) {
        final parent = deck.parentId?.value;
        if (parent != null && ids.contains(parent) && ids.add(deck.id.value)) {
          changed = true;
        }
      }
    }
    return ids;
  }

  @override
  Future<Result<List<Card>>> dueQueue({
    DeckId? within,
    required DateTime asOf,
    int? limit,
  }) async {
    final due = _dueCards(within: within, asOf: asOf);
    return Ok(limit == null ? due : due.take(limit).toList(growable: false));
  }

  @override
  Future<Result<List<Card>>> newQueue({DeckId? within, required int limit}) async {
    final scope = within == null ? null : _subtreeIds(within);
    final news = _store.cards.values.where((card) {
      if (card.hidden) return false;
      if (scope != null && !scope.contains(card.deckId.value)) return false;
      return _store.srsByCard[card.id.value]?.box.isNew ?? true;
    });
    return Ok(news.take(limit).toList(growable: false));
  }

  @override
  Future<Result<BoxLevel>> currentBox(CardId cardId) async =>
      Ok(_store.srsByCard[cardId.value]?.box ?? BoxLevel.newCard);

  @override
  Future<Result<void>> saveSchedule({
    required CardId cardId,
    required BoxLevel box,
    DateTime? dueAt,
  }) async {
    _store.srsByCard[cardId.value] = SrsState(box: box, dueAt: dueAt);
    _store.notify();
    return const Ok<void>(null);
  }

  @override
  Future<Result<void>> logReview(ReviewLog log) async {
    _store.reviewLogs.add(log);
    return const Ok<void>(null);
  }
}

/// In-memory [SettingsRepository].
class FakeSettingsRepository implements SettingsRepository {
  FakeSettingsRepository(this._store);

  final FakeStore _store;

  @override
  Stream<DailyGoal> watchDailyGoal() async* {
    yield _store.dailyGoal;
    await for (final _ in _store.onChange) {
      yield _store.dailyGoal;
    }
  }

  @override
  Future<Result<void>> saveDailyGoal(DailyGoal goal) async {
    _store.dailyGoal = goal;
    _store.notify();
    return const Ok<void>(null);
  }

  @override
  Stream<int> watchNewCardsPerDay() async* {
    yield _store.newCardsPerDay;
    await for (final _ in _store.onChange) {
      yield _store.newCardsPerDay;
    }
  }

  @override
  Future<Result<void>> saveNewCardsPerDay(int count) async {
    _store.newCardsPerDay = count;
    _store.notify();
    return const Ok<void>(null);
  }
}
