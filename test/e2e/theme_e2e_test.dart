// E2E — theme (S.08). Tag `e2e`. Map SC-THEME-* (docs/scenarios/theme.md).
// Ghi settings (DB): theme.mode / theme.font_scale. Assert UI + round-trip DB. Điều hướng:
// push '/theme'.
@Tags(['e2e'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:memox_v4/presentation/features/dashboard/screens/dashboard_screen.dart';
import 'package:memox_v4/presentation/features/theme/screens/theme_screen.dart';
import 'package:memox_v4/presentation/features/theme/widgets/preview_card.dart';

import 'support/e2e_harness.dart';

Future<void> openTheme(WidgetTester tester) async {
  GoRouter.of(tester.element(find.byType(DashboardScreen))).push('/theme');
  await settle(tester);
  expect(find.byType(ThemeScreen), findsOneWidget);
}

String? _setting(E2EHarness h, List<dynamic> rows, String key) {
  for (final r in rows) {
    if (r.key == key) return r.value as String;
  }
  return null;
}

void main() {
  // SC-THEME · render — preview + color-mode + text-size + các nhãn
  testWidgets('renders preview and appearance controls', (tester) async {
    await pumpApp(tester, seed: (h) => h.seedPair());
    await openTheme(tester);

    expect(find.byType(PreviewCard), findsOneWidget);
    expect(find.text('Color mode'), findsOneWidget);
    expect(find.text('Text size'), findsOneWidget);
    expect(find.text('Dark'), findsOneWidget);
    expect(find.text('Large'), findsOneWidget);
  });

  // SC-THEME · chọn Dark → GHI settings theme.mode = 'dark'
  testWidgets('selecting Dark persists theme.mode to settings', (tester) async {
    final h = await pumpApp(tester, seed: (h) => h.seedPair());
    await openTheme(tester);

    await tester.tap(find.text('Dark'));
    await settle(tester);

    final rows = await h.db.select(h.db.settings).get();
    expect(_setting(h, rows, 'theme.mode'), 'dark');
  });

  // SC-THEME · chọn Large → GHI settings theme.font_scale = 'large'
  testWidgets('selecting Large persists theme.font_scale to settings',
      (tester) async {
    final h = await pumpApp(tester, seed: (h) => h.seedPair());
    await openTheme(tester);

    await tester.ensureVisible(find.text('Large')); // control ở dưới, cuộn tới
    await settle(tester);
    await tester.tap(find.text('Large'));
    await settle(tester);

    final rows = await h.db.select(h.db.settings).get();
    expect(_setting(h, rows, 'theme.font_scale'), 'large');
  });
}
