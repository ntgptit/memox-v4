import 'package:flutter/material.dart';
import 'package:memox_v4/core/theme/mx_spacing.dart';
import 'package:memox_v4/presentation/shared/layouts/responsive.dart';

/// Minimal body for a tab/route whose feature is not built yet (a later WBS
/// package replaces it). Shows a centered title within readable content bounds.
class MxPlaceholder extends StatelessWidget {
  const MxPlaceholder({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) => MxContentBounds(
    child: Center(
      child: Padding(
        padding: const EdgeInsets.all(MxSpacing.space6),
        child: Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
      ),
    ),
  );
}
