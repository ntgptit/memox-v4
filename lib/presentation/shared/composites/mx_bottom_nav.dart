import 'package:flutter/material.dart';
import 'package:memox_v4/core/theme/mx_radius.dart';
import 'package:memox_v4/core/theme/mx_spacing.dart';
import 'package:memox_v4/core/theme/mx_theme.dart';
import 'package:memox_v4/core/theme/mx_typography.dart';

/// One destination of an [MxBottomNav].
class MxBottomNavItem {
  const MxBottomNavItem({
    required this.id,
    required this.label,
    required this.icon,
  });

  final String id;
  final String label;
  final IconData icon;
}

/// The kit's fixed bottom navigation with an active pill indicator (`MxBottomNav`
/// · base class `.bottom-nav`). A composite, token-driven via [MxTheme]. Each
/// destination is an accessible tab (`Semantics(button, selected, label)`); the
/// active one lifts its icon onto a `primarySoft` pill and turns `primaryStrong`.
/// Item labels are supplied by the caller (from ARB).
class MxBottomNav extends StatelessWidget {
  const MxBottomNav({
    required this.items,
    required this.value,
    this.onChanged,
    super.key,
  });

  final List<MxBottomNavItem> items;
  final String? value;
  final ValueChanged<String>? onChanged;

  // Kit `.bottom-nav` metrics — raw px with no matching token.
  static const double _iconPillWidth = 56;
  static const double _iconPillHeight = 30;
  static const double _glyphSize = 26;
  static const double _labelSize = 11;
  static const double _labelGap = 3;
  static const double _bottomInset = 4;

  @override
  Widget build(BuildContext context) {
    final mx = MxTheme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(color: mx.surface, boxShadow: mx.shadows.nav),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: MxSpacing.bottomNavHeight,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              MxSpacing.space2,
              MxSpacing.space2,
              MxSpacing.space2,
              MxSpacing.space2 + _bottomInset,
            ),
            child: Row(
              children: [
                for (final item in items)
                  Expanded(
                    child: _NavItem(
                      item: item,
                      active: item.id == value,
                      onTap: onChanged == null ? null : () => onChanged!(item.id),
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

class _NavItem extends StatelessWidget {
  const _NavItem({required this.item, required this.active, this.onTap});

  final MxBottomNavItem item;
  final bool active;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final mx = MxTheme.of(context);
    final color = active ? mx.primaryStrong : mx.textTertiary;

    return Semantics(
      button: true,
      selected: active,
      label: item.label,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: MxBottomNav._iconPillWidth,
              height: MxBottomNav._iconPillHeight,
              alignment: Alignment.center,
              decoration: active
                  ? BoxDecoration(
                      color: mx.primarySoft,
                      borderRadius: MxRadius.pillRadius,
                    )
                  : null,
              child: Icon(item.icon, size: MxBottomNav._glyphSize, color: color),
            ),
            const SizedBox(height: MxBottomNav._labelGap),
            Text(
              item.label,
              style: TextStyle(
                fontFamily: MxTypography.fontFamily,
                fontSize: MxBottomNav._labelSize,
                fontWeight: MxTypography.semibold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
