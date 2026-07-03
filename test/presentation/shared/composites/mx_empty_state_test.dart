import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:memox_v4/core/theme/app_theme.dart';
import 'package:memox_v4/core/theme/mx_colors.dart';
import 'package:memox_v4/presentation/shared/composites/mx_empty_state.dart';
import 'package:memox_v4/presentation/shared/composites/mx_icon_tile.dart';

Future<void> _pump(WidgetTester tester, Widget state, {bool dark = false}) {
  return tester.pumpWidget(
    MaterialApp(
      theme: dark ? AppTheme.dark : AppTheme.light,
      home: Scaffold(body: state),
    ),
  );
}

Color _color(WidgetTester tester, String text) =>
    tester.widget<Text>(find.text(text)).style!.color!;

void main() {
  testWidgets('renders a large icon tile + title + body', (tester) async {
    await _pump(
      tester,
      const MxEmptyState(icon: Icons.folder_off, title: 'No decks yet', text: 'Create your first deck.'),
    );
    final tile = tester.widget<MxIconTile>(find.byType(MxIconTile));
    expect(tile.icon, Icons.folder_off);
    expect(tile.size, MxIconTileSize.large);
    expect(find.text('No decks yet'), findsOneWidget);
    expect(find.text('Create your first deck.'), findsOneWidget);
  });

  testWidgets('title = text colour, body = textSecondary', (tester) async {
    await _pump(tester, const MxEmptyState(icon: Icons.folder_off, title: 'T', text: 'B'));
    expect(_color(tester, 'T'), MxColors.light.text);
    expect(_color(tester, 'B'), MxColors.light.textSecondary);
  });

  testWidgets('tone flows to the icon tile', (tester) async {
    await _pump(
      tester,
      const MxEmptyState(icon: Icons.error, title: 'T', text: 'B', tone: MxIconTileTone.error),
    );
    expect(tester.widget<MxIconTile>(find.byType(MxIconTile)).tone, MxIconTileTone.error);
  });

  group('action', () {
    testWidgets('renders when provided', (tester) async {
      await _pump(
        tester,
        const MxEmptyState(icon: Icons.folder_off, title: 'T', text: 'B', action: Text('New deck')),
      );
      expect(find.text('New deck'), findsOneWidget);
    });

    testWidgets('absent when null (title + body only)', (tester) async {
      await _pump(tester, const MxEmptyState(icon: Icons.folder_off, title: 'T', text: 'B'));
      expect(find.byType(Text), findsNWidgets(2));
    });
  });

  testWidgets('dark uses dark tokens', (tester) async {
    await _pump(tester, const MxEmptyState(icon: Icons.folder_off, title: 'T', text: 'B'), dark: true);
    expect(_color(tester, 'B'), MxColors.dark.textSecondary);
  });
}
