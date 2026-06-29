import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox_v4/core/theme/mx_spacing.dart';
import 'package:memox_v4/core/theme/theme_prefs.dart';
import 'package:memox_v4/l10n/generated/app_localizations.dart';
import 'package:memox_v4/presentation/features/personalization/viewmodels/personalization_notifier.dart';
import 'package:memox_v4/presentation/shared/widgets/buttons/mx_button.dart';
import 'package:memox_v4/presentation/shared/widgets/display/mx_chip.dart';
import 'package:memox_v4/presentation/shared/widgets/display/mx_text.dart';
import 'package:memox_v4/presentation/shared/widgets/inputs/mx_segmented_control.dart';
import 'package:memox_v4/presentation/shared/widgets/surfaces/mx_app_bar.dart';
import 'package:memox_v4/presentation/shared/widgets/surfaces/mx_card.dart';
import 'package:memox_v4/presentation/shared/widgets/surfaces/mx_scaffold.dart';

/// Theme personalization (`20-theme.md`): mode, accent and font size with a live
/// preview. Changes apply app-wide immediately (BR-3) and persist.
class ThemeScreen extends ConsumerWidget {
  const ThemeScreen({super.key});

  PersonalizationNotifier _notifier(WidgetRef ref) =>
      ref.read(personalizationProvider.notifier);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final prefs =
        ref.watch(personalizationProvider).value ?? const ThemePrefs();
    return MxScaffold(
      key: const ValueKey('mx-node:theme/screen'),
      appBar: MxAppBar(
        key: const ValueKey('mx-node:theme/appbar'),
        title: l10n.drawerTheme,
      ),
      body: ListView(
        key: const Key('theme'),
        padding: const EdgeInsets.symmetric(vertical: MxSpacing.space4),
        children: <Widget>[
          MxText.title(
            l10n.themeModeLabel,
            key: const ValueKey('mx-node:theme/mode-head'),
          ),
          const SizedBox(height: MxSpacing.space2),
          MxSegmentedControl(
            segments: <MxSegment>[
              (
                value: ThemeMode.system.name,
                label: l10n.themeModeSystem,
                icon: null,
              ),
              (
                value: ThemeMode.light.name,
                label: l10n.themeModeLight,
                icon: null,
              ),
              (
                value: ThemeMode.dark.name,
                label: l10n.themeModeDark,
                icon: null,
              ),
            ],
            value: prefs.mode.name,
            onChanged: (v) =>
                _notifier(ref).setMode(ThemeMode.values.byName(v)),
          ),
          const SizedBox(height: MxSpacing.space5),
          MxText.title(
            l10n.themeAccentLabel,
            key: const ValueKey('mx-node:theme/accent-head'),
          ),
          const SizedBox(height: MxSpacing.space2),
          Wrap(
            spacing: MxSpacing.space2,
            runSpacing: MxSpacing.space2,
            children: <Widget>[
              _accentChip(
                ref,
                l10n.themeAccentBrand,
                AccentChoice.brand,
                prefs,
              ),
              _accentChip(ref, l10n.themeAccentWarm, AccentChoice.warm, prefs),
              _accentChip(ref, l10n.themeAccentCool, AccentChoice.cool, prefs),
            ],
          ),
          const SizedBox(height: MxSpacing.space5),
          MxText.title(
            l10n.themeFontLabel,
            key: const ValueKey('mx-node:theme/size-head'),
          ),
          const SizedBox(height: MxSpacing.space2),
          MxSegmentedControl(
            segments: <MxSegment>[
              (
                value: FontScale.small.name,
                label: l10n.themeFontSmall,
                icon: null,
              ),
              (
                value: FontScale.medium.name,
                label: l10n.themeFontMedium,
                icon: null,
              ),
              (
                value: FontScale.large.name,
                label: l10n.themeFontLarge,
                icon: null,
              ),
            ],
            value: prefs.fontScale.name,
            onChanged: (v) =>
                _notifier(ref).setFontScale(FontScale.values.byName(v)),
          ),
          const SizedBox(height: MxSpacing.space6),
          _Preview(
            key: const ValueKey('mx-node:theme/preview'),
            title: l10n.themePreview,
            body: l10n.themePreviewBody,
          ),
        ],
      ),
    );
  }

  Widget _accentChip(
    WidgetRef ref,
    String label,
    AccentChoice accent,
    ThemePrefs prefs,
  ) => MxChip(
    key: Key('accent-${accent.name}'),
    label: label,
    selected: prefs.accent == accent,
    onTap: () => _notifier(ref).setAccent(accent),
  );
}

class _Preview extends StatelessWidget {
  const _Preview({super.key, required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) => MxCard(
    variant: MxCardVariant.flat,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        MxText.title(title),
        const SizedBox(height: MxSpacing.space2),
        MxText.body(body),
        const SizedBox(height: MxSpacing.space3),
        Row(
          children: <Widget>[
            MxButton(label: title, size: MxButtonSize.sm, onPressed: () {}),
            const SizedBox(width: MxSpacing.space3),
            Icon(
              Icons.local_fire_department,
              color: Theme.of(context).colorScheme.primary,
            ),
          ],
        ),
      ],
    ),
  );
}
