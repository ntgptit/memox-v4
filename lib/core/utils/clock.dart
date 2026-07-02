/// Injectable time source. Domain logic (SRS scheduling, streak roll-over) must
/// read "now" through a [Clock], never `DateTime.now()` directly, so schedulers
/// stay deterministic and testable (inject a fixed clock in tests).
abstract interface class Clock {
  DateTime now();
}

/// Real wall-clock. The only place `DateTime.now()` is allowed.
final class SystemClock implements Clock {
  const SystemClock();

  @override
  DateTime now() => DateTime.now();
}
