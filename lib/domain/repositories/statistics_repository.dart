import 'package:memox_v4/domain/models/statistics_summary.dart';
import 'package:memox_v4/domain/types/result.dart';

/// Reads raw statistics aggregates. The day-bucketing (forecast/heatmap) is done
/// in the use case so it can use the injected clock.
abstract interface class StatisticsRepository {
  /// Aggregates for [pairId] (null → whole app).
  Future<Result<StatsRaw>> read(int? pairId);
}
