import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox_v4/app/app.dart';
import 'package:memox_v4/core/logging/app_logger.dart';
import 'package:memox_v4/core/logging/logger_provider.dart';
import 'package:memox_v4/data/seed/seed_providers.dart';

/// App entrypoint wiring: one [ProviderContainer] shared between the running
/// widget tree and the app-wide error handlers, all inside a guarded zone so no
/// error path is swallowed.
///
/// Before the first frame it establishes the database's clean first-run state
/// (the single active language pair + default preferences that the deck FK needs)
/// — and, in debug builds, seeds a realistic sample deck tree — so the app opens
/// against a valid store on every platform (native + web).
///
/// This is the dev/monitoring half of the AGENTS.md error contract — every
/// uncaught error (framework, platform, or async) is routed to [AppLogger].
/// User-facing surfacing is the per-feature half: `Failure` → `AsyncValue.error`
/// → a localized message in the UI.
void bootstrap() {
  final container = ProviderContainer();
  final AppLogger logger = container.read(loggerProvider);

  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      // Errors raised inside the Flutter framework (build/layout/paint).
      FlutterError.onError = (details) {
        logger.error(
          'FlutterError: ${details.exceptionAsString()}',
          error: details.exception,
          stackTrace: details.stack,
        );
      };

      // Errors from the engine/platform outside the framework. Returning true
      // marks them handled (we've logged them) so the app is not force-killed.
      PlatformDispatcher.instance.onError = (error, stack) {
        logger.error(
          'Uncaught platform error',
          error: error,
          stackTrace: stack,
        );
        return true;
      };

      await _prepareDatabase(container, logger);

      runApp(
        UncontrolledProviderScope(
          container: container,
          child: const MemoxApp(),
        ),
      );
    },
    // Async errors that escape the zone (e.g. an un-awaited future throwing).
    (error, stack) =>
        logger.error('Uncaught zone error', error: error, stackTrace: stack),
  );
}

/// Opens the DB and seeds the clean first-run state (debug also seeds sample
/// data). A seeding failure is logged, not fatal — the app still starts, and any
/// downstream persistence error surfaces per-feature as `AsyncValue.error`.
Future<void> _prepareDatabase(
  ProviderContainer container,
  AppLogger logger,
) async {
  try {
    final seeder = container.read(databaseSeederProvider);
    await (kDebugMode ? seeder.seedSampleData() : seeder.ensureFirstRun());
  } catch (error, stack) {
    logger.error(
      'Database first-run seeding failed',
      error: error,
      stackTrace: stack,
    );
  }
}
