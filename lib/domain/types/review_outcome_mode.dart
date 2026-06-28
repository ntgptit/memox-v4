/// Stored `review_outcome.mode` values (W9, `docs/database/schema-contract.md`).
/// v1 records only [dueReview]; [newLearn] is reserved for a future version.
abstract final class ReviewOutcomeMode {
  const ReviewOutcomeMode._();

  static const String dueReview = 'dueReview';
  static const String newLearn = 'newLearn';
}
