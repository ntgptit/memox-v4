import 'package:memox_v4/data/datasources/local/drift/app_database.dart';

/// Append-only writes to `review_outcome` (accuracy stats, W9).
class ReviewOutcomeDao {
  const ReviewOutcomeDao(this._db);

  final AppDatabase _db;

  Future<void> record({
    required int cardId,
    required int pairId,
    required int ts,
    required bool correct,
    required String mode,
  }) => _db
      .into(_db.reviewOutcome)
      .insert(
        ReviewOutcomeCompanion.insert(
          cardId: cardId,
          pairId: pairId,
          ts: ts,
          correct: correct ? 1 : 0,
          mode: mode,
        ),
      );
}
