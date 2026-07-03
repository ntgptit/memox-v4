import 'package:flutter/material.dart' hide Card;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:memox_v4/core/error/failure.dart';
import 'package:memox_v4/core/error/result.dart';
import 'package:memox_v4/core/theme/app_theme.dart';
import 'package:memox_v4/data/fakes/fake_services.dart';
import 'package:memox_v4/data/fakes/fake_store.dart';
import 'package:memox_v4/domain/entities/daily_goal.dart';
import 'package:memox_v4/domain/entities/ids.dart';
import 'package:memox_v4/domain/entities/study_mode.dart';
import 'package:memox_v4/domain/entities/study_session.dart';
import 'package:memox_v4/domain/services/daily_activity_service.dart';
import 'package:memox_v4/l10n/app_localizations.dart';
import 'package:memox_v4/presentation/features/study-result/providers/study_result_providers.dart';
import 'package:memox_v4/presentation/features/study-result/screens/study_result_screen.dart';
import 'package:memox_v4/presentation/features/study-result/widgets/result_hero.dart';
import 'package:memox_v4/presentation/features/study-result/widgets/streak_goal_card.dart';

import '../../../harness/provider_harness.dart';

/// Activity for the harness clock day (2026-07-03).
Future<FakeDailyActivityService> _activity({
  required int minutes,
  required int words,
}) async {
  final service = FakeDailyActivityService();
  await service.record(
    StudySession(
      id: const StudySessionId('s1'),
      deckId: const DeckId('d'),
      mode: StudyMode.newLearn,
      startedAt: DateTime.utc(2026, 7, 3, 9),
      durationMinutes: minutes,
      wordsStudied: words,
    ),
  );
  return service;
}

/// A daily-activity service whose reads fail — drives the finalize-error branch.
class _FailingActivityService implements DailyActivityService {
  @override
  Future<Result<void>> record(StudySession session) async =>
      const Ok<void>(null);

  @override
  Future<Result<({int minutes, int words})>> activityOn(DateTime day) async =>
      const Err(PersistenceFailure('boom'));

  @override
  Stream<Map<DateTime, ({int minutes, int words})>> watchHistory() =>
      const Stream.empty();
}

void main() {
  Future<void> pump(
    WidgetTester tester, {
    required bool dark,
    required FakeStore store,
    required DailyActivityService activity,
  }) async {
    tester.view.physicalSize = const Size(420, 2200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final harness = FakeHarness(store: store, activity: activity);
    await tester.pumpWidget(
      ProviderScope(
        overrides: harness.overrides,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: dark ? AppTheme.dark : AppTheme.light,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const StudyResultScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  FakeStore _store(DailyGoal goal) => FakeStore()..dailyGoal = goal;

  for (final dark in [false, true]) {
    final theme = dark ? 'dark' : 'light';

    testWidgets('goal met: celebration head + streak card ($theme)',
        (tester) async {
      await pump(
        tester,
        dark: dark,
        store: _store(const DailyGoal(minutesTarget: 15)),
        activity: await _activity(minutes: 20, words: 10),
      );
      expect(find.text('Daily goal reached!'), findsOneWidget);
      expect(find.byType(ResultHero), findsOneWidget);
      expect(find.byType(StreakGoalCard), findsOneWidget);
    });
  }

  testWidgets('goal missed: almost-there head', (tester) async {
    await pump(
      tester,
      dark: false,
      store: _store(const DailyGoal(minutesTarget: 15, wordsTarget: 20)),
      activity: await _activity(minutes: 5, words: 2),
    );
    expect(find.text('Almost there!'), findsOneWidget);
    expect(find.text('Keep going'), findsOneWidget);
    expect(find.text('Later'), findsOneWidget);
  });

  testWidgets('no goal set: standard head', (tester) async {
    await pump(
      tester,
      dark: false,
      store: _store(const DailyGoal()),
      activity: await _activity(minutes: 6, words: 4),
    );
    expect(find.text('Session complete'), findsOneWidget);
    expect(find.text('Keep studying'), findsOneWidget);
    expect(find.text('Back to library'), findsOneWidget);
  });

  testWidgets('a failed read shows the finalize-error surface', (tester) async {
    await pump(
      tester,
      dark: false,
      store: _store(const DailyGoal(minutesTarget: 15)),
      activity: _FailingActivityService(),
    );
    expect(find.byIcon(Icons.cloud_off), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
    expect(find.text('Not now'), findsOneWidget);
  });

  test('head is goal-met when the goal is reached, missed when configured but not',
      () async {
    final metHarness = FakeHarness(
      store: _store(const DailyGoal(minutesTarget: 15)),
      activity: await _activity(minutes: 30, words: 10),
    );
    final metContainer = ProviderContainer(overrides: metHarness.overrides);
    addTearDown(metContainer.dispose);
    final met = await metContainer.read(studyResultControllerProvider.future);
    expect(met.head, ResultHead.goalMet);
    expect(met.goalMet, isTrue);

    final missHarness = FakeHarness(
      store: _store(const DailyGoal(minutesTarget: 60)),
      activity: await _activity(minutes: 5, words: 1),
    );
    final missContainer = ProviderContainer(overrides: missHarness.overrides);
    addTearDown(missContainer.dispose);
    final miss = await missContainer.read(studyResultControllerProvider.future);
    expect(miss.head, ResultHead.goalMissed);
    expect(miss.goalMet, isFalse);
  });
}
