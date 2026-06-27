import 'package:memox_v4/domain/models/deck_node.dart';
import 'package:memox_v4/domain/types/sort.dart';

/// Sorts a list of deck nodes (and, recursively, their children) by a criterion
/// and direction (D-023). Pure read-model transform — no persistence.
///
/// `alphabet` compares names case-insensitively; `createdAt` uses the deck id
/// (insertion order proxy); `lastStudied` uses the subtree's most recent study
/// time (never-studied sorts first ascending).
class SortDeckNodesUseCase {
  const SortDeckNodesUseCase();

  List<DeckNode> call(
    List<DeckNode> nodes, {
    required SortBy by,
    required SortDirection direction,
  }) {
    final sorted = <DeckNode>[...nodes]
      ..sort((a, b) {
        final base = _compare(a, b, by);
        return direction == SortDirection.asc ? base : -base;
      });
    return sorted
        .map(
          (n) => DeckNode(
            deck: n.deck,
            stats: n.stats,
            children: call(n.children, by: by, direction: direction),
          ),
        )
        .toList(growable: false);
  }

  int _compare(DeckNode a, DeckNode b, SortBy by) => switch (by) {
    SortBy.alphabet => a.deck.name.toLowerCase().compareTo(
      b.deck.name.toLowerCase(),
    ),
    SortBy.createdAt => a.deck.id.compareTo(b.deck.id),
    SortBy.lastStudied => _nullableCompare(
      a.stats.lastStudiedAt,
      b.stats.lastStudiedAt,
    ),
  };

  int _nullableCompare(int? a, int? b) {
    if (a == null && b == null) return 0;
    if (a == null) return -1;
    if (b == null) return 1;
    return a.compareTo(b);
  }
}
