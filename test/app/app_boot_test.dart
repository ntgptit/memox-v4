import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox_v4/app/di/database_provider.dart';
import 'package:memox_v4/app/memox_app.dart';
import 'package:memox_v4/core/constants/app_constants.dart';
import 'package:memox_v4/data/datasources/local/connection/database_connection.dart';
import 'package:memox_v4/data/datasources/local/drift/app_database.dart';

void main() {
  testWidgets('boots into the app shell with bottom navigation', (
    tester,
  ) async {
    final db = AppDatabase.forTesting(openInMemoryDatabase());
    addTearDown(db.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: const MemoXApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Root app is up and the router landed on the shell, not a bare placeholder.
    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
    // The app bar shows the brand name.
    expect(find.text(AppConstants.appName), findsOneWidget);

    // No remnants of the default Flutter counter scaffold.
    expect(find.text('0'), findsNothing);
  });
}
