import 'package:flutter/material.dart';
import 'package:memox_v4/core/theme/mx_colors.dart';
import 'package:memox_v4/core/theme/mx_sizes.dart';
import 'package:memox_v4/core/theme/mx_spacing.dart';
import 'package:memox_v4/core/theme/mx_theme.dart';
import 'package:memox_v4/domain/entities/theme_settings.dart';
import 'package:memox_v4/l10n/app_localizations.dart';
import 'package:memox_v4/presentation/shared/composites/mx_card.dart';

/// The domain's three accent presets in display order (the kit's six swatches
/// collapse to these — the persisted model has three, BR-2).
const List<AccentColor> themeAccentOrder = [
  AccentColor.brand,
  AccentColor.warm,
  AccentColor.cool,
];

/// A representative palette token for each accent preset.
Color accentSwatchColor(AccentColor accent) => switch (accent) {
      AccentColor.brand => MxColors.paletteIndigo,
      AccentColor.warm => MxColors.paletteCoral,
      AccentColor.cool => MxColors.paletteCyan,
    };

/// The localized name of an accent preset (for a11y; not shown visually).
String accentLabel(AppLocalizations l10n, AccentColor accent) => switch (accent) {
      AccentColor.brand => l10n.themeAccentBrand,
      AccentColor.warm => l10n.themeAccentWarm,
      AccentColor.cool => l10n.themeAccentCool,
    };

/// Theme-local accent swatch grid (kit `AccentPicker`): a tappable colour swatch
/// per accent preset; the selected one carries a ring + check. Copy (labels) is
/// from ARB.
class AccentPicker extends StatelessWidget {
  const AccentPicker({required this.selected, required this.onSelect, super.key});

  final AccentColor selected;
  final ValueChanged<AccentColor> onSelect;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return MxCard(
      child: Wrap(
        spacing: MxSpacing.space4,
        runSpacing: MxSpacing.space4,
        alignment: WrapAlignment.center,
        children: [
          for (final accent in themeAccentOrder)
            _Swatch(
              color: accentSwatchColor(accent),
              selected: accent == selected,
              label: accentLabel(l10n, accent),
              onTap: () => onSelect(accent),
            ),
        ],
      ),
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch({
    required this.color,
    required this.selected,
    required this.label,
    required this.onTap,
  });

  final Color color;
  final bool selected;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final mx = MxTheme.of(context);
    final scheme = Theme.of(context).colorScheme;

    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(MxSpacing.space1),
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: selected ? color : mx.divider,
                width: selected ? MxStroke.emphasis : MxStroke.hairline,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(MxSpacing.space1),
              child: Container(
                width: MxSizes.sizeSm,
                height: MxSizes.sizeSm,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                child: selected
                    ? Icon(Icons.check, size: MxIconSize.md, color: scheme.onPrimary)
                    : null,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
