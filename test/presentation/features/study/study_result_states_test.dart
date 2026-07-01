import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox_v4/app/di/clock_provider.dart';
import 'package:memox_v4/app/di/database_provider.dart';
import 'package:memox_v4/core/theme/app_theme.dart';
import 'package:memox_v4/core/util/clock.dart';
import 'package:memox_v4/data/datasources/local/connection/database_connection.dart';
import 'package:memox_v4/data/datasources/local/daos/srs_dao.dart';
import 'package:memox_v4/data/datasources/local/drift/app_database.dart'
    show AppDatabase, CardCompanion, DeckCompanion, LanguagePairCompanion;
import 'package:memox_v4/data/repositories/srs_repository_impl.dart';
import 'package:memox_v4/domain/entities/srs_state.dart';
import 'package:memox_v4/domain/types/study_entry.dart';
import 'package:memox_v4/l10n/generated/app_localizations.dart';
import 'package:memox_v4/presentation/features/language_pair/viewmodels/language_pair_notifier.dart';
import 'package:memox_v4/presentation/features/study/screens/study_session_screen.dart';
import 'package:memox_v4/presentation/features/study/viewmodels/study_session_notifier.dart';

/// State-COMPOSITION parity gate (Template B) for study-result — the finished
/// branch of study-session (_result(), reached when state.finished == true).
/// study-result.gen.json's one MxCard (goal) is not rendered/keyed in the FE, so —
/// like library/game — assert the keyed CONTAINER set, never casting.
///
/// Only `standard` is gated (universe = {continue, library}). goal-met/goal-missed/
/// many-wrong share standard's node-set (only the words/accuracy TEXT differs);
/// finalizing/retry-finalize/finalize-error don't exist in the FE (finalize is
/// synchronous, D-010). See the states.json $curated + intent-ledger.
class _FixedClock implements Clock {
  const _FixedClock(this._ms);
  final int _ms;
  @override
  DateTime now() => DateTime.fromMillisecondsSinceEpoch(_ms);
  @override
  DateTime nowUtc() => now().toUtc();
}

Map<String, dynamic> _readJson(String path) =>
    jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;

void main() {
  late AppDatabase db;
  late int deckId;
  late ProviderContainer container;

  final states =
      (_readJson('tool/parity/contracts/study-result.states.json')['states']
              as Map<String, dynamic>)
          .map(
            (k, v) => MapEntry(k, (v as List<dynamic>).cast<String>().toSet()),
          );
  final universe = states.values.expand((s) => s).toSet();

  setUp(() async {
    db = AppDatabase.forTesting(openInMemoryDatabase());
    final pairId = await db
        .into(db.languagePair)
        .insert(
          LanguagePairCompanion.insert(sourceLang: 'ko', targetLang: 'vi'),
        );
    deckId = await db
        .into(db.deck)
        .insert(DeckCompanion.insert(pairId: pairId, name: 'Deck'));
    container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        clockProvider.overrideWithValue(const _FixedClock(10000)),
      ],
    );
  });
  tearDown(() async {
    container.dispose();
    await db.close();
  });

  testWidgets(
    'state "standard": finished result renders exactly the kit node set',
    (tester) async {
      // Seed a single DueReview card that is due now (dueAt:0 < clock 10000).
      final cardId = await db
          .into(db.card)
          .insert(
            CardCompanion.insert(deckId: deckId, term: '학교', createdAt: 1),
          );
      await SrsRepositoryImpl(
        SrsDao(db),
      ).upsert(SrsState(cardId: cardId, box: 1, dueAt: 0));

      final req = StudyRequest(nodeId: deckId, entry: StudyEntry.dueReview);
      await container.read(languagePairProvider.future);
      await container.read(studySessionProvider(req).future);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.light(),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: StudySessionScreen(
              nodeId: deckId,
              entry: StudyEntry.dueReview,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Grade the single card correct → pending empties → _finalize() → finished →
      // _result(). Drive via the notifier (the same provider the screen watches).
      await container.read(studySessionProvider(req).notifier).grade(true);
      await tester.pumpAndSettle();

      final allowed = states['standard']!;
      for (final key in universe) {
        final finder = find.byKey(ValueKey(key));
        if (allowed.contains(key)) {
          expect(finder, findsOneWidget, reason: 'standard: $key THIẾU');
        } else {
          expect(
            finder,
            findsNothing,
            reason: 'standard: $key present but kit omits it here (THỪA)',
          );
        }
      }
    },
  );
}
