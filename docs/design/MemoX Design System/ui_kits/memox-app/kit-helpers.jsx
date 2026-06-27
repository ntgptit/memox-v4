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

Object.assign(window, { ProgressBar, Skeleton, EmptyState, DeckRow });
