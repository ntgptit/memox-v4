import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:memox_v4/core/theme/app_theme.dart';
import 'package:memox_v4/core/theme/mx_colors.dart';
import 'package:memox_v4/core/theme/mx_elevation.dart';
import 'package:memox_v4/core/theme/mx_theme.dart';

void main() {
  group('AppTheme', () {
    test('light carries the MxTheme extension built from the light tokens', () {
      final theme = AppTheme.light;
      final mx = theme.extension<MxTheme>();
      expect(mx, isNotNull);
      expect(mx!.surface, MxColors.light.surface);
      expect(mx.errorSoft, MxColors.light.errorSoft);
      expect(mx.primaryStrong, MxColors.light.primaryStrong);
      expect(mx.success, MxColors.light.success);
      expect(mx.warning, MxColors.light.warning);
      expect(mx.onSuccess, MxColors.light.onSuccess);
      expect(mx.focusRing, MxColors.light.focusRing);
      expect(mx.shadows, same(MxShadows.light));
    });

    test('light ColorScheme + scaffold come from the tokens', () {
      final theme = AppTheme.light;
      expect(theme.scaffoldBackgroundColor, MxColors.light.bg);
      expect(theme.colorScheme.primary, MxColors.light.primary);
      expect(theme.colorScheme.secondary, MxColors.light.accent);
      expect(theme.brightness, Brightness.light);
    });

    test('dark uses the dark tokens', () {
      final theme = AppTheme.dark;
      expect(theme.extension<MxTheme>()!.surface, MxColors.dark.surface);
      expect(theme.scaffoldBackgroundColor, MxColors.dark.bg);
      expect(theme.brightness, Brightness.dark);
    });
  });

  testWidgets('MxTheme.of resolves the extension off the ambient theme', (
    tester,
  ) async {
    late MxTheme mx;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Builder(
          builder: (context) {
            mx = MxTheme.of(context);
            return const SizedBox.shrink();
          },
        ),
      ),
    );
    expect(mx.text, MxColors.light.text);
    expect(mx.cardRadius, isA<BorderRadius>());
  });

  group('component themes map onto the tokens', () {
    test('stock FilledButton matches the kit primary', () {
      final style = AppTheme.light.filledButtonTheme.style!;
      expect(style.backgroundColor!.resolve({}), MxColors.light.primary);
      expect(style.foregroundColor!.resolve({}), MxColors.light.onPrimary);
    });

    test('Card / AppBar / NavigationBar / Input pull from tokens', () {
      final t = AppTheme.light;
      expect(t.cardTheme.color, MxColors.light.surfaceRaised);
      expect(t.appBarTheme.backgroundColor, MxColors.light.bg);
      expect(t.navigationBarTheme.backgroundColor, MxColors.light.surface);
      expect(t.navigationBarTheme.indicatorColor, MxColors.light.primarySoft);
      // Kit `.field` contract: inputs are bare — no theme-level fill/borders
      // (the visible box belongs to the surrounding MemoX container).
      expect(t.inputDecorationTheme.filled, isFalse);
      expect(t.inputDecorationTheme.enabledBorder, InputBorder.none);
      expect(t.inputDecorationTheme.hintStyle!.color, MxColors.light.textTertiary);
    });

    test('Switch selected track uses primary; unselected uses a sunken surface', () {
      final track = AppTheme.light.switchTheme.trackColor!;
      expect(track.resolve({WidgetState.selected}), MxColors.light.primary);
      expect(track.resolve({}), MxColors.light.surfaceSunken);
    });

    test('dark component themes pull from the dark tokens', () {
      expect(AppTheme.dark.cardTheme.color, MxColors.dark.surfaceRaised);
      expect(
        AppTheme.dark.filledButtonTheme.style!.backgroundColor!.resolve({}),
        MxColors.dark.primary,
      );
    });
  });

  group('MxTheme.lerp', () {
    test('is identity at the endpoints and blends in between', () {
      final a = AppTheme.light.extension<MxTheme>()!;
      final b = AppTheme.dark.extension<MxTheme>()!;

      expect(a.lerp(b, 0).surface, a.surface);
      expect(a.lerp(b, 1).surface, b.surface);
      // Midpoint sits strictly between the two endpoints.
      final mid = a.lerp(b, 0.5).surface;
      expect(mid, isNot(a.surface));
      expect(mid, isNot(b.surface));
    });

    test('shadows snap across the midpoint (discrete, not blended)', () {
      final a = AppTheme.light.extension<MxTheme>()!;
      final b = AppTheme.dark.extension<MxTheme>()!;
      expect(a.lerp(b, 0.4).shadows, same(MxShadows.light));
      expect(a.lerp(b, 0.6).shadows, same(MxShadows.dark));
    });
  });
}
