import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox_v4/core/theme/mx_spacing.dart';
import 'package:memox_v4/core/theme/mx_typography.dart';
import 'package:memox_v4/l10n/app_localizations.dart';
import 'package:memox_v4/presentation/features/reminder/providers/reminder_providers.dart';
import 'package:memox_v4/presentation/features/reminder/widgets/time_col.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_button.dart';

/// Reminder-local time picker (kit `reminder/picker-sheet`) — the content of an
/// [showMxSheet]. Two [TimeCol]s (hours + quarter-hour minutes) bound to
/// [reminderTimeDraftProvider]; Done applies the draft via [onDone]. Copy is from
/// ARB.
class TimePickerSheet extends ConsumerWidget {
  const TimePickerSheet({required this.onDone, super.key});

  final void Function(int hour, int minute) onDone;

  static const int _hoursInDay = 24;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final draft = ref.watch(reminderTimeDraftProvider);
    final notifier = ref.read(reminderTimeDraftProvider.notifier);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: TimeCol(
                values: List.generate(_hoursInDay, (i) => i),
                selected: draft.hour,
                semanticLabel: l10n.reminderHoursLabel,
                onSelect: notifier.setHour,
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: MxSpacing.space3),
              child: Text(
                ':',
                style: TextStyle(
                  fontFamily: MxTypography.fontFamily,
                  fontSize: MxTypography.sizeXl,
                  fontWeight: MxTypography.extrabold,
                ),
              ),
            ),
            Expanded(
              child: TimeCol(
                values: reminderMinuteSteps,
                selected: draft.minute,
                semanticLabel: l10n.reminderMinutesLabel,
                onSelect: notifier.setMinute,
              ),
            ),
          ],
        ),
        const SizedBox(height: MxSpacing.space4),
        MxButton(
          label: l10n.reminderPickerDone,
          block: true,
          onPressed: () {
            Navigator.of(context).pop();
            onDone(draft.hour, draft.minute);
          },
        ),
      ],
    );
  }
}
