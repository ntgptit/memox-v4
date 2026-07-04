import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:memox_v4/presentation/features/import/providers/import_providers.dart';

void main() {
  test('the column picker remaps which column is term / meaning', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final ctrl = container.read(importControllerProvider.notifier);

    // A 3-column, tab-separated paste (the default separator).
    ctrl.setInput('학교\tschool\tnoun\n친구\tfriend\tnoun');
    expect(ctrl.columnCount(), 3);

    // Default mapping: column A → term, column B → meaning.
    var preview = ctrl.parseCurrent();
    expect(preview.drafts.first.term, '학교');
    expect(preview.drafts.first.meaning, 'school');

    // Repick: column B → term, column A → meaning (swap).
    ctrl.setTermColumn(1);
    ctrl.setMeaningColumn(0);
    preview = ctrl.parseCurrent();
    expect(preview.drafts.first.term, 'school');
    expect(preview.drafts.first.meaning, '학교');

    // Repick term to the third column.
    ctrl.setTermColumn(2);
    preview = ctrl.parseCurrent();
    expect(preview.drafts.first.term, 'noun');
  });

  test('columnSample previews a column\'s values (skipping the header)', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final ctrl = container.read(importControllerProvider.notifier);

    ctrl.setInput('term\tmeaning\n학교\tschool\n친구\tfriend');

    // No header → the first row counts as data (capped at 2 samples).
    expect(ctrl.columnSample(0), 'term, 학교');

    // With a header → the header row is skipped in the preview.
    ctrl.setHasHeader(true);
    expect(ctrl.columnSample(0), '학교, 친구');
    expect(ctrl.columnSample(1), 'school, friend');
  });
}
