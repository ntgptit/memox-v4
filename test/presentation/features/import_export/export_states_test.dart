import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox_v4/app/di/database_provider.dart';
import 'package:memox_v4/app/di/import_export_providers.dart';
import 'package:memox_v4/core/theme/app_theme.dart';
import 'package:memox_v4/data/datasources/local/connection/database_connection.dart';
import 'package:memox_v4/data/datasources/local/drift/app_database.dart'
    show AppDatabase, CardCompanion, DeckCompanion, LanguagePairCompanion;
import 'package:memox_v4/domain/services/file_save_service.dart';
import 'package:memox_v4/l10n/generated/app_localizations.dart';
import 'package:memox_v4/presentation/features/import_export/screens/export_screen.dart';

/// State-COMPOSITION parity gate (Template B) for export, driven by the curated
/// `tool/parity/contracts/export.states.json`. The one gen MxCard node (export/progress)
/// is a bare Text in the FE, so — like dashboard_states_test — we assert keyed-node
/// present/absent, never casting the widget type.
///
/// Only `config` is driven by the composition loop (no export yet → progress absent —
/// this catches a result message leaking into the config screen). The kit's `exporting`
/// / `done` states are coverage gaps: the FE has no transient exporting UI, and its
/// post-export state keeps the config controls + appends a progress Text (matching
/// neither kit state). A separate test below drives the export tap and asserts the
/// progress Text APPEARS — the THIẾU direction, without the universe THỪA conflict.
class _FakeFileSave implements FileSaveService {
  @override
  Future<String> save(String fileName, List<int> bytes) async =>
      '/tmp/$fileName';
}

Map<String, dynamic> _readJson(String path) =>
    jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;

void main() {
  late AppDatabase db;
  late int deckId;

  final states =
      (_readJson('tool/parity/contracts/export.states.json')['states']
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
    await db
        .into(db.card)
        .insert(CardCompanion.insert(deckId: deckId, term: '학교', createdAt: 1));
  });
  tearDown(() => db.close());

  Widget host() => ProviderScope(
    overrides: [
      databaseProvider.overrideWithValue(db),
      fileSaveServiceProvider.overrideWithValue(_FakeFileSave()),
    ],
    child: MaterialApp(
      theme: AppTheme.light(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: ExportScreen(deckId: deckId)),
    ),
  );

  // The composition loop drives only `config` (exporting is a documented gap).
  const driven = <String>{'config'};

  for (final state in driven) {
    testWidgets('state "$state": FE body renders exactly the kit node set', (
      tester,
    ) async {
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

  // THIẾU direction for progress: after tapping do-export, the FE appends the progress
  // Text (result message). The config controls stay present (the documented divergence).
  testWidgets('export/progress appears after do-export (result message)', (
    tester,
  ) async {
    await tester.pumpWidget(host());
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('mx-node:export/progress')),
      findsNothing,
      reason: 'progress must be absent before export',
    );

    await tester.tap(find.byKey(const ValueKey('mx-node:export/do-export')));
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }

    expect(
      find.byKey(const ValueKey('mx-node:export/progress')),
      findsOneWidget,
      reason: 'progress (result message) must appear after export',
    );
    // FE keeps the config controls in the post-export state (divergence from kit).
    expect(
      find.byKey(const ValueKey('mx-node:export/do-export')),
      findsOneWidget,
    );
  });
}
