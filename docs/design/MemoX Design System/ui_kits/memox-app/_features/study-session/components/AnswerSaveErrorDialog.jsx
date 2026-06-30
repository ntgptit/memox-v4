/* MemoX — Study-session local: AnswerSaveErrorDialog (answer-save-error overlay).
   (Named *Dialog, not *Banner: it renders the Scrim+Dialog confirm overlay.) */
(function () {
const NS = window.MemoXDesignSystem_2ffa54;
const { MxButton } = NS;

function AnswerSaveErrorDialog() {
  return (
    <window.Scrim align="center" node="study-session/save-error-scrim">
      <window.Dialog icon="sync_problem" tone="error" title="Couldn't save your answer"
        text="Your result for this card wasn't saved. Retry so your review schedule stays correct."
        node="study-session/save-error-dialog"
        actions={<React.Fragment>
          <MxButton variant="ghost" block node="study-session/save-error-back">Back</MxButton>
          <MxButton variant="primary" icon="refresh" block node="study-session/save-error-retry">Retry</MxButton>
        </React.Fragment>} />
    </window.Scrim>
  );
}

window.MemoXStudySession = window.MemoXStudySession || {};
window.MemoXStudySession.AnswerSaveErrorDialog = AnswerSaveErrorDialog;
})();
