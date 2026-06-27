import 'package:memox_v4/core/error/failure.dart';
import 'package:memox_v4/data/datasources/local/daos/daily_activity_dao.dart';
import 'package:memox_v4/data/mappers/daily_activity_mapper.dart';
import 'package:memox_v4/domain/entities/daily_activity.dart';
import 'package:memox_v4/domain/repositories/daily_activity_repository.dart';
import 'package:memox_v4/domain/types/result.dart';

/// Drift-backed [DailyActivityRepository].
class DailyActivityRepositoryImpl implements DailyActivityRepository {
  const DailyActivityRepositoryImpl(this._dao);

  final DailyActivityDao _dao;

  @override
  Future<Result<void>> add({
    required int pairId,
    required String day,
    required int seconds,
    required int words,
  }) async {
    try {
      await _dao.add(pairId: pairId, day: day, seconds: seconds, words: words);
      return const Ok<void>(null);
    } catch (e) {
      return Err(PersistenceFailure(message: 'add daily activity', cause: e));
    }
  }

  @override
  Future<Result<DailyActivity?>> forDay(int pairId, String day) async {
    try {
      final row = await _dao.forDay(pairId, day);
      return Ok(row == null ? null : mapDailyActivity(row));
    } catch (e) {
      return Err(PersistenceFailure(message: 'read daily activity', cause: e));
    }
  }

  @override
  Future<Result<List<DailyActivity>>> allForPair(int pairId) async {
    try {
      final rows = await _dao.allForPair(pairId);
      return Ok(rows.map(mapDailyActivity).toList(growable: false));
    } catch (e) {
      return Err(PersistenceFailure(message: 'list daily activity', cause: e));
    }
  }
}
