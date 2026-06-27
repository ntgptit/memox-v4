/// Daily goal: a target number of minutes and/or words. "Met" = at least one is
/// reached (BR-2 / D-021) — `docs/contracts/types-catalog.md`.
class DailyGoal {
  const DailyGoal({this.minutes, this.words});

  final int? minutes;
  final int? words;

  bool get hasGoal =>
      (minutes != null && minutes! > 0) || (words != null && words! > 0);

  /// Whether [seconds] studied or [words] learned reach either target.
  bool isMetBy(int seconds, int words) {
    final byMinutes =
        minutes != null && minutes! > 0 && seconds >= minutes! * 60;
    final byWords =
        this.words != null && this.words! > 0 && words >= this.words!;
    return byMinutes || byWords;
  }
}
