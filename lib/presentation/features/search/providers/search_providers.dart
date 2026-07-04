import 'dart:async';

import 'package:memox_v4/core/error/failure.dart';
import 'package:memox_v4/core/error/result.dart';
import 'package:memox_v4/core/logging/logger_provider.dart';
import 'package:memox_v4/data/providers/data_providers.dart';
import 'package:memox_v4/domain/entities/box_level.dart';
import 'package:memox_v4/domain/entities/ids.dart';
import 'package:memox_v4/domain/usecases/library/card_usecases.dart';
import 'package:memox_v4/presentation/shared/composites/mx_status_card_row.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'search_providers.g.dart';

/// Status filter for the search results (kit filter chips).
enum SearchFilter { all, newCards, due, mastered }

/// One global-search hit — a card with its owning deck's name.
class SearchResult {
  const SearchResult({
    required this.cardId,
    required this.term,
    required this.meaning,
    required this.deckName,
    required this.status,
    required this.hidden,
  });

  final CardId cardId;
  final String term;
  final String meaning;
  final String deckName;
  final MxCardStatus status;
  final bool hidden;
}

/// The active search query (feature UI state; no `setState`).
@riverpod
class SearchQuery extends _$SearchQuery {
  @override
  String build() => '';

  void set(String query) => state = query;
  void clear() => state = '';
}

/// The active status filter chip.
@riverpod
class SearchFilterState extends _$SearchFilterState {
  @override
  SearchFilter build() => SearchFilter.all;

  void select(SearchFilter filter) => state = filter;
}

/// Recently used searches — **persisted** across restarts via
/// [RecentSearchService] (over the KV store). Most-recent first, de-duplicated,
/// capped. Kept alive so it survives the results↔recents transitions (it is only
/// watched when the query is empty). `build` seeds asynchronously from the store,
/// so the type stays `List<String>` for the screen.
@Riverpod(keepAlive: true)
class RecentSearches extends _$RecentSearches {
  static const int _max = 5;

  @override
  List<String> build() {
    unawaited(_seed());
    return const [];
  }

  Future<void> _seed() async {
    final saved = await ref.read(recentSearchServiceProvider).load();
    // Don't clobber an `add` that raced the async load.
    if (state.isEmpty) {
      state = saved.take(_max).toList(growable: false);
    }
  }

  void add(String query) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;
    final next = [trimmed, ...state.where((q) => q != trimmed)]
        .take(_max)
        .toList(growable: false);
    state = next;
    unawaited(_persist(next));
  }

  Future<void> _persist(List<String> queries) async {
    final result = await ref.read(recentSearchServiceProvider).save(queries);
    if (result case Err(:final failure)) {
      ref.read(loggerProvider).error('save recent searches failed', error: failure);
    }
  }
}

/// Runs the global card search (DM.6 `SearchCardsUseCase`, D-019) for the active query
/// and enriches each hit with its deck name + SRS status. Empty query → no
/// results (the screen shows recents instead). A failed read throws its [Failure]
/// — surfaced localized by the screen and logged here; never swallowed.
@riverpod
Future<List<SearchResult>> searchResults(Ref ref) async {
  final query = ref.watch(searchQueryProvider);
  if (query.trim().isEmpty) return const [];

  try {
    final cardsRepo = ref.watch(cardRepositoryProvider);
    final decksRepo = ref.watch(deckRepositoryProvider);
    final reviews = ref.watch(reviewRepositoryProvider);

    final cards = _value(await SearchCardsUseCase(cardsRepo).call(query));
    final results = <SearchResult>[];
    for (final card in cards) {
      final box = _value(await reviews.currentBox(card.id));
      final deck = _value(await decksRepo.getById(card.deckId));
      results.add(SearchResult(
        cardId: card.id,
        term: card.term,
        meaning: card.meanings.isEmpty ? '' : card.meanings.first.text,
        deckName: deck.name,
        status: _statusOf(box),
        hidden: card.hidden,
      ));
    }
    return results;
  } on Failure catch (failure, stackTrace) {
    ref
        .read(loggerProvider)
        .error('search failed', error: failure, stackTrace: stackTrace);
    rethrow;
  }
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
