import 'package:memox_v4/core/error/failure.dart';
import 'package:memox_v4/core/error/result.dart';
import 'package:memox_v4/core/logging/logger_provider.dart';
import 'package:memox_v4/data/providers/data_providers.dart';
import 'package:memox_v4/domain/entities/ids.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'mc_providers.g.dart';

/// How many distractor choices sit beside the correct one.
const int _distractorCount = 3;

/// Fixed term language for spoken prompts (per-pair language deferred — gap).
const String _termSpeakLanguage = 'ko';

/// One multiple-choice question: the prompt term, the shuffled meaning choices,
/// and which is correct.
class McQuestion {
  const McQuestion({
    required this.cardId,
    required this.prompt,
    required this.choices,
    required this.correctIndex,
  });

  final String cardId;
  final String prompt;
  final List<String> choices;
  final int correctIndex;
}

/// The MC game state.
class McState {
  const McState({
    required this.questions,
    required this.index,
    required this.chosen,
    required this.correctCount,
  });

  final List<McQuestion> questions;
  final int index;
  final int? chosen;
  final int correctCount;

  bool get isEmpty => questions.isEmpty;
  bool get isComplete => questions.isNotEmpty && index >= questions.length;
  int get total => questions.length;
  double get progress => questions.isEmpty ? 0 : index / questions.length;
  McQuestion get current => questions[index];

  McState copyWith({int? index, int? Function()? chosen, int? correctCount}) {
    return McState(
      questions: questions,
      index: index ?? this.index,
      chosen: chosen != null ? chosen() : this.chosen,
      correctCount: correctCount ?? this.correctCount,
    );
  }
}

/// Drives the multiple-choice game: loads up to the words-per-round cards (DM.5),
/// builds one question per card (correct meaning + 3 distractors, shuffled), and
/// grades answers. An async notifier rendered with `AsyncValue.when`. Failed reads
/// throw their [Failure] — surfaced localized by the screen and logged.
@riverpod
class McController extends _$McController {
  @override
  Future<McState> build() async {
    try {
      return await _newRound();
    } on Failure catch (failure, stackTrace) {
      ref.read(loggerProvider).error(
            'mc load failed',
            error: failure,
            stackTrace: stackTrace,
          );
      rethrow;
    }
  }

  Future<McState> _newRound() async {
    final wordsPerRound =
        await ref.watch(settingsServiceProvider).watchGameWordsPerRound().first;
    final cards = await _loadCards(wordsPerRound);
    final allMeanings = [for (final card in cards) card.$3];

    final questions = <McQuestion>[];
    for (final card in cards) {
      final meaning = card.$3;
      final distractors = allMeanings.where((m) => m != meaning).toList()
        ..shuffle();
      final choices = [
        meaning,
        ...distractors.take(_distractorCount),
      ]..shuffle();
      questions.add(McQuestion(
        cardId: card.$1,
        prompt: card.$2,
        choices: choices,
        correctIndex: choices.indexOf(meaning),
      ));
    }
    return McState(
      questions: questions,
      index: 0,
      chosen: null,
      correctCount: 0,
    );
  }

  void answer(int choice) {
    final data = state.asData?.value;
    if (data == null || data.chosen != null || data.isComplete) return;
    final correct = choice == data.current.correctIndex;
    state = AsyncData(data.copyWith(
      chosen: () => choice,
      correctCount: correct ? data.correctCount + 1 : data.correctCount,
    ));
  }

  void next() {
    final data = state.asData?.value;
    if (data == null || data.chosen == null) return;
    state = AsyncData(data.copyWith(index: data.index + 1, chosen: () => null));
  }

  Future<void> playAudio() async {
    final data = state.asData?.value;
    if (data == null || data.isComplete) return;
    final result = await ref
        .read(audioServiceProvider)
        .speak(data.current.prompt, languageCode: _termSpeakLanguage);
    if (result case Err(:final failure)) {
      ref.read(loggerProvider).error('mc audio failed', error: failure);
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
