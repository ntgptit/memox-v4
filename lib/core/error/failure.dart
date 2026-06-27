/// Cross-cutting failure taxonomy.
///
/// The closed set of failures every layer maps into — no ad-hoc error strings.
/// Mirrors `docs/contracts/error-contract.md`. Domain-specific failures
/// (e.g. import/sync) are added by their owning feature, not here.
sealed class Failure {
  const Failure({this.message, this.cause});

  /// Optional human-oriented detail for logging/diagnostics. User-facing copy is
  /// resolved separately (see `docs/ui-ux/l10n-copy-contract.md`).
  final String? message;

  /// The low-level error this failure was mapped from, if any. Kept for logging
  /// at the origin; never leaked raw to the presentation layer.
  final Object? cause;
}

/// Bad input at a boundary. Surfaces as an inline message; not retryable.
final class ValidationFailure extends Failure {
  const ValidationFailure({super.message, super.cause});
}

/// A requested entity does not exist. Surfaces as an empty/not-found state.
final class NotFoundFailure extends Failure {
  const NotFoundFailure({super.message, super.cause});
}

/// Concurrent or duplicate state. Surfaces as a conflict prompt.
final class ConflictFailure extends Failure {
  const ConflictFailure({super.message, super.cause});
}

/// Local storage error. Surfaces as an error state with retry.
final class PersistenceFailure extends Failure {
  const PersistenceFailure({super.message, super.cause});
}

/// Remote unreachable. Surfaces as an offline/error state with retry.
final class NetworkFailure extends Failure {
  const NetworkFailure({super.message, super.cause});
}

/// Unhandled/unexpected error. Surfaces as a generic error and is logged.
final class UnexpectedFailure extends Failure {
  const UnexpectedFailure({super.message, super.cause});
}
