/* MemoX — Statistics local: Bars (simple vertical bar chart). Used by weekly + Leitner. */
(function () {

function Bars({ data, labels, tone }) {
  const max = Math.max.apply(null, data);
  return (
    <div style={{ display: 'flex', alignItems: 'flex-end', gap: 'var(--memox-space-2)', height: 'var(--memox-size-2xl)' }}>
      {data.map((v, i) => (
        <div key={i} style={{ flex: 1, display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 'var(--memox-space-1)', height: '100%', justifyContent: 'flex-end' }}>
          <div style={{ width: '100%', height: (v / max * 100) + '%', background: tone || 'var(--memox-primary)', borderRadius: 'var(--memox-radius-xs)', minHeight: 'var(--memox-size-3xs)' }} />
          <span style={{ fontSize: 'var(--memox-font-size-xs)', color: 'var(--memox-text-tertiary)' }}>{labels[i]}</span>
        </div>
      ))}
    </div>
  );
}

window.MemoXStatistics = window.MemoXStatistics || {};
window.MemoXStatistics.Bars = Bars;
})();
