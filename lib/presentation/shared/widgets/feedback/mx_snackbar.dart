import 'package:flutter/material.dart';
import 'package:memox_v4/core/theme/mx_theme.dart';

/// Semantic tone for [MxSnackbar].
enum MxSnackbarTone { neutral, success, error }

/// Transient bottom message — the design-system snackbar.
///
/// Purpose:
/// The single entry point for transient feedback, so screens never call
/// `ScaffoldMessenger`/`SnackBar` directly and tone styling stays consistent.
///
/// Use when:
/// Confirming an action or reporting a recoverable error briefly.
///
/// Do not use when:
/// The state is persistent (use MxStateView) or needs a decision (use a dialog).
///
/// Category:
/// feedback
///
/// Public API:
/// - show(context, message, tone): display a themed snackbar
///
/// States:
/// neutral, success, error
abstract final class MxSnackbar {
  const MxSnackbar._();

  static void show(
    BuildContext context,
    String message, {
    MxSnackbarTone tone = MxSnackbarTone.neutral,
  }) {
    final colors = MxTheme.of(context).colors;
    final (background, foreground) = switch (tone) {
      MxSnackbarTone.neutral => (colors.text, colors.surface),
      MxSnackbarTone.success => (colors.successSoft, colors.onSuccessSoft),
      MxSnackbarTone.error => (colors.errorSoft, colors.onErrorSoft),
    };
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message, style: TextStyle(color: foreground)),
          backgroundColor: background,
        ),
      );
  }
}
