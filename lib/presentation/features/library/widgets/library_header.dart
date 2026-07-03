import 'package:flutter/material.dart';
import 'package:memox_v4/core/theme/mx_spacing.dart';
import 'package:memox_v4/l10n/app_localizations.dart';
import 'package:memox_v4/presentation/shared/composites/mx_app_bar.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_icon_button.dart';

/// Library-local app bar (kit `library/appbar`): a menu (drawer) button, the
/// "Library" title, and an overflow button. Shared by every library state. Copy +
/// labels are from ARB.
class LibraryHeader extends StatelessWidget implements PreferredSizeWidget {
  const LibraryHeader({this.onMenu, this.onOverflow, super.key});

  final VoidCallback? onMenu;
  final VoidCallback? onOverflow;

  @override
  Size get preferredSize => const Size.fromHeight(MxSpacing.appBarHeight);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return MxAppBar(
      title: l10n.navLibrary,
      leading: MxIconButton(
        icon: Icons.menu,
        semanticLabel: l10n.libraryMenu,
        onPressed: onMenu,
      ),
      trailing: MxIconButton(
        icon: Icons.more_vert,
        semanticLabel: l10n.libraryOverflow,
        onPressed: onOverflow,
      ),
    );
  }
}
