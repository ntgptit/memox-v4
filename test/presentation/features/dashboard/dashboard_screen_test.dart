import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

import 'package:memox_v4/core/error/failure.dart';
import 'package:memox_v4/core/error/result.dart';
import 'package:memox_v4/core/logging/app_logger.dart';
import 'package:memox_v4/core/logging/logger_provider.dart';
import 'package:memox_v4/core/theme/app_theme.dart';
import 'package:memox_v4/data/fakes/fake_services.dart';
import 'package:memox_v4/domain/entities/ids.dart';
import 'package:memox_v4/domain/entities/study_mode.dart';
import 'package:memox_v4/domain/entities/study_session.dart';
import 'package:memox_v4/domain/services/daily_activity_service.dart';
import 'package:memox_v4/l10n/app_localizations.dart';
import 'package:memox_v4/presentation/features/dashboard/screens/dashboard_screen.dart';
import 'package:memox_v4/presentation/features/dashboard/widgets/continue_deck_card.dart';
import 'package:memox_v4/presentation/features/dashboard/widgets/goal_card.dart';
import 'package:memox_v4/presentation/features/dashboard/widgets/today_summary.dart';
import 'package:memox_v4/presentation/shared/composites/mx_action_callout.dart';
import 'package:memox_v4/presentation/shared/composites/mx_fab.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_button.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_skeleton.dart';

import '../../../harness/provider_harness.dart';

// Clock is fixed at 2026-07-03 09:00Z by the harness → these are "today".
final _today = DateTime.utc(2026, 7, 3, 9);
DateTime _daysAgo(int n) => _today.subtract(Duration(days: n));

void main() {
  Future<void> pump(
    WidgetTester tester, {
    required bool dark,
    DailyActivityService? activity,
    List<Override> extra = const [],
    bool settle = true,
  }) async {
    tester.view.physicalSize = const Size(400, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final harness = FakeHarness(activity: activity);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [...harness.overrides, ...extra],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: dark ? AppTheme.dark : AppTheme.light,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const DashboardScreen(),
        ),
      ),
    );
    if (settle) await tester.pumpAndSettle();
  }

  for (final dark in [false, true]) {
    final theme = dark ? 'dark' : 'light';

    testWidgets('empty: no activity today → start CTA, no goal/decks ($theme)',
        (tester) async {
      // Default fake activity service is empty → 0 minutes / 0 words today.
      await pump(tester, dark: dark);

      expect(find.byType(TodaySummary), findsOneWidget);
      expect(
        find.text("You haven't studied today — start to keep your streak!"),
        findsOneWidget,
      );
      expect(find.text('Start studying'), findsOneWidget);
      // Empty hides the rest of the dashboard.
      expect(find.byType(GoalCard), findsNothing);
      expect(find.byType(ContinueDeckCard), findsNothing);
      expect(find.byType(MxFab), findsNothing);
    });

    testWidgets('loaded: activity + live streak → full layout, no banner ($theme)',
        (tester) async {
      final svc = await _seedActivity(
        today: (minutes: 5, words: 3), // studied, but goal not met
        past: {1: 20, 2: 20}, // met yesterday + the day before → streak alive
      );
      await pump(tester, dark: dark, activity: svc);

      expect(find.byType(GoalCard), findsOneWidget);
      expect(find.byType(ContinueDeckCard), findsOneWidget); // one due deck seeded
      expect(find.text('Continue studying'), findsOneWidget);
      expect(find.byType(MxFab), findsOneWidget);
      // The plain loaded state shows no banner.
      expect(find.byType(MxActionCallout), findsNothing);
    });

    testWidgets('goal-met: goal reached → celebration banner + complete ($theme)',
        (tester) async {
      final svc = await _seedActivity(today: (minutes: 20, words: 0));
      await pump(tester, dark: dark, activity: svc);

      expect(find.text('Daily goal reached! Streak +1.'), findsOneWidget);
      expect(find.byType(GoalCard), findsOneWidget);
      expect(find.textContaining('complete'), findsOneWidget);
      expect(find.byType(MxFab), findsOneWidget);
    });

    testWidgets('streak-reset: activity but broken streak → warning banner ($theme)',
        (tester) async {
      // Studied a little today (not empty), nothing met recently → current == 0.
      final svc = await _seedActivity(today: (minutes: 5, words: 0));
      await pump(tester, dark: dark, activity: svc);

      expect(
        find.text('Streak reset — study today to start again.'),
        findsOneWidget,
      );
      expect(find.byType(GoalCard), findsOneWidget);
    });

    testWidgets('loading: unresolved read shows skeletons ($theme)',
        (tester) async {
      await pump(
        tester,
        dark: dark,
        activity: _StuckActivityService(),
        settle: false,
      );
      await tester.pump(); // one frame — still loading

      expect(find.byType(MxSkeleton), findsWidgets);
      expect(find.byType(TodaySummary), findsNothing);
    });

    testWidgets('error: failed read → localized surface + logged cause ($theme)',
        (tester) async {
      final logger = _RecordingLogger();
      await pump(
        tester,
        dark: dark,
        activity: _ErroringActivityService(),
        extra: [loggerProvider.overrideWithValue(logger)],
      );

      expect(find.text("Couldn't load your dashboard"), findsOneWidget);
      expect(find.text('Try again'), findsOneWidget);
      expect(find.byType(MxButton), findsWidgets);
      // Dev side of the error contract: the cause was logged, not swallowed.
      expect(logger.errors, isNotEmpty);
    });
  }

  testWidgets('retry re-runs the load after an error clears', (tester) async {
    final svc = _RecoveringActivityService();
    await pump(tester, dark: false, activity: svc);

    expect(find.text("Couldn't load your dashboard"), findsOneWidget);

    svc.recovered = true;
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();

    expect(find.text("Couldn't load your dashboard"), findsNothing);
    expect(find.byType(TodaySummary), findsOneWidget);
  });
}

/// Builds a fake activity service preloaded with a day's activity via [record].
Future<FakeDailyActivityService> _seedActivity({
  ({int minutes, int words})? today,
  Map<int, int> past = const {}, // daysAgo → minutes
}) async {
  final svc = FakeDailyActivityService();
  var seq = 0;
  Future<void> rec(DateTime started, int minutes, int words) => svc.record(
        StudySession(
          id: StudySessionId('s-${seq++}'),
          deckId: const DeckId('deck-root'),
          mode: StudyMode.dueReview,
          startedAt: started,
          durationMinutes: minutes,
          wordsStudied: words,
        ),
      );

  for (final entry in past.entries) {
    await rec(_daysAgo(entry.key), entry.value, 0);
  }
  if (today != null) {
    await rec(_today, today.minutes, today.words);
  }
  return svc;
}

/// Never resolves [activityOn] → the provider stays in its loading state.
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

/// Fails [activityOn] → the provider surfaces an error.
class _ErroringActivityService implements DailyActivityService {
  @override
  Future<Result<({int minutes, int words})>> activityOn(DateTime day) async =>
      const Err(PersistenceFailure('activity read failed'));
  @override
  Future<Result<void>> record(StudySession session) async => const Ok(null);
  @override
  Stream<Map<DateTime, ({int minutes, int words})>> watchHistory() =>
      Stream.value(const {});
}

/// Fails until [recovered] is set — for the retry path.
class _RecoveringActivityService implements DailyActivityService {
  bool recovered = false;
  @override
  Future<Result<({int minutes, int words})>> activityOn(DateTime day) async =>
      recovered
          ? const Ok((minutes: 0, words: 0))
          : const Err(PersistenceFailure('activity read failed'));
  @override
  Future<Result<void>> record(StudySession session) async => const Ok(null);
  @override
  Stream<Map<DateTime, ({int minutes, int words})>> watchHistory() =>
      Stream.value(const {});
}

class _RecordingLogger implements AppLogger {
  final List<String> errors = [];
  @override
  void debug(String message) {}
  @override
  void info(String message) {}
  @override
  void warn(String message, {Object? error, StackTrace? stackTrace}) {}
  @override
  void error(String message, {Object? error, StackTrace? stackTrace}) =>
      errors.add(message);
}
