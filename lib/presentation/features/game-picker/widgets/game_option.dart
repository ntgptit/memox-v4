import 'package:flutter/material.dart';
import 'package:memox_v4/core/theme/mx_spacing.dart';
import 'package:memox_v4/core/theme/mx_theme.dart';
import 'package:memox_v4/core/theme/mx_typography.dart';
import 'package:memox_v4/presentation/shared/composites/mx_card.dart';
import 'package:memox_v4/presentation/shared/composites/mx_icon_tile.dart';

/// Game-picker local game choice (kit `GameOption`): a tinted icon tile, the game
/// name + description, and a chevron. A real accessible button; dimmed +
/// non-interactive when [onPressed] is null (not enough words). Copy is from ARB.
class GameOption extends StatelessWidget {
  const GameOption({
    required this.icon,
    required this.name,
    required this.description,
    this.onPressed,
    super.key,
  });

  final IconData icon;
  final String name;
  final String description;
  final VoidCallback? onPressed;

  static const double _disabledOpacity = 0.5;

  @override
  Widget build(BuildContext context) {
    final mx = MxTheme.of(context);
    final scheme = Theme.of(context).colorScheme;

    return Opacity(
      opacity: onPressed == null ? _disabledOpacity : 1,
      child: MxCard(
        padding: MxCardPadding.small,
        onPressed: onPressed,
        semanticLabel: name,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            MxIconTile(icon: icon, tone: MxIconTileTone.accent),
            const SizedBox(width: MxSpacing.space4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontFamily: MxTypography.fontFamily,
                      fontSize: MxTypography.sizeBase,
                      fontWeight: MxTypography.bold,
                      color: scheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: MxSpacing.space1),
                  Text(
                    description,
                    style: TextStyle(
                      fontFamily: MxTypography.fontFamily,
                      fontSize: MxTypography.sizeSm,
                      color: mx.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: mx.textTertiary),
          ],
        ),
      ),
    );
  }
}
