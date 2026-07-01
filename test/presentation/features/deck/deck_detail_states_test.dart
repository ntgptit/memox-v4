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
    show AppDatabase, CardCompanion, DeckCompanion, LanguagePairCompanion;
import 'package:memox_v4/l10n/generated/app_localizations.dart';
import 'package:memox_v4/presentation/features/deck/screens/deck_detail_screen.dart';

/// State-COMPOSITION parity gate (Template B) for deck-detail, driven by the curated
/// `tool/parity/contracts/deck-detail.states.json` (the per-state keyed node set the
/// kit renders). deck-detail.gen.json has 0 MxCard, so — like dashboard_states_test —
/// we pump each state and assert the FE renders EXACTLY the kit's keyed set:
///   - a node present that the state OMITS = THỪA (e.g. empty-* controls leaking into
///     the populated list — the bug this layer exists to catch);
///   - a node absent that the state REQUIRES = THIẾU.
///
/// Gated states: loaded / empty (both DB-seed driven, deterministic). The kit's other
/// 11 states are coverage gaps documented in deck-detail.states.json — notably `error`
/// (no clean widget-test override for this codegen family notifier) and
/// `deck-delete-confirm` (a menu→sheet→dialog tap chain); the rest are unkeyed overlays
/// / other routes / v1-absent features already recorded in the intent-ledger.
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
  late int pairId;

  final states =
      (_readJson('tool/parity/contracts/deck-detail.states.json')['states']
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
  });
  tearDown(() => db.close());

  Future<int> seedDeck({int cards = 0}) async {
    final deckId = await db
        .into(db.deck)
        .insert(DeckCompanion.insert(pairId: pairId, name: 'Deck'));
    for (var i = 0; i < cards; i++) {
      await db
          .into(db.card)
          .insert(
            CardCompanion.insert(deckId: deckId, term: '학교', createdAt: 1),
          );
    }
    return deckId;
  }

  Widget host(int deckId) => ProviderScope(
    overrides: [
      databaseProvider.overrideWithValue(db),
      clockProvider.overrideWithValue(const _FixedClock(10000)),
    ],
    child: MaterialApp(
      theme: AppTheme.light(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: DeckDetailScreen(deckId: deckId)),
    ),
  );

  // State name -> the deck to seed. loaded has a direct card; empty has none.
  final recipes = <String, Future<int> Function()>{
    'loaded': () => seedDeck(cards: 1),
    'empty': seedDeck,
  };

  for (final entry in recipes.entries) {
    final state = entry.key;
    testWidgets('state "$state": FE body renders exactly the kit node set', (
      tester,
    ) async {
      final deckId = await entry.value();
      await tester.pumpWidget(host(deckId));
      // The provider loads async; the FE shows MxStateView.loading (a spinner)
      // meanwhile, so pump frames rather than pumpAndSettle.
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
