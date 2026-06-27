/* MemoX — Account & Sync. States: signed-out · signed-in · syncing · conflict · offline */
(function () {
const NS = window.MemoXDesignSystem_2ffa54;
const { MxScaffold, MxAppBar, MxIconButton, MxCard, MxButton, MxAvatar, MxBadge, MxIconTile } = NS;

function Banner({ icon, text, tone }) {
  const c = tone === 'success'
    ? ['var(--memox-success-soft)', 'var(--memox-on-success-soft)']
    : ['var(--memox-warning-soft)', 'var(--memox-on-warning-soft)'];
  return (
    <div style={{ background: c[0], color: c[1], borderRadius: 'var(--memox-radius-control)', padding: '10px 14px', display: 'flex', alignItems: 'center', gap: 8, fontSize: 'var(--memox-font-size-sm)', fontWeight: 600 }}>
      <span className="material-symbols-rounded" style={{ fontSize: 18 }}>{icon}</span>{text}
    </div>
  );
}

function SyncBlock({ state }) {
  if (state === 'syncing') {
    return (
      <MxCard node="account/sync">
        <window.ListRow icon="sync" tone="accent" title="Syncing…" sub="Uploading changes" last node="account/sync-status" />
        <div style={{ marginTop: 10 }}><window.ProgressBar value={60} height={8} node="account/sync-bar" /></div>
      </MxCard>
    );
  }
  if (state === 'offline') {
    return (
      <MxCard node="account/sync">
        <window.ListRow icon="cloud_off" tone="warning" title="Offline" sub="Will sync when you're back online" last node="account/sync-status" />
      </MxCard>
    );
  }
  if (state === 'conflict') {
    return (
      <MxCard node="account/sync" style={{ gap: 'var(--memox-space-3)' }}>
        <window.ListRow icon="merge_type" tone="success" title="Merged" sub="Kept the latest (last-write-wins)" last node="account/sync-status" />
        <Banner icon="check_circle" tone="success" text="Your devices' data was merged safely." />
      </MxCard>
    );
  }
  return (
    <MxCard node="account/sync">
      <window.ListRow icon="cloud_done" tone="success" title="Synced" sub="Last: 14:02 today" last node="account/sync-status"
        trailing={<MxButton variant="outline" size="sm" node="account/sync-now">Sync now</MxButton>} />
    </MxCard>
  );
}

function AccountSync({ state = 'signed-out' }) {
  const bar = <MxAppBar title="Account & Sync" node="account/appbar" leading={<MxIconButton icon="arrow_back" node="account/back" />} />;

  if (state === 'signed-out') {
    return (
      <MxScaffold node="account/screen" appBar={bar}>
        <MxCard node="account/signin" style={{ alignItems: 'center', textAlign: 'center', gap: 'var(--memox-space-4)', padding: 'var(--memox-space-7) var(--memox-space-5)' }}>
          <MxIconTile icon="cloud_sync" tone="accent" size="lg" />
          <div>
            <div style={{ fontSize: 'var(--memox-font-size-lg)', fontWeight: 800 }}>Sync across devices</div>
            <div style={{ fontSize: 'var(--memox-font-size-base)', color: 'var(--memox-text-secondary)', marginTop: 4, maxWidth: 260 }}>Sign in to back up and sync cards across devices. The app still works offline.</div>
          </div>
          <MxButton variant="primary" icon="login" block node="account/google">Sign in with Google</MxButton>
        </MxCard>
        <div style={{ textAlign: 'center', fontSize: 'var(--memox-font-size-sm)', color: 'var(--memox-text-tertiary)' }}>This feature is in alpha.</div>
      </MxScaffold>
    );
  }

  return (
    <MxScaffold node="account/screen" appBar={bar}>
      <MxCard node="account/profile" style={{ flexDirection: 'row', alignItems: 'center', gap: 'var(--memox-space-4)' }}>
        <MxAvatar name="Linh Tran" size="lg" ring />
        <div style={{ flex: 1, minWidth: 0 }}>
          <div style={{ fontWeight: 800, fontSize: 'var(--memox-font-size-md)' }}>Linh Tran</div>
          <div style={{ fontSize: 'var(--memox-font-size-sm)', color: 'var(--memox-text-secondary)' }}>linh@memox.app</div>
        </div>
        <MxBadge tone="warning" soft>ALPHA</MxBadge>
      </MxCard>

      <SyncBlock state={state} />

      <MxButton variant="ghost" danger icon="logout" block node="account/signout">Sign out</MxButton>
    </MxScaffold>
  );
}

window.AccountSync = AccountSync;
})();
