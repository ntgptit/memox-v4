import 'package:memox_v4/core/error/failure.dart';
import 'package:memox_v4/core/error/result.dart';
import 'package:memox_v4/core/logging/logger_provider.dart';
import 'package:memox_v4/data/providers/data_providers.dart';
import 'package:memox_v4/domain/entities/box_level.dart';
import 'package:memox_v4/domain/entities/deck.dart';
import 'package:memox_v4/domain/entities/ids.dart';
import 'package:memox_v4/domain/usecases/library/card_usecases.dart';
import 'package:memox_v4/domain/usecases/library/deck_usecases.dart';
import 'package:memox_v4/domain/usecases/srs/reset_deck_progress_usecase.dart';
import 'package:memox_v4/presentation/shared/composites/mx_status_card_row.dart';
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
  // Set in build() before any command runs, so it is late (non-null) rather than
  // nullable + `!`; a violated invariant throws a clear LateInitializationError.
  late DeckId _id;

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
        () => SetCardHiddenUseCase(ref.read(cardRepositoryProvider))
            .call(cardId, hidden: hidden),
      );

  Future<void> deleteCard(CardId cardId) => _mutate(
        () => DeleteCardUseCase(ref.read(cardRepositoryProvider)).call(cardId),
      );

  /// Reset every card in this deck back to New (box 0, unscheduled) so the deck
  /// re-enters the learn flow (kit `deck-detail/reset-confirm`).
  Future<void> resetDeckProgress() => _mutate(
        () => ResetDeckProgressUseCase(
          ref.read(cardRepositoryProvider),
          ref.read(reviewRepositoryProvider),
        ).call(_id),
      );

  /// Create a sub-deck under this deck from the learner-entered [name] (kit
  /// `deck-detail/new-subdeck`). Id is clock-stamped (import convention); the name
  /// is validated by [Deck.create] (BR-1).
  Future<void> createSubDeck(String name) => _mutate(() async {
        final id = DeckId(
            'deck-${ref.read(clockProvider).now().microsecondsSinceEpoch}');
        final created = Deck.create(id: id, name: name, parentId: _id);
        if (created case Err(:final failure)) return Err<Deck>(failure);
        return SaveDeckUseCase(ref.read(deckRepositoryProvider))
            .call((created as Ok<Deck>).value);
      });

  Future<void> deleteDeck() => _mutate(
        () => DeleteDeckUseCase(ref.read(deckRepositoryProvider)).call(_id),
      );

  Future<void> moveTo(DeckId? newParentId) => _mutate(
        () => MoveDeckUseCase(ref.read(deckRepositoryProvider))
            .call(deckId: _id, newParentId: newParentId),
      );

  /// Runs a mutation use case; refreshes on success, logs the cause on failure
  /// (the fake data layer never fails these — a real failure is a dev signal).
  Future<void> _mutate(Future<Result<Object?>> Function() action) async {
    final result = await action();
    result.fold(
      (_) => ref.invalidateSelf(), // guard:invalidate-reviewed -- reason: refresh deck detail after a successful mutation
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
