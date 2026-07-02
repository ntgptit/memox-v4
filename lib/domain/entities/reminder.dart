import 'package:equatable/equatable.dart';

/// A study reminder (`Reminder`): a time of day plus the weekdays it fires on
/// (settings). Weekdays use `DateTime.weekday` numbering (1 = Monday … 7 =
/// Sunday). An empty weekday set means the reminder is off.
class Reminder extends Equatable {
  const Reminder({
    required this.hour,
    required this.minute,
    required this.weekdays,
  })  : assert(hour >= 0 && hour < 24, 'hour must be 0..23'),
        assert(minute >= 0 && minute < 60, 'minute must be 0..59');

  static const Reminder off = Reminder(hour: 9, minute: 0, weekdays: {});

  final int hour;
  final int minute;
  final Set<int> weekdays;

  bool get isEnabled => weekdays.isNotEmpty;

  @override
  List<Object> get props => [hour, minute, weekdays];
}
