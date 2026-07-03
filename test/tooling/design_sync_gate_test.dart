import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// V.7 — locks the design-sync → regenerate → **drift-gate** wiring so the token
/// parity gate cannot be silently dropped. Reads the actual gate script + CI
/// workflow + generator (not a mock), so removing the gate from any of them turns
/// this test red. See `docs/design/design-sync-workflow.md`.
String _read(String path) {
  final file = File(path);
  expect(file.existsSync(), isTrue, reason: 'missing $path');
  return file.readAsStringSync();
}

void main() {
  test('the verify gate script invokes the token drift gate', () {
    final runMjs = _read('tool/verify/run.mjs');
    // The `tokens()` step must call the generator in --check (drift) mode.
    expect(runMjs, contains('gen_tokens.mjs'));
    expect(runMjs, contains("'--check'"));
    // …and it must actually be invoked in the full run (not just defined).
    expect(RegExp(r'tokens\(\)').allMatches(runMjs).length,
        greaterThanOrEqualTo(2),
        reason: 'tokens() defined but not called in the gate');
  });

  test('CI runs the single verify gate (which carries the drift gate)', () {
    final ci = _read('.github/workflows/verify.yml');
    expect(ci, contains('tool/verify/run.mjs'));
  });

  test('the token generator + its committed Dart mirrors exist', () {
    // The generated-but-committed token layer the drift gate compares against.
    expect(File('tool/design/gen_tokens.mjs').existsSync(), isTrue);
    final theme = Directory('lib/core/theme');
    final mirrors = theme
        .listSync()
        .whereType<File>()
        .where((f) => f.path.split(RegExp(r'[\\/]')).last.startsWith('mx_'))
        .toList();
    expect(mirrors, isNotEmpty, reason: 'no mx_*.dart token mirrors found');
  });

  test('the design-sync workflow doc + operational notes are present', () {
    expect(File('docs/design/design-sync-workflow.md').existsSync(), isTrue);
    expect(File('.design-sync/NOTES.md').existsSync(), isTrue);
  });
}
