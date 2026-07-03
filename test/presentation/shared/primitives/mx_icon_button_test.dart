import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:memox_v4/core/theme/app_theme.dart';
import 'package:memox_v4/core/theme/mx_colors.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_icon_button.dart';

Future<void> _pump(WidgetTester tester, Widget button, {bool dark = false}) {
  return tester.pumpWidget(
    MaterialApp(
      theme: dark ? AppTheme.dark : AppTheme.light,
      home: Scaffold(body: Center(child: button)),
    ),
  );
}

ButtonStyle _style(WidgetTester tester) =>
    tester.widget<IconButton>(find.byType(IconButton)).style!;

void main() {
  group('variant → tokens (light)', () {
    testWidgets('plain = transparent bg, text fg', (tester) async {
      await _pump(tester, const MxIconButton(icon: Icons.close, semanticLabel: 'Close'));
      final style = _style(tester);
      expect(style.backgroundColor!.resolve({}), Colors.transparent);
      expect(style.foregroundColor!.resolve({}), MxColors.light.text);
    });

    testWidgets('filled = surface bg', (tester) async {
      await _pump(tester, const MxIconButton(
        icon: Icons.close,
        semanticLabel: 'Close',
        variant: MxIconButtonVariant.filled,
      ));
      expect(_style(tester).backgroundColor!.resolve({}), MxColors.light.surface);
    });

    testWidgets('primary = primarySoft bg, onPrimarySoft fg', (tester) async {
      await _pump(tester, const MxIconButton(
        icon: Icons.add,
        semanticLabel: 'Add',
        variant: MxIconButtonVariant.primary,
      ));
      final style = _style(tester);
      expect(style.backgroundColor!.resolve({}), MxColors.light.primarySoft);
      expect(style.foregroundColor!.resolve({}), MxColors.light.onPrimarySoft);
    });
  });

  testWidgets('dark variant uses dark tokens', (tester) async {
    await _pump(
      tester,
      const MxIconButton(icon: Icons.add, semanticLabel: 'Add', variant: MxIconButtonVariant.primary),
      dark: true,
    );
    expect(_style(tester).backgroundColor!.resolve({}), MxColors.dark.primarySoft);
  });

  group('accessibility + size', () {
    testWidgets('exposes the ARIA label as a tooltip (not the glyph name)', (tester) async {
      await _pump(tester, const MxIconButton(icon: Icons.arrow_back, semanticLabel: 'Back'));
      expect(find.byTooltip('Back'), findsOneWidget);
    });

    testWidgets('disabled when onPressed is null; fires otherwise', (tester) async {
      await _pump(tester, const MxIconButton(icon: Icons.close, semanticLabel: 'Close'));
      expect(tester.widget<IconButton>(find.byType(IconButton)).onPressed, isNull);

      var taps = 0;
      await _pump(tester, MxIconButton(icon: Icons.close, semanticLabel: 'Close', onPressed: () => taps++));
      await tester.tap(find.byType(IconButton));
      expect(taps, 1);
    });

    testWidgets('small variant is a 36px square', (tester) async {
      await _pump(tester, const MxIconButton(
        icon: Icons.close,
        semanticLabel: 'Close',
        size: MxIconButtonSize.small,
      ));
      final size = _style(tester).fixedSize!.resolve({})!;
      expect(size, const Size(36, 36));
    });
  });
}
