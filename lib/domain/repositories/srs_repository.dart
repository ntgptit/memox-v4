import 'package:memox_v4/domain/entities/srs_state.dart';
import 'package:memox_v4/domain/models/card_schedule_info.dart';
import 'package:memox_v4/domain/types/result.dart';

/// Persists the per-card review schedule (`srs_state`, one row per card — D-011)
/// and reads the schedule joined with cards for queue building. Errors map to
/// [Failure] at the boundary; no state lives only in memory.
abstract interface class SrsRepository {
  /// The schedule for a card, or null if it has never been scheduled (new).
  Future<Result<SrsState?>> stateFor(int cardId);

  /// Inserts or replaces a card's schedule (keyed by `card_id`).
  Future<Result<void>> upsert(SrsState state);

  /// Schedule info (hidden flag + box/due) for the given cards — the input to
  /// the due/new queue use cases. Cards without a schedule row are reported with
  /// a null box (new).
  Future<Result<List<CardScheduleInfo>>> scheduleInfo(List<int> cardIds);
}
