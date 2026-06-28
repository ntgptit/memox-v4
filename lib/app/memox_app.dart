import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:memox_v4/app/router/app_router.dart';
import 'package:memox_v4/core/constants/app_constants.dart';
import 'package:memox_v4/core/theme/app_theme.dart';
import 'package:memox_v4/core/theme/theme_prefs.dart';
import 'package:memox_v4/l10n/generated/app_localizations.dart';
import 'package:memox_v4/presentation/features/personalization/viewmodels/personalization_notifier.dart';

/// Root application widget.
///
/// Wires the Material 3 themes + router, and applies personalization (W13) live:
/// theme mode, accent and font scale react to [personalizationProvider]
/// without a restart.
class MemoXApp extends ConsumerStatefulWidget {
  const MemoXApp({super.key});

  @override
  ConsumerState<MemoXApp> createState() => _MemoXAppState();
}

class _MemoXAppState extends ConsumerState<MemoXApp> {
  final GoRouter _router = AppRouter.create();

  @override
  Widget build(BuildContext context) {
    final prefs =
        ref.watch(personalizationProvider).value ?? const ThemePrefs();
    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(accent: prefs.accent),
      darkTheme: AppTheme.dark(accent: prefs.accent),
      themeMode: prefs.mode,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: _router,
      builder: (context, child) {
        final media = MediaQuery.of(context);
        return MediaQuery(
          data: media.copyWith(
            textScaler: TextScaler.linear(prefs.fontScale.factor),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
