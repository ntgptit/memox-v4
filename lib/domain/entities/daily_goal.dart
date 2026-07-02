import 'package:equatable/equatable.dart';

/// The learner's daily goal (`DailyGoal`): a minutes target and/or a words target
/// (either may be unset). A day is "met" when **at least one** target is reached
/// (engagement BR-2, D-021).
class DailyGoal extends Equatable {
  const DailyGoal({this.minutesTarget, this.wordsTarget});

  /// Target minutes of study, or null if not set.
  final int? minutesTarget;

  /// Target words studied, or null if not set.
  final int? wordsTarget;

  /// Whether a set target exists at all.
  bool get isConfigured => minutesTarget != null || wordsTarget != null;

  /// The goal is met when at least one configured target is reached by the day's
  /// [minutes] and [words] of activity (BR-2). An unset target can never be the
  /// one that is met.
  bool isMetBy({required int minutes, required int words}) {
    final byMinutes = minutesTarget != null && minutes >= minutesTarget!;
    final byWords = wordsTarget != null && words >= wordsTarget!;
    return byMinutes || byWords;
  }

  @override
  List<Object?> get props => [minutesTarget, wordsTarget];
}
