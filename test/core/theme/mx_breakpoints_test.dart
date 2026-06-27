import 'package:flutter_test/flutter_test.dart';
import 'package:memox_v4/core/theme/mx_breakpoints.dart';

void main() {
  group('MxScreenSize.fromWidth', () {
    test('classifies each band at its boundaries', () {
      expect(MxScreenSize.fromWidth(0), MxScreenSize.compact);
      expect(MxScreenSize.fromWidth(599), MxScreenSize.compact);
      expect(MxScreenSize.fromWidth(600), MxScreenSize.medium);
      expect(MxScreenSize.fromWidth(839), MxScreenSize.medium);
      expect(MxScreenSize.fromWidth(840), MxScreenSize.expanded);
      expect(MxScreenSize.fromWidth(1199), MxScreenSize.expanded);
      expect(MxScreenSize.fromWidth(1200), MxScreenSize.large);
      expect(MxScreenSize.fromWidth(2000), MxScreenSize.large);
    });

    test('atLeast orders the size classes', () {
      expect(MxScreenSize.expanded.atLeast(MxScreenSize.medium), isTrue);
      expect(MxScreenSize.compact.atLeast(MxScreenSize.medium), isFalse);
      expect(MxScreenSize.large.atLeast(MxScreenSize.large), isTrue);
    });
  });

  group('MxBreakpoints tokens', () {
    test('gutter grows with the screen', () {
      expect(MxBreakpoints.gutterOf(MxScreenSize.compact), 20);
      expect(MxBreakpoints.gutterOf(MxScreenSize.large), 40);
      expect(
        MxBreakpoints.gutterOf(MxScreenSize.expanded),
        greaterThan(MxBreakpoints.gutterOf(MxScreenSize.compact)),
      );
    });

    test('content width is unbounded on compact, capped on larger screens', () {
      expect(
        MxBreakpoints.maxContentWidth(MxScreenSize.compact),
        double.infinity,
      );
      expect(MxBreakpoints.maxContentWidth(MxScreenSize.large), 1040);
    });
  });
}
