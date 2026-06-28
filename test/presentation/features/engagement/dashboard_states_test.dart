import 'dart:convert';
import 'dart:io';

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

/// State-COMPOSITION parity gate, driven by the curated
/// `tool/parity/contracts/dashboard.states.json` (the per-state BODY node set the
/// kit renders). The set-level key gate (`fe_node_usage`) cannot see this — a keyed
/// node counts as "used" no matter which state renders it. Here we pump each state
/// and assert the FE body renders EXACTLY the kit's set:
///   - a node present that the state OMITS = THỪA (e.g. the goal/streak cards
///     leaking into the minimal empty state — the bug this layer exists to catch);
///   - a node absent that the state REQUIRES = THIẾU.
class _FixedClock implements Clock {
  _FixedClock(this._now);
  final DateTime _now;
  @override
  DateTime now() => _now;
  @override
  DateTime nowUtc() => _now.toUtc();
}

Map<String, dynamic> _readJson(String path) =>
    jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;

void main() {
  late AppDatabase db;
  late int pairId;
  final today = DateTime(2026, 6, 28, 10);

  final states =
      (_readJson('tool/parity/contracts/dashboard.states.json')['states']
              as Map<String, dynamic>)
          .map(
            (k, v) => MapEntry(k, (v as List<dynamic>).cast<String>().toSet()),
          );
  // The forbidden set for a state is (universe - allowed); asserting it absent is
  // what turns THỪA into a hard failure.
  final universe = states.values.expand((s) => s).toSet();

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

  Future<void> seed({int? goalWords, int words = 0, int seconds = 0}) async {
    if (goalWords != null) {
      await db
          .into(db.settings)
          .insert(
            SettingsCompanion.insert(
              key: 'daily_goal_words',
              value: Value('$goalWords'),
            ),
          );
    }
    if (words > 0 || seconds > 0) {
      await db
          .into(db.dailyActivity)
          .insert(
            DailyActivityCompanion.insert(
              day: dayKey(today),
              pairId: pairId,
              seconds: Value(seconds),
              words: Value(words),
            ),
          );
    }
  }

  // State name -> the data that drives the screen into it.
  final recipes = <String, Future<void> Function()>{
    'empty': () async {}, // no activity today → empty state
    'loaded': () => seed(goalWords: 10, words: 3), // activity, goal not met
    'goal-met': () => seed(goalWords: 5, words: 7), // goal met
  };

  for (final entry in recipes.entries) {
    final state = entry.key;
    testWidgets('state "$state": FE body renders exactly the kit node set', (
      tester,
    ) async {
      await entry.value();
      await tester.pumpWidget(host());
      await tester.pumpAndSettle();

      final allowed = states[state]!;
      for (final key in universe) {
        final finder = find.byKey(ValueKey(key));
        if (allowed.contains(key)) {
          expect(finder, findsOneWidget, reason: 'state "$state": $key THIẾU');
        } else {
          expect(
            finder,
            findsNothing,
            reason: 'state "$state": $key present but kit omits it here (THỪA)',
          );
        }
      }
    });
  }
}
