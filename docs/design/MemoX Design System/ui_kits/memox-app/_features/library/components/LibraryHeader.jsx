/* MemoX — Library local: LibraryHeader (app bar, shared by every state). */
(function () {
const NS = window.MemoXDesignSystem_2ffa54;
const { MxAppBar, MxIconButton } = NS;

function LibraryHeader() {
  return (
    <MxAppBar title="Library" node="library/appbar"
      leading={<MxIconButton icon="menu" node="library/menu-open" />}
      trailing={<MxIconButton icon="more_vert" node="library/overflow" />} />
  );
}

window.MemoXLibrary = window.MemoXLibrary || {};
window.MemoXLibrary.LibraryHeader = LibraryHeader;
})();
