import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:memox_v4/core/theme/app_theme.dart';
import 'package:memox_v4/core/theme/mx_colors.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_segmented_control.dart';

const _segments = [
  MxSegment(value: 'cards', label: 'Cards'),
  MxSegment(value: 'stats', label: 'Stats', icon: Icons.bar_chart),
];

Future<void> _pump(
  WidgetTester tester, {
  String? value = 'cards',
  ValueChanged<String>? onChanged,
  bool block = false,
  bool dark = false,
}) {
  return tester.pumpWidget(
    MaterialApp(
      theme: dark ? AppTheme.dark : AppTheme.light,
      home: Scaffold(
        body: Center(
          child: MxSegmentedControl(
            segments: _segments,
            value: value,
            onChanged: onChanged,
            block: block,
          ),
        ),
      ),
    ),
  );
}

Material _segmentMaterial(WidgetTester tester, String label) =>
    tester.widget<Material>(find.ancestor(of: find.text(label), matching: find.byType(Material)).first);

Color _labelColor(WidgetTester tester, String label) =>
    tester.widget<Text>(find.text(label)).style!.color!;

void main() {
  testWidgets('renders every segment label', (tester) async {
    await _pump(tester);
    expect(find.text('Cards'), findsOneWidget);
    expect(find.text('Stats'), findsOneWidget);
    expect(find.byIcon(Icons.bar_chart), findsOneWidget);
  });

  group('active vs inactive → tokens (light)', () {
    testWidgets('active = surface pill + primaryStrong; inactive = transparent + textSecondary', (tester) async {
      await _pump(tester, value: 'cards');
      expect(_segmentMaterial(tester, 'Cards').color, MxColors.light.surface);
      expect(_labelColor(tester, 'Cards'), MxColors.light.primaryStrong);
      expect(_segmentMaterial(tester, 'Stats').color, Colors.transparent);
      expect(_labelColor(tester, 'Stats'), MxColors.light.textSecondary);
    });

    testWidgets('dark uses dark tokens', (tester) async {
      await _pump(tester, value: 'cards', dark: true);
      expect(_segmentMaterial(tester, 'Cards').color, MxColors.dark.surface);
    });
  });

  testWidgets('tapping a segment fires onChanged with its value', (tester) async {
    String? picked;
    await _pump(tester, value: 'cards', onChanged: (v) => picked = v);
    await tester.tap(find.text('Stats'));
    expect(picked, 'stats');
  });

  testWidgets('each segment carries radio semantics', (tester) async {
    await _pump(tester, value: 'cards');
    expect(
      find.byWidgetPredicate((w) =>
          w is Semantics &&
          w.properties.inMutuallyExclusiveGroup == true &&
          w.properties.selected == true &&
          w.properties.label == 'Cards'),
      findsOneWidget,
    );
    expect(
      find.byWidgetPredicate((w) =>
          w is Semantics &&
          w.properties.inMutuallyExclusiveGroup == true &&
          w.properties.selected == false &&
          w.properties.label == 'Stats'),
      findsOneWidget,
    );
  });

  testWidgets('block stretches segments to fill width', (tester) async {
    await _pump(tester, block: true);
    expect(find.byType(Expanded), findsNWidgets(2));
  });
}
