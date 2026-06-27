/* MemoX — Library. States: loaded · search-active · pair-picker · sort-menu · overflow-menu · play-sheet · drawer · empty · loading · error */
(function () {
const NS = window.MemoXDesignSystem_2ffa54;
const { MxScaffold, MxAppBar, MxBottomNav, MxCard, MxIconButton, MxSearchDock, MxFab, MxButton } = NS;

const NAV = [
  { id: 'home', label: 'Today', icon: 'today' },
  { id: 'library', label: 'Library', icon: 'style' },
  { id: 'add', label: 'Add', icon: 'add_circle' },
  { id: 'stats', label: 'Stats', icon: 'insights' },
  { id: 'me', label: 'Profile', icon: 'person' },
];

const TREE = [
  { icon: 'stacks', tone: 'accent', name: 'Korean Basics', meta: '3 decks · 412 words', due: 28, progress: 64 },
  { icon: 'stacks', tone: null, name: 'TOPIK Prep', meta: '5 decks · 980 words', due: 120, progress: 42 },
  { icon: 'style', tone: 'success', name: 'TOPIK I — Vocabulary', meta: '320 words · 48 due', due: 48, progress: 72 },
  { icon: 'style', tone: 'warning', name: 'Irregular Verbs', meta: '64 words · 41 hidden', due: 12, progress: 38 },
  { icon: 'style', tone: null, name: 'Daily Conversation', meta: '150 words · mastered', due: 0, progress: 100 },
];

function Bar() {
  return (
    <MxAppBar title="Library" node="library/appbar"
      leading={<MxIconButton icon="menu" node="library/menu-open" />}
      trailing={<MxIconButton icon="more_vert" node="library/overflow" />} />
  );
}

function ContextBar() {
  return (
    <div data-mx-node="library/context" style={{ display: 'flex', alignItems: 'center', gap: 'var(--memox-space-2)' }}>
      <MxIconButton icon="search" node="library/search-btn" />
      <button data-mx-node="library/pair" style={{ flex: 1, display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 'var(--memox-space-2)', border: 'var(--memox-stroke-hairline) solid var(--memox-divider)', background: 'var(--memox-surface)', borderRadius: 'var(--memox-radius-pill)', padding: 'var(--memox-space-3) var(--memox-space-4)', font: 'inherit', fontWeight: 'var(--memox-font-weight-bold)', cursor: 'pointer', color: 'inherit' }}>
        한국어 <span className="material-symbols-rounded" style={{ fontSize: 'var(--memox-icon-size-sm)', color: 'var(--memox-text-tertiary)' }}>swap_horiz</span> English
        <span className="material-symbols-rounded" style={{ fontSize: 'var(--memox-icon-size-sm)', color: 'var(--memox-text-tertiary)' }}>expand_more</span>
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
    <MxScaffold node="library/screen" appBar={<Bar />} bottomNav={<MxBottomNav items={NAV} value="library" node="shell/bottom-nav" />} fab={<MxFab icon="add" label="New" node="library/create" />}>
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
          <MxCard key={i} padding="sm"><div style={{ display: 'flex', gap: 'var(--memox-space-4)', alignItems: 'center' }}><S w={48} h={48} r={16} /><div style={{ flex: 1 }}><S w="55%" h={14} /><S w="38%" h={10} style={{ marginTop: 'var(--memox-space-2)' }} /></div></div></MxCard>
        ))}
      </MxScaffold>
    );
  }

  if (state === 'empty') {
    return (
      <MxScaffold node="library/screen" appBar={<Bar />} bottomNav={nav}>
        <ContextBar />
        <window.EmptyState node="library/empty" icon="style" title="Your library is empty"
          text="Decks and words you add will show up here. Start with a deck or import a CSV."
          action={<div style={{ display: 'flex', flexDirection: 'column', gap: 'var(--memox-space-3)', width: 'var(--memox-size-3xl)' }}>
            <MxButton variant="primary" icon="style" block node="library/empty-deck">Create deck</MxButton>
            <MxButton variant="ghost" icon="add" block node="library/empty-add">Add words</MxButton>
          </div>} />
      </MxScaffold>
    );
  }

  if (state === 'error') {
    return (
      <MxScaffold node="library/screen" appBar={<Bar />} bottomNav={nav}>
        <window.EmptyState node="library/error" icon="cloud_off" tone="error" title="Couldn't load your library"
          text="Something went wrong loading data. Check your connection and try again."
          action={<MxButton variant="primary" icon="refresh" node="library/retry">Retry</MxButton>} />
      </MxScaffold>
    );
  }

  if (state === 'search-active') {
    return (
      <MxScaffold node="library/screen" appBar={<Bar />} bottomNav={nav}>
        <MxSearchDock focused placeholder="Search by word or meaning" node="library/search-dock"
          trailing={<MxIconButton icon="close" size="sm" node="library/search-clear" />} />
        <div style={{ fontSize: 'var(--memox-font-size-sm)', fontWeight: 'var(--memox-font-weight-bold)', color: 'var(--memox-text-tertiary)', letterSpacing: 'var(--memox-letter-spacing-wide)', margin: 'var(--memox-space-1) 0 0 var(--memox-space-1)' }}>RECENT</div>
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
      <window.Sheet title="Language pair" node="library/pair-sheet">
        <window.MenuItem icon="check" label="한국어 → English" node="library/pair-ko-en"
          trailing={<span className="material-symbols-rounded" style={{ color: 'var(--memox-primary)' }}>check</span>} />
        <window.MenuItem icon="translate" label="日本語 → English" node="library/pair-ja-en" />
        <window.MenuItem icon="add" label="Add language" node="library/pair-add" />
      </window.Sheet>
    );
  }

  if (state === 'sort-menu') {
    const opts = [
      ['sort_by_alpha', 'Alphabetical A → Z', true], ['sort_by_alpha', 'Alphabetical Z → A', false],
      ['schedule', 'Date created (newest)', false], ['history', 'Last studied', false],
    ];
    return overlay(
      <window.Sheet title="Sort by" node="library/sort-sheet">
        {opts.map((o, i) => (
          <window.MenuItem key={i} icon={o[0]} label={o[1]} node={'library/sort-' + i}
            trailing={o[2] ? <span className="material-symbols-rounded" style={{ color: 'var(--memox-primary)' }}>check</span> : null} />
        ))}
      </window.Sheet>
    );
  }

  if (state === 'overflow-menu') {
    return overlay(
      <window.Sheet title="Library" node="library/overflow-sheet">
        <window.MenuItem icon="upload_file" label="Import cards" node="library/of-import" />
        <window.MenuItem icon="download" label="Export cards" node="library/of-export" />
        <window.MenuItem icon="checklist" label="Select multiple" node="library/of-select" />
        <window.MenuItem icon="settings" label="Settings" node="library/of-settings" />
      </window.Sheet>
    );
  }

  if (state === 'play-sheet') {
    return overlay(
      <window.Sheet title="TOPIK I — Vocabulary" node="library/play-sheet">
        <window.MenuItem icon="school" label="Learn · 20 new" node="library/play-learn" />
        <window.MenuItem icon="replay" label="Review · 48 due" node="library/play-review" />
        <window.MenuItem icon="visibility" label="Browse cards" node="library/play-browse" />
        <window.MenuItem icon="sports_esports" label="Single game · due 48 / new 20" node="library/play-game" />
        <window.MenuItem icon="play_circle" label="Player" node="library/play-player" />
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
