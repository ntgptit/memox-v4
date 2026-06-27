/* MemoX — Settings (Cài đặt). States: loaded · group-expanded · value-picker. (Không có Premium ở v1.) */
(function () {
const NS = window.MemoXDesignSystem_2ffa54;
const { MxScaffold, MxAppBar, MxBottomNav, MxCard, MxAvatar, MxSwitch, MxButton } = NS;

const NAV = [
  { id: 'home', label: 'Hôm nay', icon: 'today' },
  { id: 'library', label: 'Thư viện', icon: 'style' },
  { id: 'add', label: 'Thêm', icon: 'add_circle' },
  { id: 'stats', label: 'Thống kê', icon: 'insights' },
  { id: 'me', label: 'Hồ sơ', icon: 'person' },
];

const GROUPS = [
  { icon: 'translate', title: 'Ngôn ngữ', sub: '한국어 → Tiếng Việt', val: '' },
  { icon: 'format_shapes', title: 'Hình thức từ ngữ', sub: 'Nghĩa mẹ đẻ · màu theo giới tính' },
  { icon: 'schedule', title: 'Lặp lại giãn cách', sub: 'Ô: 8 · Thông báo bật', val: '' },
  { icon: 'sports_esports', title: 'Cài đặt trò chơi', sub: '5 từ/ván · ngẫu nhiên', val: '5' },
  { icon: 'record_voice_over', title: 'Giọng nói', sub: 'TTS bật · STT tắt' },
  { icon: 'notifications', title: 'Nhắc học', sub: '13:00 · T2–CN' },
  { icon: 'backup', title: 'Sao lưu / Khôi phục', sub: 'Tự động · lần cuối hôm nay' },
  { icon: 'cloud_sync', title: 'Đồng bộ đám mây', sub: 'linh@memox.app · alpha' },
  { icon: 'palette', title: 'Chủ đề', sub: 'Sáng · màu mặc định' },
];

function Val({ v }) {
  return (
    <div style={{ display: 'flex', alignItems: 'center', gap: 2, color: 'var(--memox-text-tertiary)' }}>
      {v ? <span style={{ fontWeight: 600, fontSize: 'var(--memox-font-size-sm)' }}>{v}</span> : null}
      <span className="material-symbols-rounded" style={{ fontSize: 20 }}>chevron_right</span>
    </div>
  );
}

function Label({ children }) {
  return <div style={{ fontSize: 'var(--memox-font-size-sm)', color: 'var(--memox-text-tertiary)', fontWeight: 700, letterSpacing: '.04em', margin: '4px 0 0 4px' }}>{children}</div>;
}

function Profile() {
  return (
    <MxCard node="settings/profile" style={{ flexDirection: 'row', alignItems: 'center', gap: 'var(--memox-space-4)' }}>
      <MxAvatar name="Linh Tran" size="lg" ring />
      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{ fontWeight: 800, fontSize: 'var(--memox-font-size-md)' }}>Linh Tran</div>
        <div style={{ fontSize: 'var(--memox-font-size-sm)', color: 'var(--memox-text-secondary)' }}>linh@memox.app</div>
      </div>
    </MxCard>
  );
}

function Settings({ state = 'loaded' }) {
  const [notif, setNotif] = React.useState(true);
  const bar = <MxAppBar large title="Cài đặt" node="settings/appbar" />;
  const nav = <MxBottomNav items={NAV} value="me" node="shell/bottom-nav" />;

  if (state === 'group-expanded') {
    return (
      <MxScaffold node="settings/screen" appBar={bar} bottomNav={nav}>
        <Profile />
        <Label>LẶP LẠI GIÃN CÁCH</Label>
        <MxCard padding="sm">
          <window.ListRow icon="grid_view" title="Số ô Leitner" sub="Số hộp lặp lại" node="settings/srs-boxes" trailing={<Val v="8" />} />
          <window.ListRow icon="timeline" title="Khoảng cách (ngày)" sub="1 · 3 · 7 · 14 · 30 · 60 · 120" node="settings/srs-intervals" trailing={<Val v="" />} />
          <window.ListRow icon="notifications_active" title="Thông báo đến hạn" last node="settings/srs-notif"
            trailing={<MxSwitch checked={notif} onChange={setNotif} node="settings/srs-notif-switch" />} />
        </MxCard>
        <Label>KHÁC</Label>
        <MxCard padding="sm">
          <window.ListRow icon="sports_esports" title="Cài đặt trò chơi" sub="5 từ/ván · ngẫu nhiên" node="settings/games" trailing={<Val v="" />} />
          <window.ListRow icon="palette" title="Chủ đề" sub="Sáng · màu mặc định" last node="settings/theme" trailing={<Val v="" />} />
        </MxCard>
      </MxScaffold>
    );
  }

  const loaded = (
    <MxScaffold node="settings/screen" appBar={bar} bottomNav={nav}>
      <Profile />
      <Label>HỌC TẬP</Label>
      <MxCard padding="sm">
        {GROUPS.slice(0, 5).map((g, i) => (
          <window.ListRow key={i} icon={g.icon} title={g.title} sub={g.sub} last={i === 4} node={'settings/g-' + i} trailing={<Val v={g.val || ''} />} />
        ))}
      </MxCard>
      <Label>ỨNG DỤNG</Label>
      <MxCard padding="sm">
        {GROUPS.slice(5).map((g, i) => (
          <window.ListRow key={i} icon={g.icon} title={g.title} sub={g.sub} last={i === GROUPS.length - 6} node={'settings/g-' + (i + 5)} trailing={<Val v={g.val || ''} />} />
        ))}
      </MxCard>
    </MxScaffold>
  );

  if (state === 'value-picker') {
    return (
      <React.Fragment>
        {loaded}
        <window.Scrim node="settings/picker-scrim">
          <window.Sheet title="Số từ mỗi ván" node="settings/picker-sheet">
            {['5', '10', '20'].map((v, i) => (
              <window.MenuItem key={v} icon={i === 0 ? 'check' : 'circle'} label={v + ' từ'} node={'settings/words-' + v}
                trailing={i === 0 ? <span className="material-symbols-rounded" style={{ color: 'var(--memox-primary)' }}>check</span> : null} />
            ))}
          </window.Sheet>
        </window.Scrim>
      </React.Fragment>
    );
  }

  return loaded;
}

window.Settings = Settings;
})();
