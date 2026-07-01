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

/// State-COMPOSITION parity gate (Template B) for game-mc, driven by the curated
/// `tool/parity/contracts/game-mc.states.json`. The FE renders the prompt node as
/// a Material Card (not MxCard), so — like library/game-typing — assert the keyed
/// CONTAINER set per state, never casting a widget type.
///
/// Gated: waiting (in-game body: prompt+options) and complete (empty — the shared
/// _complete() branch carries no keyed game-mc node, so prompt+options must be
/// ABSENT). correct/wrong share waiting's node-set — the FE has no post-answer
/// feedback frame (a tap auto-advances, D-015) — so they are documented-not-driven
/// coverage gaps (see game-mc.states.json $curated).
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
      (_readJson('tool/parity/contracts/game-mc.states.json')['states']
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

  Future<void> seedCard(String term, String meaning) async {
    final cardId = await db
        .into(db.card)
        .insert(CardCompanion.insert(deckId: deckId, term: term, createdAt: 1));
    await db
        .into(db.cardMeaning)
        .insert(
          CardMeaningCompanion.insert(
            cardId: cardId,
            lang: 'vi',
            content: meaning,
          ),
        );
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
            type: GameType.multipleChoice,
            scope: GameScope.all,
            random: false,
          ),
        ),
      ),
    ),
  );

  // Provider load is async and the body shows MxStateView.loading meanwhile, so
  // pump a fixed budget of frames rather than pumpAndSettle.
  Future<void> drain(WidgetTester tester) async {
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  // State -> how to drive the FE into it. waiting seeds several cards (a full
  // round, in-game body). complete seeds one card and taps the correct option,
  // which empties the pending queue → the shared _complete() branch (no keyed
  // game-mc body node).
  final recipes = <String, Future<void> Function(WidgetTester)>{
    'waiting': (tester) async {
      await seedCard('학교', '학교-nghĩa');
      await seedCard('사과', '사과-nghĩa');
      await seedCard('학생', '학생-nghĩa');
      await tester.pumpWidget(host());
      await drain(tester);
    },
    'complete': (tester) async {
      await seedCard('학교', '학교-nghĩa');
      await tester.pumpWidget(host());
      await drain(tester);
      await tester.tap(find.byKey(const Key('mcCorrect')));
      await drain(tester);
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
