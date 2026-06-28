import 'package:flutter/material.dart';
import 'package:memox_v4/core/theme/mx_spacing.dart';
import 'package:memox_v4/core/theme/mx_theme.dart';
import 'package:memox_v4/presentation/shared/widgets/buttons/mx_button.dart';
import 'package:memox_v4/presentation/shared/widgets/display/mx_text.dart';

/// Which async state to render.
enum MxStateKind { loading, empty, error }

/// A full-area async state — the design-system loading/empty/error view.
///
/// Purpose:
/// One consistent placeholder for the three async states a screen body can be
/// in, so every feature renders loading/empty/error the same way.
///
/// Use when:
/// A list or screen is loading, has no data, or failed to load.
///
/// Do not use when:
/// Showing a transient message (use MxSnackbar).
///
/// Category:
/// async
///
/// Public API:
/// - kind: loading / empty / error
/// - icon: glyph for empty/error
/// - title / message: copy
/// - actionLabel + onAction: optional action (e.g. Retry)
///
/// States:
/// loading, empty, error
class MxStateView extends StatelessWidget {
  const MxStateView({
    super.key,
    required this.kind,
    this.icon,
    this.title,
    this.message,
    this.actionLabel,
    this.onAction,
  });

  const MxStateView.loading({Key? key, String? message})
    : this(key: key, kind: MxStateKind.loading, message: message);

  const MxStateView.empty({
    Key? key,
    IconData? icon,
    String? title,
    String? message,
  }) : this(
         key: key,
         kind: MxStateKind.empty,
         icon: icon,
         title: title,
         message: message,
       );

  const MxStateView.error({
    Key? key,
    String? title,
    String? message,
    String? actionLabel,
    VoidCallback? onAction,
  }) : this(
         key: key,
         kind: MxStateKind.error,
         icon: Icons.error_outline,
         title: title,
         message: message,
         actionLabel: actionLabel,
         onAction: onAction,
       );

  final MxStateKind kind;
  final IconData? icon;
  final String? title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final colors = MxTheme.of(context).colors;
    if (kind == MxStateKind.loading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const CircularProgressIndicator(),
            if (message case final m?) ...<Widget>[
              const SizedBox(height: MxSpacing.space4),
              MxText.body(m, color: colors.textSecondary),
            ],
          ],
        ),
      );
    }
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(MxSpacing.space6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (icon case final i?)
              Icon(i, size: MxSpacing.space10, color: colors.textTertiary),
            if (title case final t?) ...<Widget>[
              const SizedBox(height: MxSpacing.space4),
              MxText.title(t, textAlign: TextAlign.center),
            ],
            if (message case final m?) ...<Widget>[
              const SizedBox(height: MxSpacing.space2),
              MxText.body(
                m,
                color: colors.textSecondary,
                textAlign: TextAlign.center,
              ),
            ],
            if (actionLabel case final a?) ...<Widget>[
              const SizedBox(height: MxSpacing.space5),
              MxButton(
                label: a,
                variant: MxButtonVariant.secondary,
                onPressed: onAction,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
