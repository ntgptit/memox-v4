// drawer · remove-language — golden-parity fixture.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox_v4/core/error/result.dart';
import 'package:memox_v4/data/fakes/fake_services.dart';
import 'package:memox_v4/domain/entities/ids.dart';
import 'package:memox_v4/domain/entities/language_pair.dart';

import '../../harness/provider_harness.dart';
import '../_fixture.dart';

LanguagePair _pair(String id, String learning, String native) =>
    (LanguagePair.create(
              id: LanguagePairId(id),
              learningLanguage: learning,
              nativeLanguage: native,
            )
            as Ok<LanguagePair>)
        .value;

/// Two pairs mirroring the kit's remove-language sample (한국어 → English,
/// 日本語 → English), so the list is populated and the remove-confirm dialog
/// can open over it — matching the kit shot instead of the empty state.
FakeLanguagePairService _seededPairs() {
  final service = FakeLanguagePairService();
  service.add(_pair('lp-ko', '한국어', 'English'));
  service.add(_pair('lp-ja', '日本語', 'English'));
  return service;
}

/// The remove-language screen with the remove-confirm dialog open on the first
/// pair (한국어 → English) — the kit `remove-language` shot.
final StateFixture drawerRemoveLanguageFixture = StateFixture(
  overrides: FakeHarness(languagePairService: _seededPairs()).overrides,
  drive: (tester) async {
    await tester.tap(find.text('Remove language'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.delete).first);
  },
);
