import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:memox_v4/core/theme/app_theme.dart';
import 'package:memox_v4/l10n/app_localizations.dart';
import 'package:memox_v4/presentation/shared/composites/action_callout.dart';
import 'package:memox_v4/presentation/shared/composites/mx_card.dart';
import 'package:memox_v4/presentation/shared/composites/mx_empty_state.dart';
import 'package:memox_v4/presentation/shared/composites/mx_fab.dart';
import 'package:memox_v4/presentation/shared/composites/mx_icon_tile.dart';
import 'package:memox_v4/presentation/shared/composites/mx_list_row.dart';
import 'package:memox_v4/presentation/shared/composites/mx_search_dock.dart';
import 'package:memox_v4/presentation/shared/composites/mx_stat_ring.dart';
import 'package:memox_v4/presentation/shared/composites/status_card_row.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_avatar.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_badge.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_button.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_chip.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_choice_option.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_icon_button.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_progress_bar.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_segmented_control.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_switch.dart';
import 'package:memox_v4/presentation/shared/screens/component_gallery.dart';

/// The component-gallery gate. Pixel goldens for the whole set are cross-platform
/// sensitive (text/shadows differ dev↔CI) and are owned by the V.1 golden suite,
/// which runs on the canonical platform. Here the lock is that the gallery — every
/// shared widget in its variants — renders in BOTH themes with no exception, and
/// that each component type is present. If a component breaks (throws, loses a
/// token, changes name), this gate goes red before any feature screen consumes it.
Future<void> _pumpGallery(WidgetTester tester, {required bool dark}) async {
  tester.view.physicalSize = const Size(430, 6000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MaterialApp(
      theme: dark ? AppTheme.dark : AppTheme.light,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const ComponentGallery(),
    ),
  );
  await tester.pump();
}

void main() {
  for (final dark in [false, true]) {
    final theme = dark ? 'dark' : 'light';

    testWidgets('gallery renders every component with no exception ($theme)', (tester) async {
      await _pumpGallery(tester, dark: dark);
      expect(tester.takeException(), isNull);
    });

    testWidgets('gallery includes each shared component type ($theme)', (tester) async {
      await _pumpGallery(tester, dark: dark);
      for (final type in <Type>[
        MxButton,
        MxIconButton,
        MxAvatar,
        MxBadge,
        MxChip,
        MxSwitch,
        MxSegmentedControl,
        MxCard,
        MxIconTile,
        MxFab,
        MxProgressBar,
        MxStatRing,
        MxStatusCardRow,
        MxListRow,
        MxChoiceOption,
        MxActionCallout,
        MxSearchDock,
        MxEmptyState,
      ]) {
        expect(find.byType(type), findsWidgets, reason: '$type missing from gallery');
      }
    });
  }
}
