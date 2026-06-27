/* MemoX — Statistics (Stats). States: loading · loaded · insufficient · scope-switch */
(function () {
const NS = window.MemoXDesignSystem_2ffa54;
const { MxScaffold, MxAppBar, MxBottomNav, MxCard, MxSectionHeader, MxSegmentedControl } = NS;

const NAV = [
  { id: 'home', label: 'Today', icon: 'today' },
  { id: 'library', label: 'Library', icon: 'style' },
  { id: 'add', label: 'Add', icon: 'add_circle' },
  { id: 'stats', label: 'Stats', icon: 'insights' },
  { id: 'me', label: 'Profile', icon: 'person' },
];

function Bars({ data, labels, tone }) {
  const max = Math.max.apply(null, data);
  return (
    <div style={{ display: 'flex', alignItems: 'flex-end', gap: 'var(--memox-space-2)', height: 'var(--memox-size-2xl)' }}>
      {data.map((v, i) => (
        <div key={i} style={{ flex: 1, display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 'var(--memox-space-1)', height: '100%', justifyContent: 'flex-end' }}>
          <div style={{ width: '100%', height: (v / max * 100) + '%', background: tone || 'var(--memox-primary)', borderRadius: 'var(--memox-radius-xs)', minHeight: 'var(--memox-size-3xs)' }} />
          <span style={{ fontSize: 'var(--memox-font-size-xs)', color: 'var(--memox-text-tertiary)' }}>{labels[i]}</span>
        </div>
      ))}
    </div>
  );
}

function Heatmap() {
  return (
    <div style={{ display: 'flex', gap: 'var(--memox-space-1)', overflowX: 'auto' }}>
      {Array.from({ length: 14 }).map((_, w) => (
        <div key={w} style={{ display: 'flex', flexDirection: 'column', gap: 'var(--memox-space-1)' }}>
          {Array.from({ length: 7 }).map((_, d) => {
            const op = [0.08, 0.25, 0.45, 0.7, 1][(w * 7 + d * 3) % 5];
            return <div key={d} style={{ width: 'var(--memox-size-xs)', height: 'var(--memox-size-xs)', borderRadius: 'var(--memox-radius-xs)', background: 'var(--memox-primary)', opacity: op }} />;
          })}
        </div>
      ))}
    </div>
  );
}

function Donut({ pct }) {
  return (
    <div style={{ display: 'flex', justifyContent: 'center', padding: 'var(--memox-space-1) 0' }}>
      <div style={{ position: 'relative', width: 'var(--memox-size-2xl)', height: 'var(--memox-size-2xl)', borderRadius: '50%', background: 'conic-gradient(var(--memox-success) ' + pct + '%, var(--memox-surface-sunken) 0)' }}>
        <div style={{ position: 'absolute', inset: 'var(--memox-space-4)', borderRadius: '50%', background: 'var(--memox-surface)', display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center' }}>
          <div style={{ fontSize: 'var(--memox-font-size-xl)', fontWeight: 'var(--memox-font-weight-extrabold)' }}>{pct}%</div>
          <div style={{ fontSize: 'var(--memox-font-size-sm)', color: 'var(--memox-text-secondary)' }}>accuracy</div>
        </div>
      </div>
    </div>
  );
}

function Statistics({ state = 'loaded' }) {
  const bar = <MxAppBar large title="Stats" node="statistics/appbar" />;
  const nav = <MxBottomNav items={NAV} value="stats" node="shell/bottom-nav" />;
  const scope = (
    <MxSegmentedControl value={state === 'scope-switch' ? 'all' : 'pair'} onChange={() => {}} block node="statistics/scope"
      segments={[{ value: 'pair', label: 'This pair' }, { value: 'all', label: 'All' }]} />
  );

  if (state === 'loading') {
    const S = window.Skeleton;
    return (
      <MxScaffold node="statistics/screen" appBar={bar} bottomNav={nav}>
        <S h={40} r={999} />
        {[0, 1, 2].map((i) => <MxCard key={i}><S w="45%" h={14} /><S h={110} r={12} style={{ marginTop: 'var(--memox-space-3)' }} /></MxCard>)}
      </MxScaffold>
    );
  }

  if (state === 'insufficient') {
    return (
      <MxScaffold node="statistics/screen" appBar={bar} bottomNav={nav}>
        {scope}
        <window.EmptyState node="statistics/insufficient" icon="bar_chart" title="Not enough data"
          text="Study a few more sessions and MemoX will chart your progress, streaks and due forecast." />
      </MxScaffold>
    );
  }

  return (
    <MxScaffold node="statistics/screen" appBar={bar} bottomNav={nav}>
      {scope}

      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 'var(--memox-space-3)' }}>
        <MxCard variant="primary-soft" padding="sm" node="statistics/streak-current" style={{ alignItems: 'center' }}><window.Stat n="12" l="current streak" /></MxCard>
        <MxCard variant="muted" padding="sm" node="statistics/streak-longest" style={{ alignItems: 'center' }}><window.Stat n="28" l="longest" /></MxCard>
      </div>

      <div data-mx-node="statistics/heatmap">
        <MxSectionHeader title="Study calendar" caption="last 14 weeks" node="statistics/heatmap-head" />
        <MxCard><Heatmap /></MxCard>
      </div>

      <div data-mx-node="statistics/weekly">
        <MxSectionHeader title="Time per week" caption="min / day" node="statistics/weekly-head" />
        <MxCard><Bars data={[12, 18, 9, 24, 15, 30, 20]} labels={['M', 'T', 'W', 'T', 'F', 'S', 'S']} /></MxCard>
      </div>

      <div data-mx-node="statistics/leitner">
        <MxSectionHeader title="Leitner box distribution" caption="cards in boxes 1–8" node="statistics/leitner-head" />
        <MxCard><Bars data={[40, 28, 22, 18, 12, 9, 6, 4]} labels={['1', '2', '3', '4', '5', '6', '7', '8']} tone="var(--memox-accent, var(--memox-primary))" /></MxCard>
      </div>

      <div data-mx-node="statistics/accuracy">
        <MxSectionHeader title="Accuracy" caption="30 days" node="statistics/accuracy-head" />
        <MxCard><Donut pct={88} /></MxCard>
      </div>

      <div data-mx-node="statistics/overview">
        <MxSectionHeader title="Library overview" node="statistics/overview-head" />
        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr 1fr', gap: 'var(--memox-space-3)' }}>
          {[['1240', 'total'], ['680', 'mastered'], ['96', 'due']].map(([n, l], i) => (
            <MxCard key={i} variant="muted" padding="sm" node={'statistics/ov-' + i} style={{ alignItems: 'center' }}><window.Stat n={n} l={l} /></MxCard>
          ))}
        </div>
      </div>
    </MxScaffold>
  );
}

window.Statistics = Statistics;
})();
