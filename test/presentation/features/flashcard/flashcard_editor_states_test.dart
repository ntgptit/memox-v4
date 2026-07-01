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
import 'package:memox_v4/presentation/features/flashcard/screens/flashcard_editor_screen.dart';

/// State-COMPOSITION parity gate (Template B) for flashcard-editor, driven by the
/// curated `tool/parity/contracts/flashcard-editor.states.json`. It is a FORM (0 MxCard
/// in the contract), so — like dashboard_states_test — we pump each state and assert the
/// FE renders EXACTLY the kit's keyed control set:
///   - a node present that the state OMITS = THỪA (the duplicate banner leaking into a
///     clean create form — the bug this layer exists to catch);
///   - a node absent that the state REQUIRES = THIẾU.
///
/// Gated states: `create` (no banner) and `duplicate` (banner → dup-add/dup-view, reached
/// by entering a term that already exists in the deck and tapping Save → soft-dup D-020).
/// The kit's edit / validation / multi-meaning / audio states render the SAME keyed set
/// as create (only text/errorText/icon/dynamic-field-count change), so they are documented
/// coverage gaps, not separately gated.
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
      (_readJson('tool/parity/contracts/flashcard-editor.states.json')['states']
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
    overrides: [
      databaseProvider.overrideWithValue(db),
      clockProvider.overrideWithValue(const _FixedClock(10000)),
    ],
    child: MaterialApp(
      theme: AppTheme.light(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: FlashcardEditorScreen(deckId: deckId)),
    ),
  );

  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  // State -> how to drive the create-mode editor into it. `duplicate` seeds a card
  // whose term the user then re-enters, then taps Save → soft-duplicate banner.
  final drivers = <String, Future<void> Function(WidgetTester)>{
    'create': (tester) async {
      await tester.pumpWidget(host());
      await settle(tester);
    },
    'duplicate': (tester) async {
      await db
          .into(db.card)
          .insert(
            CardCompanion.insert(deckId: deckId, term: '학교', createdAt: 1),
          );
      await tester.pumpWidget(host());
      await settle(tester);
      await tester.enterText(find.byKey(const Key('editorTermField')), '학교');
      await tester.enterText(
        find.byKey(const Key('editorMeaningField')),
        'school',
      );
      await tester.pump();
      await tester.tap(
        find.byKey(const ValueKey('mx-node:flashcard-editor/save')),
      );
      await settle(tester);
    },
  };

  for (final entry in drivers.entries) {
    final state = entry.key;
    testWidgets('state "$state": FE body renders exactly the kit node set', (
      tester,
    ) async {
      // The form is a ListView; enlarge the viewport so every keyed control builds
      // (lazy lists only build visible children — off-screen nodes would false-THIẾU).
      tester.view.physicalSize = const Size(1200, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

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
