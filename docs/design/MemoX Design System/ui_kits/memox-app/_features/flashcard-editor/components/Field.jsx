/* MemoX — Flashcard-editor local: Field (labeled text field, optional error/trailing). */
(function () {

function Field({ label, value, placeholder, multiline, error, required, node, trailing }) {
  return (
    <div data-mx-node={node} style={{ display: 'flex', flexDirection: 'column', gap: 'var(--memox-space-2)' }}>
      <div style={{ display: 'flex', alignItems: 'center', gap: 'var(--memox-space-1)', fontSize: 'var(--memox-font-size-sm)', fontWeight: 'var(--memox-font-weight-bold)', color: 'var(--memox-text-secondary)' }}>
        {label}{required ? <span style={{ color: 'var(--memox-error)' }}>*</span> : null}
      </div>
      <div style={{ display: 'flex', alignItems: 'flex-start', gap: 'var(--memox-space-2)', minHeight: multiline ? 'var(--memox-size-lg)' : 'var(--memox-touch-min)', padding: 'var(--memox-space-3) var(--memox-space-4)', borderRadius: 'var(--memox-radius-control)', background: 'var(--memox-surface)', border: 'var(--memox-stroke-hairline) solid ' + (error ? 'var(--memox-error)' : 'var(--memox-divider)') }}>
        <span style={{ flex: 1, fontSize: 'var(--memox-font-size-base)', color: value ? 'inherit' : 'var(--memox-text-tertiary)', lineHeight: 'var(--memox-line-height-normal)' }}>{value || placeholder}</span>
        {trailing}
      </div>
      {error ? <div style={{ fontSize: 'var(--memox-font-size-sm)', color: 'var(--memox-error)' }}>{error}</div> : null}
    </div>
  );
}

window.MemoXFlashcardEditor = window.MemoXFlashcardEditor || {};
window.MemoXFlashcardEditor.Field = Field;
})();
