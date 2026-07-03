import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:memox_v4/core/theme/app_theme.dart';
import 'package:memox_v4/core/theme/mx_colors.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_skeleton.dart';

Future<void> _pump(
  WidgetTester tester,
  Widget skeleton, {
  bool dark = false,
  bool reduceMotion = false,
}) {
  return tester.pumpWidget(
    MaterialApp(
      theme: dark ? AppTheme.dark : AppTheme.light,
      home: MediaQuery(
        data: MediaQueryData(disableAnimations: reduceMotion),
        child: Scaffold(body: Center(child: SizedBox(width: 200, child: skeleton))),
      ),
    ),
  );
}

BoxDecoration _decoration(WidgetTester tester) {
  final container = tester.widget<Container>(
    find.descendant(of: find.byType(MxSkeleton), matching: find.byType(Container)),
  );
  return container.decoration! as BoxDecoration;
}

void main() {
  testWidgets('renders a sunken rounded block that pulses', (tester) async {
    await _pump(tester, const MxSkeleton(height: 20, radius: 6));
    await tester.pump(); // one frame (animation is infinite — never settles)

    final deco = _decoration(tester);
    expect(deco.color, MxColors.light.surfaceSunken);
    expect(deco.borderRadius, BorderRadius.circular(6));
    expect(
      find.descendant(of: find.byType(MxSkeleton), matching: find.byType(FadeTransition)),
      findsOneWidget,
    );
    expect(tester.getSize(find.byType(MxSkeleton)).height, 20);
  });

  testWidgets('reduce-motion shows a static block (no FadeTransition)', (tester) async {
    await _pump(tester, const MxSkeleton(height: 16), reduceMotion: true);
    expect(
      find.descendant(of: find.byType(MxSkeleton), matching: find.byType(FadeTransition)),
      findsNothing,
    );
    expect(
      find.descendant(of: find.byType(MxSkeleton), matching: find.byType(Opacity)),
      findsOneWidget,
    );
  });

  testWidgets('dark uses dark tokens', (tester) async {
    await _pump(tester, const MxSkeleton(), dark: true);
    await tester.pump();
    expect(_decoration(tester).color, MxColors.dark.surfaceSunken);
  });
}
