import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:memox_v4/core/theme/app_theme.dart';
import 'package:memox_v4/core/theme/mx_colors.dart';
import 'package:memox_v4/presentation/shared/composites/mx_bottom_nav.dart';

const _items = [
  MxBottomNavItem(id: 'today', label: 'Today', icon: Icons.today),
  MxBottomNavItem(id: 'library', label: 'Library', icon: Icons.folder),
];

Future<void> _pump(
  WidgetTester tester, {
  String? value = 'today',
  ValueChanged<String>? onChanged,
  bool dark = false,
}) {
  return tester.pumpWidget(
    MaterialApp(
      theme: dark ? AppTheme.dark : AppTheme.light,
      home: Scaffold(
        bottomNavigationBar: MxBottomNav(items: _items, value: value, onChanged: onChanged),
      ),
    ),
  );
}

Color _iconColor(WidgetTester tester, IconData icon) =>
    tester.widget<Icon>(find.byIcon(icon)).color!;

void main() {
  testWidgets('renders every destination (icon + label)', (tester) async {
    await _pump(tester);
    expect(find.text('Today'), findsOneWidget);
    expect(find.text('Library'), findsOneWidget);
    expect(find.byIcon(Icons.today), findsOneWidget);
    expect(find.byIcon(Icons.folder), findsOneWidget);
  });

  group('active vs inactive → tokens (light)', () {
    testWidgets('active = primaryStrong + primarySoft icon pill; inactive = textTertiary', (tester) async {
      await _pump(tester, value: 'today');
      expect(_iconColor(tester, Icons.today), MxColors.light.primaryStrong);
      expect(_iconColor(tester, Icons.folder), MxColors.light.textTertiary);

      // exactly one active icon pill, tinted primarySoft
      expect(
        find.byWidgetPredicate((w) =>
            w is Container &&
            w.decoration is BoxDecoration &&
            (w.decoration! as BoxDecoration).color == MxColors.light.primarySoft),
        findsOneWidget,
      );
    });

    testWidgets('dark uses dark tokens', (tester) async {
      await _pump(tester, value: 'today', dark: true);
      expect(_iconColor(tester, Icons.today), MxColors.dark.primaryStrong);
    });
  });

  testWidgets('the bar surface + nav shadow come from tokens', (tester) async {
    await _pump(tester);
    final deco = tester
        .widget<DecoratedBox>(
          find.descendant(of: find.byType(MxBottomNav), matching: find.byType(DecoratedBox)).first,
        )
        .decoration as BoxDecoration;
    expect(deco.color, MxColors.light.surface);
    expect(deco.boxShadow, isNotNull);
  });

  group('interaction + a11y', () {
    testWidgets('tapping a destination fires onChanged with its id', (tester) async {
      String? picked;
      await _pump(tester, value: 'today', onChanged: (id) => picked = id);
      await tester.tap(find.text('Library'));
      expect(picked, 'library');
    });

    testWidgets('each destination carries selected tab semantics', (tester) async {
      await _pump(tester, value: 'today');
      expect(
        find.byWidgetPredicate((w) =>
            w is Semantics && w.properties.selected == true && w.properties.label == 'Today'),
        findsOneWidget,
      );
      expect(
        find.byWidgetPredicate((w) =>
            w is Semantics && w.properties.selected == false && w.properties.label == 'Library'),
        findsOneWidget,
      );
    });
  });
}
