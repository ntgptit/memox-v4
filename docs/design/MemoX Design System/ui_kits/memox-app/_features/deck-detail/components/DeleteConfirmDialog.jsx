/* MemoX — Deck-detail local: DeleteConfirmDialog (delete-a-card confirm overlay). */
(function () {
const NS = window.MemoXDesignSystem_2ffa54;
const { MxButton } = NS;

function DeleteConfirmDialog() {
  return (
    <window.Scrim align="center" node="deck-detail/delete-scrim">
      <window.Dialog icon="delete" tone="error" title="Delete this card?"
        text="The card “안녕하세요” will be removed from this deck. This can't be undone."
        node="deck-detail/delete-dialog"
        actions={<React.Fragment>
          <MxButton variant="ghost" block node="deck-detail/delete-cancel">Cancel</MxButton>
          <MxButton variant="primary" danger block node="deck-detail/delete-ok">Delete</MxButton>
        </React.Fragment>} />
    </window.Scrim>
  );
}

window.MemoXDeckDetail = window.MemoXDeckDetail || {};
window.MemoXDeckDetail.DeleteConfirmDialog = DeleteConfirmDialog;
})();
