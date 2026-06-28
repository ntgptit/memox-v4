import 'package:flutter/material.dart';

/// A labelled text input — the design-system text field.
///
/// Purpose:
/// A consistent, theme-styled text field with a label, optional hint, and inline
/// error, so screens never instantiate a raw [TextField].
///
/// Use when:
/// Capturing free-text input (term, meaning, name, goal).
///
/// Do not use when:
/// The input is a search bar (use MxSearchField) or a non-text picker.
///
/// Category:
/// input
///
/// Public API:
/// - controller: text editing controller
/// - label: field label
/// - hint: placeholder
/// - errorText: inline error message
/// - onChanged: change callback
/// - obscureText: hide input (passwords)
/// - keyboardType / maxLines / prefixIcon: standard input options
///
/// States:
/// default, focused, error, disabled
class MxTextField extends StatelessWidget {
  const MxTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.errorText,
    this.onChanged,
    this.obscureText = false,
    this.keyboardType,
    this.maxLines = 1,
    this.prefixIcon,
    this.enabled = true,
  });

  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final bool obscureText;
  final TextInputType? keyboardType;
  final int maxLines;
  final IconData? prefixIcon;
  final bool enabled;

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    onChanged: onChanged,
    obscureText: obscureText,
    keyboardType: keyboardType,
    maxLines: obscureText ? 1 : maxLines,
    enabled: enabled,
    decoration: InputDecoration(
      labelText: label,
      hintText: hint,
      errorText: errorText,
      prefixIcon: prefixIcon == null ? null : Icon(prefixIcon),
    ),
  );
}
