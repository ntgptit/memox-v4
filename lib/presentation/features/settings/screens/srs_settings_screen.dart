import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:memox_v4/core/theme/mx_spacing.dart';
import 'package:memox_v4/core/theme/mx_theme.dart';
import 'package:memox_v4/core/theme/mx_typography.dart';
import 'package:memox_v4/domain/entities/box_level.dart';
import 'package:memox_v4/domain/services/srs_scheduler.dart';
import 'package:memox_v4/l10n/app_localizations.dart';
import 'package:memox_v4/presentation/features/settings/providers/settings_providers.dart';
import 'package:memox_v4/presentation/shared/composites/mx_app_bar.dart';
import 'package:memox_v4/presentation/shared/composites/mx_card.dart';
import 'package:memox_v4/presentation/shared/composites/mx_list_row.dart';
import 'package:memox_v4/presentation/shared/composites/mx_scaffold.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_icon_button.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_skeleton.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_switch.dart';

/// The SRS detail sub-page (kit `settings/group-expanded`) reached from the
/// Settings "Spaced repetition" row. Shows the fixed-schedule facts — the box
/// count ([BoxLevel.max]) and the review intervals ([SrsScheduler.intervalDays]),
/// both **domain constants**, not editable in v1 — plus the one mutable value: a
/// "cards due" notifications opt-in ([SrsSettingsController]). The toggle persists
/// the preference; delivering the notifications is a separate later feature.
class SrsSettingsScreen extends ConsumerWidget {
  const SrsSettingsScreen({super.key});

  /// The review intervals rendered as "1 · 3 · 7 · 14 · 30 · 60 · 120".
  static String _intervalsLabel() => SrsScheduler.intervalDays.join(' · ');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final appBar = MxAppBar(
      title: l10n.srsTitle,
      leading: MxIconButton(
        icon: Icons.arrow_back,
        semanticLabel: l10n.srsBack,
        onPressed: () => context.pop(),
      ),
    );
    final async = ref.watch(srsSettingsControllerProvider);

    return MxScaffold(
      appBar: appBar,
      children: [
        _Label(l10n.srsSectionSchedule),
        MxCard(
          padding: MxCardPadding.small,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              MxListRow(
                icon: Icons.grid_view,
                title: l10n.srsBoxesTitle,
                subtitle: l10n.srsBoxesSub,
                trailing: _Value(l10n.srsBoxesValue(BoxLevel.max)),
              ),
              MxListRow(
                icon: Icons.timeline,
                title: l10n.srsIntervalsTitle,
                subtitle: l10n.srsIntervalsSub(_intervalsLabel()),
                last: true,
              ),
            ],
          ),
        ),
        _Label(l10n.srsSectionNotifications),
        MxCard(
          padding: MxCardPadding.small,
          child: MxListRow(
            icon: Icons.notifications_active,
            title: l10n.srsDueNotificationsTitle,
            subtitle: l10n.srsDueNotificationsSub,
            last: true,
            trailing: MxSwitch(
              value: async.value ?? false,
              semanticLabel: l10n.srsDueNotificationsTitle,
              onChanged: async.isLoading
                  ? null
                  : (enabled) => ref
                      .read(srsSettingsControllerProvider.notifier)
                      .setDueNotifications(enabled: enabled),
            ),
          ),
        ),
        if (async.isLoading) const _LoadingHint(),
      ],
    );
  }
}

/// A small uppercase section label (matches the Settings hub's `_Label`).
class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final mx = MxTheme.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: MxSpacing.space1),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontFamily: MxTypography.fontFamily,
          fontSize: MxTypography.sizeSm,
          fontWeight: MxTypography.bold,
          letterSpacing: MxTypography.sizeSm * MxTypography.trackingWide,
          color: mx.textSecondary,
        ),
      ),
    );
  }
}

/// The trailing read-only value chip on a fixed-schedule row.
class _Value extends StatelessWidget {
  const _Value(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: MxTypography.fontFamily,
        fontSize: MxTypography.sizeBase,
        fontWeight: MxTypography.bold,
        color: MxTheme.of(context).textSecondary,
      ),
    );
  }
}

/// A slim skeleton shown under the toggle while the persisted value loads.
class _LoadingHint extends StatelessWidget {
  const _LoadingHint();

  @override
  Widget build(BuildContext context) {
    return const MxCard(child: MxSkeleton(height: 20));
  }
}
