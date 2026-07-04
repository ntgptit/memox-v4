import 'package:flutter/material.dart';
import 'package:memox_v4/core/theme/mx_spacing.dart';
import 'package:memox_v4/core/theme/mx_theme.dart';
import 'package:memox_v4/core/theme/mx_typography.dart';
import 'package:memox_v4/presentation/shared/composites/mx_icon_tile.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_button.dart';

/// The kit's naming dialog (`Dialog` + `DialogInput`): a centered dialog with a
/// tinted header icon, a title, one labelled text field, and stacked Cancel /
/// Create actions. Used to create a deck (library) or sub-deck (deck-detail) and
/// mirrors [MxConfirmDialog]'s look. Carries **no copy of its own** — every
/// string is passed in by the caller (l10n stays owned there). Present it with
/// [showMxInputDialog], which resolves to the trimmed, non-empty name or null.
///
/// The Create button stays disabled while the field is blank (BR-1: a deck name
/// is required). State is the field's own [TextEditingController] — no `setState`.
class MxInputDialog extends StatefulWidget {
  const MxInputDialog({
    required this.title,
    required this.label,
    required this.confirmLabel,
    required this.cancelLabel,
    this.placeholder,
    this.initialValue,
    this.icon,
    super.key,
  });

  final String title;
  final String label;
  final String confirmLabel;
  final String cancelLabel;
  final String? placeholder;
  final String? initialValue;
  final IconData? icon;

  @override
  State<MxInputDialog> createState() => _MxInputDialogState();
}

class _MxInputDialogState extends State<MxInputDialog> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.initialValue);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _controller.text.trim();
    if (name.isEmpty) return;
    Navigator.of(context).pop(name);
  }

  @override
  Widget build(BuildContext context) {
    final mx = MxTheme.of(context);
    final scheme = Theme.of(context).colorScheme;

    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(MxSpacing.space5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.icon != null) ...[
              Center(child: MxIconTile(icon: widget.icon!, tone: MxIconTileTone.primary)),
              const SizedBox(height: MxSpacing.space4),
            ],
            Text(
              widget.title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: MxTypography.fontFamily,
                fontSize: MxTypography.sizeXl,
                fontWeight: MxTypography.bold,
                color: scheme.onSurface,
              ),
            ),
            const SizedBox(height: MxSpacing.space4),
            Text(
              widget.label,
              style: TextStyle(
                fontFamily: MxTypography.fontFamily,
                fontSize: MxTypography.sizeSm,
                fontWeight: MxTypography.bold,
                color: mx.textSecondary,
              ),
            ),
            const SizedBox(height: MxSpacing.space2),
            TextField(
              controller: _controller,
              autofocus: true,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submit(),
              decoration: InputDecoration(hintText: widget.placeholder),
            ),
            const SizedBox(height: MxSpacing.space5),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                MxButton(
                  label: widget.cancelLabel,
                  variant: MxButtonVariant.ghost,
                  onPressed: () => Navigator.of(context).pop(),
                ),
                const SizedBox(width: MxSpacing.space2),
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _controller,
                  builder: (context, value, _) => MxButton(
                    label: widget.confirmLabel,
                    onPressed: value.text.trim().isEmpty ? null : _submit,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Presents an [MxInputDialog] and resolves with the trimmed, non-empty name the
/// learner entered, or null if they cancelled/dismissed. Copy is owned by caller.
Future<String?> showMxInputDialog({
  required BuildContext context,
  required String title,
  required String label,
  required String confirmLabel,
  required String cancelLabel,
  String? placeholder,
  String? initialValue,
  IconData? icon,
}) {
  return showDialog<String>(
    context: context,
    builder: (_) => MxInputDialog(
      title: title,
      label: label,
      confirmLabel: confirmLabel,
      cancelLabel: cancelLabel,
      placeholder: placeholder,
      initialValue: initialValue,
      icon: icon,
    ),
  );
}
