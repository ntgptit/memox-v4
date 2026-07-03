import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:memox_v4/core/theme/app_theme.dart';
import 'package:memox_v4/core/theme/mx_colors.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_switch.dart';

Future<void> _pump(WidgetTester tester, Widget sw, {bool dark = false}) {
  return tester.pumpWidget(
    MaterialApp(
      theme: dark ? AppTheme.dark : AppTheme.light,
      home: Scaffold(body: Center(child: sw)),
    ),
  );
}

Switch _switch(WidgetTester tester) => tester.widget<Switch>(find.byType(Switch));

void main() {
  const on = {WidgetState.selected};
  const off = <WidgetState>{};

  group('track/thumb → tokens (light)', () {
    testWidgets('off = surfaceSunken track, textTertiary thumb, border outline', (tester) async {
      await _pump(tester, MxSwitch(value: false, onChanged: (_) {}));
      final sw = _switch(tester);
      expect(sw.trackColor!.resolve(off), MxColors.light.surfaceSunken);
      expect(sw.thumbColor!.resolve(off), MxColors.light.textTertiary);
      expect(sw.trackOutlineColor!.resolve(off), MxColors.light.border);
    });

    testWidgets('on = primary track, onPrimary thumb, transparent outline', (tester) async {
      await _pump(tester, MxSwitch(value: true, onChanged: (_) {}));
      final sw = _switch(tester);
      expect(sw.trackColor!.resolve(on), MxColors.light.primary);
      expect(sw.thumbColor!.resolve(on), MxColors.light.onPrimary);
      expect(sw.trackOutlineColor!.resolve(on), Colors.transparent);
    });
  });

  testWidgets('dark uses dark tokens', (tester) async {
    await _pump(tester, MxSwitch(value: true, onChanged: (_) {}), dark: true);
    expect(_switch(tester).trackColor!.resolve(on), MxColors.dark.primary);
  });

  group('interaction + a11y', () {
    testWidgets('toggles via onChanged', (tester) async {
      bool? captured;
      await _pump(tester, MxSwitch(value: false, onChanged: (v) => captured = v));
      await tester.tap(find.byType(Switch));
      expect(captured, isTrue);
    });

    testWidgets('null onChanged disables + dims to 0.45', (tester) async {
      await _pump(tester, const MxSwitch(value: false));
      expect(_switch(tester).onChanged, isNull);
      expect(
        find.byWidgetPredicate((w) => w is Opacity && w.opacity == 0.45),
        findsOneWidget,
      );
    });

    testWidgets('exposes the semantic label', (tester) async {
      await _pump(tester, MxSwitch(value: true, semanticLabel: 'Dark mode', onChanged: (_) {}));
      expect(
        find.byWidgetPredicate((w) => w is Semantics && w.properties.label == 'Dark mode'),
        findsOneWidget,
      );
    });
  });
}
