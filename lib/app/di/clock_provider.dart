import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox_v4/core/util/clock.dart';

/// App-wide [Clock]. Production uses [SystemClock]; tests override this with a
/// fake so time-dependent writes (e.g. `card.created_at`) are deterministic.
final clockProvider = Provider<Clock>((ref) => const SystemClock());
