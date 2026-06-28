import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:memox_v4/l10n/generated/app_localizations.dart';
import 'package:memox_v4/presentation/shared/navigation/app_drawer.dart';
import 'package:memox_v4/presentation/shared/widgets/buttons/mx_icon_button.dart';
import 'package:memox_v4/presentation/shared/widgets/display/mx_avatar.dart';
import 'package:memox_v4/presentation/shared/widgets/navigation/mx_bottom_nav.dart';
import 'package:memox_v4/presentation/shared/widgets/navigation/mx_fab.dart';
import 'package:memox_v4/presentation/shared/widgets/surfaces/mx_app_bar.dart';

/// Application shell: the persistent frame around the four primary tabs. Hosts
/// the app bar, the design-kit five-item bottom navigation (Today · Library ·
/// Add · Stats · Profile, where Add is a center action rather than a
/// destination), a Review FAB on the Today tab, and the language drawer. Tab
/// bodies come from the [StatefulNavigationShell].
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const String _todayTab = 'today';
  static const String _libraryTab = 'library';
  static const String _addAction = 'add';
  static const String _statsTab = 'stats';
  static const String _profileTab = 'profile';

  void _goBranch(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  void _onSelect(BuildContext context, String id) {
    // Add is a center action, not a navigation branch (no shell branch behind it).
    if (id == _addAction) {
      _comingSoon(context);
      return;
    }
    final index = switch (id) {
      _todayTab => 0,
      _libraryTab => 1,
      _statsTab => 2,
      _profileTab => 3,
      _ => navigationShell.currentIndex,
    };
    _goBranch(index);
  }

  void _comingSoon(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(l10n.comingSoon)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isToday = navigationShell.currentIndex == 0;
    final currentTab = switch (navigationShell.currentIndex) {
      0 => _todayTab,
      1 => _libraryTab,
      2 => _statsTab,
      3 => _profileTab,
      _ => _libraryTab,
    };
    return Scaffold(
      appBar: MxAppBar(
        // Today's app bar is the kit's `dashboard/appbar` node (shell-provided chrome).
        key: isToday ? const ValueKey('mx-node:dashboard/appbar') : null,
        large: isToday,
        automaticallyImplyLeading: false,
        eyebrow: isToday
            ? MaterialLocalizations.of(context).formatFullDate(DateTime.now())
            : null,
        title: isToday ? _greeting(l10n) : null,
        trailing: <Widget>[
          MxIconButton(
            key: isToday
                ? const ValueKey('mx-node:dashboard/notifications')
                : null,
            icon: Icons.notifications_none,
            onPressed: () => _comingSoon(context),
            tooltip: l10n.notificationsTooltip,
          ),
          Builder(
            builder: (innerContext) => Semantics(
              button: true,
              label: l10n.drawerLanguagesTitle,
              child: GestureDetector(
                onTap: () => Scaffold.of(innerContext).openDrawer(),
                child: const MxAvatar(name: 'Me', size: MxAvatarSize.sm),
              ),
            ),
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: navigationShell,
      floatingActionButton: isToday
          ? Semantics(
              button: true,
              label: l10n.dashboardQuickReview,
              child: MxFab(
                key: const ValueKey('mx-node:dashboard/quick-review'),
                icon: Icons.bolt,
                label: l10n.dashboardQuickReview,
                onPressed: () => _comingSoon(context),
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: MxBottomNav(
        value: currentTab,
        onChanged: (id) => _onSelect(context, id),
        items: <MxBottomNavItem>[
          (id: _todayTab, label: l10n.tabToday, icon: Icons.today),
          (id: _libraryTab, label: l10n.tabLibrary, icon: Icons.style),
          (id: _addAction, label: l10n.tabAdd, icon: Icons.add_circle),
          (id: _statsTab, label: l10n.tabStats, icon: Icons.bar_chart),
          (id: _profileTab, label: l10n.tabProfile, icon: Icons.person),
        ],
      ),
    );
  }
}

String _greeting(AppLocalizations l10n) {
  final hour = DateTime.now().hour;
  if (hour < 12) return l10n.dashboardGreetingMorning;
  if (hour < 18) return l10n.dashboardGreetingAfternoon;
  return l10n.dashboardGreetingEvening;
}
