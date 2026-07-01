import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox_v4/app/di/clock_provider.dart';
import 'package:memox_v4/app/di/database_provider.dart';
import 'package:memox_v4/core/theme/app_theme.dart';
import 'package:memox_v4/core/util/clock.dart';
import 'package:memox_v4/data/datasources/local/connection/database_connection.dart';
import 'package:memox_v4/data/datasources/local/drift/app_database.dart';
import 'package:memox_v4/l10n/generated/app_localizations.dart';
import 'package:memox_v4/presentation/features/statistics/screens/statistics_screen.dart';

/// State-COMPOSITION parity gate (Template B) for statistics, driven by the curated
/// `tool/parity/contracts/statistics.states.json` (the per-state keyed section-head set
/// the kit renders). statistics.gen.json's 2 MxCard nodes (streak-current/longest) are
/// not keyed in the FE, so — like dashboard_states_test — we pump each state and assert
/// the FE renders EXACTLY the kit's keyed head set:
///   - a head present that the state OMITS = THỪA (e.g. a chart leaking into the
///     insufficient/loading state — the bug this layer exists to catch);
///   - a head absent that the state REQUIRES = THIẾU.
///
/// accuracy-head renders only when summary.hasReviews, so the loaded/scope-switch
/// recipes seed a review_outcome row. loading is pumped a single frame (no settle) so
/// the _StatsSkeleton — with no keyed head — is what gets asserted.
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
  late int deckId;
  final today = DateTime(2026, 6, 28, 10);

  final states =
      (_readJson('tool/parity/contracts/statistics.states.json')['states']
              as Map<String, dynamic>)
          .map(
            (k, v) => MapEntry(k, (v as List<dynamic>).cast<String>().toSet()),
          );
  final universe = states.values.expand((s) => s).toSet();

  setUp(() async {
    db = AppDatabase.forTesting(openInMemoryDatabase());
    pairId = await db
        .into(db.languagePair)
        .insert(
          LanguagePairCompanion.insert(sourceLang: 'ko', targetLang: 'vi'),
        );
    deckId = await db
        .into(db.deck)
        .insert(DeckCompanion.insert(pairId: pairId, name: 'Deck'));
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
      home: const Scaffold(body: StatisticsScreen()),
    ),
  );

  // Enough data (a visible card → hasEnoughData) + a review (→ hasReviews so
  // accuracy-head renders).
  Future<void> seedLoaded() async {
    final cardId = await db
        .into(db.card)
        .insert(CardCompanion.insert(deckId: deckId, term: '학교', createdAt: 1));
    await db
        .into(db.reviewOutcome)
        .insert(
          ReviewOutcomeCompanion.insert(
            cardId: cardId,
            pairId: pairId,
            ts: 1000,
            correct: 1,
            mode: 'dueReview',
          ),
        );
  }

  // State -> how to drive it. `settle`=false pumps a single frame so the async
  // loading branch (_StatsSkeleton) is what renders.
  final recipes = <String, ({Future<void> Function() seed, bool settle})>{
    'insufficient': (seed: () async {}, settle: true),
    'loaded': (seed: seedLoaded, settle: true),
    'scope-switch': (seed: seedLoaded, settle: true),
    'loading': (seed: seedLoaded, settle: false),
  };

  for (final entry in recipes.entries) {
    final state = entry.key;
    final recipe = entry.value;
    testWidgets('state "$state": FE body renders exactly the kit head set', (
      tester,
    ) async {
      // The body is a ListView; enlarge the viewport so all section cards build
      // (lazy lists only build visible children — off-screen heads would false-THIẾU).
      tester.view.physicalSize = const Size(1200, 4000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await recipe.seed();
      await tester.pumpWidget(host());
      if (recipe.settle) {
        await tester.pumpAndSettle();
      } else {
        await tester.pump();
      }

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
