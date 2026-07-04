import 'package:memox_v4/core/error/failure.dart';
import 'package:memox_v4/core/error/result.dart';
import 'package:memox_v4/core/logging/logger_provider.dart';
import 'package:memox_v4/data/providers/data_providers.dart';
import 'package:memox_v4/domain/entities/deck.dart';
import 'package:memox_v4/domain/entities/ids.dart';
import 'package:memox_v4/domain/entities/language_pair.dart';
import 'package:memox_v4/domain/usecases/library/deck_usecases.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'library_providers.g.dart';

/// How the library tree is ordered. Only name-based orders are drivable in v1 —
/// the deck row carries no created/last-studied columns (deck spec), so those kit
/// sort options are documented gaps, not fabricated.
enum LibrarySortOrder { alphaAsc, alphaDesc }

/// The active library sort order — feature UI state owned by Riverpod (no
/// `setState`). The sort sheet writes it; [LibraryController] reads it.
@riverpod
class LibrarySort extends _$LibrarySort {
  @override
  LibrarySortOrder build() => LibrarySortOrder.alphaAsc;

  void select(LibrarySortOrder order) => state = order;
}

/// One node in the library tree — a deck or a folder (a deck that holds child
/// decks). Presentational counts come from [DeckStats] + the review queue.
class LibraryNode {
  const LibraryNode({
    required this.id,
    required this.name,
    required this.isFolder,
    required this.words,
    required this.due,
    required this.hidden,
    required this.progress,
  });

  final DeckId id;
  final String name;

  /// Whether this node has child decks (folder) vs. holds cards directly (deck).
  final bool isFolder;

  /// Visible (non-hidden) cards in the subtree.
  final int words;
  final int due;
  final int hidden;

  /// Mastered / visible fraction, 0..1.
  final double progress;

  /// All visible cards are mastered (and there is something to master).
  bool get isMastered => words > 0 && progress >= 1;
}

/// The library view-model — the ordered deck tree.
class LibraryData {
  const LibraryData({required this.nodes});

  final List<LibraryNode> nodes;

  bool get isEmpty => nodes.isEmpty;
}

/// Assembles the library tree from the deck repository (DM.6). An async notifier
/// rendered with `AsyncValue.when`. A failed read throws its [Failure] — surfaced
/// localized to the user by the screen and logged here; never swallowed.
@riverpod
class LibraryController extends _$LibraryController {
  @override
  Future<LibraryData> build() async {
    try {
      return await _load();
    } on Failure catch (failure, stackTrace) {
      ref
          .read(loggerProvider)
          .error('library load failed', error: failure, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<LibraryData> _load() async {
    final now = ref.watch(clockProvider).now();
    final decks = ref.watch(deckRepositoryProvider);
    final reviews = ref.watch(reviewRepositoryProvider);
    final order = ref.watch(librarySortProvider);

    final roots = await decks.watchChildren(null).first;
    final nodes = <LibraryNode>[];
    for (final deck in roots) {
      final stats = _value(await decks.statsFor(deck.id));
      final due = _value(await reviews.dueQueue(within: deck.id, asOf: now));
      final children = await decks.watchChildren(deck.id).first;
      nodes.add(LibraryNode(
        id: deck.id,
        name: deck.name,
        isFolder: children.isNotEmpty,
        words: stats.visibleCount,
        due: due.length,
        hidden: stats.hiddenCount,
        progress: stats.progress,
      ));
    }
    _sort(nodes, order);
    return LibraryData(nodes: nodes);
  }

  /// Create a new root deck from the learner-entered [name] (kit `library/create`
  /// → `new-deck`). The id is a clock-stamped value (same convention as import);
  /// the name is validated by [Deck.create] (BR-1). Refreshes on success; a
  /// failure is logged, not swallowed.
  Future<void> createDeck(String name) async {
    final id = DeckId('deck-${ref.read(clockProvider).now().microsecondsSinceEpoch}');
    final created = Deck.create(id: id, name: name);
    if (created case Err(:final failure)) {
      ref.read(loggerProvider).error('create deck rejected', error: failure);
      return;
    }
    final saved = await SaveDeckUseCase(ref.read(deckRepositoryProvider))
        .call((created as Ok<Deck>).value);
    saved.fold(
      (_) => ref.invalidateSelf(), // guard:invalidate-reviewed -- reason: refresh the library tree after saving a deck
      (failure) =>
          ref.read(loggerProvider).error('create deck failed', error: failure),
    );
  }

  void _sort(List<LibraryNode> nodes, LibrarySortOrder order) {
    nodes.sort((a, b) {
      final byName = a.name.toLowerCase().compareTo(b.name.toLowerCase());
      return order == LibrarySortOrder.alphaAsc ? byName : -byName;
    });
  }

  T _value<T>(Result<T> result) => switch (result) {
        Ok<T>(:final value) => value,
        // ignore: only_throw_errors -- reason: Failure is MemoX's domain error type; unwrapping the Result and rethrowing surfaces it as AsyncValue.error at the provider boundary
        Err<T>(:final failure) => throw failure,
      };
}

/// The learner's language pairs (glossary) — for the context bar + picker sheet.
@riverpod
Stream<List<LanguagePair>> languagePairs(Ref ref) =>
    ref.watch(languagePairServiceProvider).watchAll();

/// The selected language-pair id, or null before the learner has picked one.
@riverpod
Stream<LanguagePairId?> selectedLanguagePairId(Ref ref) =>
    ref.watch(languagePairServiceProvider).watchSelected();
