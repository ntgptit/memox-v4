/* MemoX — Settings local: ValuePickerSheet (words-per-round picker bottom sheet). */
(function () {

function ValuePickerSheet() {
  return (
    <window.Scrim node="settings/picker-scrim">
      <window.Sheet title="Words per round" node="settings/picker-sheet">
        {['5', '10', '20'].map((v, i) => (
          <window.MenuItem key={v} icon={i === 0 ? 'check' : 'circle'} label={v + ' words'} node={'settings/words-' + v}
            trailing={i === 0 ? <span className="material-symbols-rounded" style={{ color: 'var(--memox-primary)' }}>check</span> : null} />
        ))}
      </window.Sheet>
    </window.Scrim>
  );
}

window.MemoXSettings = window.MemoXSettings || {};
window.MemoXSettings.ValuePickerSheet = ValuePickerSheet;
})();
