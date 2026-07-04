import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:memox_v4/core/theme/app_theme.dart';
import 'package:memox_v4/l10n/app_localizations.dart';
import 'package:memox_v4/presentation/shared/composites/mx_status_card_row.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_badge.dart';

Future<void> _pump(WidgetTester tester, Widget row) {
  return tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: Center(child: row)),
    ),
  );
}

void main() {
  testWidgets('renders term + meaning + status badge from ARB', (tester) async {
    await _pump(tester, const MxStatusCardRow(term: '안녕', meaning: 'Hello', status: MxCardStatus.due));
    expect(find.text('안녕'), findsOneWidget);
    expect(find.text('Hello'), findsOneWidget);
    expect(find.text('Due'), findsOneWidget); // ARB label
  });

  group('status → badge label + tone', () {
    testWidgets('new = neutral, due = error, mastered = success', (tester) async {
      for (final (status, label, tone) in [
        (MxCardStatus.newCard, 'New', MxBadgeTone.neutral),
        (MxCardStatus.due, 'Due', MxBadgeTone.error),
        (MxCardStatus.mastered, 'Mastered', MxBadgeTone.success),
      ]) {
        await _pump(tester, MxStatusCardRow(term: 't', meaning: 'm', status: status));
        expect(find.text(label), findsOneWidget);
        final badge = tester.widget<MxBadge>(find.byType(MxBadge));
        expect(badge.tone, tone);
        expect(badge.soft, isTrue);
      }
    });
  });

  testWidgets('deck line shows only when provided', (tester) async {
    await _pump(tester, const MxStatusCardRow(term: 't', meaning: 'm', status: MxCardStatus.due, deck: 'TOPIK I'));
    expect(find.text('TOPIK I'), findsOneWidget);

    await _pump(tester, const MxStatusCardRow(term: 't', meaning: 'm', status: MxCardStatus.due));
    expect(find.text('TOPIK I'), findsNothing);
  });

  group('hidden', () {
    testWidgets('dims the row to 50% and shows the hidden glyph', (tester) async {
      await _pump(tester, const MxStatusCardRow(term: 't', meaning: 'm', status: MxCardStatus.newCard, hidden: true));
      expect(find.byIcon(Icons.visibility_off), findsOneWidget);
      expect(
        find.byWidgetPredicate((w) => w is Opacity && w.opacity == 0.5),
        findsOneWidget,
      );
    });

    testWidgets('no glyph + full opacity when not hidden', (tester) async {
      await _pump(tester, const MxStatusCardRow(term: 't', meaning: 'm', status: MxCardStatus.newCard));
      expect(find.byIcon(Icons.visibility_off), findsNothing);
    });
  });

  testWidgets('tappable row exposes button semantics + fires', (tester) async {
    var taps = 0;
    await _pump(tester, MxStatusCardRow(term: 't', meaning: 'm', status: MxCardStatus.due, onPressed: () => taps++));
    expect(
      find.byWidgetPredicate((w) => w is Semantics && w.properties.button == true),
      findsWidgets,
    );
    await tester.tap(find.byType(InkWell));
    expect(taps, 1);
  });
}
