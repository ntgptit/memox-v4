import 'package:flutter_test/flutter_test.dart';
import 'package:memox_v4/core/error/failure.dart';
import 'package:memox_v4/core/error/result.dart';
import 'package:memox_v4/domain/entities/box_level.dart';
import 'package:memox_v4/domain/entities/card.dart';
import 'package:memox_v4/domain/entities/daily_goal.dart';
import 'package:memox_v4/domain/entities/deck.dart';
import 'package:memox_v4/domain/entities/deck_stats.dart';
import 'package:memox_v4/domain/entities/ids.dart';
import 'package:memox_v4/domain/entities/review_log.dart';
import 'package:memox_v4/domain/repositories/card_repository.dart';
import 'package:memox_v4/domain/repositories/deck_repository.dart';
import 'package:memox_v4/domain/repositories/review_repository.dart';
import 'package:memox_v4/domain/repositories/settings_repository.dart';

/// DM.3 is a set of pure interfaces (the frozen FE/BE contract). This proves each
/// is implementable and its method surface is type-stable — a signature change
/// breaks these stubs to compile. Behavioral fakes come in DM.9.
void main() {
  test('DeckRepository is implementable and returns Results/streams', () async {
    final DeckRepository repo = _StubDeckRepository();
    expect(await repo.watchChildren(null).first, isEmpty);
    expect(await repo.getById(const DeckId('x')), isA<Err<Deck>>());
    expect(await repo.statsFor(const DeckId('x')), isA<Ok<DeckStats>>());
    expect(await repo.delete(const DeckId('x')), isA<Ok<void>>());
  });

  test('CardRepository is implementable', () async {
    final CardRepository repo = _StubCardRepository();
    expect(await repo.watchByDeck(const DeckId('d')).first, isEmpty);
    expect(await repo.setHidden(const CardId('c'), hidden: true), isA<Ok<void>>());
    expect(await repo.search('x'), isA<Ok<List<Card>>>());
  });

  test('ReviewRepository is implementable', () async {
    final ReviewRepository repo = _StubReviewRepository();
    expect(await repo.watchDueCount().first, 0);
    expect(await repo.currentBox(const CardId('c')), isA<Ok<BoxLevel>>());
    expect(
      await repo.saveSchedule(cardId: const CardId('c'), box: BoxLevel.firstBox),
      isA<Ok<void>>(),
    );
  });

  test('SettingsRepository is implementable', () async {
    final SettingsRepository repo = _StubSettingsRepository();
    expect(await repo.watchDailyGoal().first, isA<DailyGoal>());
    expect(await repo.watchNewCardsPerDay().first, 20);
    expect(await repo.saveNewCardsPerDay(15), isA<Ok<void>>());
  });
}

class _StubDeckRepository implements DeckRepository {
  @override
  Stream<List<Deck>> watchChildren(DeckId? parentId) => Stream.value(const []);
  @override
  Future<Result<Deck>> getById(DeckId id) async =>
      const Err(NotFoundFailure('stub'));
  @override
  Future<Result<DeckStats>> statsFor(DeckId id) async =>
      const Ok(DeckStats.empty);
  @override
  Future<Result<Deck>> save(Deck deck) async => Ok(deck);
  @override
  Future<Result<void>> delete(DeckId id) async => const Ok<void>(null);
}

class _StubCardRepository implements CardRepository {
  @override
  Stream<List<Card>> watchByDeck(DeckId deckId) => Stream.value(const []);
  @override
  Future<Result<Card>> getById(CardId id) async =>
      const Err(NotFoundFailure('stub'));
  @override
  Future<Result<Card>> save(Card card) async => Ok(card);
  @override
  Future<Result<void>> delete(CardId id) async => const Ok<void>(null);
  @override
  Future<Result<void>> setHidden(CardId id, {required bool hidden}) async =>
      const Ok<void>(null);
  @override
  Future<Result<List<Card>>> search(String query, {DeckId? within}) async =>
      const Ok([]);
}

class _StubReviewRepository implements ReviewRepository {
  @override
  Stream<int> watchDueCount({DeckId? within}) => Stream.value(0);
  @override
  Future<Result<List<Card>>> dueQueue({
    DeckId? within,
    required DateTime asOf,
    int? limit,
  }) async =>
      const Ok([]);
  @override
  Future<Result<List<Card>>> newQueue({
    DeckId? within,
    required int limit,
  }) async =>
      const Ok([]);
  @override
  Future<Result<BoxLevel>> currentBox(CardId cardId) async =>
      const Ok(BoxLevel.newCard);
  @override
  Future<Result<void>> saveSchedule({
    required CardId cardId,
    required BoxLevel box,
    DateTime? dueAt,
  }) async =>
      const Ok<void>(null);
  @override
  Future<Result<void>> logReview(ReviewLog log) async => const Ok<void>(null);
}

class _StubSettingsRepository implements SettingsRepository {
  @override
  Stream<DailyGoal> watchDailyGoal() => Stream.value(const DailyGoal());
  @override
  Future<Result<void>> saveDailyGoal(DailyGoal goal) async =>
      const Ok<void>(null);
  @override
  Stream<int> watchNewCardsPerDay() => Stream.value(20);
  @override
  Future<Result<void>> saveNewCardsPerDay(int count) async =>
      const Ok<void>(null);
}
