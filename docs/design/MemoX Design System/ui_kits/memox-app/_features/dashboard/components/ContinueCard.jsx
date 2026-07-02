/* MemoX — Dashboard local: ContinueCard (one due-deck row in "Continue studying"). */
(function () {
const NS = window.MemoXDesignSystem_2ffa54;
const { MxCard } = NS;

function ContinueCard({ deck, index }) {
  return (
    <MxCard padding="sm" interactive node={'dashboard/deck-' + index}><window.DeckRow {...deck} /></MxCard>
  );
}

window.MemoXDashboard = window.MemoXDashboard || {};
window.MemoXDashboard.ContinueCard = ContinueCard;
})();
