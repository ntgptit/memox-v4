import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox_v4/core/theme/mx_radius.dart';
import 'package:memox_v4/core/theme/mx_spacing.dart';
import 'package:memox_v4/core/theme/theme_prefs.dart';
import 'package:memox_v4/l10n/generated/app_localizations.dart';
import 'package:memox_v4/presentation/features/personalization/viewmodels/personalization_notifier.dart';

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
    return Scaffold(
      appBar: AppBar(title: Text(l10n.drawerTheme)),
      body: ListView(
        key: const Key('theme'),
        padding: const EdgeInsets.all(MxSpacing.space4),
        children: <Widget>[
          Text(
            l10n.themeModeLabel,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: MxSpacing.space2),
          SegmentedButton<ThemeMode>(
            segments: <ButtonSegment<ThemeMode>>[
              ButtonSegment<ThemeMode>(
                value: ThemeMode.system,
                label: Text(l10n.themeModeSystem),
              ),
              ButtonSegment<ThemeMode>(
                value: ThemeMode.light,
                label: Text(l10n.themeModeLight),
              ),
              ButtonSegment<ThemeMode>(
                value: ThemeMode.dark,
                label: Text(l10n.themeModeDark),
              ),
            ],
            selected: <ThemeMode>{prefs.mode},
            onSelectionChanged: (s) => _notifier(ref).setMode(s.first),
          ),
          const SizedBox(height: MxSpacing.space5),
          Text(
            l10n.themeAccentLabel,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: MxSpacing.space2),
          Wrap(
            spacing: MxSpacing.space2,
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
          Text(
            l10n.themeFontLabel,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: MxSpacing.space2),
          SegmentedButton<FontScale>(
            segments: <ButtonSegment<FontScale>>[
              ButtonSegment<FontScale>(
                value: FontScale.small,
                label: Text(l10n.themeFontSmall),
              ),
              ButtonSegment<FontScale>(
                value: FontScale.medium,
                label: Text(l10n.themeFontMedium),
              ),
              ButtonSegment<FontScale>(
                value: FontScale.large,
                label: Text(l10n.themeFontLarge),
              ),
            ],
            selected: <FontScale>{prefs.fontScale},
            onSelectionChanged: (s) => _notifier(ref).setFontScale(s.first),
          ),
          const SizedBox(height: MxSpacing.space6),
          _Preview(title: l10n.themePreview, body: l10n.themePreviewBody),
        ],
      ),
    );
  }

  Widget _accentChip(
    WidgetRef ref,
    String label,
    AccentChoice accent,
    ThemePrefs prefs,
  ) => ChoiceChip(
    key: Key('accent-${accent.name}'),
    label: Text(label),
    selected: prefs.accent == accent,
    onSelected: (_) => _notifier(ref).setAccent(accent),
  );
}

class _Preview extends StatelessWidget {
  const _Preview({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: MxRadius.cardRadius,
      ),
      child: Padding(
        padding: const EdgeInsets.all(MxSpacing.space4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(title, style: theme.textTheme.titleMedium),
            const SizedBox(height: MxSpacing.space2),
            Text(body, style: theme.textTheme.bodyMedium),
            const SizedBox(height: MxSpacing.space3),
            Row(
              children: <Widget>[
                FilledButton(onPressed: () {}, child: Text(title)),
                const SizedBox(width: MxSpacing.space3),
                Icon(
                  Icons.local_fire_department,
                  color: theme.colorScheme.primary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
