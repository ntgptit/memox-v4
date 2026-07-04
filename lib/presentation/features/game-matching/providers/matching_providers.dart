import 'package:memox_v4/core/error/failure.dart';
import 'package:memox_v4/core/logging/logger_provider.dart';
import 'package:memox_v4/core/theme/mx_motion.dart';
import 'package:memox_v4/data/providers/data_providers.dart';
import 'package:memox_v4/domain/entities/ids.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'matching_providers.g.dart';

/// A matching tile — the [text] shown, tagged with its [cardId] so a left
/// (meaning) tile and a right (term) tile match when their card ids are equal.
class MatchTile {
  const MatchTile({required this.cardId, required this.text});

  final String cardId;
  final String text;
}

/// How long a correctly-matched pair flashes the success skin before the tiles
/// collapse into the matched (hidden) state (kit motion token `flash`).
const Duration matchFlashDuration = MxDurations.flash;

/// The matching-game state: the two columns, the current left selection, the
/// matched indices, and the transient correct- / wrong-pair feedback.
class MatchingState {
  const MatchingState({
    required this.left,
    required this.right,
    required this.selectedLeft,
    required this.matchedLeft,
    required this.matchedRight,
    required this.correctLeft,
    required this.correctRight,
    required this.wrongLeft,
    required this.wrongRight,
  });

  final List<MatchTile> left;
  final List<MatchTile> right;
  final int? selectedLeft;
  final Set<int> matchedLeft;
  final Set<int> matchedRight;

  /// The pair flashing the success skin this instant (before it becomes matched).
  final int? correctLeft;
  final int? correctRight;
  final int? wrongLeft;
  final int? wrongRight;

  bool get isComplete => left.isNotEmpty && matchedLeft.length == left.length;
  int get matchedCount => matchedLeft.length;
  int get total => left.length;
  double get progress => left.isEmpty ? 0 : matchedLeft.length / left.length;

  MatchingState copyWith({
    int? Function()? selectedLeft,
    Set<int>? matchedLeft,
    Set<int>? matchedRight,
    int? Function()? correctLeft,
    int? Function()? correctRight,
    int? Function()? wrongLeft,
    int? Function()? wrongRight,
  }) {
    return MatchingState(
      left: left,
      right: right,
      selectedLeft: selectedLeft != null ? selectedLeft() : this.selectedLeft,
      matchedLeft: matchedLeft ?? this.matchedLeft,
      matchedRight: matchedRight ?? this.matchedRight,
      correctLeft: correctLeft != null ? correctLeft() : this.correctLeft,
      correctRight: correctRight != null ? correctRight() : this.correctRight,
      wrongLeft: wrongLeft != null ? wrongLeft() : this.wrongLeft,
      wrongRight: wrongRight != null ? wrongRight() : this.wrongRight,
    );
  }
}

/// Drives the matching game: loads up to the words-per-round cards (DM.5), lays
/// meanings on the left / terms (shuffled) on the right, and resolves taps. An
/// async notifier rendered with `AsyncValue.when`. Failed reads throw their
/// [Failure] — surfaced localized by the screen and logged; never swallowed.
@riverpod
class MatchingController extends _$MatchingController {
  /// True once the provider is disposed — stops the delayed match-commit from
  /// touching `state` after the learner has left the screen.
  bool _disposed = false;

  @override
  Future<MatchingState> build() async {
    ref.onDispose(() => _disposed = true);
    try {
      return await _newRound();
    } on Failure catch (failure, stackTrace) {
      ref.read(loggerProvider).error(
            'matching load failed',
            error: failure,
            stackTrace: stackTrace,
          );
      rethrow;
    }
  }

  Future<MatchingState> _newRound() async {
    final wordsPerRound =
        await ref.watch(settingsServiceProvider).watchGameWordsPerRound().first;
    final cards = await _loadCards(wordsPerRound);
    final left = [
      for (final card in cards) MatchTile(cardId: card.$1, text: card.$3),
    ];
    final right = [
      for (final card in cards) MatchTile(cardId: card.$1, text: card.$2),
    ]..shuffle();
    return MatchingState(
      left: left,
      right: right,
      selectedLeft: null,
      matchedLeft: const {},
      matchedRight: const {},
      correctLeft: null,
      correctRight: null,
      wrongLeft: null,
      wrongRight: null,
    );
  }

  void selectLeft(int index) {
    final data = state.asData?.value;
    if (data == null || data.matchedLeft.contains(index)) return;
    state = AsyncData(data.copyWith(
      selectedLeft: () => index,
      wrongLeft: () => null,
      wrongRight: () => null,
    ));
  }

  void selectRight(int index) {
    final data = state.asData?.value;
    if (data == null || data.matchedRight.contains(index)) return;
    final selected = data.selectedLeft;
    if (selected == null) return;

    final isMatch = data.left[selected].cardId == data.right[index].cardId;
    if (isMatch) {
      // Flash the success skin, then collapse the pair into matched after a beat.
      state = AsyncData(data.copyWith(
        selectedLeft: () => null,
        correctLeft: () => selected,
        correctRight: () => index,
        wrongLeft: () => null,
        wrongRight: () => null,
      ));
      _commitMatchAfterFlash(leftIndex: selected, rightIndex: index);
      return;
    }
    state = AsyncData(data.copyWith(
      selectedLeft: () => null,
      wrongLeft: () => selected,
      wrongRight: () => index,
    ));
  }

  /// After [matchFlashDuration], move the just-flashed pair into the matched set
  /// (hiding the tiles) and clear its correct flag. Guarded against firing after
  /// the provider is disposed (the learner left mid-flash).
  void _commitMatchAfterFlash({required int leftIndex, required int rightIndex}) {
    Future<void>.delayed(matchFlashDuration, () {
      if (_disposed) return;
      final data = state.asData?.value;
      if (data == null) return;
      state = AsyncData(data.copyWith(
        matchedLeft: {...data.matchedLeft, leftIndex},
        matchedRight: {...data.matchedRight, rightIndex},
        correctLeft: () => data.correctLeft == leftIndex ? null : data.correctLeft,
        correctRight: () =>
            data.correctRight == rightIndex ? null : data.correctRight,
      ));
    });
  }

  Future<void> nextRound() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_newRound);
  }

  /// Gathers up to [limit] visible cards (term + primary meaning) across the deck
  /// tree — the DM.5/Drift repo (DT.5) can replace the walk with one query.
  Future<List<(String, String, String)>> _loadCards(int limit) async {
    final decks = ref.watch(deckRepositoryProvider);
    final cardsRepo = ref.watch(cardRepositoryProvider);

    final out = <(String, String, String)>[];
    final queue = <DeckId>[
      for (final deck in await decks.watchChildren(null).first) deck.id,
    ];
    final visited = <String>{};
    while (queue.isNotEmpty && out.length < limit) {
      final id = queue.removeLast();
      if (!visited.add(id.value)) continue;
      final cards = await cardsRepo.watchByDeck(id).first;
      for (final card in cards) {
        if (card.hidden || card.meanings.isEmpty) continue;
        out.add((card.id.value, card.term, card.meanings.first.text));
        if (out.length >= limit) break;
      }
      for (final child in await decks.watchChildren(id).first) {
        queue.add(child.id);
      }
    }
    return out;
  }
}
