import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:memox_v4/core/theme/app_theme.dart';
import 'package:memox_v4/core/theme/mx_colors.dart';
import 'package:memox_v4/core/theme/mx_spacing.dart';
import 'package:memox_v4/presentation/shared/composites/mx_scaffold.dart';

Future<void> _pump(WidgetTester tester, Widget scaffold, {bool dark = false}) {
  return tester.pumpWidget(
    MaterialApp(theme: dark ? AppTheme.dark : AppTheme.light, home: scaffold),
  );
}

SingleChildScrollView _body(WidgetTester tester) =>
    tester.widget<SingleChildScrollView>(find.byType(SingleChildScrollView));

void main() {
  testWidgets('lays out the body sections in a gapped scroll column', (tester) async {
    await _pump(tester, const MxScaffold(children: [Text('a'), Text('b')]));
    expect(find.text('a'), findsOneWidget);
    expect(find.text('b'), findsOneWidget);

    final column = tester.widget<Column>(
      find.descendant(of: find.byType(SingleChildScrollView), matching: find.byType(Column)),
    );
    expect(column.spacing, MxSpacing.space5);
  });

  testWidgets('applies the gutter horizontally by default; flush drops it', (tester) async {
    await _pump(tester, const MxScaffold(children: [Text('a')]));
    expect((_body(tester).padding! as EdgeInsets).left, MxSpacing.gutter);

    await _pump(tester, const MxScaffold(flush: true, children: [Text('a')]));
    expect((_body(tester).padding! as EdgeInsets).left, 0);
  });

  testWidgets('body has the top + bottom padding', (tester) async {
    await _pump(tester, const MxScaffold(children: [Text('a')]));
    final padding = _body(tester).padding! as EdgeInsets;
    expect(padding.top, MxSpacing.space4);
    expect(padding.bottom, MxSpacing.space6);
  });

  testWidgets('wires the app bar, bottom nav, and FAB slots', (tester) async {
    await _pump(
      tester,
      MxScaffold(
        appBar: AppBar(title: const Text('Title')),
        bottomNav: const Text('nav'),
        fab: FloatingActionButton(onPressed: () {}, child: const Icon(Icons.add)),
        children: const [Text('body')],
      ),
    );
    expect(find.widgetWithText(AppBar, 'Title'), findsOneWidget);
    expect(find.text('nav'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });

  testWidgets('background comes from the bg token', (tester) async {
    await _pump(tester, const MxScaffold(children: [Text('a')]));
    final ctx = tester.element(find.byType(Scaffold));
    expect(Theme.of(ctx).scaffoldBackgroundColor, MxColors.light.bg);
  });
}
