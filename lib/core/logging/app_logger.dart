import 'dart:developer' as developer;

/// App-wide logging seam — the **dev / monitoring** side of the error contract
/// (see `core/error`). Diagnostics and error causes go through this, never
/// `print`, so a reporting backend (Crashlytics/Sentry) can be attached in one
/// place later.
abstract interface class AppLogger {
  void debug(String message);
  void info(String message);
  void warn(String message, {Object? error, StackTrace? stackTrace});
  void error(String message, {Object? error, StackTrace? stackTrace});
}

/// Default logger — routes to `dart:developer.log` (visible in DevTools; no
/// `print`). Wrap/replace with a reporting sink when observability lands.
final class DevLogger implements AppLogger {
  const DevLogger();

  @override
  void debug(String message) => _log(message, level: _debug);

  @override
  void info(String message) => _log(message, level: _info);

  @override
  void warn(String message, {Object? error, StackTrace? stackTrace}) =>
      _log(message, level: _warn, error: error, stackTrace: stackTrace);

  @override
  void error(String message, {Object? error, StackTrace? stackTrace}) =>
      _log(message, level: _error, error: error, stackTrace: stackTrace);

  void _log(
    String message, {
    required int level,
    Object? error,
    StackTrace? stackTrace,
  }) {
    developer.log(
      message,
      name: _channel,
      level: level,
      error: error,
      stackTrace: stackTrace,
    );
  }

  static const String _channel = 'memox';
  // dart:developer log levels (package:logging convention).
  static const int _debug = 500;
  static const int _info = 800;
  static const int _warn = 900;
  static const int _error = 1000;
}
