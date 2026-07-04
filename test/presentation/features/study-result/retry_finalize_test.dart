import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:memox_v4/core/theme/app_theme.dart';
import 'package:memox_v4/l10n/app_localizations.dart';
import 'package:memox_v4/presentation/features/study-result/providers/study_result_providers.dart';
import 'package:memox_v4/presentation/features/study-result/widgets/finalizing_view.dart';

void main() {
  test('FinalizeRetrying flips to true on markRetry (and defaults false)', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(finalizeRetryingProvider), isFalse);
    container.read(finalizeRetryingProvider.notifier).markRetry();
    expect(container.read(finalizeRetryingProvider), isTrue);
  });

  Future<void> pumpFinalizing(WidgetTester tester, {required bool retry}) async {
    tester.view.physicalSize = const Size(400, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: FinalizingView(retry: retry),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('retry=false shows the saving copy', (tester) async {
    await pumpFinalizing(tester, retry: false);
    expect(find.text('Saving your results…'), findsOneWidget);
    expect(find.text('Retrying…'), findsNothing);
  });

  testWidgets('retry=true shows the retrying copy (now reachable)', (tester) async {
    await pumpFinalizing(tester, retry: true);
    expect(find.text('Retrying…'), findsOneWidget);
    expect(find.text('Saving your results…'), findsNothing);
  });
}
