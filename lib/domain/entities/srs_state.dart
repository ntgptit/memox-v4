import 'package:memox_v4/domain/types/last_result.dart';

/// The single-direction review schedule for one card (one row per card — D-011).
/// `box` 0 = new/unscheduled, 1..7 carry [dueAt], 8 = mastered (no [dueAt]).
/// Mirrors `srs_state` (`docs/database/schema-contract.md`).
class SrsState {
  const SrsState({
    required this.cardId,
    required this.box,
    this.dueAt,
    this.lastResult,
    this.reviewedAt,
  });

  final int cardId;
  final int box;

  /// Next review instant (epoch ms), or null when not scheduled.
  final int? dueAt;

  /// Most recent grade, or null before the first review.
  final LastResult? lastResult;

  /// Most recent review instant (epoch ms).
  final int? reviewedAt;
}
