/* MemoX — Account & Sync (Tài khoản & Đồng bộ). States: signed-out · signed-in · syncing · conflict · offline */
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
        <window.ListRow icon="sync" tone="accent" title="Đang đồng bộ…" sub="Đang tải lên thay đổi" last node="account/sync-status" />
        <div style={{ marginTop: 10 }}><window.ProgressBar value={60} height={8} node="account/sync-bar" /></div>
      </MxCard>
    );
  }
  if (state === 'offline') {
    return (
      <MxCard node="account/sync">
        <window.ListRow icon="cloud_off" tone="warning" title="Ngoại tuyến" sub="Sẽ đồng bộ khi có mạng" last node="account/sync-status" />
      </MxCard>
    );
  }
  if (state === 'conflict') {
    return (
      <MxCard node="account/sync" style={{ gap: 'var(--memox-space-3)' }}>
        <window.ListRow icon="merge_type" tone="success" title="Đã hợp nhất" sub="Giữ theo bản mới nhất (last-write-wins)" last node="account/sync-status" />
        <Banner icon="check_circle" tone="success" text="Dữ liệu các thiết bị đã được hợp nhất an toàn." />
      </MxCard>
    );
  }
  return (
    <MxCard node="account/sync">
      <window.ListRow icon="cloud_done" tone="success" title="Đã đồng bộ" sub="Lần cuối: 14:02 hôm nay" last node="account/sync-status"
        trailing={<MxButton variant="outline" size="sm" node="account/sync-now">Đồng bộ ngay</MxButton>} />
    </MxCard>
  );
}

function AccountSync({ state = 'signed-out' }) {
  const bar = <MxAppBar title="Tài khoản & Đồng bộ" node="account/appbar" leading={<MxIconButton icon="arrow_back" node="account/back" />} />;

  if (state === 'signed-out') {
    return (
      <MxScaffold node="account/screen" appBar={bar}>
        <MxCard node="account/signin" style={{ alignItems: 'center', textAlign: 'center', gap: 'var(--memox-space-4)', padding: 'var(--memox-space-7) var(--memox-space-5)' }}>
          <MxIconTile icon="cloud_sync" tone="accent" size="lg" />
          <div>
            <div style={{ fontSize: 'var(--memox-font-size-lg)', fontWeight: 800 }}>Đồng bộ đa thiết bị</div>
            <div style={{ fontSize: 'var(--memox-font-size-base)', color: 'var(--memox-text-secondary)', marginTop: 4, maxWidth: 260 }}>Đăng nhập để sao lưu và đồng bộ thẻ giữa các thiết bị. App vẫn dùng được offline.</div>
          </div>
          <MxButton variant="primary" icon="login" block node="account/google">Đăng nhập bằng Google</MxButton>
        </MxCard>
        <div style={{ textAlign: 'center', fontSize: 'var(--memox-font-size-sm)', color: 'var(--memox-text-tertiary)' }}>Tính năng đang ở giai đoạn alpha.</div>
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

      <MxButton variant="ghost" danger icon="logout" block node="account/signout">Đăng xuất</MxButton>
    </MxScaffold>
  );
}

window.AccountSync = AccountSync;
})();
