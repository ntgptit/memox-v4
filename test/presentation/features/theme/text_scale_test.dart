import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:memox_v4/data/fakes/fake_services.dart';
import 'package:memox_v4/data/providers/data_providers.dart';
import 'package:memox_v4/domain/entities/theme_settings.dart';
import 'package:memox_v4/presentation/features/theme/providers/theme_providers.dart';

void main() {
  test('FontScale.factor orders small < medium (1.0) < large', () {
    expect(FontScale.small.factor, lessThan(FontScale.medium.factor));
    expect(FontScale.medium.factor, lessThan(FontScale.large.factor));
    expect(FontScale.medium.factor, fontScaleMediumFactor);
    expect(FontScale.medium.factor, 1.0);
  });

  test('textScaleFactor reflects the saved font scale', () async {
    final settings = FakeSettingsService();
    await settings.saveTheme(const ThemeSettings(fontScale: FontScale.large));

    final container = ProviderContainer(
      overrides: [settingsServiceProvider.overrideWithValue(settings)],
    );
    addTearDown(container.dispose);
    final sub = container.listen(textScaleFactorProvider, (_, _) {});
    addTearDown(sub.close);

    final factor = await container.read(textScaleFactorProvider.future);
    expect(factor, fontScaleLargeFactor);
    expect(factor, greaterThan(1.0));
  });
}
