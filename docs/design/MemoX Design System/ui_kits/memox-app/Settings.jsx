/* MemoX — Settings screen. State: loaded */
(function () {
const NS = window.MemoXDesignSystem_2ffa54;
const { MxScaffold, MxAppBar, MxBottomNav, MxCard, MxIconButton, MxAvatar, MxSwitch, MxSegmentedControl, MxIconTile, MxBadge, MxButton } = NS;

const NAV = [
  { id: 'home', label: 'Today', icon: 'today' },
  { id: 'library', label: 'Library', icon: 'style' },
  { id: 'add', label: 'Add', icon: 'add_circle' },
  { id: 'stats', label: 'Stats', icon: 'insights' },
  { id: 'me', label: 'Profile', icon: 'person' },
];

function Row({ icon, tone, title, sub, trailing, node, last }) {
  const { MxIconTile } = NS;
  return (
    <div data-mx-node={node} style={{ display: 'flex', alignItems: 'center', gap: 'var(--memox-space-4)', paddingBottom: last ? 0 : 'var(--memox-space-4)', marginBottom: last ? 0 : 'var(--memox-space-4)', borderBottom: last ? 'none' : '1px solid var(--memox-divider)' }}>
      <MxIconTile icon={icon} tone={tone} />
      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{ fontWeight: 700, fontSize: 'var(--memox-font-size-base)' }}>{title}</div>
        {sub ? <div style={{ fontSize: 'var(--memox-font-size-sm)', color: 'var(--memox-text-secondary)', marginTop: 2 }}>{sub}</div> : null}
      </div>
      {trailing}
    </div>
  );
}

function Settings({ state = 'loaded' }) {
  const [dark, setDark] = React.useState(false);
  const [remind, setRemind] = React.useState(true);
  const [sound, setSound] = React.useState(false);
  const [pace, setPace] = React.useState('20');

  return (
    <MxScaffold node="settings/screen"
      appBar={<MxAppBar large title="Settings" node="settings/appbar" />}
      bottomNav={<MxBottomNav items={NAV} value="me" node="shell/bottom-nav" />}>

      <MxCard node="settings/profile" style={{ flexDirection: 'row', alignItems: 'center', gap: 'var(--memox-space-4)' }}>
        <MxAvatar name="Linh Tran" size="lg" ring />
        <div style={{ flex: 1, minWidth: 0 }}>
          <div style={{ fontWeight: 800, fontSize: 'var(--memox-font-size-md)' }}>Linh Tran</div>
          <div style={{ fontSize: 'var(--memox-font-size-sm)', color: 'var(--memox-text-secondary)' }}>linh@memox.app</div>
        </div>
        <MxBadge tone="success" soft>PRO</MxBadge>
      </MxCard>

      <div data-mx-node="settings/group-prefs">
        <div style={{ fontSize: 'var(--memox-font-size-sm)', fontWeight: 700, color: 'var(--memox-text-tertiary)', letterSpacing: '.04em', margin: '0 0 8px 4px', textTransform: 'uppercase' }}>Preferences</div>
        <MxCard>
          <Row icon="dark_mode" title="Dark mode" sub="Match study time of day" node="settings/dark-mode" trailing={<MxSwitch checked={dark} onChange={setDark} node="settings/dark-mode-switch" />} />
          <Row icon="notifications" tone="warning" title="Daily reminder" sub="Every day at 8:00 PM" node="settings/reminder" trailing={<MxSwitch checked={remind} onChange={setRemind} node="settings/reminder-switch" />} />
          <Row icon="volume_up" tone="accent" title="Sound effects" node="settings/sound" last trailing={<MxSwitch checked={sound} onChange={setSound} node="settings/sound-switch" />} />
        </MxCard>
      </div>

      <div data-mx-node="settings/group-study">
        <div style={{ fontSize: 'var(--memox-font-size-sm)', fontWeight: 700, color: 'var(--memox-text-tertiary)', letterSpacing: '.04em', margin: '0 0 8px 4px', textTransform: 'uppercase' }}>Study</div>
        <MxCard style={{ gap: 'var(--memox-space-4)' }}>
          <Row icon="bolt" tone="success" title="New cards / day" sub="Across all decks" node="settings/pace" last
            trailing={null} />
          <MxSegmentedControl value={pace} onChange={setPace} block node="settings/pace-control"
            segments={[{ value: '10', label: '10' }, { value: '20', label: '20' }, { value: '40', label: '40' }]} />
        </MxCard>
      </div>

      <div data-mx-node="settings/group-about">
        <MxCard padding="sm">
          <Row icon="help" title="Help & feedback" node="settings/help" trailing={<MxIconButton icon="chevron_right" node="settings/help-go" />} />
          <Row icon="logout" tone="error" title="Sign out" node="settings/signout" last trailing={<MxIconButton icon="chevron_right" node="settings/signout-go" />} />
        </MxCard>
      </div>
    </MxScaffold>
  );
}

window.Settings = Settings;
})();
