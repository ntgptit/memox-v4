import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Z.1 — locks the props-parity gate wiring so the `.d.ts` contract → Flutter
/// constructor check cannot be silently dropped. Reads the actual gate script +
/// CI workflow + checker + config (not a mock), so removing the gate from any of
/// them turns this test red. See `tool/parity/README.md` +
/// `docs/agent/props-parity/WBS.md`.
String _read(String path) {
  final file = File(path);
  expect(file.existsSync(), isTrue, reason: 'missing $path');
  return file.readAsStringSync();
}

void main() {
  test('the verify gate script invokes props_check in --strict (blocking) mode', () {
    final runMjs = _read('tool/verify/run.mjs');
    // The step must call the checker in --strict mode (fails on undeclared drift).
    expect(runMjs, contains('tool/parity/props_check.mjs'));
    expect(runMjs, contains("'--strict'"));
    // …and it must actually be invoked in the full run (not just defined).
    expect(RegExp(r'propsParity\(\)').allMatches(runMjs).length,
        greaterThanOrEqualTo(2),
        reason: 'propsParity() defined but not called in the gate');
  });

  test('CI runs the single verify gate (which carries the props-parity gate)', () {
    final ci = _read('.github/workflows/verify.yml');
    expect(ci, contains('tool/verify/run.mjs'));
  });

  test('the checker + its alias map + the exceptions ledger exist', () {
    expect(File('tool/parity/props_check.mjs').existsSync(), isTrue);
    expect(File('tool/parity/props_map.json').existsSync(), isTrue);
    expect(File('props-parity.exceptions.json').existsSync(), isTrue);
    expect(File('tool/parity/README.md').existsSync(), isTrue);
  });

  test('the checker enforces the closed exception-reason schema', () {
    final checker = _read('tool/parity/props_check.mjs');
    // The reason allow-list + the validator that fails on an unknown reason.
    expect(checker, contains('const REASONS'));
    expect(checker, contains('validateExceptions'));
    expect(checker, contains('enum-base-expansion'));
    expect(checker, contains('fixture-parameterized'));
  });

  test('the exceptions ledger is valid JSON of typed, reasoned entries', () {
    // A minimal structural check independent of the JS checker: every entry has
    // component + prop + reason + note, and reason is in the closed set.
    const reasons = {
      'web-only',
      'enum-base-expansion',
      'flutter-idiom',
      'deferred-screen',
      'flutter-only',
      'fixture-parameterized',
      'flutter-helper',
    };
    final raw = _read('props-parity.exceptions.json');
    final decoded = _decodeJsonArray(raw);
    expect(decoded, isNotEmpty, reason: 'exceptions ledger is empty');
    for (final entry in decoded) {
      expect(entry['component'], isNotNull);
      expect(entry['prop'], isNotNull);
      expect(entry['note'], isNotNull,
          reason: 'exception ${entry['component']}/${entry['prop']} has no note');
      expect(reasons, contains(entry['reason']),
          reason: 'unknown reason "${entry['reason']}" on '
              '${entry['component']}/${entry['prop']}');
    }
  });
}

/// Decode the exceptions file as a `List<Map>` without pulling in dart:convert
/// typing noise. Kept local so the test has no extra imports.
List<Map<String, dynamic>> _decodeJsonArray(String raw) {
  final decoded = jsonDecode(raw);
  expect(decoded, isA<List<dynamic>>());
  return (decoded as List<dynamic>).cast<Map<String, dynamic>>();
}
