import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox_v4/app/di/database_provider.dart';
import 'package:memox_v4/data/datasources/local/connection/database_connection.dart';
import 'package:memox_v4/data/datasources/local/drift/app_database.dart';
import 'package:memox_v4/l10n/generated/app_localizations.dart';
import 'package:memox_v4/presentation/shared/navigation/app_drawer.dart';

Widget _host(AppDatabase db) => ProviderScope(
  overrides: [databaseProvider.overrideWithValue(db)],
  child: const MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(drawer: AppDrawer(), body: SizedBox.shrink()),
  ),
);

Future<void> _openDrawer(WidgetTester tester) async {
  tester.state<ScaffoldState>(find.byType(Scaffold)).openDrawer();
  await tester.pumpAndSettle();
}

Future<void> _seedPair(AppDatabase db) => db
    .into(db.languagePair)
    .insert(LanguagePairCompanion.insert(sourceLang: 'ko', targetLang: 'vi'));

Map<String, dynamic> _readJson(String path) =>
    jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase.forTesting(openInMemoryDatabase()));
  tearDown(() => db.close());

  testWidgets('menu lists seeded pairs and the language actions', (
    tester,
  ) async {
    await _seedPair(db);
    await tester.pumpWidget(_host(db));
    await _openDrawer(tester);

    expect(find.byKey(const Key('pairTile-1')), findsOneWidget);
    expect(find.byKey(const Key('drawerAddLanguage')), findsOneWidget);
    expect(find.byKey(const Key('drawerRemoveLanguage')), findsOneWidget);
  });

  testWidgets('add-language view renders the picker and submit', (
    tester,
  ) async {
    await tester.pumpWidget(_host(db));
    await _openDrawer(tester);

    await tester.tap(find.byKey(const Key('drawerAddLanguage')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('addLanguageSource')), findsOneWidget);
    expect(find.byKey(const Key('addLanguageTarget')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('mx-node:drawer/add-confirm')),
      findsOneWidget,
    );
  });

  testWidgets('remove-language view lists pairs to delete', (tester) async {
    await _seedPair(db);
    await tester.pumpWidget(_host(db));
    await _openDrawer(tester);

    await tester.tap(find.byKey(const Key('drawerRemoveLanguage')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('removeTile-1')), findsOneWidget);
  });

  // State-COMPOSITION parity gate (Template B) for the shared AppDrawer, driven by
  // tool/parity/contracts/drawer.states.json. drawer.gen.json has 0 MxCard, so —
  // like dashboard_states_test — assert the keyed CONTAINER set per state, never
  // casting. The drawer is a shared component (not a route): one AppDrawer swaps
  // _DrawerView in place, so all three states are reached via tap in one host.
  //
  // `open` (the menu view) has 0 literal mx-node:drawer/ keys, so it gates the
  // empty set — a THỪA guard that add-screen/remove-screen do not leak into the
  // menu. The menu's positive coverage is the three tests above
  // (drawerAddLanguage/drawerRemoveLanguage/pairTile-*). remove-cancel/remove-ok
  // live in a Material AlertDialog (option A coverage gap); pair rows use dynamic
  // keys (removeTile-<id>). See the states.json $curated + intent-ledger.
  final states =
      (_readJson('tool/parity/contracts/drawer.states.json')['states']
              as Map<String, dynamic>)
          .map(
            (k, v) => MapEntry(k, (v as List<dynamic>).cast<String>().toSet()),
          );
  final universe = states.values.expand((s) => s).toSet();

  // State -> how to drive the shared AppDrawer into it (all from the open menu).
  final drivers = <String, Future<void> Function(WidgetTester)>{
    'open': (tester) async {},
    'add-language': (tester) async {
      await tester.tap(find.byKey(const Key('drawerAddLanguage')));
      await tester.pumpAndSettle();
    },
    'remove-language': (tester) async {
      await tester.tap(find.byKey(const Key('drawerRemoveLanguage')));
      await tester.pumpAndSettle();
    },
  };

  for (final entry in drivers.entries) {
    final state = entry.key;
    testWidgets('state "$state": drawer renders exactly the kit node set', (
      tester,
    ) async {
      await _seedPair(db); // a pair is needed for the remove action to appear
      await tester.pumpWidget(_host(db));
      await _openDrawer(tester);
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
