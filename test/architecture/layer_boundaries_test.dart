import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Architecture guard (WBS I.10). custom_lint / riverpod_lint cannot resolve on
/// this toolchain (Riverpod 3 + drift on Dart 3.11 — analyzer version conflict),
/// so the layer boundaries are enforced here by a source-scanning test instead of
/// a lint plugin.
///
/// The rule engine below is made of pure functions so each rule is proven to FIRE
/// on a synthetic violation (the self-test group) before it is run against the
/// real `lib/` tree. A feature can never quietly break the layering: if it does,
/// this test goes red.

// ── Rule engine (pure) ──────────────────────────────────────────────────────

/// Imports a `domain/` file may never pull in — the domain is pure Dart, unaware
/// of Flutter, persistence, routing, or the outer layers.
const _domainForbidden = <String>[
  'package:flutter/',
  'package:memox_v4/data/',
  'package:memox_v4/presentation/',
  'package:drift/',
  'package:go_router/',
  'dart:io',
  'dart:ui',
];

/// Imports feature UI may never pull in — presentation talks to the domain via
/// providers, never to persistence, drift, or platform plugins directly.
const _presentationForbidden = <String>[
  'package:memox_v4/data/',
  'package:drift/',
  'package:sqlite3',
  'package:path_provider',
  'dart:io',
];

/// A Riverpod provider must not perform navigation — routing is a UI concern.
const _providerForbidden = <String>['package:go_router/'];

String _norm(String path) => path.replaceAll('\\', '/');

bool _isDomain(String p) => _norm(p).contains('/domain/');
bool _isPresentation(String p) => _norm(p).contains('/presentation/');

/// Provider files (`*_provider.dart` or anything under a `providers/` dir), except
/// the app router itself — the one place go_router is meant to live.
bool _isProvider(String p) {
  final n = _norm(p);
  if (n.endsWith('app_router.dart')) return false;
  return n.endsWith('_provider.dart') || n.contains('/providers/');
}

bool _isGenerated(String p) {
  final n = _norm(p);
  return n.endsWith('.g.dart') ||
      n.endsWith('.drift.dart') ||
      n.endsWith('.freezed.dart');
}

/// Forbidden-import violations for a single file given its import URIs.
List<String> importViolations(String path, List<String> imports) {
  final n = _norm(path);
  final out = <String>[];

  void check(List<String> forbidden, String layer) {
    for (final imp in imports) {
      for (final bad in forbidden) {
        if (!imp.contains(bad)) continue;
        // The DI provider seam (`data/providers/`) is the sanctioned channel by
        // which presentation obtains repositories/services — swapping fakes →
        // Drift never touches a screen. It is allowed, unlike data *impls*
        // (repos/drift/plugins). The domain stays pure and may not use it.
        if (layer == 'presentation' &&
            bad == 'package:memox_v4/data/' &&
            imp.contains('package:memox_v4/data/providers/')) {
          continue;
        }
        out.add('$layer file "$n" imports "$imp" (forbidden: "$bad")');
      }
    }
  }

  if (_isDomain(n)) check(_domainForbidden, 'domain');
  if (_isPresentation(n)) check(_presentationForbidden, 'presentation');
  if (_isProvider(n)) check(_providerForbidden, 'provider');
  return out;
}

final _navLiteral = RegExp(r"\.(go|push|replace|pushReplacement)\(\s*'/");
final _inlineGoRoutePath = RegExp(r"GoRoute\(\s*path:\s*'");

/// Raw navigation path literals — nav must go through the typed `Routes` table,
/// and route paths are declared only under `core/routes/`.
List<String> navLiteralViolations(String path, String content) {
  final n = _norm(path);
  if (n.contains('/core/routes/')) return const [];
  final out = <String>[];
  if (_navLiteral.hasMatch(content)) {
    out.add('raw navigation path literal in "$n" — navigate via Routes.*');
  }
  if (_inlineGoRoutePath.hasMatch(content)) {
    out.add('inline GoRoute path literal in "$n" — declare routes under core/routes');
  }
  return out;
}

final _importLine = RegExp("^\\s*(?:import|export)\\s+'([^']+)'", multiLine: true);

List<String> importsOf(String content) =>
    _importLine.allMatches(content).map((m) => m.group(1)!).toList();

Iterable<File> _dartSources(String dir) => Directory(dir)
    .listSync(recursive: true)
    .whereType<File>()
    .where((f) => f.path.endsWith('.dart'))
    .where((f) => !_isGenerated(f.path));

// ── Tests ───────────────────────────────────────────────────────────────────

void main() {
  group('rules fire on deliberate violations (self-test)', () {
    test('domain may not import Flutter / data / presentation / drift', () {
      expect(importViolations('lib/domain/e.dart', ['package:flutter/material.dart']),
          isNotEmpty);
      expect(importViolations('lib/domain/e.dart', ['package:memox_v4/data/db.dart']),
          isNotEmpty);
      expect(
          importViolations('lib/domain/e.dart', ['package:memox_v4/presentation/x.dart']),
          isNotEmpty);
      // A domain-internal import is fine.
      expect(importViolations('lib/domain/e.dart', ['package:memox_v4/domain/v.dart']),
          isEmpty);
    });

    test('presentation may not import data / drift / plugins', () {
      const f = 'lib/presentation/features/deck/screen.dart';
      expect(importViolations(f, ['package:drift/drift.dart']), isNotEmpty);
      expect(importViolations(f, ['package:memox_v4/data/repo.dart']), isNotEmpty);
      // Flutter + domain use-cases are exactly what a screen should import.
      expect(importViolations(f, ['package:flutter/material.dart']), isEmpty);
      // The DI provider seam is the one data/ import presentation may use…
      expect(
          importViolations(f, ['package:memox_v4/data/providers/data_providers.dart']),
          isEmpty);
      // …but a concrete data implementation is still forbidden.
      expect(
          importViolations(f, ['package:memox_v4/data/repositories/deck_repo.dart']),
          isNotEmpty);
      // The domain stays pure — it may not reach the seam either.
      expect(
          importViolations('lib/domain/x.dart',
              ['package:memox_v4/data/providers/data_providers.dart']),
          isNotEmpty);
    });

    test('a provider may not import go_router; the app router is exempt', () {
      expect(
          importViolations('lib/presentation/features/deck/providers/deck_provider.dart',
              ['package:go_router/go_router.dart']),
          isNotEmpty);
      expect(
          importViolations('lib/core/routes/app_router.dart',
              ['package:go_router/go_router.dart']),
          isEmpty);
    });

    test('raw navigation path literals are flagged outside core/routes', () {
      expect(navLiteralViolations('lib/presentation/x.dart', "context.go('/today');"),
          isNotEmpty);
      expect(navLiteralViolations('lib/presentation/x.dart', 'context.go(Routes.today);'),
          isEmpty);
      expect(navLiteralViolations('lib/core/routes/app_router.dart', "GoRoute(path: '/x')"),
          isEmpty);
    });
  });

  test('the real lib/ tree obeys every layer boundary', () {
    final problems = <String>[];
    for (final f in _dartSources('lib')) {
      final content = f.readAsStringSync();
      problems.addAll(importViolations(f.path, importsOf(content)));
      problems.addAll(navLiteralViolations(f.path, content));
    }
    expect(problems, isEmpty, reason: problems.join('\n'));
  });

  test('generated token mirrors keep their DO-NOT-EDIT header', () {
    // A mirror is identified by the generator's signature line, NOT its filename —
    // hand-written theme files (mx_theme.dart, app_theme.dart) live alongside the
    // mirrors and must NOT be required to carry the header.
    const signature = 'GENERATED by tool/design/gen_tokens.mjs';
    final mirrors = Directory('lib/core/theme')
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))
        .where((f) => f.readAsStringSync().contains(signature));
    // gen_tokens writes 6 mirror files — guard against the check going vacuous.
    expect(mirrors.length, greaterThanOrEqualTo(6),
        reason: 'expected ≥6 generated token mirrors, found ${mirrors.length}');
    for (final f in mirrors) {
      expect(f.readAsStringSync(), contains('DO NOT EDIT'),
          reason: '${f.path} lost its generated header — was it hand-edited?');
    }
  });
}
