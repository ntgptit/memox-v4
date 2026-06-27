import 'package:memox_v4/core/error/failure.dart';
import 'package:memox_v4/core/util/clock.dart';
import 'package:memox_v4/data/datasources/local/daos/deck_dao.dart';
import 'package:memox_v4/data/datasources/local/drift/app_database.dart'
    show DeckData, SrsStateData;
import 'package:memox_v4/data/mappers/deck_mapper.dart';
import 'package:memox_v4/domain/entities/deck.dart';
import 'package:memox_v4/domain/models/deck_node.dart';
import 'package:memox_v4/domain/models/deck_stats.dart';
import 'package:memox_v4/domain/repositories/deck_repository.dart';
import 'package:memox_v4/domain/types/result.dart';

/// Mutable per-deck accumulator for direct (non-recursive) stats.
class _Acc {
  int words = 0;
  int hidden = 0;
  int due = 0;
  int mastered = 0;
  int? lastStudiedAt;
}

/// Drift-backed [DeckRepository]. Builds the tree and recursive stats in Dart
/// over the pair's decks/cards/srs (small per-pair data, v1). Errors map to
/// [PersistenceFailure] at this boundary.
class DeckRepositoryImpl implements DeckRepository {
  const DeckRepositoryImpl(this._dao, this._clock);

  final DeckDao _dao;
  final Clock _clock;

  @override
  Future<Result<List<DeckNode>>> libraryTree(int pairId) async {
    try {
      return Ok(await _buildRoots(pairId));
    } catch (e) {
      return Err(PersistenceFailure(message: 'library tree', cause: e));
    }
  }

  @override
  Future<Result<DeckNode?>> node(int deckId) async {
    try {
      final deck = await _dao.deckById(deckId);
      if (deck == null) return const Ok(null);
      final roots = await _buildRoots(deck.pairId);
      return Ok(_find(roots, deckId));
    } catch (e) {
      return Err(PersistenceFailure(message: 'deck node', cause: e));
    }
  }

  @override
  Future<Result<Deck>> create({
    required int pairId,
    int? parentDeckId,
    required String name,
  }) async {
    try {
      final orderIndex = await _dao.siblingCount(pairId, parentDeckId);
      final id = await _dao.insertDeck(
        pairId: pairId,
        parentDeckId: parentDeckId,
        name: name,
        orderIndex: orderIndex,
      );
      final created = await _dao.deckById(id);
      return Ok(mapDeck(created!));
    } catch (e) {
      return Err(PersistenceFailure(message: 'create deck', cause: e));
    }
  }

  @override
  Future<Result<Deck>> rename(int id, String name) async {
    try {
      await _dao.renameDeck(id, name);
      final deck = await _dao.deckById(id);
      if (deck == null) {
        return const Err(NotFoundFailure(message: 'deck not found'));
      }
      return Ok(mapDeck(deck));
    } catch (e) {
      return Err(PersistenceFailure(message: 'rename deck', cause: e));
    }
  }

  @override
  Future<Result<void>> move(int id, {int? newParentId}) async {
    try {
      if (newParentId != null) {
        final deck = await _dao.deckById(id);
        if (deck == null) {
          return const Err(NotFoundFailure(message: 'deck not found'));
        }
        final descendants = await _descendantIds(deck.pairId, id);
        if (newParentId == id || descendants.contains(newParentId)) {
          return const Err(
            ValidationFailure(
              message: 'cannot move a deck into its own subtree',
            ),
          );
        }
      }
      await _dao.updateParent(id, newParentId);
      return const Ok<void>(null);
    } catch (e) {
      return Err(PersistenceFailure(message: 'move deck', cause: e));
    }
  }

  @override
  Future<Result<void>> delete(int id) async {
    try {
      await _dao.deleteDeck(id);
      return const Ok<void>(null);
    } catch (e) {
      return Err(PersistenceFailure(message: 'delete deck', cause: e));
    }
  }

  // ── tree + recursive stats ──────────────────────────────────────────────────
  Future<List<DeckNode>> _buildRoots(int pairId) async {
    final decks = await _dao.decksForPair(pairId);
    if (decks.isEmpty) return const <DeckNode>[];

    final cards = await _dao.cardsIn(
      decks.map((d) => d.id).toList(growable: false),
    );
    final srs = await _dao.srsFor(
      cards.map((c) => c.id).toList(growable: false),
    );
    final now = _clock.now().millisecondsSinceEpoch;
    final srsByCard = <int, SrsStateData>{for (final s in srs) s.cardId: s};

    final direct = <int, _Acc>{};
    for (final c in cards) {
      final acc = direct.putIfAbsent(c.deckId, _Acc.new);
      if (c.hidden) {
        acc.hidden++;
        continue;
      }
      acc.words++;
      final studiedAt = c.lastStudiedAt;
      if (studiedAt != null &&
          (acc.lastStudiedAt == null || studiedAt > acc.lastStudiedAt!)) {
        acc.lastStudiedAt = studiedAt;
      }
      final state = srsByCard[c.id];
      if (state != null) {
        if (state.box >= 8) {
          acc.mastered++;
        } else if (state.box >= 1 &&
            state.dueAt != null &&
            state.dueAt! <= now) {
          acc.due++;
        }
      }
    }

    final childrenOf = <int?, List<DeckData>>{};
    for (final d in decks) {
      (childrenOf[d.parentDeckId] ??= <DeckData>[]).add(d);
    }

    final cache = <int, DeckStats>{};
    DeckStats statsOf(int deckId) {
      final cached = cache[deckId];
      if (cached != null) return cached;
      final acc = direct[deckId] ?? _Acc();
      var words = acc.words;
      var hidden = acc.hidden;
      var due = acc.due;
      var mastered = acc.mastered;
      var last = acc.lastStudiedAt;
      for (final child in childrenOf[deckId] ?? const <DeckData>[]) {
        final cs = statsOf(child.id);
        words += cs.words;
        hidden += cs.hidden;
        due += cs.due;
        mastered += cs.mastered;
        final childLast = cs.lastStudiedAt;
        if (childLast != null && (last == null || childLast > last)) {
          last = childLast;
        }
      }
      final stats = DeckStats(
        words: words,
        hidden: hidden,
        due: due,
        mastered: mastered,
        lastStudiedAt: last,
      );
      cache[deckId] = stats;
      return stats;
    }

    DeckNode nodeOf(DeckData d) => DeckNode(
      deck: mapDeck(d),
      stats: statsOf(d.id),
      children: <DeckNode>[
        for (final c in childrenOf[d.id] ?? const <DeckData>[]) nodeOf(c),
      ],
    );

    return <DeckNode>[
      for (final root in childrenOf[null] ?? const <DeckData>[]) nodeOf(root),
    ];
  }

  Future<Set<int>> _descendantIds(int pairId, int rootId) async {
    final decks = await _dao.decksForPair(pairId);
    final childrenOf = <int?, List<int>>{};
    for (final d in decks) {
      (childrenOf[d.parentDeckId] ??= <int>[]).add(d.id);
    }
    final result = <int>{};
    void visit(int id) {
      for (final childId in childrenOf[id] ?? const <int>[]) {
        if (result.add(childId)) visit(childId);
      }
    }

    visit(rootId);
    return result;
  }

  DeckNode? _find(List<DeckNode> nodes, int id) {
    for (final node in nodes) {
      if (node.deck.id == id) return node;
      final found = _find(node.children, id);
      if (found != null) return found;
    }
    return null;
  }
}
