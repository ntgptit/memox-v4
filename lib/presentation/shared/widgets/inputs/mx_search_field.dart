import 'package:flutter/material.dart';
import 'package:memox_v4/core/theme/mx_radius.dart';
import 'package:memox_v4/core/theme/mx_spacing.dart';
import 'package:memox_v4/core/theme/mx_theme.dart';

/// A search bar — the design kit's `MxSearchDock`.
///
/// Purpose:
/// A rounded search input with a leading magnifier and an optional trailing slot.
///
/// Use when:
/// Filtering a list (library search, deck search).
///
/// Do not use when:
/// Capturing general text (use MxTextField).
///
/// Category:
/// input
///
/// Public API:
/// - controller: text editing controller
/// - placeholder: hint text
/// - onChanged: query change callback
/// - trailing: trailing slot (e.g. a filter button)
/// - flat: muted flat treatment instead of an elevated card
///
/// States:
/// default, focused
class MxSearchField extends StatelessWidget {
  const MxSearchField({
    super.key,
    this.controller,
    this.placeholder,
    this.onChanged,
    this.trailing,
    this.flat = false,
  });

  final TextEditingController? controller;
  final String? placeholder;
  final ValueChanged<String>? onChanged;
  final Widget? trailing;
  final bool flat;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = MxTheme.of(context).colors;
    return Container(
      decoration: BoxDecoration(
        color: flat ? colors.surfaceMuted : colors.surfaceRaised,
        borderRadius: MxRadius.pillRadius,
        boxShadow: flat ? null : MxTheme.of(context).shadows.sm,
      ),
      padding: const EdgeInsets.symmetric(horizontal: MxSpacing.space4),
      child: Row(
        children: <Widget>[
          Icon(
            Icons.search,
            size: MxSpacing.space5,
            color: colors.textTertiary,
          ),
          const SizedBox(width: MxSpacing.space2),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: theme.textTheme.bodyMedium,
              decoration: InputDecoration(
                hintText: placeholder,
                filled: false,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                isCollapsed: true,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: MxSpacing.space3,
                ),
              ),
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}
