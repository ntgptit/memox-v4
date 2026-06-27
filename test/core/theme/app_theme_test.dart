import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox_v4/core/theme/app_theme.dart';
import 'package:memox_v4/core/theme/mx_colors.dart';
import 'package:memox_v4/core/theme/mx_theme.dart';
import 'package:memox_v4/core/theme/mx_typography.dart';

void main() {
  test('light theme is Material 3 with light brightness', () {
    final theme = AppTheme.light();

    expect(theme.useMaterial3, isTrue);
    expect(theme.colorScheme.brightness, Brightness.light);
  });

  test('dark theme is Material 3 with dark brightness', () {
    final theme = AppTheme.dark();

    expect(theme.useMaterial3, isTrue);
    expect(theme.colorScheme.brightness, Brightness.dark);
  });

  test('color scheme is anchored on the brand tokens', () {
    expect(AppTheme.light().colorScheme.primary, MxColors.light.primary);
    expect(AppTheme.dark().colorScheme.primary, MxColors.dark.primary);
    expect(AppTheme.light().colorScheme.error, MxColors.light.error);
  });

  test(
    'registers the MxTheme extension with the matching palette per brightness',
    () {
      final light = AppTheme.light().extension<MxTheme>();
      final dark = AppTheme.dark().extension<MxTheme>();

      expect(light, isNotNull);
      expect(dark, isNotNull);
      expect(light!.colors.surface, MxColors.light.surface);
      expect(dark!.colors.surface, MxColors.dark.surface);
    },
  );

  test('MxTheme.of reads the active extension', () {
    expect(MxTheme.light.colors.bg, MxColors.light.bg);
    expect(MxTheme.dark.shadows.card.length, 2);
  });

  test('text theme uses the brand font family', () {
    final text = AppTheme.light().textTheme;

    expect(text.headlineMedium?.fontFamily, MxTypography.fontFamily);
    expect(text.bodyMedium?.fontSize, MxTypography.sizeBase);
  });
}
