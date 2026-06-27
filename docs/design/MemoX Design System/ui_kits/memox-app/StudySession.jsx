/* MemoX — Study session (NewLearn 5 stages + DueReview).
   States: stage1-review · stage2-matching · stage3-choice · stage4-recall · stage5-typing · relearn · due-review · exit · resume-error · answer-save-error */
(function () {
const NS = window.MemoXDesignSystem_2ffa54;
const { MxScaffold, MxAppBar, MxIconButton, MxCard, MxButton } = NS;

const META = {
  'stage1-review': { label: 'Stage 1 · Review', pct: 16 },
  'stage2-matching': { label: 'Stage 2 · Matching', pct: 32 },
  'stage3-choice': { label: 'Stage 3 · Multiple choice', pct: 48 },
  'stage4-recall': { label: 'Stage 4 · Recall', pct: 64 },
  'stage5-typing': { label: 'Stage 5 · Typing', pct: 84 },
  'relearn': { label: 'Stage 3 · Multiple choice', pct: 48 },
  'due-review': { label: 'Review · due cards', pct: 50 },
  'exit': { label: 'Stage 1 · Review', pct: 16 },
  'answer-save-error': { label: 'Stage 5 · Typing', pct: 84 },
};

function Note({ icon, text, tone }) {
  const c = tone === 'success' ? ['var(--memox-success-soft)', 'var(--memox-on-success-soft)'] : ['var(--memox-warning-soft)', 'var(--memox-on-warning-soft)'];
  return <div style={{ background: c[0], color: c[1], borderRadius: 'var(--memox-radius-control)', padding: 'var(--memox-space-3) var(--memox-space-4)', display: 'flex', alignItems: 'center', gap: 'var(--memox-space-2)', fontSize: 'var(--memox-font-size-sm)', fontWeight: 'var(--memox-font-weight-semibold)' }}><span className="material-symbols-rounded" style={{ fontSize: 'var(--memox-icon-size-sm)' }}>{icon}</span>{text}</div>;
}

function Tile({ text }) {
  return <div style={{ border: 'var(--memox-stroke-hairline) solid var(--memox-divider)', background: 'var(--memox-surface)', borderRadius: 'var(--memox-radius-control)', padding: 'var(--memox-space-4) var(--memox-space-2)', textAlign: 'center', fontWeight: 'var(--memox-font-weight-bold)', fontSize: 'var(--memox-font-size-base)' }}>{text}</div>;
}

function Opt({ text }) {
  return <div style={{ border: 'var(--memox-stroke-hairline) solid var(--memox-divider)', background: 'var(--memox-surface)', borderRadius: 'var(--memox-radius-control)', padding: 'var(--memox-space-4)', fontWeight: 'var(--memox-font-weight-bold)', fontSize: 'var(--memox-font-size-base)' }}>{text}</div>;
}

function PromptCard({ term, sub }) {
  return (
    <MxCard style={{ alignItems: 'center', textAlign: 'center', gap: 'var(--memox-space-3)', padding: 'var(--memox-space-6)' }}>
      <div style={{ fontSize: 'var(--memox-font-size-4xl)', fontWeight: 'var(--memox-font-weight-extrabold)', letterSpacing: 'var(--memox-letter-spacing-tight)' }}>{term}</div>
      {sub ? <div style={{ fontSize: 'var(--memox-font-size-base)', color: 'var(--memox-text-secondary)' }}>{sub}</div> : null}
    </MxCard>
  );
}

function Body({ state }) {
  if (state === 'stage1-review' || state === 'exit') {
    return (
      <React.Fragment>
        <MxCard node="study-session/card" style={{ flex: 1, alignItems: 'center', justifyContent: 'center', textAlign: 'center', gap: 'var(--memox-space-4)', minHeight: 'var(--memox-size-5xl)' }}>
          <div style={{ fontSize: 'var(--memox-font-size-4xl)', fontWeight: 'var(--memox-font-weight-extrabold)', letterSpacing: 'var(--memox-letter-spacing-tight)' }}>학교</div>
          <div style={{ width: 'var(--memox-size-md)', height: 'var(--memox-size-3xs)', background: 'var(--memox-divider)', borderRadius: 'var(--memox-radius-xs)' }} />
          <div style={{ fontSize: 'var(--memox-font-size-2xl)', fontWeight: 'var(--memox-font-weight-bold)' }}>school</div>
          <div style={{ fontSize: 'var(--memox-font-size-base)', color: 'var(--memox-text-secondary)' }}>noun · a place of learning</div>
        </MxCard>
        <MxButton variant="primary" icon="arrow_forward" block size="lg" node="study-session/next">Next</MxButton>
      </React.Fragment>
    );
  }
  if (state === 'stage2-matching') {
    return (
      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 'var(--memox-space-3)' }}>
        <div style={{ display: 'flex', flexDirection: 'column', gap: 'var(--memox-space-3)' }}>{['school', 'love', 'friend'].map((t) => <Tile key={t} text={t} />)}</div>
        <div style={{ display: 'flex', flexDirection: 'column', gap: 'var(--memox-space-3)' }}>{['사랑', '친구', '학교'].map((t) => <Tile key={t} text={t} />)}</div>
      </div>
    );
  }
  if (state === 'stage3-choice' || state === 'relearn') {
    return (
      <React.Fragment>
        {state === 'relearn' ? <Note icon="replay" tone="warning" text="Review this word — not counted toward progress." /> : null}
        <PromptCard term="학교" />
        <div style={{ display: 'flex', flexDirection: 'column', gap: 'var(--memox-space-3)' }}>{['school', 'hospital', 'park'].map((t) => <Opt key={t} text={t} />)}</div>
      </React.Fragment>
    );
  }
  if (state === 'stage4-recall') {
    return (
      <React.Fragment>
        <PromptCard term="친구" />
        <MxCard style={{ alignItems: 'center', minHeight: 'var(--memox-size-xl)', justifyContent: 'center', color: 'var(--memox-text-tertiary)' }}>Recall the meaning, then tap “Show”</MxCard>
        <MxButton variant="primary" icon="visibility" block size="lg" node="study-session/reveal">Show</MxButton>
      </React.Fragment>
    );
  }
  if (state === 'stage5-typing' || state === 'answer-save-error') {
    return (
      <React.Fragment>
        <PromptCard term="school" sub="MEANING" />
        <div style={{ border: 'var(--memox-stroke-hairline) solid var(--memox-divider)', background: 'var(--memox-surface)', borderRadius: 'var(--memox-radius-control)', padding: 'var(--memox-space-4)', minHeight: 'var(--memox-size-md)', color: 'var(--memox-text-tertiary)', fontWeight: 'var(--memox-font-weight-semibold)' }}>Type the Korean word…</div>
        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 'var(--memox-space-3)' }}>
          <MxButton variant="ghost" icon="lightbulb" block node="study-session/hint">Help</MxButton>
          <MxButton variant="primary" block node="study-session/check">Check</MxButton>
        </div>
      </React.Fragment>
    );
  }
  // due-review
  return (
    <React.Fragment>
      <Note icon="schedule" tone="warning" text="Reviewing due cards — results update the Leitner box." />
      <MxCard node="study-session/card" style={{ alignItems: 'center', textAlign: 'center', gap: 'var(--memox-space-3)', minHeight: 'var(--memox-size-3xl)', justifyContent: 'center' }}>
        <div style={{ fontSize: 'var(--memox-font-size-4xl)', fontWeight: 'var(--memox-font-weight-extrabold)' }}>학교</div>
        <div style={{ fontSize: 'var(--memox-font-size-2xl)', fontWeight: 'var(--memox-font-weight-bold)' }}>school</div>
      </MxCard>
      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 'var(--memox-space-3)' }}>
        <MxButton variant="ghost" icon="replay" block node="study-session/due-relearn">Relearn</MxButton>
        <MxButton variant="primary" icon="arrow_forward" block node="study-session/due-next">Next</MxButton>
      </div>
    </React.Fragment>
  );
}

function StudySession({ state = 'stage1-review' }) {
  if (state === 'resume-error') {
    const errBar = (
      <MxAppBar node="study-session/appbar"
        leading={<MxIconButton icon="close" node="study-session/close" />}
        title={<span style={{ fontSize: 'var(--memox-font-size-base)', fontWeight: 'var(--memox-font-weight-bold)' }}>Resume session</span>} />
    );
    return (
      <MxScaffold node="study-session/screen" appBar={errBar}>
        <window.EmptyState node="study-session/resume-error" icon="play_disabled" tone="error" title="Couldn't resume your session"
          text="We couldn't restore where you left off. Restart this session or go back to the deck."
          action={<div style={{ display: 'flex', flexDirection: 'column', gap: 'var(--memox-space-3)', width: 'var(--memox-size-3xl)' }}>
            <MxButton variant="primary" icon="refresh" block node="study-session/resume-retry">Restart session</MxButton>
            <MxButton variant="ghost" block node="study-session/resume-back">Back to deck</MxButton>
          </div>} />
      </MxScaffold>
    );
  }

  const m = META[state] || META['stage1-review'];
  const bar = (
    <MxAppBar node="study-session/appbar"
      leading={<MxIconButton icon="close" node="study-session/close" />}
      title={<div data-mx-node="study-session/progress" style={{ display: 'flex', alignItems: 'center', gap: 'var(--memox-space-3)' }}>
        <window.ProgressBar value={m.pct} height={8} />
        <span style={{ fontSize: 'var(--memox-font-size-sm)', fontWeight: 'var(--memox-font-weight-bold)', color: 'var(--memox-text-secondary)', whiteSpace: 'nowrap' }}>{m.pct}%</span>
      </div>}
      trailing={<MxIconButton icon="more_horiz" node="study-session/options" />} />
  );

  const scaffold = (
    <MxScaffold node="study-session/screen" appBar={bar}>
      <div style={{ textAlign: 'center', fontSize: 'var(--memox-font-size-sm)', fontWeight: 'var(--memox-font-weight-bold)', color: 'var(--memox-primary)' }}>{m.label}</div>
      <Body state={state} />
    </MxScaffold>
  );

  if (state === 'exit') {
    return (
      <React.Fragment>
        {scaffold}
        <window.Scrim align="center" node="study-session/exit-scrim">
          <window.Dialog icon="logout" tone="warning" title="Leave the session?"
            text="Cards that haven't finished all 5 stages will stay New."
            node="study-session/exit-dialog"
            actions={<React.Fragment>
              <MxButton variant="ghost" block node="study-session/exit-cancel">Stay</MxButton>
              <MxButton variant="primary" block node="study-session/exit-ok">Leave</MxButton>
            </React.Fragment>} />
        </window.Scrim>
      </React.Fragment>
    );
  }

  if (state === 'answer-save-error') {
    return (
      <React.Fragment>
        {scaffold}
        <window.Scrim align="center" node="study-session/save-error-scrim">
          <window.Dialog icon="sync_problem" tone="error" title="Couldn't save your answer"
            text="Your result for this card wasn't saved. Retry so your review schedule stays correct."
            node="study-session/save-error-dialog"
            actions={<React.Fragment>
              <MxButton variant="ghost" block node="study-session/save-error-back">Back</MxButton>
              <MxButton variant="primary" icon="refresh" block node="study-session/save-error-retry">Retry</MxButton>
            </React.Fragment>} />
        </window.Scrim>
      </React.Fragment>
    );
  }

  return scaffold;
}

window.StudySession = StudySession;
})();
