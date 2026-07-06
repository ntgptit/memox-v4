import 'package:flutter/material.dart';
import 'package:memox_v4/core/theme/mx_component.dart';
import 'package:memox_v4/core/theme/mx_radius.dart';
import 'package:memox_v4/core/theme/mx_sizes.dart';
import 'package:memox_v4/core/theme/mx_spacing.dart';
import 'package:memox_v4/core/theme/mx_theme.dart';
import 'package:memox_v4/core/theme/mx_typography.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_text_field.dart';

/// The kit's rounded search dock with a leading search glyph (`MxSearchDock` ·
/// base class `.search-dock`). A composite wrapping a real [TextField],
/// token-driven via [MxTheme]. The focus ring shows on real focus (tracked via a
/// [FocusNode]) or when [focused] is forced. [flat] swaps the elevated surface for
/// a muted one. [placeholder] comes from ARB.
///
/// Stateful only to own the internal [FocusNode]'s lifecycle; the ring rebuilds
/// via a [ListenableBuilder], not `setState`.
class MxSearchDock extends StatefulWidget {
  const MxSearchDock({
    required this.placeholder,
    this.controller,
    this.focusNode,
    this.onChanged,
    this.focused = false,
    this.flat = false,
    this.trailing,
    super.key,
  });

  final String placeholder;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final bool focused;
  final bool flat;
  final Widget? trailing;

  @override
  State<MxSearchDock> createState() => _MxSearchDockState();

  /// Kit `--memox-comp-search-dock-height` mirror.
  static const double height = MxComponentSizes.searchDockHeight;
}

class _MxSearchDockState extends State<MxSearchDock> {
  FocusNode? _ownedNode;

  FocusNode get _node => widget.focusNode ?? (_ownedNode ??= FocusNode());

  @override
  void dispose() {
    _ownedNode?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mx = MxTheme.of(context);
    final trailing = widget.trailing;

    return ListenableBuilder(
      listenable: _node,
      builder: (context, _) {
        final focused = widget.focused || _node.hasFocus;
        final shadows = <BoxShadow>[
          if (!widget.flat) ...mx.shadows.sm,
          if (focused)
            BoxShadow(color: mx.focusRing, spreadRadius: MxStroke.focus),
        ];

        return Container(
          height: MxSearchDock.height,
          padding: const EdgeInsets.symmetric(horizontal: MxSpacing.space4),
          decoration: BoxDecoration(
            color: widget.flat ? mx.surfaceMuted : mx.surface,
            borderRadius: MxRadius.pillRadius,
            boxShadow: shadows.isEmpty ? null : shadows,
          ),
          child: Row(
            children: [
              Icon(Icons.search, size: MxIconSize.md, color: mx.textTertiary),
              const SizedBox(width: MxSpacing.space3),
              Expanded(
                // The bare-input primitive — the pill container above is the
                // sole owner of box, shadow, and focus ring (kit .search-dock).
                child: MxTextField(
                  controller: widget.controller,
                  focusNode: _node,
                  onChanged: widget.onChanged,
                  style: TextStyle(
                    fontFamily: MxTypography.fontFamily,
                    fontSize: MxTypography.sizeBase,
                    color: mx.text,
                  ),
                  hintText: widget.placeholder,
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: MxSpacing.space3),
                trailing,
              ],
            ],
          ),
        );
      },
    );
  }
}
