import 'package:flutter_test/flutter_test.dart';
import 'package:memox_v4/core/error/result.dart';
import 'package:memox_v4/domain/entities/box_level.dart';
import 'package:memox_v4/domain/entities/ids.dart';
import 'package:memox_v4/domain/entities/review_grade.dart';
import 'package:memox_v4/domain/entities/review_log.dart';
import 'package:memox_v4/domain/entities/srs_state.dart';
import 'package:memox_v4/domain/usecases/stats/review_stats.dart';
import 'package:memox_v4/domain/usecases/stats/srs_stats.dart';

BoxLevel _box(int v) => (BoxLevel.of(v) as Ok<BoxLevel>).value;

void main() {
  group('boxDistribution', () {
    test('counts cards per box 1..8, excluding new (box 0)', () {
      final dist = boxDistribution([
        SrsState(box: _box(1)),
        SrsState(box: _box(1)),
        SrsState(box: _box(3)),
        const SrsState(box: BoxLevel.mastered),
        SrsState.newborn, // box 0 — excluded
      ]);
      expect(dist.keys, {1, 2, 3, 4, 5, 6, 7, 8});
      expect(dist[1], 2);
      expect(dist[3], 1);
      expect(dist[8], 1);
      expect(dist[2], 0);
    });
  });

  group('dueForecast', () {
    test('buckets due cards by day over the window; ignores out-of-range', () {
      final from = DateTime.utc(2026, 7, 3, 9);
      final forecast = dueForecast(
        [
          SrsState(box: _box(1), dueAt: DateTime.utc(2026, 7, 3, 23)), // today
          SrsState(box: _box(2), dueAt: DateTime.utc(2026, 7, 5, 1)), // +2
          SrsState(box: _box(2), dueAt: DateTime.utc(2026, 7, 5, 20)), // +2
          SrsState(box: _box(3), dueAt: DateTime.utc(2026, 7, 20)), // out of range
          SrsState.newborn, // no due
        ],
        from: from,
        days: 7,
      );
      expect(forecast, [1, 0, 2, 0, 0, 0, 0]);
    });
  });

  group('reviewAccuracy', () {
    ReviewLog log(ReviewGrade grade) =>
        ReviewLog(cardId: const CardId('c'), grade: grade, reviewedAt: DateTime.utc(2026));

    test('is correct over total; 0 for an empty history', () {
      expect(reviewAccuracy(const []), 0);
      expect(
        reviewAccuracy([log(ReviewGrade.pass), log(ReviewGrade.pass), log(ReviewGrade.fail)]),
        closeTo(2 / 3, 1e-9),
      );
    });
  });
}
