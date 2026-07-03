import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:memox_v4/core/theme/app_theme.dart';
import 'package:memox_v4/core/theme/mx_colors.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_choice_option.dart';

Future<void> _pump(WidgetTester tester, Widget option, {bool dark = false}) {
  return tester.pumpWidget(
    MaterialApp(
      theme: dark ? AppTheme.dark : AppTheme.light,
      home: Scaffold(body: Center(child: SizedBox(width: 300, child: option))),
    ),
  );
}

Material _material(WidgetTester tester) => tester.widget<Material>(
      find.descendant(of: find.byType(MxChoiceOption), matching: find.byType(Material)),
    );

BorderSide _side(WidgetTester tester) =>
    (_material(tester).shape! as RoundedRectangleBorder).side;

void main() {
  testWidgets('default (none) = surface + hairline divider border, no icon', (tester) async {
    await _pump(tester, const MxChoiceOption(text: 'Seoul'));
    expect(_material(tester).color, MxColors.light.surface);
    final side = _side(tester);
    expect(side.color, MxColors.light.divider);
    expect(side.width, 1);
    expect(find.byIcon(Icons.check_circle), findsNothing);
    expect(find.byIcon(Icons.cancel), findsNothing);
  });

  testWidgets('correct = successSoft + success border + check icon', (tester) async {
    await _pump(tester, const MxChoiceOption(text: 'Seoul', tone: MxChoiceTone.correct));
    expect(_material(tester).color, MxColors.light.successSoft);
    final side = _side(tester);
    expect(side.color, MxColors.light.success);
    expect(side.width, 2);
    expect(find.byIcon(Icons.check_circle), findsOneWidget);
    expect(tester.widget<Text>(find.text('Seoul')).style!.color, MxColors.light.onSuccessSoft);
  });

  testWidgets('wrong = errorSoft + error border + cancel icon', (tester) async {
    await _pump(tester, const MxChoiceOption(text: 'Busan', tone: MxChoiceTone.wrong));
    expect(_material(tester).color, MxColors.light.errorSoft);
    expect(_side(tester).color, MxColors.light.error);
    expect(find.byIcon(Icons.cancel), findsOneWidget);
  });

  testWidgets('dark uses dark tokens', (tester) async {
    await _pump(tester, const MxChoiceOption(text: 'x'), dark: true);
    expect(_material(tester).color, MxColors.dark.surface);
  });

  group('interaction + a11y', () {
    testWidgets('fires onPressed and has a ≥48 tap target', (tester) async {
      var taps = 0;
      await _pump(tester, MxChoiceOption(text: 'Seoul', onPressed: () => taps++));
      expect(tester.getSize(find.byType(MxChoiceOption)).height, greaterThanOrEqualTo(48));
      await tester.tap(find.byType(InkWell));
      expect(taps, 1);
    });

    testWidgets('carries mutually-exclusive radio semantics; selected once graded', (tester) async {
      await _pump(tester, const MxChoiceOption(text: 'Seoul', tone: MxChoiceTone.correct));
      expect(
        find.byWidgetPredicate((w) =>
            w is Semantics &&
            w.properties.inMutuallyExclusiveGroup == true &&
            w.properties.selected == true &&
            w.properties.label == 'Seoul'),
        findsOneWidget,
      );

      await _pump(tester, const MxChoiceOption(text: 'Seoul'));
      expect(
        find.byWidgetPredicate((w) => w is Semantics && w.properties.selected == false && w.properties.label == 'Seoul'),
        findsOneWidget,
      );
    });
  });
}
