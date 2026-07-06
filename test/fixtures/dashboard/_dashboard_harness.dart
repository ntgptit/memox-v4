import 'dart:async';

import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:memox_v4/core/error/result.dart';
import 'package:memox_v4/data/fakes/fake_services.dart';
import 'package:memox_v4/data/fakes/fake_store.dart';
import 'package:memox_v4/domain/entities/ids.dart';
import 'package:memox_v4/domain/entities/study_mode.dart';
import 'package:memox_v4/domain/entities/study_session.dart';
import 'package:memox_v4/domain/services/daily_activity_service.dart';

import '../../harness/provider_harness.dart';

// Shared seeds for the dashboard golden fixtures. NOT a *_fixture.dart file, so
// the scaffolder ignores it. Each seed builds a COMPLETE override list (via
// FakeHarness) that the golden harness applies directly.
//
// The clock is fixed at the FakeHarness default (2026-07-03 09:00Z), so "today"
// and "N days ago" line up with the seeded activity.
final DateTime _today = DateTime.utc(2026, 7, 3, 9);

StudySession _session(DateTime started, int minutes, int words, int seq) =>
    StudySession(
      id: StudySessionId('golden-s-$seq'),
      deckId: const DeckId('deck-root'),
      mode: StudyMode.dueReview,
      startedAt: started,
      durationMinutes: minutes,
      wordsStudied: words,
    );

/// A [FakeDailyActivityService] pre-seeded with today's activity and past days
/// (daysAgo → minutes). `record` mutates synchronously, so no await is needed.
FakeDailyActivityService dashboardActivity({
  ({int minutes, int words})? today,
  Map<int, int> past = const {},
}) {
  final svc = FakeDailyActivityService();
  var seq = 0;
  past.forEach((daysAgo, minutes) {
    svc.record(
      _session(_today.subtract(Duration(days: daysAgo)), minutes, 0, seq++),
    );
  });
  if (today != null) {
    svc.record(_session(_today, today.minutes, today.words, seq++));
  }
  return svc;
}

/// empty — the library has no decks (first-run onboarding).
List<Override> dashboardEmptyOverrides() =>
    FakeHarness(store: FakeStore()).overrides;

/// The seeded store (Korean Basics · Food, one due card) with a custom activity.
List<Override> dashboardSeededOverrides(DailyActivityService activity) =>
    FakeHarness(activity: activity).overrides;

/// loading — activity never resolves, so the controller stays in loading.
List<Override> dashboardLoadingOverrides() =>
    FakeHarness(activity: _StuckActivityService()).overrides;

class _StuckActivityService implements DailyActivityService {
  @override
  Future<Result<({int minutes, int words})>> activityOn(DateTime day) =>
      Completer<Result<({int minutes, int words})>>().future;
  @override
  Future<Result<void>> record(StudySession session) async => const Ok(null);
  @override
  Stream<Map<DateTime, ({int minutes, int words})>> watchHistory() =>
      Stream.value(const {});
}
