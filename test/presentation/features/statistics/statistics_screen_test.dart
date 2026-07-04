import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:memox_v4/core/error/failure.dart';
import 'package:memox_v4/core/error/result.dart';
import 'package:memox_v4/core/theme/app_theme.dart';
import 'package:memox_v4/data/fakes/fake_services.dart';
import 'package:memox_v4/domain/entities/deck.dart';
import 'package:memox_v4/domain/entities/deck_stats.dart';
import 'package:memox_v4/domain/entities/ids.dart';
import 'package:memox_v4/domain/entities/study_mode.dart';
import 'package:memox_v4/domain/entities/study_session.dart';
import 'package:memox_v4/domain/repositories/deck_repository.dart';
import 'package:memox_v4/l10n/app_localizations.dart';
import 'package:memox_v4/presentation/features/statistics/screens/statistics_screen.dart';
import 'package:memox_v4/presentation/features/statistics/widgets/bars.dart';
import 'package:memox_v4/presentation/features/statistics/widgets/donut.dart';
import 'package:memox_v4/presentation/features/statistics/widgets/heatmap.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_skeleton.dart';

import '../../../harness/provider_harness.dart';

final _today = DateTime.utc(2026, 7, 3, 9);

void main() {
  Future<void> pump(
    WidgetTester tester, {
    required bool dark,
    FakeDailyActivityService? activity,
    DeckRepository? deckRepository,
    bool settle = true,
  }) async {
    tester.view.physicalSize = const Size(400, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final harness = FakeHarness(
      activity: activity,
      deckRepository: deckRepository,
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: harness.overrides,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: dark ? AppTheme.dark : AppTheme.light,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const StatisticsScreen(),
        ),
      ),
    );
    if (settle) await tester.pumpAndSettle();
  }

  for (final dark in [false, true]) {
    final theme = dark ? 'dark' : 'light';

    testWidgets('insufficient: no study activity yet ($theme)', (tester) async {
      await pump(tester, dark: dark); // default fake activity is empty
      expect(find.text('Not enough data'), findsOneWidget);
      expect(find.byType(StatBars), findsNothing);
    });

    testWidgets('loaded: charts render once there is activity ($theme)', (
      tester,
    ) async {
      await pump(tester, dark: dark, activity: await _seededActivity());

      expect(find.byType(Heatmap), findsOneWidget);
      expect(find.byType(StatBars), findsNWidgets(2)); // weekly + Leitner
      expect(find.byType(Donut), findsOneWidget);
      expect(find.text('Study calendar'), findsOneWidget);
      expect(find.text('Library overview'), findsOneWidget);
    });
  }

  testWidgets('loading: unresolved read shows skeletons', (tester) async {
    await pump(
      tester,
      dark: false,
      activity: await _seededActivity(),
      deckRepository: _StuckDeckRepository(),
      settle: false,
    );
    await tester.pump();

    expect(find.byType(MxSkeleton), findsWidgets);
    expect(find.byType(Heatmap), findsNothing);
  });

  testWidgets('error: a failed read surfaces the error state', (tester) async {
    await pump(
      tester,
      dark: false,
      activity: await _seededActivity(),
      deckRepository: _ErroringDeckRepository(),
    );

    expect(find.text("Couldn't load stats"), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);
  });
}

Future<FakeDailyActivityService> _seededActivity() async {
  final svc = FakeDailyActivityService();
  var seq = 0;
  Future<void> rec(DateTime day, int minutes) => svc.record(
    StudySession(
      id: StudySessionId('s-${seq++}'),
      deckId: const DeckId('deck-root'),
      mode: StudyMode.dueReview,
      startedAt: day,
      durationMinutes: minutes,
      wordsStudied: minutes,
    ),
  );
  for (var i = 0; i < 5; i++) {
    await rec(_today.subtract(Duration(days: i)), 10 + i * 3);
  }
  return svc;
}

/// Never completes its tree stream → the provider stays loading.
class _StuckDeckRepository implements DeckRepository {
  @override
  Stream<List<Deck>> watchChildren(DeckId? parentId) =>
      Stream.fromFuture(Completer<List<Deck>>().future);
  @override
  Future<Result<Deck>> getById(DeckId id) => throw UnimplementedError();
  @override
  Future<Result<DeckStats>> statsFor(DeckId id) => throw UnimplementedError();
  @override
  Future<Result<Deck>> save(Deck deck) => throw UnimplementedError();
  @override
  Future<Result<void>> delete(DeckId id) => throw UnimplementedError();
}

/// Errors its tree stream → the provider surfaces an error.
class _ErroringDeckRepository implements DeckRepository {
  @override
  Stream<List<Deck>> watchChildren(DeckId? parentId) =>
      Stream.error(const PersistenceFailure('stats read failed'));
  @override
  Future<Result<Deck>> getById(DeckId id) => throw UnimplementedError();
  @override
  Future<Result<DeckStats>> statsFor(DeckId id) => throw UnimplementedError();
  @override
  Future<Result<Deck>> save(Deck deck) => throw UnimplementedError();
  @override
  Future<Result<void>> delete(DeckId id) => throw UnimplementedError();
}
