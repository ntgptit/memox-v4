/* MemoX — Dashboard (Today). States: loaded · empty · loading · goal-met · streak-reset */
(function () {
const NS = window.MemoXDesignSystem_2ffa54;
const { MxScaffold, MxAppBar, MxBottomNav, MxCard, MxSectionHeader, MxButton, MxIconButton, MxAvatar } = NS;

const NAV = [
  { id: 'home', label: 'Today', icon: 'today' },
  { id: 'library', label: 'Library', icon: 'style' },
  { id: 'add', label: 'Add', icon: 'add_circle' },
  { id: 'stats', label: 'Stats', icon: 'insights' },
  { id: 'me', label: 'Profile', icon: 'person' },
];

const DECKS = [
  { icon: 'translate', tone: 'accent', name: 'TOPIK I — Vocabulary', meta: '320 cards · 48 due', due: 48, progress: 72 },
  { icon: 'menu_book', tone: 'warning', name: 'Basic Grammar', meta: '180 cards · 23 due', due: 23, progress: 54 },
  { icon: 'record_voice_over', tone: 'success', name: 'Daily Conversation', meta: '150 cards · 6 due', due: 6, progress: 88 },
];

function GoalRing({ pct }) {
  return (
    <window.Ring pct={pct}>
      <div style={{ fontWeight: 'var(--memox-font-weight-extrabold)', fontSize: 'var(--memox-font-size-base)' }}>{pct}%</div>
    </window.Ring>
  );
}

const Note = window.Note;

function Dashboard({ state = 'loaded' }) {
  const nav = <MxBottomNav items={NAV} value="home" node="shell/bottom-nav" />;
  const bar = (
    <MxAppBar large eyebrow="Saturday · 27 Jun" title="Good evening, Linh" node="dashboard/appbar"
      trailing={<React.Fragment>
        <MxIconButton icon="notifications" node="dashboard/notifications" />
        <MxAvatar name="Linh Tran" size="sm" />
      </React.Fragment>} />
  );

  if (state === 'loading') {
    const S = window.Skeleton;
    return (
      <MxScaffold node="dashboard/screen" appBar={bar} bottomNav={nav}>
        <MxCard><S w="40%" h={12} /><S w="55%" h={30} style={{ marginTop: 'var(--memox-space-2)' }} /></MxCard>
        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 'var(--memox-space-3)' }}>{[0, 1].map((i) => <MxCard key={i} padding="sm"><S w="60%" h={22} /><S w="45%" h={10} style={{ marginTop: 'var(--memox-space-2)' }} /></MxCard>)}</div>
        <S w="45%" h={16} />
        {[0, 1].map((i) => <MxCard key={i} padding="sm"><div style={{ display: 'flex', gap: 'var(--memox-space-4)', alignItems: 'center' }}><S w={48} h={48} r={16} /><div style={{ flex: 1 }}><S w="60%" h={14} /><S w="40%" h={10} style={{ marginTop: 'var(--memox-space-2)' }} /></div></div></MxCard>)}
      </MxScaffold>
    );
  }

  if (state === 'empty') {
    return (
      <MxScaffold node="dashboard/screen" appBar={bar} bottomNav={nav}>
        <Note icon="bolt" tone="accent" text="You haven't studied today — start to keep your streak!" />
        <MxCard variant="primary" node="dashboard/today">
          <div style={{ fontSize: 'var(--memox-font-size-sm)', fontWeight: 'var(--memox-font-weight-bold)', opacity: .9, letterSpacing: 'var(--memox-letter-spacing-wide)' }}>TODAY</div>
          <div style={{ display: 'flex', gap: 'var(--memox-space-7)', marginTop: 'var(--memox-space-2)' }}>
            <div><div style={{ fontSize: 'var(--memox-font-size-2xl)', fontWeight: 'var(--memox-font-weight-extrabold)' }}>00:00</div><div style={{ fontSize: 'var(--memox-font-size-sm)', opacity: .9 }}>time studied</div></div>
            <div><div style={{ fontSize: 'var(--memox-font-size-2xl)', fontWeight: 'var(--memox-font-weight-extrabold)' }}>0</div><div style={{ fontSize: 'var(--memox-font-size-sm)', opacity: .9 }}>words learned</div></div>
          </div>
          <MxButton variant="contrast" icon="play_arrow" block node="dashboard/start">Start studying</MxButton>
        </MxCard>
      </MxScaffold>
    );
  }

  const met = state === 'goal-met';
  const reset = state === 'streak-reset';
  const goalPct = met ? 100 : 70;
  const streak = met ? 13 : reset ? 0 : 12;

  return (
    <MxScaffold node="dashboard/screen" appBar={bar} bottomNav={nav}
      fab={<MxFabReview />}>
      {met ? <Note icon="celebration" tone="success" text="Daily goal reached! Streak +1." /> : null}
      {reset ? <Note icon="local_fire_department" tone="warning" text="Streak reset — study today to start again." /> : null}

      <MxCard variant="primary" node="dashboard/today">
        <div style={{ fontSize: 'var(--memox-font-size-sm)', fontWeight: 'var(--memox-font-weight-bold)', opacity: .9, letterSpacing: 'var(--memox-letter-spacing-wide)' }}>TODAY</div>
        <div style={{ display: 'flex', gap: 'var(--memox-space-7)', marginTop: 'var(--memox-space-2)' }}>
          <div><div style={{ fontSize: 'var(--memox-font-size-2xl)', fontWeight: 'var(--memox-font-weight-extrabold)' }}>12:30</div><div style={{ fontSize: 'var(--memox-font-size-sm)', opacity: .9 }}>time studied</div></div>
          <div><div style={{ fontSize: 'var(--memox-font-size-2xl)', fontWeight: 'var(--memox-font-weight-extrabold)' }}>24</div><div style={{ fontSize: 'var(--memox-font-size-sm)', opacity: .9 }}>words learned</div></div>
        </div>
      </MxCard>

      <MxCard node="dashboard/goal" style={{ flexDirection: 'row', alignItems: 'center', gap: 'var(--memox-space-4)' }}>
        <GoalRing pct={goalPct} />
        <div style={{ flex: 1, minWidth: 0 }}>
          <div style={{ fontWeight: 'var(--memox-font-weight-extrabold)', fontSize: 'var(--memox-font-size-md)' }}>Daily goal</div>
          <div style={{ fontSize: 'var(--memox-font-size-base)', color: 'var(--memox-text-secondary)', marginTop: 'var(--memox-space-1)' }}>{met ? '20/20 min · complete' : '14/20 min'}</div>
          <div style={{ fontSize: 'var(--memox-font-size-sm)', color: 'var(--memox-text-tertiary)', marginTop: 'var(--memox-space-1)' }}>Met when minutes OR words reached</div>
        </div>
      </MxCard>

      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 'var(--memox-space-3)' }}>
        <MxCard variant="primary-soft" padding="sm" node="dashboard/streak">
          <div style={{ display: 'flex', alignItems: 'center', gap: 'var(--memox-space-3)' }}>
            <span className="material-symbols-rounded" style={{ fontSize: 'var(--memox-font-size-xl)' }}>local_fire_department</span>
            <div><div style={{ fontSize: 'var(--memox-icon-size-md)', fontWeight: 'var(--memox-font-weight-extrabold)', lineHeight: 'var(--memox-line-height-none)' }}>{streak}</div><div style={{ fontSize: 'var(--memox-font-size-xs)', opacity: .85 }}>day streak</div></div>
          </div>
        </MxCard>
        <MxCard variant="muted" padding="sm" node="dashboard/mastered">
          <div style={{ display: 'flex', alignItems: 'center', gap: 'var(--memox-space-3)' }}>
            <span className="material-symbols-rounded" style={{ fontSize: 'var(--memox-font-size-xl)', color: 'var(--memox-success)' }}>verified</span>
            <div><div style={{ fontSize: 'var(--memox-icon-size-md)', fontWeight: 'var(--memox-font-weight-extrabold)', lineHeight: 'var(--memox-line-height-none)' }}>55%</div><div style={{ fontSize: 'var(--memox-font-size-xs)', color: 'var(--memox-text-secondary)' }}>mastered</div></div>
          </div>
        </MxCard>
      </div>

      <MxSectionHeader title="Continue studying" caption="3 decks due today" action="See all" node="dashboard/decks-head" />
      {DECKS.map((d, i) => <MxCard key={i} padding="sm" interactive node={'dashboard/deck-' + i}><window.DeckRow {...d} /></MxCard>)}
    </MxScaffold>
  );
}

function MxFabReview() {
  const { MxFab } = NS;
  return <MxFab icon="bolt" label="Review" node="dashboard/quick-review" />;
}

window.Dashboard = Dashboard;
})();
