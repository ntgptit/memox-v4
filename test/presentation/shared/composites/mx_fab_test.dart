import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:memox_v4/core/theme/app_theme.dart';
import 'package:memox_v4/core/theme/mx_colors.dart';
import 'package:memox_v4/presentation/shared/composites/mx_fab.dart';

Future<void> _pump(WidgetTester tester, Widget fab, {bool dark = false}) {
  return tester.pumpWidget(
    MaterialApp(
      theme: dark ? AppTheme.dark : AppTheme.light,
      home: Scaffold(body: Center(child: fab)),
    ),
  );
}

Material _material(WidgetTester tester) => tester.widget<Material>(
      find.descendant(of: find.byType(MxFab), matching: find.byType(Material)),
    );

void main() {
  group('round vs extended', () {
    testWidgets('no label = round (circle, 60px, icon only)', (tester) async {
      await _pump(tester, const MxFab(icon: Icons.add, semanticLabel: 'Add'));
      expect(_material(tester).shape, isA<CircleBorder>());
      expect(tester.getSize(find.byType(MxFab)), const Size(60, 60));
      expect(find.byType(Text), findsNothing);
    });

    testWidgets('label = extended (rounded rect, icon + label)', (tester) async {
      await _pump(tester, const MxFab(icon: Icons.add, label: 'Add card'));
      expect(_material(tester).shape, isA<RoundedRectangleBorder>());
      expect(find.text('Add card'), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('round:true forces the round shape even with a label', (tester) async {
      await _pump(tester, const MxFab(icon: Icons.add, label: 'Add', round: true, semanticLabel: 'Add'));
      expect(_material(tester).shape, isA<CircleBorder>());
      expect(find.text('Add'), findsNothing);
    });
  });

  group('variant → tokens (light)', () {
    testWidgets('primary = primary fill', (tester) async {
      await _pump(tester, const MxFab(icon: Icons.add, semanticLabel: 'Add'));
      expect(_material(tester).color, MxColors.light.primary);
    });

    testWidgets('accent = accent fill', (tester) async {
      await _pump(tester, const MxFab(icon: Icons.add, variant: MxFabVariant.accent, semanticLabel: 'Add'));
      expect(_material(tester).color, MxColors.light.accent);
    });

    testWidgets('dark uses dark tokens', (tester) async {
      await _pump(tester, const MxFab(icon: Icons.add, semanticLabel: 'Add'), dark: true);
      expect(_material(tester).color, MxColors.dark.primary);
    });
  });

  testWidgets('carries the fab shadow', (tester) async {
    await _pump(tester, const MxFab(icon: Icons.add, semanticLabel: 'Add'));
    final decoration = tester
        .widget<DecoratedBox>(find.descendant(of: find.byType(MxFab), matching: find.byType(DecoratedBox)).first)
        .decoration as ShapeDecoration;
    expect(decoration.shadows, isNotEmpty);
  });

  group('interaction + a11y', () {
    testWidgets('fires onPressed', (tester) async {
      var taps = 0;
      await _pump(tester, MxFab(icon: Icons.add, semanticLabel: 'Add', onPressed: () => taps++));
      await tester.tap(find.byType(MxFab));
      expect(taps, 1);
    });

    testWidgets('round fab exposes the semantic label', (tester) async {
      await _pump(tester, const MxFab(icon: Icons.add, semanticLabel: 'Add card'));
      expect(
        find.byWidgetPredicate((w) => w is Semantics && w.properties.button == true && w.properties.label == 'Add card'),
        findsOneWidget,
      );
    });
  });
}
