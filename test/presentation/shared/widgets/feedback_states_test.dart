import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox_v4/core/theme/app_theme.dart';
import 'package:memox_v4/presentation/shared/widgets/display/mx_text.dart';
import 'package:memox_v4/presentation/shared/widgets/feedback/mx_snackbar.dart';
import 'package:memox_v4/presentation/shared/widgets/states/mx_state_view.dart';

Widget _wrap(Widget child) => MaterialApp(
  theme: AppTheme.light(),
  home: Scaffold(body: child),
);

void main() {
  testWidgets('MxText renders for a role', (tester) async {
    await tester.pumpWidget(_wrap(const MxText.title('Hello')));
    expect(find.text('Hello'), findsOneWidget);
  });

  testWidgets('MxStateView.loading shows a spinner', (tester) async {
    await tester.pumpWidget(
      _wrap(const MxStateView.loading(message: 'Loading')),
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Loading'), findsOneWidget);
  });

  testWidgets('MxStateView.empty shows title + message', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const MxStateView.empty(
          icon: Icons.inbox,
          title: 'Nothing here',
          message: 'Add your first deck',
        ),
      ),
    );
    expect(find.text('Nothing here'), findsOneWidget);
    expect(find.text('Add your first deck'), findsOneWidget);
    expect(find.byIcon(Icons.inbox), findsOneWidget);
  });

  testWidgets('MxStateView.error fires its action', (tester) async {
    var retried = false;
    await tester.pumpWidget(
      _wrap(
        MxStateView.error(
          title: 'Failed',
          actionLabel: 'Retry',
          onAction: () => retried = true,
        ),
      ),
    );
    await tester.tap(find.text('Retry'));
    expect(retried, isTrue);
  });

  testWidgets('MxSnackbar.show displays the message', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => MxSnackbar.show(
                context,
                'Saved',
                tone: MxSnackbarTone.success,
              ),
              child: const Text('go'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('go'));
    await tester.pump();
    expect(find.text('Saved'), findsOneWidget);
  });
}
