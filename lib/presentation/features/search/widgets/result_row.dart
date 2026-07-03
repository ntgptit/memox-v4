import 'package:flutter/material.dart';
import 'package:memox_v4/presentation/features/search/providers/search_providers.dart';
import 'package:memox_v4/presentation/shared/composites/status_card_row.dart';

/// Search-local result row (kit `ResultRow`): the shared [MxStatusCardRow] with
/// the owning deck's name on the deck line. Wrap it in an `MxCard` at the call
/// site. Copy (status labels) is from ARB.
class ResultRow extends StatelessWidget {
  const ResultRow({required this.result, this.onPressed, super.key});

  final SearchResult result;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return MxStatusCardRow(
      term: result.term,
      meaning: result.meaning,
      deck: result.deckName,
      status: result.status,
      hidden: result.hidden,
      onPressed: onPressed,
    );
  }
}
