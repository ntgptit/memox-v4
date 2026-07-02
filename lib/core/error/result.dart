import 'package:equatable/equatable.dart';
import 'package:memox_v4/core/error/failure.dart';

/// A success ([Ok]) or a [Failure] ([Err]). Domain and data layers return this
/// instead of throwing for expected errors, so callers must handle both branches.
sealed class Result<T> {
  const Result();

  bool get isOk => this is Ok<T>;

  /// Collapse both branches into one value.
  R fold<R>(R Function(T value) onOk, R Function(Failure failure) onErr) {
    final self = this;
    return switch (self) {
      Ok<T>(:final value) => onOk(value),
      Err<T>(:final failure) => onErr(failure),
    };
  }

  /// Transform the success value; a failure passes through unchanged.
  Result<R> map<R>(R Function(T value) transform) =>
      fold((value) => Ok<R>(transform(value)), Err<R>.new);
}

final class Ok<T> extends Result<T> with EquatableMixin {
  const Ok(this.value);
  final T value;

  @override
  List<Object?> get props => [value];
}

final class Err<T> extends Result<T> with EquatableMixin {
  const Err(this.failure);
  final Failure failure;

  @override
  List<Object?> get props => [failure];
}

/// Run [body], converting any thrown error into an [Err] — never swallow.
/// Pass [onError] to classify the error; otherwise a thrown [Failure] passes
/// through and anything else becomes an [UnexpectedFailure].
Result<T> guard<T>(
  T Function() body, {
  Failure Function(Object error, StackTrace stackTrace)? onError,
}) {
  try {
    return Ok<T>(body());
  } catch (error, stackTrace) {
    return Err<T>(_toFailure(error, stackTrace, onError));
  }
}

/// Async variant of [guard].
Future<Result<T>> guardAsync<T>(
  Future<T> Function() body, {
  Failure Function(Object error, StackTrace stackTrace)? onError,
}) async {
  try {
    return Ok<T>(await body());
  } catch (error, stackTrace) {
    return Err<T>(_toFailure(error, stackTrace, onError));
  }
}

Failure _toFailure(
  Object error,
  StackTrace stackTrace,
  Failure Function(Object, StackTrace)? onError,
) {
  if (onError != null) {
    return onError(error, stackTrace);
  }
  if (error is Failure) {
    return error;
  }
  return UnexpectedFailure(
    error.toString(),
    cause: error,
    stackTrace: stackTrace,
  );
}
