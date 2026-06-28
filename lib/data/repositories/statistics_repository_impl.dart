import 'package:memox_v4/core/error/failure.dart';
import 'package:memox_v4/data/datasources/local/daos/stats_dao.dart';
import 'package:memox_v4/domain/models/statistics_summary.dart';
import 'package:memox_v4/domain/repositories/statistics_repository.dart';
import 'package:memox_v4/domain/types/result.dart';

/// Drift-backed [StatisticsRepository].
class StatisticsRepositoryImpl implements StatisticsRepository {
  const StatisticsRepositoryImpl(this._dao);

  final StatsDao _dao;

  @override
  Future<Result<StatsRaw>> read(
    int? pairId, {
    required String activitySince,
  }) async {
    try {
      return Ok(await _dao.read(pairId, activitySince: activitySince));
    } catch (e) {
      return Err(PersistenceFailure(message: 'read statistics', cause: e));
    }
  }
}
