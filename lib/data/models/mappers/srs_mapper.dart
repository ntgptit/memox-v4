import 'package:memox_v4/core/error/result.dart';
import 'package:memox_v4/data/datasources/local/app_database.dart';
import 'package:memox_v4/data/models/mappers/time_mapper.dart';
import 'package:memox_v4/domain/entities/box_level.dart';
import 'package:memox_v4/domain/entities/srs_state.dart';

/// Int → [BoxLevel] (0..8). An out-of-range stored box is data corruption.
BoxLevel boxFromInt(int value) {
  final result = BoxLevel.of(value);
  return switch (result) {
    Ok<BoxLevel>(:final value) => value,
    Err<BoxLevel>(:final failure) =>
      throw StateError('Corrupt box level $value: ${failure.message}'),
  };
}

/// Row → entity mapping for the SRS position; a missing row is a newborn card.
SrsState srsFromRow(SrsStateRow? row) {
  if (row == null) return SrsState.newborn;
  return SrsState(
    box: boxFromInt(row.box),
    dueAt: microsToDateTime(row.dueAt),
    lastReviewedAt: microsToDateTime(row.lastReviewedAt),
  );
}
