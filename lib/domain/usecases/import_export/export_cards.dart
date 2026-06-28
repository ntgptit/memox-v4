import 'package:memox_v4/domain/entities/card.dart';
import 'package:memox_v4/domain/models/card_schedule_info.dart';
import 'package:memox_v4/domain/repositories/card_repository.dart';
import 'package:memox_v4/domain/repositories/deck_repository.dart';
import 'package:memox_v4/domain/repositories/srs_repository.dart';
import 'package:memox_v4/domain/types/result.dart';

/// Gathers a deck's cards (optionally its subtree) into table rows for export
/// (D-026). Row 0 is the header. With [includeSrs] each row also carries the
/// Leitner box + due_at. Encoding (CSV/Excel) is a data-layer concern
/// (`TableCodec`); this use case is plugin-free + testable.
class ExportCardsUseCase {
  const ExportCardsUseCase(this._cards, this._decks, this._srs);

  final CardRepository _cards;
  final DeckRepository _decks;
  final SrsRepository _srs;

  Future<Result<List<List<String>>>> call({
    required int deckId,
    bool includeSubtree = false,
    bool includeSrs = false,
  }) async {
    final cards = <Card>[];
    if (includeSubtree) {
      final ids =
          (await _decks.subtreeCardIds(
            deckId,
            includeHidden: true,
          )).valueOrNull ??
          const <int>[];
      cards.addAll((await _cards.listByIds(ids)).valueOrNull ?? const <Card>[]);
    } else {
      cards.addAll(
        (await _cards.listByDeck(deckId, includeHidden: true)).valueOrNull ??
            const <Card>[],
      );
    }

    final srsById = <int, CardScheduleInfo>{};
    if (includeSrs && cards.isNotEmpty) {
      final infos =
          (await _srs.scheduleInfo(<int>[
            for (final c in cards) c.id,
          ])).valueOrNull ??
          const <CardScheduleInfo>[];
      for (final info in infos) {
        srsById[info.cardId] = info;
      }
    }

    final rows = <List<String>>[
      <String>[
        'term',
        'meaning',
        if (includeSrs) ...<String>['box', 'due_at'],
      ],
      for (final card in cards)
        <String>[
          card.term,
          card.meanings.isEmpty ? '' : card.meanings.first.content,
          if (includeSrs) ...<String>[
            '${srsById[card.id]?.box ?? 0}',
            '${srsById[card.id]?.dueAt ?? ''}',
          ],
        ],
    ];
    return Ok(rows);
  }
}
