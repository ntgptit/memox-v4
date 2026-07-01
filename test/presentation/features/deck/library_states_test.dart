import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:memox_v4/app/di/database_provider.dart';
import 'package:memox_v4/core/theme/app_theme.dart';
import 'package:memox_v4/data/datasources/local/connection/database_connection.dart';
import 'package:memox_v4/data/datasources/local/drift/app_database.dart';
import 'package:memox_v4/domain/models/deck_node.dart';
import 'package:memox_v4/l10n/generated/app_localizations.dart';
import 'package:memox_v4/presentation/features/deck/screens/library_screen.dart';
import 'package:memox_v4/presentation/features/deck/viewmodels/library_notifier.dart';

/// State-COMPOSITION parity gate (Template B) for library, driven by the curated
/// `tool/parity/contracts/library.states.json`. library.gen.json has 0 MxCard, so
/// — like dashboard_states_test — assert the keyed CONTAINER set per state, never
/// casting a widget type.
///
/// The gate universe is the two true state-discriminators (`empty-deck`, `retry`).
/// The toolbar controls (search-btn/sort-btn/create) are keyed but render in EVERY
/// state (a stable toolbar — divergence #1, documented in intent-ledger), so they
/// are NOT state-discriminating and are excluded from the loop; a targeted test
/// below locks that toolbar-always behavior instead. Coverage gaps (7):
/// search-active, pair-picker, sort-menu, overflow-menu, play-sheet, drawer,
/// loading — see library.states.json $curated.
class _ErrorLibraryNotifier extends LibraryNotifier {
  @override
  Future<List<DeckNode>> build() async =>
      throw Exception('forced library error');
}

Map<String, dynamic> _readJson(String path) =>
    jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;

void main() {
  late AppDatabase db;

  final states =
      (_readJson('tool/parity/contracts/library.states.json')['states']
              as Map<String, dynamic>)
          .map(
            (k, v) => MapEntry(k, (v as List<dynamic>).cast<String>().toSet()),
          );
  final universe = states.values.expand((s) => s).toSet();

  setUp(() async {
    db = AppDatabase.forTesting(openInMemoryDatabase());
    await db
        .into(db.languagePair)
        .insert(
          LanguagePairCompanion.insert(sourceLang: 'ko', targetLang: 'vi'),
        );
  });
  tearDown(() => db.close());

  Widget host({List<Override> extra = const <Override>[]}) => ProviderScope(
    overrides: <Override>[databaseProvider.overrideWithValue(db), ...extra],
    child: MaterialApp(
      theme: AppTheme.light(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const Scaffold(body: LibraryScreen()),
    ),
  );

  // State -> how to drive the FE into it. `loaded` seeds a root deck so neither
  // CTA (empty-deck/retry) appears; the deck tile itself uses a dynamic
  // deckTile-<id> key (identity-rollout gap, covered by library_screen_test), so
  // it is not in the gate universe. `empty` pumps with only a languagePair;
  // `error` forces the provider to throw via an override (the notifier folds repo
  // Result.err into an empty list, so a thrown build is the only clean path to the
  // error branch).
  final recipes =
      <String, ({Future<void> Function() seed, List<Override> extra})>{
        'loaded': (
          seed: () async {
            final pairId = await db.select(db.languagePair).getSingle();
            await db
                .into(db.deck)
                .insert(DeckCompanion.insert(pairId: pairId.id, name: 'Verbs'));
          },
          extra: const <Override>[],
        ),
        'empty': (seed: () async {}, extra: const <Override>[]),
        'error': (
          seed: () async {},
          extra: <Override>[
            libraryProvider.overrideWith(_ErrorLibraryNotifier.new),
          ],
        ),
      };

  for (final entry in recipes.entries) {
    final state = entry.key;
    testWidgets('state "$state": FE body renders exactly the kit node set', (
      tester,
    ) async {
      await entry.value.seed();
      await tester.pumpWidget(host(extra: entry.value.extra));
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

  // Divergence #1 lock: the FE toolbar (search/sort/create) renders in EVERY
  // state, unlike the kit which scopes search/sort into the with-data body and
  // derives create only in loaded. This is why those three are excluded from the
  // composition universe above; assert their FE-always presence explicitly.
  for (final state in <String>['empty', 'error']) {
    testWidgets('toolbar controls stay visible in "$state" (divergence #1)', (
      tester,
    ) async {
      await tester.pumpWidget(host(extra: recipes[state]!.extra));
      await tester.pumpAndSettle();

      for (final key in const <String>[
        'mx-node:library/search-btn',
        'mx-node:library/sort-btn',
        'mx-node:library/create',
      ]) {
        expect(
          find.byKey(ValueKey(key)),
          findsOneWidget,
          reason: 'toolbar $key should stay visible in $state',
        );
      }
    });
  }
}
