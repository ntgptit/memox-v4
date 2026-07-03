import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:memox_v4/core/theme/app_theme.dart';
import 'package:memox_v4/core/theme/mx_colors.dart';
import 'package:memox_v4/core/theme/mx_elevation.dart';
import 'package:memox_v4/presentation/shared/composites/mx_card.dart';

Future<void> _pump(WidgetTester tester, Widget card, {bool dark = false}) {
  return tester.pumpWidget(
    MaterialApp(
      theme: dark ? AppTheme.dark : AppTheme.light,
      home: Scaffold(body: Center(child: card)),
    ),
  );
}

BoxDecoration _decoration(WidgetTester tester) {
  final box = tester.widget<DecoratedBox>(
    find.descendant(of: find.byType(MxCard), matching: find.byType(DecoratedBox)).first,
  );
  return box.decoration as BoxDecoration;
}

void main() {
  group('variant → tokens (light)', () {
    testWidgets('elevated = surface + card shadow', (tester) async {
      await _pump(tester, const MxCard(child: Text('x')));
      final deco = _decoration(tester);
      expect(deco.color, MxColors.light.surface);
      expect(deco.boxShadow, MxShadows.light.card);
      expect(deco.border, isNull);
    });

    testWidgets('flat = surface + border, no shadow', (tester) async {
      await _pump(tester, const MxCard(variant: MxCardVariant.flat, child: Text('x')));
      final deco = _decoration(tester);
      expect(deco.color, MxColors.light.surface);
      expect(deco.boxShadow, isNull);
      expect((deco.border! as Border).top.color, MxColors.light.border);
    });

    testWidgets('muted = surfaceMuted, no shadow', (tester) async {
      await _pump(tester, const MxCard(variant: MxCardVariant.muted, child: Text('x')));
      final deco = _decoration(tester);
      expect(deco.color, MxColors.light.surfaceMuted);
      expect(deco.boxShadow, isNull);
    });

    testWidgets('primary = primary + fab shadow', (tester) async {
      await _pump(tester, const MxCard(variant: MxCardVariant.primary, child: Text('x')));
      final deco = _decoration(tester);
      expect(deco.color, MxColors.light.primary);
      expect(deco.boxShadow, MxShadows.light.fab);
    });

    testWidgets('primary-soft = primarySoft, no shadow', (tester) async {
      await _pump(tester, const MxCard(variant: MxCardVariant.primarySoft, child: Text('x')));
      final deco = _decoration(tester);
      expect(deco.color, MxColors.light.primarySoft);
      expect(deco.boxShadow, isNull);
    });
  });

  testWidgets('dark uses dark tokens', (tester) async {
    await _pump(tester, const MxCard(child: Text('x')), dark: true);
    expect(_decoration(tester).color, MxColors.dark.surface);
  });

  group('interactive', () {
    testWidgets('actionable card = Material(bg) + InkWell + button semantics; fires', (tester) async {
      var taps = 0;
      await _pump(
        tester,
        MxCard(
          variant: MxCardVariant.primary,
          onPressed: () => taps++,
          semanticLabel: 'Open deck',
          child: const Text('Tap'),
        ),
      );

      final material = tester.widget<Material>(
        find.descendant(of: find.byType(MxCard), matching: find.byType(Material)),
      );
      expect(material.color, MxColors.light.primary);
      expect(find.byType(InkWell), findsOneWidget);
      expect(
        find.byWidgetPredicate((w) => w is Semantics && w.properties.button == true && w.properties.label == 'Open deck'),
        findsOneWidget,
      );

      await tester.tap(find.text('Tap'));
      expect(taps, 1);
    });

    testWidgets('non-interactive card has no InkWell', (tester) async {
      await _pump(tester, const MxCard(child: Text('x')));
      expect(find.byType(InkWell), findsNothing);
    });
  });

  testWidgets('foreground color reaches the content (primary → onPrimary)', (tester) async {
    await _pump(tester, const MxCard(variant: MxCardVariant.primary, child: Text('x')));
    expect(
      find.byWidgetPredicate((w) => w is DefaultTextStyle && w.style.color == MxColors.light.onPrimary),
      findsWidgets,
    );
  });
}
