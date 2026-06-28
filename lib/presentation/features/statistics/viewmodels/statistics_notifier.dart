import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox_v4/app/di/clock_provider.dart';
import 'package:memox_v4/app/di/statistics_providers.dart';
import 'package:memox_v4/domain/models/statistics_summary.dart';
import 'package:memox_v4/domain/types/result.dart';
import 'package:memox_v4/domain/types/stats_scope.dart';
import 'package:memox_v4/domain/usecases/statistics/get_statistics.dart';
import 'package:memox_v4/presentation/features/language_pair/viewmodels/language_pair_notifier.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'statistics_notifier.g.dart';

/// The selected statistics scope (current pair vs whole app).
final statsScopeProvider = NotifierProvider<StatsScopeNotifier, StatsScope>(
  StatsScopeNotifier.new,
);

class StatsScopeNotifier extends Notifier<StatsScope> {
  @override
  StatsScope build() => StatsScope.currentPair;

  void set(StatsScope scope) => state = scope;
}

/// The statistics summary for a scope (autoDispose family — switching scope
/// discards the previous computation).
@riverpod
class Statistics extends _$Statistics {
  @override
  Future<StatisticsSummary> build(StatsScope scope) async {
    final pairId = scope == StatsScope.allApp
        ? null
        : ref.watch(languagePairNotifierProvider).value?.active?.id;
    if (scope == StatsScope.currentPair && pairId == null) {
      return StatisticsSummary.empty;
    }
    final useCase = GetStatisticsUseCase(
      ref.read(statisticsRepositoryProvider),
      ref.read(clockProvider),
    );
    final result = await useCase.call(pairId: pairId);
    return result.valueOrNull ?? StatisticsSummary.empty;
  }
}
