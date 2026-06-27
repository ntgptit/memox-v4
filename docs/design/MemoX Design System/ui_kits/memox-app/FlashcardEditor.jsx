/* MemoX — Flashcard editor. States: create · edit · validation · duplicate · multi-meaning · audio */
(function () {
const NS = window.MemoXDesignSystem_2ffa54;
const { MxScaffold, MxAppBar, MxCard, MxButton, MxIconButton, MxChip, MxSwitch } = NS;

function Field({ label, value, placeholder, multiline, error, required, node, trailing }) {
  return (
    <div data-mx-node={node} style={{ display: 'flex', flexDirection: 'column', gap: 6 }}>
      <div style={{ display: 'flex', alignItems: 'center', gap: 4, fontSize: 'var(--memox-font-size-sm)', fontWeight: 700, color: 'var(--memox-text-secondary)' }}>
        {label}{required ? <span style={{ color: 'var(--memox-error)' }}>*</span> : null}
      </div>
      <div style={{ display: 'flex', alignItems: 'flex-start', gap: 8, minHeight: multiline ? 80 : 48, padding: '12px 14px', borderRadius: 'var(--memox-radius-control)', background: 'var(--memox-surface)', border: '1px solid ' + (error ? 'var(--memox-error)' : 'var(--memox-divider)') }}>
        <span style={{ flex: 1, fontSize: 'var(--memox-font-size-base)', color: value ? 'inherit' : 'var(--memox-text-tertiary)', lineHeight: 1.5 }}>{value || placeholder}</span>
        {trailing}
      </div>
      {error ? <div style={{ fontSize: 'var(--memox-font-size-sm)', color: 'var(--memox-error)' }}>{error}</div> : null}
    </div>
  );
}

function DupBanner() {
  return (
    <div data-mx-node="flashcard-editor/dup-warning" style={{ background: 'var(--memox-warning-soft)', color: 'var(--memox-on-warning-soft)', borderRadius: 'var(--memox-radius-control)', padding: '12px 14px', display: 'flex', flexDirection: 'column', gap: 10 }}>
      <div style={{ display: 'flex', gap: 8, alignItems: 'flex-start' }}>
        <span className="material-symbols-rounded" style={{ fontSize: 20 }}>warning</span>
        <span style={{ flex: 1, fontSize: 'var(--memox-font-size-sm)', lineHeight: 1.5 }}>A card “안녕하세요” already exists in this deck.</span>
      </div>
      <div style={{ display: 'flex', gap: 8 }}>
        <MxButton variant="ghost" size="sm" node="flashcard-editor/dup-view">View existing</MxButton>
        <MxButton variant="primary" size="sm" node="flashcard-editor/dup-add">Add anyway</MxButton>
      </div>
    </div>
  );
}

function FlashcardEditor({ state = 'create' }) {
  const [hidden, setHidden] = React.useState(false);
  const blank = state === 'create' || state === 'validation';
  const title = state === 'create' ? 'New card' : 'Edit card';
  const termErr = state === 'validation' ? 'Term is required' : null;
  const meaningErr = state === 'validation' ? 'Meaning is required' : null;

  const bar = (
    <MxAppBar node="flashcard-editor/appbar" title={title}
      leading={<MxButton variant="ghost" node="flashcard-editor/cancel">Cancel</MxButton>}
      trailing={<MxButton variant="primary" size="sm" disabled={state === 'create'} node="flashcard-editor/save">Save</MxButton>} />
  );

  return (
    <MxScaffold node="flashcard-editor/screen" appBar={bar}>
      {state === 'duplicate' ? <DupBanner /> : null}

      <Field label="Term (Korean)" required node="flashcard-editor/term"
        value={blank ? '' : '안녕하세요'} placeholder="Enter a word…" error={termErr} />

      <Field label="Meaning (English)" required multiline node="flashcard-editor/meaning"
        value={blank ? '' : 'Hello (formal); used when greeting elders'}
        placeholder="Enter the meaning, with examples or notes…" error={meaningErr} />

      {state === 'multi-meaning'
        ? <Field label="Secondary meaning (Vietnamese)" node="flashcard-editor/meaning-2" value="xin chào" placeholder="Enter a secondary meaning…" />
        : <MxButton variant="ghost" icon="add" block node="flashcard-editor/add-meaning">Add a secondary-language meaning</MxButton>}

      <div data-mx-node="flashcard-editor/gender" style={{ display: 'flex', flexDirection: 'column', gap: 6 }}>
        <div style={{ fontSize: 'var(--memox-font-size-sm)', fontWeight: 700, color: 'var(--memox-text-secondary)' }}>Gender (optional)</div>
        <div style={{ display: 'flex', gap: 8, flexWrap: 'wrap' }}>
          {['None', 'Masc', 'Fem', 'Neutral'].map((g, i) => <MxChip key={g} label={g} selected={i === 0} node={'flashcard-editor/gender-' + i} />)}
        </div>
      </div>

      <Field label="Audio" node="flashcard-editor/audio"
        value={state === 'audio' ? 'Generating from term…' : 'Auto from term'}
        trailing={<MxIconButton icon={state === 'audio' ? 'sync' : 'volume_up'} node="flashcard-editor/audio-play" />} />

      <MxCard padding="sm">
        <window.ListRow icon="visibility_off" title="Hide card" sub="Won't show during study / review" last node="flashcard-editor/hidden"
          trailing={<MxSwitch checked={hidden} onChange={setHidden} node="flashcard-editor/hidden-switch" />} />
      </MxCard>
    </MxScaffold>
  );
}

window.FlashcardEditor = FlashcardEditor;
})();
