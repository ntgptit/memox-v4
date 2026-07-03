/**
 * Deck-detail deck-level actions bottom sheet.
 *
 * The kit renders this as a **static fixture** (hardcoded Rename / Move / Reset /
 * Delete items) and exposes **no props**. The Flutter `DeckMenu` wires `onMove` /
 * `onDelete` (Rename is an inline text dialog, Reset progress has no v1 use case)
 * — recorded as fixture-parameterized exceptions.
 */
export interface DeckMenuProps {}

export function DeckMenu(): JSX.Element;
