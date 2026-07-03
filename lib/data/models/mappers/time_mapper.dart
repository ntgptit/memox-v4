/// Time mapping at the data boundary. The store keeps UTC epoch **microseconds**
/// (`int`); the domain works in [DateTime]. Nullable both ways ("not scheduled").
library;

/// A [DateTime] → epoch-microseconds (UTC).
int? dateTimeToMicros(DateTime? value) => value?.toUtc().microsecondsSinceEpoch;

/// Epoch-microseconds (UTC) → a [DateTime]; null passes through.
DateTime? microsToDateTime(int? micros) => micros == null
    ? null
    : DateTime.fromMicrosecondsSinceEpoch(micros, isUtc: true);
