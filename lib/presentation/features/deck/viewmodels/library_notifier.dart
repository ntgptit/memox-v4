import 'package:memox_v4/app/di/deck_providers.dart';
import 'package:memox_v4/domain/models/deck_node.dart';
import 'package:memox_v4/domain/types/result.dart';
import 'package:memox_v4/domain/types/sort.dart';
import 'package:memox_v4/domain/usecases/deck/create_deck.dart';
import 'package:memox_v4/domain/usecases/deck/delete_deck.dart';
import 'package:memox_v4/domain/usecases/deck/get_library_tree.dart';
import 'package:memox_v4/domain/usecases/deck/move_deck.dart';
import 'package:memox_v4/domain/usecases/deck/rename_deck.dart';
import 'package:memox_v4/domain/usecases/deck/sort_deck_nodes.dart';
import 'package:memox_v4/presentation/features/language_pair/viewmodels/language_pair_notifier.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'library_notifier.g.dart';

/// Library home state: the active pair's root deck nodes, sorted. Owns the
/// current sort and the deck mutations (`state-management-contract`). Reloads
/// when the active pair changes.
@riverpod
class LibraryNotifier extends _$LibraryNotifier {
  SortBy _sortBy = SortBy.alphabet;
  SortDirection _sortDirection = SortDirection.asc;

  SortBy get sortBy => _sortBy;
  SortDirection get sortDirection => _sortDirection;

  @override
  Future<List<DeckNode>> build() => _load();

  Future<List<DeckNode>> _load() async {
    final pairId = ref.watch(languagePairProvider).value?.active?.id;
    if (pairId == null) return const <DeckNode>[];
    final result = await GetLibraryTreeUseCase(
      ref.read(deckRepositoryProvider),
    ).call(pairId);
    final nodes = result.valueOrNull ?? const <DeckNode>[];
    return const SortDeckNodesUseCase().call(
      nodes,
      by: _sortBy,
      direction: _sortDirection,
    );
  }

  void setSort(SortBy by, SortDirection direction) {
    _sortBy = by;
    _sortDirection = direction;
    final current = state.value;
    if (current == null) return;
    state = AsyncData(
      const SortDeckNodesUseCase().call(current, by: by, direction: direction),
    );
  }

  Future<void> createDeck({int? parentDeckId, required String name}) async {
    final pairId = ref.read(languagePairProvider).value?.active?.id;
    if (pairId == null) return;
    await CreateDeckUseCase(
      ref.read(deckRepositoryProvider),
    ).call(pairId: pairId, parentDeckId: parentDeckId, name: name);
    await _refresh();
  }

  Future<void> renameDeck(int id, String name) async {
    await RenameDeckUseCase(ref.read(deckRepositoryProvider)).call(id, name);
    await _refresh();
  }

  Future<void> moveDeck(int id, {int? newParentId}) async {
    await MoveDeckUseCase(
      ref.read(deckRepositoryProvider),
    ).call(id, newParentId: newParentId);
    await _refresh();
  }

  Future<void> deleteDeck(int id) async {
    await DeleteDeckUseCase(ref.read(deckRepositoryProvider)).call(id);
    await _refresh();
  }

  Future<void> refresh() => _refresh();

  Future<void> _refresh() async {
    state = await AsyncValue.guard(_load);
  }
}
