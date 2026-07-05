/* MemoX — Dashboard local: TodaySummary (today's time + words hero card).
   `children` is an optional CTA slot (kept for contract stability; currently
   unused — the first-run empty state renders OnboardingHero instead). */
(function () {
const NS = window.MemoXDesignSystem_2ffa54;
const { MxCard } = NS;

function TodaySummary({ time, words, children }) {
  return (
    <MxCard variant="primary" node="dashboard/today">
      <div style={{ fontSize: 'var(--memox-font-size-sm)', fontWeight: 'var(--memox-font-weight-bold)', opacity: .9, letterSpacing: 'var(--memox-letter-spacing-wide)' }}>TODAY</div>
      <div style={{ display: 'flex', gap: 'var(--memox-space-7)', marginTop: 'var(--memox-space-2)' }}>
        <div><div style={{ fontSize: 'var(--memox-font-size-2xl)', fontWeight: 'var(--memox-font-weight-extrabold)' }}>{time}</div><div style={{ fontSize: 'var(--memox-font-size-sm)', opacity: .9 }}>time studied</div></div>
        <div><div style={{ fontSize: 'var(--memox-font-size-2xl)', fontWeight: 'var(--memox-font-weight-extrabold)' }}>{words}</div><div style={{ fontSize: 'var(--memox-font-size-sm)', opacity: .9 }}>words learned</div></div>
      </div>
      {children}
    </MxCard>
  );
}

window.MemoXDashboard = window.MemoXDashboard || {};
window.MemoXDashboard.TodaySummary = TodaySummary;
})();
