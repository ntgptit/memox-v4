import 'package:memox_v4/domain/entities/box_level.dart';
import 'package:memox_v4/domain/entities/srs_state.dart';

/// Pure statistics over SRS state (`docs/business/statistics/statistics.md`).

/// Cards per Leitner box 1..8 (the mastery distribution). New (box 0) cards are
/// not yet on the ladder and are excluded. Every box 1..8 is present (0 when
/// empty) so the chart has a stable set of bars.
Map<int, int> boxDistribution(Iterable<SrsState> states) {
  final counts = <int, int>{
    for (var box = BoxLevel.firstScheduled; box <= BoxLevel.max; box++) box: 0,
  };
  for (final state in states) {
    final box = state.box.value;
    if (box < BoxLevel.firstScheduled) continue;
    counts[box] = counts[box]! + 1;
  }
  return counts;
}

/// How many cards fall due on each of the next [days] days starting at [from]
/// (the due forecast). Bucketed by calendar day, machine time (BR-3). Cards with
/// no due date (new / mastered) and due dates outside the window are ignored.
List<int> dueForecast(
  Iterable<SrsState> states, {
  required DateTime from,
  required int days,
}) {
  final start = _calendarDay(from);
  final buckets = List<int>.filled(days, 0);
  for (final state in states) {
    final due = state.dueAt;
    if (due == null) continue;
    final offset = _calendarDay(due).difference(start).inDays;
    if (offset < 0 || offset >= days) continue;
    buckets[offset]++;
  }
  return buckets;
}

DateTime _calendarDay(DateTime dt) => DateTime.utc(dt.year, dt.month, dt.day);
