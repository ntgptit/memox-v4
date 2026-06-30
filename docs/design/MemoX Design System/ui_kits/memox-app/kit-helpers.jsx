/* MemoX UI-kit shared helpers — exported to window for screen modules. */
const NS = window.MemoXDesignSystem_2ffa54;

function ProgressBar({ value = 0, tone, height = 8, node }) {
  return (
    <div data-mx-node={node} style={{ height, borderRadius: 'var(--memox-radius-pill)', background: 'var(--memox-surface-sunken)', overflow: 'hidden' }}>
      <div style={{ height: '100%', width: value + '%', borderRadius: 'var(--memox-radius-pill)', background: tone || 'var(--memox-primary)', transition: 'width .3s ease' }} />
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
      <div style={{ display: 'flex', flexDirection: 'column', gap: 'var(--memox-space-2)', maxWidth: 'var(--memox-size-3xl)' }}>
        <div style={{ fontSize: 'var(--memox-font-size-lg)', fontWeight: 'var(--memox-font-weight-extrabold)', letterSpacing: 'var(--memox-letter-spacing-tight)' }}>{title}</div>
        <div style={{ fontSize: 'var(--memox-font-size-base)', color: 'var(--memox-text-secondary)', lineHeight: 'var(--memox-line-height-normal)' }}>{text}</div>
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
        <div style={{ fontWeight: 'var(--memox-font-weight-bold)', fontSize: 'var(--memox-font-size-base)', whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' }}>{name}</div>
        <div style={{ fontSize: 'var(--memox-font-size-sm)', color: 'var(--memox-text-secondary)', marginTop: 'var(--memox-space-1)' }}>{meta}</div>
        {progress != null ? <div style={{ marginTop: 'var(--memox-space-2)' }}><ProgressBar value={progress} height={6} /></div> : null}
      </div>
      {due != null ? <MxBadge tone={due > 0 ? undefined : 'success'} soft>{due > 0 ? due : '✓'}</MxBadge> : null}
    </div>
  );
}

/* Generic settings/detail list row: icon · title · sub · trailing, divider unless last. */
function ListRow({ icon, tone, title, sub, trailing, node, last, muted, onClick }) {
  const { MxIconTile } = NS;
  return (
    <div data-mx-node={node} onClick={onClick} style={{ display: 'flex', alignItems: 'center', gap: 'var(--memox-space-4)', opacity: muted ? .55 : 1, paddingBottom: last ? 0 : 'var(--memox-space-4)', marginBottom: last ? 0 : 'var(--memox-space-4)', borderBottom: last ? 'none' : 'var(--memox-stroke-hairline) solid var(--memox-divider)' }}>
      {icon ? <MxIconTile icon={icon} tone={tone} /> : null}
      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{ fontWeight: 'var(--memox-font-weight-bold)', fontSize: 'var(--memox-font-size-base)', whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' }}>{title}</div>
        {sub ? <div style={{ fontSize: 'var(--memox-font-size-sm)', color: 'var(--memox-text-secondary)', marginTop: 'var(--memox-space-1)' }}>{sub}</div> : null}
      </div>
      {trailing}
    </div>
  );
}

/* Compact stat cell — caller wraps in an MxCard. */
function Stat({ n, l, tone, node }) {
  return (
    <div data-mx-node={node} style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 'var(--memox-space-1)' }}>
      <div style={{ fontSize: 'var(--memox-icon-size-md)', fontWeight: 'var(--memox-font-weight-extrabold)', color: tone || 'inherit' }}>{n}</div>
      <div style={{ fontSize: 'var(--memox-font-size-xs)', color: 'var(--memox-text-secondary)' }}>{l}</div>
    </div>
  );
}

/* Modal scrim — absolute over the device frame; align 'end' (sheet) or 'center' (dialog). */
function Scrim({ children, align = 'end', node }) {
  return (
    <div data-mx-node={node} style={{ position: 'absolute', inset: 0, zIndex: 60, background: 'var(--memox-overlay)', display: 'flex', flexDirection: 'column', justifyContent: align === 'center' ? 'center' : 'flex-end', alignItems: align === 'center' ? 'center' : 'stretch', padding: align === 'center' ? 'var(--memox-space-6)' : 0 }}>
      {children}
    </div>
  );
}

/* Bottom action sheet surface. */
function Sheet({ title, children, node }) {
  return (
    <div data-mx-node={node} style={{ background: 'var(--memox-surface)', color: 'var(--memox-text)', borderTopLeftRadius: 'var(--memox-radius-2xl)', borderTopRightRadius: 'var(--memox-radius-2xl)', padding: 'var(--memox-space-5) var(--memox-space-4) var(--memox-space-6)', display: 'flex', flexDirection: 'column', gap: 'var(--memox-space-1)', boxShadow: 'var(--memox-shadow-nav)' }}>
      <div style={{ width: 'var(--memox-size-sm)', height: 'var(--memox-size-3xs)', borderRadius: 'var(--memox-radius-pill)', background: 'var(--memox-divider)', margin: '0 auto var(--memox-space-4)' }} />
      {title ? <div style={{ fontSize: 'var(--memox-font-size-sm)', fontWeight: 'var(--memox-font-weight-bold)', color: 'var(--memox-text-tertiary)', textTransform: 'uppercase', letterSpacing: 'var(--memox-letter-spacing-wide)', margin: '0 0 var(--memox-space-2) var(--memox-space-2)' }}>{title}</div> : null}
      {children}
    </div>
  );
}

/* Full-width row button inside a Sheet. */
function MenuItem({ icon, label, tone, danger, trailing, node, onClick }) {
  const color = danger ? 'var(--memox-error)' : 'inherit';
  return (
    <button data-mx-node={node} onClick={onClick} style={{ display: 'flex', alignItems: 'center', gap: 'var(--memox-space-4)', width: '100%', border: 'none', background: 'transparent', cursor: 'pointer', font: 'inherit', color, padding: 'var(--memox-space-3) var(--memox-space-2)', borderRadius: 'var(--memox-radius-control)', textAlign: 'left' }}>
      <span className="material-symbols-rounded" style={{ fontSize: 'var(--memox-icon-size-md)', color: danger ? 'var(--memox-error)' : (tone || 'var(--memox-text-secondary)') }}>{icon}</span>
      <span style={{ flex: 1, fontWeight: 'var(--memox-font-weight-semibold)', fontSize: 'var(--memox-font-size-base)' }}>{label}</span>
      {trailing}
    </button>
  );
}

/* Centered confirm/alert dialog (wrap in <Scrim align="center">). */
function Dialog({ icon, tone, title, text, actions, node }) {
  const { MxIconTile } = NS;
  return (
    <div data-mx-node={node} style={{ width: '100%', maxWidth: 'var(--memox-size-5xl)', background: 'var(--memox-surface)', color: 'var(--memox-text)', borderRadius: 'var(--memox-radius-xl)', padding: 'var(--memox-space-6)', display: 'flex', flexDirection: 'column', alignItems: 'center', textAlign: 'center', gap: 'var(--memox-space-4)', boxShadow: 'var(--memox-shadow-lg)' }}>
      {icon ? <MxIconTile icon={icon} tone={tone} size="lg" /> : null}
      <div style={{ display: 'flex', flexDirection: 'column', gap: 'var(--memox-space-2)' }}>
        <div style={{ fontSize: 'var(--memox-font-size-lg)', fontWeight: 'var(--memox-font-weight-extrabold)', letterSpacing: 'var(--memox-letter-spacing-tight)' }}>{title}</div>
        {text ? <div style={{ fontSize: 'var(--memox-font-size-base)', color: 'var(--memox-text-secondary)', lineHeight: 'var(--memox-line-height-normal)' }}>{text}</div> : null}
      </div>
      <div style={{ display: 'flex', gap: 'var(--memox-space-3)', width: '100%', marginTop: 'var(--memox-space-1)' }}>{actions}</div>
    </div>
  );
}

/* Inline tinted callout — icon + text on a soft tonal background. */
function Note({ icon, text, tone = 'accent' }) {
  const map = {
    accent: ['var(--memox-primary-soft)', 'var(--memox-on-primary-soft)'],
    success: ['var(--memox-success-soft)', 'var(--memox-on-success-soft)'],
    warning: ['var(--memox-warning-soft)', 'var(--memox-on-warning-soft)'],
    error: ['var(--memox-error-soft)', 'var(--memox-on-error-soft)'],
  };
  const c = map[tone] || map.accent;
  return (
    <div style={{ background: c[0], color: c[1], borderRadius: 'var(--memox-radius-control)', padding: 'var(--memox-space-3) var(--memox-space-4)', display: 'flex', alignItems: 'center', gap: 'var(--memox-space-2)', fontSize: 'var(--memox-font-size-sm)', fontWeight: 'var(--memox-font-weight-semibold)' }}>
      <span className="material-symbols-rounded" style={{ fontSize: 'var(--memox-icon-size-sm)' }}>{icon}</span>{text}
    </div>
  );
}

/* Small overline label above a group of rows/cards. */
function SectionLabel({ children }) {
  return <div style={{ fontSize: 'var(--memox-font-size-sm)', fontWeight: 'var(--memox-font-weight-bold)', color: 'var(--memox-text-tertiary)', letterSpacing: 'var(--memox-letter-spacing-wide)', margin: 'var(--memox-space-1) 0 0 var(--memox-space-1)' }}>{children}</div>;
}

Object.assign(window, { ProgressBar, Skeleton, EmptyState, DeckRow, ListRow, Stat, Scrim, Sheet, MenuItem, Dialog, Note, SectionLabel });
