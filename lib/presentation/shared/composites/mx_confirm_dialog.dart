import 'package:flutter/material.dart';
import 'package:memox_v4/core/theme/mx_spacing.dart';
import 'package:memox_v4/core/theme/mx_theme.dart';
import 'package:memox_v4/core/theme/mx_typography.dart';
import 'package:memox_v4/presentation/shared/composites/mx_icon_tile.dart';

/// Tone for [MxConfirmDialog] — drives the header icon tint.
enum MxDialogTone { neutral, warning, error }

/// The kit's shared confirm overlay (`ConfirmDialog`): a centered dialog with a
/// tinted header icon, a title, body text, and a caller-supplied action row. A
/// composite, token-driven via [MxTheme]. It carries **no copy of its own** —
/// every string, node key, and action is passed in by the calling screen (so
/// l10n stays owned there). Present it with [showMxConfirmDialog].
///
/// Convention (kit): exactly one primary/confirm action; cancel is a `ghost`
/// button; a destructive confirm uses `tone: error` + a `danger` confirm button.
class MxConfirmDialog extends StatelessWidget {
  const MxConfirmDialog({
    required this.title,
    required this.text,
    required this.actions,
    this.icon,
    this.tone = MxDialogTone.neutral,
    this.alignment = Alignment.center,
    super.key,
  });

  final String title;
  final String text;

  /// Full-width action buttons (typically `MxButton(block: true)`), stacked.
  final List<Widget> actions;
  final IconData? icon;
  final MxDialogTone tone;
  final AlignmentGeometry alignment;

  @override
  Widget build(BuildContext context) {
    final mx = MxTheme.of(context);
    final scheme = Theme.of(context).colorScheme;
    final icon = this.icon;

    return Dialog(
      alignment: alignment,
      child: Padding(
        padding: const EdgeInsets.all(MxSpacing.space5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (icon != null) ...[
              Center(child: MxIconTile(icon: icon, tone: _tileTone)),
              const SizedBox(height: MxSpacing.space4),
            ],
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: MxTypography.fontFamily,
                fontSize: MxTypography.sizeXl,
                fontWeight: MxTypography.bold,
                color: scheme.onSurface,
              ),
            ),
            const SizedBox(height: MxSpacing.space2),
            Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: MxTypography.fontFamily,
                fontSize: MxTypography.sizeBase,
                color: mx.textSecondary,
              ),
            ),
            const SizedBox(height: MxSpacing.space5),
            for (var i = 0; i < actions.length; i++) ...[
              if (i > 0) const SizedBox(height: MxSpacing.space2),
              actions[i],
            ],
          ],
        ),
      ),
    );
  }

  MxIconTileTone get _tileTone => switch (tone) {
        MxDialogTone.warning => MxIconTileTone.warning,
        MxDialogTone.error => MxIconTileTone.error,
        MxDialogTone.neutral => MxIconTileTone.primary,
      };
}

/// Presents an [MxConfirmDialog] and resolves with whatever the tapped action
/// pops (`Navigator.pop(context, value)`), or null if dismissed. Copy + actions
/// are owned by the caller.
Future<T?> showMxConfirmDialog<T>({
  required BuildContext context,
  required String title,
  required String text,
  required List<Widget> actions,
  IconData? icon,
  MxDialogTone tone = MxDialogTone.neutral,
  AlignmentGeometry alignment = Alignment.center,
  String? barrierLabel,
}) {
  return showDialog<T>(
    context: context,
    barrierLabel: barrierLabel,
    builder: (_) => MxConfirmDialog(
      title: title,
      text: text,
      actions: actions,
      icon: icon,
      tone: tone,
      alignment: alignment,
    ),
  );
}
