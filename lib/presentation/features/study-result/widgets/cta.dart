import 'package:flutter/material.dart';
import 'package:memox_v4/core/theme/mx_spacing.dart';
import 'package:memox_v4/l10n/app_localizations.dart';
import 'package:memox_v4/presentation/features/study-result/providers/study_result_providers.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_button.dart';

/// Study-result local (kit `Cta`): the primary + secondary action pair, which
/// varies by the result [head]. Copy is from ARB.
class Cta extends StatelessWidget {
  const Cta({
    required this.head,
    this.onPrimary,
    this.onSecondary,
    super.key,
  });

  final ResultHead head;
  final VoidCallback? onPrimary;
  final VoidCallback? onSecondary;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final (primaryLabel, primaryIcon, secondaryLabel) = switch (head) {
      ResultHead.goalMissed => (l10n.resultKeepGoing, Icons.bolt, l10n.resultLater),
      _ => (l10n.resultKeepStudying, Icons.bolt, l10n.resultBackToLibrary),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MxButton(
          label: primaryLabel,
          icon: primaryIcon,
          block: true,
          onPressed: onPrimary,
        ),
        const SizedBox(height: MxSpacing.space2),
        MxButton(
          label: secondaryLabel,
          variant: MxButtonVariant.ghost,
          block: true,
          onPressed: onSecondary,
        ),
      ],
    );
  }
}
