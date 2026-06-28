import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox_v4/app/di/database_provider.dart';
import 'package:memox_v4/app/memox_app.dart';
import 'package:memox_v4/data/datasources/local/connection/database_connection.dart';
import 'package:memox_v4/data/datasources/local/drift/app_database.dart';
import 'package:memox_v4/presentation/shared/widgets/navigation/mx_bottom_nav.dart';
import 'package:memox_v4/presentation/shared/widgets/navigation/mx_fab.dart';

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
    expect(find.byType(MxBottomNav), findsOneWidget);
    // Shell chrome: a minimal app bar (notifications + avatar) replaced the
    // brand-title bar, per the design kit.
    expect(find.byType(AppBar), findsOneWidget);
    // Design-kit bottom nav carries the center "Add" action as a fifth item.
    expect(find.text('Add'), findsOneWidget);
    // Boot lands on Library (root) — the Review FAB is a Today-only action.
    expect(find.text('Review'), findsNothing);

    // Switching to the Today tab surfaces the Review FAB.
    await tester.tap(find.text('Today'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(MxFab, 'Review'), findsOneWidget);
  });
}
