import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

/// Severity levels per `docs/quality/observability-contract.md`.
enum LogLevel {
  /// Dev-only detail — suppressed in release builds.
  debug(500),

  /// Notable lifecycle events (migration ran, sync completed).
  info(800),

  /// Recovered / degraded (a retry succeeded).
  warn(900),

  /// A failure the user feels (persistence error).
  error(1000);

  const LogLevel(this.value);

  /// `dart:developer` level int (mirrors the `logging` package scale).
  final int value;
}

/// Dependency-free logging facade over `dart:developer` — no logging package.
///
/// One [AppLogger] per feature; structured fields (`feature`, `op`, `failure`,
/// `ms`) are appended so logs are filterable and actionable. Log a failure
/// **once, at its origin** (the layer that maps it to a [LogLevel.error]).
///
/// Never pass secrets, tokens, or full PII — redact at the call site
/// (`docs/quality/observability-contract.md`). `debug` is compiled past in
/// release via [kReleaseMode]; never log in hot paths.
class AppLogger {
  const AppLogger(this.feature);

  /// Owning feature/module, e.g. `flashcard`, `srs`, `sync`.
  final String feature;

  void debug(String message, {String? op}) =>
      _log(LogLevel.debug, message, op: op);

  void info(String message, {String? op, int? ms}) =>
      _log(LogLevel.info, message, op: op, ms: ms);

  void warn(String message, {String? op, Object? failure, int? ms}) =>
      _log(LogLevel.warn, message, op: op, failure: failure, ms: ms);

  void error(
    String message, {
    String? op,
    Object? failure,
    int? ms,
    Object? cause,
    StackTrace? stackTrace,
  }) => _log(
    LogLevel.error,
    message,
    op: op,
    failure: failure,
    ms: ms,
    cause: cause,
    stackTrace: stackTrace,
  );

  void _log(
    LogLevel level,
    String message, {
    String? op,
    Object? failure,
    int? ms,
    Object? cause,
    StackTrace? stackTrace,
  }) {
    // Drop debug entirely in release — no string work in the hot path.
    if (level == LogLevel.debug && kReleaseMode) return;

    final fields = <String>[
      'feature=$feature',
      if (op != null) 'op=$op',
      if (failure != null) 'failure=$failure',
      if (ms != null) 'ms=$ms',
    ].join(' ');

    developer.log(
      '$message · $fields',
      name: 'memox.$feature',
      level: level.value,
      error: cause,
      stackTrace: stackTrace,
    );
  }
}
