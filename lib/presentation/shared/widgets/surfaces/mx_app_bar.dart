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
    this.leading,
    this.trailing = const <Widget>[],
  });

  final String? title;
  final String? eyebrow;
  final bool large;
  final Widget? leading;
  final List<Widget> trailing;

  static const double _largeHeight = 96;

  @override
  Size get preferredSize =>
      Size.fromHeight(large ? _largeHeight : kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = MxTheme.of(context).colors;
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
            style:
                (large ? theme.textTheme.headlineMedium : null) ??
                theme.textTheme.titleLarge,
          ),
      ],
    );
    return AppBar(
      leading: leading,
      titleSpacing: leading == null ? MxSpacing.space4 : 0,
      title: titleWidget,
      actions: <Widget>[
        ...trailing,
        const SizedBox(width: MxSpacing.space2),
      ],
      toolbarHeight: large ? _largeHeight : kToolbarHeight,
    );
  }
}
