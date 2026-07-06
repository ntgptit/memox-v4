import 'package:flutter/material.dart';
import 'package:memox_v4/core/theme/mx_sizes.dart';
import 'package:memox_v4/core/theme/mx_spacing.dart';
import 'package:memox_v4/core/theme/mx_theme.dart';
import 'package:memox_v4/core/theme/mx_typography.dart';
import 'package:memox_v4/l10n/app_localizations.dart';

/// Drawer-local menu panel (kit `DrawerPanel`): a today's-activity header above
/// the nav [items]. Rendered as the full-screen drawer route body (the kit's
/// slide-out overlay + scrim is a route here — documented gap). [activity] is the
/// header's time·words row (or a skeleton). Copy is from ARB.
class DrawerPanel extends StatelessWidget {
  const DrawerPanel({required this.activity, required this.items, super.key});

  final Widget activity;
  final List<Widget> items;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final mx = MxTheme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: MxSpacing.space2,
            right: MxSpacing.space2,
            bottom: MxSpacing.space4,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.drawerActivityLabel.toUpperCase(),
                style: TextStyle(
                  fontFamily: MxTypography.fontFamily,
                  fontSize: MxTypography.sizeSm,
                  fontWeight: MxTypography.bold,
                  letterSpacing: MxTypography.sizeSm * MxTypography.trackingWide,
                  color: mx.textSecondary,
                ),
              ),
              const SizedBox(height: MxSpacing.space2),
              activity,
            ],
          ),
        ),
        Divider(height: MxStroke.hairline, color: mx.divider),
        const SizedBox(height: MxSpacing.space2),
        ...items,
      ],
    );
  }
}

/// The header's time·words row (kit `schedule 12:45 · 24 words`).
class DrawerActivityRow extends StatelessWidget {
  const DrawerActivityRow({required this.time, required this.words, super.key});

  final String time;
  final String words;

  @override
  Widget build(BuildContext context) {
    final mx = MxTheme.of(context);
    final scheme = Theme.of(context).colorScheme;
    final style = TextStyle(
      fontFamily: MxTypography.fontFamily,
      fontSize: MxTypography.sizeMd,
      fontWeight: MxTypography.bold,
      color: scheme.onSurface,
    );

    return Row(
      children: [
        Icon(Icons.schedule, size: MxIconSize.lg, color: scheme.primary),
        const SizedBox(width: MxSpacing.space2),
        Text(time, style: style),
        const SizedBox(width: MxSpacing.space2),
        Text('·', style: TextStyle(color: mx.textTertiary)),
        const SizedBox(width: MxSpacing.space2),
        Text(words, style: style),
      ],
    );
  }
}
