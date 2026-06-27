import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox_v4/core/theme/mx_colors.dart';
import 'package:memox_v4/core/theme/mx_elevation.dart';
import 'package:memox_v4/core/theme/mx_radius.dart';
import 'package:memox_v4/core/theme/mx_sizes.dart';
import 'package:memox_v4/core/theme/mx_spacing.dart';
import 'package:memox_v4/core/theme/mx_typography.dart';

void main() {
  group('MxSpacing', () {
    test('4px scale steps match the design tokens', () {
      expect(MxSpacing.space1, 4);
      expect(MxSpacing.space4, 16);
      expect(MxSpacing.space6, 24);
      expect(MxSpacing.space7, 32);
      expect(MxSpacing.space12, 96);
    });

    test('layout rhythm tokens', () {
      expect(MxSpacing.gutter, 20);
      expect(MxSpacing.minTouchTarget, 48);
      expect(MxSpacing.bottomNavHeight, 72);
    });
  });

  group('MxRadius', () {
    test('scale + role aliases', () {
      expect(MxRadius.card, 20);
      expect(MxRadius.field, 14);
      expect(MxRadius.pill, 999);
    });

    test('BorderRadius helpers carry the role value', () {
      expect(MxRadius.cardRadius.topLeft.x, MxRadius.card);
      expect(MxRadius.pillRadius.topLeft.x, MxRadius.pill);
    });
  });

  group('MxTypography', () {
    test('font sizes', () {
      expect(MxTypography.sizeBase, 15);
      expect(MxTypography.sizeXl, 24);
      expect(MxTypography.size4xl, 48);
    });

    test('weights map to FontWeight', () {
      expect(MxTypography.regular, FontWeight.w400);
      expect(MxTypography.semibold, FontWeight.w600);
      expect(MxTypography.extrabold, FontWeight.w800);
    });

    test('tracking is stored as an em multiplier', () {
      expect(MxTypography.trackingTight, -0.02);
      expect(MxTypography.trackingCaps, 0.08);
    });
  });

  group('MxSizes / MxIconSize / MxStroke', () {
    test('element + icon + stroke scales', () {
      expect(MxSizes.sizeMd, 56);
      expect(MxSizes.size5xl, 320);
      expect(MxIconSize.md, 22);
      expect(MxStroke.hairline, 1);
      expect(MxStroke.focus, 3);
    });
  });

  group('MxColors', () {
    test('seed equals the light primary', () {
      expect(MxColors.light.primary, MxColors.seed);
    });

    test('light and dark are distinct palettes', () {
      expect(MxColors.light.bg, isNot(MxColors.dark.bg));
      expect(MxColors.light.surface, const Color(0xFFFFFFFF));
      expect(MxColors.dark.surface, const Color(0xFF181C34));
    });

    test('alpha-bearing roles preserve their opacity', () {
      // text-secondary light = rgba(29,34,64,0.62) → 0x9E in the alpha byte.
      expect((MxColors.light.textSecondary.a * 255).round(), 0x9E);
    });
  });

  group('MxShadows', () {
    test('light card casts a two-layer shadow', () {
      expect(MxShadows.light.card.length, 2);
    });

    test('dark surfaces use a 1px hairline ring (spread, no blur)', () {
      final ring = MxShadows.dark.sm.single;
      expect(ring.spreadRadius, 1);
      expect(ring.blurRadius, 0);
    });
  });
}
