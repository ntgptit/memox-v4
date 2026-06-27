import 'package:memox_v4/core/error/failure.dart';

/// Railway-oriented result returned by use cases and repositories.
///
/// A [Result] is either an [Ok] holding a success value of type [T] or an [Err]
/// holding a [Failure]. Callers branch with Dart 3 pattern matching:
///
/// ```dart
/// switch (result) {
///   case Ok(:final value): ...
///   case Err(:final failure): ...
/// }
/// ```
///
/// See `docs/contracts/code-style.md` and `docs/contracts/error-contract.md`.
sealed class Result<T> {
  const Result();
}

/// Success carrying a [value] of type [T].
final class Ok<T> extends Result<T> {
  const Ok(this.value);

  final T value;
}

/// Failure carrying a [Failure] from the error taxonomy.
final class Err<T> extends Result<T> {
  const Err(this.failure);

  final Failure failure;
}

/// Ergonomic accessors over [Result] so call sites don't re-write the same
/// `switch` everywhere. Pure — no dependencies beyond the taxonomy.
extension ResultX<T> on Result<T> {
  bool get isOk => this is Ok<T>;

  bool get isErr => this is Err<T>;

  /// The success value, or `null` on failure.
  T? get valueOrNull => switch (this) {
    Ok(:final value) => value,
    Err() => null,
  };

  /// The [Failure], or `null` on success.
  Failure? get failureOrNull => switch (this) {
    Err(:final failure) => failure,
    Ok() => null,
  };

  /// Collapse both branches into a single value.
  R fold<R>(R Function(T value) onOk, R Function(Failure failure) onErr) =>
      switch (this) {
        Ok(:final value) => onOk(value),
        Err(:final failure) => onErr(failure),
      };

  /// Map the success value, preserving any [Failure] unchanged.
  Result<R> map<R>(R Function(T value) transform) => switch (this) {
    Ok(:final value) => Ok(transform(value)),
    Err(:final failure) => Err(failure),
  };

  /// The success value, or the result of [orElse] applied to the failure.
  T getOrElse(T Function(Failure failure) orElse) => switch (this) {
    Ok(:final value) => value,
    Err(:final failure) => orElse(failure),
  };
}
