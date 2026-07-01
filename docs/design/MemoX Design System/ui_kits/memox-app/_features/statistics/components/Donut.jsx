/* MemoX — Statistics local: Donut (accuracy ring). */
(function () {

function Donut({ pct }) {
  return (
    <div style={{ display: 'flex', justifyContent: 'center', padding: 'var(--memox-space-1) 0' }}>
      <window.Ring pct={pct} size="var(--memox-size-2xl)" tone="var(--memox-success)" inset="var(--memox-space-4)">
        <div style={{ fontSize: 'var(--memox-font-size-xl)', fontWeight: 'var(--memox-font-weight-extrabold)' }}>{pct}%</div>
        <div style={{ fontSize: 'var(--memox-font-size-sm)', color: 'var(--memox-text-secondary)' }}>accuracy</div>
      </window.Ring>
    </div>
  );
}

window.MemoXStatistics = window.MemoXStatistics || {};
window.MemoXStatistics.Donut = Donut;
})();
