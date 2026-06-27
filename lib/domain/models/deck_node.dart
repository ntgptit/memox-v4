import 'package:memox_v4/domain/entities/deck.dart';
import 'package:memox_v4/domain/models/deck_stats.dart';

/// A node in the library tree: a deck, its recursive [stats], and its child
/// nodes. The read-model the library/deck-detail screens render.
class DeckNode {
  const DeckNode({
    required this.deck,
    required this.stats,
    this.children = const <DeckNode>[],
  });

  final Deck deck;
  final DeckStats stats;
  final List<DeckNode> children;
}
