/**
 * Deck-detail app bar (shared by every state): back + title + play-audio + menu.
 *
 * The kit renders this as a **static fixture** (hardcoded title + node ids) and
 * exposes **no props**. The Flutter `DeckHeader` parameterizes `title` and wires
 * `onBack` / `onMenu` (the deck-level play-audio action is intentionally omitted
 * in v1) — recorded as fixture-parameterized exceptions.
 */
export interface DeckHeaderProps {}

export function DeckHeader(): JSX.Element;
