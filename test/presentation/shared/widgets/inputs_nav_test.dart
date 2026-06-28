import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox_v4/core/theme/app_theme.dart';
import 'package:memox_v4/presentation/shared/widgets/buttons/mx_icon_button.dart';
import 'package:memox_v4/presentation/shared/widgets/inputs/mx_search_field.dart';
import 'package:memox_v4/presentation/shared/widgets/inputs/mx_text_field.dart';
import 'package:memox_v4/presentation/shared/widgets/navigation/mx_bottom_nav.dart';
import 'package:memox_v4/presentation/shared/widgets/navigation/mx_fab.dart';

Widget _wrap(Widget child) => MaterialApp(
  theme: AppTheme.light(),
  home: Scaffold(body: child),
);

void main() {
  testWidgets('MxTextField shows label + reports changes', (tester) async {
    String? typed;
    await tester.pumpWidget(
      _wrap(MxTextField(label: 'Term', onChanged: (v) => typed = v)),
    );
    expect(find.text('Term'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'xin');
    expect(typed, 'xin');
  });

  testWidgets('MxSearchField shows placeholder + reports query', (
    tester,
  ) async {
    String? q;
    await tester.pumpWidget(
      _wrap(
        MxSearchField(
          placeholder: 'Search',
          onChanged: (v) => q = v,
          trailing: const Icon(Icons.tune),
        ),
      ),
    );
    expect(find.text('Search'), findsOneWidget);
    expect(find.byIcon(Icons.tune), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'ab');
    expect(q, 'ab');
  });

  testWidgets('MxIconButton fires for each variant', (tester) async {
    for (final v in MxIconButtonVariant.values) {
      var taps = 0;
      await tester.pumpWidget(
        _wrap(
          MxIconButton(icon: Icons.add, variant: v, onPressed: () => taps++),
        ),
      );
      await tester.tap(find.byIcon(Icons.add));
      expect(taps, 1);
    }
  });

  testWidgets('MxFab round + extended render and fire', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          floatingActionButton: MxFab(
            icon: Icons.add,
            label: 'Add',
            onPressed: () => taps++,
          ),
          body: const SizedBox(),
        ),
      ),
    );
    expect(find.text('Add'), findsOneWidget);
    // The extended FAB hugs its content — it must not stretch to fill the
    // bounded constraints the Scaffold gives its FAB slot.
    expect(tester.getSize(find.byType(MxFab)).width, lessThan(300));
    await tester.tap(find.byIcon(Icons.add));
    expect(taps, 1);
  });

  testWidgets('MxBottomNav selects a destination', (tester) async {
    String? picked;
    await tester.pumpWidget(
      _wrap(
        MxBottomNav(
          items: const <MxBottomNavItem>[
            (id: 'home', label: 'Home', icon: Icons.home),
            (id: 'stats', label: 'Stats', icon: Icons.bar_chart),
          ],
          value: 'home',
          onChanged: (id) => picked = id,
        ),
      ),
    );
    expect(find.text('Stats'), findsOneWidget);
    await tester.tap(find.text('Stats'));
    expect(picked, 'stats');
  });
}
