import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:memox_v4/core/theme/app_theme.dart';
import 'package:memox_v4/l10n/app_localizations.dart';
import 'package:memox_v4/domain/entities/theme_settings.dart';
import 'package:memox_v4/presentation/features/theme/widgets/accent_picker.dart';
import 'package:memox_v4/presentation/shared/composites/mx_fab.dart';
import 'package:memox_v4/presentation/shared/composites/mx_section_header.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_button.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_chip.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_choice_option.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_icon_button.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_segmented_control.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_switch.dart';

/// V.5 — tap-target size (≥ 48, `MxSpacing.minTouchTarget`) and icon-only-control
/// labels for the interactive primitives, via Flutter's built-in a11y guidelines
/// (they measure the real semantics/hit rects, so a small visual with a padded
/// hit area still passes).
Future<void> _pump(WidgetTester tester, List<Widget> children) async {
  tester.view.physicalSize = const Size(420, 1200);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: Column(mainAxisAlignment: MainAxisAlignment.center, children: children),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  void noop() {}

  testWidgets('interactive primitives meet the ≥48 tap-target guideline',
      (tester) async {
    final handle = tester.ensureSemantics();
    await _pump(tester, [
      MxButton(label: 'Save', onPressed: noop),
      MxButton(label: 'Small', size: MxButtonSize.small, onPressed: noop),
      MxIconButton(icon: Icons.close, semanticLabel: 'Close', onPressed: noop),
      MxIconButton(
        icon: Icons.edit,
        semanticLabel: 'Edit',
        size: MxIconButtonSize.small,
        onPressed: noop,
      ),
      MxFab(icon: Icons.add, semanticLabel: 'Add', onPressed: noop),
      MxChoiceOption(text: 'Option', onPressed: noop),
    ]);

    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
    handle.dispose();
  });

  testWidgets(
      'sub-48 visuals still meet the guideline via expanded hit areas (M3-1)',
      (tester) async {
    // Audit G2: these controls draw smaller than 48px — the tap surface must
    // still measure ≥48 (kit ::after overlays / Flutter padded tap boxes).
    final handle = tester.ensureSemantics();
    await _pump(tester, [
      MxChip(label: 'Filter', onPressed: noop),
      MxSwitch(value: true, onChanged: (_) {}, semanticLabel: 'Reminders'),
      MxSegmentedControl(
        segments: const [
          MxSegment(value: 'a', label: 'Week'),
          MxSegment(value: 'b', label: 'Month'),
        ],
        value: 'a',
        onChanged: (_) {},
      ),
      MxSectionHeader(title: 'Decks', actionLabel: 'See all', onAction: noop),
      AccentPicker(selected: AccentColor.brand, onSelect: (_) {}),
    ]);

    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
    handle.dispose();
  });

  testWidgets('icon-only controls expose a label (not the icon name)',
      (tester) async {
    final handle = tester.ensureSemantics();
    await _pump(tester, [
      MxIconButton(icon: Icons.arrow_back, semanticLabel: 'Back', onPressed: noop),
      MxIconButton(icon: Icons.volume_up, semanticLabel: 'Play audio', onPressed: noop),
      MxFab(icon: Icons.add, semanticLabel: 'Add card', onPressed: noop),
    ]);

    // Every icon-only tappable carries a label (the guideline fails if any is
    // unlabeled) …
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    // … and that label is the ARB copy (surfaced as the a11y tooltip), never the
    // Material icon ligature.
    expect(find.byTooltip('Back'), findsOneWidget);
    expect(find.byTooltip('Play audio'), findsOneWidget);
    expect(find.bySemanticsLabel('arrow_back'), findsNothing);
    expect(find.bySemanticsLabel('volume_up'), findsNothing);
    handle.dispose();
  });
}
