/* MemoX — Search local: ResultRow (term + meaning + deck + status badge).
   Composes the shared window.StatusCardRow (_shared/StatusCardRow.jsx); search adds
   the `deck` line and keeps the default (untightened, non-clipped) term/meaning. */
(function () {

function ResultRow(props) {
  return <window.StatusCardRow {...props} />;
}

window.MemoXSearch = window.MemoXSearch || {};
window.MemoXSearch.ResultRow = ResultRow;
})();
