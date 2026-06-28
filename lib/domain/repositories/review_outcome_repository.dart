import 'package:memox_v4/domain/types/result.dart';

/// Records per-grade outcomes used by accuracy statistics (W9).
abstract interface class ReviewOutcomeRepository {
  Future<Result<void>> record({
    required int cardId,
    required int pairId,
    required int ts,
    required bool correct,
    required String mode,
  });
}
