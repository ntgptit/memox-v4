/* MemoX — Theme (Chủ đề). States: light · dark · accent-size */
(function () {
const NS = window.MemoXDesignSystem_2ffa54;
const { MxScaffold, MxAppBar, MxIconButton, MxCard, MxSegmentedControl, MxSectionHeader } = NS;

// Presentational palette samples for the accent picker.
const SWATCHES = ['#5569ff', '#7c5cff', '#2bb673', '#ff6b6b', '#ff9f43', '#22a3c3'];

function Theme({ state = 'light' }) {
  const mode = state === 'dark' ? 'dark' : 'light';
  const size = state === 'accent-size' ? 'lg' : 'md';
  const accent = state === 'accent-size' ? 1 : 0;
  const accentColor = SWATCHES[accent];
  const termSize = size === 'lg' ? 42 : size === 'sm' ? 26 : 34;

  const bar = <MxAppBar title="Chủ đề" node="theme/appbar" leading={<MxIconButton icon="arrow_back" node="theme/back" />} />;

  return (
    <MxScaffold node="theme/screen" appBar={bar}>
      <MxCard node="theme/preview" style={{ gap: 'var(--memox-space-3)' }}>
        <div style={{ fontSize: 'var(--memox-font-size-sm)', color: 'var(--memox-text-tertiary)', fontWeight: 700, letterSpacing: '.04em' }}>XEM TRƯỚC</div>
        <div style={{ borderRadius: 'var(--memox-radius-control)', border: '1px solid var(--memox-divider)', padding: 'var(--memox-space-5)', textAlign: 'center' }}>
          <div style={{ fontSize: termSize, fontWeight: 800, letterSpacing: '-.02em' }}>학교</div>
          <div style={{ fontSize: 'var(--memox-font-size-base)', color: 'var(--memox-text-secondary)', marginTop: 4 }}>trường học</div>
          <div style={{ marginTop: 14, display: 'inline-block', padding: '8px 18px', borderRadius: 999, background: accentColor, color: '#fff', fontWeight: 700, fontSize: 14 }}>Học ngay</div>
        </div>
      </MxCard>

      <div data-mx-node="theme/mode">
        <MxSectionHeader title="Chế độ màu" node="theme/mode-head" />
        <MxSegmentedControl value={mode} onChange={() => {}} block node="theme/mode-control"
          segments={[{ value: 'light', label: 'Sáng' }, { value: 'dark', label: 'Tối' }, { value: 'system', label: 'Hệ thống' }]} />
      </div>

      <div data-mx-node="theme/accent">
        <MxSectionHeader title="Màu nhấn" node="theme/accent-head" />
        <MxCard>
          <div style={{ display: 'flex', gap: 14, flexWrap: 'wrap', justifyContent: 'center' }}>
            {SWATCHES.map((c, i) => (
              <button key={c} data-mx-node={'theme/accent-' + i} style={{ width: 42, height: 42, borderRadius: '50%', background: c, border: 'none', boxShadow: i === accent ? '0 0 0 3px var(--memox-bg), 0 0 0 6px ' + c : '0 0 0 1px var(--memox-divider)', cursor: 'pointer', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                {i === accent ? <span className="material-symbols-rounded" style={{ color: '#fff', fontSize: 22 }}>check</span> : null}
              </button>
            ))}
          </div>
        </MxCard>
      </div>

      <div data-mx-node="theme/size">
        <MxSectionHeader title="Cỡ chữ" node="theme/size-head" />
        <MxSegmentedControl value={size} onChange={() => {}} block node="theme/size-control"
          segments={[{ value: 'sm', label: 'Nhỏ' }, { value: 'md', label: 'Vừa' }, { value: 'lg', label: 'Lớn' }]} />
      </div>
    </MxScaffold>
  );
}

window.Theme = Theme;
})();
