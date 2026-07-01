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
import 'package:memox_v4/data/datasources/local/drift/app_database.dart'
    show AppDatabase, CardCompanion, DeckCompanion, LanguagePairCompanion;
import 'package:memox_v4/l10n/generated/app_localizations.dart';
import 'package:memox_v4/presentation/features/study/screens/review_screen.dart';
import 'package:memox_v4/presentation/shared/widgets/display/mx_text.dart';
import 'package:memox_v4/presentation/shared/widgets/surfaces/mx_card.dart';

/// Parity gate for the review screen — a WORKED TEMPLATE of the slot layer for
/// Flutter conversion. `review.slots.json` was curated from the
/// `gen_slots.mjs` skeleton (`tool/parity/gen_slots.mjs`); this test cross-checks
/// it against the real FE render, the same way dashboard_parity_test.dart does.
///
/// Three layers, all on typed props (no pixels, no AI):
///  1. IDENTITY — every keyed MxCard node in `review.gen.json` renders.
///  2. STYLING  — its `variant` matches the kit contract (⇒ bg/radius/border).
///  3. SLOTS    — each slot in `review.slots.json` renders an MxText with the
///                bound MxTextRole. Review's slots are `bind` (card data:
///                term/meaning), so only the role is asserted — the copy is user
///                content, not localizable UI text.
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

MxTextRole _role(String name) =>
    MxTextRole.values.firstWhere((r) => r.name == name);

Map<String, dynamic> _readJson(String path) =>
    jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;

void main() {
  late AppDatabase db;
  late int deckId;

  final nodes =
      (_readJson('tool/parity/contracts/review.gen.json')['nodes']
              as List<dynamic>)
          .cast<Map<String, dynamic>>();
  final slotMap =
      _readJson('tool/parity/contracts/review.slots.json')['slots']
          as Map<String, dynamic>;

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
    // StudyEntry.review returns every card of the node → one card fills the queue.
    await db
        .into(db.card)
        .insert(CardCompanion.insert(deckId: deckId, term: '학교', createdAt: 1));
  });
  tearDown(() => db.close());

  Widget host() => ProviderScope(
    overrides: [
      databaseProvider.overrideWithValue(db),
      clockProvider.overrideWithValue(const _FixedClock(10000)),
    ],
    child: MaterialApp(
      theme: AppTheme.light(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: ReviewScreen(nodeId: deckId)),
    ),
  );

  testWidgets('generated contract: identity + variant + slot roles', (
    tester,
  ) async {
    await tester.pumpWidget(host());
    // ReviewScreen loads its queue in initState; let the async load + rebuild
    // settle to the card (its progress bar is determinate — no spinner to hang on).
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }

    for (final node in nodes) {
      // The FE keys only MxCard nodes here (appbar/buttons await identity rollout).
      if (node['component'] != 'MxCard') continue;
      final key = node['key'] as String;
      final finder = find.byKey(ValueKey(key));

      // 1. IDENTITY.
      expect(finder, findsOneWidget, reason: '$key not rendered');

      // 2. STYLING (variant ⇒ bg/radius/border).
      final expectedVariant = _variants[node['variant'] as String];
      expect(expectedVariant, isNotNull, reason: 'unknown variant for $key');
      expect(
        tester.widget<MxCard>(finder).variant,
        expectedVariant,
        reason: '$key variant drifted from contract',
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
          reason: '$key slot "${slot['name']}": no MxText(role:${role.name})',
        );
      }
    }
  });
}
