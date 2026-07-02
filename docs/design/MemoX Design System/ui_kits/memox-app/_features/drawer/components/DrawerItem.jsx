/* MemoX — Drawer local: DrawerItem (one nav button in the slide-out panel). */
(function () {

function DrawerItem({ icon, label, node }) {
  return (
    <button data-mx-node={node} style={{ display: 'flex', alignItems: 'center', gap: 'var(--memox-space-4)', width: '100%', border: 'none', background: 'transparent', cursor: 'pointer', font: 'inherit', padding: 'var(--memox-space-3) var(--memox-space-2)', borderRadius: 'var(--memox-radius-control)', textAlign: 'left', color: 'inherit' }}>
      <span className="material-symbols-rounded" style={{ fontSize: 'var(--memox-icon-size-md)', color: 'var(--memox-text-secondary)' }}>{icon}</span>
      <span style={{ flex: 1, fontWeight: 'var(--memox-font-weight-semibold)', fontSize: 'var(--memox-font-size-base)' }}>{label}</span>
    </button>
  );
}

window.MemoXDrawer = window.MemoXDrawer || {};
window.MemoXDrawer.DrawerItem = DrawerItem;
})();
