import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:memox_v4/core/theme/app_theme.dart';
import 'package:memox_v4/core/theme/mx_colors.dart';
import 'package:memox_v4/presentation/shared/composites/mx_icon_tile.dart';
import 'package:memox_v4/presentation/shared/composites/mx_list_row.dart';

Future<void> _pump(WidgetTester tester, Widget row, {bool dark = false}) {
  return tester.pumpWidget(
    MaterialApp(
      theme: dark ? AppTheme.dark : AppTheme.light,
      home: Scaffold(body: Center(child: SizedBox(width: 300, child: row))),
    ),
  );
}

Finder _borderedContainer() => find.byWidgetPredicate(
      (w) => w is Container && w.decoration is BoxDecoration && (w.decoration! as BoxDecoration).border != null,
    );

void main() {
  testWidgets('renders title, optional icon tile, subtitle, and trailing', (tester) async {
    await _pump(
      tester,
      const MxListRow(
        title: 'Korean',
        icon: Icons.folder,
        subtitle: '42 cards',
        trailing: Icon(Icons.chevron_right),
      ),
    );
    expect(find.text('Korean'), findsOneWidget);
    expect(find.text('42 cards'), findsOneWidget);
    expect(find.byType(MxIconTile), findsOneWidget);
    expect(find.byIcon(Icons.chevron_right), findsOneWidget);
  });

  testWidgets('title = text colour, subtitle = textSecondary', (tester) async {
    await _pump(tester, const MxListRow(title: 'T', subtitle: 'S'));
    expect(tester.widget<Text>(find.text('T')).style!.color, MxColors.light.text);
    expect(tester.widget<Text>(find.text('S')).style!.color, MxColors.light.textSecondary);
  });

  group('divider', () {
    testWidgets('shows a bottom divider by default; last drops it', (tester) async {
      await _pump(tester, const MxListRow(title: 'T'));
      final deco = tester.widget<Container>(_borderedContainer()).decoration! as BoxDecoration;
      expect((deco.border! as Border).bottom.color, MxColors.light.divider);

      await _pump(tester, const MxListRow(title: 'T', last: true));
      expect(_borderedContainer(), findsNothing);
    });
  });

  testWidgets('muted dims the row to 0.55', (tester) async {
    await _pump(tester, const MxListRow(title: 'T', muted: true));
    expect(
      find.byWidgetPredicate((w) => w is Opacity && w.opacity == 0.55),
      findsOneWidget,
    );
  });

  testWidgets('tappable row exposes button semantics + fires', (tester) async {
    var taps = 0;
    await _pump(tester, MxListRow(title: 'T', onPressed: () => taps++));
    expect(
      find.byWidgetPredicate((w) => w is Semantics && w.properties.button == true && w.properties.label == 'T'),
      findsOneWidget,
    );
    await tester.tap(find.byType(InkWell));
    expect(taps, 1);
  });

  testWidgets('dark uses dark tokens', (tester) async {
    await _pump(tester, const MxListRow(title: 'T', subtitle: 'S'), dark: true);
    expect(tester.widget<Text>(find.text('S')).style!.color, MxColors.dark.textSecondary);
  });
}
