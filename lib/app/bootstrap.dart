import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox_v4/app/app.dart';
import 'package:memox_v4/core/logging/app_logger.dart';
import 'package:memox_v4/core/logging/logger_provider.dart';

/// App entrypoint wiring: one [ProviderContainer] shared between the running
/// widget tree and the app-wide error handlers, all inside a guarded zone so no
/// error path is swallowed.
///
/// This is the dev/monitoring half of the AGENTS.md error contract — every
/// uncaught error (framework, platform, or async) is routed to [AppLogger].
/// User-facing surfacing is the per-feature half: `Failure` → `AsyncValue.error`
/// → a localized message in the UI.
void bootstrap() {
  final container = ProviderContainer();
  final AppLogger logger = container.read(loggerProvider);

  runZonedGuarded(
    () {
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
        logger.error('Uncaught platform error', error: error, stackTrace: stack);
        return true;
      };

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
