/// A daily study reminder: a time of day + the weekdays it fires
/// (`docs/contracts/types-catalog.md`). Weekdays use `DateTime` numbering
/// (1 = Monday … 7 = Sunday). The OS scheduling is gated (W12 only persists it).
class Reminder {
  const Reminder({
    required this.enabled,
    required this.hour,
    required this.minute,
    required this.weekdays,
  });

  /// Disabled default — every day at 09:00.
  static const Reminder off = Reminder(
    enabled: false,
    hour: 9,
    minute: 0,
    weekdays: <int>{1, 2, 3, 4, 5, 6, 7},
  );

  final bool enabled;
  final int hour;
  final int minute;
  final Set<int> weekdays;

  /// `HH:mm`.
  String get timeText =>
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

  Reminder copyWith({
    bool? enabled,
    int? hour,
    int? minute,
    Set<int>? weekdays,
  }) => Reminder(
    enabled: enabled ?? this.enabled,
    hour: hour ?? this.hour,
    minute: minute ?? this.minute,
    weekdays: weekdays ?? this.weekdays,
  );
}
