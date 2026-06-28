import 'package:flutter/material.dart';
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
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: MxSpacing.space1),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              for (final item in items)
                Expanded(
                  child: InkWell(
                    onTap: () => onChanged(item.id),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: MxSpacing.space2,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Icon(
                            item.icon,
                            size: MxSpacing.space6,
                            color: item.id == value
                                ? colors.primary
                                : colors.textTertiary,
                          ),
                          const SizedBox(height: MxSpacing.space1),
                          Text(
                            item.label,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: item.id == value
                                  ? colors.primary
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
