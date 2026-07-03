import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox_v4/core/theme/mx_colors.dart';

/// V.5 — WCAG AA contrast for the semantic token pairs, in both themes. Token
/// math (not a widget golden) so it is deterministic and platform-independent.
///
/// Two AA tiers (WCAG 2.1 §1.4.3 / §1.4.11):
/// - **4.5:1** for normal body/secondary text and soft-banner text;
/// - **3.0:1** for **large / bold** text and UI components — the `on*` labels on a
///   solid accent are always bold ≥14pt button/chip labels, so 3:1 is the
///   applicable threshold there.
const double _aaNormal = 4.5;
const double _aaLargeOrUi = 3.0;

double _linear(double channel) => channel <= 0.03928
    ? channel / 12.92
    : math.pow((channel + 0.055) / 1.055, 2.4).toDouble();

double _luminance(Color c) =>
    0.2126 * _linear(c.r) + 0.7152 * _linear(c.g) + 0.0722 * _linear(c.b);

double contrastRatio(Color a, Color b) {
  final la = _luminance(a);
  final lb = _luminance(b);
  final lighter = math.max(la, lb);
  final darker = math.min(la, lb);
  return (lighter + 0.05) / (darker + 0.05);
}

void main() {
  for (final (name, c) in [
    ('light', MxColors.light),
    ('dark', MxColors.dark),
  ]) {
    group('$name theme', () {
      // Normal text (AA 4.5:1): body + secondary + soft-banner copy.
      final normalTextPairs = <String, (Color, Color)>{
        'text on bg': (c.text, c.bg),
        'text on surface': (c.text, c.surface),
        'textSecondary on surface': (c.textSecondary, c.surface),
        'onPrimarySoft on primarySoft': (c.onPrimarySoft, c.primarySoft),
        'onSuccessSoft on successSoft': (c.onSuccessSoft, c.successSoft),
        'onWarningSoft on warningSoft': (c.onWarningSoft, c.warningSoft),
        'onErrorSoft on errorSoft': (c.onErrorSoft, c.errorSoft),
      };
      normalTextPairs.forEach((label, pair) {
        test('$label meets AA normal (4.5:1)', () {
          expect(contrastRatio(pair.$1, pair.$2),
              greaterThanOrEqualTo(_aaNormal),
              reason: label);
        });
      });

      // Bold labels on a solid accent (AA large / UI: 3:1).
      final accentLabelPairs = <String, (Color, Color)>{
        'onPrimary on primary': (c.onPrimary, c.primary),
        'onSuccess on success': (c.onSuccess, c.success),
        'onWarning on warning': (c.onWarning, c.warning),
        'onError on error': (c.onError, c.error),
      };
      accentLabelPairs.forEach((label, pair) {
        test('$label meets AA large/UI (3:1)', () {
          expect(contrastRatio(pair.$1, pair.$2),
              greaterThanOrEqualTo(_aaLargeOrUi),
              reason: label);
        });
      });
    });
  }
}
