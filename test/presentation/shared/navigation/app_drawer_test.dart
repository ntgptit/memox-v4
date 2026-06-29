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
}
