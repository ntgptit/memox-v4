import 'package:memox_v4/domain/types/study_entry.dart';

/// The Play menu for a node: the due/new counts plus the entries to offer.
/// "Lặp lại" (dueReview) appears only when due > 0 (D-001/D-016); "Học"
/// (newLearn) only when there are new cards.
class PlayMenu {
  const PlayMenu({required this.dueCount, required this.newCount});

  final int dueCount;
  final int newCount;

  bool get hasDue => dueCount > 0;
  bool get hasNew => newCount > 0;

  List<StudyEntry> get entries => <StudyEntry>[
    if (hasDue) StudyEntry.dueReview,
    if (hasNew) StudyEntry.newLearn,
    StudyEntry.review,
    StudyEntry.game,
    StudyEntry.player,
  ];
}
