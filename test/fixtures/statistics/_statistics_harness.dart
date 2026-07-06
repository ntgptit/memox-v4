import 'dart:async';

import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:memox_v4/core/error/result.dart';
import 'package:memox_v4/data/fakes/fake_services.dart';
import 'package:memox_v4/domain/entities/deck.dart';
import 'package:memox_v4/domain/entities/deck_stats.dart';
import 'package:memox_v4/domain/entities/ids.dart';
import 'package:memox_v4/domain/entities/study_mode.dart';
import 'package:memox_v4/domain/entities/study_session.dart';
import 'package:memox_v4/domain/repositories/deck_repository.dart';

import '../../harness/provider_harness.dart';

final DateTime _today = DateTime.utc(2026, 7, 3, 9);

FakeDailyActivityService _seededActivity() {
  final svc = FakeDailyActivityService();
  var seq = 0;
  for (var i = 0; i < 5; i++) {
    svc.record(
      StudySession(
        id: StudySessionId('golden-stat-${seq++}'),
        deckId: const DeckId('deck-root'),
        mode: StudyMode.dueReview,
        startedAt: _today.subtract(Duration(days: i)),
        durationMinutes: 10 + i * 3,
        wordsStudied: 10 + i * 3,
      ),
    );
  }
  return svc;
}

/// loaded — activity present, so every chart renders.
List<Override> statisticsLoadedOverrides() =>
    FakeHarness(activity: _seededActivity()).overrides;

/// loading — the deck tree never resolves, so the provider stays loading.
List<Override> statisticsLoadingOverrides() => FakeHarness(
  activity: _seededActivity(),
  deckRepository: _StuckDeckRepository(),
).overrides;

class _StuckDeckRepository implements DeckRepository {
  @override
  Stream<List<Deck>> watchChildren(DeckId? parentId) =>
      Stream.fromFuture(Completer<List<Deck>>().future);
  @override
  Future<Result<Deck>> getById(DeckId id) => throw UnimplementedError();
  @override
  Future<Result<DeckStats>> statsFor(DeckId id) => throw UnimplementedError();
  @override
  Future<Result<Deck>> save(Deck deck) => throw UnimplementedError();
  @override
  Future<Result<void>> delete(DeckId id) => throw UnimplementedError();
}
