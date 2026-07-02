import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:memox_v4/core/theme/mx_colors.dart';
import 'package:memox_v4/main.dart';

/// Confirms the Tier-0 tokens are actually applied by [MemoxApp]: the app
/// renders without error, and the scaffold background is driven by the token
/// value for the active theme (light by default, dark after the toggle).
void main() {
  Color scaffoldBg(WidgetTester tester) {
    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
    final ctx = tester.element(find.byType(Scaffold));
    return scaffold.backgroundColor ?? Theme.of(ctx).scaffoldBackgroundColor;
  }

  testWidgets('renders and applies light tokens', (tester) async {
    await tester.pumpWidget(const MemoxApp());

    expect(find.text('MemoX'), findsOneWidget);
    expect(find.text('primary'), findsOneWidget);
    expect(scaffoldBg(tester), MxColors.light.bg);
  });

  testWidgets('toggling switches to dark tokens', (tester) async {
    await tester.pumpWidget(const MemoxApp());

    await tester.tap(find.byIcon(Icons.dark_mode));
    await tester.pumpAndSettle();

    expect(scaffoldBg(tester), MxColors.dark.bg);
    expect(find.byIcon(Icons.light_mode), findsOneWidget);
  });
}
