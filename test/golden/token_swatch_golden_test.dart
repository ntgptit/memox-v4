import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox_v4/core/theme/app_theme.dart';
import 'package:memox_v4/core/theme/mx_colors.dart';
import 'package:memox_v4/core/theme/mx_spacing.dart';

import '../support/golden.dart';

/// Golden harness proof (T.5). Deliberately renders only **solid, axis-aligned
/// fills** (no text, no curves, no anti-aliasing) so the baseline is byte-stable
/// across host platforms — the dev machine and the Linux CI produce the same PNG.
/// It still fails CI on a real regression: change a semantic token color and the
/// swatch grid no longer matches.
///
/// Font loading (via `flutter_test_config.dart`) is in place for future *text*
/// goldens, which are font-dependent and should be regenerated on the CI platform.
void main() {
  Widget grid(MxColors c) => _SwatchGrid([
        c.primary,
        c.accent,
        c.success,
        c.warning,
        c.error,
        c.info,
      ]);

  testWidgets('semantic palette swatches — light', (tester) async {
    await pumpForGolden(tester, grid(MxColors.light), theme: AppTheme.light);
    await expectLater(
      find.byType(_SwatchGrid),
      matchesGoldenFile('goldens/token_swatch_light.png'),
    );
  });

  testWidgets('semantic palette swatches — dark', (tester) async {
    await pumpForGolden(tester, grid(MxColors.dark), theme: AppTheme.dark);
    await expectLater(
      find.byType(_SwatchGrid),
      matchesGoldenFile('goldens/token_swatch_dark.png'),
    );
  });
}

/// A row of fixed-size solid color chips — no text, no rounded corners, so the
/// rasterization is identical on every platform.
class _SwatchGrid extends StatelessWidget {
  const _SwatchGrid(this.colors);

  final List<Color> colors;

  static const double _chip = 48;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: MxSpacing.space2,
      runSpacing: MxSpacing.space2,
      children: [
        for (final color in colors)
          SizedBox(width: _chip, height: _chip, child: ColoredBox(color: color)),
      ],
    );
  }
}
