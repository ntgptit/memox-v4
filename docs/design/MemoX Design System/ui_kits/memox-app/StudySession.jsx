/* MemoX — Study session (Phiên học, NewLearn 5 chặng + DueReview).
   States: stage1-review · stage2-matching · stage3-choice · stage4-recall · stage5-typing · relearn · due-review · exit */
(function () {
const NS = window.MemoXDesignSystem_2ffa54;
const { MxScaffold, MxAppBar, MxIconButton, MxCard, MxButton } = NS;

const META = {
  'stage1-review': { label: 'Chặng 1 · Xem lại', pct: 16 },
  'stage2-matching': { label: 'Chặng 2 · Ghép đôi', pct: 32 },
  'stage3-choice': { label: 'Chặng 3 · Đoán', pct: 48 },
  'stage4-recall': { label: 'Chặng 4 · Nhớ lại', pct: 64 },
  'stage5-typing': { label: 'Chặng 5 · Điền', pct: 84 },
  'relearn': { label: 'Chặng 3 · Đoán', pct: 48 },
  'due-review': { label: 'Lặp lại · thẻ đến hạn', pct: 50 },
  'exit': { label: 'Chặng 1 · Xem lại', pct: 16 },
};

function Note({ icon, text, tone }) {
  const c = tone === 'success' ? ['var(--memox-success-soft)', 'var(--memox-on-success-soft)'] : ['var(--memox-warning-soft)', 'var(--memox-on-warning-soft)'];
  return <div style={{ background: c[0], color: c[1], borderRadius: 'var(--memox-radius-control)', padding: '10px 14px', display: 'flex', alignItems: 'center', gap: 8, fontSize: 'var(--memox-font-size-sm)', fontWeight: 600 }}><span className="material-symbols-rounded" style={{ fontSize: 18 }}>{icon}</span>{text}</div>;
}

function Tile({ text }) {
  return <div style={{ border: '1px solid var(--memox-divider)', background: 'var(--memox-surface)', borderRadius: 'var(--memox-radius-control)', padding: '14px 8px', textAlign: 'center', fontWeight: 700, fontSize: 'var(--memox-font-size-base)' }}>{text}</div>;
}

function Opt({ text }) {
  return <div style={{ border: '1px solid var(--memox-divider)', background: 'var(--memox-surface)', borderRadius: 'var(--memox-radius-control)', padding: '16px', fontWeight: 700, fontSize: 'var(--memox-font-size-base)' }}>{text}</div>;
}

function PromptCard({ term, sub }) {
  return (
    <MxCard style={{ alignItems: 'center', textAlign: 'center', gap: 'var(--memox-space-3)', padding: 'var(--memox-space-6)' }}>
      <div style={{ fontSize: 48, fontWeight: 800, letterSpacing: '-.02em' }}>{term}</div>
      {sub ? <div style={{ fontSize: 'var(--memox-font-size-base)', color: 'var(--memox-text-secondary)' }}>{sub}</div> : null}
    </MxCard>
  );
}

function Body({ state }) {
  if (state === 'stage1-review' || state === 'exit') {
    return (
      <React.Fragment>
        <MxCard node="study-session/card" style={{ flex: 1, alignItems: 'center', justifyContent: 'center', textAlign: 'center', gap: 'var(--memox-space-4)', minHeight: 300 }}>
          <div style={{ fontSize: 52, fontWeight: 800, letterSpacing: '-.02em' }}>학교</div>
          <div style={{ width: 56, height: 2, background: 'var(--memox-divider)', borderRadius: 2 }} />
          <div style={{ fontSize: 'var(--memox-font-size-2xl)', fontWeight: 700 }}>trường học</div>
          <div style={{ fontSize: 'var(--memox-font-size-base)', color: 'var(--memox-text-secondary)' }}>danh từ · nơi học tập</div>
        </MxCard>
        <MxButton variant="primary" icon="arrow_forward" block size="lg" node="study-session/next">Tiếp</MxButton>
      </React.Fragment>
    );
  }
  if (state === 'stage2-matching') {
    return (
      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 'var(--memox-space-3)' }}>
        <div style={{ display: 'flex', flexDirection: 'column', gap: 'var(--memox-space-3)' }}>{['trường học', 'tình yêu', 'bạn bè'].map((t) => <Tile key={t} text={t} />)}</div>
        <div style={{ display: 'flex', flexDirection: 'column', gap: 'var(--memox-space-3)' }}>{['사랑', '친구', '학교'].map((t) => <Tile key={t} text={t} />)}</div>
      </div>
    );
  }
  if (state === 'stage3-choice' || state === 'relearn') {
    return (
      <React.Fragment>
        {state === 'relearn' ? <Note icon="replay" tone="warning" text="Học lại từ này — chưa tính vào tiến độ." /> : null}
        <PromptCard term="학교" />
        <div style={{ display: 'flex', flexDirection: 'column', gap: 'var(--memox-space-3)' }}>{['trường học', 'bệnh viện', 'công viên'].map((t) => <Opt key={t} text={t} />)}</div>
      </React.Fragment>
    );
  }
  if (state === 'stage4-recall') {
    return (
      <React.Fragment>
        <PromptCard term="친구" />
        <MxCard style={{ alignItems: 'center', minHeight: 90, justifyContent: 'center', color: 'var(--memox-text-tertiary)' }}>Tự nhớ nghĩa, rồi chạm “Hiển thị”</MxCard>
        <MxButton variant="primary" icon="visibility" block size="lg" node="study-session/reveal">Hiển thị</MxButton>
      </React.Fragment>
    );
  }
  if (state === 'stage5-typing') {
    return (
      <React.Fragment>
        <PromptCard term="trường học" sub="NGHĨA" />
        <div style={{ border: '1px solid var(--memox-divider)', background: 'var(--memox-surface)', borderRadius: 'var(--memox-radius-control)', padding: 16, minHeight: 56, color: 'var(--memox-text-tertiary)', fontWeight: 600 }}>Gõ từ tiếng Hàn…</div>
        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 'var(--memox-space-3)' }}>
          <MxButton variant="ghost" icon="lightbulb" block node="study-session/hint">Trợ giúp</MxButton>
          <MxButton variant="primary" block node="study-session/check">Kiểm tra</MxButton>
        </div>
      </React.Fragment>
    );
  }
  // due-review
  return (
    <React.Fragment>
      <Note icon="schedule" tone="warning" text="Ôn thẻ đến hạn — kết quả cập nhật ô Leitner." />
      <MxCard node="study-session/card" style={{ alignItems: 'center', textAlign: 'center', gap: 'var(--memox-space-3)', minHeight: 220, justifyContent: 'center' }}>
        <div style={{ fontSize: 48, fontWeight: 800 }}>학교</div>
        <div style={{ fontSize: 'var(--memox-font-size-2xl)', fontWeight: 700 }}>trường học</div>
      </MxCard>
      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 'var(--memox-space-3)' }}>
        <MxButton variant="ghost" icon="replay" block node="study-session/due-relearn">Học lại</MxButton>
        <MxButton variant="primary" icon="arrow_forward" block node="study-session/due-next">Tiếp</MxButton>
      </div>
    </React.Fragment>
  );
}

function StudySession({ state = 'stage1-review' }) {
  const m = META[state] || META['stage1-review'];
  const bar = (
    <MxAppBar node="study-session/appbar"
      leading={<MxIconButton icon="close" node="study-session/close" />}
      title={<div data-mx-node="study-session/progress" style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
        <window.ProgressBar value={m.pct} height={8} />
        <span style={{ fontSize: 'var(--memox-font-size-sm)', fontWeight: 700, color: 'var(--memox-text-secondary)', whiteSpace: 'nowrap' }}>{m.pct}%</span>
      </div>}
      trailing={<MxIconButton icon="more_horiz" node="study-session/options" />} />
  );

  const scaffold = (
    <MxScaffold node="study-session/screen" appBar={bar}>
      <div style={{ textAlign: 'center', fontSize: 'var(--memox-font-size-sm)', fontWeight: 700, color: 'var(--memox-primary)' }}>{m.label}</div>
      <Body state={state} />
    </MxScaffold>
  );

  if (state === 'exit') {
    return (
      <React.Fragment>
        {scaffold}
        <window.Scrim align="center" node="study-session/exit-scrim">
          <window.Dialog icon="logout" tone="warning" title="Thoát phiên học?"
            text="Thẻ chưa hoàn thành cả 5 chặng sẽ vẫn ở trạng thái Mới."
            node="study-session/exit-dialog"
            actions={<React.Fragment>
              <MxButton variant="ghost" block node="study-session/exit-cancel">Ở lại</MxButton>
              <MxButton variant="primary" block node="study-session/exit-ok">Thoát</MxButton>
            </React.Fragment>} />
        </window.Scrim>
      </React.Fragment>
    );
  }

  return scaffold;
}

window.StudySession = StudySession;
})();
