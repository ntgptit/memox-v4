/* MemoX — Study-session local: ExitDialog (leave-session confirm overlay). */
(function () {
const NS = window.MemoXDesignSystem_2ffa54;
const { MxButton } = NS;

function ExitDialog() {
  return (
    <window.Scrim align="center" node="study-session/exit-scrim">
      <window.Dialog icon="logout" tone="warning" title="Leave the session?"
        text="Cards that haven't finished all 5 stages will stay New."
        node="study-session/exit-dialog"
        actions={<React.Fragment>
          <MxButton variant="ghost" block node="study-session/exit-cancel">Stay</MxButton>
          <MxButton variant="primary" block node="study-session/exit-ok">Leave</MxButton>
        </React.Fragment>} />
    </window.Scrim>
  );
}

window.MemoXStudySession = window.MemoXStudySession || {};
window.MemoXStudySession.ExitDialog = ExitDialog;
})();
