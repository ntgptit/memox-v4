import 'package:flutter/material.dart';
import 'package:memox_v4/core/theme/mx_spacing.dart';
import 'package:memox_v4/core/theme/mx_theme.dart';

/// A list/section title row — the design kit's `MxSectionHeader`.
///
/// Purpose:
/// Labels a section of content, with an optional caption and a trailing action.
///
/// Use when:
/// Introducing a group of items (e.g. "Recent decks", with a "See all" action).
///
/// Do not use when:
/// The heading is the screen title (use MxAppBar).
///
/// Category:
/// display
///
/// Public API:
/// - title: section title
/// - caption: optional sub-label under the title
/// - action: trailing action label (e.g. "See all")
/// - onAction: action callback
///
/// States:
/// default
class MxSectionHeader extends StatelessWidget {
  const MxSectionHeader({
    super.key,
    required this.title,
    this.caption,
    this.action,
    this.onAction,
  });

  final String title;
  final String? caption;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = MxTheme.of(context).colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: MxSpacing.space2),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(title, style: theme.textTheme.titleMedium),
                if (caption case final c?)
                  Text(
                    c,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          if (action case final a?)
            TextButton(onPressed: onAction, child: Text(a)),
        ],
      ),
    );
  }
}
