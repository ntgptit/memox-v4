/* MemoX — Game: Multiple choice. States: waiting · correct · wrong · complete */
(function () {
const NS = window.MemoXDesignSystem_2ffa54;
const { MxScaffold, MxAppBar, MxCard, MxIconButton, MxButton } = NS;

const CHOICES = ['school', 'hospital', 'park', 'restaurant'];

const Choice = window.ChoiceOption;

function toneFor(state, i) {
  if (state === 'correct') return i === 0 ? 'correct' : undefined;
  if (state === 'wrong') return i === 0 ? 'correct' : (i === 2 ? 'wrong' : undefined);
  return undefined;
}

function GameMultipleChoice({ state = 'waiting' }) {
  const bar = (
    <MxAppBar node="game-mc/appbar" title="Multiple choice"
      leading={<MxIconButton icon="arrow_back" node="game-mc/back" />}
      trailing={<MxIconButton icon="more_horiz" node="game-mc/options" />} />
  );

  if (state === 'complete') {
    return (
      <MxScaffold node="game-mc/screen" appBar={bar}>
        <window.ProgressBar value={100} height={8} node="game-mc/progress" />
        <window.EmptyState node="game-mc/complete" icon="celebration" tone="success" title="Round complete!"
          text="You answered 5/5 correctly."
          action={<MxButton variant="primary" icon="arrow_forward" node="game-mc/next">Next round</MxButton>} />
      </MxScaffold>
    );
  }

  return (
    <MxScaffold node="game-mc/screen" appBar={bar}>
      <window.ProgressBar value={40} height={8} node="game-mc/progress" />
      <MxCard node="game-mc/prompt" style={{ alignItems: 'center', textAlign: 'center', gap: 'var(--memox-space-3)', padding: 'var(--memox-space-6)' }}>
        <div style={{ fontSize: 'var(--memox-font-size-4xl)', fontWeight: 'var(--memox-font-weight-extrabold)', letterSpacing: 'var(--memox-letter-spacing-tight)' }}>학교</div>
        <div style={{ display: 'flex', gap: 'var(--memox-space-2)' }}>
          <MxIconButton icon="volume_up" node="game-mc/audio" />
          <MxIconButton icon="edit" size="sm" node="game-mc/edit" />
        </div>
      </MxCard>
      <div style={{ display: 'flex', flexDirection: 'column', gap: 'var(--memox-space-3)' }}>
        {CHOICES.map((c, i) => <Choice key={i} text={c} tone={toneFor(state, i)} node={'game-mc/choice-' + i} />)}
      </div>
    </MxScaffold>
  );
}

window.GameMultipleChoice = GameMultipleChoice;
})();
