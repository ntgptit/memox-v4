import 'package:memox_v4/core/logging/app_logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'logger_provider.g.dart';

/// The app [AppLogger]. Features/services read it via `ref.watch(loggerProvider)`
/// — never construct a logger directly. Override in tests to capture output.
@riverpod
AppLogger logger(Ref ref) => const DevLogger();
