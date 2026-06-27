import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox_v4/app/memox_app.dart';
import 'package:memox_v4/core/constants/app_constants.dart';
import 'package:memox_v4/presentation/shared/foundation_screen.dart';

void main() {
  testWidgets('boots to the foundation root, not the Flutter counter', (
    tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: MemoXApp()));
    await tester.pumpAndSettle();

    // Root app is up and the router landed on the foundation placeholder.
    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.byType(FoundationScreen), findsOneWidget);
    expect(find.text(AppConstants.appName), findsOneWidget);

    // No remnants of the default Flutter counter scaffold.
    expect(find.byType(FloatingActionButton), findsNothing);
    expect(find.byIcon(Icons.add), findsNothing);
    expect(find.text('0'), findsNothing);
  });
}
