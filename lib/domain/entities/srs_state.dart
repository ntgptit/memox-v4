import 'package:equatable/equatable.dart';
import 'package:memox_v4/domain/entities/box_level.dart';

/// The scheduling state of a card (`SrsState`): its Leitner [box], the next due
/// time, and when it was last reviewed. One state per card — a single learning
/// direction (BR-6 / D-011).
///
/// `dueAt` is null exactly when the card is not on the schedule: a brand-new card
/// (box 0) or a mastered card (box 8, BR-5).
class SrsState extends Equatable {
  const SrsState({required this.box, this.dueAt, this.lastReviewedAt});

  /// A brand-new, unscheduled card (box 0).
  static const SrsState newborn = SrsState(box: BoxLevel.newCard);

  final BoxLevel box;
  final DateTime? dueAt;
  final DateTime? lastReviewedAt;

  bool get isScheduled => dueAt != null;

  /// Whether the card is due for review at [now] (a scheduled card whose due time
  /// has arrived). Hidden-card exclusion is a queue concern, not modeled here.
  bool isDue(DateTime now) {
    final due = dueAt;
    return due != null && !due.isAfter(now);
  }

  @override
  List<Object?> get props => [box, dueAt, lastReviewedAt];
}
