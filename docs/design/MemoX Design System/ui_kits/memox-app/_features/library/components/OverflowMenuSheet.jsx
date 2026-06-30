/* MemoX — Library local: OverflowMenuSheet (library overflow bottom sheet). */
(function () {

function OverflowMenuSheet() {
  return (
    <window.Sheet title="Library" node="library/overflow-sheet">
      <window.MenuItem icon="upload_file" label="Import cards" node="library/of-import" />
      <window.MenuItem icon="download" label="Export cards" node="library/of-export" />
      <window.MenuItem icon="checklist" label="Select multiple" node="library/of-select" />
      <window.MenuItem icon="settings" label="Settings" node="library/of-settings" />
    </window.Sheet>
  );
}

window.MemoXLibrary = window.MemoXLibrary || {};
window.MemoXLibrary.OverflowMenuSheet = OverflowMenuSheet;
})();
