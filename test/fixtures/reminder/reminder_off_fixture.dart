// reminder · off — golden-parity fixture.
import '../../harness/provider_harness.dart';
import '../_fixture.dart';

/// Reminders disabled (default) — toggle off, time/repeat dimmed.
final StateFixture reminderOffFixture = StateFixture(
  overrides: FakeHarness().overrides,
);
