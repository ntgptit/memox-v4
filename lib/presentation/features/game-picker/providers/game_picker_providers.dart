import 'package:memox_v4/core/error/failure.dart';
import 'package:memox_v4/core/error/result.dart';
import 'package:memox_v4/core/logging/logger_provider.dart';
import 'package:memox_v4/data/providers/data_providers.dart';
import 'package:memox_v4/domain/entities/deck_stats.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'game_picker_providers.g.dart';

/// Minimum words a source needs before a game can start (kit "at least 4 words").
const int gameMinWords = 4;

/// A large cap for counting unlearned cards.
const int _unlearnedCountCap = 9999;

/// Which cards a game draws from (kit `ScopeSheet`).
enum GameSource { schedule, all, unlearned }

/// The game-picker view-model.
class GamePickerData {
  const GamePickerData({
    required this.source,
    required this.wordCount,
    required this.wordsPerRound,
  });

  final GameSource source;

  /// How many cards the selected source yields.
  final int wordCount;

  /// Words per game round (D-008).
  final int wordsPerRound;

  /// A game needs at least [gameMinWords] words.
  bool get canPlay => wordCount >= gameMinWords;
}

/// Assembles the game-picker state — the selected card source, its word count,
/// and the words-per-round setting (DM.5 queues + DM.8 settings). An async
/// notifier rendered with `AsyncValue.when`. Failed reads throw their [Failure] —
/// surfaced localized by the screen and logged; never swallowed.
@riverpod
class GamePickerController extends _$GamePickerController {
  GameSource _source = GameSource.schedule;

  @override
  Future<GamePickerData> build() async {
    try {
      return await _load(_source);
    } on Failure catch (failure, stackTrace) {
      ref.read(loggerProvider).error(
            'game picker load failed',
            error: failure,
            stackTrace: stackTrace,
          );
      rethrow;
    }
  }

  Future<void> setSource(GameSource source) async {
    _source = source;
    ref.invalidateSelf();
  }

  Future<GamePickerData> _load(GameSource source) async {
    final settings = ref.watch(settingsServiceProvider);
    final wordsPerRound = await settings.watchGameWordsPerRound().first;
    final wordCount = await _countFor(source);
    return GamePickerData(
      source: source,
      wordCount: wordCount,
      wordsPerRound: wordsPerRound,
    );
  }

  Future<int> _countFor(GameSource source) async {
    final reviews = ref.watch(reviewRepositoryProvider);
    final now = ref.watch(clockProvider).now();
    return switch (source) {
      GameSource.schedule =>
        _value(await reviews.dueQueue(asOf: now)).length,
      GameSource.unlearned =>
        _value(await reviews.newQueue(limit: _unlearnedCountCap)).length,
      GameSource.all => await _totalVisible(),
    };
  }

  Future<int> _totalVisible() async {
    final decks = ref.watch(deckRepositoryProvider);
    final roots = await decks.watchChildren(null).first;
    var aggregate = DeckStats.empty;
    for (final deck in roots) {
      aggregate = aggregate + _value(await decks.statsFor(deck.id));
    }
    return aggregate.visibleCount;
  }

  T _value<T>(Result<T> result) => switch (result) {
        Ok<T>(:final value) => value,
        // ignore: only_throw_errors
        Err<T>(:final failure) => throw failure,
      };
}
