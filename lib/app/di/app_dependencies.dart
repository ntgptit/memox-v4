import 'package:flutter_riverpod/misc.dart' show Override;

/// Composition root for app-wide dependency injection.
///
/// W1 establishes the Riverpod container (a `ProviderScope` at the root) as the
/// single DI entry point. Concrete repository/data-source overrides are
/// registered here as features land (W2+). No persistent state is held here.
List<Override> appOverrides() => const <Override>[];
