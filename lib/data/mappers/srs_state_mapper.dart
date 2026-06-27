import 'package:memox_v4/data/datasources/local/drift/app_database.dart'
    show SrsStateData;
import 'package:memox_v4/domain/entities/srs_state.dart';
import 'package:memox_v4/domain/types/last_result.dart';

/// Maps a Drift `srs_state` row ([SrsStateData]) to the domain [SrsState].
SrsState mapSrsState(SrsStateData row) => SrsState(
  cardId: row.cardId,
  box: row.box,
  dueAt: row.dueAt,
  lastResult: LastResult.fromStorage(row.lastResult),
  reviewedAt: row.reviewedAt,
);
