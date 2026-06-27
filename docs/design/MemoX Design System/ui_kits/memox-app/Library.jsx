/* MemoX — Library screen. States: loaded · no-results · empty · loading */
(function () {
const NS = window.MemoXDesignSystem_2ffa54;
const { MxScaffold, MxAppBar, MxBottomNav, MxCard, MxButton, MxIconButton, MxSearchDock, MxChip, MxFab, MxIconTile } = NS;

const NAV = [
  { id: 'home', label: 'Today', icon: 'today' },
  { id: 'library', label: 'Library', icon: 'style' },
  { id: 'add', label: 'Add', icon: 'add_circle' },
  { id: 'stats', label: 'Stats', icon: 'insights' },
  { id: 'me', label: 'Profile', icon: 'person' },
];

const FILTERS = ['All', 'Due', 'Learning', 'Mastered'];

const DECKS = [
  { icon: 'translate', tone: 'accent', name: 'Japanese N5', meta: '320 cards · 48 due', due: 48, progress: 72 },
  { icon: 'functions', tone: 'success', name: 'Calculus II', meta: '140 cards · 12 due', due: 12, progress: 54 },
  { icon: 'biotech', tone: 'warning', name: 'Cell Biology', meta: '86 cards · 23 due', due: 23, progress: 38 },
  { icon: 'gavel', tone: 'error', name: 'Legal Latin', meta: '64 cards · all done', due: 0, progress: 100 },
  { icon: 'public', tone: null, name: 'World Capitals', meta: '195 cards · 6 due', due: 6, progress: 88 },
];

function Bar() {
  return (
    <MxAppBar title="Library"
      trailing={<React.Fragment>
        <MxIconButton icon="swap_vert" node="library/sort" />
        <MxIconButton icon="more_vert" node="library/menu" />
      </React.Fragment>} node="library/appbar" />
  );
}

function Filters({ active }) {
  return (
    <div data-mx-node="library/filters" style={{ display: 'flex', gap: 'var(--memox-space-2)', overflowX: 'auto', paddingBottom: 2 }}>
      {FILTERS.map((f) => <MxChip key={f} label={f} selected={f === active} node={'library/filter-' + f.toLowerCase()} />)}
    </div>
  );
}

function Library({ state = 'loaded' }) {
  const nav = <MxBottomNav items={NAV} value="library" node="shell/bottom-nav" />;
  const fab = <MxFab icon="add" label="New deck" node="library/new-deck" />;

  if (state === 'empty') {
    return (
      <MxScaffold node="library/screen" appBar={<Bar />} bottomNav={nav}>
        <window.EmptyState node="library/empty" icon="style" title="Your library is empty"
          text="Decks you create or import will live here. Start with a blank deck or import a CSV."
          action={<MxButton variant="primary" icon="add" node="library/empty-create">New deck</MxButton>} />
      </MxScaffold>
    );
  }

  if (state === 'no-results') {
    return (
      <MxScaffold node="library/screen" appBar={<Bar />} bottomNav={nav}>
        <MxSearchDock value="kanjii" focused node="library/search-dock" trailing={<MxIconButton icon="close" size="sm" node="library/search-clear" />} />
        <Filters active="All" />
        <window.EmptyState node="library/no-results" icon="search_off" tone="warning" title="No matches"
          text={'Nothing matched "kanjii". Check the spelling or try a different term.'}
          action={<MxButton variant="outline" icon="restart_alt" node="library/clear-search">Clear search</MxButton>} />
      </MxScaffold>
    );
  }

  if (state === 'loading') {
    const S = window.Skeleton;
    return (
      <MxScaffold node="library/screen" appBar={<Bar />} bottomNav={nav}>
        <S h={52} r={999} />
        <div style={{ display: 'flex', gap: 8 }}>{[44, 38, 60, 56].map((w, i) => <S key={i} w={w} h={34} r={999} />)}</div>
        {[0, 1, 2, 3].map((i) => (
          <MxCard key={i} padding="sm">
            <div style={{ display: 'flex', gap: 14, alignItems: 'center' }}>
              <S w={48} h={48} r={16} />
              <div style={{ flex: 1 }}><S w="55%" h={14} /><S w="35%" h={10} style={{ marginTop: 8 }} /></div>
            </div>
          </MxCard>
        ))}
      </MxScaffold>
    );
  }

  // loaded
  return (
    <MxScaffold node="library/screen" appBar={<Bar />} bottomNav={nav} fab={fab}>
      <MxSearchDock placeholder="Search decks & cards" node="library/search-dock"
        trailing={<MxIconButton icon="tune" size="sm" node="library/filter-btn" />} />
      <Filters active="All" />
      {DECKS.map((d, i) => (
        <MxCard key={i} padding="sm" interactive node={'library/deck-' + i}>
          <window.DeckRow {...d} />
        </MxCard>
      ))}
    </MxScaffold>
  );
}

window.Library = Library;
})();
