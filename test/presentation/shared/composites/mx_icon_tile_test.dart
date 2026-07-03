import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:memox_v4/core/theme/app_theme.dart';
import 'package:memox_v4/core/theme/mx_colors.dart';
import 'package:memox_v4/presentation/shared/composites/mx_icon_tile.dart';

Future<void> _pump(WidgetTester tester, Widget tile, {bool dark = false}) {
  return tester.pumpWidget(
    MaterialApp(
      theme: dark ? AppTheme.dark : AppTheme.light,
      home: Scaffold(body: Center(child: tile)),
    ),
  );
}

BoxDecoration _decoration(WidgetTester tester) {
  final container = tester.widget<Container>(
    find.descendant(of: find.byType(MxIconTile), matching: find.byType(Container)),
  );
  return container.decoration! as BoxDecoration;
}

Color _iconColor(WidgetTester tester) =>
    tester.widget<Icon>(find.byType(Icon)).color!;

void main() {
  group('tone → tokens (light)', () {
    testWidgets('default = primarySoft/onPrimarySoft', (tester) async {
      await _pump(tester, const MxIconTile(icon: Icons.book));
      expect(_decoration(tester).color, MxColors.light.primarySoft);
      expect(_iconColor(tester), MxColors.light.onPrimarySoft);
    });

    testWidgets('success/warning/error use the soft tone tokens', (tester) async {
      await _pump(tester, const MxIconTile(icon: Icons.book, tone: MxIconTileTone.success));
      expect(_decoration(tester).color, MxColors.light.successSoft);

      await _pump(tester, const MxIconTile(icon: Icons.book, tone: MxIconTileTone.error));
      expect(_decoration(tester).color, MxColors.light.errorSoft);
      expect(_iconColor(tester), MxColors.light.onErrorSoft);
    });

    testWidgets('solid overrides the tone with primary/onPrimary', (tester) async {
      await _pump(tester, const MxIconTile(icon: Icons.book, tone: MxIconTileTone.error, solid: true));
      expect(_decoration(tester).color, MxColors.light.primary);
      expect(_iconColor(tester), MxColors.light.onPrimary);
    });
  });

  testWidgets('dark uses dark tokens', (tester) async {
    await _pump(tester, const MxIconTile(icon: Icons.book), dark: true);
    expect(_decoration(tester).color, MxColors.dark.primarySoft);
  });

  group('sizes', () {
    testWidgets('medium = 48px, tile radius', (tester) async {
      await _pump(tester, const MxIconTile(icon: Icons.book));
      expect(tester.getSize(find.byType(MxIconTile)), const Size(48, 48));
      expect(_decoration(tester).borderRadius, const BorderRadius.all(Radius.circular(16)));
    });

    testWidgets('large = 60px, lg radius', (tester) async {
      await _pump(tester, const MxIconTile(icon: Icons.book, size: MxIconTileSize.large));
      expect(tester.getSize(find.byType(MxIconTile)), const Size(60, 60));
      expect(_decoration(tester).borderRadius, const BorderRadius.all(Radius.circular(18)));
    });
  });

  testWidgets('renders the icon', (tester) async {
    await _pump(tester, const MxIconTile(icon: Icons.folder));
    expect(find.byIcon(Icons.folder), findsOneWidget);
  });
}
