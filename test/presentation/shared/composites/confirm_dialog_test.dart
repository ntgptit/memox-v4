import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:memox_v4/core/theme/app_theme.dart';
import 'package:memox_v4/presentation/shared/composites/mx_confirm_dialog.dart';
import 'package:memox_v4/presentation/shared/composites/mx_icon_tile.dart';

/// Pumps a screen with a button that opens the dialog and records its result.
Future<void> _pumpOpener(
  WidgetTester tester, {
  IconData? icon,
  MxDialogTone tone = MxDialogTone.neutral,
  required void Function(bool?) onResult,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              final result = await showMxConfirmDialog<bool>(
                context: context,
                icon: icon,
                tone: tone,
                title: 'Delete this card?',
                text: "This can't be undone.",
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Delete'),
                  ),
                ],
              );
              onResult(result);
            },
            child: const Text('open'),
          ),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('opens with the title, body, and actions', (tester) async {
    await _pumpOpener(tester, icon: Icons.delete, tone: MxDialogTone.error, onResult: (_) {});
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('Delete this card?'), findsOneWidget);
    expect(find.text("This can't be undone."), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('Delete'), findsOneWidget);
  });

  testWidgets('tone drives the header icon tile tint', (tester) async {
    await _pumpOpener(tester, icon: Icons.delete, tone: MxDialogTone.error, onResult: (_) {});
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    final tile = tester.widget<MxIconTile>(find.byType(MxIconTile));
    expect(tile.tone, MxIconTileTone.error);
    expect(tile.icon, Icons.delete);
  });

  testWidgets('no header icon when icon is null', (tester) async {
    await _pumpOpener(tester, onResult: (_) {});
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.byType(MxIconTile), findsNothing);
  });

  testWidgets('resolves with the value the tapped action pops', (tester) async {
    bool? result;
    await _pumpOpener(tester, icon: Icons.delete, onResult: (r) => result = r);
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(result, isTrue);
    expect(find.text('Delete this card?'), findsNothing); // dialog closed
  });
}
