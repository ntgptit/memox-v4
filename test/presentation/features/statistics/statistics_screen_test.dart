import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox_v4/app/di/clock_provider.dart';
import 'package:memox_v4/app/di/database_provider.dart';
import 'package:memox_v4/core/theme/app_theme.dart';
import 'package:memox_v4/core/util/clock.dart';
import 'package:memox_v4/data/datasources/local/connection/database_connection.dart';
import 'package:memox_v4/data/datasources/local/drift/app_database.dart';
import 'package:memox_v4/l10n/generated/app_localizations.dart';
import 'package:memox_v4/presentation/features/statistics/screens/statistics_screen.dart';

class _FixedClock implements Clock {
  _FixedClock(this._now);
  final DateTime _now;
  @override
  DateTime now() => _now;
  @override
  DateTime nowUtc() => _now.toUtc();
}

void main() {
  late AppDatabase db;
  late int pairId;
  late int deckId;
  final today = DateTime(2026, 6, 28, 10);

  setUp(() async {
    db = AppDatabase.forTesting(openInMemoryDatabase());
    pairId = await db
        .into(db.languagePair)
        .insert(
          LanguagePairCompanion.insert(sourceLang: 'ko', targetLang: 'vi'),
        );
    deckId = await db
        .into(db.deck)
        .insert(DeckCompanion.insert(pairId: pairId, name: 'Deck'));
  });
  tearDown(() => db.close());

  Widget host() => ProviderScope(
    overrides: <Override>[
      databaseProvider.overrideWithValue(db),
      clockProvider.overrideWithValue(_FixedClock(today)),
    ],
    child: MaterialApp(
      theme: AppTheme.light(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const Scaffold(body: StatisticsScreen()),
    ),
  );

  testWidgets('shows the insufficient-data state with no cards', (
    tester,
  ) async {
    await tester.pumpWidget(host());
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('statsInsufficient')), findsOneWidget);
  });

  testWidgets('renders charts when there is data', (tester) async {
    await db
        .into(db.card)
        .insert(CardCompanion.insert(deckId: deckId, term: 'a', createdAt: 1));

    await tester.pumpWidget(host());
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('statistics')), findsOneWidget);
  });
}
