import 'package:flutter/material.dart';
import 'package:memox_v4/core/theme/mx_radius.dart';
import 'package:memox_v4/core/theme/mx_sizes.dart';
import 'package:memox_v4/core/theme/mx_spacing.dart';
import 'package:memox_v4/core/theme/mx_theme.dart';
import 'package:memox_v4/core/theme/mx_typography.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_text_field.dart';

/// Editor-local labelled field (kit `Field`): a label (with an optional required
/// marker), a bordered input — an editable [TextField] when [controller] is set,
/// or a read-only [value] otherwise — an optional [trailing] widget, and an
/// optional [error] beneath. Copy is from ARB.
class Field extends StatelessWidget {
  const Field({
    required this.label,
    this.controller,
    this.value,
    this.onChanged,
    this.placeholder,
    this.error,
    this.required = false,
    this.multiline = false,
    this.trailing,
    super.key,
  });

  final String label;
  final TextEditingController? controller;
  final String? value;
  final ValueChanged<String>? onChanged;
  final String? placeholder;
  final String? error;
  final bool required;
  final bool multiline;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final mx = MxTheme.of(context);
    final scheme = Theme.of(context).colorScheme;
    final error = this.error;
    final borderColor = error != null ? scheme.error : mx.divider;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontFamily: MxTypography.fontFamily,
                fontSize: MxTypography.sizeSm,
                fontWeight: MxTypography.bold,
                color: mx.textSecondary,
              ),
            ),
            if (required)
              Text(
                ' *',
                style: TextStyle(
                  fontFamily: MxTypography.fontFamily,
                  fontSize: MxTypography.sizeSm,
                  fontWeight: MxTypography.bold,
                  color: scheme.error,
                ),
              ),
          ],
        ),
        const SizedBox(height: MxSpacing.space2),
        Container(
          constraints: const BoxConstraints(minHeight: MxSpacing.minTouchTarget),
          padding: const EdgeInsets.symmetric(
            horizontal: MxSpacing.space4,
            vertical: MxSpacing.space3,
          ),
          decoration: BoxDecoration(
            borderRadius: MxRadius.controlRadius,
            border: Border.all(color: borderColor, width: MxStroke.hairline),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(child: _input(context, mx, scheme)),
              ?trailing,
            ],
          ),
        ),
        if (error != null) ...[
          const SizedBox(height: MxSpacing.space1),
          Text(
            error,
            style: TextStyle(
              fontFamily: MxTypography.fontFamily,
              fontSize: MxTypography.sizeSm,
              color: scheme.error,
            ),
          ),
        ],
      ],
    );
  }

  Widget _input(BuildContext context, MxTheme mx, ColorScheme scheme) {
    final textStyle = TextStyle(
      fontFamily: MxTypography.fontFamily,
      fontSize: MxTypography.sizeBase,
      color: scheme.onSurface,
    );

    if (controller == null) {
      return Text(value ?? '', style: textStyle.copyWith(color: mx.textSecondary));
    }
    return MxTextField(
      controller: controller!,
      onChanged: onChanged,
      maxLines: multiline ? null : 1,
      minLines: multiline ? 3 : 1,
      style: textStyle,
      hintText: placeholder,
    );
  }
}
