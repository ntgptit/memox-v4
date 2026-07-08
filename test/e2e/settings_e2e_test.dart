// E2E — settings hub (S.05). Tag `e2e`. Map SC-SETTINGS-* (docs/scenarios/settings.md).
// Game words-per-round GHI settings (game.words_per_round); các hàng khác điều hướng. Vào màn:
// bottom-nav "Profile".
@Tags(['e2e'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:memox_v4/presentation/features/settings/screens/settings_screen.dart';
import 'package:memox_v4/presentation/features/settings/screens/srs_settings_screen.dart';
import 'package:memox_v4/presentation/shared/composites/mx_profile_card.dart';

import 'support/e2e_harness.dart';

Future<void> openSettings(WidgetTester tester) async {
  await tester.tap(find.text('Profile'));
  await settle(tester);
  expect(find.byType(SettingsScreen), findsOneWidget);
}

String? _setting(List<dynamic> rows, String key) {
  for (final r in rows) {
    if (r.key == key) return r.value as String;
  }
  return null;
}

void main() {
  // SC-SETTINGS · render — profile + nhóm + các hàng
  testWidgets('renders profile card and setting rows', (tester) async {
    await pumpApp(tester, seed: (h) => h.seedPair());
    await openSettings(tester);

    expect(find.byType(MxProfileCard), findsOneWidget);
    expect(find.text('STUDYING'), findsOneWidget); // MxSectionLabel uppercased
    expect(find.text('Spaced repetition'), findsOneWidget);
    expect(find.text('Game settings'), findsOneWidget);
    expect(find.text('Reminders'), findsOneWidget);
    expect(find.text('Theme'), findsOneWidget);
  });

  // SC-SETTINGS · đổi words-per-round → GHI settings game.words_per_round
  testWidgets('picking words-per-round persists to settings', (tester) async {
    final h = await pumpApp(tester, seed: (h) => h.seedPair());
    await openSettings(tester);

    await tester.tap(find.text('Game settings'));
    await settle(tester);
    await tester.tap(find.text('10 words')); // option [5,10,20]
    await settle(tester);

    final rows = await h.db.select(h.db.settings).get();
    expect(_setting(rows, 'game.words_per_round'), '10');
  });

  // SC-SETTINGS · "Spaced repetition" → điều hướng SrsSettingsScreen
  testWidgets('Spaced repetition row navigates to the SRS detail',
      (tester) async {
    await pumpApp(tester, seed: (h) => h.seedPair());
    await openSettings(tester);

    await tester.tap(find.text('Spaced repetition'));
    await settle(tester);
    expect(find.byType(SrsSettingsScreen), findsOneWidget);
  });
}
