import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:memox_v4/core/theme/app_theme.dart';
import 'package:memox_v4/core/theme/mx_colors.dart';
import 'package:memox_v4/presentation/shared/composites/mx_section_header.dart';

Future<void> _pump(WidgetTester tester, Widget header, {bool dark = false}) {
  return tester.pumpWidget(
    MaterialApp(
      theme: dark ? AppTheme.dark : AppTheme.light,
      home: Scaffold(body: Center(child: header)),
    ),
  );
}

Color _color(WidgetTester tester, String text) =>
    tester.widget<Text>(find.text(text)).style!.color!;

void main() {
  testWidgets('renders the title in the text color', (tester) async {
    await _pump(tester, const MxSectionHeader(title: 'Decks'));
    expect(find.text('Decks'), findsOneWidget);
    expect(_color(tester, 'Decks'), MxColors.light.text);
  });

  group('caption', () {
    testWidgets('renders in textSecondary when given', (tester) async {
      await _pump(tester, const MxSectionHeader(title: 'Decks', caption: '3 due'));
      expect(find.text('3 due'), findsOneWidget);
      expect(_color(tester, '3 due'), MxColors.light.textSecondary);
    });

    testWidgets('absent when null', (tester) async {
      await _pump(tester, const MxSectionHeader(title: 'Decks'));
      expect(find.byType(Text), findsOneWidget); // title only
    });
  });

  group('action', () {
    testWidgets('renders a primaryStrong text action that fires', (tester) async {
      var taps = 0;
      await _pump(
        tester,
        MxSectionHeader(title: 'Decks', actionLabel: 'See all', onAction: () => taps++),
      );
      expect(find.widgetWithText(TextButton, 'See all'), findsOneWidget);
      expect(
        tester.widget<TextButton>(find.byType(TextButton)).style!.foregroundColor!.resolve({}),
        MxColors.light.primaryStrong,
      );
      await tester.tap(find.text('See all'));
      expect(taps, 1);
    });

    testWidgets('no action button when actionLabel is null', (tester) async {
      await _pump(tester, const MxSectionHeader(title: 'Decks'));
      expect(find.byType(TextButton), findsNothing);
    });
  });

  testWidgets('dark uses dark tokens', (tester) async {
    await _pump(tester, const MxSectionHeader(title: 'Decks', caption: '3 due'), dark: true);
    expect(_color(tester, '3 due'), MxColors.dark.textSecondary);
  });
}
