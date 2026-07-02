// Generates a FLAT per-mx-node style record from the real Flutter render tree,
// in a token-aware form that mirrors the kit `specs/*.md` style fields, so
// `tool/parity/spec_diff.mjs` can compare design-kit-intended vs FE-rendered
// style (bg/color/font/radius/size) WITHOUT pixel diffing. One file per screen
// under `tool/parity/fe-specs/<screen>.json`. Not a behavioural test — a spec
// exporter run as a widget test (it needs a rendered tree).
import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:memox_v4/app/di/database_provider.dart';
import 'package:memox_v4/app/di/import_export_providers.dart';
import 'package:memox_v4/core/theme/app_theme.dart';
import 'package:memox_v4/core/theme/mx_theme.dart';
import 'package:memox_v4/core/util/day_key.dart';
import 'package:memox_v4/data/datasources/local/connection/database_connection.dart';
import 'package:memox_v4/data/datasources/local/drift/app_database.dart';
import 'package:memox_v4/domain/models/deck_node.dart';
import 'package:memox_v4/domain/services/file_save_service.dart';
import 'package:memox_v4/domain/types/game_scope.dart';
import 'package:memox_v4/domain/types/game_type.dart';
import 'package:memox_v4/domain/types/study_entry.dart';
import 'package:memox_v4/l10n/generated/app_localizations.dart';
import 'package:memox_v4/presentation/features/deck/screens/deck_detail_screen.dart';
import 'package:memox_v4/presentation/features/deck/screens/library_screen.dart';
import 'package:memox_v4/presentation/features/deck/viewmodels/library_notifier.dart';
import 'package:memox_v4/presentation/features/engagement/screens/dashboard_screen.dart';
import 'package:memox_v4/presentation/features/flashcard/screens/flashcard_editor_screen.dart';
import 'package:memox_v4/presentation/features/game/screens/game_picker_screen.dart';
import 'package:memox_v4/presentation/features/game/screens/game_screen.dart';
import 'package:memox_v4/presentation/features/game/viewmodels/game_session_notifier.dart';
import 'package:memox_v4/presentation/features/import_export/screens/export_screen.dart';
import 'package:memox_v4/presentation/features/import_export/screens/import_screen.dart';
import 'package:memox_v4/presentation/features/personalization/screens/theme_screen.dart';
import 'package:memox_v4/presentation/features/search/screens/search_screen.dart';
import 'package:memox_v4/presentation/features/settings/screens/reminder_screen.dart';
import 'package:memox_v4/presentation/features/settings/screens/settings_screen.dart';
import 'package:memox_v4/presentation/features/statistics/screens/statistics_screen.dart';
import 'package:memox_v4/presentation/features/study/screens/player_screen.dart';
import 'package:memox_v4/presentation/features/study/screens/review_screen.dart';
import 'package:memox_v4/presentation/features/study/screens/study_session_screen.dart';
import 'package:memox_v4/presentation/shared/navigation/app_drawer.dart';

const String _prefix = 'mx-node:';

/// Repump a fresh tree on the SAME tester/db (used by drives that need a
/// different route argument or extra provider overrides, e.g. an empty deck or
/// a throwing notifier for the error branch).
Future<void> _repump(
  WidgetTester tester,
  AppDatabase db,
  Widget home, {
  List<Override> extra = const <Override>[],
}) async {
  await tester.pumpWidget(
    ProviderScope(
      // A fresh scope element per repump: Riverpod forbids changing the override
      // LIST LENGTH on a reused ProviderScope, and a reused container would keep
      // stale provider state from the base pump.
      key: UniqueKey(),
      overrides: [databaseProvider.overrideWithValue(db), ...extra],
      child: MaterialApp(
        theme: AppTheme.light(),
        debugShowCheckedModeBanner: false,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: home,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// Bounded frame drain for trees that never settle (TextField autofocus keeps a
/// cursor-blink animation running — pumpAndSettle would time out). 6×50ms =
/// 300ms of simulated time, enough for the in-memory DB futures + a setState
/// round-trip (the same budget the states tests use).
Future<void> _drain(WidgetTester tester) async {
  for (var i = 0; i < 6; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

/// Forces the library provider into its error branch (the notifier folds repo
/// Result.err into an empty list, so a thrown build is the only clean path).
class _ThrowingLibrary extends LibraryNotifier {
  @override
  Future<List<DeckNode>> build() async =>
      throw Exception('forced library error');
}

class _FakeFileSave implements FileSaveService {
  @override
  Future<String> save(String fileName, List<int> bytes) async =>
      '/tmp/$fileName';
}

/// Pumps [child] at the kit's 390-wide frame with a seeded in-memory DB, then
/// exports its mx-node style record.
///
/// [drives] extends the export beyond the base state: each drive interacts with
/// the pumped tree (taps / text entry / re-pumps — the drive owns its own
/// pumping), after which the screen is exported again in MERGE mode, so nodes
/// that only render in secondary states (dialogs, error/empty branches, wrong/
/// complete phases) join the spec instead of staying blind spots. First-wins per
/// node id, matching spec_diff's parseKit which also keeps the FIRST style a
/// node shows (base state first).
Future<void> _pumpAndExport(
  WidgetTester tester,
  String screen,
  Future<Widget> Function(AppDatabase db) buildChild, {
  Future<void> Function(AppDatabase db)? seed,
  List<Future<void> Function(WidgetTester tester, AppDatabase db)>? drives,
}) async {
  final db = AppDatabase.forTesting(openInMemoryDatabase());
  addTearDown(db.close);
  await db
      .into(db.languagePair)
      .insert(LanguagePairCompanion.insert(sourceLang: 'ko', targetLang: 'vi'));
  if (seed != null) await seed(db);
  final child = await buildChild(db);

  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [databaseProvider.overrideWithValue(db)],
      child: MaterialApp(
        theme: AppTheme.light(),
        debugShowCheckedModeBanner: false,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: child,
      ),
    ),
  );
  await tester.pumpAndSettle();
  // Consume soft layout exceptions (e.g. RenderFlex overflow at the fixed test
  // frame) — rendering still produces sizes/styles, which is all we export.
  while (tester.takeException() != null) {}
  _exportScreen(tester, screen);
  await _maybeShot(tester, screen);

  for (final drive in drives ?? const []) {
    await drive(tester, db);
    while (tester.takeException() != null) {}
    _exportScreen(tester, screen, merge: true);
  }
}

/// When MEMOX_SHOT=1 (run with `flutter test --update-goldens`), captures a PNG
/// of the rendered screen under `test/parity/shots/<screen>.png`.
Future<void> _maybeShot(WidgetTester tester, String screen) async {
  if (Platform.environment['MEMOX_SHOT'] != '1') return;
  await expectLater(
    find.byType(MaterialApp).first,
    matchesGoldenFile('shots/$screen.png'),
  );
}

void main() {
  // Load the app's bundled font so golden shots (MEMOX_SHOT=1) render real text
  // instead of the test environment's box glyphs. No-op for the spec export.
  setUpAll(() async {
    final bytes = File('assets/fonts/PlusJakartaSans.ttf').readAsBytesSync();
    final loader = FontLoader('Plus Jakarta Sans')
      ..addFont(Future<ByteData>.value(bytes.buffer.asByteData()));
    await loader.load();
    // Material icons (env path to the SDK font) so glyphs render, not boxes.
    final iconPath = Platform.environment['MEMOX_ICON_FONT'];
    if (iconPath != null && File(iconPath).existsSync()) {
      final icons = File(iconPath).readAsBytesSync();
      final iconLoader = FontLoader('MaterialIcons')
        ..addFont(Future<ByteData>.value(icons.buffer.asByteData()));
      await iconLoader.load();
    }
  });

  testWidgets('export FE spec — library (empty state)', (tester) async {
    await _pumpAndExport(
      tester,
      'library',
      (db) async => const Scaffold(body: LibraryScreen()),
      drives: [
        // error branch → library/retry (a thrown build is the only clean path).
        (tester, db) async {
          await _repump(
            tester,
            db,
            const Scaffold(body: LibraryScreen()),
            extra: [libraryProvider.overrideWith(_ThrowingLibrary.new)],
          );
        },
      ],
    );
  });

  testWidgets('export FE spec — search', (tester) async {
    await _pumpAndExport(
      tester,
      'search',
      (db) async => const SearchScreen(),
      drives: [
        // a non-matching query → search/no-results.
        (tester, db) async {
          await tester.enterText(
            find.byKey(const ValueKey('mx-node:search/dock')),
            'zzznomatch',
          );
          await _drain(tester);
        },
      ],
    );
  });

  testWidgets('export FE spec — reminder', (tester) async {
    await _pumpAndExport(
      tester,
      'reminder',
      (db) async => const ReminderScreen(),
      // Enable the reminder so the time row isn't disabled/faded.
      seed: (db) async {
        await db
            .into(db.settings)
            .insert(
              SettingsCompanion.insert(
                key: 'reminder_time',
                value: const Value('08:00'),
              ),
            );
      },
    );
  });

  testWidgets('export FE spec — theme', (tester) async {
    await _pumpAndExport(tester, 'theme', (db) async => const ThemeScreen());
  });

  testWidgets('export FE spec — settings', (tester) async {
    await _pumpAndExport(
      tester,
      'settings',
      (db) async => const SettingsScreen(),
    );
  });

  testWidgets('export FE spec — statistics', (tester) async {
    await _pumpAndExport(
      tester,
      'statistics',
      (db) async => const Scaffold(body: StatisticsScreen()),
      // Seed a deck + card so words > 0 (hasEnoughData) → the overview renders,
      // and one review outcome so hasReviews → the accuracy card renders too.
      seed: (db) async {
        final pair = await db.select(db.languagePair).getSingle();
        final deckId = await db
            .into(db.deck)
            .insert(DeckCompanion.insert(pairId: pair.id, name: 'Deck'));
        final cardId = await db
            .into(db.card)
            .insert(
              CardCompanion.insert(deckId: deckId, term: 'mesa', createdAt: 1),
            );
        await db
            .into(db.reviewOutcome)
            .insert(
              ReviewOutcomeCompanion.insert(
                cardId: cardId,
                pairId: pair.id,
                ts: 1000,
                correct: 1,
                mode: 'dueReview',
              ),
            );
      },
    );
  });

  testWidgets('export FE spec — flashcard-editor', (tester) async {
    await _pumpAndExport(
      tester,
      'flashcard-editor',
      (db) async {
        final pair = await db.select(db.languagePair).getSingle();
        final deckId = await db
            .into(db.deck)
            .insert(DeckCompanion.insert(pairId: pair.id, name: 'Deck'));
        // an existing card so re-entering its term triggers the soft-dup banner.
        await db
            .into(db.card)
            .insert(
              CardCompanion.insert(deckId: deckId, term: 'mesa', createdAt: 1),
            );
        return FlashcardEditorScreen(deckId: deckId);
      },
      drives: [
        // soft-duplicate banner (D-020) → flashcard-editor/dup-add + /dup-view.
        (tester, db) async {
          await tester.enterText(
            find.byKey(const Key('editorTermField')),
            'mesa',
          );
          await tester.enterText(
            find.byKey(const Key('editorMeaningField')),
            'bàn',
          );
          await tester.tap(
            find.byKey(const ValueKey('mx-node:flashcard-editor/save')),
          );
          await _drain(tester);
        },
      ],
    );
  });

  testWidgets('export FE spec — export', (tester) async {
    await _pumpAndExport(
      tester,
      'export',
      (db) async {
        final pair = await db.select(db.languagePair).getSingle();
        final deckId = await db
            .into(db.deck)
            .insert(DeckCompanion.insert(pairId: pair.id, name: 'Deck'));
        return ExportScreen(deckId: deckId);
      },
      drives: [
        // run the export (fake file sink) → the export/progress result line.
        (tester, db) async {
          final deck = await (db.select(db.deck)..limit(1)).getSingle();
          await _repump(
            tester,
            db,
            ExportScreen(deckId: deck.id),
            extra: [fileSaveServiceProvider.overrideWithValue(_FakeFileSave())],
          );
          await tester.tap(
            find.byKey(const ValueKey('mx-node:export/do-export')),
          );
          await tester.pumpAndSettle();
        },
      ],
    );
  });

  testWidgets('export FE spec — import', (tester) async {
    await _pumpAndExport(
      tester,
      'import',
      (db) async {
        final pair = await db.select(db.languagePair).getSingle();
        final deckId = await db
            .into(db.deck)
            .insert(DeckCompanion.insert(pairId: pair.id, name: 'Deck'));
        return ImportScreen(deckId: deckId);
      },
      drives: [
        // paste rows (mock clipboard) → import/map-term-pick + /map-meaning-pick +
        // /do-import render.
        (tester, db) async {
          tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
            SystemChannels.platform,
            (call) async => call.method == 'Clipboard.getData'
                ? <String, dynamic>{'text': 'a\tb\nc\td'}
                : null,
          );
          addTearDown(
            () => tester.binding.defaultBinaryMessenger
                .setMockMethodCallHandler(SystemChannels.platform, null),
          );
          await tester.tap(find.byKey(const Key('importPaste')));
          await tester.pumpAndSettle();
        },
        // run the import → done → import/go-deck appears.
        (tester, db) async {
          await tester.tap(
            find.byKey(const ValueKey('mx-node:import/do-import')),
          );
          await tester.pumpAndSettle();
        },
      ],
    );
  });

  testWidgets('export FE spec — deck-detail', (tester) async {
    await _pumpAndExport(
      tester,
      'deck-detail',
      (db) async {
        final pair = await db.select(db.languagePair).getSingle();
        final deckId = await db
            .into(db.deck)
            .insert(DeckCompanion.insert(pairId: pair.id, name: 'Deck'));
        await db
            .into(db.card)
            .insert(
              CardCompanion.insert(deckId: deckId, term: 'mesa', createdAt: 1),
            );
        return DeckDetailScreen(deckId: deckId);
      },
      drives: [
        // empty state → empty-add / empty-subdeck / empty-import CTAs.
        (tester, db) async {
          final pair = await db.select(db.languagePair).getSingle();
          final emptyId = await db
              .into(db.deck)
              .insert(DeckCompanion.insert(pairId: pair.id, name: 'Empty'));
          await _repump(tester, db, DeckDetailScreen(deckId: emptyId));
        },
        // deck-delete confirm dialog → deck-delete-cancel / deck-delete-ok.
        (tester, db) async {
          final deck = await (db.select(db.deck)..limit(1)).getSingle();
          await _repump(tester, db, DeckDetailScreen(deckId: deck.id));
          await tester.tap(
            find.byKey(const ValueKey('mx-node:deck-detail/menu')),
          );
          await tester.pumpAndSettle();
          await tester.tap(find.byKey(const Key('deckActionDelete')));
          await tester.pumpAndSettle();
        },
      ],
    );
  });

  testWidgets('export FE spec — study-session', (tester) async {
    await _pumpAndExport(
      tester,
      'study-session',
      (db) async {
        final pair = await db.select(db.languagePair).getSingle();
        final deckId = await db
            .into(db.deck)
            .insert(DeckCompanion.insert(pairId: pair.id, name: 'Deck'));
        for (var i = 0; i < 3; i++) {
          await db
              .into(db.card)
              .insert(
                CardCompanion.insert(deckId: deckId, term: 'w$i', createdAt: i),
              );
        }
        return StudySessionScreen(nodeId: deckId, entry: StudyEntry.newLearn);
      },
      drives: [
        // the exit-confirm dialog → study-session/exit-cancel + /exit-ok.
        (tester, db) async {
          await tester.tap(find.byIcon(Icons.close));
          await tester.pumpAndSettle();
        },
      ],
    );
  });

  testWidgets('export FE spec — review', (tester) async {
    await _pumpAndExport(
      tester,
      'review',
      (db) async {
        final pair = await db.select(db.languagePair).getSingle();
        final deckId = await db
            .into(db.deck)
            .insert(DeckCompanion.insert(pairId: pair.id, name: 'Deck'));
        for (var i = 0; i < 3; i++) {
          await db
              .into(db.card)
              .insert(
                CardCompanion.insert(deckId: deckId, term: 'w$i', createdAt: i),
              );
        }
        return ReviewScreen(nodeId: deckId);
      },
      drives: [
        // an empty deck → end state → review/study-now + /back-deck.
        (tester, db) async {
          final pair = await db.select(db.languagePair).getSingle();
          final emptyId = await db
              .into(db.deck)
              .insert(DeckCompanion.insert(pairId: pair.id, name: 'Empty'));
          await _repump(tester, db, ReviewScreen(nodeId: emptyId));
        },
      ],
    );
  });

  testWidgets('export FE spec — player', (tester) async {
    await _pumpAndExport(
      tester,
      'player',
      (db) async {
        final pair = await db.select(db.languagePair).getSingle();
        final deckId = await db
            .into(db.deck)
            .insert(DeckCompanion.insert(pairId: pair.id, name: 'Deck'));
        for (var i = 0; i < 3; i++) {
          await db
              .into(db.card)
              .insert(
                CardCompanion.insert(deckId: deckId, term: 'w$i', createdAt: i),
              );
        }
        return PlayerScreen(nodeId: deckId);
      },
      drives: [
        // step past the last card → end state → player/replay + /close (bounded
        // pumps: the player may hold an autoplay timer, pumpAndSettle could hang).
        (tester, db) async {
          for (var i = 0; i < 4; i++) {
            final next = find.byKey(const ValueKey('mx-node:player/next'));
            if (next.evaluate().isEmpty) break;
            await tester.tap(next);
            await _drain(tester);
          }
        },
      ],
    );
  });

  testWidgets('export FE spec — game-matching', (tester) async {
    await _pumpAndExport(
      tester,
      'game-matching',
      (db) async {
        final pair = await db.select(db.languagePair).getSingle();
        final deckId = await db
            .into(db.deck)
            .insert(DeckCompanion.insert(pairId: pair.id, name: 'Deck'));
        for (var i = 0; i < 12; i++) {
          await db
              .into(db.card)
              .insert(
                CardCompanion.insert(deckId: deckId, term: 'w$i', createdAt: i),
              );
        }
        return GameScreen(
          request: GameRequest(
            nodeId: deckId,
            type: GameType.matching,
            scope: GameScope.all,
          ),
        );
      },
      drives: [
        // complete: match every pair (tiles are keyed matchLeft/right-<id> by
        // runtime cardId — read the first left tile's id, tap its pair, repeat).
        (tester, db) async {
          for (var i = 0; i < 12; i++) {
            final lefts = find.byWidgetPredicate(
              (w) =>
                  w.key is ValueKey<String> &&
                  (w.key! as ValueKey<String>).value.startsWith('matchLeft-'),
            );
            if (lefts.evaluate().isEmpty) break; // round complete
            final key =
                (lefts.evaluate().first.widget.key! as ValueKey<String>).value;
            final id = key.substring('matchLeft-'.length);
            await tester.tap(find.byKey(Key(key)));
            await tester.pumpAndSettle();
            await tester.tap(find.byKey(Key('matchRight-$id')));
            await tester.pumpAndSettle();
          }
        },
      ],
    );
  });

  testWidgets('export FE spec — game-typing', (tester) async {
    await _pumpAndExport(
      tester,
      'game-typing',
      (db) async {
        final pair = await db.select(db.languagePair).getSingle();
        final deckId = await db
            .into(db.deck)
            .insert(DeckCompanion.insert(pairId: pair.id, name: 'Deck'));
        for (var i = 0; i < 12; i++) {
          await db
              .into(db.card)
              .insert(
                CardCompanion.insert(deckId: deckId, term: 'w$i', createdAt: i),
              );
        }
        return GameScreen(
          request: GameRequest(
            nodeId: deckId,
            type: GameType.typing,
            scope: GameScope.all,
          ),
        );
      },
      drives: [
        // wrong branch → game-typing/retry + /accept (bounded pumps: the focused
        // TextField keeps a cursor-blink animation, pumpAndSettle would hang).
        (tester, db) async {
          await tester.enterText(find.byKey(const Key('typingField')), 'zz');
          await tester.tap(
            find.byKey(const ValueKey('mx-node:game-typing/check')),
          );
          await _drain(tester);
        },
        // complete: accept (= markCorrect) through every card → game-typing/complete.
        (tester, db) async {
          for (var i = 0; i < 12; i++) {
            final accept = find.byKey(
              const ValueKey('mx-node:game-typing/accept'),
            );
            if (accept.evaluate().isNotEmpty) {
              await tester.tap(accept);
              await _drain(tester);
            }
            final field = find.byKey(const Key('typingField'));
            if (field.evaluate().isEmpty) break; // round complete
            await tester.enterText(field, 'zz');
            await tester.tap(
              find.byKey(const ValueKey('mx-node:game-typing/check')),
            );
            await _drain(tester);
          }
        },
      ],
    );
  });

  testWidgets('export FE spec — game-recall', (tester) async {
    await _pumpAndExport(
      tester,
      'game-recall',
      (db) async {
        final pair = await db.select(db.languagePair).getSingle();
        final deckId = await db
            .into(db.deck)
            .insert(DeckCompanion.insert(pairId: pair.id, name: 'Deck'));
        for (var i = 0; i < 12; i++) {
          await db
              .into(db.card)
              .insert(
                CardCompanion.insert(deckId: deckId, term: 'w$i', createdAt: i),
              );
        }
        return GameScreen(
          request: GameRequest(
            nodeId: deckId,
            type: GameType.recall,
            scope: GameScope.all,
          ),
        );
      },
      drives: [
        // revealed → game-recall/meaning + /forgot + /remembered.
        (tester, db) async {
          await tester.tap(
            find.byKey(const ValueKey('mx-node:game-recall/reveal')),
          );
          await tester.pumpAndSettle();
        },
        // complete: remember every card → game-recall/complete.
        (tester, db) async {
          for (var i = 0; i < 12; i++) {
            final remembered = find.byKey(
              const ValueKey('mx-node:game-recall/remembered'),
            );
            if (remembered.evaluate().isEmpty) break;
            await tester.tap(remembered);
            await tester.pumpAndSettle();
            final reveal = find.byKey(
              const ValueKey('mx-node:game-recall/reveal'),
            );
            if (reveal.evaluate().isEmpty) break; // round complete
            await tester.tap(reveal);
            await tester.pumpAndSettle();
          }
        },
      ],
    );
  });

  testWidgets('export FE spec — game-mc', (tester) async {
    await _pumpAndExport(
      tester,
      'game-mc',
      (db) async {
        final pair = await db.select(db.languagePair).getSingle();
        final deckId = await db
            .into(db.deck)
            .insert(DeckCompanion.insert(pairId: pair.id, name: 'Deck'));
        for (var i = 0; i < 12; i++) {
          await db
              .into(db.card)
              .insert(
                CardCompanion.insert(deckId: deckId, term: 'w$i', createdAt: i),
              );
        }
        return GameScreen(
          request: GameRequest(
            nodeId: deckId,
            type: GameType.multipleChoice,
            scope: GameScope.all,
          ),
        );
      },
      drives: [
        // complete: answer every card correctly → game-mc/complete.
        (tester, db) async {
          for (var i = 0; i < 12; i++) {
            final correct = find.byKey(const Key('mcCorrect'));
            if (correct.evaluate().isEmpty) break;
            await tester.tap(correct);
            await tester.pumpAndSettle();
          }
        },
      ],
    );
  });

  testWidgets('export FE spec — game-picker', (tester) async {
    await _pumpAndExport(
      tester,
      'game-picker',
      (db) async {
        final pair = await db.select(db.languagePair).getSingle();
        final deckId = await db
            .into(db.deck)
            .insert(DeckCompanion.insert(pairId: pair.id, name: 'Deck'));
        for (var i = 0; i < 12; i++) {
          await db
              .into(db.card)
              .insert(
                CardCompanion.insert(deckId: deckId, term: 'w$i', createdAt: i),
              );
        }
        return GamePickerScreen(nodeId: deckId);
      },
      drives: [
        // an empty deck → not-enough → game-picker/add-cards.
        (tester, db) async {
          final pair = await db.select(db.languagePair).getSingle();
          final emptyId = await db
              .into(db.deck)
              .insert(DeckCompanion.insert(pairId: pair.id, name: 'Empty'));
          await _repump(tester, db, GamePickerScreen(nodeId: emptyId));
        },
      ],
    );
  });

  // study-result is the finished state of the study session; drive a 1-card
  // DueReview session to completion, then export the result.
  testWidgets('export FE spec — study-result', (tester) async {
    final db = AppDatabase.forTesting(openInMemoryDatabase());
    addTearDown(db.close);
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
        .insert(CardCompanion.insert(deckId: deckId, term: 'w', createdAt: 1));
    await db
        .into(db.srsState)
        .insert(
          SrsStateCompanion.insert(
            cardId: Value(cardId),
            box: const Value(1),
            dueAt: const Value(0),
          ),
        );

    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          theme: AppTheme.light(),
          debugShowCheckedModeBanner: false,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: StudySessionScreen(nodeId: deckId, entry: StudyEntry.dueReview),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // DueReview = recall: reveal then grade "remembered" → 1-card session finishes.
    final reveal = find.byKey(const ValueKey('mx-node:game-recall/reveal'));
    if (reveal.evaluate().isNotEmpty) {
      await tester.tap(reveal);
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const ValueKey('mx-node:game-recall/remembered')),
      );
      await tester.pumpAndSettle();
    }
    while (tester.takeException() != null) {}
    _exportScreen(tester, 'study-result');
    await _maybeShot(tester, 'study-result');
  });

  // Dashboard: the today/start hero renders in every state and is what we gate.
  // The goal/streak/mastered stat cards only appear once there is logged study
  // activity (status != empty) — a state the minimal card seed doesn't reproduce
  // — so they fall under "state not exported", like other screens' deeper states.
  testWidgets('export FE spec — dashboard', (tester) async {
    final db = AppDatabase.forTesting(openInMemoryDatabase());
    addTearDown(db.close);
    final pairId = await db
        .into(db.languagePair)
        .insert(
          LanguagePairCompanion.insert(sourceLang: 'ko', targetLang: 'vi'),
        );
    final deckId = await db
        .into(db.deck)
        .insert(DeckCompanion.insert(pairId: pairId, name: 'Deck'));
    for (var i = 0; i < 6; i++) {
      final cardId = await db
          .into(db.card)
          .insert(
            CardCompanion.insert(deckId: deckId, term: 'w$i', createdAt: i),
          );
      await db
          .into(db.srsState)
          .insert(
            SrsStateCompanion.insert(
              cardId: Value(cardId),
              box: Value(i == 0 ? 8 : 1),
              dueAt: const Value(0),
            ),
          );
    }
    // Seed today's activity + an unmet daily goal so the dashboard renders its
    // POPULATED state (goal ring / streak / mastered / decks stack), not the
    // minimal empty state — otherwise only today+start export and the rest go
    // unchecked (style-parity blind spot). Goal (40) > words (24) → the goal card
    // shows the progress-ring variant, matching the kit's `loaded` spec.
    await db
        .into(db.settings)
        .insert(
          SettingsCompanion.insert(
            key: 'daily_goal_words',
            value: const Value('40'),
          ),
        );
    await db
        .into(db.dailyActivity)
        .insert(
          DailyActivityCompanion.insert(
            day: dayKey(DateTime.now()),
            pairId: pairId,
            seconds: const Value(750),
            words: const Value(24),
          ),
        );

    tester.view.physicalSize = const Size(390, 1800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          theme: AppTheme.light(),
          debugShowCheckedModeBanner: false,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(body: DashboardScreen()),
        ),
      ),
    );
    await tester.pumpAndSettle();
    while (tester.takeException() != null) {}
    _exportScreen(tester, 'dashboard');
    await _maybeShot(tester, 'dashboard');

    // Empty state (a fresh db with no activity) → the dashboard/start CTA.
    // dashboard/appbar + /notifications + /quick-review live in the app shell
    // (app_shell.dart), outside this body harness — a documented coverage gap.
    final db2 = AppDatabase.forTesting(openInMemoryDatabase());
    addTearDown(db2.close);
    await db2
        .into(db2.languagePair)
        .insert(
          LanguagePairCompanion.insert(sourceLang: 'ko', targetLang: 'vi'),
        );
    await _repump(tester, db2, const Scaffold(body: DashboardScreen()));
    while (tester.takeException() != null) {}
    _exportScreen(tester, 'dashboard', merge: true);
  });

  // The drawer's keyed mx-nodes live in its add-language view (add-screen,
  // add-confirm); open the drawer and switch into that view, then export.
  testWidgets('export FE spec — drawer', (tester) async {
    final db = AppDatabase.forTesting(openInMemoryDatabase());
    addTearDown(db.close);
    await db
        .into(db.languagePair)
        .insert(
          LanguagePairCompanion.insert(sourceLang: 'ko', targetLang: 'vi'),
        );

    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          theme: AppTheme.light(),
          debugShowCheckedModeBanner: false,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(body: AppDrawer()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final addLang = find.byKey(const Key('drawerAddLanguage'));
    if (addLang.evaluate().isNotEmpty) {
      await tester.tap(addLang);
      await tester.pumpAndSettle();
    }
    while (tester.takeException() != null) {}
    _exportScreen(tester, 'drawer');
    await _maybeShot(tester, 'drawer');

    // remove-language view → drawer/remove-screen; then tap a pair's delete →
    // the confirm AlertDialog → drawer/remove-cancel + drawer/remove-ok.
    await tester.tap(find.byKey(const Key('addBack')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('drawerRemoveLanguage')));
    await tester.pumpAndSettle();
    while (tester.takeException() != null) {}
    _exportScreen(tester, 'drawer', merge: true);

    await tester.tap(find.byIcon(Icons.delete_outline).first);
    await tester.pumpAndSettle();
    while (tester.takeException() != null) {}
    _exportScreen(tester, 'drawer', merge: true);
  });
}

/// Reverse map: a resolved [Color] → its `--memox-*` token name (kebab-case, the
/// kit spec's vocabulary). Keyed by Color (Color's == is value-based).
Map<Color, String> _tokenMap(BuildContext context) {
  final c = MxTheme.of(context).colors;
  final m = <Color, String>{};
  void put(Color color, String name) => m.putIfAbsent(color, () => name);
  put(c.bg, 'bg');
  put(c.surface, 'surface');
  put(c.surfaceMuted, 'surface-muted');
  put(c.surfaceRaised, 'surface-raised');
  put(c.surfaceSunken, 'surface-sunken');
  put(c.text, 'text');
  put(c.textSecondary, 'text-secondary');
  put(c.textTertiary, 'text-tertiary');
  put(c.primary, 'primary');
  put(c.primaryStrong, 'primary-strong');
  put(c.onPrimary, 'on-primary');
  put(c.primarySoft, 'primary-soft');
  put(c.onPrimarySoft, 'on-primary-soft');
  put(c.accent, 'accent');
  put(c.onAccent, 'on-accent');
  put(c.accentSoft, 'accent-soft');
  put(c.success, 'success');
  put(c.successSoft, 'success-soft');
  put(c.onSuccessSoft, 'on-success-soft');
  put(c.warning, 'warning');
  put(c.warningSoft, 'warning-soft');
  put(c.onWarningSoft, 'on-warning-soft');
  put(c.error, 'error');
  put(c.onError, 'on-error');
  put(c.errorSoft, 'error-soft');
  put(c.onErrorSoft, 'on-error-soft');
  return m;
}

String _color(Map<Color, String> tokens, Color? color) {
  if (color == null || color == const Color(0x00000000)) return '';
  return tokens[color] ?? color.toString();
}

String? _radiusStr(BorderRadiusGeometry? br) =>
    br is BorderRadius ? br.topLeft.x.round().toString() : null;

String? _materialRadius(Material material) {
  final direct = material.borderRadius;
  if (direct is BorderRadius) return direct.topLeft.x.round().toString();
  final shape = material.shape;
  if (shape is RoundedRectangleBorder) return _radiusStr(shape.borderRadius);
  if (shape is StadiumBorder || shape is CircleBorder) return '9999';
  return null;
}

void _exportScreen(WidgetTester tester, String screen, {bool merge = false}) {
  final context = tester.element(find.byType(Scaffold).first);
  final tokens = _tokenMap(context);

  final nodes = <Map<String, Object?>>[];
  for (final element in tester.allElements) {
    final key = element.widget.key;
    if (key is! ValueKey) continue;
    final value = key.value;
    if (value is! String || !value.startsWith(_prefix)) continue;
    final render = element.renderObject;
    if (render is! RenderBox || !render.hasSize) continue;

    final style = _styleOf(element, tokens);
    nodes.add(<String, Object?>{
      'id': value.substring(_prefix.length),
      'w': render.size.width.round(),
      'h': render.size.height.round(),
      ...style,
    });
  }

  // Only write the artifact when explicitly exporting (MEMOX_EXPORT_SPEC=1), so a
  // normal `flutter test` run (e.g. inside verify) renders + walks the tree but
  // does NOT mutate the working tree.
  if (Platform.environment['MEMOX_EXPORT_SPEC'] != '1') return;
  final file = File('tool/parity/fe-specs/$screen.json');
  file.parent.createSync(recursive: true);

  // merge: union with the records already on disk (the base-state export),
  // FIRST-wins per node id — a node visible in both states keeps its base-state
  // style, matching spec_diff's parseKit which also keeps the first style seen.
  var out = nodes;
  if (merge && file.existsSync()) {
    final existing = (jsonDecode(file.readAsStringSync()) as List<dynamic>)
        .cast<Map<String, dynamic>>();
    final seen = existing.map((n) => n['id'] as String).toSet();
    out = <Map<String, Object?>>[
      ...existing,
      for (final n in nodes)
        if (!seen.contains(n['id'] as String)) n,
    ];
  }
  out.sort((a, b) => (a['id']! as String).compareTo(b['id']! as String));
  file.writeAsStringSync(const JsonEncoder.withIndent('  ').convert(out));
  // ignore: avoid_print
  print('wrote ${file.path} (${out.length} nodes${merge ? ', merged' : ''})');
}

/// Flattens the effective style of a keyed node: the first colored box (bg +
/// radius) and the first text run (font + color) inside its subtree, stopping at
/// any nested mx-node (those own their own record).
Map<String, Object?> _styleOf(Element root, Map<Color, String> tokens) {
  String? bg;
  String? color;
  String? font;
  String? radius;

  void visit(Element element) {
    if (!identical(element, root)) {
      final key = element.widget.key;
      if (key is ValueKey &&
          key.value is String &&
          (key.value! as String).startsWith(_prefix)) {
        return; // nested keyed node owns its style
      }
    }
    // bg (first non-transparent fill) + radius (first shaped box) from the first
    // painted box: Material / Container / DecoratedBox. Radius is captured even
    // when the fill is transparent (e.g. a plain icon button's CircleBorder).
    final widget = element.widget;
    BoxDecoration? boxOf(Widget w) => switch (w) {
      Container(:final decoration) when decoration is BoxDecoration =>
        decoration,
      DecoratedBox(:final decoration) when decoration is BoxDecoration =>
        decoration,
      _ => null,
    };
    if (widget is TextField) {
      // InputDecoration fill/border are painted, not child widgets — read them off
      // the declared decoration.
      final dec = widget.decoration;
      if (dec != null) {
        if ((dec.filled ?? false) && bg == null) {
          final b = _color(tokens, dec.fillColor);
          if (b.isNotEmpty) bg = b;
        }
        final border = dec.border;
        if (border is OutlineInputBorder) {
          radius ??= _radiusStr(border.borderRadius);
        }
      }
    } else if (widget is Material) {
      radius ??= _materialRadius(widget);
      final b = _color(tokens, widget.color);
      if (b.isNotEmpty && bg == null) bg = b;
    } else {
      final d = boxOf(widget);
      if (d != null) {
        radius ??= _radiusStr(d.borderRadius);
        final b = _color(tokens, d.color);
        if (b.isNotEmpty && bg == null) bg = b;
      }
    }
    // font + color from the first resolved text run.
    final render = element.renderObject;
    if (render is RenderParagraph && font == null) {
      final style = render.text.style;
      final size = style?.fontSize;
      if (size != null) {
        final weight = style?.fontWeight;
        final w = weight == null ? '' : weight.value.toString();
        font = '${size.round()}/$w';
        color = _color(tokens, style?.color);
      }
    }
    element.visitChildren(visit);
  }

  visit(root);
  return <String, Object?>{'bg': bg, 'color': color, 'font': font, 'r': radius};
}
