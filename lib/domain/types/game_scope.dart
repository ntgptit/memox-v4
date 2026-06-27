/// Which cards a game round draws from (`docs/business/game/game-modes.md` BR-5):
/// `spaced` prioritises due + new, `all` uses every visible card, `notMastered`
/// excludes box-8 cards.
enum GameScope { spaced, all, notMastered }
