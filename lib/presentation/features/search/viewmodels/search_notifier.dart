import 'package:memox_v4/app/di/search_providers.dart';
import 'package:memox_v4/domain/models/search_result.dart';
import 'package:memox_v4/domain/types/card_status.dart';
import 'package:memox_v4/domain/types/result.dart';
import 'package:memox_v4/domain/usecases/search/search_cards.dart';
import 'package:memox_v4/presentation/features/language_pair/viewmodels/language_pair_notifier.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'search_notifier.g.dart';

/// Search UI state: the query, the status filter (null = all), and the raw
/// results (the screen applies the filter against the clock).
class SearchUiState {
  const SearchUiState({
    this.query = '',
    this.filter,
    this.searching = false,
    this.results = const <SearchResult>[],
    this.recent = const <String>[],
  });

  final String query;
  final CardStatus? filter;
  final bool searching;
  final List<SearchResult> results;
  final List<String> recent;

  SearchUiState copyWith({
    String? query,
    bool? searching,
    List<SearchResult>? results,
    List<String>? recent,
  }) => SearchUiState(
    query: query ?? this.query,
    filter: filter,
    searching: searching ?? this.searching,
    results: results ?? this.results,
    recent: recent ?? this.recent,
  );
}

/// Kept alive so recent searches survive within a session.
@Riverpod(keepAlive: true)
class SearchNotifier extends _$SearchNotifier {
  static const int _recentLimit = 5;

  @override
  SearchUiState build() => const SearchUiState();

  Future<void> search(String query) async {
    final trimmed = query.trim();
    state = state.copyWith(query: query, searching: trimmed.isNotEmpty);
    if (trimmed.isEmpty) {
      state = state.copyWith(results: const <SearchResult>[], searching: false);
      return;
    }
    final pairContext = await ref.read(languagePairProvider.future);
    if (state.query.trim() != trimmed) return;
    final pairId = pairContext.active?.id;
    if (pairId == null) {
      state = state.copyWith(results: const <SearchResult>[], searching: false);
      return;
    }
    final results =
        (await SearchCardsUseCase(
          ref.read(searchRepositoryProvider),
        ).call(pairId: pairId, query: trimmed)).valueOrNull ??
        const <SearchResult>[];
    // Ignore stale responses if the query moved on.
    if (state.query.trim() != trimmed) return;
    state = state.copyWith(
      results: results,
      searching: false,
      recent: _withRecent(state.recent, trimmed),
    );
  }

  void setFilter(CardStatus? filter) => state = SearchUiState(
    query: state.query,
    filter: filter,
    searching: state.searching,
    results: state.results,
    recent: state.recent,
  );

  void clear() =>
      state = state.copyWith(query: '', results: const <SearchResult>[]);

  List<String> _withRecent(List<String> recent, String query) {
    final next = <String>[query, ...recent.where((r) => r != query)];
    return next.length <= _recentLimit ? next : next.sublist(0, _recentLimit);
  }
}
