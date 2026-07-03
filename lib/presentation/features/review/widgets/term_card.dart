import 'package:flutter/material.dart';
import 'package:memox_v4/core/theme/mx_spacing.dart';
import 'package:memox_v4/core/theme/mx_typography.dart';
import 'package:memox_v4/l10n/app_localizations.dart';
import 'package:memox_v4/presentation/shared/composites/mx_card.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_icon_button.dart';

/// Review-local (kit `review/term`): the term with an audio control. While audio
/// plays the icon becomes an equalizer and a "Playing…" line appears. Copy is
/// from ARB.
class TermCard extends StatelessWidget {
  const TermCard({
    required this.term,
    required this.playing,
    this.onAudio,
    super.key,
  });

  final String term;
  final bool playing;
  final VoidCallback? onAudio;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;

    return MxCard(
      child: Column(
        children: [
          Text(
            term,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: MxTypography.fontFamily,
              fontSize: MxTypography.size4xl,
              fontWeight: MxTypography.extrabold,
              letterSpacing: MxTypography.size4xl * MxTypography.trackingTight,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: MxSpacing.space3),
          MxIconButton(
            icon: playing ? Icons.graphic_eq : Icons.volume_up,
            semanticLabel: l10n.reviewAudio,
            onPressed: onAudio,
          ),
          if (playing) ...[
            const SizedBox(height: MxSpacing.space2),
            Text(
              l10n.reviewPlaying,
              style: TextStyle(
                fontFamily: MxTypography.fontFamily,
                fontSize: MxTypography.sizeSm,
                fontWeight: MxTypography.semibold,
                color: scheme.primary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
