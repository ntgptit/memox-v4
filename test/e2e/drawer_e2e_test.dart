// E2E — drawer + language-pair manager (S.06). Tag `e2e`. Map SC-DRAWER-*.
// 3 sub-view (menu / add-language / remove-language). Add/Remove GHI language_pairs (D-030).
// TODAY'S ACTIVITY đọc daily_activity. Điều hướng: push '/drawer'.
@Tags(['e2e'])
library;

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:memox_v4/data/datasources/local/app_database.dart';
import 'package:memox_v4/presentation/features/dashboard/screens/dashboard_screen.dart';
import 'package:memox_v4/presentation/features/drawer/screens/drawer_screen.dart';
import 'package:memox_v4/presentation/features/drawer/widgets/drawer_item.dart';
import 'package:memox_v4/presentation/features/drawer/widgets/lang_card.dart';

import 'support/e2e_harness.dart';

final int _today = DateTime.utc(2026, 7, 3).microsecondsSinceEpoch;

Future<void> openDrawer(WidgetTester tester) async {
  GoRouter.of(tester.element(find.byType(DashboardScreen))).push('/drawer');
  await settle(tester);
  expect(find.byType(DrawerScreen), findsOneWidget);
}

void main() {
  // SC-DRAWER · menu — 8 mục + TODAY'S ACTIVITY (đọc daily_activity)
  testWidgets('menu renders 8 items and today activity', (tester) async {
    await pumpApp(tester, seed: (h) async {
      await h.seedPair();
      await h.db.into(h.db.dailyActivity).insert(DailyActivityCompanion.insert(
            day: Value(_today),
            minutes: const Value(90),
            words: const Value(12),
          ));
    });
    await openDrawer(tester);

    expect(find.byType(DrawerItem), findsNWidgets(8));
    expect(find.text('Add language'), findsOneWidget);
    expect(find.text('01:30'), findsOneWidget); // 90 phút = 01:30
    expect(find.text('12 words'), findsOneWidget);
  });

  // SC-DRAWER · thêm cặp ngôn ngữ → GHI language_pairs (D-030)
  testWidgets('add language pair writes to language_pairs', (tester) async {
    final h = await pumpApp(tester); // DB rỗng
    await openDrawer(tester);

    await tester.tap(find.text('Add language')); // → add-language view
    await settle(tester);
    await tester.tap(find.byType(LangCard).first); // learning picker
    await settle(tester);
    await tester.tap(find.text('한국어'));
    await settle(tester);
    await tester.tap(find.byType(LangCard).last); // native picker
    await settle(tester);
    await tester.tap(find.text('Tiếng Việt'));
    await settle(tester);
    await tester.tap(find.text('Add language pair'));
    await settle(tester);

    final pair = (await h.db.select(h.db.languagePairs).get()).single;
    expect(pair.learningLanguage, '한국어');
    expect(pair.nativeLanguage, 'Tiếng Việt');
  });

  // SC-DRAWER · xoá cặp ngôn ngữ → language_pairs rỗng (D-030)
  testWidgets('remove language pair deletes it from language_pairs',
      (tester) async {
    final h = await pumpApp(tester, seed: (h) =>
        h.seedPair(id: 'lp', learning: 'ko', native: 'vi'));
    await openDrawer(tester);

    await tester.tap(find.text('Remove language')); // → remove view
    await settle(tester);
    await tester.tap(find.byIcon(Icons.delete)); // xoá cặp
    await settle(tester);
    await tester.tap(find.text('Remove')); // confirm dialog
    await settle(tester);

    expect(await h.db.select(h.db.languagePairs).get(), isEmpty);
  });
}
