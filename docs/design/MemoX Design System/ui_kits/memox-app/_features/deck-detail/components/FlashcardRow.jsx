/* MemoX — Deck-detail local: FlashcardRow (term + meaning + status badge).
   Composes the shared window.StatusCardRow (_shared/StatusCardRow.jsx); deck-detail
   tightens the term + ellipsis-clips the meaning. */
(function () {

function FlashcardRow(props) {
  return <window.StatusCardRow {...props} tightTerm truncateMeaning />;
}

window.MemoXDeckDetail = window.MemoXDeckDetail || {};
window.MemoXDeckDetail.FlashcardRow = FlashcardRow;
})();
