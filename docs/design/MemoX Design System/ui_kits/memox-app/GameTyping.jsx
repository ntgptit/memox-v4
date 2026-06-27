/* MemoX — Game: Typing. States: waiting · typing · hint · correct · wrong · complete */
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

function CharCompare() {
  const typed = ['친', '고'];
  const correct = ['친', '구'];
  return (
    <div style={{ display: 'flex', gap: 6, justifyContent: 'center' }}>
      {correct.map((c, i) => {
        const ok = typed[i] === c;
        return <span key={i} style={{ fontSize: 'var(--memox-font-size-2xl)', fontWeight: 800, color: ok ? 'var(--memox-success)' : 'var(--memox-error)' }}>{typed[i] || '_'}</span>;
      })}
    </div>
  );
}

function InputBox({ content, tone, placeholder }) {
  const border = tone === 'correct' ? '2px solid var(--memox-success)' : tone === 'wrong' ? '2px solid var(--memox-error)' : '1px solid var(--memox-divider)';
  return (
    <div data-mx-node="game-typing/input" style={{ border, borderRadius: 'var(--memox-radius-control)', background: 'var(--memox-surface)', padding: '16px', minHeight: 56, display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 'var(--memox-font-size-2xl)', fontWeight: 800 }}>
      {content != null ? content : <span style={{ color: 'var(--memox-text-tertiary)', fontSize: 'var(--memox-font-size-base)', fontWeight: 600 }}>{placeholder}</span>}
    </div>
  );
}

const INPUT = {
  waiting: { content: null, placeholder: 'Type the Korean word…' },
  typing: { content: '친' },
  hint: { content: '친 _' },
  correct: { content: '친구', tone: 'correct' },
  wrong: { content: <CharCompare />, tone: 'wrong' },
};

function GameTyping({ state = 'waiting' }) {
  const bar = (
    <MxAppBar node="game-typing/appbar" title="Typing"
      leading={<MxIconButton icon="arrow_back" node="game-typing/back" />}
      trailing={<MxIconButton icon="more_horiz" node="game-typing/options" />} />
  );

  if (state === 'complete') {
    return (
      <MxScaffold node="game-typing/screen" appBar={bar}>
        <window.ProgressBar value={100} height={8} node="game-typing/progress" />
        <window.EmptyState node="game-typing/complete" icon="celebration" tone="success" title="Round complete!"
          text="You typed the words correctly."
          action={<MxButton variant="primary" icon="arrow_forward" node="game-typing/next">Next round</MxButton>} />
      </MxScaffold>
    );
  }

  const inp = INPUT[state] || INPUT.waiting;
  let controls;
  if (state === 'correct') {
    controls = <MxButton variant="primary" icon="arrow_forward" block node="game-typing/next">Next</MxButton>;
  } else if (state === 'wrong') {
    controls = (
      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 'var(--memox-space-3)' }}>
        <MxButton variant="outline" block node="game-typing/accept">Correct</MxButton>
        <MxButton variant="primary" block node="game-typing/retry">Retry</MxButton>
      </div>
    );
  } else {
    controls = (
      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 'var(--memox-space-3)' }}>
        <MxButton variant="ghost" icon="lightbulb" block node="game-typing/hint">Help</MxButton>
        <MxButton variant="primary" block disabled={state === 'waiting'} node="game-typing/check">Check</MxButton>
      </div>
    );
  }

  return (
    <MxScaffold node="game-typing/screen" appBar={bar}>
      <window.ProgressBar value={80} height={8} node="game-typing/progress" />

      <MxCard node="game-typing/meaning" style={{ alignItems: 'center', textAlign: 'center', gap: 8, padding: 'var(--memox-space-6)' }}>
        <div style={{ fontSize: 'var(--memox-font-size-sm)', color: 'var(--memox-text-tertiary)', fontWeight: 700, letterSpacing: '.04em' }}>MEANING</div>
        <div style={{ fontSize: 'var(--memox-font-size-2xl)', fontWeight: 800 }}>friend</div>
      </MxCard>

      <div style={{ fontSize: 'var(--memox-font-size-sm)', fontWeight: 700, color: 'var(--memox-text-secondary)' }}>Type the term (Korean)</div>
      <InputBox {...inp} />

      {state === 'hint' ? <Note icon="lightbulb" tone="warning" text="Hint: 2 characters, starts with 친" /> : null}
      {state === 'wrong' ? (
        <div style={{ textAlign: 'center', fontSize: 'var(--memox-font-size-base)', color: 'var(--memox-text-secondary)' }}>
          Answer: <b style={{ color: 'var(--memox-success)' }}>친구</b>
        </div>
      ) : null}

      {controls}
    </MxScaffold>
  );
}

window.GameTyping = GameTyping;
})();
