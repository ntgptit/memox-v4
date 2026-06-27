import 'package:memox_v4/core/error/failure.dart';
import 'package:memox_v4/data/datasources/local/daos/srs_dao.dart';
import 'package:memox_v4/data/mappers/srs_state_mapper.dart';
import 'package:memox_v4/domain/entities/srs_state.dart';
import 'package:memox_v4/domain/models/card_schedule_info.dart';
import 'package:memox_v4/domain/repositories/srs_repository.dart';
import 'package:memox_v4/domain/types/result.dart';

/// Drift-backed [SrsRepository]. Maps storage errors to [PersistenceFailure] at
/// this boundary (`docs/contracts/error-contract.md`).
class SrsRepositoryImpl implements SrsRepository {
  const SrsRepositoryImpl(this._dao);

  final SrsDao _dao;

  @override
  Future<Result<SrsState?>> stateFor(int cardId) async {
    try {
      final row = await _dao.stateFor(cardId);
      return Ok(row == null ? null : mapSrsState(row));
    } catch (e) {
      return Err(PersistenceFailure(message: 'read srs state', cause: e));
    }
  }

  @override
  Future<Result<void>> upsert(SrsState state) async {
    try {
      await _dao.upsert(
        cardId: state.cardId,
        box: state.box,
        dueAt: state.dueAt,
        lastResult: state.lastResult?.storageValue,
        reviewedAt: state.reviewedAt,
      );
      return const Ok<void>(null);
    } catch (e) {
      return Err(PersistenceFailure(message: 'upsert srs state', cause: e));
    }
  }

  @override
  Future<Result<List<CardScheduleInfo>>> scheduleInfo(List<int> cardIds) async {
    try {
      final rows = await _dao.scheduleRows(cardIds);
      return Ok(
        rows
            .map(
              (r) => CardScheduleInfo(
                cardId: r.cardId,
                hidden: r.hidden,
                box: r.box,
                dueAt: r.dueAt,
              ),
            )
            .toList(growable: false),
      );
    } catch (e) {
      return Err(PersistenceFailure(message: 'schedule info', cause: e));
    }
  }
}
