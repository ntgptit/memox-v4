import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox_v4/core/theme/app_theme.dart';
import 'package:memox_v4/presentation/shared/widgets/buttons/mx_button.dart';
import 'package:memox_v4/presentation/shared/widgets/display/mx_avatar.dart';
import 'package:memox_v4/presentation/shared/widgets/display/mx_badge.dart';
import 'package:memox_v4/presentation/shared/widgets/display/mx_chip.dart';
import 'package:memox_v4/presentation/shared/widgets/inputs/mx_segmented_control.dart';
import 'package:memox_v4/presentation/shared/widgets/inputs/mx_switch.dart';

Widget _wrap(Widget child) => MaterialApp(
  theme: AppTheme.light(),
  home: Scaffold(body: Center(child: child)),
);

void main() {
  testWidgets('MxButton renders every variant and fires onPressed', (
    tester,
  ) async {
    for (final v in MxButtonVariant.values) {
      var taps = 0;
      await tester.pumpWidget(
        _wrap(
          MxButton(
            label: 'Go-${v.name}',
            variant: v,
            icon: Icons.bolt,
            onPressed: () => taps++,
          ),
        ),
      );
      expect(find.text('Go-${v.name}'), findsOneWidget);
      await tester.tap(find.text('Go-${v.name}'));
      expect(taps, 1);
    }
  });

  testWidgets('MxButton with null onPressed is inert', (tester) async {
    await tester.pumpWidget(
      _wrap(const MxButton(label: 'Off', onPressed: null)),
    );
    expect(find.text('Off'), findsOneWidget);
  });

  testWidgets('MxSwitch toggles', (tester) async {
    bool? next;
    await tester.pumpWidget(
      _wrap(MxSwitch(value: false, onChanged: (v) => next = v)),
    );
    await tester.tap(find.byType(MxSwitch));
    expect(next, isTrue);
  });

  testWidgets('MxSegmentedControl selects on tap', (tester) async {
    String? picked;
    await tester.pumpWidget(
      _wrap(
        MxSegmentedControl(
          segments: const <MxSegment>[
            (value: 'a', label: 'A', icon: null),
            (value: 'b', label: 'B', icon: Icons.star),
          ],
          value: 'a',
          onChanged: (v) => picked = v,
        ),
      ),
    );
    await tester.tap(find.text('B'));
    expect(picked, 'b');
  });

  testWidgets('MxChip shows its label', (tester) async {
    await tester.pumpWidget(
      _wrap(const MxChip(label: 'Due', icon: Icons.schedule, selected: true)),
    );
    expect(find.text('Due'), findsOneWidget);
  });

  testWidgets('MxBadge shows label + dot', (tester) async {
    await tester.pumpWidget(
      _wrap(const MxBadge(label: '5', tone: MxBadgeTone.warning, soft: true)),
    );
    expect(find.text('5'), findsOneWidget);
    await tester.pumpWidget(_wrap(const MxBadge(dot: true)));
    expect(find.byType(MxBadge), findsOneWidget);
  });

  testWidgets('MxAvatar shows initials from a name', (tester) async {
    await tester.pumpWidget(_wrap(const MxAvatar(name: 'Nguyen Tan')));
    expect(find.text('NT'), findsOneWidget);
  });
}
