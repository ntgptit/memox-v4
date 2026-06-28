import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox_v4/app/di/clock_provider.dart';
import 'package:memox_v4/app/di/database_provider.dart';
import 'package:memox_v4/core/theme/app_theme.dart';
import 'package:memox_v4/core/util/clock.dart';
import 'package:memox_v4/core/util/day_key.dart';
import 'package:memox_v4/data/datasources/local/connection/database_connection.dart';
import 'package:memox_v4/data/datasources/local/drift/app_database.dart';
import 'package:memox_v4/l10n/generated/app_localizations.dart';
import 'package:memox_v4/presentation/features/engagement/screens/dashboard_screen.dart';

class _FixedClock implements Clock {
  _FixedClock(this._now);
  final DateTime _now;
  @override
  DateTime now() => _now;
  @override
  DateTime nowUtc() => _now.toUtc();
}

void main() {
  late AppDatabase db;
  late int pairId;
  final today = DateTime(2026, 6, 28, 10);

  setUp(() async {
    db = AppDatabase.forTesting(openInMemoryDatabase());
    pairId = await db
        .into(db.languagePair)
        .insert(
          LanguagePairCompanion.insert(sourceLang: 'ko', targetLang: 'vi'),
        );
  });
  tearDown(() => db.close());

  Widget host() => ProviderScope(
    overrides: [
      databaseProvider.overrideWithValue(db),
      clockProvider.overrideWithValue(_FixedClock(today)),
    ],
    child: MaterialApp(
      theme: AppTheme.light(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const Scaffold(body: DashboardScreen()),
    ),
  );

  testWidgets('renders activity, met goal and streak', (tester) async {
    await db
        .into(db.settings)
        .insert(
          SettingsCompanion.insert(
            key: 'daily_goal_words',
            value: const Value('5'),
          ),
        );
    await db
        .into(db.dailyActivity)
        .insert(
          DailyActivityCompanion.insert(
            day: dayKey(today),
            pairId: pairId,
            seconds: const Value(120),
            words: const Value(7),
          ),
        );

    await tester.pumpWidget(host());
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('dashboard')), findsOneWidget);
    // 7 words shown in the TODAY hero card.
    expect(find.text('7'), findsOneWidget);
    // 7 words ≥ goal 5 → streak of 1 day (streak card shows the count + label).
    expect(find.byKey(const Key('dashboardStreak')), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
    expect(find.text('Daily goal reached. Streak +1.'), findsOneWidget);
  });

  testWidgets('empty state is minimal — only the note + Start CTA', (
    tester,
  ) async {
    await tester.pumpWidget(host());
    await tester.pumpAndSettle();

    expect(
      find.text('No study yet today — start to keep your streak!'),
      findsOneWidget,
    );
    expect(find.text('Start studying'), findsOneWidget);
    // The kit's empty state drops the goal / streak / mastered / decks stack.
    expect(find.byKey(const Key('dashboardGoalNone')), findsNothing);
    expect(find.byKey(const Key('dashboardStreak')), findsNothing);
  });

  testWidgets('with activity but no goal, shows the set-a-goal hint', (
    tester,
  ) async {
    await db
        .into(db.dailyActivity)
        .insert(
          DailyActivityCompanion.insert(
            day: dayKey(today),
            pairId: pairId,
            seconds: const Value(60),
            words: const Value(3),
          ),
        );
    await tester.pumpWidget(host());
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('dashboardGoalNone')), findsOneWidget);
  });
}
