import 'package:flutter/material.dart';
import 'package:memox_v4/core/theme/mx_radius.dart';
import 'package:memox_v4/core/theme/mx_sizes.dart';
import 'package:memox_v4/core/theme/mx_spacing.dart';
import 'package:memox_v4/core/theme/mx_theme.dart';
import 'package:memox_v4/core/theme/mx_typography.dart';
import 'package:memox_v4/presentation/features/study-session/providers/study_session_providers.dart';

/// Study-session local (kit `StageMatching`): stage 2 — two columns of tiles;
/// tap a term then its meaning to match the pair.
class StageMatching extends StatelessWidget {
  const StageMatching({
    required this.terms,
    required this.meanings,
    required this.matched,
    required this.selectedTermId,
    this.onSelectTerm,
    this.onSelectMeaning,
    super.key,
  });

  final List<MatchTile> terms;
  final List<MatchTile> meanings;
  final Set<String> matched;
  final String? selectedTermId;
  final ValueChanged<String>? onSelectTerm;
  final ValueChanged<String>? onSelectMeaning;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            children: [
              for (final tile in terms)
                _Tile(
                  text: tile.text,
                  matched: matched.contains(tile.cardId),
                  selected: selectedTermId == tile.cardId,
                  onTap: matched.contains(tile.cardId)
                      ? null
                      : () => onSelectTerm?.call(tile.cardId),
                ),
            ],
          ),
        ),
        const SizedBox(width: MxSpacing.space3),
        Expanded(
          child: Column(
            children: [
              for (final tile in meanings)
                _Tile(
                  text: tile.text,
                  matched: matched.contains(tile.cardId),
                  selected: false,
                  onTap: matched.contains(tile.cardId)
                      ? null
                      : () => onSelectMeaning?.call(tile.cardId),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.text,
    required this.matched,
    required this.selected,
    this.onTap,
  });

  final String text;
  final bool matched;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final mx = MxTheme.of(context);
    final scheme = Theme.of(context).colorScheme;
    final border = matched
        ? mx.success
        : selected
            ? scheme.primary
            : mx.divider;

    return Padding(
      padding: const EdgeInsets.only(bottom: MxSpacing.space3),
      child: Semantics(
        button: true,
        selected: selected || matched,
        child: Material(
          color: matched ? mx.successSoft : mx.surface,
          borderRadius: MxRadius.controlRadius,
          child: InkWell(
            onTap: onTap,
            borderRadius: MxRadius.controlRadius,
            child: Container(
              constraints:
                  const BoxConstraints(minHeight: MxSpacing.minTouchTarget),
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(
                horizontal: MxSpacing.space2,
                vertical: MxSpacing.space4,
              ),
              decoration: BoxDecoration(
                borderRadius: MxRadius.controlRadius,
                border: Border.all(
                  color: border,
                  width: selected || matched
                      ? MxStroke.emphasis
                      : MxStroke.hairline,
                ),
              ),
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: MxTypography.fontFamily,
                  fontSize: MxTypography.sizeBase,
                  fontWeight: MxTypography.bold,
                  color: scheme.onSurface,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
