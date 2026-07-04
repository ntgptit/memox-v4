import 'package:flutter/material.dart';
import 'package:memox_v4/core/theme/mx_radius.dart';
import 'package:memox_v4/core/theme/mx_sizes.dart';
import 'package:memox_v4/core/theme/mx_spacing.dart';
import 'package:memox_v4/core/theme/mx_theme.dart';
import 'package:memox_v4/core/theme/mx_typography.dart';

/// The kit's `Sheet` helper as a reusable composite: a bottom sheet surface with a
/// centered drag handle, an optional uppercase section title, and content.
/// Token-driven via [MxTheme]. Present it with [showMxSheet] (which supplies the
/// scrim + drag-to-dismiss). Copy is supplied by the caller (from ARB).
class MxSheet extends StatelessWidget {
  const MxSheet({required this.child, this.title, super.key});

  final Widget child;
  final String? title;

  @override
  Widget build(BuildContext context) {
    final mx = MxTheme.of(context);
    final title = this.title;

    return Container(
      decoration: BoxDecoration(
        color: mx.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(MxRadius.xxl)),
        boxShadow: mx.shadows.nav,
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.only(
            top: MxSpacing.space5,
            left: MxSpacing.space4,
            right: MxSpacing.space4,
            bottom: MxSpacing.space6,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: MxSpacing.space4),
                child: Center(
                  child: Container(
                    width: MxSizes.sizeSm,
                    height: MxSizes.size3xs,
                    decoration: BoxDecoration(
                      color: mx.divider,
                      borderRadius: MxRadius.pillRadius,
                    ),
                  ),
                ),
              ),
              if (title != null)
                Padding(
                  padding: const EdgeInsets.only(
                    left: MxSpacing.space2,
                    bottom: MxSpacing.space2,
                  ),
                  child: Text(
                    title.toUpperCase(),
                    style: TextStyle(
                      fontFamily: MxTypography.fontFamily,
                      fontSize: MxTypography.sizeSm,
                      fontWeight: MxTypography.bold,
                      letterSpacing: MxTypography.sizeSm * MxTypography.trackingWide,
                      color: mx.textTertiary,
                    ),
                  ),
                ),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

/// Presents a [MxSheet] as a modal bottom sheet (Material supplies the scrim +
/// drag-to-dismiss). Resolves with whatever the content pops, or null if
/// dismissed.
Future<T?> showMxSheet<T>({
  required BuildContext context,
  required Widget child,
  String? title,
}) {
  return showModalBottomSheet<T>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => MxSheet(title: title, child: child),
  );
}
