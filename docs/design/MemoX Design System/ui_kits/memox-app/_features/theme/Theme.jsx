/* MemoX — Theme. States: light · dark · accent-size */
(function () {
const NS = window.MemoXDesignSystem_2ffa54;
const { MxScaffold, MxAppBar, MxIconButton, MxCard, MxSegmentedControl, MxSectionHeader } = NS;

// Presentational palette samples for the accent picker.
const SWATCHES = ['var(--memox-palette-indigo)', 'var(--memox-palette-violet)', 'var(--memox-palette-green)', 'var(--memox-palette-coral)', 'var(--memox-palette-amber)', 'var(--memox-palette-cyan)'];

function Theme({ state = 'light' }) {
  const mode = state === 'dark' ? 'dark' : 'light';
  const size = state === 'accent-size' ? 'lg' : 'md';
  const accent = state === 'accent-size' ? 1 : 0;
  const accentColor = SWATCHES[accent];
  const termSize = size === 'lg' ? 'var(--memox-font-size-3xl)' : size === 'sm' ? 'var(--memox-font-size-xl)' : 'var(--memox-font-size-2xl)';

  const bar = <MxAppBar title="Theme" node="theme/appbar" leading={<MxIconButton icon="arrow_back" node="theme/back" />} />;

  return (
    <MxScaffold node="theme/screen" appBar={bar}>
      <MxCard node="theme/preview" style={{ gap: 'var(--memox-space-3)' }}>
        <div style={{ fontSize: 'var(--memox-font-size-sm)', color: 'var(--memox-text-tertiary)', fontWeight: 'var(--memox-font-weight-bold)', letterSpacing: 'var(--memox-letter-spacing-wide)' }}>PREVIEW</div>
        <div style={{ borderRadius: 'var(--memox-radius-control)', border: 'var(--memox-stroke-hairline) solid var(--memox-divider)', padding: 'var(--memox-space-5)', textAlign: 'center' }}>
          <div style={{ fontSize: termSize, fontWeight: 'var(--memox-font-weight-extrabold)', letterSpacing: 'var(--memox-letter-spacing-tight)' }}>학교</div>
          <div style={{ fontSize: 'var(--memox-font-size-base)', color: 'var(--memox-text-secondary)', marginTop: 'var(--memox-space-1)' }}>school</div>
          <div style={{ marginTop: 'var(--memox-space-4)', display: 'inline-block', padding: 'var(--memox-space-2) var(--memox-space-5)', borderRadius: 'var(--memox-radius-pill)', background: accentColor, color: 'var(--memox-on-primary)', fontWeight: 'var(--memox-font-weight-bold)', fontSize: 'var(--memox-font-size-sm)' }}>Study now</div>
        </div>
      </MxCard>

      <div data-mx-node="theme/mode">
        <MxSectionHeader title="Color mode" node="theme/mode-head" />
        <MxSegmentedControl value={mode} onChange={() => {}} block node="theme/mode-control"
          segments={[{ value: 'light', label: 'Light' }, { value: 'dark', label: 'Dark' }, { value: 'system', label: 'System' }]} />
      </div>

      <div data-mx-node="theme/accent">
        <MxSectionHeader title="Accent color" node="theme/accent-head" />
        <MxCard>
          <div style={{ display: 'flex', gap: 'var(--memox-space-4)', flexWrap: 'wrap', justifyContent: 'center' }}>
            {SWATCHES.map((c, i) => (
              <button key={c} data-mx-node={'theme/accent-' + i} style={{ width: 'var(--memox-size-sm)', height: 'var(--memox-size-sm)', borderRadius: '50%', background: c, border: 'none', boxShadow: i === accent ? '0 0 0 var(--memox-stroke-focus) ' + c : '0 0 0 var(--memox-stroke-hairline) var(--memox-divider)', cursor: 'pointer', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                {i === accent ? <span className="material-symbols-rounded" style={{ color: 'var(--memox-on-primary)', fontSize: 'var(--memox-icon-size-md)' }}>check</span> : null}
              </button>
            ))}
          </div>
        </MxCard>
      </div>

      <div data-mx-node="theme/size">
        <MxSectionHeader title="Text size" node="theme/size-head" />
        <MxSegmentedControl value={size} onChange={() => {}} block node="theme/size-control"
          segments={[{ value: 'sm', label: 'Small' }, { value: 'md', label: 'Medium' }, { value: 'lg', label: 'Large' }]} />
      </div>
    </MxScaffold>
  );
}

window.Theme = Theme;
})();
