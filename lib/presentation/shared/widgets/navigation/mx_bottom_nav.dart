import 'package:flutter/material.dart';
import 'package:memox_v4/core/theme/mx_radius.dart';
import 'package:memox_v4/core/theme/mx_sizes.dart';
import 'package:memox_v4/core/theme/mx_spacing.dart';
import 'package:memox_v4/core/theme/mx_theme.dart';

/// One destination in an [MxBottomNav].
typedef MxBottomNavItem = ({String id, String label, IconData icon});

/// The bottom navigation bar — the design kit's `MxBottomNav`.
///
/// Purpose:
/// The app's top-level destination switcher, pinned to the bottom edge.
///
/// Use when:
/// Switching between the app's main sections.
///
/// Do not use when:
/// Selecting an in-screen option (use MxSegmentedControl).
///
/// Category:
/// navigation
///
/// Public API:
/// - items: the destinations (id + label + icon)
/// - value: the active destination id
/// - onChanged: destination-change callback
///
/// States:
/// default, selected
class MxBottomNav extends StatelessWidget {
  const MxBottomNav({
    super.key,
    required this.items,
    required this.value,
    required this.onChanged,
  });

  final List<MxBottomNavItem> items;
  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = MxTheme.of(context).colors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(
          top: BorderSide(color: colors.divider, width: MxStroke.hairline),
        ),
        boxShadow: MxTheme.of(context).shadows.nav,
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: MxSpacing.bottomNavHeight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              for (final item in items)
                Expanded(
                  child: InkWell(
                    onTap: () => onChanged(item.id),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: MxSpacing.space1,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          DecoratedBox(
                            decoration: BoxDecoration(
                              color: item.id == value
                                  ? colors.primarySoft
                                  : Colors.transparent,
                              borderRadius: MxRadius.pillRadius,
                            ),
                            child: SizedBox(
                              width: MxSizes.sizeMd,
                              height: MxSpacing.space7,
                              child: Icon(
                                item.icon,
                                size: MxIconSize.lg,
                                color: item.id == value
                                    ? colors.primaryStrong
                                    : colors.textTertiary,
                              ),
                            ),
                          ),
                          Text(
                            item.label,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: item.id == value
                                  ? colors.primaryStrong
                                  : colors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
