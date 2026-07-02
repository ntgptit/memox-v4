import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox_v4/core/constants/app_constants.dart';
import 'package:memox_v4/core/routes/app_router.dart';
import 'package:memox_v4/core/theme/app_theme.dart';
import 'package:memox_v4/l10n/app_localizations.dart';

/// Root widget. Riverpod owns all state — no `setState` here — and the router is
/// read from [routerProvider]. The Material theme comes from [AppTheme], assembled
/// from the design tokens (colors + the `MxTheme` extension).
class MemoxApp extends ConsumerWidget {
  const MemoxApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
    );
  }
}
