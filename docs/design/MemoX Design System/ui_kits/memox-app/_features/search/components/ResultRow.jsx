/* MemoX — Search local: ResultRow (term + meaning + deck + status badge). */
(function () {
const NS = window.MemoXDesignSystem_2ffa54;
const { MxBadge } = NS;

const STATUS = {
  new: { label: 'New', tone: undefined },
  due: { label: 'Due', tone: 'error' },
  mastered: { label: 'Mastered', tone: 'success' },
};

function ResultRow({ term, meaning, deck, status, hidden, node }) {
  const s = STATUS[status];
  return (
    <div data-mx-node={node} style={{ display: 'flex', alignItems: 'center', gap: 'var(--memox-space-4)', opacity: hidden ? .5 : 1 }}>
      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 'var(--memox-space-2)' }}>
          <span style={{ fontWeight: 'var(--memox-font-weight-extrabold)', fontSize: 'var(--memox-font-size-md)' }}>{term}</span>
          {hidden ? <span className="material-symbols-rounded" style={{ fontSize: 'var(--memox-font-size-base)', color: 'var(--memox-text-tertiary)' }}>visibility_off</span> : null}
        </div>
        <div style={{ fontSize: 'var(--memox-font-size-sm)', color: 'var(--memox-text-secondary)', marginTop: 'var(--memox-space-1)' }}>{meaning}</div>
        <div style={{ fontSize: 'var(--memox-font-size-sm)', color: 'var(--memox-text-tertiary)', marginTop: 'var(--memox-space-1)' }}>{deck}</div>
      </div>
      <MxBadge tone={s.tone} soft>{s.label}</MxBadge>
    </div>
  );
}

window.MemoXSearch = window.MemoXSearch || {};
window.MemoXSearch.ResultRow = ResultRow;
})();
