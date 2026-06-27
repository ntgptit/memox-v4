import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:memox_v4/app/router/route_paths.dart';
import 'package:memox_v4/core/theme/mx_spacing.dart';
import 'package:memox_v4/domain/models/app_settings.dart';
import 'package:memox_v4/domain/types/result.dart';
import 'package:memox_v4/l10n/generated/app_localizations.dart';
import 'package:memox_v4/presentation/features/settings/viewmodels/settings_notifier.dart';

/// Settings (`17-settings.md`): game, SRS, daily goal, reminder, backup. Theme
/// and language-display live in W13; cloud sync in W10. No Premium lock (D-012).
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  SettingsNotifier _notifier(WidgetRef ref) =>
      ref.read(settingsNotifierProvider.notifier);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final settings = ref.watch(settingsNotifierProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.drawerSettings)),
      body: settings.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(child: Text(l10n.searchHint)),
        data: (data) => _body(context, ref, l10n, data),
      ),
    );
  }

  Widget _body(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    AppSettings settings,
  ) => ListView(
    key: const Key('settings'),
    padding: const EdgeInsets.symmetric(vertical: MxSpacing.space2),
    children: <Widget>[
      _GroupHeader(l10n.settingsGroupGame),
      _StepperRow(
        label: l10n.settingsWordsPerRound,
        value: settings.gameWordsPerRound,
        min: 3,
        max: 12,
        keyPrefix: 'wordsPerRound',
        onChanged: _notifier(ref).setGameWordsPerRound,
      ),
      SwitchListTile(
        title: Text(l10n.settingsGameRandom),
        value: settings.gameRandom,
        onChanged: _notifier(ref).setGameRandom,
      ),
      _GroupHeader(l10n.settingsGroupSrs),
      ListTile(
        title: Text(l10n.settingsBoxCount),
        trailing: Text('${settings.leitnerBoxCount}'),
      ),
      _StepperRow(
        label: l10n.settingsNewPerDay,
        value: settings.newCardsPerDay,
        min: 5,
        max: 50,
        step: 5,
        keyPrefix: 'newPerDay',
        onChanged: _notifier(ref).setNewCardsPerDay,
      ),
      _GroupHeader(l10n.settingsGroupGoal),
      _StepperRow(
        label: l10n.settingsGoalMinutes,
        value: settings.dailyGoalMinutes ?? 0,
        min: 0,
        max: 120,
        step: 5,
        keyPrefix: 'goalMinutes',
        emptyLabel: l10n.settingsNotSet,
        onChanged: (v) => _notifier(ref).setDailyGoalMinutes(v == 0 ? null : v),
      ),
      _StepperRow(
        label: l10n.settingsGoalWords,
        value: settings.dailyGoalWords ?? 0,
        min: 0,
        max: 200,
        step: 5,
        keyPrefix: 'goalWords',
        emptyLabel: l10n.settingsNotSet,
        onChanged: (v) => _notifier(ref).setDailyGoalWords(v == 0 ? null : v),
      ),
      _GroupHeader(l10n.settingsGroupReminder),
      ListTile(
        key: const Key('settingsReminderRow'),
        title: Text(l10n.settingsGroupReminder),
        subtitle: Text(
          settings.reminder.enabled
              ? settings.reminder.timeText
              : l10n.settingsReminderSummaryOff,
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.push(RoutePaths.reminder),
      ),
      _GroupHeader(l10n.settingsGroupBackup),
      SwitchListTile(
        title: Text(l10n.settingsAutoBackup),
        value: settings.autoBackup,
        onChanged: _notifier(ref).setAutoBackup,
      ),
      Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: MxSpacing.space4,
          vertical: MxSpacing.space2,
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: FilledButton.tonal(
                key: const Key('settingsBackupNow'),
                onPressed: () => _backup(context, ref, l10n),
                child: Text(l10n.settingsBackupNow),
              ),
            ),
            const SizedBox(width: MxSpacing.space3),
            Expanded(
              child: OutlinedButton(
                onPressed: () => _restore(context, ref, l10n),
                child: Text(l10n.settingsRestore),
              ),
            ),
          ],
        ),
      ),
      ListTile(
        key: const Key('settingsThemeRow'),
        title: Text(l10n.drawerTheme),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.push(RoutePaths.theme),
      ),
    ],
  );

  Future<void> _backup(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) async {
    final result = await _notifier(ref).backupNow();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            result is Ok<String>
                ? l10n.settingsBackupDone
                : l10n.settingsBackupError,
          ),
        ),
      );
  }

  Future<void> _restore(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) async {
    final result = await _notifier(ref).restoreNow();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            result is Ok<void>
                ? l10n.settingsRestoreDone
                : l10n.settingsBackupError,
          ),
        ),
      );
  }
}

class _GroupHeader extends StatelessWidget {
  const _GroupHeader(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        MxSpacing.space4,
        MxSpacing.space4,
        MxSpacing.space4,
        MxSpacing.space1,
      ),
      child: Text(
        title,
        style: theme.textTheme.labelLarge?.copyWith(
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }
}

class _StepperRow extends StatelessWidget {
  const _StepperRow({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.keyPrefix,
    required this.onChanged,
    this.step = 1,
    this.emptyLabel,
  });

  final String label;
  final int value;
  final int min;
  final int max;
  final int step;
  final String keyPrefix;
  final String? emptyLabel;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final display = (value == 0 && emptyLabel != null) ? emptyLabel! : '$value';
    return ListTile(
      title: Text(label),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          IconButton(
            key: Key('${keyPrefix}Dec'),
            icon: const Icon(Icons.remove_circle_outline),
            onPressed: value > min ? () => onChanged(value - step) : null,
          ),
          Text(display),
          IconButton(
            key: Key('${keyPrefix}Inc'),
            icon: const Icon(Icons.add_circle_outline),
            onPressed: value < max ? () => onChanged(value + step) : null,
          ),
        ],
      ),
    );
  }
}
