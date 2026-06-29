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
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox_v4/app/di/database_provider.dart';
import 'package:memox_v4/core/theme/app_theme.dart';
import 'package:memox_v4/core/theme/mx_theme.dart';
import 'package:memox_v4/data/datasources/local/connection/database_connection.dart';
import 'package:memox_v4/data/datasources/local/drift/app_database.dart';
import 'package:memox_v4/domain/types/study_entry.dart';
import 'package:memox_v4/l10n/generated/app_localizations.dart';
import 'package:memox_v4/presentation/features/deck/screens/deck_detail_screen.dart';
import 'package:memox_v4/presentation/features/deck/screens/library_screen.dart';
import 'package:memox_v4/presentation/features/flashcard/screens/flashcard_editor_screen.dart';
import 'package:memox_v4/presentation/features/import_export/screens/export_screen.dart';
import 'package:memox_v4/presentation/features/import_export/screens/import_screen.dart';
import 'package:memox_v4/presentation/features/personalization/screens/theme_screen.dart';
import 'package:memox_v4/presentation/features/search/screens/search_screen.dart';
import 'package:memox_v4/presentation/features/settings/screens/reminder_screen.dart';
import 'package:memox_v4/presentation/features/settings/screens/settings_screen.dart';
import 'package:memox_v4/presentation/features/statistics/screens/statistics_screen.dart';
import 'package:memox_v4/presentation/features/study/screens/study_session_screen.dart';

const String _prefix = 'mx-node:';

/// Pumps [child] at the kit's 390-wide frame with a seeded in-memory DB, then
/// exports its mx-node style record.
Future<void> _pumpAndExport(
  WidgetTester tester,
  String screen,
  Future<Widget> Function(AppDatabase db) buildChild, {
  Future<void> Function(AppDatabase db)? seed,
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
}

void main() {
  testWidgets('export FE spec — library (empty state)', (tester) async {
    await _pumpAndExport(
      tester,
      'library',
      (db) async => const Scaffold(body: LibraryScreen()),
    );
  });

  testWidgets('export FE spec — search', (tester) async {
    await _pumpAndExport(tester, 'search', (db) async => const SearchScreen());
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
      // Seed a deck + card so words > 0 (hasEnoughData) → the overview renders.
      seed: (db) async {
        final pair = await db.select(db.languagePair).getSingle();
        final deckId = await db
            .into(db.deck)
            .insert(DeckCompanion.insert(pairId: pair.id, name: 'Deck'));
        await db
            .into(db.card)
            .insert(
              CardCompanion.insert(deckId: deckId, term: 'mesa', createdAt: 1),
            );
      },
    );
  });

  testWidgets('export FE spec — flashcard-editor', (tester) async {
    await _pumpAndExport(tester, 'flashcard-editor', (db) async {
      final pair = await db.select(db.languagePair).getSingle();
      final deckId = await db
          .into(db.deck)
          .insert(DeckCompanion.insert(pairId: pair.id, name: 'Deck'));
      return FlashcardEditorScreen(deckId: deckId);
    });
  });

  testWidgets('export FE spec — export', (tester) async {
    await _pumpAndExport(tester, 'export', (db) async {
      final pair = await db.select(db.languagePair).getSingle();
      final deckId = await db
          .into(db.deck)
          .insert(DeckCompanion.insert(pairId: pair.id, name: 'Deck'));
      return ExportScreen(deckId: deckId);
    });
  });

  testWidgets('export FE spec — import', (tester) async {
    await _pumpAndExport(tester, 'import', (db) async {
      final pair = await db.select(db.languagePair).getSingle();
      final deckId = await db
          .into(db.deck)
          .insert(DeckCompanion.insert(pairId: pair.id, name: 'Deck'));
      return ImportScreen(deckId: deckId);
    });
  });

  testWidgets('export FE spec — deck-detail', (tester) async {
    await _pumpAndExport(tester, 'deck-detail', (db) async {
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
    });
  });

  testWidgets('export FE spec — study-session', (tester) async {
    await _pumpAndExport(tester, 'study-session', (db) async {
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
    });
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
  put(c.warning, 'warning');
  put(c.warningSoft, 'warning-soft');
  put(c.onWarningSoft, 'on-warning-soft');
  put(c.error, 'error');
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

void _exportScreen(WidgetTester tester, String screen) {
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
  nodes.sort((a, b) => (a['id']! as String).compareTo(b['id']! as String));

  // Only write the artifact when explicitly exporting (MEMOX_EXPORT_SPEC=1), so a
  // normal `flutter test` run (e.g. inside verify) renders + walks the tree but
  // does NOT mutate the working tree.
  if (Platform.environment['MEMOX_EXPORT_SPEC'] != '1') return;
  final file = File('tool/parity/fe-specs/$screen.json');
  file.parent.createSync(recursive: true);
  file.writeAsStringSync(const JsonEncoder.withIndent('  ').convert(nodes));
  // ignore: avoid_print
  print('wrote ${file.path} (${nodes.length} nodes)');
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
