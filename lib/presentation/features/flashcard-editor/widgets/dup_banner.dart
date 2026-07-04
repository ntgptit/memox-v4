import 'package:flutter/material.dart';
import 'package:memox_v4/l10n/app_localizations.dart';
import 'package:memox_v4/presentation/shared/composites/mx_action_callout.dart';

/// Editor-local duplicate warning (kit `DupBanner`): a soft warning banner shown
/// when the term already exists in the deck (soft-duplicate, D-020 — the save is
/// still allowed). Copy is from ARB.
class DupBanner extends StatelessWidget {
  const DupBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return MxActionCallout(
      icon: Icons.warning_amber,
      text: AppLocalizations.of(context).editorDupWarning,
    );
  }
}
