import 'package:flutter/material.dart';
import 'package:memox_v4/presentation/features/deck-detail/providers/deck_detail_providers.dart';
import 'package:memox_v4/presentation/shared/composites/mx_status_card_row.dart';

/// Deck-detail card row (kit `FlashcardRow`): the shared [MxStatusCardRow] with
/// the deck-detail tightening (tight term + ellipsis-clipped meaning). Wrap it in
/// an `MxCard` at the call site. Copy (status labels) is from ARB.
class FlashcardRow extends StatelessWidget {
  const FlashcardRow({required this.card, this.onPressed, super.key});

  final DeckCardInfo card;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return MxStatusCardRow(
      term: card.term,
      meaning: card.meaning,
      status: card.status,
      hidden: card.hidden,
      onPressed: onPressed,
      tightTerm: true,
      truncateMeaning: true,
    );
  }
}
