/* MemoX — Library local: SortSheet (sort-by bottom sheet). */
(function () {

function SortSheet() {
  const opts = [
    ['sort_by_alpha', 'Alphabetical A → Z', true], ['sort_by_alpha', 'Alphabetical Z → A', false],
    ['schedule', 'Date created (newest)', false], ['history', 'Last studied', false],
  ];
  return (
    <window.SelectSheet title="Sort by" node="library/sort-sheet"
      options={opts.map((o, i) => ({ key: i, icon: o[0], label: o[1], node: 'library/sort-' + i, selected: o[2] }))} />
  );
}

window.MemoXLibrary = window.MemoXLibrary || {};
window.MemoXLibrary.SortSheet = SortSheet;
})();
