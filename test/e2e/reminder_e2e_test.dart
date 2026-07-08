// E2E — reminder (S.07). Tag `e2e`. Map SC-REMINDER-* (docs/scenarios/reminder.md).
// Config là SESSION STATE (v1 không lưu DB) — assert hành vi UI: toggle / weekday chips /
// enable. isEnabled = có ít nhất 1 weekday. Điều hướng: push '/reminder'.
@Tags(['e2e'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:memox_v4/presentation/features/dashboard/screens/dashboard_screen.dart';
import 'package:memox_v4/presentation/features/reminder/screens/reminder_screen.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_chip.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_switch.dart';

import 'support/e2e_harness.dart';

Future<void> openReminder(WidgetTester tester) async {
  GoRouter.of(tester.element(find.byType(DashboardScreen))).push('/reminder');
  await settle(tester);
  expect(find.byType(ReminderScreen), findsOneWidget);
}

void main() {
  // SC-REMINDER · render — toggle (off mặc định) + REPEAT + 7 chip ngày
  testWidgets('renders toggle off by default with 7 weekday chips',
      (tester) async {
    await pumpApp(tester, seed: (h) => h.seedPair());
    await openReminder(tester);

    expect(find.text('Study reminders'), findsOneWidget);
    expect(find.text('REPEAT'), findsOneWidget); // MxSectionLabel uppercased
    expect(find.byType(MxChip), findsNWidgets(7)); // Mon..Sun
    expect(find.text('Mon'), findsOneWidget);
    expect(tester.widget<MxSwitch>(find.byType(MxSwitch)).value, isFalse);
  });

  // SC-REMINDER · off ⇒ time + weekday chips bị VÔ HIỆU (onPressed null)
  // (Bật reminder cần quyền notification nền — KHÔNG drive được trong flutter_test;
  // ghi làm gap, test nhánh drivable là trạng thái off.)
  testWidgets('when off, weekday chips are disabled', (tester) async {
    await pumpApp(tester, seed: (h) => h.seedPair());
    await openReminder(tester);

    expect(
      tester.widgetList<MxChip>(find.byType(MxChip)).every((c) => c.onPressed == null),
      isTrue,
    );
  });
}
