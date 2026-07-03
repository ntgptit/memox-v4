import 'package:flutter/material.dart';
import 'package:memox_v4/core/theme/mx_spacing.dart';
import 'package:memox_v4/core/theme/mx_theme.dart';
import 'package:memox_v4/core/theme/mx_typography.dart';
import 'package:memox_v4/l10n/app_localizations.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_badge.dart';

/// The status a [MxStatusCardRow] badges — the single taxonomy shared by
/// deck-detail + search (previously duplicated).
enum MxCardStatus { newCard, due, mastered }

/// The kit's shared card row (`StatusCardRow`): a term + meaning (+ optional deck
/// line) with a trailing status badge. A composite, token-driven via [MxTheme];
/// wrap it in an `MxCard` at the call site. Owns the status → label + badge tone
/// map once; the labels come from ARB, not hardcoded.
///
/// [hidden] dims the row and shows a hidden glyph. The two render flags encode the
/// only differences between callers: [tightTerm] (deck-detail tightens the term
/// tracking) and [truncateMeaning] (deck-detail clips the meaning to one line).
class MxStatusCardRow extends StatelessWidget {
  const MxStatusCardRow({
    required this.term,
    required this.meaning,
    required this.status,
    this.deck,
    this.hidden = false,
    this.onPressed,
    this.tightTerm = false,
    this.truncateMeaning = false,
    super.key,
  });

  final String term;
  final String meaning;
  final MxCardStatus status;
  final String? deck;
  final bool hidden;
  final VoidCallback? onPressed;
  final bool tightTerm;
  final bool truncateMeaning;

  @override
  Widget build(BuildContext context) {
    final mx = MxTheme.of(context);
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final (label, tone) = _status(l10n);

    final row = Opacity(
      opacity: hidden ? 0.5 : 1,
      child: Row(
        spacing: MxSpacing.space4,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  spacing: MxSpacing.space2,
                  children: [
                    Flexible(
                      child: Text(
                        term,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: MxTypography.fontFamily,
                          fontSize: MxTypography.sizeMd,
                          fontWeight: MxTypography.extrabold,
                          letterSpacing: tightTerm
                              ? MxTypography.sizeMd * MxTypography.trackingTight
                              : null,
                          color: scheme.onSurface,
                        ),
                      ),
                    ),
                    if (hidden)
                      Icon(
                        Icons.visibility_off,
                        size: MxTypography.sizeBase,
                        color: mx.textTertiary,
                        semanticLabel: l10n.cardHidden,
                      ),
                  ],
                ),
                const SizedBox(height: MxSpacing.space1),
                Text(
                  meaning,
                  maxLines: truncateMeaning ? 1 : null,
                  overflow: truncateMeaning ? TextOverflow.ellipsis : null,
                  style: TextStyle(
                    fontFamily: MxTypography.fontFamily,
                    fontSize: MxTypography.sizeSm,
                    color: mx.textSecondary,
                  ),
                ),
                if (deck != null) ...[
                  const SizedBox(height: MxSpacing.space1),
                  Text(
                    deck!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: MxTypography.fontFamily,
                      fontSize: MxTypography.sizeSm,
                      color: mx.textTertiary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          MxBadge(tone: tone, soft: true, label: label),
        ],
      ),
    );

    if (onPressed == null) return row;
    return Semantics(
      button: true,
      child: InkWell(onTap: onPressed, child: row),
    );
  }

  (String, MxBadgeTone) _status(AppLocalizations l10n) {
    return switch (status) {
      MxCardStatus.newCard => (l10n.cardStatusNew, MxBadgeTone.neutral),
      MxCardStatus.due => (l10n.cardStatusDue, MxBadgeTone.error),
      MxCardStatus.mastered => (l10n.cardStatusMastered, MxBadgeTone.success),
    };
  }
}
