/* MemoX — Import cards. States: source · mapping · preview · dup-warning · done */
(function () {
const NS = window.MemoXDesignSystem_2ffa54;
const { MxScaffold, MxAppBar, MxIconButton, MxCard, MxButton, MxChip, MxIconTile } = NS;

const SOURCES = [
  { icon: 'description', name: 'CSV file', desc: 'Import from a .csv file' },
  { icon: 'table_chart', name: 'Excel', desc: 'Import from an .xlsx file' },
  { icon: 'content_paste', name: 'Paste text', desc: 'Copy from somewhere else' },
];
const SEPS = ['Tab', 'Comma', 'Semicolon'];
const ROWS = [['Term', 'Meaning'], ['안녕하세요', 'Hello'], ['감사합니다', 'Thank you'], ['사랑', 'love'], ['학교', 'school']];

function Table({ rows }) {
  return (
    <div style={{ border: '1px solid var(--memox-divider)', borderRadius: 'var(--memox-radius-control)', overflow: 'hidden' }}>
      {rows.map((r, i) => (
        <div key={i} style={{ display: 'flex', gap: 12, padding: '10px 14px', borderTop: i ? '1px solid var(--memox-divider)' : 'none', background: i === 0 ? 'var(--memox-surface-sunken)' : 'transparent', fontSize: 'var(--memox-font-size-sm)' }}>
          <span style={{ flex: 1, fontWeight: 700 }}>{r[0]}</span>
          <span style={{ flex: 1.4, fontWeight: i === 0 ? 700 : 400, color: i === 0 ? 'inherit' : 'var(--memox-text-secondary)' }}>{r[1]}</span>
        </div>
      ))}
    </div>
  );
}

function SectionLabel({ children }) {
  return <div style={{ fontSize: 'var(--memox-font-size-sm)', color: 'var(--memox-text-tertiary)', fontWeight: 700, letterSpacing: '.04em', margin: '4px 0 0 4px' }}>{children}</div>;
}

function Import({ state = 'source' }) {
  const bar = <MxAppBar title="Import cards" node="import/appbar" leading={<MxIconButton icon="arrow_back" node="import/back" />} />;

  if (state === 'done') {
    return (
      <MxScaffold node="import/screen" appBar={bar}>
        <window.EmptyState node="import/done" icon="task_alt" tone="success" title="Imported 124 cards"
          text="The new cards were added to “TOPIK I — Vocabulary”."
          action={<MxButton variant="primary" icon="arrow_forward" node="import/go-deck">Back to deck</MxButton>} />
      </MxScaffold>
    );
  }

  if (state === 'source') {
    return (
      <MxScaffold node="import/screen" appBar={bar}>
        <SectionLabel>CHOOSE SOURCE</SectionLabel>
        {SOURCES.map((s, i) => (
          <MxCard key={i} interactive padding="sm" node={'import/source-' + i}>
            <div style={{ display: 'flex', alignItems: 'center', gap: 'var(--memox-space-4)' }}>
              <MxIconTile icon={s.icon} tone={i === 2 ? 'accent' : null} />
              <div style={{ flex: 1, minWidth: 0 }}>
                <div style={{ fontWeight: 700, fontSize: 'var(--memox-font-size-base)' }}>{s.name}</div>
                <div style={{ fontSize: 'var(--memox-font-size-sm)', color: 'var(--memox-text-secondary)', marginTop: 2 }}>{s.desc}</div>
              </div>
              <span className="material-symbols-rounded" style={{ color: 'var(--memox-text-tertiary)' }}>chevron_right</span>
            </div>
          </MxCard>
        ))}
        <div data-mx-node="import/paste" style={{ border: '1px dashed var(--memox-divider)', borderRadius: 'var(--memox-radius-control)', minHeight: 96, padding: '14px', color: 'var(--memox-text-tertiary)', fontSize: 'var(--memox-font-size-base)' }}>Paste your data here (one card per line: term[tab]meaning)…</div>
      </MxScaffold>
    );
  }

  if (state === 'mapping') {
    return (
      <MxScaffold node="import/screen" appBar={bar}>
        <SectionLabel>SEPARATOR</SectionLabel>
        <div style={{ display: 'flex', gap: 'var(--memox-space-2)' }}>
          {SEPS.map((s, i) => <MxChip key={s} label={s} selected={i === 0} node={'import/sep-' + i} />)}
        </div>
        <SectionLabel>COLUMN MAPPING</SectionLabel>
        <MxCard padding="sm">
          <window.ListRow icon="text_fields" title="Column A → Term" sub="안녕하세요, 감사합니다…" node="import/map-term"
            trailing={<MxIconButton icon="expand_more" size="sm" node="import/map-term-pick" />} />
          <window.ListRow icon="translate" title="Column B → Meaning" sub="Hello, Thank you…" last node="import/map-meaning"
            trailing={<MxIconButton icon="expand_more" size="sm" node="import/map-meaning-pick" />} />
        </MxCard>
        <Table rows={ROWS} />
        <MxButton variant="primary" block node="import/to-preview">Continue</MxButton>
      </MxScaffold>
    );
  }

  // preview / dup-warning
  return (
    <MxScaffold node="import/screen" appBar={bar}>
      {state === 'dup-warning' ? (
        <div data-mx-node="import/dup-warning" style={{ background: 'var(--memox-warning-soft)', color: 'var(--memox-on-warning-soft)', borderRadius: 'var(--memox-radius-control)', padding: '12px 14px', display: 'flex', alignItems: 'center', gap: 10 }}>
          <span className="material-symbols-rounded">warning</span>
          <span style={{ flex: 1, fontSize: 'var(--memox-font-size-sm)' }}>8 cards already exist — import anyway?</span>
        </div>
      ) : null}
      <SectionLabel>PREVIEW · 124 CARDS</SectionLabel>
      <Table rows={ROWS} />
      <MxButton variant="primary" icon="download" block node="import/do-import">Import 124 cards</MxButton>
    </MxScaffold>
  );
}

window.Import = Import;
})();
