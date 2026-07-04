import 'package:memox_v4/core/error/failure.dart';
import 'package:memox_v4/core/error/result.dart';
import 'package:memox_v4/core/logging/logger_provider.dart';
import 'package:memox_v4/data/providers/data_providers.dart';
import 'package:memox_v4/domain/entities/card.dart';
import 'package:memox_v4/domain/entities/card_meaning.dart';
import 'package:memox_v4/domain/entities/ids.dart';
import 'package:memox_v4/domain/usecases/library/card_usecases.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'review_providers.g.dart';

/// Fixed term language for spoken prompts (per-pair language deferred — gap).
const String _termSpeakLanguage = 'ko';

/// The review browse state — the full card list (walked from the deck tree), the
/// cursor, and the transient inline-edit / audio-playing flags. When the cursor
/// runs past the last card the browse is over ([isEnd]).
class ReviewState {
  const ReviewState({
    required this.cards,
    required this.index,
    required this.editing,
    required this.playing,
  });

  final List<Card> cards;
  final int index;
  final bool editing;
  final bool playing;

  bool get isEmpty => cards.isEmpty;
  bool get isEnd => cards.isNotEmpty && index >= cards.length;
  int get total => cards.length;
  int get position => index + 1;
  double get progress => cards.isEmpty ? 0 : position / cards.length;
  Card? get current => (index < 0 || index >= cards.length) ? null : cards[index];

  ReviewState copyWith({
    List<Card>? cards,
    int? index,
    bool? editing,
    bool? playing,
  }) {
    return ReviewState(
      cards: cards ?? this.cards,
      index: index ?? this.index,
      editing: editing ?? this.editing,
      playing: playing ?? this.playing,
    );
  }
}

/// Drives the review browse: walks every card in the library (DM.5), steps
/// forward/back, plays the term audio, and edits the meaning inline (saved via
/// [SaveCardUseCase]). An async notifier rendered with `AsyncValue.when`; failed loads
/// throw their [Failure] — surfaced localized by the screen + logged.
@riverpod
class ReviewController extends _$ReviewController {
  @override
  Future<ReviewState> build() async {
    try {
      final cards = await _loadCards();
      return ReviewState(cards: cards, index: 0, editing: false, playing: false);
    } on Failure catch (failure, stackTrace) {
      ref.read(loggerProvider).error(
            'review load failed',
            error: failure,
            stackTrace: stackTrace,
          );
      rethrow;
    }
  }

  void next() {
    final data = state.asData?.value;
    if (data == null || data.index >= data.cards.length) return;
    state = AsyncData(
      data.copyWith(index: data.index + 1, editing: false, playing: false),
    );
  }

  void prev() {
    final data = state.asData?.value;
    if (data == null || data.index <= 0) return;
    state = AsyncData(
      data.copyWith(index: data.index - 1, editing: false, playing: false),
    );
  }

  void startEdit() {
    final data = state.asData?.value;
    if (data == null || data.current == null || data.editing) return;
    state = AsyncData(data.copyWith(editing: true));
  }

  void cancelEdit() {
    final data = state.asData?.value;
    if (data == null || !data.editing) return;
    state = AsyncData(data.copyWith(editing: false));
  }

  /// Persist an edited meaning for the current card. On failure the edit stays
  /// open (the draft is preserved) and the cause is logged.
  Future<void> saveEdit(String text) async {
    final data = state.asData?.value;
    final card = data?.current;
    if (data == null || card == null || !data.editing) return;

    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    final updated = _withPrimaryMeaning(card, trimmed);
    if (updated case Err(:final failure)) {
      ref.read(loggerProvider).error('review edit invalid', error: failure);
      return;
    }

    final saved = await SaveCardUseCase(ref.read(cardRepositoryProvider))
        .call((updated as Ok<Card>).value);
    if (saved case Err(:final failure)) {
      ref.read(loggerProvider).error('review edit save failed', error: failure);
      return;
    }

    final cards = [...data.cards];
    cards[data.index] = (saved as Ok<Card>).value;
    state = AsyncData(data.copyWith(cards: cards, editing: false));
  }

  Future<void> playAudio() async {
    final data = state.asData?.value;
    final card = data?.current;
    if (data == null || card == null || data.playing) return;

    state = AsyncData(data.copyWith(playing: true));
    final result = await ref
        .read(audioServiceProvider)
        .speak(card.term, languageCode: _termSpeakLanguage);
    if (result case Err(:final failure)) {
      ref.read(loggerProvider).error('review audio failed', error: failure);
    }
    final latest = state.asData?.value;
    if (latest != null) state = AsyncData(latest.copyWith(playing: false));
  }

  Result<Card> _withPrimaryMeaning(Card card, String text) {
    final first = card.meanings.first;
    final meaning = CardMeaning.create(
      id: first.id,
      language: first.language,
      text: text,
    );
    if (meaning case Err(:final failure)) return Err(failure);
    return Card.create(
      id: card.id,
      deckId: card.deckId,
      term: card.term,
      meanings: [(meaning as Ok<CardMeaning>).value, ...card.meanings.skip(1)],
      hidden: card.hidden,
      audioRef: card.audioRef,
      grammaticalGender: card.grammaticalGender,
    );
  }

  Future<List<Card>> _loadCards() async {
    final decks = ref.watch(deckRepositoryProvider);
    final cardsRepo = ref.watch(cardRepositoryProvider);

    final out = <Card>[];
    final queue = <DeckId>[
      for (final deck in await decks.watchChildren(null).first) deck.id,
    ];
    final visited = <String>{};
    while (queue.isNotEmpty) {
      final id = queue.removeLast();
      if (!visited.add(id.value)) continue;
      for (final card in await cardsRepo.watchByDeck(id).first) {
        if (card.hidden || card.meanings.isEmpty) continue;
        out.add(card);
      }
      for (final child in await decks.watchChildren(id).first) {
        queue.add(child.id);
      }
    }
    return out;
  }
}
