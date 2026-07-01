import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox_v4/core/theme/app_theme.dart';
import 'package:memox_v4/core/theme/theme_prefs.dart';
import 'package:memox_v4/l10n/generated/app_localizations.dart';
import 'package:memox_v4/presentation/features/personalization/screens/theme_screen.dart';
import 'package:memox_v4/presentation/features/personalization/viewmodels/personalization_notifier.dart';
import 'package:memox_v4/presentation/shared/widgets/display/mx_text.dart';
import 'package:memox_v4/presentation/shared/widgets/surfaces/mx_card.dart';

/// PER-STATE parity gate for the theme screen — mirrors review_parity_test.dart
/// (Template A), driven by three generated/curated contracts (no pixels, no AI):
///   - theme.gen.json    : identity + component + variant   (gen_parity_contract.mjs)
///   - theme.slots.json  : text role + binding per node      (curated from gen_slots.mjs)
///   - theme.states.json : which node ids are present per STATE (gen_states.mjs)
///
/// theme's 3 kit states (light / dark / accent-size) are NOT node-distinct — each
/// only remaps ThemePrefs (color-mode / accent / font scale). The keyed MxCard
/// theme/preview renders identically in all three, so the gate is: preview identity
/// + variant + slots hold across every ThemePrefs. There is no absent-node state.
///
/// The FE renders theme/preview as MxCardVariant.flat, but gen.json says elevated —
/// a documented VARIANT divergence (intent-ledger exceptionKind:variant, feVariant).
/// This test reads that override and asserts the FE variant (flat), not gen's.
const Map<String, MxCardVariant> _variants = <String, MxCardVariant>{
  'elevated': MxCardVariant.elevated,
  'flat': MxCardVariant.flat,
  'muted': MxCardVariant.muted,
  'primary': MxCardVariant.primary,
  'primarySoft': MxCardVariant.primarySoft,
};

// Curated kit-state -> the ThemePrefs that reaches it. All three render the same
// node-set (preview present); the value only remaps tokens/accent/scale.
const Map<String, ThemePrefs> _stateSeed = <String, ThemePrefs>{
  'light': ThemePrefs(mode: ThemeMode.light),
  'dark': ThemePrefs(mode: ThemeMode.dark),
  'accent-size': ThemePrefs(
    accent: AccentChoice.warm,
    fontScale: FontScale.large,
  ),
};

/// Feeds a fixed ThemePrefs so a state can be pumped without the settings store.
class _FixedPersonalization extends PersonalizationNotifier {
  _FixedPersonalization(this._prefs);
  final ThemePrefs _prefs;
  @override
  Future<ThemePrefs> build() async => _prefs;
}

MxTextRole _role(String name) =>
    MxTextRole.values.firstWhere((r) => r.name == name);

Map<String, dynamic> _readJson(String path) =>
    jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;

void main() {
  final nodes =
      (_readJson('tool/parity/contracts/theme.gen.json')['nodes']
              as List<dynamic>)
          .cast<Map<String, dynamic>>();
  final slotMap =
      _readJson('tool/parity/contracts/theme.slots.json')['slots']
          as Map<String, dynamic>;
  final stateNodes =
      _readJson('tool/parity/contracts/theme.states.json')['states']
          as Map<String, dynamic>;
  final exceptions =
      (_readJson('tool/parity/intent-ledger.json')['exceptions']
              as List<dynamic>)
          .cast<Map<String, dynamic>>();

  // Documented variant overrides: nodes the FE intentionally renders with a
  // different MxCard variant than the kit (intent-ledger exceptionKind 'variant').
  String? feVariant(String node) {
    for (final e in exceptions) {
      if (e['screen'] == 'theme' &&
          e['node'] == node &&
          e['exceptionKind'] == 'variant') {
        return e['feVariant'] as String?;
      }
    }
    return null;
  }

  Widget host(ThemePrefs prefs) => ProviderScope(
    overrides: [
      personalizationProvider.overrideWith(() => _FixedPersonalization(prefs)),
    ],
    child: MaterialApp(
      theme: AppTheme.light(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const ThemeScreen(),
    ),
  );

  for (final entry in _stateSeed.entries) {
    final state = entry.key;
    testWidgets('state "$state": MxCard identity matches theme.states.json', (
      tester,
    ) async {
      await tester.pumpWidget(host(entry.value));
      // The prefs load async; the FE falls back to a default ThemePrefs while
      // loading, so preview renders immediately — pump a few frames to settle.
      for (var i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      final present = (stateNodes[state] as List<dynamic>).cast<String>();

      for (final node in nodes) {
        // Template A loops only MxCard nodes (theme/preview); the others are
        // non-MxCard chrome/heads covered at the identity layer.
        if (node['component'] != 'MxCard') continue;
        final key = node['key'] as String; // 'mx-node:theme/…'
        final id = key.replaceFirst('mx-node:', '');
        final nodeName = key.replaceFirst('mx-node:theme/', '');
        final finder = find.byKey(ValueKey(key));

        if (!present.contains(key)) {
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

        // 2. STYLING (variant ⇒ bg/radius/border). A documented variant
        // divergence (intent-ledger) overrides the gen.json variant.
        final expectedName = feVariant(nodeName) ?? node['variant'] as String;
        final expectedVariant = _variants[expectedName];
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
    });
  }
}
