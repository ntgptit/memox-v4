import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:memox_v4/core/theme/app_theme.dart';
import 'package:memox_v4/core/theme/mx_colors.dart';
import 'package:memox_v4/presentation/shared/composites/action_callout.dart';

Future<void> _pump(WidgetTester tester, Widget callout, {bool dark = false}) {
  return tester.pumpWidget(
    MaterialApp(
      theme: dark ? AppTheme.dark : AppTheme.light,
      home: Scaffold(body: Center(child: callout)),
    ),
  );
}

BoxDecoration _decoration(WidgetTester tester) {
  final container = tester.widget<Container>(
    find.descendant(of: find.byType(MxActionCallout), matching: find.byType(Container)),
  );
  return container.decoration! as BoxDecoration;
}

Color _textColor(WidgetTester tester, String text) =>
    tester.widget<Text>(find.text(text)).style!.color!;

void main() {
  testWidgets('renders the icon + message', (tester) async {
    await _pump(tester, const MxActionCallout(icon: Icons.warning, text: '8 cards already exist'));
    expect(find.byIcon(Icons.warning), findsOneWidget);
    expect(find.text('8 cards already exist'), findsOneWidget);
  });

  group('tone → soft tokens (light)', () {
    testWidgets('warning (default) = warningSoft / onWarningSoft', (tester) async {
      await _pump(tester, const MxActionCallout(icon: Icons.warning, text: 'x'));
      expect(_decoration(tester).color, MxColors.light.warningSoft);
      expect(_textColor(tester, 'x'), MxColors.light.onWarningSoft);
    });

    testWidgets('success + error use their soft pairs', (tester) async {
      await _pump(tester, const MxActionCallout(icon: Icons.check, text: 'ok', tone: MxCalloutTone.success));
      expect(_decoration(tester).color, MxColors.light.successSoft);

      await _pump(tester, const MxActionCallout(icon: Icons.error, text: 'bad', tone: MxCalloutTone.error));
      expect(_decoration(tester).color, MxColors.light.errorSoft);
      expect(_textColor(tester, 'bad'), MxColors.light.onErrorSoft);
    });

    testWidgets('dark uses dark tokens', (tester) async {
      await _pump(tester, const MxActionCallout(icon: Icons.warning, text: 'x'), dark: true);
      expect(_decoration(tester).color, MxColors.dark.warningSoft);
    });
  });

  testWidgets('renders an optional trailing action', (tester) async {
    await _pump(
      tester,
      const MxActionCallout(
        icon: Icons.info,
        text: 'Needs 4 words',
        tone: MxCalloutTone.warning,
        action: Text('Add'),
      ),
    );
    expect(find.text('Add'), findsOneWidget);
  });

  testWidgets('no trailing widget when action is null', (tester) async {
    await _pump(tester, const MxActionCallout(icon: Icons.warning, text: 'x'));
    // icon + message text only
    expect(find.byType(Text), findsOneWidget);
  });
}
