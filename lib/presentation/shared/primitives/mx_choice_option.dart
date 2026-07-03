import 'package:flutter/material.dart';
import 'package:memox_v4/core/theme/mx_radius.dart';
import 'package:memox_v4/core/theme/mx_sizes.dart';
import 'package:memox_v4/core/theme/mx_spacing.dart';
import 'package:memox_v4/core/theme/mx_theme.dart';
import 'package:memox_v4/core/theme/mx_typography.dart';

/// Result tone for [MxChoiceOption] (`none` is the unanswered default).
enum MxChoiceTone { none, correct, wrong }

/// The kit's `ChoiceOption` helper as a reusable primitive: a full-width tappable
/// answer option for the quiz games, which reveals a correct/wrong skin (border +
/// tinted fill + icon) once graded. Token-driven via [MxTheme].
///
/// It is one option of a mutually-exclusive group, so it carries radio semantics
/// (`inMutuallyExclusiveGroup` + `selected`) and a ≥48 tap target. [text] is
/// supplied by the caller (from ARB).
class MxChoiceOption extends StatelessWidget {
  const MxChoiceOption({
    required this.text,
    this.tone = MxChoiceTone.none,
    this.onPressed,
    super.key,
  });

  final String text;
  final MxChoiceTone tone;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final mx = MxTheme.of(context);
    final scheme = Theme.of(context).colorScheme;
    final skin = _skin(mx, scheme);

    return Semantics(
      inMutuallyExclusiveGroup: true,
      selected: tone != MxChoiceTone.none,
      button: true,
      label: text,
      child: Material(
        color: skin.background,
        shape: RoundedRectangleBorder(
          borderRadius: MxRadius.controlRadius,
          side: BorderSide(color: skin.borderColor, width: skin.borderWidth),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: MxSpacing.minTouchTarget),
            child: Padding(
              padding: const EdgeInsets.all(MxSpacing.space4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      text,
                      style: TextStyle(
                        fontFamily: MxTypography.fontFamily,
                        fontSize: MxTypography.sizeBase,
                        fontWeight: MxTypography.bold,
                        color: skin.foreground,
                      ),
                    ),
                  ),
                  if (skin.icon != null) ...[
                    const SizedBox(width: MxSpacing.space3),
                    Icon(skin.icon, size: MxIconSize.md, color: skin.iconColor),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  _ChoiceSkin _skin(MxTheme mx, ColorScheme scheme) {
    return switch (tone) {
      MxChoiceTone.correct => _ChoiceSkin(
          background: mx.successSoft,
          foreground: mx.onSuccessSoft,
          borderColor: mx.success,
          borderWidth: MxStroke.emphasis,
          icon: Icons.check_circle,
          iconColor: mx.success,
        ),
      MxChoiceTone.wrong => _ChoiceSkin(
          background: mx.errorSoft,
          foreground: mx.onErrorSoft,
          borderColor: scheme.error,
          borderWidth: MxStroke.emphasis,
          icon: Icons.cancel,
          iconColor: scheme.error,
        ),
      MxChoiceTone.none => _ChoiceSkin(
          background: mx.surface,
          foreground: scheme.onSurface,
          borderColor: mx.divider,
          borderWidth: MxStroke.hairline,
        ),
    };
  }
}

class _ChoiceSkin {
  const _ChoiceSkin({
    required this.background,
    required this.foreground,
    required this.borderColor,
    required this.borderWidth,
    this.icon,
    this.iconColor,
  });

  final Color background;
  final Color foreground;
  final Color borderColor;
  final double borderWidth;
  final IconData? icon;
  final Color? iconColor;
}
