/* MemoX — Import (Nhập thẻ). States: source · mapping · preview · dup-warning · done */
(function () {
const NS = window.MemoXDesignSystem_2ffa54;
const { MxScaffold, MxAppBar, MxIconButton, MxCard, MxButton, MxChip, MxIconTile } = NS;

const SOURCES = [
  { icon: 'description', name: 'Tệp CSV', desc: 'Nhập từ tệp .csv' },
  { icon: 'table_chart', name: 'Excel', desc: 'Nhập từ tệp .xlsx' },
  { icon: 'content_paste', name: 'Dán văn bản', desc: 'Sao chép từ nơi khác' },
];
const SEPS = ['Tab', 'Phẩy', 'Chấm phẩy'];
const ROWS = [['Term', 'Nghĩa'], ['안녕하세요', 'Xin chào'], ['감사합니다', 'Cảm ơn'], ['사랑', 'Tình yêu'], ['학교', 'Trường học']];

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
  const bar = <MxAppBar title="Nhập thẻ" node="import/appbar" leading={<MxIconButton icon="arrow_back" node="import/back" />} />;

  if (state === 'done') {
    return (
      <MxScaffold node="import/screen" appBar={bar}>
        <window.EmptyState node="import/done" icon="task_alt" tone="success" title="Đã nhập 124 thẻ"
          text="Các thẻ mới đã được thêm vào bộ thẻ “TOPIK I — Từ vựng”."
          action={<MxButton variant="primary" icon="arrow_forward" node="import/go-deck">Về bộ thẻ</MxButton>} />
      </MxScaffold>
    );
  }

  if (state === 'source') {
    return (
      <MxScaffold node="import/screen" appBar={bar}>
        <SectionLabel>CHỌN NGUỒN</SectionLabel>
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
        <div data-mx-node="import/paste" style={{ border: '1px dashed var(--memox-divider)', borderRadius: 'var(--memox-radius-control)', minHeight: 96, padding: '14px', color: 'var(--memox-text-tertiary)', fontSize: 'var(--memox-font-size-base)' }}>Dán dữ liệu vào đây (mỗi dòng một thẻ: term[tab]nghĩa)…</div>
      </MxScaffold>
    );
  }

  if (state === 'mapping') {
    return (
      <MxScaffold node="import/screen" appBar={bar}>
        <SectionLabel>DẤU PHÂN TÁCH</SectionLabel>
        <div style={{ display: 'flex', gap: 'var(--memox-space-2)' }}>
          {SEPS.map((s, i) => <MxChip key={s} label={s} selected={i === 0} node={'import/sep-' + i} />)}
        </div>
        <SectionLabel>ÁNH XẠ CỘT</SectionLabel>
        <MxCard padding="sm">
          <window.ListRow icon="text_fields" title="Cột A → Term" sub="안녕하세요, 감사합니다…" node="import/map-term"
            trailing={<MxIconButton icon="expand_more" size="sm" node="import/map-term-pick" />} />
          <window.ListRow icon="translate" title="Cột B → Nghĩa" sub="Xin chào, Cảm ơn…" last node="import/map-meaning"
            trailing={<MxIconButton icon="expand_more" size="sm" node="import/map-meaning-pick" />} />
        </MxCard>
        <Table rows={ROWS} />
        <MxButton variant="primary" block node="import/to-preview">Tiếp tục</MxButton>
      </MxScaffold>
    );
  }

  // preview / dup-warning
  return (
    <MxScaffold node="import/screen" appBar={bar}>
      {state === 'dup-warning' ? (
        <div data-mx-node="import/dup-warning" style={{ background: 'var(--memox-warning-soft)', color: 'var(--memox-on-warning-soft)', borderRadius: 'var(--memox-radius-control)', padding: '12px 14px', display: 'flex', alignItems: 'center', gap: 10 }}>
          <span className="material-symbols-rounded">warning</span>
          <span style={{ flex: 1, fontSize: 'var(--memox-font-size-sm)' }}>Có 8 thẻ trùng với thẻ đã có — vẫn nhập?</span>
        </div>
      ) : null}
      <SectionLabel>XEM TRƯỚC · 124 THẺ</SectionLabel>
      <Table rows={ROWS} />
      <MxButton variant="primary" icon="download" block node="import/do-import">Nhập 124 thẻ</MxButton>
    </MxScaffold>
  );
}

window.Import = Import;
})();
