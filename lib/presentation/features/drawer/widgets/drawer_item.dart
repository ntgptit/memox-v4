import 'package:flutter/material.dart';
import 'package:memox_v4/core/theme/mx_radius.dart';
import 'package:memox_v4/core/theme/mx_sizes.dart';
import 'package:memox_v4/core/theme/mx_spacing.dart';
import 'package:memox_v4/core/theme/mx_theme.dart';
import 'package:memox_v4/core/theme/mx_typography.dart';

/// Drawer-local nav row (kit `DrawerItem`): an icon + label, a real accessible
/// button with a ≥48 tap target. Copy is from ARB.
class DrawerItem extends StatelessWidget {
  const DrawerItem({
    required this.icon,
    required this.label,
    this.onPressed,
    super.key,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final mx = MxTheme.of(context);
    final scheme = Theme.of(context).colorScheme;

    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: Colors.transparent,
        borderRadius: MxRadius.controlRadius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: MxSpacing.space3,
              horizontal: MxSpacing.space2,
            ),
            child: Row(
              children: [
                Icon(icon, size: MxIconSize.md, color: mx.textSecondary),
                const SizedBox(width: MxSpacing.space4),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontFamily: MxTypography.fontFamily,
                      fontSize: MxTypography.sizeBase,
                      fontWeight: MxTypography.semibold,
                      color: scheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
