/* MemoX — Game: Recall. States: before-reveal · revealed · forgot · remembered · complete */
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
    <MxAppBar node="game-recall/appbar" title="Recall"
      leading={<MxIconButton icon="arrow_back" node="game-recall/back" />}
      trailing={<MxIconButton icon="more_horiz" node="game-recall/options" />} />
  );

  if (state === 'complete') {
    return (
      <MxScaffold node="game-recall/screen" appBar={bar}>
        <window.ProgressBar value={100} height={8} node="game-recall/progress" />
        <window.EmptyState node="game-recall/complete" icon="celebration" tone="success" title="Round complete!"
          text="You've reviewed the words in this round."
          action={<MxButton variant="primary" icon="arrow_forward" node="game-recall/next">Next round</MxButton>} />
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
            <div style={{ fontSize: 'var(--memox-font-size-2xl)', fontWeight: 700 }}>friend</div>
            <div style={{ fontSize: 'var(--memox-font-size-base)', color: 'var(--memox-text-secondary)' }}>a friend, companion</div>
          </React.Fragment>
        ) : (
          <div style={{ display: 'flex', alignItems: 'center', gap: 6, color: 'var(--memox-text-tertiary)', fontSize: 'var(--memox-font-size-sm)', fontWeight: 600 }}>
            <span className="material-symbols-rounded" style={{ fontSize: 18 }}>visibility</span> Recall the meaning, then tap “Show”
          </div>
        )}
      </MxCard>

      {state === 'forgot' ? <Note icon="replay" tone="warning" text="You'll see this word again this round." /> : null}
      {state === 'remembered' ? <Note icon="check_circle" tone="success" text="Nice! Moving to the next card." /> : null}

      {state === 'before-reveal' ? (
        <MxButton variant="primary" icon="visibility" block size="lg" node="game-recall/reveal">Show</MxButton>
      ) : (
        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 'var(--memox-space-3)' }}>
          <MxButton variant={state === 'forgot' ? 'primary' : 'ghost'} danger={state === 'forgot'} block node="game-recall/forgot">Forgot</MxButton>
          <MxButton variant={state === 'remembered' ? 'primary' : 'outline'} block node="game-recall/remembered">Got it</MxButton>
        </div>
      )}
    </MxScaffold>
  );
}

window.GameRecall = GameRecall;
})();
