/* MemoX — Library (Thư viện). States: loaded · search-active · pair-picker · sort-menu · overflow-menu · play-sheet · drawer · empty · loading · error */
(function () {
const NS = window.MemoXDesignSystem_2ffa54;
const { MxScaffold, MxAppBar, MxBottomNav, MxCard, MxIconButton, MxSearchDock, MxFab, MxButton } = NS;

const NAV = [
  { id: 'home', label: 'Hôm nay', icon: 'today' },
  { id: 'library', label: 'Thư viện', icon: 'style' },
  { id: 'add', label: 'Thêm', icon: 'add_circle' },
  { id: 'stats', label: 'Thống kê', icon: 'insights' },
  { id: 'me', label: 'Hồ sơ', icon: 'person' },
];

const TREE = [
  { icon: 'folder', tone: 'accent', name: 'Tiếng Hàn nhập môn', meta: '3 thư mục · 412 từ', due: 28, progress: 64 },
  { icon: 'folder', tone: null, name: 'Luyện thi TOPIK', meta: '5 bộ thẻ · 980 từ', due: 120, progress: 42 },
  { icon: 'style', tone: 'success', name: 'TOPIK I — Từ vựng', meta: '320 từ · 48 đến hạn', due: 48, progress: 72 },
  { icon: 'style', tone: 'warning', name: 'Động từ bất quy tắc', meta: '64 từ · 41 ẩn', due: 12, progress: 38 },
  { icon: 'style', tone: null, name: 'Hội thoại hằng ngày', meta: '150 từ · đã thuộc', due: 0, progress: 100 },
];

function Bar() {
  return (
    <MxAppBar title="Thư viện" node="library/appbar"
      leading={<MxIconButton icon="menu" node="library/menu-open" />}
      trailing={<MxIconButton icon="more_vert" node="library/overflow" />} />
  );
}

function ContextBar() {
  return (
    <div data-mx-node="library/context" style={{ display: 'flex', alignItems: 'center', gap: 'var(--memox-space-2)' }}>
      <MxIconButton icon="search" node="library/search-btn" />
      <button data-mx-node="library/pair" style={{ flex: 1, display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 8, border: '1px solid var(--memox-divider)', background: 'var(--memox-surface)', borderRadius: 999, padding: '10px 14px', font: 'inherit', fontWeight: 700, cursor: 'pointer', color: 'inherit' }}>
        한국어 <span className="material-symbols-rounded" style={{ fontSize: 18, color: 'var(--memox-text-tertiary)' }}>swap_horiz</span> Tiếng Việt
        <span className="material-symbols-rounded" style={{ fontSize: 18, color: 'var(--memox-text-tertiary)' }}>expand_more</span>
      </button>
      <MxIconButton icon="swap_vert" node="library/sort-btn" />
    </div>
  );
}

function Tree() {
  return TREE.map((d, i) => (
    <MxCard key={i} padding="sm" interactive node={'library/node-' + i}><window.DeckRow {...d} /></MxCard>
  ));
}

function base() {
  return (
    <MxScaffold node="library/screen" appBar={<Bar />} bottomNav={<MxBottomNav items={NAV} value="library" node="shell/bottom-nav" />} fab={<MxFab icon="add" label="Tạo mới" node="library/create" />}>
      <ContextBar />
      <Tree />
    </MxScaffold>
  );
}

function overlay(sheet, align) {
  return <React.Fragment>{base()}<window.Scrim align={align} node="library/scrim">{sheet}</window.Scrim></React.Fragment>;
}

function Library({ state = 'loaded' }) {
  const nav = <MxBottomNav items={NAV} value="library" node="shell/bottom-nav" />;

  if (state === 'loading') {
    const S = window.Skeleton;
    return (
      <MxScaffold node="library/screen" appBar={<Bar />} bottomNav={nav}>
        <S h={48} r={999} />
        {[0, 1, 2, 3].map((i) => (
          <MxCard key={i} padding="sm"><div style={{ display: 'flex', gap: 14, alignItems: 'center' }}><S w={48} h={48} r={16} /><div style={{ flex: 1 }}><S w="55%" h={14} /><S w="38%" h={10} style={{ marginTop: 8 }} /></div></div></MxCard>
        ))}
      </MxScaffold>
    );
  }

  if (state === 'empty') {
    return (
      <MxScaffold node="library/screen" appBar={<Bar />} bottomNav={nav}>
        <ContextBar />
        <window.EmptyState node="library/empty" icon="style" title="Chưa có gì để học"
          text="Tạo bộ thẻ hoặc thêm từ để bắt đầu hành trình tiếng Hàn của bạn."
          action={<div style={{ display: 'flex', flexDirection: 'column', gap: 10, width: 220 }}>
            <MxButton variant="primary" icon="style" block node="library/empty-deck">Tạo bộ thẻ</MxButton>
            <MxButton variant="ghost" icon="add" block node="library/empty-add">Thêm từ</MxButton>
          </div>} />
      </MxScaffold>
    );
  }

  if (state === 'error') {
    return (
      <MxScaffold node="library/screen" appBar={<Bar />} bottomNav={nav}>
        <window.EmptyState node="library/error" icon="cloud_off" tone="error" title="Không tải được thư viện"
          text="Đã có lỗi khi tải dữ liệu. Kiểm tra kết nối rồi thử lại."
          action={<MxButton variant="primary" icon="refresh" node="library/retry">Thử lại</MxButton>} />
      </MxScaffold>
    );
  }

  if (state === 'search-active') {
    return (
      <MxScaffold node="library/screen" appBar={<Bar />} bottomNav={nav}>
        <MxSearchDock focused placeholder="Tìm theo từ hoặc nghĩa" node="library/search-dock"
          trailing={<MxIconButton icon="close" size="sm" node="library/search-clear" />} />
        <div style={{ fontSize: 'var(--memox-font-size-sm)', fontWeight: 700, color: 'var(--memox-text-tertiary)', letterSpacing: '.04em', margin: '4px 0 0 4px' }}>TÌM GẦN ĐÂY</div>
        <MxCard padding="sm">
          {['안녕하세요', '학교', '공부하다'].map((r, i) => (
            <window.ListRow key={r} icon="history" title={r} last={i === 2} node={'library/recent-' + i} />
          ))}
        </MxCard>
      </MxScaffold>
    );
  }

  if (state === 'pair-picker') {
    return overlay(
      <window.Sheet title="Cặp ngôn ngữ" node="library/pair-sheet">
        <window.MenuItem icon="check" label="한국어 → Tiếng Việt" node="library/pair-ko-vi"
          trailing={<span className="material-symbols-rounded" style={{ color: 'var(--memox-primary)' }}>check</span>} />
        <window.MenuItem icon="translate" label="English → Tiếng Việt" node="library/pair-en-vi" />
        <window.MenuItem icon="add" label="Thêm ngôn ngữ" node="library/pair-add" />
      </window.Sheet>
    );
  }

  if (state === 'sort-menu') {
    const opts = [
      ['sort_by_alpha', 'Bảng chữ cái A → Z', true], ['sort_by_alpha', 'Bảng chữ cái Z → A', false],
      ['schedule', 'Ngày tạo (mới nhất)', false], ['history', 'Ngày học gần đây', false],
    ];
    return overlay(
      <window.Sheet title="Sắp xếp" node="library/sort-sheet">
        {opts.map((o, i) => (
          <window.MenuItem key={i} icon={o[0]} label={o[1]} node={'library/sort-' + i}
            trailing={o[2] ? <span className="material-symbols-rounded" style={{ color: 'var(--memox-primary)' }}>check</span> : null} />
        ))}
      </window.Sheet>
    );
  }

  if (state === 'overflow-menu') {
    return overlay(
      <window.Sheet title="Thư viện" node="library/overflow-sheet">
        <window.MenuItem icon="upload_file" label="Nhập thẻ" node="library/of-import" />
        <window.MenuItem icon="download" label="Xuất thẻ" node="library/of-export" />
        <window.MenuItem icon="checklist" label="Chọn nhiều" node="library/of-select" />
        <window.MenuItem icon="settings" label="Cài đặt" node="library/of-settings" />
      </window.Sheet>
    );
  }

  if (state === 'play-sheet') {
    return overlay(
      <window.Sheet title="TOPIK I — Từ vựng" node="library/play-sheet">
        <window.MenuItem icon="school" label="Học · 20 từ mới" node="library/play-learn" />
        <window.MenuItem icon="replay" label="Lặp lại · 48 từ đến hạn" node="library/play-review" />
        <window.MenuItem icon="visibility" label="Xem lại các từ" node="library/play-browse" />
        <window.MenuItem icon="sports_esports" label="Một trò chơi · đến hạn 48 / mới 20" node="library/play-game" />
        <window.MenuItem icon="play_circle" label="Trình phát" node="library/play-player" />
      </window.Sheet>
    );
  }

  if (state === 'drawer') {
    return <React.Fragment>{base()}<window.Drawer state="open" /></React.Fragment>;
  }

  return base();
}

window.Library = Library;
})();
