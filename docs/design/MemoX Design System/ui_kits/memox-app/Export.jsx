/* MemoX — Export (Xuất thẻ). States: config · exporting · done */
(function () {
const NS = window.MemoXDesignSystem_2ffa54;
const { MxScaffold, MxAppBar, MxIconButton, MxCard, MxButton, MxChip, MxSegmentedControl, MxSwitch } = NS;

const FORMATS = [
  { icon: 'description', name: 'CSV', sub: 'Tệp .csv', id: 'csv' },
  { icon: 'table_chart', name: 'Excel', sub: 'Tệp .xlsx', id: 'xlsx' },
  { icon: 'content_copy', name: 'Sao chép văn bản', sub: 'Vào bộ nhớ tạm', id: 'copy' },
];
const SEPS = ['Tab', 'Phẩy', 'Chấm phẩy'];

function SectionLabel({ children }) {
  return <div style={{ fontSize: 'var(--memox-font-size-sm)', color: 'var(--memox-text-tertiary)', fontWeight: 700, letterSpacing: '.04em', margin: '4px 0 0 4px' }}>{children}</div>;
}

function Export({ state = 'config' }) {
  const [incl, setIncl] = React.useState(true);
  const bar = <MxAppBar title="Xuất thẻ" node="export/appbar" leading={<MxIconButton icon="arrow_back" node="export/back" />} />;

  if (state === 'exporting') {
    return (
      <MxScaffold node="export/screen" appBar={bar}>
        <MxCard node="export/progress" style={{ alignItems: 'center', gap: 'var(--memox-space-4)', padding: 'var(--memox-space-7)' }}>
          <span className="material-symbols-rounded" style={{ fontSize: 40, color: 'var(--memox-primary)' }}>sync</span>
          <div style={{ fontWeight: 700 }}>Đang xuất…</div>
          <div style={{ width: '100%' }}><window.ProgressBar value={70} height={8} node="export/bar" /></div>
        </MxCard>
      </MxScaffold>
    );
  }

  if (state === 'done') {
    return (
      <MxScaffold node="export/screen" appBar={bar}>
        <window.EmptyState node="export/done" icon="ios_share" tone="success" title="Đã xuất 320 thẻ"
          text="Tệp đã sẵn sàng để chia sẻ hoặc lưu lại."
          action={<div style={{ display: 'flex', flexDirection: 'column', gap: 10, width: 240 }}>
            <MxButton variant="primary" icon="share" block node="export/share">Chia sẻ tệp</MxButton>
            <MxButton variant="ghost" icon="save_alt" block node="export/save">Lưu vào thiết bị</MxButton>
          </div>} />
      </MxScaffold>
    );
  }

  return (
    <MxScaffold node="export/screen" appBar={bar}>
      <SectionLabel>PHẠM VI</SectionLabel>
      <MxSegmentedControl value="deck" onChange={() => {}} block node="export/scope"
        segments={[{ value: 'deck', label: 'Bộ thẻ này' }, { value: 'folder', label: 'Cả thư mục' }]} />

      <SectionLabel>ĐỊNH DẠNG</SectionLabel>
      <MxCard padding="sm">
        {FORMATS.map((f, i) => (
          <window.ListRow key={f.id} icon={f.icon} title={f.name} sub={f.sub} last={i === FORMATS.length - 1} node={'export/format-' + f.id}
            trailing={<span className="material-symbols-rounded" style={{ color: i === 0 ? 'var(--memox-primary)' : 'var(--memox-text-tertiary)' }}>{i === 0 ? 'radio_button_checked' : 'radio_button_unchecked'}</span>} />
        ))}
      </MxCard>

      <SectionLabel>DẤU PHÂN TÁCH</SectionLabel>
      <div style={{ display: 'flex', gap: 'var(--memox-space-2)' }}>
        {SEPS.map((s, i) => <MxChip key={s} label={s} selected={i === 0} node={'export/sep-' + i} />)}
      </div>

      <MxCard padding="sm">
        <window.ListRow icon="schedule" tone="success" title="Kèm trạng thái ôn" sub="Ô Leitner + ngày đến hạn" last node="export/incl-srs"
          trailing={<MxSwitch checked={incl} onChange={setIncl} node="export/incl-srs-switch" />} />
      </MxCard>

      <MxButton variant="primary" icon="download" block node="export/do-export">Xuất</MxButton>
    </MxScaffold>
  );
}

window.Export = Export;
})();
