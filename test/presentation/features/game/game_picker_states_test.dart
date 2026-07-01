import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox_v4/app/di/database_provider.dart';
import 'package:memox_v4/core/theme/app_theme.dart';
import 'package:memox_v4/data/datasources/local/connection/database_connection.dart';
import 'package:memox_v4/data/datasources/local/drift/app_database.dart'
    show AppDatabase, CardCompanion, DeckCompanion, LanguagePairCompanion;
import 'package:memox_v4/l10n/generated/app_localizations.dart';
import 'package:memox_v4/presentation/features/game/screens/game_picker_screen.dart';

/// State-COMPOSITION parity gate (Template B) for game-picker, driven by the
/// curated `tool/parity/contracts/game-picker.states.json`. game-picker/scope is
/// keyed on a Material DropdownButton (not MxCard) and the game rows are dynamic
/// `gamePick-<type>` ListTiles, so — like library/game-typing — assert the keyed
/// CONTAINER set per state, never casting a widget type.
///
/// Gated: default (deck has >=1 card → the picker's scope dropdown; add-cards
/// absent) and not-enough (deck has 0 cards → the add-cards CTA; scope absent).
/// scope-dropdown (Material menu overlay, no keyed sheet items) and loading are
/// coverage gaps. The FE enters not-enough only at count==0 — a documented
/// behavior divergence from the kit's "<4 words" banner (game-modes.md sets no
/// minimum-words rule); see game-picker.states.json $curated + intent-ledger.
Map<String, dynamic> _readJson(String path) =>
    jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;

void main() {
  late AppDatabase db;
  late int deckId;

  final states =
      (_readJson('tool/parity/contracts/game-picker.states.json')['states']
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

  Widget host() => ProviderScope(
    overrides: [databaseProvider.overrideWithValue(db)],
    child: MaterialApp(
      theme: AppTheme.light(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: GamePickerScreen(nodeId: deckId),
    ),
  );

  // State -> how to seed the deck. default seeds cards so _count>0 → the picker;
  // not-enough leaves the deck empty so _count==0 → the add-cards empty-state.
  final recipes = <String, Future<void> Function()>{
    'default': () async {
      for (var i = 0; i < 12; i++) {
        await db
            .into(db.card)
            .insert(
              CardCompanion.insert(deckId: deckId, term: '학교', createdAt: 1),
            );
      }
    },
    'not-enough': () async {},
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
