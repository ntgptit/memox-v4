import 'package:memox_v4/core/error/failure.dart';
import 'package:memox_v4/core/logging/logger_provider.dart';
import 'package:memox_v4/data/providers/data_providers.dart';
import 'package:memox_v4/domain/entities/ids.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'typing_providers.g.dart';

/// The grade of the current word — [none] while the learner is still typing.
enum TypingOutcome { none, correct, wrong }

/// A typing card: the meaning is prompted, the learner types the [term].
class TypingCard {
  const TypingCard({
    required this.cardId,
    required this.term,
    required this.meaning,
  });

  final String cardId;
  final String term;
  final String meaning;
}

/// The typing game state — the remaining queue, the current grade, the submitted
/// answer (kept for the wrong-state character diff), and whether the hint is shown.
class TypingState {
  const TypingState({
    required this.queue,
    required this.total,
    required this.outcome,
    required this.submitted,
    required this.hintShown,
  });

  final List<TypingCard> queue;
  final int total;
  final TypingOutcome outcome;
  final String submitted;
  final bool hintShown;

  bool get isEmpty => total == 0;
  bool get isComplete => total > 0 && queue.isEmpty;
  bool get isGraded => outcome != TypingOutcome.none;
  int get reviewed => total - queue.length;
  double get progress => total == 0 ? 0 : reviewed / total;
  TypingCard? get current => queue.isEmpty ? null : queue.first;

  TypingState copyWith({
    List<TypingCard>? queue,
    TypingOutcome? outcome,
    String? submitted,
    bool? hintShown,
  }) {
    return TypingState(
      queue: queue ?? this.queue,
      total: total,
      outcome: outcome ?? this.outcome,
      submitted: submitted ?? this.submitted,
      hintShown: hintShown ?? this.hintShown,
    );
  }
}

/// Drives the typing game: loads up to the words-per-round cards (DM.5), prompts
/// the meaning, grades a typed term (exact match after trimming), and advances.
/// A near-miss can be self-accepted ([acceptAsCorrect]) or retried ([retry]).
/// An async notifier rendered with `AsyncValue.when`; failed reads throw their
/// [Failure] — surfaced localized by the screen + logged.
@riverpod
class TypingController extends _$TypingController {
  @override
  Future<TypingState> build() async {
    try {
      return await _newRound();
    } on Failure catch (failure, stackTrace) {
      ref.read(loggerProvider).error(
            'typing load failed',
            error: failure,
            stackTrace: stackTrace,
          );
      rethrow;
    }
  }

  Future<TypingState> _newRound() async {
    final wordsPerRound =
        await ref.watch(settingsServiceProvider).watchGameWordsPerRound().first;
    final cards = await _loadCards(wordsPerRound);
    final queue = [
      for (final card in cards)
        TypingCard(cardId: card.$1, term: card.$2, meaning: card.$3),
    ];
    return TypingState(
      queue: queue,
      total: queue.length,
      outcome: TypingOutcome.none,
      submitted: '',
      hintShown: false,
    );
  }

  /// Grades [answer] against the current term (exact, trimmed). No-op on a blank
  /// answer or once already graded.
  void check(String answer) {
    final data = state.asData?.value;
    final card = data?.current;
    if (data == null || card == null || data.isGraded) return;
    final trimmed = answer.trim();
    if (trimmed.isEmpty) return;
    final correct = trimmed == card.term.trim();
    state = AsyncData(
      data.copyWith(
        outcome: correct ? TypingOutcome.correct : TypingOutcome.wrong,
        submitted: trimmed,
      ),
    );
  }

  void showHint() {
    final data = state.asData?.value;
    if (data == null || data.isGraded || data.current == null) return;
    state = AsyncData(data.copyWith(hintShown: true));
  }

  /// Advance past the current (correctly-answered or self-accepted) card.
  void next() {
    final data = state.asData?.value;
    if (data == null || !data.isGraded || data.queue.isEmpty) return;
    state = AsyncData(
      data.copyWith(
        queue: data.queue.sublist(1),
        outcome: TypingOutcome.none,
        submitted: '',
        hintShown: false,
      ),
    );
  }

  /// A near-miss the learner judges correct — advance, same as [next].
  void acceptAsCorrect() => next();

  /// Re-attempt the current word after a wrong grade.
  void retry() {
    final data = state.asData?.value;
    if (data == null || data.outcome != TypingOutcome.wrong) return;
    state = AsyncData(
      data.copyWith(outcome: TypingOutcome.none, submitted: ''),
    );
  }

  Future<void> nextRound() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_newRound);
  }

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
