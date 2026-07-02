/// The two scheduled study activities that create a counting [StudySession] and
/// change the SRS schedule / daily activity (study-flow BR-5). Practice modes
/// (games, review browse, player) do not create sessions and are not modeled here.
enum StudyMode {
  /// "Lặp lại" — reviewing due cards (grades the SRS box).
  dueReview,

  /// "Học" — the 5-stage new-card learning flow.
  newLearn,
}
