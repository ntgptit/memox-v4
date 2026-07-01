/* MemoX — Deck-detail local: SubDeckCard (one sub-deck node in the SUB-DECKS list). */
(function () {
const NS = window.MemoXDesignSystem_2ffa54;
const { MxCard } = NS;

function SubDeckCard({ deck, index }) {
  return (
    <MxCard padding="sm" interactive node={'deck-detail/subdeck-' + index}><window.DeckRow {...deck} /></MxCard>
  );
}

window.MemoXDeckDetail = window.MemoXDeckDetail || {};
window.MemoXDeckDetail.SubDeckCard = SubDeckCard;
})();
