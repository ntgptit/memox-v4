import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox_v4/core/theme/app_theme.dart';
import 'package:memox_v4/presentation/shared/widgets/surfaces/mx_app_bar.dart';
import 'package:memox_v4/presentation/shared/widgets/surfaces/mx_card.dart';
import 'package:memox_v4/presentation/shared/widgets/surfaces/mx_icon_tile.dart';
import 'package:memox_v4/presentation/shared/widgets/surfaces/mx_scaffold.dart';
import 'package:memox_v4/presentation/shared/widgets/surfaces/mx_section_header.dart';

Widget _wrap(Widget child) => MaterialApp(theme: AppTheme.light(), home: child);

void main() {
  testWidgets('MxCard renders its child for every variant', (tester) async {
    for (final v in MxCardVariant.values) {
      await tester.pumpWidget(
        _wrap(
          Scaffold(
            body: MxCard(variant: v, child: Text('card-${v.name}')),
          ),
        ),
      );
      expect(find.text('card-${v.name}'), findsOneWidget);
    }
  });

  testWidgets('MxScaffold lays out body + appBar + fab', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const MxScaffold(
          appBar: MxAppBar(title: 'Title', eyebrow: 'Eyebrow'),
          fab: FloatingActionButton(onPressed: null),
          body: Text('body'),
        ),
      ),
    );
    expect(find.text('body'), findsOneWidget);
    expect(find.text('Title'), findsOneWidget);
    expect(find.text('Eyebrow'), findsOneWidget);
  });

  testWidgets('MxSectionHeader shows title + action', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      _wrap(
        Scaffold(
          body: MxSectionHeader(
            title: 'Recent',
            caption: 'last 7 days',
            action: 'See all',
            onAction: () => tapped = true,
          ),
        ),
      ),
    );
    expect(find.text('Recent'), findsOneWidget);
    expect(find.text('last 7 days'), findsOneWidget);
    await tester.tap(find.text('See all'));
    expect(tapped, isTrue);
  });

  testWidgets('MxIconTile renders its icon for each tone', (tester) async {
    for (final tone in MxIconTileTone.values) {
      await tester.pumpWidget(
        _wrap(
          Scaffold(
            body: MxIconTile(icon: Icons.star, tone: tone, solid: true),
          ),
        ),
      );
      expect(find.byIcon(Icons.star), findsOneWidget);
    }
  });
}
