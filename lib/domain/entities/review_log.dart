import 'package:equatable/equatable.dart';
import 'package:memox_v4/domain/entities/ids.dart';
import 'package:memox_v4/domain/entities/review_grade.dart';

/// One review outcome for a card (`review_outcome`): the self-graded result of a
/// due-review at a point in time. Feeds review accuracy in statistics (BR-2).
class ReviewLog extends Equatable {
  const ReviewLog({
    required this.cardId,
    required this.grade,
    required this.reviewedAt,
  });

  final CardId cardId;
  final ReviewGrade grade;
  final DateTime reviewedAt;

  @override
  List<Object> get props => [cardId.value, grade, reviewedAt];
}
