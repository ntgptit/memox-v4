import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox_v4/app/di/database_provider.dart';
import 'package:memox_v4/core/theme/app_theme.dart';
import 'package:memox_v4/data/datasources/local/connection/database_connection.dart';
import 'package:memox_v4/data/datasources/local/drift/app_database.dart';
import 'package:memox_v4/l10n/generated/app_localizations.dart';
import 'package:memox_v4/presentation/features/settings/screens/reminder_screen.dart';

/// State-COMPOSITION parity gate (Template B) for reminder, driven by the curated
/// `tool/parity/contracts/reminder.states.json`. The one gen MxCard node (reminder/time)
/// is a Container in the FE, so — like dashboard_states_test — we pump each state and
/// assert the FE renders EXACTLY the kit's keyed set (present → findsOneWidget, absent →
/// findsNothing), never casting the widget type.
///
/// NOTE: `on` and `off` render the SAME keyed node-set (reminder/time + reminder/time-edit);
/// the difference is only the enabled flag / opacity / active-hint, not the node-set — so
/// this layer does NOT distinguish on vs off (a documented gap). Its value is catching a
/// keyed node disappearing (THIẾU) or a stray one appearing (THỪA). The kit's `time-picker`
/// state is a framework showTimePicker dialog with no keyed node → coverage gap, not driven.
Map<String, dynamic> _readJson(String path) =>
    jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;

void main() {
  late AppDatabase db;

  final states =
      (_readJson('tool/parity/contracts/reminder.states.json')['states']
              as Map<String, dynamic>)
          .map(
            (k, v) => MapEntry(k, (v as List<dynamic>).cast<String>().toSet()),
          );
  final universe = states.values.expand((s) => s).toSet();

  setUp(() async {
    db = AppDatabase.forTesting(openInMemoryDatabase());
  });
  tearDown(() => db.close());

  Widget host() => ProviderScope(
    overrides: [databaseProvider.overrideWithValue(db)],
    child: MaterialApp(
      theme: AppTheme.light(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const Scaffold(body: ReminderScreen()),
    ),
  );

  // `on` seeds a reminder_time setting (→ Reminder.enabled == true); `off` leaves the
  // settings empty (→ Reminder.off). Both render the same keyed node-set.
  final recipes = <String, Future<void> Function()>{
    'off': () async {},
    'on': () async {
      await db
          .into(db.settings)
          .insert(
            SettingsCompanion.insert(
              key: 'reminder_time',
              value: const Value('09:00'),
            ),
          );
    },
  };

  for (final entry in recipes.entries) {
    final state = entry.key;
    testWidgets('state "$state": FE body renders exactly the kit node set', (
      tester,
    ) async {
      await entry.value();
      await tester.pumpWidget(host());
      await tester.pumpAndSettle();

      final allowed = states[state]!;
      for (final key in universe) {
        final finder = find.byKey(ValueKey(key));
        if (allowed.contains(key)) {
          expect(finder, findsOneWidget, reason: 'state "$state": $key THIẾU');
        } else {
          expect(
            finder,
            findsNothing,
            reason: 'state "$state": $key present but kit omits it here (THỪA)',
          );
        }
      }
    });
  }
}
