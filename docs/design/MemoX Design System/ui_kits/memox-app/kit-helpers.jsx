/* MemoX UI-kit shared helpers — exported to window for screen modules. */
const NS = window.MemoXDesignSystem_2ffa54;

function ProgressBar({ value = 0, tone, height = 8, node }) {
  return (
    <div data-mx-node={node} style={{ height, borderRadius: 999, background: 'var(--memox-surface-sunken)', overflow: 'hidden' }}>
      <div style={{ height: '100%', width: value + '%', borderRadius: 999, background: tone || 'var(--memox-primary)', transition: 'width .3s ease' }} />
    </div>
  );
}

function Skeleton({ w = '100%', h = 16, r = 8, style }) {
  return <div className="mxg-skel" style={{ width: w, height: h, borderRadius: r, ...style }} />;
}

function EmptyState({ icon, tone, title, text, action, node }) {
  const { MxIconTile } = NS;
  return (
    <div data-mx-node={node} style={{ flex: 1, display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', textAlign: 'center', gap: 'var(--memox-space-4)', padding: 'var(--memox-space-8) var(--memox-space-4)' }}>
      <MxIconTile icon={icon} tone={tone} size="lg" />
      <div style={{ display: 'flex', flexDirection: 'column', gap: '6px', maxWidth: 240 }}>
        <div style={{ fontSize: 'var(--memox-font-size-lg)', fontWeight: 800, letterSpacing: '-.02em' }}>{title}</div>
        <div style={{ fontSize: 'var(--memox-font-size-base)', color: 'var(--memox-text-secondary)', lineHeight: 1.5 }}>{text}</div>
      </div>
      {action}
    </div>
  );
}

/* A deck list-row built only from Mx primitives + tokens. */
function DeckRow({ icon, tone, name, meta, due, progress, node, onClick }) {
  const { MxIconTile, MxBadge } = NS;
  return (
    <div data-mx-node={node} onClick={onClick} style={{ display: 'flex', alignItems: 'center', gap: 'var(--memox-space-4)' }}>
      <MxIconTile icon={icon} tone={tone} />
      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{ fontWeight: 700, fontSize: 'var(--memox-font-size-base)', whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' }}>{name}</div>
        <div style={{ fontSize: 'var(--memox-font-size-sm)', color: 'var(--memox-text-secondary)', marginTop: 2 }}>{meta}</div>
        {progress != null ? <div style={{ marginTop: 8 }}><ProgressBar value={progress} height={6} /></div> : null}
      </div>
      {due != null ? <MxBadge tone={due > 0 ? undefined : 'success'} soft>{due > 0 ? due : '✓'}</MxBadge> : null}
    </div>
  );
}

/* Generic settings/detail list row: icon · title · sub · trailing, divider unless last. */
function ListRow({ icon, tone, title, sub, trailing, node, last, muted, onClick }) {
  const { MxIconTile } = NS;
  return (
    <div data-mx-node={node} onClick={onClick} style={{ display: 'flex', alignItems: 'center', gap: 'var(--memox-space-4)', opacity: muted ? .55 : 1, paddingBottom: last ? 0 : 'var(--memox-space-4)', marginBottom: last ? 0 : 'var(--memox-space-4)', borderBottom: last ? 'none' : '1px solid var(--memox-divider)' }}>
      {icon ? <MxIconTile icon={icon} tone={tone} /> : null}
      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{ fontWeight: 700, fontSize: 'var(--memox-font-size-base)', whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' }}>{title}</div>
        {sub ? <div style={{ fontSize: 'var(--memox-font-size-sm)', color: 'var(--memox-text-secondary)', marginTop: 2 }}>{sub}</div> : null}
      </div>
      {trailing}
    </div>
  );
}

/* Compact stat cell — caller wraps in an MxCard. */
function Stat({ n, l, tone, node }) {
  return (
    <div data-mx-node={node} style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 2 }}>
      <div style={{ fontSize: 22, fontWeight: 800, color: tone || 'inherit' }}>{n}</div>
      <div style={{ fontSize: 12, color: 'var(--memox-text-secondary)' }}>{l}</div>
    </div>
  );
}

/* Modal scrim — absolute over the device frame; align 'end' (sheet) or 'center' (dialog). */
function Scrim({ children, align = 'end', node }) {
  return (
    <div data-mx-node={node} style={{ position: 'absolute', inset: 0, zIndex: 60, background: 'rgba(8,11,24,.5)', display: 'flex', flexDirection: 'column', justifyContent: align === 'center' ? 'center' : 'flex-end', alignItems: align === 'center' ? 'center' : 'stretch', padding: align === 'center' ? 'var(--memox-space-6)' : 0 }}>
      {children}
    </div>
  );
}

/* Bottom action sheet surface. */
function Sheet({ title, children, node }) {
  return (
    <div data-mx-node={node} style={{ background: 'var(--memox-surface)', borderTopLeftRadius: 28, borderTopRightRadius: 28, padding: 'var(--memox-space-5) var(--memox-space-4) var(--memox-space-6)', display: 'flex', flexDirection: 'column', gap: '4px', boxShadow: '0 -12px 32px rgba(8,11,24,.18)' }}>
      <div style={{ width: 40, height: 4, borderRadius: 999, background: 'var(--memox-divider)', margin: '0 auto var(--memox-space-4)' }} />
      {title ? <div style={{ fontSize: 'var(--memox-font-size-sm)', fontWeight: 700, color: 'var(--memox-text-tertiary)', textTransform: 'uppercase', letterSpacing: '.04em', margin: '0 0 6px 8px' }}>{title}</div> : null}
      {children}
    </div>
  );
}

/* Full-width row button inside a Sheet. */
function MenuItem({ icon, label, tone, danger, trailing, node, onClick }) {
  const color = danger ? 'var(--memox-error)' : 'inherit';
  return (
    <button data-mx-node={node} onClick={onClick} style={{ display: 'flex', alignItems: 'center', gap: 'var(--memox-space-4)', width: '100%', border: 'none', background: 'transparent', cursor: 'pointer', font: 'inherit', color, padding: '12px 8px', borderRadius: 'var(--memox-radius-control)', textAlign: 'left' }}>
      <span className="material-symbols-rounded" style={{ fontSize: 22, color: danger ? 'var(--memox-error)' : (tone || 'var(--memox-text-secondary)') }}>{icon}</span>
      <span style={{ flex: 1, fontWeight: 600, fontSize: 'var(--memox-font-size-base)' }}>{label}</span>
      {trailing}
    </button>
  );
}

/* Centered confirm/alert dialog (wrap in <Scrim align="center">). */
function Dialog({ icon, tone, title, text, actions, node }) {
  const { MxIconTile } = NS;
  return (
    <div data-mx-node={node} style={{ width: '100%', maxWidth: 320, background: 'var(--memox-surface)', borderRadius: 24, padding: 'var(--memox-space-6)', display: 'flex', flexDirection: 'column', alignItems: 'center', textAlign: 'center', gap: 'var(--memox-space-4)', boxShadow: '0 24px 60px rgba(8,11,24,.35)' }}>
      {icon ? <MxIconTile icon={icon} tone={tone} size="lg" /> : null}
      <div style={{ display: 'flex', flexDirection: 'column', gap: 6 }}>
        <div style={{ fontSize: 'var(--memox-font-size-lg)', fontWeight: 800, letterSpacing: '-.02em' }}>{title}</div>
        {text ? <div style={{ fontSize: 'var(--memox-font-size-base)', color: 'var(--memox-text-secondary)', lineHeight: 1.5 }}>{text}</div> : null}
      </div>
      <div style={{ display: 'flex', gap: 'var(--memox-space-3)', width: '100%', marginTop: 4 }}>{actions}</div>
    </div>
  );
}

Object.assign(window, { ProgressBar, Skeleton, EmptyState, DeckRow, ListRow, Stat, Scrim, Sheet, MenuItem, Dialog });
