import 'package:memox_v4/domain/entities/review_grade.dart';
import 'package:memox_v4/domain/entities/review_log.dart';

/// Review accuracy — the share of correct answers over review outcomes. v1 counts
/// **only** DueReview grades, and those are exactly the [ReviewLog]s the app
/// records (NewLearn / games never produce a review log), so every log counts
/// (statistics §5 accuracy). Returns 0 when there is no history.
double reviewAccuracy(Iterable<ReviewLog> logs) {
  var total = 0;
  var correct = 0;
  for (final log in logs) {
    total++;
    if (log.grade == ReviewGrade.pass) correct++;
  }
  if (total == 0) return 0;
  return correct / total;
}
