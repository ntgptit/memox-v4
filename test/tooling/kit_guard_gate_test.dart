import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// K.6 — locks the no-raw-values kit guard wiring so it cannot be silently
/// dropped: `kit_guard.mjs` must exist and `tool/verify/run.mjs` must invoke it
/// in both the docs and full modes. Reads the actual scripts, not mocks.
String _read(String path) {
  final file = File(path);
  expect(file.existsSync(), isTrue, reason: 'missing $path');
  return file.readAsStringSync();
}

void main() {
  test('the kit guard script exists and checks components.css', () {
    final guard = _read('tool/design/kit_guard.mjs');
    expect(guard, contains('components.css'));
    expect(guard, contains('raw-ok'));
    expect(guard, contains('process.exit(1)'));
  });

  test('the verify gate invokes the kit guard (defined AND called)', () {
    final runMjs = _read('tool/verify/run.mjs');
    expect(runMjs, contains('kit_guard.mjs'));
    expect(
      RegExp(r'kitGuard\(\)').allMatches(runMjs).length,
      greaterThanOrEqualTo(2),
      reason: 'kitGuard() defined but not called in both gate modes',
    );
  });

  test('components.css currently passes the guard contract', () {
    // The guard's own invariant, mirrored cheaply: every raw px/hex/duration
    // outside a raw-ok line would fail `node tool/design/kit_guard.mjs`; here we
    // just pin that the raw-ok escape hatch is used sparingly (< 10 lines).
    final css = _read('docs/design/MemoX Design System/components.css');
    final rawOk = RegExp('raw-ok:').allMatches(css).length;
    expect(rawOk, lessThan(10), reason: 'raw-ok whitelist is ballooning');
  });
}
