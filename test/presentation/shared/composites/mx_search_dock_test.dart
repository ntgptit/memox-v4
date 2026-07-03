import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:memox_v4/core/theme/app_theme.dart';
import 'package:memox_v4/core/theme/mx_colors.dart';
import 'package:memox_v4/presentation/shared/composites/mx_search_dock.dart';

Future<void> _pump(WidgetTester tester, Widget dock, {bool dark = false}) {
  return tester.pumpWidget(
    MaterialApp(
      theme: dark ? AppTheme.dark : AppTheme.light,
      home: Scaffold(body: Center(child: dock)),
    ),
  );
}

BoxDecoration _decoration(WidgetTester tester) {
  final container = tester.widget<Container>(
    find.descendant(of: find.byType(MxSearchDock), matching: find.byType(Container)),
  );
  return container.decoration! as BoxDecoration;
}

void main() {
  testWidgets('renders the search glyph, placeholder, and trailing slot', (tester) async {
    await _pump(
      tester,
      const MxSearchDock(placeholder: 'Search cards', trailing: Icon(Icons.tune)),
    );
    expect(find.byIcon(Icons.search), findsOneWidget);
    expect(find.text('Search cards'), findsOneWidget); // hint
    expect(find.byIcon(Icons.tune), findsOneWidget);
  });

  group('surface variant → tokens (light)', () {
    testWidgets('elevated (default) = surface + shadow', (tester) async {
      await _pump(tester, const MxSearchDock(placeholder: 'Search'));
      final deco = _decoration(tester);
      expect(deco.color, MxColors.light.surface);
      expect(deco.boxShadow, isNotNull);
    });

    testWidgets('flat = surfaceMuted + no shadow', (tester) async {
      await _pump(tester, const MxSearchDock(placeholder: 'Search', flat: true));
      final deco = _decoration(tester);
      expect(deco.color, MxColors.light.surfaceMuted);
      expect(deco.boxShadow, isNull);
    });

    testWidgets('dark uses dark tokens', (tester) async {
      await _pump(tester, const MxSearchDock(placeholder: 'Search'), dark: true);
      expect(_decoration(tester).color, MxColors.dark.surface);
    });
  });

  testWidgets('focused adds the focus-ring shadow', (tester) async {
    await _pump(tester, const MxSearchDock(placeholder: 'Search', focused: true));
    final shadows = _decoration(tester).boxShadow!;
    expect(shadows.any((s) => s.color == MxColors.light.focusRing && s.spreadRadius == 3), isTrue);
  });

  testWidgets('typing fires onChanged', (tester) async {
    String? typed;
    await _pump(tester, MxSearchDock(placeholder: 'Search', onChanged: (v) => typed = v));
    await tester.enterText(find.byType(TextField), 'neko');
    expect(typed, 'neko');
  });
}
