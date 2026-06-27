import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:memox_v4/app/router/app_router.dart';
import 'package:memox_v4/core/constants/app_constants.dart';
import 'package:memox_v4/core/theme/app_theme.dart';
import 'package:memox_v4/l10n/generated/app_localizations.dart';

/// Root application widget.
///
/// Wires the Material 3 themes and the router. Holds no business state — the
/// router is created once for the widget's lifetime.
class MemoXApp extends StatefulWidget {
  const MemoXApp({super.key});

  @override
  State<MemoXApp> createState() => _MemoXAppState();
}

class _MemoXAppState extends State<MemoXApp> {
  final GoRouter _router = AppRouter.create();

  @override
  Widget build(BuildContext context) => MaterialApp.router(
    title: AppConstants.appName,
    debugShowCheckedModeBanner: false,
    theme: AppTheme.light(),
    darkTheme: AppTheme.dark(),
    themeMode: ThemeMode.system,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    routerConfig: _router,
  );
}
