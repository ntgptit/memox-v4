import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox_v4/core/theme/app_theme.dart';
import 'package:memox_v4/l10n/app_localizations.dart';
import 'package:memox_v4/presentation/features/deck-detail/screens/deck_detail_screen.dart';

import '../../../harness/provider_harness.dart';

void main() {
  testWidgets('deck-detail play-audio speaks every visible card term', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final harness = FakeHarness(); // seeded deck-food: 사과 · 고양이 · 개
    await tester.pumpWidget(
      ProviderScope(
        overrides: harness.overrides,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const DeckDetailScreen(deckId: 'deck-food'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(harness.audio.lastSpoken, isNull);

    await tester.tap(find.byIcon(Icons.volume_up));
    await tester.pumpAndSettle();

    // playDeckAudio walks the cards in order → the last spoken is card-3 (개).
    expect(harness.audio.lastSpoken, '개');
  });
}
