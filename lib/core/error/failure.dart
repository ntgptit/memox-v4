import 'package:equatable/equatable.dart';

/// The app's error vocabulary. A [Failure] carries a **developer-facing**
/// [message] (for logs / monitoring) plus the optional [cause] / [stackTrace].
///
/// The END-USER message is deliberately NOT here — it is produced from the
/// failure by a `FailurePresenter` (see `failure_presenter.dart`) so all user
/// text stays in ARB (l10n). Layers return `Result<T>` (`result.dart`) instead
/// of throwing for expected errors.
sealed class Failure extends Equatable {
  const Failure(this.message, {this.cause, this.stackTrace});

  /// Developer-facing description — logged/reported, never shown raw to users.
  final String message;
  final Object? cause;
  final StackTrace? stackTrace;

  @override
  List<Object?> get props => [runtimeType, message, cause];
}

/// Invalid input (e.g. D-030: language pair `source == target` or empty).
final class ValidationFailure extends Failure {
  const ValidationFailure(super.message, {super.cause, super.stackTrace});
}

/// A requested entity does not exist.
final class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message, {super.cause, super.stackTrace});
}

/// Local persistence (Drift / file) error.
final class PersistenceFailure extends Failure {
  const PersistenceFailure(super.message, {super.cause, super.stackTrace});
}

/// A device/service (notification, TTS, file, backup) error.
final class ServiceFailure extends Failure {
  const ServiceFailure(super.message, {super.cause, super.stackTrace});
}

/// Anything uncaught / unexpected — wraps an unknown thrown error.
final class UnexpectedFailure extends Failure {
  const UnexpectedFailure(super.message, {super.cause, super.stackTrace});
}
