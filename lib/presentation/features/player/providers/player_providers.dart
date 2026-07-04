import 'dart:async';

import 'package:memox_v4/core/error/failure.dart';
import 'package:memox_v4/core/error/result.dart';
import 'package:memox_v4/core/logging/logger_provider.dart';
import 'package:memox_v4/data/providers/data_providers.dart';
import 'package:memox_v4/domain/entities/card.dart';
import 'package:memox_v4/domain/entities/ids.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'player_providers.g.dart';

/// Fixed term language for spoken playback (per-pair language deferred — gap).
const String _termSpeakLanguage = 'ko';

/// The playback-rate options (kit `player/speed-control`). The chosen rate is
/// passed to [AudioService.speak] on every read (audible once the real TTS
/// adapter ships; the current adapter is a no-op that accepts the rate).
const List<String> playerSpeeds = ['0.75', '1', '1.5'];

/// The default playback rate.
const String _defaultSpeed = '1';

/// Fallback rate if a speed string can't be parsed (should not happen — the
/// options are all valid doubles).
const double _fallbackRate = 1.0;

/// How many progress dots the deck indicator shows (kit `player/progress`).
const int playerDotCount = 8;

/// The player state — the card list (walked from the deck tree), the cursor,
/// whether playback is running, whether the speed control is expanded, and the
/// selected (session-only) rate. Past the last card the playthrough is over.
class PlayerState {
  const PlayerState({
    required this.cards,
    required this.index,
    required this.playing,
    required this.speedOpen,
    required this.speed,
  });

  final List<Card> cards;
  final int index;
  final bool playing;
  final bool speedOpen;
  final String speed;

  bool get isEmpty => cards.isEmpty;
  bool get isEnd => cards.isNotEmpty && index >= cards.length;
  int get total => cards.length;
  Card? get current => (index < 0 || index >= cards.length) ? null : cards[index];

  /// The active dot (0-based) across [playerDotCount] dots, mapped from the
  /// cursor position over the deck.
  int get activeDot {
    if (cards.length <= 1) return 0;
    final ratio = index / (cards.length - 1);
    return (ratio * (playerDotCount - 1)).round();
  }

  PlayerState copyWith({
    List<Card>? cards,
    int? index,
    bool? playing,
    bool? speedOpen,
    String? speed,
  }) {
    return PlayerState(
      cards: cards ?? this.cards,
      index: index ?? this.index,
      playing: playing ?? this.playing,
      speedOpen: speedOpen ?? this.speedOpen,
      speed: speed ?? this.speed,
    );
  }
}

/// Drives the auto-play reader: walks every card in the library (DM.5), reads the
/// term aloud via [AudioService] (DM.8), and steps through with transport
/// controls. An async notifier rendered with `AsyncValue.when`; failed loads
/// throw their [Failure] — surfaced localized by the screen + logged.
///
/// Note: automatic advance-on-speech-end is deferred to DT.7 (the fake TTS has no
/// completion event); v1 wires the manual transport + per-card speak, and
/// `playing` is the transport/visual state.
@riverpod
class PlayerController extends _$PlayerController {
  @override
  Future<PlayerState> build() async {
    try {
      final cards = await _loadCards();
      final state = PlayerState(
        cards: cards,
        index: 0,
        playing: cards.isNotEmpty,
        speedOpen: false,
        speed: _defaultSpeed,
      );
      final current = state.current;
      if (current != null) unawaited(_speak(current));
      return state;
    } on Failure catch (failure, stackTrace) {
      ref.read(loggerProvider).error(
            'player load failed',
            error: failure,
            stackTrace: stackTrace,
          );
      rethrow;
    }
  }

  void playPause() {
    final data = state.asData?.value;
    final current = data?.current;
    if (data == null || current == null) return;
    final playing = !data.playing;
    state = AsyncData(data.copyWith(playing: playing));
    if (playing) {
      unawaited(_speak(current));
      return;
    }
    unawaited(_stop());
  }

  void next() {
    final data = state.asData?.value;
    if (data == null || data.index >= data.cards.length) return;
    _moveTo(data, data.index + 1);
  }

  void prev() {
    final data = state.asData?.value;
    if (data == null || data.index <= 0) return;
    _moveTo(data, data.index - 1);
  }

  void _moveTo(PlayerState data, int index) {
    final ended = index >= data.cards.length;
    final moved = data.copyWith(
      index: index,
      playing: ended ? false : data.playing,
      speedOpen: false,
    );
    state = AsyncData(moved);
    final current = moved.current;
    if (!ended && moved.playing && current != null) {
      unawaited(_speak(current));
    }
  }

  void toggleSpeedControl() {
    final data = state.asData?.value;
    if (data == null) return;
    state = AsyncData(data.copyWith(speedOpen: !data.speedOpen));
  }

  void setSpeed(String value) {
    final data = state.asData?.value;
    if (data == null || !playerSpeeds.contains(value)) return;
    final next = data.copyWith(speed: value, speedOpen: false);
    state = AsyncData(next);
    // Re-read the current card at the new rate so the change is heard now.
    final current = next.current;
    if (next.playing && current != null) {
      unawaited(_speak(current));
    }
  }

  void replay() {
    final data = state.asData?.value;
    if (data == null || data.cards.isEmpty) return;
    final restarted =
        data.copyWith(index: 0, playing: true, speedOpen: false);
    state = AsyncData(restarted);
    final current = restarted.current;
    if (current != null) unawaited(_speak(current));
  }

  Future<void> _speak(Card card) async {
    final result = await ref.read(audioServiceProvider).speak(
          card.term,
          languageCode: _termSpeakLanguage,
          rate: _currentRate(),
        );
    if (result case Err(:final failure)) {
      ref.read(loggerProvider).error('player audio failed', error: failure);
    }
  }

  /// The active playback rate as a double (the selected speed option parsed).
  double _currentRate() {
    final speed = state.asData?.value.speed ?? _defaultSpeed;
    return double.tryParse(speed) ?? _fallbackRate;
  }

  Future<void> _stop() async {
    final result = await ref.read(audioServiceProvider).stop();
    if (result case Err(:final failure)) {
      ref.read(loggerProvider).error('player stop failed', error: failure);
    }
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
