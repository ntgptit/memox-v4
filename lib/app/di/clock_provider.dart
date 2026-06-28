import 'package:memox_v4/core/util/clock.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'clock_provider.g.dart';

/// App-wide [Clock]. Production uses [SystemClock]; tests override this with a
/// fake so time-dependent writes (e.g. `card.created_at`) are deterministic.
@Riverpod(keepAlive: true)
Clock clock(Ref ref) => const SystemClock();
