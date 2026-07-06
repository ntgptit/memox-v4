import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

/// One screen-state's golden fixture (golden-parity WBS). **Data only** — the
/// screen widget lives in the per-screen golden test, not here (keeps fixtures
/// reusable and free of widget imports). Carries:
/// - [overrides]: the COMPLETE provider override list that seeds the state
///   (typically `FakeHarness(...).overrides`);
/// - [drive]: optional interaction to reach an overlay/menu/error after pump;
/// - [contentMask]: rects of intentionally kit-divergent content (greeting name,
///   date, illustrative counts) excluded from the eventual kit↔Flutter diff.
class StateFixture {
  const StateFixture({
    this.overrides = const [],
    this.drive,
    this.contentMask = const [],
  }) : sentinel = null;

  /// Fail-by-default skeleton emitted by `tool/golden/scaffold.mjs`. A golden
  /// built on this throws (see [failIfUnimplemented]), so an un-filled state is
  /// RED, never green. Replace the whole expression with a real [StateFixture].
  const StateFixture.unimplemented(String id)
    : overrides = const [],
      drive = null,
      contentMask = const [],
      sentinel = id;

  final List<Override> overrides;
  final Future<void> Function(WidgetTester tester)? drive;
  final List<Rect> contentMask;

  /// Non-null while this is still an un-filled scaffold stub.
  final String? sentinel;

  bool get isUnimplemented => sentinel != null;

  /// Fails the current test with a clear reminder if this fixture is still a stub.
  /// Called by the golden harness before rendering.
  void failIfUnimplemented() {
    if (sentinel != null) {
      fail(
        'UNIMPLEMENTED golden-parity fixture "$sentinel" — '
        'fill its StateFixture in test/fixtures/ (see docs/agent/golden-parity/WBS.md).',
      );
    }
  }
}
