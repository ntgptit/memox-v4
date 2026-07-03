import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:memox_v4/core/theme/app_theme.dart';
import 'package:memox_v4/core/theme/mx_colors.dart';
import 'package:memox_v4/core/theme/mx_radius.dart';
import 'package:memox_v4/presentation/shared/composites/mx_sheet.dart';

Future<void> _pump(WidgetTester tester, Widget sheet, {bool dark = false}) {
  return tester.pumpWidget(
    MaterialApp(
      theme: dark ? AppTheme.dark : AppTheme.light,
      home: Scaffold(body: sheet),
    ),
  );
}

BoxDecoration _surfaceDecoration(WidgetTester tester) {
  final container = tester.widget<Container>(
    find.descendant(of: find.byType(MxSheet), matching: find.byType(Container)).first,
  );
  return container.decoration! as BoxDecoration;
}

void main() {
  testWidgets('renders a surface with the drag handle + content', (tester) async {
    await _pump(tester, const MxSheet(child: Text('Sheet body')));
    expect(find.text('Sheet body'), findsOneWidget);

    final deco = _surfaceDecoration(tester);
    expect(deco.color, MxColors.light.surface);
    expect(
      deco.borderRadius,
      const BorderRadius.vertical(top: Radius.circular(MxRadius.xxl)),
    );
    expect(deco.boxShadow, isNotNull);
  });

  testWidgets('optional title renders uppercased', (tester) async {
    await _pump(tester, const MxSheet(title: 'Sort by', child: Text('body')));
    expect(find.text('SORT BY'), findsOneWidget);
  });

  testWidgets('no title node when title is null', (tester) async {
    await _pump(tester, const MxSheet(child: Text('body')));
    expect(find.text('body'), findsOneWidget);
    expect(find.byType(Text), findsOneWidget); // just the body
  });

  testWidgets('dark uses dark tokens', (tester) async {
    await _pump(tester, const MxSheet(child: Text('body')), dark: true);
    expect(_surfaceDecoration(tester).color, MxColors.dark.surface);
  });

  testWidgets('showMxSheet presents the sheet content modally', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => showMxSheet<void>(
                context: context,
                title: 'Options',
                child: const Text('Sheet content'),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.byType(MxSheet), findsOneWidget);
    expect(find.text('Sheet content'), findsOneWidget);
    expect(find.text('OPTIONS'), findsOneWidget);
  });
}
