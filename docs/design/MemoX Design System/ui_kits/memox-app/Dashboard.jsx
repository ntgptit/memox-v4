/* MemoX — Dashboard (Today) screen. States: loaded · empty · loading */
(function () {
const NS = window.MemoXDesignSystem_2ffa54;
const { MxScaffold, MxAppBar, MxBottomNav, MxCard, MxSectionHeader, MxButton, MxIconButton, MxAvatar, MxFab, MxBadge, MxIconTile } = NS;

const NAV = [
  { id: 'home', label: 'Today', icon: 'today' },
  { id: 'library', label: 'Library', icon: 'style' },
  { id: 'add', label: 'Add', icon: 'add_circle' },
  { id: 'stats', label: 'Stats', icon: 'insights' },
  { id: 'me', label: 'Profile', icon: 'person' },
];

const DECKS = [
  { icon: 'translate', tone: 'accent', name: 'Japanese N5', meta: 'Kanji · 320 cards', due: 48, progress: 72 },
  { icon: 'functions', tone: 'success', name: 'Calculus II', meta: 'Derivatives · 140 cards', due: 12, progress: 54 },
  { icon: 'biotech', tone: 'warning', name: 'Cell Biology', meta: 'Midterm prep · 86 cards', due: 23, progress: 38 },
];

function Bar() {
  return (
    <MxAppBar large eyebrow="Tuesday · 27 June" title="Good evening, Linh"
      trailing={<React.Fragment>
        <MxIconButton icon="notifications" node="dashboard/notifications" />
        <MxAvatar name="Linh Tran" size="sm" />
      </React.Fragment>} node="dashboard/appbar" />
  );
}

function Dashboard({ state = 'loaded' }) {
  const nav = <MxBottomNav items={NAV} value="home" node="shell/bottom-nav" />;

  if (state === 'empty') {
    return (
      <MxScaffold node="dashboard/screen" appBar={<MxAppBar large eyebrow="Welcome to MemoX" title="Let's get started" node="dashboard/appbar" />} bottomNav={nav}>
        <window.EmptyState node="dashboard/empty" icon="auto_stories" title="No decks yet"
          text="Create a deck and add a few cards — your daily reviews show up here."
          action={<MxButton variant="primary" icon="add" node="dashboard/create-first">Create your first deck</MxButton>} />
      </MxScaffold>
    );
  }

  if (state === 'loading') {
    const S = window.Skeleton;
    return (
      <MxScaffold node="dashboard/screen" appBar={<Bar />} bottomNav={nav}>
        <MxCard><S w="40%" h={12} /><S w="55%" h={34} style={{ marginTop: 6 }} /><S w="70%" h={12} style={{ marginTop: 10 }} /></MxCard>
        <S w="45%" h={16} />
        <MxCard>
          {[0, 1, 2].map((i) => (
            <div key={i} style={{ display: 'flex', gap: 14, alignItems: 'center', marginBottom: i < 2 ? 18 : 0 }}>
              <S w={48} h={48} r={16} />
              <div style={{ flex: 1 }}><S w="60%" h={14} /><S w="40%" h={10} style={{ marginTop: 8 }} /></div>
            </div>
          ))}
        </MxCard>
      </MxScaffold>
    );
  }

  // loaded
  return (
    <MxScaffold node="dashboard/screen" appBar={<Bar />} bottomNav={nav}
      fab={<MxFab icon="bolt" label="Review" node="dashboard/quick-review" />}>
      <MxCard variant="primary" node="dashboard/due-summary">
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start' }}>
          <div>
            <div style={{ fontSize: 'var(--memox-font-size-sm)', fontWeight: 700, opacity: .9, letterSpacing: '.06em' }}>DUE NOW</div>
            <div style={{ fontSize: 38, fontWeight: 800, lineHeight: 1, margin: '6px 0' }}>83</div>
            <div style={{ fontSize: 'var(--memox-font-size-sm)', opacity: .9 }}>cards across 3 decks</div>
          </div>
          <span className="material-symbols-rounded" style={{ fontSize: 30, opacity: .9 }}>schedule</span>
        </div>
        <MxButton variant="contrast" icon="play_arrow" block node="dashboard/start-review">Start review</MxButton>
      </MxCard>

      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 'var(--memox-space-3)' }}>
        <MxCard variant="primary-soft" padding="sm" node="dashboard/streak">
          <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
            <span className="material-symbols-rounded" style={{ fontSize: 26 }}>local_fire_department</span>
            <div><div style={{ fontSize: 22, fontWeight: 800, lineHeight: 1 }}>12</div><div style={{ fontSize: 12, opacity: .85 }}>day streak</div></div>
          </div>
        </MxCard>
        <MxCard variant="muted" padding="sm" node="dashboard/accuracy">
          <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
            <span className="material-symbols-rounded" style={{ fontSize: 26, color: 'var(--memox-success)' }}>check_circle</span>
            <div><div style={{ fontSize: 22, fontWeight: 800, lineHeight: 1 }}>94%</div><div style={{ fontSize: 12, color: 'var(--memox-text-secondary)' }}>accuracy</div></div>
          </div>
        </MxCard>
      </div>

      <MxSectionHeader title="Continue studying" caption="3 decks due today" action="See all" node="dashboard/decks-head" />
      <MxCard node="dashboard/deck-list" style={{ gap: 'var(--memox-space-5)' }}>
        {DECKS.map((d, i) => <window.DeckRow key={i} {...d} node={'dashboard/deck-' + i} />)}
      </MxCard>
    </MxScaffold>
  );
}

window.Dashboard = Dashboard;
})();
