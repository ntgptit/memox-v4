import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:memox_v4/app/router/route_paths.dart';
import 'package:memox_v4/core/theme/mx_spacing.dart';
import 'package:memox_v4/core/theme/mx_theme.dart';
import 'package:memox_v4/domain/models/app_settings.dart';
import 'package:memox_v4/domain/types/result.dart';
import 'package:memox_v4/domain/types/sync.dart';
import 'package:memox_v4/l10n/generated/app_localizations.dart';
import 'package:memox_v4/presentation/features/settings/viewmodels/settings_notifier.dart';
import 'package:memox_v4/presentation/shared/widgets/buttons/mx_button.dart';
import 'package:memox_v4/presentation/shared/widgets/buttons/mx_icon_button.dart';
import 'package:memox_v4/presentation/shared/widgets/display/mx_text.dart';
import 'package:memox_v4/presentation/shared/widgets/feedback/mx_snackbar.dart';
import 'package:memox_v4/presentation/shared/widgets/inputs/mx_switch.dart';
import 'package:memox_v4/presentation/shared/widgets/states/mx_state_view.dart';
import 'package:memox_v4/presentation/shared/widgets/surfaces/mx_app_bar.dart';
import 'package:memox_v4/presentation/shared/widgets/surfaces/mx_scaffold.dart';

/// Settings (`17-settings.md`): game, SRS, daily goal, reminder, backup. Theme
/// and language-display live in W13; cloud sync in W10. No Premium lock (D-012).
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  SettingsNotifier _notifier(WidgetRef ref) =>
      ref.read(settingsProvider.notifier);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final settings = ref.watch(settingsProvider);
    return MxScaffold(
      appBar: MxAppBar(title: l10n.drawerSettings),
      flush: true,
      body: settings.when(
        loading: () => const MxStateView.loading(),
        error: (_, _) => const SizedBox.shrink(),
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
      ListTile(
        title: Text(l10n.settingsGameRandom),
        trailing: MxSwitch(
          value: settings.gameRandom,
          onChanged: _notifier(ref).setGameRandom,
        ),
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
      ListTile(
        title: Text(l10n.settingsAutoBackup),
        trailing: MxSwitch(
          value: settings.autoBackup,
          onChanged: _notifier(ref).setAutoBackup,
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: MxSpacing.space4,
          vertical: MxSpacing.space2,
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: MxButton(
                key: const Key('settingsBackupNow'),
                label: l10n.settingsBackupNow,
                variant: MxButtonVariant.secondary,
                block: true,
                onPressed: () => _backup(context, ref, l10n),
              ),
            ),
            const SizedBox(width: MxSpacing.space3),
            Expanded(
              child: MxButton(
                label: l10n.settingsRestore,
                variant: MxButtonVariant.outline,
                block: true,
                onPressed: () => _restore(context, ref, l10n),
              ),
            ),
          ],
        ),
      ),
      ListTile(
        key: const Key('settingsSyncRow'),
        leading: const Icon(Icons.cloud_sync_outlined),
        title: Text(l10n.settingsSyncTitle),
        subtitle: Text(l10n.settingsSyncSubtitle),
        onTap: () => _sync(context, ref, l10n),
      ),
      ListTile(
        key: const Key('settingsThemeRow'),
        title: Text(l10n.drawerTheme),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.push(RoutePaths.theme),
      ),
    ],
  );

  Future<void> _sync(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) async {
    final result = await _notifier(ref).syncNow();
    if (!context.mounted) return;
    final (message, tone) = switch (result) {
      Ok(value: SyncOutcome.pushed) => (
        l10n.settingsSyncPushed,
        MxSnackbarTone.success,
      ),
      Ok(value: SyncOutcome.pulled) => (
        l10n.settingsSyncPulled,
        MxSnackbarTone.success,
      ),
      Ok(value: SyncOutcome.signInRequired) => (
        l10n.settingsSyncSignInRequired,
        MxSnackbarTone.neutral,
      ),
      Err() => (l10n.settingsSyncError, MxSnackbarTone.error),
    };
    MxSnackbar.show(context, message, tone: tone);
  }

  Future<void> _backup(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) async {
    final result = await _notifier(ref).backupNow();
    if (!context.mounted) return;
    final ok = result is Ok<String>;
    MxSnackbar.show(
      context,
      ok ? l10n.settingsBackupDone : l10n.settingsBackupError,
      tone: ok ? MxSnackbarTone.success : MxSnackbarTone.error,
    );
  }

  Future<void> _restore(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) async {
    final result = await _notifier(ref).restoreNow();
    if (!context.mounted) return;
    final ok = result is Ok<void>;
    MxSnackbar.show(
      context,
      ok ? l10n.settingsRestoreDone : l10n.settingsBackupError,
      tone: ok ? MxSnackbarTone.success : MxSnackbarTone.error,
    );
  }
}

class _GroupHeader extends StatelessWidget {
  const _GroupHeader(this.title);

  final String title;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(
      MxSpacing.space4,
      MxSpacing.space4,
      MxSpacing.space4,
      MxSpacing.space1,
    ),
    child: MxText(
      title,
      role: MxTextRole.labelLarge,
      color: MxTheme.of(context).colors.primary,
    ),
  );
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
          MxIconButton(
            key: Key('${keyPrefix}Dec'),
            icon: Icons.remove_circle_outline,
            onPressed: value > min ? () => onChanged(value - step) : null,
          ),
          Text(display),
          MxIconButton(
            key: Key('${keyPrefix}Inc'),
            icon: Icons.add_circle_outline,
            onPressed: value < max ? () => onChanged(value + step) : null,
          ),
        ],
      ),
    );
  }
}
