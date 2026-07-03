import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

import 'package:memox_v4/data/fakes/fake_repositories.dart';
import 'package:memox_v4/data/fakes/fake_services.dart';
import 'package:memox_v4/data/fakes/fake_store.dart';
import 'package:memox_v4/data/providers/data_providers.dart';
import 'package:memox_v4/domain/repositories/card_repository.dart';
import 'package:memox_v4/domain/repositories/deck_repository.dart';
import 'package:memox_v4/domain/services/daily_activity_service.dart';
import 'package:memox_v4/l10n/app_localizations.dart';

/// A ready-made bundle of fake overrides for the data-layer providers, so any
/// Phase S screen can be pumped against in-memory fakes via
/// `ProviderScope(overrides: harness.overrides)` — no Drift required. This is the
/// seam that lets FE and BE proceed in parallel; DT.5 swaps the same providers for
/// Drift-backed values with no screen change.
class FakeHarness {
  FakeHarness._({
    required this.store,
    required this.clock,
    required this.overrides,
    required this.audio,
    required this.files,
  });

  final FakeStore store;
  final FakeClock clock;
  final FakeAudioService audio;
  final FakeImportExportFileService files;
  final List<Override> overrides;

  factory FakeHarness({
    FakeStore? store,
    DateTime? now,
    DailyActivityService? activity,
    DeckRepository? deckRepository,
    CardRepository? cardRepository,
  }) {
    final clock = FakeClock(now ?? DateTime.utc(2026, 7, 3, 9));
    final data = store ?? seedFakeStore(now: clock.now());
    final audio = FakeAudioService();
    final files = FakeImportExportFileService();

    final overrides = <Override>[
      clockProvider.overrideWithValue(clock),
      deckRepositoryProvider
          .overrideWithValue(deckRepository ?? FakeDeckRepository(data)),
      cardRepositoryProvider
          .overrideWithValue(cardRepository ?? FakeCardRepository(data)),
      reviewRepositoryProvider.overrideWithValue(FakeReviewRepository(data)),
      settingsRepositoryProvider.overrideWithValue(FakeSettingsRepository(data)),
      settingsServiceProvider.overrideWithValue(FakeSettingsService()),
      languagePairServiceProvider.overrideWithValue(FakeLanguagePairService()),
      dailyActivityServiceProvider
          .overrideWithValue(activity ?? FakeDailyActivityService()),
      reminderNotificationServiceProvider
          .overrideWithValue(FakeReminderNotificationService()),
      audioServiceProvider.overrideWithValue(audio),
      importExportFileServiceProvider.overrideWithValue(files),
      backupRestoreServiceProvider.overrideWithValue(FakeBackupRestoreService()),
    ];

    return FakeHarness._(
      store: data,
      clock: clock,
      overrides: overrides,
      audio: audio,
      files: files,
    );
  }
}

/// Pumps [child] inside a [ProviderScope] wired to the fakes and a localized
/// [MaterialApp]. Pass a shared [harness] to seed/assert store state, or extra
/// overrides for provider(s) under test.
Future<FakeHarness> pumpWithFakes(
  WidgetTester tester,
  Widget child, {
  FakeHarness? harness,
  List<Override> extra = const [],
}) async {
  final active = harness ?? FakeHarness();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [...active.overrides, ...extra],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: child,
      ),
    ),
  );
  await tester.pumpAndSettle();
  return active;
}
