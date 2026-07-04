import 'package:flutter_test/flutter_test.dart';
import 'package:memox_v4/core/error/result.dart';
import 'package:memox_v4/domain/entities/box_level.dart';
import 'package:memox_v4/domain/entities/card.dart';
import 'package:memox_v4/domain/entities/card_meaning.dart';
import 'package:memox_v4/domain/entities/ids.dart';
import 'package:memox_v4/domain/entities/import_preview.dart';
import 'package:memox_v4/domain/entities/srs_state.dart';
import 'package:memox_v4/domain/services/table_codec.dart';
import 'package:memox_v4/domain/usecases/io/export_cards_usecase.dart';
import 'package:memox_v4/domain/usecases/io/import_cards_usecase.dart';

Card _card(String term, List<String> meanings) => (Card.create(
      id: const CardId('c'),
      deckId: const DeckId('d'),
      term: term,
      meanings: [
        for (var i = 0; i < meanings.length; i++)
          (CardMeaning.create(id: CardMeaningId('m$i'), language: 'vi', text: meanings[i])
                  as Ok<CardMeaning>)
              .value,
      ],
    ) as Ok<Card>)
    .value;

void main() {
  group('CsvCodec', () {
    test('decodes simple comma rows', () {
      expect(
        const CsvCodec().decode('a,b\nc,d'),
        [
          ['a', 'b'],
          ['c', 'd'],
        ],
      );
    });

    test('respects a tab delimiter (D-025)', () {
      expect(
        const CsvCodec(delimiter: '\t').decode('term\tmeaning'),
        [
          ['term', 'meaning'],
        ],
      );
    });

    test('parses quoted fields with delimiter, newline, and escaped quotes', () {
      final rows = const CsvCodec().decode('"a,b","line1\nline2","he said ""hi"""');
      expect(rows, [
        ['a,b', 'line1\nline2', 'he said "hi"'],
      ]);
    });

    test('encode round-trips and quotes per BR-4', () {
      const codec = CsvCodec();
      final encoded = codec.encode([
        ['a,b', 'plain'],
        ['has"quote', 'has\nnewline'],
      ]);
      expect(encoded.contains('"a,b"'), isTrue);
      expect(encoded.contains('"has""quote"'), isTrue);
      expect(codec.decode(encoded), [
        ['a,b', 'plain'],
        ['has"quote', 'has\nnewline'],
      ]);
    });
  });

  group('ParseImportUseCase (D-025)', () {
    test('maps columns, skips the header, and counts bad rows', () {
      const input = 'Term,Meaning\nneko,con mèo\ninu,con chó\nbad-row-no-comma';
      final preview = const ParseImportUseCase(CsvCodec()).call(
        input,
        const ColumnMapping(termColumn: 0, meaningColumn: 1, hasHeader: true),
      );
      expect(preview.drafts, [
        const CardDraft(term: 'neko', meaning: 'con mèo'),
        const CardDraft(term: 'inu', meaning: 'con chó'),
      ]);
      expect(preview.skipped, 1);
    });

    test('skips rows missing a required field', () {
      final preview = const ParseImportUseCase(CsvCodec()).call(
        'neko,\n,con chó',
        const ColumnMapping(termColumn: 0, meaningColumn: 1),
      );
      expect(preview.drafts, isEmpty);
      expect(preview.skipped, 2);
    });
  });

  group('BuildExportUseCase (D-026)', () {
    test('emits term + joined meanings, no SRS by default', () {
      final out = const BuildExportUseCase(CsvCodec()).call(
        [(card: _card('neko', ['con mèo', 'cat']), srs: null)],
        includeSrs: false,
      );
      expect(out, 'neko,con mèo; cat');
    });

    test('includes box + due when opted in (AC-3)', () {
      final due = DateTime.utc(2026, 7, 10);
      final out = const BuildExportUseCase(CsvCodec()).call(
        [
          (card: _card('neko', ['con mèo']), srs: SrsState(box: BoxLevel.firstBox, dueAt: due)),
        ],
        includeSrs: true,
      );
      expect(out, 'neko,con mèo,1,${due.toIso8601String()}');
    });
  });
}
