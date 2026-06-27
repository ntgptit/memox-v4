/* MemoX — Export cards. States: config · exporting · done */
(function () {
const NS = window.MemoXDesignSystem_2ffa54;
const { MxScaffold, MxAppBar, MxIconButton, MxCard, MxButton, MxChip, MxSegmentedControl, MxSwitch } = NS;

const FORMATS = [
  { icon: 'description', name: 'CSV', sub: '.csv file', id: 'csv' },
  { icon: 'table_chart', name: 'Excel', sub: '.xlsx file', id: 'xlsx' },
  { icon: 'content_copy', name: 'Copy text', sub: 'To clipboard', id: 'copy' },
];
const SEPS = ['Tab', 'Comma', 'Semicolon'];

function SectionLabel({ children }) {
  return <div style={{ fontSize: 'var(--memox-font-size-sm)', color: 'var(--memox-text-tertiary)', fontWeight: 'var(--memox-font-weight-bold)', letterSpacing: 'var(--memox-letter-spacing-wide)', margin: 'var(--memox-space-1) 0 0 var(--memox-space-1)' }}>{children}</div>;
}

function Export({ state = 'config' }) {
  const [incl, setIncl] = React.useState(true);
  const bar = <MxAppBar title="Export cards" node="export/appbar" leading={<MxIconButton icon="arrow_back" node="export/back" />} />;

  if (state === 'exporting') {
    return (
      <MxScaffold node="export/screen" appBar={bar}>
        <MxCard node="export/progress" style={{ alignItems: 'center', gap: 'var(--memox-space-4)', padding: 'var(--memox-space-7)' }}>
          <span className="material-symbols-rounded" style={{ fontSize: 'var(--memox-font-size-3xl)', color: 'var(--memox-primary)' }}>sync</span>
          <div style={{ fontWeight: 'var(--memox-font-weight-bold)' }}>Exporting…</div>
          <div style={{ width: '100%' }}><window.ProgressBar value={70} height={8} node="export/bar" /></div>
        </MxCard>
      </MxScaffold>
    );
  }

  if (state === 'done') {
    return (
      <MxScaffold node="export/screen" appBar={bar}>
        <window.EmptyState node="export/done" icon="ios_share" tone="success" title="Exported 320 cards"
          text="Your file is ready to share or save."
          action={<div style={{ display: 'flex', flexDirection: 'column', gap: 'var(--memox-space-3)', width: 'var(--memox-size-3xl)' }}>
            <MxButton variant="primary" icon="share" block node="export/share">Share file</MxButton>
            <MxButton variant="ghost" icon="save_alt" block node="export/save">Save to device</MxButton>
          </div>} />
      </MxScaffold>
    );
  }

  return (
    <MxScaffold node="export/screen" appBar={bar}>
      <SectionLabel>SCOPE</SectionLabel>
      <MxSegmentedControl value="deck" onChange={() => {}} block node="export/scope"
        segments={[{ value: 'deck', label: 'This deck' }, { value: 'subtree', label: 'Incl. sub-decks' }]} />

      <SectionLabel>FORMAT</SectionLabel>
      <MxCard padding="sm">
        {FORMATS.map((f, i) => (
          <window.ListRow key={f.id} icon={f.icon} title={f.name} sub={f.sub} last={i === FORMATS.length - 1} node={'export/format-' + f.id}
            trailing={<span className="material-symbols-rounded" style={{ color: i === 0 ? 'var(--memox-primary)' : 'var(--memox-text-tertiary)' }}>{i === 0 ? 'radio_button_checked' : 'radio_button_unchecked'}</span>} />
        ))}
      </MxCard>

      <SectionLabel>SEPARATOR</SectionLabel>
      <div style={{ display: 'flex', gap: 'var(--memox-space-2)' }}>
        {SEPS.map((s, i) => <MxChip key={s} label={s} selected={i === 0} node={'export/sep-' + i} />)}
      </div>

      <MxCard padding="sm">
        <window.ListRow icon="schedule" tone="success" title="Include review state" sub="Leitner box + due date" last node="export/incl-srs"
          trailing={<MxSwitch checked={incl} onChange={setIncl} node="export/incl-srs-switch" />} />
      </MxCard>

      <MxButton variant="primary" icon="download" block node="export/do-export">Export</MxButton>
    </MxScaffold>
  );
}

window.Export = Export;
})();
