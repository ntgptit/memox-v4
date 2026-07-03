import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:memox_v4/core/theme/app_theme.dart';
import 'package:memox_v4/core/theme/mx_colors.dart';
import 'package:memox_v4/core/theme/mx_spacing.dart';
import 'package:memox_v4/presentation/shared/composites/mx_app_bar.dart';

Future<void> _pump(WidgetTester tester, MxAppBar appBar, {bool dark = false}) {
  return tester.pumpWidget(
    MaterialApp(
      theme: dark ? AppTheme.dark : AppTheme.light,
      home: Scaffold(appBar: appBar, body: const SizedBox()),
    ),
  );
}

Color _titleColor(WidgetTester tester, String title) =>
    tester.widget<Text>(find.text(title)).style!.color!;

void main() {
  group('compact', () {
    testWidgets('renders the title + leading/trailing slots', (tester) async {
      await _pump(
        tester,
        const MxAppBar(
          title: 'Library',
          leading: Icon(Icons.menu),
          trailing: Icon(Icons.search),
        ),
      );
      expect(find.text('Library'), findsOneWidget);
      expect(find.byIcon(Icons.menu), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(_titleColor(tester, 'Library'), MxColors.light.text);
    });

    testWidgets('preferred height is the compact app-bar token', (tester) async {
      const bar = MxAppBar(title: 'x');
      expect(bar.preferredSize.height, MxSpacing.appBarHeight);
    });
  });

  group('large', () {
    testWidgets('renders eyebrow + large title + slot row', (tester) async {
      await _pump(
        tester,
        const MxAppBar(
          large: true,
          eyebrow: 'Good morning',
          title: 'Today',
          trailing: Icon(Icons.settings),
        ),
      );
      expect(find.text('Good morning'), findsOneWidget);
      expect(find.text('Today'), findsOneWidget);
      expect(find.byIcon(Icons.settings), findsOneWidget);
      expect(_titleColor(tester, 'Good morning'), MxColors.light.textSecondary);
    });

    testWidgets('preferred height is the large app-bar token', (tester) async {
      const bar = MxAppBar(large: true, title: 'x');
      expect(bar.preferredSize.height, MxSpacing.appBarLargeHeight);
    });
  });

  testWidgets('background comes from the bg token', (tester) async {
    await _pump(tester, const MxAppBar(title: 'x'));
    final material = tester.widget<Material>(
      find.descendant(of: find.byType(MxAppBar), matching: find.byType(Material)),
    );
    expect(material.color, MxColors.light.bg);
  });

  testWidgets('dark uses dark tokens', (tester) async {
    await _pump(tester, const MxAppBar(title: 'x'), dark: true);
    expect(_titleColor(tester, 'x'), MxColors.dark.text);
  });
}
