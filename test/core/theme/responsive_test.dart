import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:memox_v4/core/theme/mx_spacing.dart';
import 'package:memox_v4/core/theme/responsive.dart';

void main() {
  group('FormFactor.fromWidth', () {
    test('classifies at the breakpoint boundaries', () {
      expect(FormFactor.fromWidth(0), FormFactor.compact);
      expect(FormFactor.fromWidth(Breakpoints.compactMax - 1), FormFactor.compact);
      expect(FormFactor.fromWidth(Breakpoints.compactMax), FormFactor.medium);
      expect(FormFactor.fromWidth(Breakpoints.mediumMax - 1), FormFactor.medium);
      expect(FormFactor.fromWidth(Breakpoints.mediumMax), FormFactor.expanded);
      expect(FormFactor.fromWidth(1400), FormFactor.expanded);
    });
  });

  group('Responsive.gutterFor', () {
    test('is phone-first and widens with the form factor', () {
      expect(Responsive.gutterFor(FormFactor.compact), MxSpacing.gutter);
      expect(Responsive.gutterFor(FormFactor.medium), MxSpacing.space7);
      expect(Responsive.gutterFor(FormFactor.expanded), MxSpacing.space8);
    });
  });

  group('ResponsiveContext extension', () {
    Future<FormFactor> factorAt(WidgetTester tester, Size size) async {
      late FormFactor factor;
      late double gutter;
      await tester.pumpWidget(
        MediaQuery(
          data: MediaQueryData(size: size),
          child: Builder(
            builder: (context) {
              factor = context.formFactor;
              gutter = context.gutter;
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      expect(gutter, Responsive.gutterFor(factor));
      return factor;
    }

    testWidgets('reads the form factor from the ambient window width', (
      tester,
    ) async {
      expect(await factorAt(tester, const Size(390, 844)), FormFactor.compact);
      expect(await factorAt(tester, const Size(720, 1024)), FormFactor.medium);
      expect(await factorAt(tester, const Size(1200, 900)), FormFactor.expanded);
    });
  });
}
