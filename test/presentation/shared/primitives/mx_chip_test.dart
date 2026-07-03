import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:memox_v4/core/theme/app_theme.dart';
import 'package:memox_v4/core/theme/mx_colors.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_chip.dart';

Future<void> _pump(WidgetTester tester, Widget chip, {bool dark = false}) {
  return tester.pumpWidget(
    MaterialApp(
      theme: dark ? AppTheme.dark : AppTheme.light,
      home: Scaffold(body: Center(child: chip)),
    ),
  );
}

Material _material(WidgetTester tester) => tester.widget<Material>(
      find.descendant(of: find.byType(MxChip), matching: find.byType(Material)).first,
    );

Color _bg(WidgetTester tester) => _material(tester).color!;
BorderSide _side(WidgetTester tester) => (_material(tester).shape! as StadiumBorder).side;
Color _textColor(WidgetTester tester) => tester
    .widget<Text>(find.descendant(of: find.byType(MxChip), matching: find.byType(Text)))
    .style!
    .color!;

void main() {
  group('state → tokens (light)', () {
    testWidgets('standard unselected = surface + border, textSecondary', (tester) async {
      await _pump(tester, const MxChip(label: 'All'));
      expect(_bg(tester), MxColors.light.surface);
      expect(_side(tester).color, MxColors.light.border);
      expect(_textColor(tester), MxColors.light.textSecondary);
    });

    testWidgets('selected = primarySoft, onPrimarySoft, no border', (tester) async {
      await _pump(tester, const MxChip(label: 'Due', selected: true));
      expect(_bg(tester), MxColors.light.primarySoft);
      expect(_textColor(tester), MxColors.light.onPrimarySoft);
      expect(_side(tester).style, BorderStyle.none);
    });

    testWidgets('accent = accentSoft, no border (precedes selected)', (tester) async {
      await _pump(tester, const MxChip(label: 'New', variant: MxChipVariant.accent, selected: true));
      expect(_bg(tester), MxColors.light.accentSoft);
      expect(_side(tester).style, BorderStyle.none);
    });

    testWidgets('ghost = transparent + border', (tester) async {
      await _pump(tester, const MxChip(label: 'Ghost', variant: MxChipVariant.ghost));
      expect(_bg(tester), Colors.transparent);
      expect(_side(tester).color, MxColors.light.border);
    });
  });

  testWidgets('dark uses dark tokens', (tester) async {
    await _pump(tester, const MxChip(label: 'Due', selected: true), dark: true);
    expect(_bg(tester), MxColors.dark.primarySoft);
  });

  group('interaction + a11y', () {
    testWidgets('exposes selected + button semantics; fires onPressed', (tester) async {
      var taps = 0;
      await _pump(tester, MxChip(label: 'Due', selected: true, onPressed: () => taps++));

      expect(
        find.byWidgetPredicate(
          (w) => w is Semantics && w.properties.button == true && w.properties.selected == true,
        ),
        findsOneWidget,
      );

      await tester.tap(find.byType(MxChip));
      expect(taps, 1);
    });

    testWidgets('renders a leading icon + label', (tester) async {
      await _pump(tester, const MxChip(label: 'Filter', icon: Icons.filter_list));
      expect(find.text('Filter'), findsOneWidget);
      expect(find.byIcon(Icons.filter_list), findsOneWidget);
    });

    testWidgets('is 34px tall', (tester) async {
      await _pump(tester, const MxChip(label: 'All'));
      expect(tester.getSize(find.byType(SizedBox).first).height, 34);
    });
  });
}
