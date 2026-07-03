import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:memox_v4/core/theme/mx_spacing.dart';
import 'package:memox_v4/domain/entities/theme_settings.dart';
import 'package:memox_v4/l10n/app_localizations.dart';
import 'package:memox_v4/presentation/features/theme/providers/theme_providers.dart';
import 'package:memox_v4/presentation/features/theme/widgets/accent_picker.dart';
import 'package:memox_v4/presentation/features/theme/widgets/preview_card.dart';
import 'package:memox_v4/presentation/shared/composites/mx_app_bar.dart';
import 'package:memox_v4/presentation/shared/composites/mx_card.dart';
import 'package:memox_v4/presentation/shared/composites/mx_scaffold.dart';
import 'package:memox_v4/presentation/shared/composites/mx_section_header.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_icon_button.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_segmented_control.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_skeleton.dart';

/// The Theme screen (S.08): a live preview + colour mode, accent, and text-size
/// controls. Reads/saves appearance preferences through [themeControllerProvider]
/// (DM.8 `SettingsService`, BR-1..3). Colour mode applies live app-wide (via
/// `themeModeProvider`); accent + size are persisted + previewed. No `setState`.
/// Copy is from ARB.
class ThemeScreen extends ConsumerWidget {
  const ThemeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final appBar = MxAppBar(
      title: l10n.themeTitle,
      leading: MxIconButton(
        icon: Icons.arrow_back,
        semanticLabel: l10n.themeBack,
        onPressed: () => context.pop(),
      ),
    );
    final async = ref.watch(themeControllerProvider);

    return async.when(
      loading: () => MxScaffold(
        appBar: appBar,
        children: const [MxCard(child: MxSkeleton(height: 140))],
      ),
      error: (_, _) => MxScaffold(
        appBar: appBar,
        children: const [MxCard(child: MxSkeleton(height: 140))],
      ),
      data: (settings) => _content(context, ref, appBar, settings),
    );
  }

  Widget _content(
    BuildContext context,
    WidgetRef ref,
    MxAppBar appBar,
    ThemeSettings settings,
  ) {
    final l10n = AppLocalizations.of(context);
    final controller = ref.read(themeControllerProvider.notifier);

    return MxScaffold(
      appBar: appBar,
      children: [
        PreviewCard(accent: settings.accent, fontScale: settings.fontScale),
        MxSectionHeader(title: l10n.themeColorMode),
        MxSegmentedControl(
          block: true,
          value: settings.mode.name,
          segments: [
            MxSegment(value: ColorMode.light.name, label: l10n.themeModeLight),
            MxSegment(value: ColorMode.dark.name, label: l10n.themeModeDark),
            MxSegment(value: ColorMode.system.name, label: l10n.themeModeSystem),
          ],
          onChanged: (value) => controller.setMode(ColorMode.values.byName(value)),
        ),
        const SizedBox(height: MxSpacing.space2),
        MxSectionHeader(title: l10n.themeAccent),
        AccentPicker(
          selected: settings.accent,
          onSelect: controller.setAccent,
        ),
        const SizedBox(height: MxSpacing.space2),
        MxSectionHeader(title: l10n.themeTextSize),
        MxSegmentedControl(
          block: true,
          value: settings.fontScale.name,
          segments: [
            MxSegment(value: FontScale.small.name, label: l10n.themeSizeSmall),
            MxSegment(value: FontScale.medium.name, label: l10n.themeSizeMedium),
            MxSegment(value: FontScale.large.name, label: l10n.themeSizeLarge),
          ],
          onChanged: (value) =>
              controller.setFontScale(FontScale.values.byName(value)),
        ),
      ],
    );
  }
}
