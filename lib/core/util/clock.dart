/// A source of the current time, injected rather than read from `DateTime.now`
/// directly so time-dependent logic (SRS due dates, daily activity, streaks)
/// is deterministic under test.
///
/// Production wires [SystemClock]; tests supply a fake implementing [Clock].
/// Provided via DI (`app/di`) so callers never reach for `DateTime.now()`.
abstract interface class Clock {
  /// Current wall-clock time in the local zone.
  DateTime now();

  /// Current instant in UTC.
  DateTime nowUtc();
}

/// The real system clock.
class SystemClock implements Clock {
  const SystemClock();

  @override
  DateTime now() => DateTime.now();

  @override
  DateTime nowUtc() => DateTime.now().toUtc();
}
