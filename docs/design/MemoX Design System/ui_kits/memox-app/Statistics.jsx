/* MemoX — Statistics (Thống kê). States: loading · loaded · insufficient · scope-switch */
(function () {
const NS = window.MemoXDesignSystem_2ffa54;
const { MxScaffold, MxAppBar, MxBottomNav, MxCard, MxSectionHeader, MxSegmentedControl } = NS;

const NAV = [
  { id: 'home', label: 'Hôm nay', icon: 'today' },
  { id: 'library', label: 'Thư viện', icon: 'style' },
  { id: 'add', label: 'Thêm', icon: 'add_circle' },
  { id: 'stats', label: 'Thống kê', icon: 'insights' },
  { id: 'me', label: 'Hồ sơ', icon: 'person' },
];

function Bars({ data, labels, tone }) {
  const max = Math.max.apply(null, data);
  return (
    <div style={{ display: 'flex', alignItems: 'flex-end', gap: 6, height: 120 }}>
      {data.map((v, i) => (
        <div key={i} style={{ flex: 1, display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 4, height: '100%', justifyContent: 'flex-end' }}>
          <div style={{ width: '100%', height: (v / max * 100) + '%', background: tone || 'var(--memox-primary)', borderRadius: 6, minHeight: 4 }} />
          <span style={{ fontSize: 10, color: 'var(--memox-text-tertiary)' }}>{labels[i]}</span>
        </div>
      ))}
    </div>
  );
}

function Heatmap() {
  return (
    <div style={{ display: 'flex', gap: 3, overflowX: 'auto' }}>
      {Array.from({ length: 14 }).map((_, w) => (
        <div key={w} style={{ display: 'flex', flexDirection: 'column', gap: 3 }}>
          {Array.from({ length: 7 }).map((_, d) => {
            const op = [0.08, 0.25, 0.45, 0.7, 1][(w * 7 + d * 3) % 5];
            return <div key={d} style={{ width: 13, height: 13, borderRadius: 4, background: 'var(--memox-primary)', opacity: op }} />;
          })}
        </div>
      ))}
    </div>
  );
}

function Donut({ pct }) {
  return (
    <div style={{ display: 'flex', justifyContent: 'center', padding: '4px 0' }}>
      <div style={{ position: 'relative', width: 130, height: 130, borderRadius: '50%', background: 'conic-gradient(var(--memox-success) ' + pct + '%, var(--memox-surface-sunken) 0)' }}>
        <div style={{ position: 'absolute', inset: 16, borderRadius: '50%', background: 'var(--memox-surface)', display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center' }}>
          <div style={{ fontSize: 26, fontWeight: 800 }}>{pct}%</div>
          <div style={{ fontSize: 'var(--memox-font-size-sm)', color: 'var(--memox-text-secondary)' }}>chính xác</div>
        </div>
      </div>
    </div>
  );
}

function Statistics({ state = 'loaded' }) {
  const bar = <MxAppBar large title="Thống kê" node="statistics/appbar" />;
  const nav = <MxBottomNav items={NAV} value="stats" node="shell/bottom-nav" />;
  const scope = (
    <MxSegmentedControl value={state === 'scope-switch' ? 'all' : 'pair'} onChange={() => {}} block node="statistics/scope"
      segments={[{ value: 'pair', label: 'Cặp này' }, { value: 'all', label: 'Toàn app' }]} />
  );

  if (state === 'loading') {
    const S = window.Skeleton;
    return (
      <MxScaffold node="statistics/screen" appBar={bar} bottomNav={nav}>
        <S h={40} r={999} />
        {[0, 1, 2].map((i) => <MxCard key={i}><S w="45%" h={14} /><S h={110} r={12} style={{ marginTop: 10 }} /></MxCard>)}
      </MxScaffold>
    );
  }

  if (state === 'insufficient') {
    return (
      <MxScaffold node="statistics/screen" appBar={bar} bottomNav={nav}>
        {scope}
        <window.EmptyState node="statistics/insufficient" icon="bar_chart" title="Chưa đủ dữ liệu"
          text="Học thêm vài phiên để MemoX vẽ thống kê tiến độ, streak và dự báo đến hạn cho bạn." />
      </MxScaffold>
    );
  }

  return (
    <MxScaffold node="statistics/screen" appBar={bar} bottomNav={nav}>
      {scope}

      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 'var(--memox-space-3)' }}>
        <MxCard variant="primary-soft" padding="sm" node="statistics/streak-current" style={{ alignItems: 'center' }}><window.Stat n="12" l="streak hiện tại" /></MxCard>
        <MxCard variant="muted" padding="sm" node="statistics/streak-longest" style={{ alignItems: 'center' }}><window.Stat n="28" l="dài nhất" /></MxCard>
      </div>

      <div data-mx-node="statistics/heatmap">
        <MxSectionHeader title="Lịch học" caption="14 tuần gần nhất" node="statistics/heatmap-head" />
        <MxCard><Heatmap /></MxCard>
      </div>

      <div data-mx-node="statistics/weekly">
        <MxSectionHeader title="Thời gian theo tuần" caption="phút / ngày" node="statistics/weekly-head" />
        <MxCard><Bars data={[12, 18, 9, 24, 15, 30, 20]} labels={['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN']} /></MxCard>
      </div>

      <div data-mx-node="statistics/leitner">
        <MxSectionHeader title="Phân bố ô Leitner" caption="số thẻ theo ô 1–8" node="statistics/leitner-head" />
        <MxCard><Bars data={[40, 28, 22, 18, 12, 9, 6, 4]} labels={['1', '2', '3', '4', '5', '6', '7', '8']} tone="var(--memox-accent, var(--memox-primary))" /></MxCard>
      </div>

      <div data-mx-node="statistics/accuracy">
        <MxSectionHeader title="Độ chính xác" caption="30 ngày" node="statistics/accuracy-head" />
        <MxCard><Donut pct={88} /></MxCard>
      </div>

      <div data-mx-node="statistics/overview">
        <MxSectionHeader title="Tổng quan thư viện" node="statistics/overview-head" />
        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr 1fr', gap: 'var(--memox-space-3)' }}>
          {[['1240', 'tổng từ'], ['680', 'đã thuộc'], ['96', 'đến hạn']].map(([n, l], i) => (
            <MxCard key={i} variant="muted" padding="sm" node={'statistics/ov-' + i} style={{ alignItems: 'center' }}><window.Stat n={n} l={l} /></MxCard>
          ))}
        </div>
      </div>
    </MxScaffold>
  );
}

window.Statistics = Statistics;
})();
