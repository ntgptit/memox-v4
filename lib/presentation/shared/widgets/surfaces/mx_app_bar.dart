import 'package:flutter/material.dart';
import 'package:memox_v4/core/theme/mx_spacing.dart';
import 'package:memox_v4/core/theme/mx_theme.dart';

/// The top app bar — the design kit's `MxAppBar`.
///
/// Purpose:
/// A flat, brand-tinted top bar with an optional eyebrow over the title and
/// leading/trailing slots.
///
/// Use when:
/// Heading any screen built with MxScaffold.
///
/// Do not use when:
/// A screen needs no title bar (omit it from MxScaffold).
///
/// Category:
/// layout
///
/// Public API:
/// - title: the bar title text
/// - eyebrow: a small label shown above the title
/// - large: taller large-title bar
/// - leading: leading slot (back button, avatar)
/// - trailing: trailing actions
///
/// States:
/// default
///
/// Variants:
/// regular, large
class MxAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MxAppBar({
    super.key,
    this.title,
    this.eyebrow,
    this.large = false,
    this.automaticallyImplyLeading = true,
    this.leading,
    this.trailing = const <Widget>[],
  });

  final String? title;
  final String? eyebrow;
  final bool large;
  final bool automaticallyImplyLeading;
  final Widget? leading;
  final List<Widget> trailing;

  @override
  Size get preferredSize => Size.fromHeight(
    large ? MxSpacing.appBarLargeHeight : MxSpacing.appBarHeight,
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = MxTheme.of(context).colors;
    final titleStyle = large
        ? theme.textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w800)
        : theme.textTheme.titleLarge;
    final titleWidget = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (eyebrow case final e?)
          Text(
            e,
            style: theme.textTheme.labelMedium?.copyWith(
              color: colors.textSecondary,
            ),
          ),
        if (title case final t?)
          Text(
            t,
            style: titleStyle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
      ],
    );
    return AppBar(
      automaticallyImplyLeading: automaticallyImplyLeading,
      backgroundColor: colors.bg,
      foregroundColor: colors.text,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: leading,
      titleSpacing: leading == null ? MxSpacing.gutter : 0,
      title: titleWidget,
      actions: <Widget>[
        ...trailing,
        const SizedBox(width: MxSpacing.space2),
      ],
      toolbarHeight: large
          ? MxSpacing.appBarLargeHeight
          : MxSpacing.appBarHeight,
    );
  }
}
