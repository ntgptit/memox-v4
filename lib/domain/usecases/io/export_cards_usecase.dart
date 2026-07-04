import 'package:memox_v4/domain/entities/card.dart';
import 'package:memox_v4/domain/entities/srs_state.dart';
import 'package:memox_v4/domain/services/table_codec.dart';

/// One card to export, paired with its SRS state (null when the card was never
/// scheduled). The state is only emitted when the learner opts in (D-026).
typedef ExportItem = ({Card card, SrsState? srs});

/// Emits cards as table text via the chosen [TableCodec]. Each card is one row:
/// `term`, its meanings joined by `; `, and — when [includeSrs] is set — the
/// Leitner box and ISO-8601 due time (import-export BR-3 / D-026 / AC-3). Cell
/// quoting for delimiters/newlines is handled by the codec (BR-4).
class BuildExportUseCase {
  const BuildExportUseCase(this._codec);

  final TableCodec _codec;

  String call(Iterable<ExportItem> items, {required bool includeSrs}) {
    final rows = <List<String>>[];
    for (final item in items) {
      final meanings = item.card.meanings.map((m) => m.text).join('; ');
      final row = <String>[item.card.term, meanings];
      if (includeSrs) {
        final srs = item.srs;
        row.add(srs == null ? '' : '${srs.box.value}');
        row.add(srs?.dueAt?.toIso8601String() ?? '');
      }
      rows.add(row);
    }
    return _codec.encode(rows);
  }
}
