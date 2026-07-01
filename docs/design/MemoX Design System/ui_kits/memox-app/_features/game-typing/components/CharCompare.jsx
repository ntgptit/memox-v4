/* MemoX — Game-typing local: CharCompare (per-character typed-vs-correct diff). */
(function () {

function CharCompare() {
  const typed = ['친', '고'];
  const correct = ['친', '구'];
  return (
    <div style={{ display: 'flex', gap: 'var(--memox-space-2)', justifyContent: 'center' }}>
      {correct.map((c, i) => {
        const ok = typed[i] === c;
        return <span key={i} style={{ fontSize: 'var(--memox-font-size-2xl)', fontWeight: 'var(--memox-font-weight-extrabold)', color: ok ? 'var(--memox-success)' : 'var(--memox-error)' }}>{typed[i] || '_'}</span>;
      })}
    </div>
  );
}

window.MemoXGameTyping = window.MemoXGameTyping || {};
window.MemoXGameTyping.CharCompare = CharCompare;
})();
