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
import 'package:memox_v4/presentation/shared/widgets/display/mx_text.dart';
import 'package:memox_v4/presentation/shared/widgets/surfaces/mx_card.dart';

/// PER-STATE parity gate for the game-recall screen — mirrors review_parity_test.dart
/// (Template A), driven by three generated/curated contracts (no pixels, no AI):
///   - game-recall.gen.json    : identity + component + variant   (gen_parity_contract.mjs)
///   - game-recall.slots.json  : text role + binding per node      (curated from gen_slots.mjs)
///   - game-recall.states.json : which node ids are present per STATE (gen_states.mjs)
///
/// The state-differentiating MxCards are game-recall/term (always) and
/// game-recall/meaning (only after reveal). We drive:
///   - before-reveal: 1-card round, no tap → term present, meaning absent.
///   - revealed      : 1-card round, tap reveal → term + meaning present.
/// `forgot` / `remembered` render the SAME node-set as `revealed` (the FE grades then
/// returns to before-reveal — no distinct banner state), so they are listed in
/// game-recall.states.json but NOT driven (coverage gap, like review's editing/audio).
/// `complete` is the shared GameScreen chrome with no keyed game-recall/* MxCard.
class _FixedClock implements Clock {
  const _FixedClock(this._ms);
  final int _ms;
  @override
  DateTime now() => DateTime.fromMillisecondsSinceEpoch(_ms);
  @override
  DateTime nowUtc() => now().toUtc();
}

const Map<String, MxCardVariant> _variants = <String, MxCardVariant>{
  'elevated': MxCardVariant.elevated,
  'flat': MxCardVariant.flat,
  'muted': MxCardVariant.muted,
  'primary': MxCardVariant.primary,
  'primarySoft': MxCardVariant.primarySoft,
};

// Curated kit-state -> whether to tap reveal to reach it. before-reveal/revealed
// are the two drivable states; forgot/remembered/complete are coverage gaps.
const Map<String, bool> _reveal = <String, bool>{
  'before-reveal': false,
  'revealed': true,
};

MxTextRole _role(String name) =>
    MxTextRole.values.firstWhere((r) => r.name == name);

Map<String, dynamic> _readJson(String path) =>
    jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;

void main() {
  final nodes =
      (_readJson('tool/parity/contracts/game-recall.gen.json')['nodes']
              as List<dynamic>)
          .cast<Map<String, dynamic>>();
  final slotMap =
      _readJson('tool/parity/contracts/game-recall.slots.json')['slots']
          as Map<String, dynamic>;
  final stateNodes =
      _readJson('tool/parity/contracts/game-recall.states.json')['states']
          as Map<String, dynamic>;

  Future<(AppDatabase, int)> seed() async {
    final db = AppDatabase.forTesting(openInMemoryDatabase());
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
    return (db, deckId);
  }

  Widget host(AppDatabase db, int deckId) => ProviderScope(
    overrides: [
      databaseProvider.overrideWithValue(db),
      clockProvider.overrideWithValue(const _FixedClock(0)),
    ],
    child: MaterialApp(
      theme: AppTheme.light(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: GameScreen(
        request: GameRequest(
          nodeId: deckId,
          type: GameType.recall,
          scope: GameScope.all,
          random: false,
        ),
      ),
    ),
  );

  for (final entry in _reveal.entries) {
    final state = entry.key;
    final tapReveal = entry.value;
    testWidgets(
      'state "$state": MxCard identity matches game-recall.states.json',
      (tester) async {
        final (db, deckId) = await seed();
        addTearDown(db.close);
        await tester.pumpWidget(host(db, deckId));
        // The session loads its queue async; pump frames to the data state (the
        // progress bar is determinate — no spinner to hang on).
        for (var i = 0; i < 5; i++) {
          await tester.pump(const Duration(milliseconds: 50));
        }

        if (tapReveal) {
          await tester.tap(
            find.byKey(const ValueKey('mx-node:game-recall/reveal')),
          );
          await tester.pump(const Duration(milliseconds: 50));
        }

        final present = (stateNodes[state] as List<dynamic>).cast<String>();

        for (final node in nodes) {
          // Template A loops only MxCard nodes (term / meaning); the controls
          // (reveal/forgot/remembered) are non-MxCard and covered elsewhere.
          if (node['component'] != 'MxCard') continue;
          final key = node['key'] as String; // 'mx-node:game-recall/…'
          final id = key.replaceFirst('mx-node:', '');
          final finder = find.byKey(ValueKey(key));

          if (!present.contains(key)) {
            // State-differentiated identity: node absent in this state.
            expect(
              finder,
              findsNothing,
              reason: 'state $state: $id must be absent',
            );
            continue;
          }

          // 1. IDENTITY.
          expect(
            finder,
            findsOneWidget,
            reason: 'state $state: $id not rendered',
          );

          // 2. STYLING (variant ⇒ bg/radius/border).
          final expectedVariant = _variants[node['variant'] as String];
          expect(expectedVariant, isNotNull, reason: 'unknown variant for $id');
          expect(
            tester.widget<MxCard>(finder).variant,
            expectedVariant,
            reason: 'state $state: $id variant drifted from contract',
          );

          // 3. SLOTS (curated overlay — bind slots assert the role only).
          final slots = (slotMap[key] as List<dynamic>? ?? <dynamic>[])
              .cast<Map<String, dynamic>>();
          for (final slot in slots) {
            final role = _role(slot['role'] as String);
            expect(
              find.descendant(
                of: finder,
                matching: find.byWidgetPredicate(
                  (w) => w is MxText && w.role == role,
                ),
              ),
              findsWidgets,
              reason:
                  'state $state: $id slot "${slot['name']}": no MxText(role:${role.name})',
            );
          }
        }
      },
    );
  }
}
