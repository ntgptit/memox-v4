/* MemoX — Account-sync local: ProfileCard (signed-in avatar + name + ALPHA badge). */
(function () {
const NS = window.MemoXDesignSystem_2ffa54;
const { MxCard, MxAvatar, MxBadge } = NS;

function ProfileCard() {
  return (
    <MxCard node="account/profile" style={{ flexDirection: 'row', alignItems: 'center', gap: 'var(--memox-space-4)' }}>
      <MxAvatar name="Linh Tran" size="lg" ring />
      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{ fontWeight: 'var(--memox-font-weight-extrabold)', fontSize: 'var(--memox-font-size-md)' }}>Linh Tran</div>
        <div style={{ fontSize: 'var(--memox-font-size-sm)', color: 'var(--memox-text-secondary)' }}>linh@memox.app</div>
      </div>
      <MxBadge tone="warning" soft>ALPHA</MxBadge>
    </MxCard>
  );
}

window.MemoXAccountSync = window.MemoXAccountSync || {};
window.MemoXAccountSync.ProfileCard = ProfileCard;
})();
