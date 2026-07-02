/* MemoX — Settings local: Profile (avatar + name + email card). */
(function () {
const NS = window.MemoXDesignSystem_2ffa54;
const { MxCard, MxAvatar } = NS;

function Profile() {
  return (
    <MxCard node="settings/profile" style={{ flexDirection: 'row', alignItems: 'center', gap: 'var(--memox-space-4)' }}>
      <MxAvatar name="Linh Tran" size="lg" ring />
      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{ fontWeight: 'var(--memox-font-weight-extrabold)', fontSize: 'var(--memox-font-size-md)' }}>Linh Tran</div>
        <div style={{ fontSize: 'var(--memox-font-size-sm)', color: 'var(--memox-text-secondary)' }}>linh@memox.app</div>
      </div>
    </MxCard>
  );
}

window.MemoXSettings = window.MemoXSettings || {};
window.MemoXSettings.Profile = Profile;
})();
