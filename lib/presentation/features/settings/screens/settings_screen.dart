import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:memox_v4/core/routes/app_routes.dart';
import 'package:memox_v4/core/theme/mx_sizes.dart';
import 'package:memox_v4/core/theme/mx_spacing.dart';
import 'package:memox_v4/core/theme/mx_theme.dart';
import 'package:memox_v4/core/theme/mx_typography.dart';
import 'package:memox_v4/l10n/app_localizations.dart';
import 'package:memox_v4/presentation/features/settings/providers/settings_providers.dart';
import 'package:memox_v4/presentation/features/settings/widgets/value_picker_sheet.dart';
import 'package:memox_v4/presentation/shared/composites/mx_app_bar.dart';
import 'package:memox_v4/presentation/shared/composites/mx_card.dart';
import 'package:memox_v4/presentation/shared/composites/mx_empty_state.dart';
import 'package:memox_v4/presentation/shared/composites/mx_icon_tile.dart';
import 'package:memox_v4/presentation/shared/composites/mx_list_row.dart';
import 'package:memox_v4/presentation/shared/composites/mx_profile_card.dart';
import 'package:memox_v4/presentation/shared/composites/mx_scaffold.dart';
import 'package:memox_v4/presentation/shared/composites/mx_sheet.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_button.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_skeleton.dart';

/// The Settings hub (S.05): a local-identity card + grouped setting rows. Reads
/// DM.8 service state through [settingsControllerProvider] and renders it with
/// `AsyncValue.when`. Fixed-schedule SRS (8 boxes, D-002) is informational; the
/// game words-per-round (D-008) opens a picker sheet; the SRS row drills into the
/// [SrsSettingsScreen] detail sub-page (kit `group-expanded`); reminders / theme /
/// backup navigate to their screens. State lives in the provider; no `setState`.
/// Copy is from ARB.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final appBar = MxAppBar(large: true, title: l10n.settingsTitle);
    final async = ref.watch(settingsControllerProvider);

    return async.when(
      loading: () => MxScaffold(appBar: appBar, children: _loadingBody()),
      error: (_, _) => MxScaffold(
        appBar: appBar,
        children: [
          SizedBox(
            height: MxSizes.size4xl,
            child: _ErrorBody(
              onRetry: () => ref.invalidate(settingsControllerProvider),
            ),
          ),
        ],
      ),
      data: (data) => _loaded(context, ref, appBar, data),
    );
  }

  Widget _loaded(
    BuildContext context,
    WidgetRef ref,
    MxAppBar appBar,
    SettingsData data,
  ) {
    final l10n = AppLocalizations.of(context);

    return MxScaffold(
      appBar: appBar,
      children: [
        const MxProfileCard(),
        _Label(l10n.settingsSectionStudying),
        MxCard(
          padding: MxCardPadding.small,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              MxListRow(
                icon: Icons.translate,
                title: l10n.settingsLanguage,
                subtitle: data.languageLabel ?? l10n.settingsLanguageNotSet,
              ),
              MxListRow(
                icon: Icons.schedule,
                title: l10n.settingsSpacedRepetition,
                subtitle: l10n.settingsSpacedRepetitionSub,
                trailing: const _Chevron(),
                onPressed: () => context.push(Routes.settingsSrs),
              ),
              MxListRow(
                icon: Icons.sports_esports,
                title: l10n.settingsGameSettings,
                subtitle: l10n.settingsGameSettingsSub(data.gameWordsPerRound),
                trailing: const _Chevron(),
                last: true,
                onPressed: () => _openWordsPicker(context, ref, data),
              ),
            ],
          ),
        ),
        _Label(l10n.settingsSectionApp),
        MxCard(
          padding: MxCardPadding.small,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              MxListRow(
                icon: Icons.notifications,
                title: l10n.settingsReminders,
                subtitle: l10n.settingsRemindersSub,
                trailing: const _Chevron(),
                onPressed: () => context.push(Routes.reminder),
              ),
              MxListRow(
                icon: Icons.palette,
                title: l10n.settingsTheme,
                subtitle: l10n.settingsThemeSub,
                trailing: const _Chevron(),
                onPressed: () => context.push(Routes.theme),
              ),
              MxListRow(
                icon: Icons.backup,
                title: l10n.settingsBackup,
                subtitle: l10n.settingsBackupSub,
                trailing: const _Chevron(),
                last: true,
                onPressed: () => context.push(Routes.export_),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _openWordsPicker(BuildContext context, WidgetRef ref, SettingsData data) {
    final l10n = AppLocalizations.of(context);
    showMxSheet<void>(
      context: context,
      title: l10n.settingsWordsPerRoundTitle,
      child: ValuePickerSheet(
        current: data.gameWordsPerRound,
        onSelect: (count) => ref
            .read(settingsControllerProvider.notifier)
            .setGameWordsPerRound(count),
      ),
    );
  }

  List<Widget> _loadingBody() {
    return [
      const MxCard(child: MxSkeleton(height: 48)),
      for (var i = 0; i < 2; i++)
        const MxCard(
          padding: MxCardPadding.small,
          child: Column(
            children: [
              MxSkeleton(height: 20),
              SizedBox(height: MxSpacing.space3),
              MxSkeleton(height: 20),
            ],
          ),
        ),
    ];
  }
}

/// A small uppercase section label (kit `SectionLabel`).
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

/// The trailing navigation chevron on a tappable setting row.
class _Chevron extends StatelessWidget {
  const _Chevron();

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.chevron_right,
      color: MxTheme.of(context).textTertiary,
    );
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return MxEmptyState(
      icon: Icons.error_outline,
      tone: MxIconTileTone.error,
      title: l10n.settingsErrorTitle,
      text: l10n.settingsErrorText,
      action: MxButton(
        label: l10n.actionRetry,
        icon: Icons.refresh,
        onPressed: onRetry,
      ),
    );
  }
}
