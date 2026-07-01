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
import 'package:memox_v4/domain/types/game_scope.dart';
import 'package:memox_v4/domain/types/game_type.dart';
import 'package:memox_v4/l10n/generated/app_localizations.dart';
import 'package:memox_v4/presentation/features/game/screens/game_screen.dart';
import 'package:memox_v4/presentation/features/game/viewmodels/game_session_notifier.dart';

/// State-COMPOSITION parity gate (Template B) for game-matching, driven by the
/// curated `tool/parity/contracts/game-matching.states.json`. game-matching has 0
/// MxCard and dynamic-keyed tiles (`matchLeft/right-<id>`), so — like the other
/// games — assert the keyed CONTAINER set per state, never casting.
///
/// The only literal keyed body discriminator is `complete` (rolled out this pass
/// via game_screen.dart:_completeKey). So `complete` is gated (present at complete,
/// absent at playing); playing/selected/correct/wrong/almost are coverage gaps
/// (dynamic-keyed tile grid, no literal keyed node). See the states.json $curated.
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
  late int deckId;

  final states =
      (_readJson('tool/parity/contracts/game-matching.states.json')['states']
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
    deckId = await db
        .into(db.deck)
        .insert(DeckCompanion.insert(pairId: pairId, name: 'Deck'));
  });
  tearDown(() => db.close());

  // Matching needs both term and meaning; returns the seeded card ids in order.
  Future<List<int>> seedCards(int n) async {
    final ids = <int>[];
    for (var i = 0; i < n; i++) {
      final cardId = await db
          .into(db.card)
          .insert(
            CardCompanion.insert(deckId: deckId, term: 'term$i', createdAt: 1),
          );
      await db
          .into(db.cardMeaning)
          .insert(
            CardMeaningCompanion.insert(
              cardId: cardId,
              lang: 'vi',
              content: 'mean$i',
            ),
          );
      ids.add(cardId);
    }
    return ids;
  }

  Widget host() => ProviderScope(
    overrides: [
      databaseProvider.overrideWithValue(db),
      clockProvider.overrideWithValue(const _FixedClock(0)),
    ],
    child: MaterialApp(
      theme: AppTheme.light(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: GameScreen(
          request: GameRequest(
            nodeId: deckId,
            type: GameType.matching,
            scope: GameScope.all,
            random: false,
          ),
        ),
      ),
    ),
  );

  // State -> how to drive the FE into it. playing seeds a grid and leaves it
  // untouched; complete matches every pair (tap matchLeft-<id> then
  // matchRight-<id> for each card) → pending empties → the _complete() container.
  final recipes = <String, Future<void> Function(WidgetTester)>{
    'playing': (tester) async {
      await seedCards(3);
      await tester.pumpWidget(host());
      await tester.pumpAndSettle();
    },
    'complete': (tester) async {
      final ids = await seedCards(2);
      await tester.pumpWidget(host());
      await tester.pumpAndSettle();
      for (final id in ids) {
        await tester.tap(find.byKey(Key('matchLeft-$id')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(Key('matchRight-$id')));
        await tester.pumpAndSettle();
      }
    },
  };

  for (final entry in recipes.entries) {
    final state = entry.key;
    testWidgets('state "$state": FE body renders exactly the kit node set', (
      tester,
    ) async {
      await entry.value(tester);

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
