import 'package:memox_v4/app/di/clock_provider.dart';
import 'package:memox_v4/app/di/daily_activity_providers.dart';
import 'package:memox_v4/app/di/deck_providers.dart';
import 'package:memox_v4/app/di/settings_providers.dart';
import 'package:memox_v4/core/constants/settings_keys.dart';
import 'package:memox_v4/core/util/day_key.dart';
import 'package:memox_v4/domain/models/engagement_summary.dart';
import 'package:memox_v4/domain/types/daily_goal.dart';
import 'package:memox_v4/domain/types/result.dart';
import 'package:memox_v4/domain/types/streak.dart';
import 'package:memox_v4/domain/usecases/engagement/compute_streak.dart';
import 'package:memox_v4/presentation/features/language_pair/viewmodels/language_pair_notifier.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'engagement_notifier.g.dart';

/// Today dashboard state (kept alive). Composes daily activity (W4), the goal
/// (settings), the streak (D-021), and the library's due/mastered snapshot.
@Riverpod(keepAlive: true)
class EngagementNotifier extends _$EngagementNotifier {
  static const EngagementSummary _empty = EngagementSummary(
    seconds: 0,
    words: 0,
    goal: DailyGoal(),
    streak: Streak(0),
    dueCount: 0,
    masteredCount: 0,
    totalWords: 0,
  );

  @override
  Future<EngagementSummary> build() => _load();

  Future<void> refresh() async {
    state = await AsyncValue.guard(_load);
  }

  Future<EngagementSummary> _load() async {
    final pairId = ref.watch(languagePairProvider).value?.active?.id;
    if (pairId == null) return _empty;

    final now = ref.read(clockProvider).now();
    final daily = ref.read(dailyActivityRepositoryProvider);
    final today = (await daily.forDay(pairId, dayKey(now))).valueOrNull;
    final history = (await daily.allForPair(pairId)).valueOrNull ?? const [];
    final byDay = <String, DayActivity>{
      for (final a in history) a.day: (seconds: a.seconds, words: a.words),
    };

    final settings = ref.read(settingsRepositoryProvider);
    final minutes = (await settings.readInt(
      SettingsKeys.dailyGoalMinutes,
    )).valueOrNull;
    final words = (await settings.readInt(
      SettingsKeys.dailyGoalWords,
    )).valueOrNull;
    final goal = DailyGoal(minutes: minutes, words: words);
    final streak = const ComputeStreakUseCase().call(
      byDay: byDay,
      goal: goal,
      today: now,
    );

    final roots =
        (await ref.read(deckRepositoryProvider).libraryTree(pairId))
            .valueOrNull ??
        const [];
    var due = 0;
    var mastered = 0;
    var totalWords = 0;
    for (final root in roots) {
      due += root.stats.due;
      mastered += root.stats.mastered;
      totalWords += root.stats.words;
    }

    return EngagementSummary(
      seconds: today?.seconds ?? 0,
      words: today?.words ?? 0,
      goal: goal,
      streak: streak,
      dueCount: due,
      masteredCount: mastered,
      totalWords: totalWords,
    );
  }
}
