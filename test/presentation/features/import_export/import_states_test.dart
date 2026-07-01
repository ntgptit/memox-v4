import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox_v4/app/di/database_provider.dart';
import 'package:memox_v4/core/theme/app_theme.dart';
import 'package:memox_v4/data/datasources/local/connection/database_connection.dart';
import 'package:memox_v4/data/datasources/local/drift/app_database.dart'
    show AppDatabase, DeckCompanion, LanguagePairCompanion;
import 'package:memox_v4/l10n/generated/app_localizations.dart';
import 'package:memox_v4/presentation/features/import_export/screens/import_screen.dart';

/// State-COMPOSITION parity gate (Template B) for import, driven by the curated
/// `tool/parity/contracts/import.states.json`. import.gen.json has 0 MxCard, so — like
/// dashboard_states_test — we assert keyed-node present/absent, never casting.
///
/// The kit is a 5-step WIZARD with controls SPLIT across steps (map-picks in `mapping`,
/// do-import in `preview`/`dup-warning`, go-deck in `done`); the FE is a single scrolling
/// screen that renders map-picks + do-import TOGETHER once _rows is set (and keeps them
/// after import while appending go-deck). Because no single kit state name holds
/// {map-picks, do-import} together, import.states.json follows the KIT per-state
/// membership (so states_check — curated ⊆ derived — passes); the FE's COMBINED node-sets
/// therefore cannot be asserted through the universe loop. So the loop drives only
/// `source` (every body node ABSENT — catches a leak onto the initial screen), and the
/// FE's real body states are fully composition-checked by two TARGETED tests below:
///   - loaded (_rows set): map-term-pick + map-meaning-pick + do-import present, go-deck absent;
///   - done (_result set): the FE KEEPS all three + appends go-deck → all four present.
/// This is the FE-faithful composition gate, expressed as targeted asserts rather than
/// the states.json loop (which states_check forces to the kit's split membership).
Map<String, dynamic> _readJson(String path) =>
    jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;

void main() {
  late AppDatabase db;
  late int deckId;

  final states =
      (_readJson('tool/parity/contracts/import.states.json')['states']
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
      home: Scaffold(body: ImportScreen(deckId: deckId)),
    ),
  );

  // Make Clipboard.getData return delimited text so tapping paste populates _rows.
  void mockClipboard(WidgetTester tester, String text) {
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async => call.method == 'Clipboard.getData'
          ? <String, dynamic>{'text': text}
          : null,
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );
  }

  void bigViewport(WidgetTester tester) {
    tester.view.physicalSize = const Size(1200, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  // Composition loop: only `source` is drivable cleanly (initial screen, _rows == null).
  testWidgets('state "source": FE body renders exactly the kit node set', (
    tester,
  ) async {
    bigViewport(tester);
    await tester.pumpWidget(host());
    await tester.pumpAndSettle();

    final allowed = states['source']!;
    for (final key in universe) {
      final finder = find.byKey(ValueKey(key));
      if (allowed.contains(key)) {
        expect(finder, findsOneWidget, reason: 'state "source": $key THIẾU');
      } else {
        expect(
          finder,
          findsNothing,
          reason: 'state "source": $key present but kit omits it here (THỪA)',
        );
      }
    }
  });

  testWidgets('after paste: map-picks + do-import appear (_rows loaded)', (
    tester,
  ) async {
    bigViewport(tester);
    mockClipboard(tester, 'term,meaning\n학교,school');
    await tester.pumpWidget(host());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('importPaste')));
    await tester.pumpAndSettle();

    for (final key in <String>[
      'mx-node:import/map-term-pick',
      'mx-node:import/map-meaning-pick',
      'mx-node:import/do-import',
    ]) {
      expect(
        find.byKey(ValueKey(key)),
        findsOneWidget,
        reason: '$key must appear once _rows is loaded',
      );
    }
    // go-deck must NOT appear before the import runs.
    expect(find.byKey(const ValueKey('mx-node:import/go-deck')), findsNothing);
  });

  testWidgets('after do-import: FE done keeps the controls + appends go-deck', (
    tester,
  ) async {
    bigViewport(tester);
    mockClipboard(tester, 'term,meaning\n학교,school');
    await tester.pumpWidget(host());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('importPaste')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('mx-node:import/do-import')));
    await tester.pumpAndSettle();

    // The FE does NOT clear _rows on import (documented divergence from the kit's
    // separate `done` step), so the full done composition is all four body nodes.
    for (final key in <String>[
      'mx-node:import/map-term-pick',
      'mx-node:import/map-meaning-pick',
      'mx-node:import/do-import',
      'mx-node:import/go-deck',
    ]) {
      expect(
        find.byKey(ValueKey(key)),
        findsOneWidget,
        reason: '$key must be present in the FE done state',
      );
    }
  });
}
