/* MemoX — Player local: Dots (8-dot deck progress indicator). */
(function () {

function Dots() {
  return (
    <div data-mx-node="player/progress" style={{ display: 'flex', gap: 'var(--memox-space-2)', justifyContent: 'center' }}>
      {Array.from({ length: 8 }).map((_, i) => (
        <div key={i} style={{ width: i === 3 ? 'var(--memox-size-xs)' : 'var(--memox-size-2xs)', height: 'var(--memox-size-2xs)', borderRadius: 'var(--memox-radius-pill)', background: i <= 3 ? 'var(--memox-primary)' : 'var(--memox-surface-sunken)' }} />
      ))}
    </div>
  );
}

window.MemoXPlayer = window.MemoXPlayer || {};
window.MemoXPlayer.Dots = Dots;
})();
