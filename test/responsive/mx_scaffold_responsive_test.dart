import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:memox_v4/core/theme/app_theme.dart';
import 'package:memox_v4/core/theme/responsive.dart';
import 'package:memox_v4/presentation/shared/composites/mx_card.dart';
import 'package:memox_v4/presentation/shared/composites/mx_scaffold.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_button.dart';

/// V.6 — the shared frame stays correct on phones and graceful on large screens.
/// `MxScaffold` caps its body at [Breakpoints.maxContentWidth] and centers it, so
/// phone widths fill (they are under the cap) while tablet/desktop widths keep a
/// readable column instead of edge-to-edge stretch.
Future<void> _pump(WidgetTester tester, double width) async {
  tester.view.physicalSize = Size(width, 1400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      home: MxScaffold(
        appBar: AppBar(title: const Text('Frame')),
        children: [
          const MxCard(child: Text('A card of body content')),
          MxButton(label: 'Primary action', block: true, onPressed: () {}),
          const MxCard(child: Text('Another section')),
        ],
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// The rendered width of the body content column.
double _contentWidth(WidgetTester tester) =>
    tester.getSize(find.byType(MxButton)).width;

void main() {
  // Common phone widths (logical px).
  const phoneWidths = [320.0, 360.0, 375.0, 390.0, 430.0];
  // Tablet / desktop.
  const largeWidths = [768.0, 1024.0, 1440.0];

  for (final width in [...phoneWidths, ...largeWidths]) {
    testWidgets('no overflow at ${width.toInt()}px', (tester) async {
      await _pump(tester, width);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('phone widths fill the frame (content grows with width)',
      (tester) async {
    await _pump(tester, 320);
    final narrow = _contentWidth(tester);
    await _pump(tester, 430);
    final wide = _contentWidth(tester);
    expect(wide, greaterThan(narrow)); // not capped below the max on phones
    expect(wide, lessThanOrEqualTo(Breakpoints.maxContentWidth));
  });

  testWidgets('large screens cap the content at maxContentWidth', (tester) async {
    for (final width in largeWidths) {
      await _pump(tester, width);
      // The content column never exceeds the cap (minus the gutter padding),
      // so it stays a readable width instead of stretching edge-to-edge.
      expect(_contentWidth(tester),
          lessThanOrEqualTo(Breakpoints.maxContentWidth));
    }
  });

  testWidgets('the capped content is centered on a wide screen', (tester) async {
    await _pump(tester, 1440);
    final button = tester.getRect(find.byType(MxButton));
    const screenCenter = 1440 / 2;
    final buttonCenter = (button.left + button.right) / 2;
    expect((buttonCenter - screenCenter).abs(), lessThan(1.0));
  });
}
