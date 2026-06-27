/* MemoX — Study result (Kết quả phiên học). States: standard · goal-met · goal-missed · many-wrong */
(function () {
const NS = window.MemoXDesignSystem_2ffa54;
const { MxScaffold, MxAppBar, MxCard, MxButton, MxIconButton, MxIconTile } = NS;

const HEAD = {
  standard: { icon: 'task_alt', tone: 'accent', title: 'Hoàn thành phiên', text: 'Bạn đã ôn 24 thẻ trong phiên này.' },
  'goal-met': { icon: 'celebration', tone: 'success', title: 'Đạt mục tiêu hôm nay!', text: 'Chuỗi học +1 → 13 ngày liên tiếp.' },
  'goal-missed': { icon: 'trending_up', tone: 'warning', title: 'Gần đạt rồi!', text: 'Còn 6 phút nữa để đạt mục tiêu hôm nay.' },
  'many-wrong': { icon: 'refresh', tone: 'error', title: 'Có vài từ chưa chắc', text: 'Bạn trả lời sai 8 thẻ — ôn lại ngay để nhớ lâu hơn.' },
};

function Cta({ state }) {
  if (state === 'goal-missed') {
    return (<React.Fragment>
      <MxButton variant="primary" icon="bolt" block node="study-result/continue">Học tiếp</MxButton>
      <MxButton variant="ghost" block node="study-result/later">Để sau</MxButton>
    </React.Fragment>);
  }
  if (state === 'many-wrong') {
    return (<React.Fragment>
      <MxButton variant="primary" icon="replay" block node="study-result/review-wrong">Ôn lại 8 thẻ</MxButton>
      <MxButton variant="ghost" block node="study-result/library">Về thư viện</MxButton>
    </React.Fragment>);
  }
  return (<React.Fragment>
    <MxButton variant="primary" icon="bolt" block node="study-result/continue">Tiếp tục học</MxButton>
    <MxButton variant="ghost" block node="study-result/library">Về thư viện</MxButton>
  </React.Fragment>);
}

function StudyResult({ state = 'standard' }) {
  const h = HEAD[state] || HEAD.standard;
  const met = state === 'goal-met';
  const bar = <MxAppBar node="study-result/appbar" title="Kết quả" leading={<MxIconButton icon="close" node="study-result/close" />} />;

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
        {[['24', 'thẻ'], ['88%', 'đúng'], ['6:30', 'phút']].map(([n, l], i) => (
          <MxCard key={i} variant="muted" padding="sm" node={'study-result/stat-' + i} style={{ alignItems: 'center' }}>
            <window.Stat n={n} l={l} />
          </MxCard>
        ))}
      </div>

      <MxCard node="study-result/goal" variant="primary-soft" style={{ gap: 'var(--memox-space-3)' }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 'var(--memox-space-4)' }}>
          <span className="material-symbols-rounded" style={{ fontSize: 28 }}>local_fire_department</span>
          <div style={{ flex: 1, minWidth: 0 }}>
            <div style={{ fontWeight: 800, fontSize: 'var(--memox-font-size-md)' }}>{met ? '13 ngày' : '12 ngày'}</div>
            <div style={{ fontSize: 'var(--memox-font-size-sm)', opacity: .85 }}>chuỗi học{met ? ' · +1 hôm nay' : ''}</div>
          </div>
        </div>
        <div>
          <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: 'var(--memox-font-size-sm)', marginBottom: 6, opacity: .9 }}>
            <span>Mục tiêu hôm nay</span><span>{met ? '20/20 phút' : '14/20 phút'}</span>
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
