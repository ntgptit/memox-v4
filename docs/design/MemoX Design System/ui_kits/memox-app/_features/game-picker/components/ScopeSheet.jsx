/* MemoX — Game-picker local: ScopeSheet (card-source dropdown bottom sheet). */
(function () {

function ScopeSheet() {
  const opts = [
    { icon: 'schedule', label: 'By schedule', sel: true, id: 'srs' },
    { icon: 'apps', label: 'All cards', sel: false, id: 'all' },
    { icon: 'hourglass_empty', label: 'Unlearned only', sel: false, id: 'unlearned' },
  ];
  return (
    <window.Scrim node="game-picker/scope-scrim">
      <window.Sheet title="Card source" node="game-picker/scope-sheet">
        {opts.map((o) => (
          <window.MenuItem key={o.id} icon={o.icon} label={o.label} node={'game-picker/scope-' + o.id}
            trailing={o.sel ? <span className="material-symbols-rounded" style={{ color: 'var(--memox-primary)' }}>check</span> : null} />
        ))}
      </window.Sheet>
    </window.Scrim>
  );
}

window.MemoXGamePicker = window.MemoXGamePicker || {};
window.MemoXGamePicker.ScopeSheet = ScopeSheet;
})();
