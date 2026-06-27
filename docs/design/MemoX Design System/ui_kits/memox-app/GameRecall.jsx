/* MemoX — Game: Nhớ lại (recall). States: before-reveal · revealed · forgot · remembered · complete */
(function () {
const NS = window.MemoXDesignSystem_2ffa54;
const { MxScaffold, MxAppBar, MxCard, MxIconButton, MxButton } = NS;

function Note({ icon, text, tone }) {
  const c = tone === 'success'
    ? ['var(--memox-success-soft)', 'var(--memox-on-success-soft)']
    : ['var(--memox-warning-soft)', 'var(--memox-on-warning-soft)'];
  return (
    <div style={{ background: c[0], color: c[1], borderRadius: 'var(--memox-radius-control)', padding: '10px 14px', display: 'flex', alignItems: 'center', gap: 8, fontSize: 'var(--memox-font-size-sm)', fontWeight: 600 }}>
      <span className="material-symbols-rounded" style={{ fontSize: 18 }}>{icon}</span>{text}
    </div>
  );
}

function GameRecall({ state = 'before-reveal' }) {
  const revealed = state === 'revealed' || state === 'forgot' || state === 'remembered';
  const bar = (
    <MxAppBar node="game-recall/appbar" title="Nhớ lại"
      leading={<MxIconButton icon="arrow_back" node="game-recall/back" />}
      trailing={<MxIconButton icon="more_horiz" node="game-recall/options" />} />
  );

  if (state === 'complete') {
    return (
      <MxScaffold node="game-recall/screen" appBar={bar}>
        <window.ProgressBar value={100} height={8} node="game-recall/progress" />
        <window.EmptyState node="game-recall/complete" icon="celebration" tone="success" title="Hoàn thành ván!"
          text="Bạn đã ôn xong các từ trong ván này."
          action={<MxButton variant="primary" icon="arrow_forward" node="game-recall/next">Ván tiếp theo</MxButton>} />
      </MxScaffold>
    );
  }

  return (
    <MxScaffold node="game-recall/screen" appBar={bar}>
      <window.ProgressBar value={60} height={8} node="game-recall/progress" />

      <MxCard node="game-recall/term" style={{ alignItems: 'center', textAlign: 'center', gap: 'var(--memox-space-3)', padding: 'var(--memox-space-6)' }}>
        <div style={{ fontSize: 48, fontWeight: 800, letterSpacing: '-.02em' }}>친구</div>
        <div style={{ display: 'flex', gap: 'var(--memox-space-2)' }}>
          <MxIconButton icon="volume_up" node="game-recall/audio" />
          <MxIconButton icon="edit" size="sm" node="game-recall/edit" />
        </div>
      </MxCard>

      <MxCard node="game-recall/meaning" style={{ alignItems: 'center', textAlign: 'center', gap: 8, minHeight: 120, justifyContent: 'center' }}>
        {revealed ? (
          <React.Fragment>
            <div style={{ width: 56, height: 2, background: 'var(--memox-divider)', borderRadius: 2 }} />
            <div style={{ fontSize: 'var(--memox-font-size-2xl)', fontWeight: 700 }}>bạn bè</div>
            <div style={{ fontSize: 'var(--memox-font-size-base)', color: 'var(--memox-text-secondary)' }}>người bạn, bằng hữu</div>
          </React.Fragment>
        ) : (
          <div style={{ display: 'flex', alignItems: 'center', gap: 6, color: 'var(--memox-text-tertiary)', fontSize: 'var(--memox-font-size-sm)', fontWeight: 600 }}>
            <span className="material-symbols-rounded" style={{ fontSize: 18 }}>visibility</span> Tự nhớ nghĩa, rồi chạm “Hiển thị”
          </div>
        )}
      </MxCard>

      {state === 'forgot' ? <Note icon="replay" tone="warning" text="Sẽ học lại từ này trong ván." /> : null}
      {state === 'remembered' ? <Note icon="check_circle" tone="success" text="Tốt! Chuyển sang thẻ kế." /> : null}

      {state === 'before-reveal' ? (
        <MxButton variant="primary" icon="visibility" block size="lg" node="game-recall/reveal">Hiển thị</MxButton>
      ) : (
        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 'var(--memox-space-3)' }}>
          <MxButton variant={state === 'forgot' ? 'primary' : 'ghost'} danger={state === 'forgot'} block node="game-recall/forgot">Đã quên</MxButton>
          <MxButton variant={state === 'remembered' ? 'primary' : 'outline'} block node="game-recall/remembered">Nhớ được</MxButton>
        </div>
      )}
    </MxScaffold>
  );
}

window.GameRecall = GameRecall;
})();
