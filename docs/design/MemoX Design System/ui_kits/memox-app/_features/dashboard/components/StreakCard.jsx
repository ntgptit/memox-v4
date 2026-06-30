/* MemoX — Dashboard local: StreakCard (day-streak stat). */
(function () {
const NS = window.MemoXDesignSystem_2ffa54;
const { MxCard } = NS;

function StreakCard({ streak }) {
  return (
    <MxCard variant="primary-soft" padding="sm" node="dashboard/streak">
      <div style={{ display: 'flex', alignItems: 'center', gap: 'var(--memox-space-3)' }}>
        <span className="material-symbols-rounded" style={{ fontSize: 'var(--memox-font-size-xl)' }}>local_fire_department</span>
        <div><div style={{ fontSize: 'var(--memox-icon-size-md)', fontWeight: 'var(--memox-font-weight-extrabold)', lineHeight: 'var(--memox-line-height-none)' }}>{streak}</div><div style={{ fontSize: 'var(--memox-font-size-xs)', opacity: .85 }}>day streak</div></div>
      </div>
    </MxCard>
  );
}

window.MemoXDashboard = window.MemoXDashboard || {};
window.MemoXDashboard.StreakCard = StreakCard;
})();
