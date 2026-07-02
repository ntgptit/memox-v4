import 'package:memox_v4/core/error/failure.dart';

/// Maps a [Failure] to a **localized, user-facing** message.
///
/// Implemented in the l10n layer (WBS T.4) so all user text stays in ARB — the
/// domain/data layers never build user strings. The developer-facing detail
/// stays in [Failure.message] (logged/reported). The UI resolves a failure to a
/// message through this contract before showing it on an error surface.
abstract interface class FailurePresenter {
  String message(Failure failure);
}
