import 'package:flutter/material.dart';
import 'package:memox_v4/core/routes/app_routes.dart';
import 'package:memox_v4/l10n/app_localizations.dart';
import 'package:memox_v4/presentation/shared/composites/mx_bottom_nav.dart';

/// The app's five-tab bottom navigation, mapping [AppTab] → the kit-parity
/// [MxBottomNav] with ARB labels. Shared by the router shell (interactive) and
/// the screen goldens (static frame), so both render the identical kit
/// `.bottom-nav` and stay in lockstep.
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({required this.active, this.onSelected, super.key});

  /// The currently selected tab (lifts its icon onto the active pill).
  final AppTab active;

  /// Tapped-tab callback. `null` renders a non-interactive nav (goldens).
  final ValueChanged<AppTab>? onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final onSelected = this.onSelected;
    return MxBottomNav(
      value: active.name,
      items: [
        for (final tab in AppTab.values)
          MxBottomNavItem(
            id: tab.name,
            label: _label(tab, l10n),
            icon: tab.icon,
          ),
      ],
      onChanged: onSelected == null
          ? null
          : (id) => onSelected(AppTab.values.byName(id)),
    );
  }

  static String _label(AppTab tab, AppLocalizations l10n) => switch (tab) {
    AppTab.today => l10n.navToday,
    AppTab.library => l10n.navLibrary,
    AppTab.add => l10n.navAdd,
    AppTab.stats => l10n.navStats,
    AppTab.profile => l10n.navProfile,
  };
}
