/* MemoX — Folder detail screen. States: loaded · empty · edit-menu · delete-confirm · move · loading */
(function () {
const NS = window.MemoXDesignSystem_2ffa54;
const { MxScaffold, MxAppBar, MxCard, MxButton, MxIconButton, MxSearchDock, MxChip, MxFab } = NS;

const ITEMS = [
  { icon: 'folder', tone: 'accent', name: 'Ngữ pháp sơ cấp', meta: '3 thư mục con · 412 từ', due: 28, progress: 64 },
  { icon: 'folder', tone: null, name: 'Chủ đề: Gia đình', meta: '5 bộ thẻ · 180 từ', due: 0, progress: 100 },
  { icon: 'style', tone: 'success', name: 'TOPIK I — Từ vựng', meta: '320 từ · 48 đến hạn', due: 48, progress: 72 },
  { icon: 'style', tone: 'warning', name: 'Động từ bất quy tắc', meta: '64 từ · 12 đến hạn', due: 12, progress: 38 },
];

function Bar() {
  return (
    <MxAppBar title="Tiếng Hàn nhập môn" node="folder-detail/appbar"
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
      <div style={{ flex: 1 }}><MxSearchDock placeholder="Tìm trong thư mục" node="folder-detail/search-dock" /></div>
      <MxChip label="한국어 › Việt" variant="ghost" node="folder-detail/direction" />
      <MxIconButton icon="swap_vert" node="folder-detail/sort" />
    </div>
  );
}

function List() {
  return ITEMS.map((d, i) => (
    <MxCard key={i} padding="sm" interactive node={'folder-detail/item-' + i}>
      <window.DeckRow {...d} />
    </MxCard>
  ));
}

function FolderDetail({ state = 'loaded' }) {
  const fab = <MxFab icon="add" label="Thêm" node="folder-detail/add" />;

  if (state === 'empty') {
    return (
      <MxScaffold node="folder-detail/screen" appBar={<Bar />}>
        <window.EmptyState node="folder-detail/empty" icon="folder_open" title="Thư mục trống"
          text="Tạo bộ thẻ hoặc thư mục con để bắt đầu sắp xếp từ vựng của bạn."
          action={<div style={{ display: 'flex', flexDirection: 'column', gap: 10, width: 220 }}>
            <MxButton variant="primary" icon="style" block node="folder-detail/empty-deck">Tạo bộ thẻ</MxButton>
            <MxButton variant="ghost" icon="create_new_folder" block node="folder-detail/empty-folder">Tạo thư mục con</MxButton>
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
          <MxCard key={i} padding="sm">
            <div style={{ display: 'flex', gap: 14, alignItems: 'center' }}>
              <S w={48} h={48} r={16} />
              <div style={{ flex: 1 }}><S w="55%" h={14} /><S w="38%" h={10} style={{ marginTop: 8 }} /></div>
            </div>
          </MxCard>
        ))}
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
          <window.Sheet title="Tiếng Hàn nhập môn" node="folder-detail/edit-sheet">
            <window.MenuItem icon="edit" label="Đổi tên" node="folder-detail/menu-rename" />
            <window.MenuItem icon="drive_file_move" label="Di chuyển" node="folder-detail/menu-move" />
            <window.MenuItem icon="delete" label="Xoá thư mục" danger node="folder-detail/menu-delete" />
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
          <window.Dialog icon="delete" tone="error" title="Xoá thư mục này?"
            text="Xoá sẽ xoá toàn bộ thư mục con, bộ thẻ và thẻ bên trong. Không thể hoàn tác."
            node="folder-detail/delete-dialog"
            actions={<React.Fragment>
              <MxButton variant="ghost" block node="folder-detail/delete-cancel">Huỷ</MxButton>
              <MxButton variant="primary" danger block node="folder-detail/delete-confirm">Xoá</MxButton>
            </React.Fragment>} />
        </window.Scrim>
      </React.Fragment>
    );
  }

  if (state === 'move') {
    const DEST = [
      { icon: 'home', name: 'Thư viện (gốc)', node: 'folder-detail/move-root' },
      { icon: 'folder', name: 'Luyện thi TOPIK', node: 'folder-detail/move-1' },
      { icon: 'folder', name: 'Tiếng Hàn nhập môn (đang ở đây)', muted: true, node: 'folder-detail/move-self' },
      { icon: 'folder', name: '— Ngữ pháp sơ cấp (thư mục con)', muted: true, node: 'folder-detail/move-child' },
    ];
    return (
      <React.Fragment>
        {base}
        <window.Scrim node="folder-detail/move-scrim">
          <window.Sheet title="Di chuyển tới" node="folder-detail/move-sheet">
            {DEST.map((d) => (
              <window.ListRow key={d.node} icon={d.icon} title={d.name} muted={d.muted} node={d.node}
                trailing={d.muted ? null : <MxIconButton icon="radio_button_unchecked" node={d.node + '-pick'} />} />
            ))}
            <div style={{ marginTop: 8 }}><MxButton variant="primary" block node="folder-detail/move-apply">Di chuyển</MxButton></div>
          </window.Sheet>
        </window.Scrim>
      </React.Fragment>
    );
  }

  return base;
}

window.FolderDetail = FolderDetail;
})();
