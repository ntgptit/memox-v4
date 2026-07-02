import 'package:equatable/equatable.dart';
import 'package:memox_v4/domain/entities/ids.dart';
import 'package:memox_v4/domain/entities/study_mode.dart';

/// A completed unit of scheduled study ("Lặp lại"/"Học") over a deck subtree. Its
/// minutes and word count feed the day's activity (engagement BR-1). Practice
/// modes do not produce sessions.
class StudySession extends Equatable {
  const StudySession({
    required this.id,
    required this.deckId,
    required this.mode,
    required this.startedAt,
    required this.durationMinutes,
    required this.wordsStudied,
  });

  final StudySessionId id;

  /// The node studied (a parent node covers its subtree recursively, BR-6).
  final DeckId deckId;
  final StudyMode mode;
  final DateTime startedAt;
  final int durationMinutes;
  final int wordsStudied;

  @override
  List<Object> get props => [
        id.value,
        deckId.value,
        mode,
        startedAt,
        durationMinutes,
        wordsStudied,
      ];
}
