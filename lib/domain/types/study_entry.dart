/// The five ways to open a node (`docs/business/study/study-flow.md`,
/// `docs/contracts/types-catalog.md`). Only `dueReview`/`newLearn` change the
/// schedule and count as activity (D-007, D-010).
enum StudyEntry { dueReview, newLearn, review, game, player }

extension StudyEntryX on StudyEntry {
  /// Whether this entry updates `srs_state` + `daily_activity` (D-007/D-010).
  bool get changesSchedule =>
      this == StudyEntry.dueReview || this == StudyEntry.newLearn;
}
