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
import 'package:memox_v4/presentation/features/study/screens/player_screen.dart';
import 'package:memox_v4/presentation/shared/widgets/display/mx_text.dart';
import 'package:memox_v4/presentation/shared/widgets/surfaces/mx_card.dart';

/// PER-STATE parity gate for the player screen — mirrors review_parity_test.dart
/// (Template A), driven by three generated/curated contracts (no pixels, no AI):
///   - player.gen.json    : identity + component + variant   (gen_parity_contract.mjs)
///   - player.slots.json  : text role + binding per node      (curated from gen_slots.mjs)
///   - player.states.json : which node ids are present per STATE (gen_states.mjs)
///
/// For each mapped state we drive the FE to that state and assert, per keyed MxCard:
///   present in the state  → renders + variant matches + each slot's MxTextRole shows.
///   absent in the state   → does NOT render (state-differentiated identity).
///
/// The kit→FE state map below is the curated part (like slots): `playing` shows a
/// card (1-card queue); `end` is the exhausted queue (0 cards). The kit's `paused`
/// state renders the SAME node-set as `playing` (_playing only swaps the play/pause
/// icon, not identity), and the FE has no speed control, so `paused` / `speed` are
/// intentionally NOT driven — exactly the per-state coverage gap this contract surfaces.
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

// Curated kit-state -> number of cards to seed to reach it in the FE.
// paused/speed are documented-not-driven coverage gaps (see player.states.json).
const Map<String, int> _stateSeed = <String, int>{'playing': 1, 'end': 0};

MxTextRole _role(String name) =>
    MxTextRole.values.firstWhere((r) => r.name == name);

Map<String, dynamic> _readJson(String path) =>
    jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;

void main() {
  final nodes =
      (_readJson('tool/parity/contracts/player.gen.json')['nodes']
              as List<dynamic>)
          .cast<Map<String, dynamic>>();
  final slotMap =
      _readJson('tool/parity/contracts/player.slots.json')['slots']
          as Map<String, dynamic>;
  final stateNodes =
      _readJson('tool/parity/contracts/player.states.json')['states']
          as Map<String, dynamic>;

  Future<(AppDatabase, int)> seed(int cards) async {
    final db = AppDatabase.forTesting(openInMemoryDatabase());
    final pairId = await db
        .into(db.languagePair)
        .insert(
          LanguagePairCompanion.insert(sourceLang: 'ko', targetLang: 'vi'),
        );
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
    return (db, deckId);
  }

  Widget host(AppDatabase db, int deckId) => ProviderScope(
    overrides: [
      databaseProvider.overrideWithValue(db),
      clockProvider.overrideWithValue(const _FixedClock(10000)),
    ],
    child: MaterialApp(
      theme: AppTheme.light(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: PlayerScreen(nodeId: deckId)),
    ),
  );

  for (final entry in _stateSeed.entries) {
    final state = entry.key;
    testWidgets('state "$state": MxCard identity matches player.states.json', (
      tester,
    ) async {
      final (db, deckId) = await seed(entry.value);
      addTearDown(db.close);
      await tester.pumpWidget(host(db, deckId));
      // PlayerScreen loads its queue in initState; pump a few frames to settle
      // (no spinner to hang on once loaded — avoid pumpAndSettle on the loader).
      for (var i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      final present = (stateNodes[state] as List<dynamic>).cast<String>();

      for (final node in nodes) {
        // The FE keys only MxCard nodes for the Template-A loop (others await
        // identity rollout / are non-MxCard chrome).
        if (node['component'] != 'MxCard') continue;
        final key =
            node['key']
                as String; // 'mx-node:player/…', as player.states.json lists
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
    });
  }
}
