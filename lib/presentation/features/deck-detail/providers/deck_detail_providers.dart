import 'package:memox_v4/core/error/failure.dart';
import 'package:memox_v4/core/error/result.dart';
import 'package:memox_v4/core/logging/logger_provider.dart';
import 'package:memox_v4/data/providers/data_providers.dart';
import 'package:memox_v4/domain/entities/box_level.dart';
import 'package:memox_v4/domain/entities/deck.dart';
import 'package:memox_v4/domain/entities/ids.dart';
import 'package:memox_v4/domain/usecases/library/card_use_cases.dart';
import 'package:memox_v4/domain/usecases/library/deck_use_cases.dart';
import 'package:memox_v4/presentation/shared/composites/status_card_row.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'deck_detail_providers.g.dart';

/// Card status filter for the in-deck search (kit filter chips).
enum DeckCardFilter { all, newCards, due, mastered }

/// One sub-deck node under the current deck.
class SubDeckInfo {
  const SubDeckInfo({
    required this.id,
    required this.name,
    required this.isFolder,
    required this.words,
    required this.due,
    required this.progress,
  });

  final DeckId id;
  final String name;
  final bool isFolder;
  final int words;
  final int due;
  final double progress;
}

/// One card row in the deck (term + primary meaning + status + hidden flag).
class DeckCardInfo {
  const DeckCardInfo({
    required this.id,
    required this.term,
    required this.meaning,
    required this.status,
    required this.hidden,
  });

  final CardId id;
  final String term;
  final String meaning;
  final MxCardStatus status;
  final bool hidden;
}

/// The deck-detail view-model: the deck's name, its sub-decks, and its cards.
class DeckDetailData {
  const DeckDetailData({
    required this.deckId,
    required this.deckName,
    required this.subDecks,
    required this.cards,
  });

  final DeckId deckId;
  final String deckName;
  final List<SubDeckInfo> subDecks;
  final List<DeckCardInfo> cards;

  bool get isEmpty => subDecks.isEmpty && cards.isEmpty;
}

/// The in-deck search query (feature UI state; no `setState`).
@riverpod
class DeckSearchQuery extends _$DeckSearchQuery {
  @override
  String build() => '';

  void set(String query) => state = query;
  void clear() => state = '';
}

/// The active card filter chip.
@riverpod
class DeckCardFilterState extends _$DeckCardFilterState {
  @override
  DeckCardFilter build() => DeckCardFilter.all;

  void select(DeckCardFilter filter) => state = filter;
}

/// Root decks — move-sheet destinations.
@riverpod
Stream<List<Deck>> rootDecks(Ref ref) =>
    ref.watch(deckRepositoryProvider).watchChildren(null);

/// Assembles the deck-detail view-model for [deckId] and owns its mutations
/// (hide/delete card, delete/move deck). An async family notifier rendered with
/// `AsyncValue.when`. A failed read throws its [Failure] — surfaced localized by
/// the screen and logged here; never swallowed.
@riverpod
class DeckDetailController extends _$DeckDetailController {
  DeckId? _id;

  @override
  Future<DeckDetailData> build(String deckId) async {
    final id = DeckId(deckId);
    _id = id;
    try {
      return await _load(id);
    } on Failure catch (failure, stackTrace) {
      ref.read(loggerProvider).error(
            'deck-detail load failed',
            error: failure,
            stackTrace: stackTrace,
          );
      rethrow;
    }
  }

  Future<DeckDetailData> _load(DeckId id) async {
    final decks = ref.watch(deckRepositoryProvider);
    final cardsRepo = ref.watch(cardRepositoryProvider);
    final reviews = ref.watch(reviewRepositoryProvider);
    final now = ref.watch(clockProvider).now();

    final deck = _value(await decks.getById(id));

    final children = await decks.watchChildren(id).first;
    final subDecks = <SubDeckInfo>[];
    for (final child in children) {
      final stats = _value(await decks.statsFor(child.id));
      final due = _value(await reviews.dueQueue(within: child.id, asOf: now));
      final grandChildren = await decks.watchChildren(child.id).first;
      subDecks.add(SubDeckInfo(
        id: child.id,
        name: child.name,
        isFolder: grandChildren.isNotEmpty,
        words: stats.visibleCount,
        due: due.length,
        progress: stats.progress,
      ));
    }

    final cards = await cardsRepo.watchByDeck(id).first;
    final cardInfos = <DeckCardInfo>[];
    for (final card in cards) {
      final box = _value(await reviews.currentBox(card.id));
      cardInfos.add(DeckCardInfo(
        id: card.id,
        term: card.term,
        meaning: card.meanings.isEmpty ? '' : card.meanings.first.text,
        status: _statusOf(box),
        hidden: card.hidden,
      ));
    }

    return DeckDetailData(
      deckId: id,
      deckName: deck.name,
      subDecks: subDecks,
      cards: cardInfos,
    );
  }

  Future<void> setCardHidden(CardId cardId, {required bool hidden}) => _mutate(
        () => SetCardHidden(ref.read(cardRepositoryProvider))
            .call(cardId, hidden: hidden),
      );

  Future<void> deleteCard(CardId cardId) => _mutate(
        () => DeleteCard(ref.read(cardRepositoryProvider)).call(cardId),
      );

  Future<void> deleteDeck() => _mutate(
        () => DeleteDeck(ref.read(deckRepositoryProvider)).call(_id!),
      );

  Future<void> moveTo(DeckId? newParentId) => _mutate(
        () => MoveDeck(ref.read(deckRepositoryProvider))
            .call(deckId: _id!, newParentId: newParentId),
      );

  /// Runs a mutation use case; refreshes on success, logs the cause on failure
  /// (the fake data layer never fails these — a real failure is a dev signal).
  Future<void> _mutate(Future<Result<Object?>> Function() action) async {
    final result = await action();
    result.fold(
      (_) => ref.invalidateSelf(),
      (failure) => ref
          .read(loggerProvider)
          .error('deck-detail mutation failed', error: failure),
    );
  }

  MxCardStatus _statusOf(BoxLevel box) {
    if (box.isNew) return MxCardStatus.newCard;
    if (box.isMastered) return MxCardStatus.mastered;
    return MxCardStatus.due;
  }

  T _value<T>(Result<T> result) => switch (result) {
        Ok<T>(:final value) => value,
        // ignore: only_throw_errors
        Err<T>(:final failure) => throw failure,
      };
}
