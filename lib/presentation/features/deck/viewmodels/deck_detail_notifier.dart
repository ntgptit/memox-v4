import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox_v4/app/di/card_providers.dart';
import 'package:memox_v4/app/di/deck_providers.dart';
import 'package:memox_v4/domain/entities/card.dart';
import 'package:memox_v4/domain/models/deck_node.dart';
import 'package:memox_v4/domain/types/result.dart';
import 'package:memox_v4/domain/types/sort.dart';
import 'package:memox_v4/domain/usecases/deck/create_deck.dart';
import 'package:memox_v4/domain/usecases/deck/delete_deck.dart';
import 'package:memox_v4/domain/usecases/deck/get_deck_node.dart';
import 'package:memox_v4/domain/usecases/deck/move_deck.dart';
import 'package:memox_v4/domain/usecases/deck/rename_deck.dart';
import 'package:memox_v4/domain/usecases/deck/sort_deck_nodes.dart';
import 'package:memox_v4/presentation/features/deck/viewmodels/library_notifier.dart';

/// A deck-detail view: the deck's node (with recursive stats + sub-decks) and
/// its direct cards. `node` is null when the deck no longer exists.
class DeckDetailState {
  const DeckDetailState({required this.node, required this.cards});

  final DeckNode? node;
  final List<Card> cards;
}

/// Deck-detail state for one deck id. Mutations refresh this view and invalidate
/// the library so its recursive counts stay in sync.
final deckDetailNotifierProvider = AsyncNotifierProvider.autoDispose
    .family<DeckDetailNotifier, DeckDetailState, int>(DeckDetailNotifier.new);

class DeckDetailNotifier
    extends AutoDisposeFamilyAsyncNotifier<DeckDetailState, int> {
  @override
  Future<DeckDetailState> build(int arg) => _load();

  Future<DeckDetailState> _load() async {
    final nodeResult = await GetDeckNodeUseCase(
      ref.read(deckRepositoryProvider),
    ).call(arg);
    final node = nodeResult.valueOrNull;
    if (node == null) {
      return const DeckDetailState(node: null, cards: <Card>[]);
    }
    final cards =
        (await ref.read(cardRepositoryProvider).listByDeck(arg)).valueOrNull ??
        const <Card>[];
    final sortedChildren = const SortDeckNodesUseCase().call(
      node.children,
      by: SortBy.alphabet,
      direction: SortDirection.asc,
    );
    return DeckDetailState(
      node: DeckNode(
        deck: node.deck,
        stats: node.stats,
        children: sortedChildren,
      ),
      cards: cards,
    );
  }

  Future<void> createSubDeck(String name) async {
    final pairId = state.valueOrNull?.node?.deck.pairId;
    if (pairId == null) return;
    await CreateDeckUseCase(
      ref.read(deckRepositoryProvider),
    ).call(pairId: pairId, parentDeckId: arg, name: name);
    await _refreshAll();
  }

  Future<void> renameDeck(int id, String name) async {
    await RenameDeckUseCase(ref.read(deckRepositoryProvider)).call(id, name);
    await _refreshAll();
  }

  Future<void> moveDeck(int id, {int? newParentId}) async {
    await MoveDeckUseCase(
      ref.read(deckRepositoryProvider),
    ).call(id, newParentId: newParentId);
    await _refreshAll();
  }

  Future<void> deleteDeck(int id) async {
    await DeleteDeckUseCase(ref.read(deckRepositoryProvider)).call(id);
    await _refreshAll();
  }

  Future<void> refresh() => _refresh();

  Future<void> _refreshAll() async {
    ref.invalidate(libraryNotifierProvider);
    await _refresh();
  }

  Future<void> _refresh() async {
    state = await AsyncValue.guard(_load);
  }
}
