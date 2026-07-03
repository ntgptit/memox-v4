import 'package:memox_v4/core/error/failure.dart';
import 'package:memox_v4/core/error/result.dart';
import 'package:memox_v4/core/logging/logger_provider.dart';
import 'package:memox_v4/data/providers/data_providers.dart';
import 'package:memox_v4/domain/entities/ids.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'recall_providers.g.dart';

/// Fixed term language for spoken prompts (per-pair language deferred — gap).
const String _termSpeakLanguage = 'ko';

/// A recall card — its term prompt and the meaning revealed on demand.
class RecallCard {
  const RecallCard({
    required this.cardId,
    required this.term,
    required this.meaning,
  });

  final String cardId;
  final String term;
  final String meaning;
}

/// The recall game state — the remaining queue (a forgotten card is re-queued to
/// the end), whether the current meaning is revealed, and the round total.
class RecallState {
  const RecallState({
    required this.queue,
    required this.total,
    required this.revealed,
  });

  final List<RecallCard> queue;
  final int total;
  final bool revealed;

  bool get isEmpty => total == 0;
  bool get isComplete => total > 0 && queue.isEmpty;
  int get reviewed => total - queue.length;
  double get progress => total == 0 ? 0 : reviewed / total;
  RecallCard? get current => queue.isEmpty ? null : queue.first;

  RecallState copyWith({List<RecallCard>? queue, bool? revealed}) {
    return RecallState(
      queue: queue ?? this.queue,
      total: total,
      revealed: revealed ?? this.revealed,
    );
  }
}

/// Drives the recall game: loads up to the words-per-round cards (DM.5), shows a
/// term, reveals its meaning, and self-grades (Got it removes the card; Forgot
/// re-queues it to the end). An async notifier rendered with `AsyncValue.when`.
/// Failed reads throw their [Failure] — surfaced localized by the screen + logged.
@riverpod
class RecallController extends _$RecallController {
  @override
  Future<RecallState> build() async {
    try {
      return await _newRound();
    } on Failure catch (failure, stackTrace) {
      ref.read(loggerProvider).error(
            'recall load failed',
            error: failure,
            stackTrace: stackTrace,
          );
      rethrow;
    }
  }

  Future<RecallState> _newRound() async {
    final wordsPerRound =
        await ref.watch(settingsServiceProvider).watchGameWordsPerRound().first;
    final cards = await _loadCards(wordsPerRound);
    final queue = [
      for (final card in cards)
        RecallCard(cardId: card.$1, term: card.$2, meaning: card.$3),
    ];
    return RecallState(queue: queue, total: queue.length, revealed: false);
  }

  void reveal() {
    final data = state.asData?.value;
    if (data == null || data.revealed || data.current == null) return;
    state = AsyncData(data.copyWith(revealed: true));
  }

  void gotIt() {
    final data = state.asData?.value;
    if (data == null || !data.revealed || data.queue.isEmpty) return;
    state = AsyncData(
      data.copyWith(queue: data.queue.sublist(1), revealed: false),
    );
  }

  void forgot() {
    final data = state.asData?.value;
    if (data == null || !data.revealed || data.queue.isEmpty) return;
    final next = [...data.queue.sublist(1), data.queue.first];
    state = AsyncData(data.copyWith(queue: next, revealed: false));
  }

  Future<void> playAudio() async {
    final data = state.asData?.value;
    final card = data?.current;
    if (card == null) return;
    final result = await ref
        .read(audioServiceProvider)
        .speak(card.term, languageCode: _termSpeakLanguage);
    if (result case Err(:final failure)) {
      ref.read(loggerProvider).error('recall audio failed', error: failure);
    }
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
