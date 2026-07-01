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
import 'package:memox_v4/data/datasources/local/drift/app_database.dart'
    show
        AppDatabase,
        CardCompanion,
        CardMeaningCompanion,
        DeckCompanion,
        LanguagePairCompanion;
import 'package:memox_v4/l10n/generated/app_localizations.dart';
import 'package:memox_v4/presentation/features/search/screens/search_screen.dart';

/// State-COMPOSITION parity gate (Template B) for search, driven by the curated
/// `tool/parity/contracts/search.states.json`. search.gen.json has 0 MxCard, so — like
/// dashboard_states_test — we assert keyed CONTAINER present/absent, never casting.
///
/// Gated states: `results` (a matching query → result list; filters present, no-results
/// absent) and `no-results` (a non-matching query → filters + no-results empty state).
/// The `no-results` container is the real discriminator. `empty-recent` is a coverage
/// gap because the FE renders the filter row ALWAYS (divergence #1) while the kit hides
/// it on empty-recent, so it can't be loop-asserted; `filtered` shares the results
/// node-set; `loading` is a skeleton with no keyed body node.
class _FixedClock implements Clock {
  const _FixedClock(this._ms);
  final int _ms;
  @override
  DateTime now() => DateTime.fromMillisecondsSinceEpoch(_ms);
  @override
  DateTime nowUtc() => now().toUtc();
}

Map<String, dynamic> _readJson(String path) =>
    jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;

void main() {
  late AppDatabase db;

  final states =
      (_readJson('tool/parity/contracts/search.states.json')['states']
              as Map<String, dynamic>)
          .map(
            (k, v) => MapEntry(k, (v as List<dynamic>).cast<String>().toSet()),
          );
  final universe = states.values.expand((s) => s).toSet();

  setUp(() async {
    db = AppDatabase.forTesting(openInMemoryDatabase());
    final pairId = await db
        .into(db.languagePair)
        .insert(
          LanguagePairCompanion.insert(sourceLang: 'ko', targetLang: 'vi'),
        );
    final deckId = await db
        .into(db.deck)
        .insert(DeckCompanion.insert(pairId: pairId, name: 'Deck'));
    final cardId = await db
        .into(db.card)
        .insert(CardCompanion.insert(deckId: deckId, term: '학교', createdAt: 1));
    await db
        .into(db.cardMeaning)
        .insert(
          CardMeaningCompanion.insert(cardId: cardId, lang: 'vi', content: '학'),
        );
  });
  tearDown(() => db.close());

  Widget host() => ProviderScope(
    overrides: [
      databaseProvider.overrideWithValue(db),
      clockProvider.overrideWithValue(const _FixedClock(10000)),
    ],
    child: MaterialApp(
      theme: AppTheme.light(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const Scaffold(body: SearchScreen()),
    ),
  );

  // State -> the query text that drives the FE into it. A matching query yields the
  // result list; a non-matching query yields the no-results empty state.
  const query = <String, String>{'results': '학교', 'no-results': 'zzznomatch'};

  for (final entry in query.entries) {
    final state = entry.key;
    testWidgets('state "$state": FE body renders exactly the kit node set', (
      tester,
    ) async {
      await tester.pumpWidget(host());
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const ValueKey('mx-node:search/dock')),
        entry.value,
      );
      for (var i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 50));
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
