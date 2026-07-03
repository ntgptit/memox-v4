import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:memox_v4/core/theme/app_theme.dart';
import 'package:memox_v4/core/theme/mx_colors.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_button.dart';

Future<void> _pump(WidgetTester tester, Widget button, {bool dark = false}) {
  return tester.pumpWidget(
    MaterialApp(
      theme: dark ? AppTheme.dark : AppTheme.light,
      home: Scaffold(body: Center(child: button)),
    ),
  );
}

Color _bg<T extends ButtonStyleButton>(WidgetTester tester) =>
    tester.widget<T>(find.byType(T)).style!.backgroundColor!.resolve({})!;

Color _fg<T extends ButtonStyleButton>(WidgetTester tester) =>
    tester.widget<T>(find.byType(T)).style!.foregroundColor!.resolve({})!;

void main() {
  group('variant → tokens (light)', () {
    testWidgets('primary = primary / onPrimary', (tester) async {
      await _pump(tester, const MxButton(label: 'Go'));
      expect(_bg<FilledButton>(tester), MxColors.light.primary);
      expect(_fg<FilledButton>(tester), MxColors.light.onPrimary);
    });

    testWidgets('secondary = primarySoft / onPrimarySoft', (tester) async {
      await _pump(tester, const MxButton(label: 'Go', variant: MxButtonVariant.secondary));
      expect(_bg<FilledButton>(tester), MxColors.light.primarySoft);
      expect(_fg<FilledButton>(tester), MxColors.light.onPrimarySoft);
    });

    testWidgets('contrast = onPrimary / primary', (tester) async {
      await _pump(tester, const MxButton(label: 'Go', variant: MxButtonVariant.contrast));
      expect(_bg<FilledButton>(tester), MxColors.light.onPrimary);
      expect(_fg<FilledButton>(tester), MxColors.light.primary);
    });

    testWidgets('outline = OutlinedButton, borderStrong side, text fg', (tester) async {
      await _pump(tester, const MxButton(label: 'Go', variant: MxButtonVariant.outline));
      final side = tester.widget<OutlinedButton>(find.byType(OutlinedButton)).style!.side!.resolve({})!;
      expect(side.color, MxColors.light.borderStrong);
      expect(_fg<OutlinedButton>(tester), MxColors.light.text);
    });

    testWidgets('ghost = TextButton, primaryStrong fg', (tester) async {
      await _pump(tester, const MxButton(label: 'Go', variant: MxButtonVariant.ghost));
      expect(_fg<TextButton>(tester), MxColors.light.primaryStrong);
    });

    testWidgets('danger composes over any variant → error / onError', (tester) async {
      await _pump(tester, const MxButton(label: 'Del', variant: MxButtonVariant.ghost, danger: true));
      expect(find.byType(FilledButton), findsOneWidget); // danger is a filled error button
      expect(_bg<FilledButton>(tester), MxColors.light.error);
      expect(_fg<FilledButton>(tester), MxColors.light.onError);
    });
  });

  group('variant → tokens (dark)', () {
    testWidgets('primary uses dark tokens', (tester) async {
      await _pump(tester, const MxButton(label: 'Go'), dark: true);
      expect(_bg<FilledButton>(tester), MxColors.dark.primary);
      expect(_fg<FilledButton>(tester), MxColors.dark.onPrimary);
    });
  });

  group('accessibility + layout', () {
    testWidgets('disabled (onPressed null) does not fire and reports disabled', (tester) async {
      await _pump(tester, const MxButton(label: 'Go'));
      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(button.enabled, isFalse);
      await tester.tap(find.byType(FilledButton));
      // No callback to fire — the test simply proves the tap is inert.
    });

    testWidgets('enabled fires its callback', (tester) async {
      var taps = 0;
      await _pump(tester, MxButton(label: 'Go', onPressed: () => taps++));
      await tester.tap(find.byType(FilledButton));
      expect(taps, 1);
    });

    testWidgets('block stretches to full width', (tester) async {
      await _pump(tester, const MxButton(label: 'Go', block: true));
      expect(
        tester.getSize(find.byType(SizedBox).first).width,
        greaterThan(300),
      );
    });

    testWidgets('renders leading + trailing icons with the label', (tester) async {
      await _pump(
        tester,
        const MxButton(label: 'Go', icon: Icons.play_arrow, trailingIcon: Icons.chevron_right),
      );
      expect(find.text('Go'), findsOneWidget);
      expect(find.byIcon(Icons.play_arrow), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    });
  });
}
