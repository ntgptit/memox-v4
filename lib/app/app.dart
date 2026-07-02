import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox_v4/core/constants/app_constants.dart';
import 'package:memox_v4/core/routes/app_router.dart';
import 'package:memox_v4/core/theme/mx_colors.dart';
import 'package:memox_v4/core/theme/mx_typography.dart';

/// Root widget. Riverpod owns all state — no `setState` here — and the router is
/// read from [routerProvider]. The Material theme is still assembled inline from
/// the Tier-0 token mirrors; the full Tier-1 theme (an `MxTheme` extension for
/// the non-Material roles) supersedes [_themeFrom] in T.1.
class MemoxApp extends ConsumerWidget {
  const MemoxApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: _themeFrom(MxColors.light, Brightness.light),
      darkTheme: _themeFrom(MxColors.dark, Brightness.dark),
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}

/// Builds a Material [ThemeData] from the generated design tokens ([MxColors] +
/// [MxTypography]) for one brightness — the seam where the Tier-0 token mirrors
/// become the app's actual theme. Temporary until T.1 formalizes the theme.
ThemeData _themeFrom(MxColors c, Brightness brightness) {
  final scheme = ColorScheme.fromSeed(
    seedColor: MxColors.seed,
    brightness: brightness,
  ).copyWith(
    primary: c.primary,
    onPrimary: c.onPrimary,
    primaryContainer: c.primarySoft,
    onPrimaryContainer: c.onPrimarySoft,
    secondary: c.accent,
    onSecondary: c.onAccent,
    secondaryContainer: c.accentSoft,
    error: c.error,
    onError: c.onError,
    surface: c.surface,
    onSurface: c.text,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: c.bg,
    fontFamily: MxTypography.fontFamily,
    textTheme: const TextTheme().apply(
      bodyColor: c.text,
      displayColor: c.text,
    ),
  );
}
