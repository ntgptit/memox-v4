/* MemoX — Study-session local: StageChoice (stage 3 / relearn — multiple choice).
   `relearn` adds the not-counted warning note. */
(function () {
const NS = window.MemoXDesignSystem_2ffa54;
const Note = window.Note;
const Opt = window.ChoiceOption;

function StageChoice({ relearn }) {
  const { PromptCard } = window.MemoXStudySession;
  return (
    <React.Fragment>
      {relearn ? <Note icon="replay" tone="warning" text="Review this word — not counted toward progress." /> : null}
      <PromptCard term="학교" />
      <div style={{ display: 'flex', flexDirection: 'column', gap: 'var(--memox-space-3)' }}>{['school', 'hospital', 'park'].map((t) => <Opt key={t} text={t} />)}</div>
    </React.Fragment>
  );
}

window.MemoXStudySession = window.MemoXStudySession || {};
window.MemoXStudySession.StageChoice = StageChoice;
})();
