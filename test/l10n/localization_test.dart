import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:memox_v4/app/app.dart';
import 'package:memox_v4/l10n/app_localizations.dart';

/// T.4 — proves copy flows from ARB → AppLocalizations → the UI end-to-end.
void main() {
  test('AppLocalizations loads the English ARB strings', () async {
    final l10n = await AppLocalizations.delegate.load(const Locale('en'));
    expect(l10n.navToday, 'Today');
    expect(l10n.navLibrary, 'Library');
    expect(l10n.routeNotFoundTitle, 'Page not found');
  });

  testWidgets('the bottom nav renders labels from the ARB, not hardcoded', (
    tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: MemoxApp()));
    await tester.pumpAndSettle();

    // Labels sourced from app_en.arb via AppLocalizations.
    expect(find.text('Today'), findsWidgets);
    expect(find.text('Library'), findsWidgets);
    expect(find.text('Profile'), findsWidgets);
  });
}
