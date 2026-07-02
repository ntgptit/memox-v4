import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:memox_v4/app/app.dart';
import 'package:memox_v4/core/routes/app_router.dart';
import 'package:memox_v4/core/routes/app_routes.dart';
import 'package:memox_v4/core/theme/mx_theme.dart';
import 'package:memox_v4/l10n/app_localizations.dart';

/// Foundation exit gate (WBS I.9) — the "foundation usable" seal. The empty app
/// must boot with the correct architecture and degrade gracefully BEFORE any
/// feature/screen work begins.
///
/// The rest of the exit checklist is enforced by sibling gates, not re-asserted
/// here (that would be circular):
///   • analyze + codegen clean, `gen_tokens --check` .... `node tool/verify/run.mjs`
///   • no reverse-layer imports / raw route strings / hand-edited mirrors ..........
///     `test/architecture/layer_boundaries_test.dart`
///   • hardcoded user-facing copy → ARB ................ enforced once T.4 lands l10n
void main() {
  testWidgets('app boots under ProviderScope with no first-frame exception', (
    tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: MemoxApp()));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    // Booted into the tab shell (the architecture is wired, not just a bare frame).
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.widgetWithText(AppBar, Routes.today), findsOneWidget);
  });

  testWidgets('the MxTheme extension resolves on the booted tree', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: MemoxApp()));
    await tester.pumpAndSettle();

    final context = tester.element(find.byType(NavigationBar));
    // Throws if the theme was not assembled with the extension — a wiring bug.
    expect(MxTheme.of(context).surface, isA<Color>());
  });

  testWidgets('an unknown route renders the fallback, never a crash', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final router = container.read(routerProvider);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          routerConfig: router,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );
    await tester.pumpAndSettle();

    router.go('/no-such-route-xyz');
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byType(RouteErrorScreen), findsOneWidget);
    expect(find.text('/no-such-route-xyz'), findsOneWidget);
  });
}
