/* MemoX — Dashboard (Today). States: loaded · empty · loading · goal-met · streak-reset
   Feature-local components: components/{TodaySummary,GoalCard,StreakCard,ContinueCard}.jsx */
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

const Note = window.Note;

function Dashboard({ state = 'loaded' }) {
  const { TodaySummary, GoalCard, StreakCard, ContinueCard } = window.MemoXDashboard;
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
        <TodaySummary time="00:00" words="0">
          <MxButton variant="contrast" icon="play_arrow" block node="dashboard/start">Start studying</MxButton>
        </TodaySummary>
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

      <TodaySummary time="12:30" words="24" />

      <GoalCard pct={goalPct} met={met} />

      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 'var(--memox-space-3)' }}>
        <StreakCard streak={streak} />
        <MxCard variant="muted" padding="sm" node="dashboard/mastered">
          <div style={{ display: 'flex', alignItems: 'center', gap: 'var(--memox-space-3)' }}>
            <span className="material-symbols-rounded" style={{ fontSize: 'var(--memox-font-size-xl)', color: 'var(--memox-success)' }}>verified</span>
            <div><div style={{ fontSize: 'var(--memox-icon-size-md)', fontWeight: 'var(--memox-font-weight-extrabold)', lineHeight: 'var(--memox-line-height-none)' }}>55%</div><div style={{ fontSize: 'var(--memox-font-size-xs)', color: 'var(--memox-text-secondary)' }}>mastered</div></div>
          </div>
        </MxCard>
      </div>

      <MxSectionHeader title="Continue studying" caption="3 decks due today" action="See all" node="dashboard/decks-head" />
      {DECKS.map((d, i) => <ContinueCard key={i} deck={d} index={i} />)}
    </MxScaffold>
  );
}

function MxFabReview() {
  const { MxFab } = NS;
  return <MxFab icon="bolt" label="Review" node="dashboard/quick-review" />;
}

window.Dashboard = Dashboard;
})();
