import 'package:equatable/equatable.dart';

/// Consecutive days meeting the daily goal (`Streak`), plus the longest run ever
/// reached (shown on the dashboard). A met day advances the streak; a missed day
/// resets the current run to zero (engagement BR-3, D-021).
class Streak extends Equatable {
  const Streak({required this.current, required this.longest})
      : assert(current >= 0, 'current must be >= 0'),
        assert(longest >= current, 'longest must be >= current');

  static const Streak zero = Streak(current: 0, longest: 0);

  final int current;
  final int longest;

  /// A day the goal was met: current +1, extending [longest] if it sets a record.
  Streak advanced() {
    final next = current + 1;
    return Streak(current: next, longest: next > longest ? next : longest);
  }

  /// A day the goal was missed: the current run resets, the record is kept.
  Streak reset() => Streak(current: 0, longest: longest);

  @override
  List<Object> get props => [current, longest];
}
