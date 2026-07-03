import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:memox_v4/core/theme/app_theme.dart';
import 'package:memox_v4/core/theme/mx_colors.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_badge.dart';

Future<void> _pump(WidgetTester tester, Widget badge, {bool dark = false}) {
  return tester.pumpWidget(
    MaterialApp(
      theme: dark ? AppTheme.dark : AppTheme.light,
      home: Scaffold(body: Center(child: badge)),
    ),
  );
}

BoxDecoration _decoration(WidgetTester tester) {
  final container = tester.widget<Container>(
    find.descendant(of: find.byType(MxBadge), matching: find.byType(Container)),
  );
  return container.decoration! as BoxDecoration;
}

Color _textColor(WidgetTester tester) =>
    tester.widget<Text>(find.descendant(of: find.byType(MxBadge), matching: find.byType(Text))).style!.color!;

void main() {
  group('tone × solid/soft → tokens (light)', () {
    testWidgets('neutral solid = primary/onPrimary; soft = primarySoft', (tester) async {
      await _pump(tester, const MxBadge(label: '3'));
      expect(_decoration(tester).color, MxColors.light.primary);
      expect(_textColor(tester), MxColors.light.onPrimary);

      await _pump(tester, const MxBadge(label: '3', soft: true));
      expect(_decoration(tester).color, MxColors.light.primarySoft);
    });

    testWidgets('success/warning/error solids use the tone tokens', (tester) async {
      await _pump(tester, const MxBadge(label: 'ok', tone: MxBadgeTone.success));
      expect(_decoration(tester).color, MxColors.light.success);

      await _pump(tester, const MxBadge(label: '!', tone: MxBadgeTone.warning));
      expect(_decoration(tester).color, MxColors.light.warning);

      await _pump(tester, const MxBadge(label: 'x', tone: MxBadgeTone.error));
      expect(_decoration(tester).color, MxColors.light.error);
    });

    testWidgets('soft tones use the soft tokens', (tester) async {
      await _pump(tester, const MxBadge(label: 'ok', tone: MxBadgeTone.success, soft: true));
      expect(_decoration(tester).color, MxColors.light.successSoft);
      expect(_textColor(tester), MxColors.light.onSuccessSoft);
    });
  });

  testWidgets('dark uses dark tokens', (tester) async {
    await _pump(tester, const MxBadge(label: '3'), dark: true);
    expect(_decoration(tester).color, MxColors.dark.primary);
  });

  group('dot form', () {
    testWidgets('is a 10px circle with no text', (tester) async {
      await _pump(tester, const MxBadge(dot: true, tone: MxBadgeTone.error));
      expect(tester.getSize(find.byType(MxBadge)), const Size(10, 10));
      expect(_decoration(tester).shape, BoxShape.circle);
      expect(_decoration(tester).color, MxColors.light.error);
      expect(find.byType(Text), findsNothing);
    });
  });

  testWidgets('label renders as the count text', (tester) async {
    await _pump(tester, const MxBadge(label: '12'));
    expect(find.text('12'), findsOneWidget);
  });
}
