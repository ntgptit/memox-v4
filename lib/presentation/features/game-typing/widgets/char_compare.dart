import 'package:flutter/material.dart';
import 'package:memox_v4/core/theme/mx_spacing.dart';
import 'package:memox_v4/core/theme/mx_theme.dart';
import 'package:memox_v4/core/theme/mx_typography.dart';

/// Placeholder glyph for a character the learner never typed.
const String _missingGlyph = '_';

/// Game-typing local (kit `CharCompare`): a per-character diff of the typed
/// answer against the correct term — each glyph is [MxTheme.success] when it
/// matches, [MxTheme.error] otherwise. A missing character shows as `_`.
class CharCompare extends StatelessWidget {
  const CharCompare({required this.typed, required this.correct, super.key});

  final String typed;
  final String correct;

  @override
  Widget build(BuildContext context) {
    final mx = MxTheme.of(context);
    final errorColor = Theme.of(context).colorScheme.error;
    final typedChars = typed.characters.toList();
    final correctChars = correct.characters.toList();

    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: MxSpacing.space2,
      children: [
        for (final (index, expected) in correctChars.indexed)
          Text(
            index < typedChars.length ? typedChars[index] : _missingGlyph,
            style: TextStyle(
              fontFamily: MxTypography.fontFamily,
              fontSize: MxTypography.size2xl,
              fontWeight: MxTypography.extrabold,
              color: (index < typedChars.length && typedChars[index] == expected)
                  ? mx.success
                  : errorColor,
            ),
          ),
      ],
    );
  }
}
