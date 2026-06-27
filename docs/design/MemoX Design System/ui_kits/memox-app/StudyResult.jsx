/* MemoX — Study result. States: standard · goal-met · goal-missed · many-wrong */
(function () {
const NS = window.MemoXDesignSystem_2ffa54;
const { MxScaffold, MxAppBar, MxCard, MxButton, MxIconButton, MxIconTile } = NS;

const HEAD = {
  standard: { icon: 'task_alt', tone: 'accent', title: 'Session complete', text: 'You reviewed 24 cards this session.' },
  'goal-met': { icon: 'celebration', tone: 'success', title: 'Daily goal reached!', text: 'Streak +1 → 13 days in a row.' },
  'goal-missed': { icon: 'trending_up', tone: 'warning', title: 'Almost there!', text: '6 more minutes to hit today’s goal.' },
  'many-wrong': { icon: 'refresh', tone: 'error', title: 'A few shaky words', text: 'You missed 8 cards — review now to remember them longer.' },
};

function Cta({ state }) {
  if (state === 'goal-missed') {
    return (<React.Fragment>
      <MxButton variant="primary" icon="bolt" block node="study-result/continue">Keep going</MxButton>
      <MxButton variant="ghost" block node="study-result/later">Later</MxButton>
    </React.Fragment>);
  }
  if (state === 'many-wrong') {
    return (<React.Fragment>
      <MxButton variant="primary" icon="replay" block node="study-result/review-wrong">Review 8 cards</MxButton>
      <MxButton variant="ghost" block node="study-result/library">Back to library</MxButton>
    </React.Fragment>);
  }
  return (<React.Fragment>
    <MxButton variant="primary" icon="bolt" block node="study-result/continue">Keep studying</MxButton>
    <MxButton variant="ghost" block node="study-result/library">Back to library</MxButton>
  </React.Fragment>);
}

function StudyResult({ state = 'standard' }) {
  const h = HEAD[state] || HEAD.standard;
  const met = state === 'goal-met';
  const bar = <MxAppBar node="study-result/appbar" title="Results" leading={<MxIconButton icon="close" node="study-result/close" />} />;

  return (
    <MxScaffold node="study-result/screen" appBar={bar}>
      <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', textAlign: 'center', gap: 'var(--memox-space-3)', paddingTop: 'var(--memox-space-4)' }}>
        <MxIconTile icon={h.icon} tone={h.tone} size="lg" />
        <div>
          <div style={{ fontSize: 'var(--memox-font-size-lg)', fontWeight: 800, letterSpacing: '-.02em' }}>{h.title}</div>
          <div style={{ fontSize: 'var(--memox-font-size-base)', color: 'var(--memox-text-secondary)', marginTop: 4, maxWidth: 260 }}>{h.text}</div>
        </div>
      </div>

      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr 1fr', gap: 'var(--memox-space-3)' }}>
        {[['24', 'cards'], ['88%', 'correct'], ['6:30', 'min']].map(([n, l], i) => (
          <MxCard key={i} variant="muted" padding="sm" node={'study-result/stat-' + i} style={{ alignItems: 'center' }}>
            <window.Stat n={n} l={l} />
          </MxCard>
        ))}
      </div>

      <MxCard node="study-result/goal" variant="primary-soft" style={{ gap: 'var(--memox-space-3)' }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 'var(--memox-space-4)' }}>
          <span className="material-symbols-rounded" style={{ fontSize: 28 }}>local_fire_department</span>
          <div style={{ flex: 1, minWidth: 0 }}>
            <div style={{ fontWeight: 800, fontSize: 'var(--memox-font-size-md)' }}>{met ? '13 days' : '12 days'}</div>
            <div style={{ fontSize: 'var(--memox-font-size-sm)', opacity: .85 }}>day streak{met ? ' · +1 today' : ''}</div>
          </div>
        </div>
        <div>
          <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: 'var(--memox-font-size-sm)', marginBottom: 6, opacity: .9 }}>
            <span>Today's goal</span><span>{met ? '20/20 min' : '14/20 min'}</span>
          </div>
          <window.ProgressBar value={met ? 100 : 70} height={8} tone="var(--memox-on-primary-soft)" node="study-result/goal-bar" />
        </div>
      </MxCard>

      <div style={{ display: 'flex', flexDirection: 'column', gap: 'var(--memox-space-2)' }}>
        <Cta state={state} />
      </div>
    </MxScaffold>
  );
}

window.StudyResult = StudyResult;
})();
