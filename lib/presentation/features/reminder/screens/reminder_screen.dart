import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:memox_v4/core/theme/mx_spacing.dart';
import 'package:memox_v4/core/theme/mx_theme.dart';
import 'package:memox_v4/core/theme/mx_typography.dart';
import 'package:memox_v4/domain/entities/reminder.dart';
import 'package:memox_v4/l10n/app_localizations.dart';
import 'package:memox_v4/presentation/features/reminder/providers/reminder_providers.dart';
import 'package:memox_v4/presentation/features/reminder/widgets/time_picker_sheet.dart';
import 'package:memox_v4/presentation/shared/composites/mx_app_bar.dart';
import 'package:memox_v4/presentation/shared/composites/mx_card.dart';
import 'package:memox_v4/presentation/shared/composites/mx_icon_tile.dart';
import 'package:memox_v4/presentation/shared/composites/mx_list_row.dart';
import 'package:memox_v4/presentation/shared/composites/mx_scaffold.dart';
import 'package:memox_v4/presentation/shared/composites/mx_sheet.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_chip.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_icon_button.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_switch.dart';

/// Weekdays in display order (Mon..Sun), `DateTime.weekday` numbering.
const List<int> _weekdayOrder = [1, 2, 3, 4, 5, 6, 7];

/// Opacity applied to the time + repeat controls when reminders are off.
const double _disabledOpacity = 0.5;

/// The Reminders screen (S.07): a master toggle, the reminder time, and the
/// weekday repeat chips. Reads/mutates the reminder config through
/// [reminderControllerProvider] (DM.8 `ReminderNotificationService`, BR-4). The
/// config is session state (no store in v1); no `setState`. Copy is from ARB.
class ReminderScreen extends ConsumerWidget {
  const ReminderScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final reminder = ref.watch(reminderControllerProvider);
    final controller = ref.read(reminderControllerProvider.notifier);
    final on = reminder.isEnabled;

    return MxScaffold(
      appBar: MxAppBar(
        title: l10n.reminderTitle,
        leading: MxIconButton(
          icon: Icons.arrow_back,
          semanticLabel: l10n.reminderBack,
          onPressed: () => context.pop(),
        ),
      ),
      children: [
        MxCard(
          padding: MxCardPadding.small,
          child: MxListRow(
            icon: Icons.notifications,
            tone: MxIconTileTone.warning,
            title: l10n.reminderToggleTitle,
            subtitle: l10n.reminderToggleSub,
            last: true,
            trailing: MxSwitch(
              value: on,
              semanticLabel: l10n.reminderToggleTitle,
              onChanged: controller.setEnabled,
            ),
          ),
        ),
        Opacity(
          opacity: on ? 1 : _disabledOpacity,
          child: MxCard(
            onPressed: on ? () => _openTimePicker(context, ref, reminder) : null,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _Label(l10n.reminderTimeLabel),
                      const SizedBox(height: MxSpacing.space1),
                      Text(
                        _formatTime(reminder),
                        style: TextStyle(
                          fontFamily: MxTypography.fontFamily,
                          fontSize: MxTypography.size3xl,
                          fontWeight: MxTypography.extrabold,
                          letterSpacing:
                              MxTypography.size3xl * MxTypography.trackingTight,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
                MxIconButton(
                  icon: Icons.schedule,
                  semanticLabel: l10n.reminderEditTime,
                  onPressed: on ? () => _openTimePicker(context, ref, reminder) : null,
                ),
              ],
            ),
          ),
        ),
        Opacity(
          opacity: on ? 1 : _disabledOpacity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _Label(l10n.reminderRepeatLabel),
              const SizedBox(height: MxSpacing.space2),
              Wrap(
                spacing: MxSpacing.space2,
                runSpacing: MxSpacing.space2,
                children: [
                  for (final day in _weekdayOrder)
                    MxChip(
                      label: _dayName(l10n, day),
                      selected: reminder.weekdays.contains(day),
                      onPressed: on ? () => controller.toggleWeekday(day) : null,
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _openTimePicker(BuildContext context, WidgetRef ref, Reminder reminder) {
    ref
        .read(reminderTimeDraftProvider.notifier)
        .reset(reminder.hour, reminder.minute);
    final l10n = AppLocalizations.of(context);
    showMxSheet<void>(
      context: context,
      title: l10n.reminderPickerTitle,
      child: TimePickerSheet(
        onDone: (hour, minute) =>
            ref.read(reminderControllerProvider.notifier).setTime(hour, minute),
      ),
    );
  }

  String _formatTime(Reminder reminder) {
    final h = reminder.hour.toString().padLeft(2, '0');
    final m = reminder.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  String _dayName(AppLocalizations l10n, int weekday) {
    return switch (weekday) {
      1 => l10n.reminderDayMon,
      2 => l10n.reminderDayTue,
      3 => l10n.reminderDayWed,
      4 => l10n.reminderDayThu,
      5 => l10n.reminderDayFri,
      6 => l10n.reminderDaySat,
      _ => l10n.reminderDaySun,
    };
  }
}

/// A small uppercase section label (kit `SectionLabel`).
class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final mx = MxTheme.of(context);
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        fontFamily: MxTypography.fontFamily,
        fontSize: MxTypography.sizeSm,
        fontWeight: MxTypography.bold,
        letterSpacing: MxTypography.sizeSm * MxTypography.trackingWide,
        color: mx.textTertiary,
      ),
    );
  }
}
