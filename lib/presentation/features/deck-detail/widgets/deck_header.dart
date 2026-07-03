import 'package:flutter/material.dart';
import 'package:memox_v4/core/theme/mx_spacing.dart';
import 'package:memox_v4/l10n/app_localizations.dart';
import 'package:memox_v4/presentation/shared/composites/mx_app_bar.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_icon_button.dart';

/// Deck-detail app bar (kit `deck-detail/appbar`): a back button, the deck name,
/// and an overflow (deck options) button. Shared by every deck-detail state. The
/// kit's deck-level "play audio" action is omitted in v1 (bulk deck TTS is
/// undrivable / ambiguous — documented gap). Copy + labels are from ARB.
class DeckHeader extends StatelessWidget implements PreferredSizeWidget {
  const DeckHeader({required this.title, this.onBack, this.onMenu, super.key});

  final String title;
  final VoidCallback? onBack;
  final VoidCallback? onMenu;

  @override
  Size get preferredSize => const Size.fromHeight(MxSpacing.appBarHeight);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return MxAppBar(
      title: title,
      leading: MxIconButton(
        icon: Icons.arrow_back,
        semanticLabel: l10n.deckDetailBack,
        onPressed: onBack,
      ),
      trailing: MxIconButton(
        icon: Icons.more_vert,
        semanticLabel: l10n.deckDetailMenu,
        onPressed: onMenu,
      ),
    );
  }
}
