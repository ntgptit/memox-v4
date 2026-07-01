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
import 'package:memox_v4/presentation/features/study/screens/study_session_screen.dart';
import 'package:memox_v4/presentation/features/study/viewmodels/study_session_notifier.dart';
import 'package:memox_v4/presentation/shared/widgets/display/mx_text.dart';
import 'package:memox_v4/presentation/shared/widgets/surfaces/mx_card.dart';

/// PER-STATE parity gate for the study-session screen — mirrors review_parity_test.dart
/// (Template A), driven by three generated/curated contracts (no pixels, no AI):
///   - study-session.gen.json    : identity + component + variant   (gen_parity_contract.mjs)
///   - study-session.slots.json  : text role + binding per node      (curated from gen_slots.mjs)
///   - study-session.states.json : which node ids are present per STATE (gen_states.mjs)
///
/// The only state-differentiating MxCard is study-session/card: present ONLY in the
/// NewLearn stage-1 learn pass, absent in every game stage and in due-review (the game
/// widgets own those bodies). We drive the states we can reach cleanly:
///   - stage1-review  : 1-card NewLearn, 0 grades → learn card present.
///   - stage2-matching: 1-card NewLearn, 1 grade  → MatchingGame, card absent.
///   - due-review     : 1-card DueReview (+ srs row) → RecallGame, card absent.
/// stage3-choice / stage4-recall / stage5-typing are the same card-absent gate as
/// stage2 (listed in study-session.states.json, not driven — coverage gap). relearn /
/// exit / resume-error / answer-save-error are not distinct MxCard node-sets in the FE.
class _FixedClock implements Clock {
  const _FixedClock(this._ms);
  final int _ms;
  @override
  DateTime now() => DateTime.fromMillisecondsSinceEpoch(_ms);
  @override
  DateTime nowUtc() => now().toUtc();
}

const Map<String, MxCardVariant> _variants = <String, MxCardVariant>{
  'elevated': MxCardVariant.elevated,
  'flat': MxCardVariant.flat,
  'muted': MxCardVariant.muted,
  'primary': MxCardVariant.primary,
  'primarySoft': MxCardVariant.primarySoft,
};

/// How to reach a curated state in the FE: the study entry, how many correct grades
/// to advance the NewLearn stage, and whether the card needs a due srs row.
class _Drive {
  const _Drive(this.entry, this.grades, {this.srs = false});
  final StudyEntry entry;
  final int grades;
  final bool srs;
}

const Map<String, _Drive> _drive = <String, _Drive>{
  'stage1-review': _Drive(StudyEntry.newLearn, 0),
  'stage2-matching': _Drive(StudyEntry.newLearn, 1),
  'due-review': _Drive(StudyEntry.dueReview, 0, srs: true),
};

MxTextRole _role(String name) =>
    MxTextRole.values.firstWhere((r) => r.name == name);

Map<String, dynamic> _readJson(String path) =>
    jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;

void main() {
  final nodes =
      (_readJson('tool/parity/contracts/study-session.gen.json')['nodes']
              as List<dynamic>)
          .cast<Map<String, dynamic>>();
  final slotMap =
      _readJson('tool/parity/contracts/study-session.slots.json')['slots']
          as Map<String, dynamic>;
  final stateNodes =
      _readJson('tool/parity/contracts/study-session.states.json')['states']
          as Map<String, dynamic>;

  Future<(AppDatabase, int)> seed({required bool srs}) async {
    final db = AppDatabase.forTesting(openInMemoryDatabase());
    final pairId = await db
        .into(db.languagePair)
        .insert(
          LanguagePairCompanion.insert(sourceLang: 'ko', targetLang: 'vi'),
        );
    final deckId = await db
        .into(db.deck)
        .insert(DeckCompanion.insert(pairId: pairId, name: 'Deck'));
    final cardId = await db
        .into(db.card)
        .insert(CardCompanion.insert(deckId: deckId, term: '학교', createdAt: 1));
    if (srs) {
      // A due row (dueAt < clock 10000) so DueReview picks the card up (D-007).
      await SrsRepositoryImpl(
        SrsDao(db),
      ).upsert(SrsState(cardId: cardId, box: 2, dueAt: 5000));
    }
    return (db, deckId);
  }

  Widget host(AppDatabase db, int deckId, StudyEntry entry) => ProviderScope(
    overrides: [
      databaseProvider.overrideWithValue(db),
      clockProvider.overrideWithValue(const _FixedClock(10000)),
    ],
    child: MaterialApp(
      theme: AppTheme.light(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: StudySessionScreen(nodeId: deckId, entry: entry),
    ),
  );

  Future<void> settle(WidgetTester tester) async {
    // The session loads async (studySessionProvider); pump frames to the data
    // state — no determinate spinner to hang on, so avoid pumpAndSettle.
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  for (final entry in _drive.entries) {
    final state = entry.key;
    final drive = entry.value;
    testWidgets(
      'state "$state": MxCard identity matches study-session.states.json',
      (tester) async {
        final (db, deckId) = await seed(srs: drive.srs);
        addTearDown(db.close);
        await tester.pumpWidget(host(db, deckId, drive.entry));
        await settle(tester);

        // Advance the NewLearn stage with correct grades (1 grade == 1 stage for a
        // 1-card queue, D-002), so the learn card gives way to the game body.
        if (drive.grades > 0) {
          final container = ProviderScope.containerOf(
            tester.element(find.byType(StudySessionScreen)),
          );
          final notifier = container.read(
            studySessionProvider(
              StudyRequest(nodeId: deckId, entry: drive.entry),
            ).notifier,
          );
          for (var i = 0; i < drive.grades; i++) {
            await notifier.grade(true);
            await tester.pump(const Duration(milliseconds: 50));
          }
        }

        final present = (stateNodes[state] as List<dynamic>).cast<String>();

        for (final node in nodes) {
          // Template A loops only MxCard nodes (the single keyed identity that
          // differentiates state here); others are non-MxCard chrome/game-owned.
          if (node['component'] != 'MxCard') continue;
          final key = node['key'] as String; // 'mx-node:study-session/…'
          final id = key.replaceFirst('mx-node:', '');
          final finder = find.byKey(ValueKey(key));

          if (!present.contains(key)) {
            // State-differentiated identity: node absent in this state.
            expect(
              finder,
              findsNothing,
              reason: 'state $state: $id must be absent',
            );
            continue;
          }

          // 1. IDENTITY.
          expect(
            finder,
            findsOneWidget,
            reason: 'state $state: $id not rendered',
          );

          // 2. STYLING (variant ⇒ bg/radius/border).
          final expectedVariant = _variants[node['variant'] as String];
          expect(expectedVariant, isNotNull, reason: 'unknown variant for $id');
          expect(
            tester.widget<MxCard>(finder).variant,
            expectedVariant,
            reason: 'state $state: $id variant drifted from contract',
          );

          // 3. SLOTS (curated overlay — bind slots assert the role only).
          final slots = (slotMap[key] as List<dynamic>? ?? <dynamic>[])
              .cast<Map<String, dynamic>>();
          for (final slot in slots) {
            final role = _role(slot['role'] as String);
            expect(
              find.descendant(
                of: finder,
                matching: find.byWidgetPredicate(
                  (w) => w is MxText && w.role == role,
                ),
              ),
              findsWidgets,
              reason:
                  'state $state: $id slot "${slot['name']}": no MxText(role:${role.name})',
            );
          }
        }
      },
    );
  }
}
