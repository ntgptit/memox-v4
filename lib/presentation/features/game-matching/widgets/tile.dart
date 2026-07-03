import 'package:flutter/material.dart';
import 'package:memox_v4/core/theme/mx_radius.dart';
import 'package:memox_v4/core/theme/mx_sizes.dart';
import 'package:memox_v4/core/theme/mx_spacing.dart';
import 'package:memox_v4/core/theme/mx_theme.dart';
import 'package:memox_v4/core/theme/mx_typography.dart';

/// Visual tone for a [MatchTile].
enum MatchTone { none, selected, correct, wrong, matched }

/// Game-matching local tile (kit `Tile`): a tappable word card whose tone tints
/// its skin; a [MatchTone.matched] tile is hidden (keeping its grid slot). A real
/// accessible button.
class MatchTileView extends StatelessWidget {
  const MatchTileView({
    required this.text,
    required this.tone,
    this.onPressed,
    super.key,
  });

  final String text;
  final MatchTone tone;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final mx = MxTheme.of(context);
    final scheme = Theme.of(context).colorScheme;

    if (tone == MatchTone.matched) {
      return const SizedBox(height: MxSizes.sizeMd);
    }

    final (background, foreground, border) = switch (tone) {
      MatchTone.selected => (mx.primarySoft, mx.onPrimarySoft, scheme.primary),
      MatchTone.correct => (mx.successSoft, mx.onSuccessSoft, mx.success),
      MatchTone.wrong => (mx.errorSoft, mx.onErrorSoft, scheme.error),
      MatchTone.none || MatchTone.matched => (mx.surface, scheme.onSurface, mx.divider),
    };
    final borderWidth =
        tone == MatchTone.none ? MxStroke.hairline : MxStroke.emphasis;

    return Semantics(
      button: true,
      label: text,
      child: Material(
        color: background,
        shape: RoundedRectangleBorder(
          borderRadius: MxRadius.controlRadius,
          side: BorderSide(color: border, width: borderWidth),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: Container(
            constraints: const BoxConstraints(minHeight: MxSizes.sizeMd),
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(
              vertical: MxSpacing.space4,
              horizontal: MxSpacing.space3,
            ),
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: MxTypography.fontFamily,
                fontSize: MxTypography.sizeBase,
                fontWeight: MxTypography.bold,
                color: foreground,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
