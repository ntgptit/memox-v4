import 'package:flutter/material.dart';
import 'package:memox_v4/core/theme/mx_theme.dart';
import 'package:memox_v4/core/theme/mx_typography.dart';

/// The kit's bare inline text input (`MxTextField` · base class `.field`). A
/// borderless, token-styled wrapper over Material's [TextField] for MemoX's inline
/// inputs — editor fields, game answers, paste boxes. It owns the shared input
/// chrome (`isCollapsed`, no border, placeholder color from tokens) so features
/// stop hand-rolling `InputDecoration`. The visible box, if any, is the caller's
/// surrounding container; this widget is only the input itself.
///
/// Purpose: one place for the MemoX inline-input contract.
/// Use when: any editable text inside a feature surface.
/// Public API:
/// - [controller]: the text controller.
/// - [style]: the input typography (defaults to a token body style).
/// - [hintText] / [hintStyle]: placeholder text + optional style (defaults to
///   [style] at the tertiary color).
/// - [onChanged] / [onSubmitted] / [focusNode] / [autofocus] / [textAlign] /
///   [minLines] / [maxLines] / [keyboardType]: pass-through to the input.
/// Category: input
class MxTextField extends StatelessWidget {
  const MxTextField({
    this.controller,
    this.style,
    this.hintText,
    this.hintStyle,
    this.onChanged,
    this.onSubmitted,
    this.focusNode,
    this.autofocus = false,
    this.textAlign = TextAlign.start,
    this.minLines,
    this.maxLines = 1,
    this.keyboardType,
    super.key,
  });

  final TextEditingController? controller;
  final TextStyle? style;
  final String? hintText;
  final TextStyle? hintStyle;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FocusNode? focusNode;
  final bool autofocus;
  final TextAlign textAlign;
  final int? minLines;
  final int? maxLines;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    final mx = MxTheme.of(context);
    final scheme = Theme.of(context).colorScheme;
    final effectiveStyle =
        style ??
        TextStyle(
          fontFamily: MxTypography.fontFamily,
          fontSize: MxTypography.sizeBase,
          color: scheme.onSurface,
        );
    return TextField(
      controller: controller,
      focusNode: focusNode,
      autofocus: autofocus,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      textAlign: textAlign,
      minLines: minLines,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: effectiveStyle,
      // Every border slot is explicitly none: an ambient InputDecorationTheme's
      // enabledBorder/focusedBorder would override a bare `border:` and paint a
      // second outline inside the caller's container (kit `.field` = no chrome).
      decoration: InputDecoration(
        isCollapsed: true,
        filled: false,
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        focusedErrorBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
        hintText: hintText,
        hintStyle: hintStyle ?? effectiveStyle.copyWith(color: mx.textTertiary),
      ),
    );
  }
}
