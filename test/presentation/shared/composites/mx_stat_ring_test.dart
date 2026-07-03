import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:memox_v4/core/theme/app_theme.dart';
import 'package:memox_v4/core/theme/mx_colors.dart';
import 'package:memox_v4/presentation/shared/composites/mx_stat_ring.dart';

Future<void> _pump(WidgetTester tester, Widget ring, {bool dark = false}) {
  return tester.pumpWidget(
    MaterialApp(
      theme: dark ? AppTheme.dark : AppTheme.light,
      home: Scaffold(body: Center(child: ring)),
    ),
  );
}

CircularProgressIndicator _indicator(WidgetTester tester) =>
    tester.widget<CircularProgressIndicator>(find.byType(CircularProgressIndicator));

Color _valueColor(WidgetTester tester, String v) =>
    tester.widget<Text>(find.text(v)).style!.color!;

void main() {
  testWidgets('renders the ring + centered value + label', (tester) async {
    await _pump(tester, const MxStatRing(percent: 0.7, value: '5', label: 'day streak'));
    expect(find.text('5'), findsOneWidget);
    expect(find.text('day streak'), findsOneWidget);

    final indicator = _indicator(tester);
    expect(indicator.value, 0.7);
    expect(indicator.color, MxColors.light.primary);
    expect(indicator.backgroundColor, MxColors.light.surfaceSunken);
  });

  testWidgets('clamps percent to 0..1', (tester) async {
    await _pump(tester, const MxStatRing(percent: 1.4, value: '1', label: 'l'));
    expect(_indicator(tester).value, 1.0);
  });

  testWidgets('a custom colour tints the ring + value', (tester) async {
    await _pump(tester, MxStatRing(percent: 0.5, value: '9', label: 'l', color: MxColors.light.success));
    expect(_indicator(tester).color, MxColors.light.success);
    expect(_valueColor(tester, '9'), MxColors.light.success);
  });

  testWidgets('value defaults to onSurface; label = textSecondary', (tester) async {
    await _pump(tester, const MxStatRing(percent: 0.5, value: 'V', label: 'L'));
    expect(_valueColor(tester, 'V'), MxColors.light.text);
    expect(_valueColor(tester, 'L'), MxColors.light.textSecondary);
  });

  testWidgets('dark uses dark tokens', (tester) async {
    await _pump(tester, const MxStatRing(percent: 0.5, value: 'V', label: 'L'), dark: true);
    expect(_indicator(tester).backgroundColor, MxColors.dark.surfaceSunken);
  });
}
