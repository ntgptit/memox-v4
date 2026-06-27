/* MemoX — Settings. States: loaded · group-expanded · value-picker. (No Premium in v1.) */
(function () {
const NS = window.MemoXDesignSystem_2ffa54;
const { MxScaffold, MxAppBar, MxBottomNav, MxCard, MxAvatar, MxSwitch } = NS;

const NAV = [
  { id: 'home', label: 'Today', icon: 'today' },
  { id: 'library', label: 'Library', icon: 'style' },
  { id: 'add', label: 'Add', icon: 'add_circle' },
  { id: 'stats', label: 'Stats', icon: 'insights' },
  { id: 'me', label: 'Profile', icon: 'person' },
];

const GROUPS = [
  { icon: 'translate', title: 'Language', sub: '한국어 → English', val: '' },
  { icon: 'format_shapes', title: 'Word display', sub: 'Native meaning · color by gender' },
  { icon: 'schedule', title: 'Spaced repetition', sub: 'Boxes: 8 · Notifications on', val: '' },
  { icon: 'sports_esports', title: 'Game settings', sub: '5 words/round · shuffle', val: '5' },
  { icon: 'record_voice_over', title: 'Voice', sub: 'TTS on · STT off' },
  { icon: 'notifications', title: 'Reminders', sub: '13:00 · Mon–Sun' },
  { icon: 'backup', title: 'Backup / Restore', sub: 'Auto · last today' },
  { icon: 'cloud_sync', title: 'Cloud sync', sub: 'linh@memox.app · alpha' },
  { icon: 'palette', title: 'Theme', sub: 'Light · default accent' },
];

function Val({ v }) {
  return (
    <div style={{ display: 'flex', alignItems: 'center', gap: 'var(--memox-space-1)', color: 'var(--memox-text-tertiary)' }}>
      {v ? <span style={{ fontWeight: 'var(--memox-font-weight-semibold)', fontSize: 'var(--memox-font-size-sm)' }}>{v}</span> : null}
      <span className="material-symbols-rounded" style={{ fontSize: 'var(--memox-font-size-lg)' }}>chevron_right</span>
    </div>
  );
}

function Label({ children }) {
  return <div style={{ fontSize: 'var(--memox-font-size-sm)', color: 'var(--memox-text-tertiary)', fontWeight: 'var(--memox-font-weight-bold)', letterSpacing: 'var(--memox-letter-spacing-wide)', margin: 'var(--memox-space-1) 0 0 var(--memox-space-1)' }}>{children}</div>;
}

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

function Settings({ state = 'loaded' }) {
  const [notif, setNotif] = React.useState(true);
  const bar = <MxAppBar large title="Settings" node="settings/appbar" />;
  const nav = <MxBottomNav items={NAV} value="me" node="shell/bottom-nav" />;

  if (state === 'group-expanded') {
    return (
      <MxScaffold node="settings/screen" appBar={bar} bottomNav={nav}>
        <Profile />
        <Label>SPACED REPETITION</Label>
        <MxCard padding="sm">
          <window.ListRow icon="grid_view" title="Leitner boxes" sub="Number of review boxes" node="settings/srs-boxes" trailing={<Val v="8" />} />
          <window.ListRow icon="timeline" title="Intervals (days)" sub="1 · 3 · 7 · 14 · 30 · 60 · 120" node="settings/srs-intervals" trailing={<Val v="" />} />
          <window.ListRow icon="notifications_active" title="Due notifications" last node="settings/srs-notif"
            trailing={<MxSwitch checked={notif} onChange={setNotif} node="settings/srs-notif-switch" />} />
        </MxCard>
        <Label>OTHER</Label>
        <MxCard padding="sm">
          <window.ListRow icon="sports_esports" title="Game settings" sub="5 words/round · shuffle" node="settings/games" trailing={<Val v="" />} />
          <window.ListRow icon="palette" title="Theme" sub="Light · default accent" last node="settings/theme" trailing={<Val v="" />} />
        </MxCard>
      </MxScaffold>
    );
  }

  const loaded = (
    <MxScaffold node="settings/screen" appBar={bar} bottomNav={nav}>
      <Profile />
      <Label>STUDYING</Label>
      <MxCard padding="sm">
        {GROUPS.slice(0, 5).map((g, i) => (
          <window.ListRow key={i} icon={g.icon} title={g.title} sub={g.sub} last={i === 4} node={'settings/g-' + i} trailing={<Val v={g.val || ''} />} />
        ))}
      </MxCard>
      <Label>APP</Label>
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
          <window.Sheet title="Words per round" node="settings/picker-sheet">
            {['5', '10', '20'].map((v, i) => (
              <window.MenuItem key={v} icon={i === 0 ? 'check' : 'circle'} label={v + ' words'} node={'settings/words-' + v}
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
