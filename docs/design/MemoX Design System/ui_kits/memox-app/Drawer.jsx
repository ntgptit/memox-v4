/* MemoX — Drawer & language pairs. States: open · add-language · remove-language */
(function () {
const NS = window.MemoXDesignSystem_2ffa54;
const { MxScaffold, MxAppBar, MxIconButton, MxCard, MxButton } = NS;

const ITEMS = [
  { icon: 'add', label: 'Add language' },
  { icon: 'delete', label: 'Remove language' },
  { icon: 'upload_file', label: 'Import' },
  { icon: 'download', label: 'Export' },
  { icon: 'insights', label: 'Stats' },
  { icon: 'palette', label: 'Theme' },
  { icon: 'settings', label: 'Settings' },
  { icon: 'help', label: 'FAQ' },
  { icon: 'mail', label: 'Email us' },
  { icon: 'cloud_sync', label: 'Sync (alpha)' },
];

function DrawerItem({ icon, label, node }) {
  return (
    <button data-mx-node={node} style={{ display: 'flex', alignItems: 'center', gap: 14, width: '100%', border: 'none', background: 'transparent', cursor: 'pointer', font: 'inherit', padding: '11px 8px', borderRadius: 'var(--memox-radius-control)', textAlign: 'left', color: 'inherit' }}>
      <span className="material-symbols-rounded" style={{ fontSize: 22, color: 'var(--memox-text-secondary)' }}>{icon}</span>
      <span style={{ flex: 1, fontWeight: 600, fontSize: 'var(--memox-font-size-base)' }}>{label}</span>
    </button>
  );
}

function LangCard({ icon, name, sub, node }) {
  return (
    <MxCard interactive padding="sm" node={node}>
      <div style={{ display: 'flex', alignItems: 'center', gap: 'var(--memox-space-4)' }}>
        <span className="material-symbols-rounded" style={{ fontSize: 28, color: 'var(--memox-text-secondary)' }}>{icon}</span>
        <div style={{ flex: 1, minWidth: 0 }}>
          <div style={{ fontWeight: 700, fontSize: 'var(--memox-font-size-base)' }}>{name}</div>
          <div style={{ fontSize: 'var(--memox-font-size-sm)', color: 'var(--memox-text-secondary)', marginTop: 2 }}>{sub}</div>
        </div>
        <span className="material-symbols-rounded" style={{ color: 'var(--memox-text-tertiary)' }}>expand_more</span>
      </div>
    </MxCard>
  );
}

function Drawer({ state = 'open' }) {
  if (state === 'open') {
    return (
      <div data-mx-node="drawer/overlay" style={{ position: 'absolute', inset: 0, zIndex: 60, display: 'flex' }}>
        <div data-mx-node="drawer/panel" style={{ width: '82%', maxWidth: 320, height: '100%', background: 'var(--memox-surface)', display: 'flex', flexDirection: 'column', padding: 'var(--memox-space-5) var(--memox-space-4)', boxShadow: '8px 0 32px rgba(8,11,24,.2)' }}>
          <div style={{ padding: '0 8px var(--memox-space-4)', borderBottom: '1px solid var(--memox-divider)', marginBottom: 'var(--memox-space-2)' }}>
            <div style={{ fontSize: 'var(--memox-font-size-sm)', color: 'var(--memox-text-tertiary)', fontWeight: 700, letterSpacing: '.04em' }}>TODAY'S ACTIVITY</div>
            <div style={{ display: 'flex', alignItems: 'center', gap: 8, marginTop: 6, fontWeight: 700 }}>
              <span className="material-symbols-rounded" style={{ fontSize: 20, color: 'var(--memox-primary)' }}>schedule</span>
              <span style={{ fontSize: 'var(--memox-font-size-md)' }}>12:45</span>
              <span style={{ color: 'var(--memox-text-tertiary)' }}>·</span>
              <span style={{ fontSize: 'var(--memox-font-size-md)' }}>24 words</span>
            </div>
          </div>
          <div style={{ flex: 1, overflowY: 'auto' }}>
            {ITEMS.map((it, i) => <DrawerItem key={i} icon={it.icon} label={it.label} node={'drawer/item-' + i} />)}
          </div>
        </div>
        <div style={{ flex: 1, background: 'rgba(8,11,24,.5)' }} />
      </div>
    );
  }

  if (state === 'add-language') {
    return (
      <MxScaffold node="drawer/add-screen" appBar={<MxAppBar title="Add language" node="drawer/add-appbar" leading={<MxIconButton icon="arrow_back" node="drawer/add-back" />} />}>
        <div style={{ fontSize: 'var(--memox-font-size-sm)', color: 'var(--memox-text-tertiary)', fontWeight: 700, letterSpacing: '.04em', margin: '4px 0 0 4px' }}>LEARNING</div>
        <LangCard icon="language" name="한국어" sub="Korean" node="drawer/learn-lang" />
        <div style={{ display: 'flex', justifyContent: 'center', color: 'var(--memox-text-tertiary)' }}><span className="material-symbols-rounded">arrow_downward</span></div>
        <div style={{ fontSize: 'var(--memox-font-size-sm)', color: 'var(--memox-text-tertiary)', fontWeight: 700, letterSpacing: '.04em', margin: '0 0 0 4px' }}>NATIVE</div>
        <LangCard icon="translate" name="English" sub="Meaning language" node="drawer/native-lang" />
        <MxButton variant="primary" icon="add" block node="drawer/add-confirm">Add language pair</MxButton>
      </MxScaffold>
    );
  }

  // remove-language
  return (
    <React.Fragment>
      <MxScaffold node="drawer/remove-screen" appBar={<MxAppBar title="Remove language" node="drawer/remove-appbar" leading={<MxIconButton icon="arrow_back" node="drawer/remove-back" />} />}>
        <MxCard padding="sm">
          <window.ListRow icon="translate" title="한국어 → English" sub="1240 cards" node="drawer/pair-0"
            trailing={<MxIconButton icon="delete" node="drawer/pair-0-del" />} />
          <window.ListRow icon="translate" title="日本語 → English" sub="430 cards" last node="drawer/pair-1"
            trailing={<MxIconButton icon="delete" node="drawer/pair-1-del" />} />
        </MxCard>
      </MxScaffold>
      <window.Scrim align="center" node="drawer/remove-scrim">
        <window.Dialog icon="delete" tone="error" title="Remove 한국어 → English?"
          text="All folders, decks and cards for this pair will be deleted. This can't be undone."
          node="drawer/remove-dialog"
          actions={<React.Fragment>
            <MxButton variant="ghost" block node="drawer/remove-cancel">Cancel</MxButton>
            <MxButton variant="primary" danger block node="drawer/remove-ok">Remove</MxButton>
          </React.Fragment>} />
      </window.Scrim>
    </React.Fragment>
  );
}

window.Drawer = Drawer;
})();
