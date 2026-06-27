/* MemoX — Flashcard editor screen. States: create · edit · validation · duplicate · multi-meaning · audio */
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
        <span style={{ flex: 1, fontSize: 'var(--memox-font-size-sm)', lineHeight: 1.5 }}>Đã có thẻ “안녕하세요” trong bộ thẻ này.</span>
      </div>
      <div style={{ display: 'flex', gap: 8 }}>
        <MxButton variant="ghost" size="sm" node="flashcard-editor/dup-view">Xem thẻ đã có</MxButton>
        <MxButton variant="primary" size="sm" node="flashcard-editor/dup-add">Vẫn thêm</MxButton>
      </div>
    </div>
  );
}

function FlashcardEditor({ state = 'create' }) {
  const [hidden, setHidden] = React.useState(false);
  const blank = state === 'create' || state === 'validation';
  const title = state === 'create' ? 'Thẻ mới' : 'Sửa thẻ';
  const termErr = state === 'validation' ? 'Bắt buộc nhập term' : null;
  const meaningErr = state === 'validation' ? 'Bắt buộc nhập nghĩa' : null;

  const bar = (
    <MxAppBar node="flashcard-editor/appbar" title={title}
      leading={<MxButton variant="ghost" node="flashcard-editor/cancel">Huỷ</MxButton>}
      trailing={<MxButton variant="primary" size="sm" disabled={state === 'create'} node="flashcard-editor/save">Lưu</MxButton>} />
  );

  return (
    <MxScaffold node="flashcard-editor/screen" appBar={bar}>
      {state === 'duplicate' ? <DupBanner /> : null}

      <Field label="Term (tiếng Hàn)" required node="flashcard-editor/term"
        value={blank ? '' : '안녕하세요'} placeholder="Nhập từ…" error={termErr} />

      <Field label="Nghĩa (tiếng Việt)" required multiline node="flashcard-editor/meaning"
        value={blank ? '' : 'Xin chào (trang trọng); dùng khi gặp người lớn tuổi'}
        placeholder="Nhập nghĩa, có thể kèm ví dụ/ghi chú…" error={meaningErr} />

      {state === 'multi-meaning'
        ? <Field label="Nghĩa phụ (English)" node="flashcard-editor/meaning-2" value="hello (formal)" placeholder="Nhập nghĩa phụ…" />
        : <MxButton variant="ghost" icon="add" block node="flashcard-editor/add-meaning">Thêm nghĩa ngôn ngữ phụ</MxButton>}

      <div data-mx-node="flashcard-editor/gender" style={{ display: 'flex', flexDirection: 'column', gap: 6 }}>
        <div style={{ fontSize: 'var(--memox-font-size-sm)', fontWeight: 700, color: 'var(--memox-text-secondary)' }}>Giới tính (tuỳ chọn)</div>
        <div style={{ display: 'flex', gap: 8, flexWrap: 'wrap' }}>
          {['Không', 'Đực', 'Cái', 'Trung'].map((g, i) => <MxChip key={g} label={g} selected={i === 0} node={'flashcard-editor/gender-' + i} />)}
        </div>
      </div>

      <Field label="Âm thanh" node="flashcard-editor/audio"
        value={state === 'audio' ? 'Đang tạo từ term…' : 'Tự sinh từ term'}
        trailing={<MxIconButton icon={state === 'audio' ? 'sync' : 'volume_up'} node="flashcard-editor/audio-play" />} />

      <MxCard padding="sm">
        <window.ListRow icon="visibility_off" title="Ẩn thẻ" sub="Không hiện khi học / ôn" last node="flashcard-editor/hidden"
          trailing={<MxSwitch checked={hidden} onChange={setHidden} node="flashcard-editor/hidden-switch" />} />
      </MxCard>
    </MxScaffold>
  );
}

window.FlashcardEditor = FlashcardEditor;
})();
