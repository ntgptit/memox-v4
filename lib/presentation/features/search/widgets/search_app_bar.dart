import 'package:flutter/material.dart';
import 'package:memox_v4/core/theme/mx_spacing.dart';
import 'package:memox_v4/l10n/app_localizations.dart';
import 'package:memox_v4/presentation/shared/composites/mx_search_dock.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_icon_button.dart';

/// Search-local app bar (kit `search/appbar`): a back button beside the search
/// field. MxAppBar takes a string title, so the search screen needs this bar with
/// an embedded [MxSearchDock]. Copy + labels are from ARB.
class SearchAppBar extends StatelessWidget implements PreferredSizeWidget {
  const SearchAppBar({
    required this.controller,
    this.onBack,
    this.onChanged,
    this.onClear,
    this.showClear = false,
    super.key,
  });

  final TextEditingController controller;
  final VoidCallback? onBack;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final bool showClear;

  /// Kit `search/appbar` height — raw px with no matching token.
  static const double _height = 64;

  @override
  Size get preferredSize => const Size.fromHeight(_height);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: _height,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: MxSpacing.gutter),
            child: Row(
              spacing: MxSpacing.space3,
              children: [
                MxIconButton(
                  icon: Icons.arrow_back,
                  semanticLabel: l10n.searchBack,
                  onPressed: onBack,
                ),
                Expanded(
                  child: MxSearchDock(
                    controller: controller,
                    placeholder: l10n.searchPlaceholder,
                    focused: true,
                    onChanged: onChanged,
                    trailing: showClear
                        ? MxIconButton(
                            icon: Icons.close,
                            semanticLabel: l10n.searchClear,
                            size: MxIconButtonSize.small,
                            onPressed: onClear,
                          )
                        : null,
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
