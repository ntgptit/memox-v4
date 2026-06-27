/* MemoX — Folder detail. States: loaded · empty · edit-menu · delete-confirm · move · loading */
(function () {
const NS = window.MemoXDesignSystem_2ffa54;
const { MxScaffold, MxAppBar, MxCard, MxButton, MxIconButton, MxSearchDock, MxChip, MxFab } = NS;

const ITEMS = [
  { icon: 'folder', tone: 'accent', name: 'Beginner Grammar', meta: '3 subfolders · 412 words', due: 28, progress: 64 },
  { icon: 'folder', tone: null, name: 'Topic: Family', meta: '5 decks · 180 words', due: 0, progress: 100 },
  { icon: 'style', tone: 'success', name: 'TOPIK I — Vocabulary', meta: '320 words · 48 due', due: 48, progress: 72 },
  { icon: 'style', tone: 'warning', name: 'Irregular Verbs', meta: '64 words · 12 due', due: 12, progress: 38 },
];

function Bar() {
  return (
    <MxAppBar title="Korean Basics" node="folder-detail/appbar"
      leading={<MxIconButton icon="arrow_back" node="folder-detail/back" />}
      trailing={<React.Fragment>
        <MxIconButton icon="volume_up" node="folder-detail/play-audio" />
        <MxIconButton icon="edit" node="folder-detail/edit" />
      </React.Fragment>} />
  );
}

function Toolbar() {
  return (
    <div data-mx-node="folder-detail/toolbar" style={{ display: 'flex', alignItems: 'center', gap: 'var(--memox-space-2)' }}>
      <div style={{ flex: 1 }}><MxSearchDock placeholder="Search in folder" node="folder-detail/search-dock" /></div>
      <MxChip label="한국어 › EN" variant="ghost" node="folder-detail/direction" />
      <MxIconButton icon="swap_vert" node="folder-detail/sort" />
    </div>
  );
}

function List() {
  return ITEMS.map((d, i) => (
    <MxCard key={i} padding="sm" interactive node={'folder-detail/item-' + i}><window.DeckRow {...d} /></MxCard>
  ));
}

function FolderDetail({ state = 'loaded' }) {
  const fab = <MxFab icon="add" label="New" node="folder-detail/add" />;

  if (state === 'empty') {
    return (
      <MxScaffold node="folder-detail/screen" appBar={<Bar />}>
        <window.EmptyState node="folder-detail/empty" icon="folder_open" title="Empty folder"
          text="Create a deck or subfolder to start organizing your vocabulary."
          action={<div style={{ display: 'flex', flexDirection: 'column', gap: 'var(--memox-space-3)', width: 'var(--memox-size-3xl)' }}>
            <MxButton variant="primary" icon="style" block node="folder-detail/empty-deck">Create deck</MxButton>
            <MxButton variant="ghost" icon="create_new_folder" block node="folder-detail/empty-folder">Create subfolder</MxButton>
          </div>} />
      </MxScaffold>
    );
  }

  if (state === 'loading') {
    const S = window.Skeleton;
    return (
      <MxScaffold node="folder-detail/screen" appBar={<Bar />}>
        <S h={48} r={999} />
        {[0, 1, 2, 3].map((i) => (
          <MxCard key={i} padding="sm"><div style={{ display: 'flex', gap: 'var(--memox-space-4)', alignItems: 'center' }}><S w={48} h={48} r={16} /><div style={{ flex: 1 }}><S w="55%" h={14} /><S w="38%" h={10} style={{ marginTop: 'var(--memox-space-2)' }} /></div></div></MxCard>
        ))}
      </MxScaffold>
    );
  }

  if (state === 'error') {
    return (
      <MxScaffold node="folder-detail/screen" appBar={<Bar />}>
        <window.EmptyState node="folder-detail/error" icon="cloud_off" tone="error" title="Couldn't load this folder"
          text="Something went wrong. Check your connection and try again."
          action={<MxButton variant="primary" icon="refresh" node="folder-detail/retry">Retry</MxButton>} />
      </MxScaffold>
    );
  }

  const base = (
    <MxScaffold node="folder-detail/screen" appBar={<Bar />} fab={fab}>
      <Toolbar />
      <List />
    </MxScaffold>
  );

  if (state === 'edit-menu') {
    return (
      <React.Fragment>
        {base}
        <window.Scrim node="folder-detail/edit-scrim">
          <window.Sheet title="Korean Basics" node="folder-detail/edit-sheet">
            <window.MenuItem icon="edit" label="Rename" node="folder-detail/menu-rename" />
            <window.MenuItem icon="drive_file_move" label="Move" node="folder-detail/menu-move" />
            <window.MenuItem icon="delete" label="Delete folder" danger node="folder-detail/menu-delete" />
          </window.Sheet>
        </window.Scrim>
      </React.Fragment>
    );
  }

  if (state === 'delete-confirm') {
    return (
      <React.Fragment>
        {base}
        <window.Scrim align="center" node="folder-detail/delete-scrim">
          <window.Dialog icon="delete" tone="error" title="Delete this folder?"
            text="Deleting removes all subfolders, decks and cards inside. This can't be undone."
            node="folder-detail/delete-dialog"
            actions={<React.Fragment>
              <MxButton variant="ghost" block node="folder-detail/delete-cancel">Cancel</MxButton>
              <MxButton variant="primary" danger block node="folder-detail/delete-confirm">Delete</MxButton>
            </React.Fragment>} />
        </window.Scrim>
      </React.Fragment>
    );
  }

  if (state === 'move') {
    const DEST = [
      { icon: 'home', name: 'Library (root)', node: 'folder-detail/move-root' },
      { icon: 'folder', name: 'TOPIK Prep', node: 'folder-detail/move-1' },
      { icon: 'folder', name: 'Korean Basics (current)', muted: true, node: 'folder-detail/move-self' },
      { icon: 'folder', name: '— Beginner Grammar (subfolder)', muted: true, node: 'folder-detail/move-child' },
    ];
    return (
      <React.Fragment>
        {base}
        <window.Scrim node="folder-detail/move-scrim">
          <window.Sheet title="Move to" node="folder-detail/move-sheet">
            {DEST.map((d) => (
              <window.ListRow key={d.node} icon={d.icon} title={d.name} muted={d.muted} node={d.node}
                trailing={d.muted ? null : <MxIconButton icon="radio_button_unchecked" node={d.node + '-pick'} />} />
            ))}
            <div style={{ marginTop: 'var(--memox-space-2)' }}><MxButton variant="primary" block node="folder-detail/move-apply">Move</MxButton></div>
          </window.Sheet>
        </window.Scrim>
      </React.Fragment>
    );
  }

  return base;
}

window.FolderDetail = FolderDetail;
})();
