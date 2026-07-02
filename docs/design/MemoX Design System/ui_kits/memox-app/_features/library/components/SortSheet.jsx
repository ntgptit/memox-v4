/* MemoX — Library local: SortSheet (sort-by bottom sheet). */
(function () {

function SortSheet() {
  const opts = [
    ['sort_by_alpha', 'Alphabetical A → Z', true], ['sort_by_alpha', 'Alphabetical Z → A', false],
    ['schedule', 'Date created (newest)', false], ['history', 'Last studied', false],
  ];
  return (
    <window.Sheet title="Sort by" node="library/sort-sheet">
      {opts.map((o, i) => (
        <window.MenuItem key={i} icon={o[0]} label={o[1]} node={'library/sort-' + i}
          trailing={o[2] ? <span className="material-symbols-rounded" style={{ color: 'var(--memox-primary)' }}>check</span> : null} />
      ))}
    </window.Sheet>
  );
}

window.MemoXLibrary = window.MemoXLibrary || {};
window.MemoXLibrary.SortSheet = SortSheet;
})();
