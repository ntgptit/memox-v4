import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox_v4/core/theme/app_theme.dart';
import 'package:memox_v4/domain/models/game_card.dart';
import 'package:memox_v4/l10n/generated/app_localizations.dart';
import 'package:memox_v4/presentation/features/game/round.dart';
import 'package:memox_v4/presentation/features/game/widgets/multiple_choice_game.dart';
import 'package:memox_v4/presentation/features/game/widgets/recall_game.dart';

class _FakeActions implements RoundActions {
  int? corrected;
  int? wronged;

  @override
  void markCorrect(int cardId) => corrected = cardId;

  @override
  void markWrong(int cardId, {bool requeue = true}) => wronged = cardId;

  @override
  void clearWrong() {}
}

const _round = RoundState(
  cards: <GameCard>[
    GameCard(cardId: 1, term: 'xin', meaning: 'please'),
    GameCard(cardId: 2, term: 'cảm ơn', meaning: 'thanks'),
  ],
  pending: <int>[1, 2],
);

Widget _host(Widget child) => MaterialApp(
  theme: AppTheme.light(),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(body: child),
);

void main() {
  testWidgets('a game widget grades through RoundActions (decoupled from the '
      'game notifier — same widget can drive NewLearn)', (tester) async {
    final fake = _FakeActions();
    await tester.pumpWidget(
      _host(MultipleChoiceGame(round: _round, actions: fake)),
    );

    await tester.tap(find.byKey(const Key('mcCorrect')));
    await tester.pump();
    expect(fake.corrected, 1);
  });

  testWidgets('recall reveals then grades via RoundActions', (tester) async {
    final fake = _FakeActions();
    await tester.pumpWidget(_host(RecallGame(round: _round, actions: fake)));

    await tester.tap(find.byKey(const ValueKey('mx-node:game-recall/reveal')));
    await tester.pump();
    await tester.tap(
      find.byKey(const ValueKey('mx-node:game-recall/remembered')),
    );
    await tester.pump();
    expect(fake.corrected, 1);
  });
}
