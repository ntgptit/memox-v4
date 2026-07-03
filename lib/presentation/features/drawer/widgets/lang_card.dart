import 'package:flutter/material.dart';
import 'package:memox_v4/core/theme/mx_sizes.dart';
import 'package:memox_v4/core/theme/mx_spacing.dart';
import 'package:memox_v4/core/theme/mx_theme.dart';
import 'package:memox_v4/core/theme/mx_typography.dart';
import 'package:memox_v4/presentation/shared/composites/mx_card.dart';

/// Drawer-local language selector (kit `LangCard`): an icon, the language name +
/// subtitle, and an expand chevron. A real accessible button that opens a picker.
/// Copy is supplied by the caller (from ARB).
class LangCard extends StatelessWidget {
  const LangCard({
    required this.icon,
    required this.name,
    required this.subtitle,
    this.onPressed,
    super.key,
  });

  final IconData icon;
  final String name;
  final String subtitle;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final mx = MxTheme.of(context);
    final scheme = Theme.of(context).colorScheme;

    return MxCard(
      padding: MxCardPadding.small,
      onPressed: onPressed,
      semanticLabel: name,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: MxIconSize.lg, color: mx.textSecondary),
          const SizedBox(width: MxSpacing.space4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: MxTypography.fontFamily,
                    fontSize: MxTypography.sizeBase,
                    fontWeight: MxTypography.bold,
                    color: scheme.onSurface,
                  ),
                ),
                const SizedBox(height: MxSpacing.space1),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontFamily: MxTypography.fontFamily,
                    fontSize: MxTypography.sizeSm,
                    color: mx.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.expand_more, color: mx.textTertiary),
        ],
      ),
    );
  }
}
