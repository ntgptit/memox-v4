import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox_v4/core/theme/mx_breakpoints.dart';
import 'package:memox_v4/presentation/shared/layouts/responsive.dart';

Widget _sized(Size size, Widget child) => MediaQuery(
  data: MediaQueryData(size: size),
  child: Directionality(textDirection: TextDirection.ltr, child: child),
);

void main() {
  testWidgets('context.mxScreenSize + responsive() read the window width', (
    tester,
  ) async {
    late MxScreenSize size;
    late double gutter;
    late String pick;

    await tester.pumpWidget(
      _sized(
        const Size(900, 800),
        Builder(
          builder: (context) {
            size = context.mxScreenSize;
            gutter = context.screenGutter;
            pick = context.responsive(compact: 'c', expanded: 'e');
            return const SizedBox();
          },
        ),
      ),
    );

    expect(size, MxScreenSize.expanded);
    expect(gutter, MxBreakpoints.gutterOf(MxScreenSize.expanded));
    expect(pick, 'e');
  });

  testWidgets('MxResponsiveBuilder classifies from local constraints', (
    tester,
  ) async {
    late MxScreenSize seen;

    await tester.pumpWidget(
      _sized(
        const Size(1400, 900),
        Center(
          child: SizedBox(
            width: 360, // narrow panel inside a wide window
            child: MxResponsiveBuilder(
              builder: (context, size) {
                seen = size;
                return const SizedBox();
              },
            ),
          ),
        ),
      ),
    );

    expect(seen, MxScreenSize.compact);
  });

  testWidgets('MxContentBounds caps content width on large screens', (
    tester,
  ) async {
    await tester.pumpWidget(
      _sized(
        const Size(1600, 900),
        MxContentBounds(child: Container(key: const Key('content'))),
      ),
    );

    final box = tester.getSize(find.byKey(const Key('content')));
    // large cap (1040) minus the two gutters (40 each).
    expect(box.width, lessThanOrEqualTo(1040));
    expect(box.width, lessThan(1600));
  });
}
