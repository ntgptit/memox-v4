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
