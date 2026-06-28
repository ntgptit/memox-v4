import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox_v4/core/theme/mx_spacing.dart';
import 'package:memox_v4/domain/types/reminder.dart';
import 'package:memox_v4/l10n/generated/app_localizations.dart';
import 'package:memox_v4/presentation/features/settings/viewmodels/settings_notifier.dart';

/// Reminder schedule (`18-reminder.md`): enable + time + weekdays. Persists and
/// schedules an OS notification per selected weekday (W12).
class ReminderScreen extends ConsumerWidget {
  const ReminderScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final settings = ref.watch(settingsProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsGroupReminder)),
      body: settings.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => const SizedBox.shrink(),
        data: (data) => _body(context, ref, l10n, data.reminder),
      ),
    );
  }

  Widget _body(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    Reminder reminder,
  ) {
    final notifier = ref.read(settingsProvider.notifier);
    return ListView(
      padding: const EdgeInsets.all(MxSpacing.space4),
      children: <Widget>[
        SwitchListTile(
          key: const Key('reminderEnable'),
          title: Text(l10n.reminderEnable),
          value: reminder.enabled,
          onChanged: (value) =>
              _save(l10n, notifier, reminder.copyWith(enabled: value)),
        ),
        ListTile(
          enabled: reminder.enabled,
          title: Text(l10n.reminderTimeLabel),
          trailing: Text(reminder.timeText),
          onTap: reminder.enabled
              ? () => _pickTime(context, l10n, notifier, reminder)
              : null,
        ),
        const SizedBox(height: MxSpacing.space3),
        Wrap(
          spacing: MxSpacing.space2,
          children: <Widget>[
            for (var day = 1; day <= 7; day++)
              FilterChip(
                label: Text(_weekdayLabel(l10n, day)),
                selected: reminder.weekdays.contains(day),
                onSelected: reminder.enabled
                    ? (selected) {
                        final weekdays = <int>{...reminder.weekdays};
                        selected ? weekdays.add(day) : weekdays.remove(day);
                        _save(
                          l10n,
                          notifier,
                          reminder.copyWith(enabled: true, weekdays: weekdays),
                        );
                      }
                    : null,
              ),
          ],
        ),
        if (reminder.enabled) ...<Widget>[
          const SizedBox(height: MxSpacing.space4),
          Text(
            l10n.reminderActiveHint,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }

  void _save(
    AppLocalizations l10n,
    SettingsNotifier notifier,
    Reminder reminder,
  ) {
    unawaited(
      notifier.setReminder(
        reminder,
        notificationTitle: l10n.reminderNotificationTitle,
        notificationBody: l10n.reminderNotificationBody,
      ),
    );
  }

  Future<void> _pickTime(
    BuildContext context,
    AppLocalizations l10n,
    SettingsNotifier notifier,
    Reminder reminder,
  ) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: reminder.hour, minute: reminder.minute),
    );
    if (picked == null) return;
    _save(
      l10n,
      notifier,
      reminder.copyWith(
        enabled: true,
        hour: picked.hour,
        minute: picked.minute,
      ),
    );
  }

  String _weekdayLabel(AppLocalizations l10n, int day) => switch (day) {
    1 => l10n.weekdayMon,
    2 => l10n.weekdayTue,
    3 => l10n.weekdayWed,
    4 => l10n.weekdayThu,
    5 => l10n.weekdayFri,
    6 => l10n.weekdaySat,
    _ => l10n.weekdaySun,
  };
}
