/* MemoX — Reminder local: TimeCol (one scrollable hour/minute column). */
(function () {

function TimeCol({ values, sel }) {
  return (
    <div style={{ flex: 1, maxHeight: 'var(--memox-size-2xl)', overflowY: 'auto', textAlign: 'center' }}>
      {values.map((v) => (
        <div key={v} style={{ padding: 'var(--memox-space-2) 0', fontSize: 'var(--memox-font-size-md)', fontWeight: v === sel ? 'var(--memox-font-weight-extrabold)' : 'var(--memox-font-weight-medium)', color: v === sel ? 'var(--memox-primary)' : 'var(--memox-text-tertiary)' }}>{v}</div>
      ))}
    </div>
  );
}

window.MemoXReminder = window.MemoXReminder || {};
window.MemoXReminder.TimeCol = TimeCol;
})();
