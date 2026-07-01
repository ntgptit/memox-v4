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

/// State-COMPOSITION parity gate (Template B) for game-typing, driven by the
/// curated `tool/parity/contracts/game-typing.states.json`. The FE renders the
/// meaning node as a Material Card (not MxCard), so — like library — assert the
/// keyed CONTAINER set per state, never casting a widget type.
///
/// Gate node-sets: waiting/typing/hint (the answering branch: meaning+hint+check)
/// and wrong (the just-wrong branch: meaning+retry+accept). waiting/typing/hint
/// share a node-set — typing changes only the text field, hint appends an
/// unkeyed hint Text — and are driven separately here to prove that invariance.
/// Coverage gaps (correct/complete) and identity-rollout gaps are documented in
/// game-typing.states.json $curated.
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
      (_readJson('tool/parity/contracts/game-typing.states.json')['states']
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
            type: GameType.typing,
            scope: GameScope.all,
            random: false,
          ),
        ),
      ),
    ),
  );

  // Provider load is async and the typing TextField autofocuses, so pump a fixed
  // budget of frames rather than pumpAndSettle (the review-parity pattern).
  Future<void> drain(WidgetTester tester) async {
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  // State -> the extra action (beyond seeding one card) that drives the FE into
  // it. typing enters partial text (no keyed node change); hint taps Help (adds
  // an unkeyed hint Text); wrong enters a wrong answer and taps Check.
  final actions = <String, Future<void> Function(WidgetTester)>{
    'waiting': (tester) async {},
    'typing': (tester) async {
      await tester.enterText(find.byKey(const Key('typingField')), '학');
      await tester.pump();
    },
    'hint': (tester) async {
      await tester.tap(find.byKey(const ValueKey('mx-node:game-typing/hint')));
      await tester.pump();
    },
    'wrong': (tester) async {
      await tester.enterText(find.byKey(const Key('typingField')), 'sai');
      await tester.tap(find.byKey(const ValueKey('mx-node:game-typing/check')));
      await tester.pump();
    },
  };

  for (final entry in actions.entries) {
    final state = entry.key;
    testWidgets('state "$state": FE body renders exactly the kit node set', (
      tester,
    ) async {
      await tester.pumpWidget(host());
      await drain(tester);
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
