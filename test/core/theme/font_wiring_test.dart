import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:memox_v4/core/theme/mx_typography.dart';

/// T.2 wiring check: the variable font is present on disk and registered in
/// pubspec under [MxTypography.fontFamily] for every weight the type scale uses,
/// so `FontWeight.w400…w800` resolve to real glyphs.
///
/// Golden proof that the weights render *distinctly* is deferred to T.5 (which
/// stands up the golden harness + font loading).
void main() {
  test('the Plus Jakarta Sans variable font asset is present', () {
    expect(File('assets/fonts/PlusJakartaSans.ttf').existsSync(), isTrue);
  });

  test('pubspec registers the font family with weights 400–800', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    expect(pubspec, contains('family: ${MxTypography.fontFamily}'));
    expect(pubspec, contains('assets/fonts/PlusJakartaSans.ttf'));
    for (final weight in const [400, 500, 600, 700, 800]) {
      expect(pubspec, contains('weight: $weight'),
          reason: 'pubspec is missing font weight $weight');
    }
  });
}
