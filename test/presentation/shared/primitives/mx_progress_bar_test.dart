import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:memox_v4/core/theme/app_theme.dart';
import 'package:memox_v4/core/theme/mx_colors.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_progress_bar.dart';

Future<void> _pump(WidgetTester tester, Widget bar, {bool dark = false}) {
  return tester.pumpWidget(
    MaterialApp(
      theme: dark ? AppTheme.dark : AppTheme.light,
      home: Scaffold(body: Center(child: SizedBox(width: 200, child: bar))),
    ),
  );
}

LinearProgressIndicator _indicator(WidgetTester tester) =>
    tester.widget<LinearProgressIndicator>(find.byType(LinearProgressIndicator));

void main() {
  testWidgets('renders a determinate bar with the value + token track/fill', (tester) async {
    await _pump(tester, const MxProgressBar(value: 0.4));
    final indicator = _indicator(tester);
    expect(indicator.value, 0.4);
    expect(indicator.backgroundColor, MxColors.light.surfaceSunken);
    expect(indicator.color, MxColors.light.primary);
  });

  testWidgets('clamps the value to 0..1', (tester) async {
    await _pump(tester, const MxProgressBar(value: 1.6));
    expect(_indicator(tester).value, 1.0);

    await _pump(tester, const MxProgressBar(value: -0.3));
    expect(_indicator(tester).value, 0.0);
  });

  testWidgets('a custom colour overrides the primary fill', (tester) async {
    await _pump(tester, MxProgressBar(value: 0.5, color: MxColors.light.success));
    expect(_indicator(tester).color, MxColors.light.success);
  });

  testWidgets('honours a custom height (minHeight)', (tester) async {
    await _pump(tester, const MxProgressBar(value: 0.5, height: 12));
    expect(_indicator(tester).minHeight, 12);
  });

  testWidgets('exposes a semantics label', (tester) async {
    await _pump(tester, const MxProgressBar(value: 0.5, semanticLabel: 'Study progress'));
    expect(_indicator(tester).semanticsLabel, 'Study progress');
  });

  testWidgets('dark uses dark tokens', (tester) async {
    await _pump(tester, const MxProgressBar(value: 0.5), dark: true);
    expect(_indicator(tester).backgroundColor, MxColors.dark.surfaceSunken);
  });
}
