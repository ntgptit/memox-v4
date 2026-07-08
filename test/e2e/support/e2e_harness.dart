import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:memox_v4/app/app.dart';
import 'package:memox_v4/core/utils/clock.dart';
import 'package:memox_v4/data/datasources/local/app_database.dart';
import 'package:memox_v4/data/providers/data_providers.dart';
import 'package:memox_v4/data/providers/database_provider.dart';

/// Fixed clock so dates / streak / due windows are deterministic (matches the
/// V.4 study-flow E2E pattern — no fakes pulled into E2E).
class _FixedClock implements Clock {
  const _FixedClock(this._now);
  final DateTime _now;
  @override
  DateTime now() => _now;
}

/// E2E harness (TEST-WBS T.0): drives the **real** app + real providers over a
/// **real in-memory Drift DB** (`AppDatabase.memory()`) — NO fakes for behaviour.
/// Assert both the UI (widget finders) and the DB (`db` queries) so a test fails
/// on a real code bug, not on a fake match. Companion seed helpers keep the
/// per-screen scenario tests concise.
class E2EHarness {
  E2EHarness({DateTime? now})
      : db = AppDatabase.memory(),
        now = now ?? DateTime.utc(2026, 7, 3, 9);

  /// Live in-memory DB — seed with the helpers below, assert with `db.select(...)`.
  final AppDatabase db;
  final DateTime now;

  List<Override> get overrides => [
        appDatabaseProvider.overrideWithValue(db),
        clockProvider.overrideWithValue(_FixedClock(now)),
      ];

  int micros(DateTime t) => t.microsecondsSinceEpoch;

  Future<void> seedPair({
    String id = 'lp',
    String learning = 'ko',
    String native = 'vi',
    bool active = true,
  }) =>
      db.into(db.languagePairs).insert(LanguagePairsCompanion.insert(
            id: id,
            learningLanguage: learning,
            nativeLanguage: native,
            createdAt: 0,
            isActive: Value(active),
          ));

  Future<void> seedDeck({
    String id = 'd',
    String name = 'Deck',
    String pair = 'lp',
    String? parent,
  }) =>
      db.into(db.decks).insert(DecksCompanion.insert(
            id: id,
            name: name,
            languagePairId: pair,
            createdAt: 0,
            parentId: parent == null ? const Value.absent() : Value(parent),
          ));

  Future<void> seedCard({
    required String id,
    String deck = 'd',
    required String term,
    String? meaning,
    bool hidden = false,
  }) async {
    await db.into(db.cards).insert(CardsCompanion.insert(
          id: id,
          deckId: deck,
          term: term,
          createdAt: 0,
          hidden: Value(hidden),
        ));
    if (meaning != null) {
      await db.into(db.cardMeanings).insert(CardMeaningsCompanion.insert(
            id: 'm-$id',
            cardId: id,
            language: 'vi',
            content: meaning,
          ));
    }
  }

  /// [dueAt] = null → box 0/8 off-schedule; else a due instant (µs).
  Future<void> seedSrs({
    required String cardId,
    required int box,
    DateTime? dueAt,
  }) =>
      db.into(db.srsStates).insert(SrsStatesCompanion.insert(
            cardId: cardId,
            box: box,
            dueAt: dueAt == null ? const Value.absent() : Value(micros(dueAt)),
          ));

  Future<void> close() => db.close();
}

/// Pumps the real [MemoxApp] over an [E2EHarness] and settles to a deterministic
/// frame. [seed] runs BEFORE the first pump so the opening frame reflects the DB.
Future<E2EHarness> pumpApp(
  WidgetTester tester, {
  DateTime? now,
  Future<void> Function(E2EHarness h)? seed,
}) async {
  final h = E2EHarness(now: now);
  tester.view.physicalSize = const Size(390, 780);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  // Own the container ourselves (UncontrolledProviderScope) instead of letting
  // ProviderScope dispose it at framework teardown. Reason: disposing the scope
  // cancels the app's Drift watch-streams, and Drift schedules a 0-duration
  // Timer to close them (StreamQueryStore.markAsClosed). Under testWidgets'
  // FakeAsync that timer never fires ⇒ the end-of-test `!timersPending` check
  // throws / the isolate hangs (every E2E test "kẹt"). Disposing the container
  // + closing the DB inside `tester.runAsync` (REAL async) lets that close-timer
  // fire for real. During the test body the streams are merely OPEN (a
  // subscription, not a Timer), so the pending-timer check passes.
  // retry:null ⇒ tắt auto-retry (exponential backoff) của Riverpod. Khi một
  // provider lỗi (vd xoá deck hiện tại ⇒ deckDetailController.getById thất bại),
  // Riverpod tự lên lịch retry backoff (0.8→1.6→3.2s…) — chuỗi tự-đặt-lại này
  // KHÔNG thể drain bằng pump và treo '!timersPending' ở teardown. E2E không cần
  // retry nền; lỗi được assert trực tiếp.
  final container = ProviderContainer(
    overrides: h.overrides,
    retry: (_, _) => null,
  );
  addTearDown(() async {
    await tester.runAsync(() async {
      container.dispose();
      await Future<void>.delayed(Duration.zero); // let Drift's close-timer fire
      await h.close();
    });
  });

  if (seed != null) await seed(h);

  await tester.pumpWidget(
    UncontrolledProviderScope(container: container, child: const MemoxApp()),
  );
  await settle(tester);
  return h;
}

/// Settle for E2E — **luôn dùng cái này**, KHÔNG `tester.pumpAndSettle()` trần.
///
/// Hai vấn đề cần xử lý cùng lúc:
///  1. **Drift cần REAL async.** `testWidgets` chạy trong FakeAsync; query Drift
///     (in-memory) hoàn tất qua timer/microtask THẬT → dưới FakeAsync future không
///     resolve → màn kẹt ở loading. Ta chèn cửa sổ `tester.runAsync` (real async)
///     để query chạy xong rồi `pump` để rebuild với dữ liệu.
///  2. **Animation lặp vô hạn** (shimmer skeleton `..repeat()`, chart) khiến
///     `pumpAndSettle` không bao giờ settle → treo. Nên ta bounded vòng lặp và
///     dừng khi hết frame theo lịch (`hasScheduledFrame == false`).
Future<void> settle(WidgetTester tester, {int steps = 60}) async {
  for (var i = 0; i < steps; i++) {
    // Cho async THẬT (Drift query + stream close-timer) tiến triển.
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await tester.pump(const Duration(milliseconds: 32));
    // Settled khi không còn frame theo lịch (đã rời loading, hết animation).
    if (!tester.binding.hasScheduledFrame) break;
  }
  // Tiêu nốt Timer HỮU HẠN không-đẩy-frame còn treo (transition pop, snackbar
  // auto-dismiss…): advance đồng hồ FAKE 3s (tức thời về real-time) để teardown
  // không dính '!timersPending'. Animation vô hạn (shimmer) chỉ bị đẩy 3s rồi
  // dừng — không treo.
  await tester.pump(const Duration(seconds: 3));
}
