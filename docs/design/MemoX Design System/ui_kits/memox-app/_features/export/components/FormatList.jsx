/* MemoX — Export local: FormatList (export-format radio list). Owns its FORMATS. */
(function () {
const NS = window.MemoXDesignSystem_2ffa54;
const { MxCard } = NS;

const FORMATS = [
  { icon: 'description', name: 'CSV', sub: '.csv file', id: 'csv' },
  { icon: 'table_chart', name: 'Excel', sub: '.xlsx file', id: 'xlsx' },
  { icon: 'content_copy', name: 'Copy text', sub: 'To clipboard', id: 'copy' },
];

function FormatList() {
  return (
    <MxCard padding="sm">
      {FORMATS.map((f, i) => (
        <window.ListRow key={f.id} icon={f.icon} title={f.name} sub={f.sub} last={i === FORMATS.length - 1} node={'export/format-' + f.id}
          trailing={<span className="material-symbols-rounded" style={{ color: i === 0 ? 'var(--memox-primary)' : 'var(--memox-text-tertiary)' }}>{i === 0 ? 'radio_button_checked' : 'radio_button_unchecked'}</span>} />
      ))}
    </MxCard>
  );
}

window.MemoXExport = window.MemoXExport || {};
window.MemoXExport.FormatList = FormatList;
})();
