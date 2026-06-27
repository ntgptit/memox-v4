/* MemoX — Deck detail (card list). States: loaded · search · no-results · empty · card-actions · delete-confirm · reset-confirm · loading · error */
(function () {
const NS = window.MemoXDesignSystem_2ffa54;
const { MxScaffold, MxAppBar, MxCard, MxButton, MxIconButton, MxSearchDock, MxChip, MxFab, MxBadge } = NS;

const FILTERS = ['All', 'New', 'Due', 'Mastered'];

const CARDS = [
  { term: '안녕하세요', meaning: 'Hello (formal)', status: 'due' },
  { term: '감사합니다', meaning: 'Thank you', status: 'mastered' },
  { term: '사랑', meaning: 'love; affection', status: 'new' },
  { term: '공부하다', meaning: 'to study', status: 'due' },
  { term: '맛있다', meaning: 'delicious (food)', status: 'mastered' },
  { term: '어렵다', meaning: 'difficult, hard', status: 'new', hidden: true },
];

const STATUS = {
  new: { label: 'New', tone: undefined },
  due: { label: 'Due', tone: 'error' },
  mastered: { label: 'Mastered', tone: 'success' },
};

function CardRow({ term, meaning, status, hidden, node, onClick }) {
  const s = STATUS[status];
  return (
    <div data-mx-node={node} onClick={onClick} style={{ display: 'flex', alignItems: 'center', gap: 'var(--memox-space-4)', opacity: hidden ? .5 : 1 }}>
      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 'var(--memox-space-2)' }}>
          <span style={{ fontWeight: 'var(--memox-font-weight-extrabold)', fontSize: 'var(--memox-font-size-md)', letterSpacing: 'var(--memox-letter-spacing-tight)' }}>{term}</span>
          {hidden ? <span className="material-symbols-rounded" style={{ fontSize: 'var(--memox-font-size-base)', color: 'var(--memox-text-tertiary)' }}>visibility_off</span> : null}
        </div>
        <div style={{ fontSize: 'var(--memox-font-size-sm)', color: 'var(--memox-text-secondary)', marginTop: 'var(--memox-space-1)', whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' }}>{meaning}</div>
      </div>
      <MxBadge tone={s.tone} soft>{s.label}</MxBadge>
    </div>
  );
}

function Bar() {
  return (
    <MxAppBar title="TOPIK I — Vocabulary" node="deck-detail/appbar"
      leading={<MxIconButton icon="arrow_back" node="deck-detail/back" />}
      trailing={<React.Fragment>
        <MxIconButton icon="volume_up" node="deck-detail/play-audio" />
        <MxIconButton icon="more_vert" node="deck-detail/menu" />
      </React.Fragment>} />
  );
}

function DeckDetail({ state = 'loaded' }) {
  const fab = <MxFab icon="add" label="Add word" node="deck-detail/add-card" />;

  if (state === 'empty') {
    return (
      <MxScaffold node="deck-detail/screen" appBar={<Bar />}>
        <window.EmptyState node="deck-detail/empty" icon="playing_cards" title="No cards yet"
          text="Add words manually or import in bulk from a CSV / Excel file."
          action={<div style={{ display: 'flex', flexDirection: 'column', gap: 'var(--memox-space-3)', width: 'var(--memox-size-3xl)' }}>
            <MxButton variant="primary" icon="add" block node="deck-detail/empty-add">Add words</MxButton>
            <MxButton variant="ghost" icon="upload_file" block node="deck-detail/empty-import">Import from file</MxButton>
          </div>} />
      </MxScaffold>
    );
  }

  if (state === 'loading') {
    const S = window.Skeleton;
    return (
      <MxScaffold node="deck-detail/screen" appBar={<Bar />}>
        <S h={48} r={999} />
        {[0, 1, 2, 3, 4].map((i) => (
          <MxCard key={i} padding="sm"><div style={{ display: 'flex', gap: 'var(--memox-space-4)', alignItems: 'center' }}><div style={{ flex: 1 }}><S w="40%" h={16} /><S w="62%" h={10} style={{ marginTop: 'var(--memox-space-2)' }} /></div><S w={56} h={22} r={999} /></div></MxCard>
        ))}
      </MxScaffold>
    );
  }

  if (state === 'error') {
    return (
      <MxScaffold node="deck-detail/screen" appBar={<Bar />}>
        <window.EmptyState node="deck-detail/error" icon="cloud_off" tone="error" title="Couldn't load this deck"
          text="Something went wrong. Check your connection and try again."
          action={<MxButton variant="primary" icon="refresh" node="deck-detail/retry">Retry</MxButton>} />
      </MxScaffold>
    );
  }

  if (state === 'search') {
    return (
      <MxScaffold node="deck-detail/screen" appBar={<Bar />}>
        <MxSearchDock value="하" focused node="deck-detail/search-dock"
          trailing={<MxIconButton icon="close" size="sm" node="deck-detail/search-clear" />} />
        <div data-mx-node="deck-detail/filters" style={{ display: 'flex', gap: 'var(--memox-space-2)', overflowX: 'auto', paddingBottom: 'var(--memox-space-1)' }}>
          {FILTERS.map((f, i) => <MxChip key={f} label={f} selected={i === 0} node={'deck-detail/filter-' + i} />)}
        </div>
        {CARDS.filter((c) => c.term.includes('하') || c.meaning.includes('study')).map((c, i) => (
          <MxCard key={i} padding="sm" interactive node={'deck-detail/result-' + i}><CardRow {...c} /></MxCard>
        ))}
      </MxScaffold>
    );
  }

  if (state === 'no-results') {
    return (
      <MxScaffold node="deck-detail/screen" appBar={<Bar />}>
        <MxSearchDock value="xyz" focused node="deck-detail/search-dock"
          trailing={<MxIconButton icon="close" size="sm" node="deck-detail/search-clear" />} />
        <div data-mx-node="deck-detail/filters" style={{ display: 'flex', gap: 'var(--memox-space-2)', overflowX: 'auto', paddingBottom: 'var(--memox-space-1)' }}>
          {FILTERS.map((f, i) => <MxChip key={f} label={f} selected={i === 0} node={'deck-detail/nr-filter-' + i} />)}
        </div>
        <window.EmptyState node="deck-detail/no-results" icon="search_off" tone="warning" title="No cards found"
          text={'Nothing matched “xyz”. Try another term or check the spelling.'} />
      </MxScaffold>
    );
  }

  const base = (
    <MxScaffold node="deck-detail/screen" appBar={<Bar />} fab={fab}>
      <MxSearchDock placeholder="Search in deck" node="deck-detail/search-dock"
        trailing={<MxIconButton icon="swap_vert" size="sm" node="deck-detail/sort" />} />
      {CARDS.map((c, i) => (
        <MxCard key={i} padding="sm" interactive node={'deck-detail/card-' + i}><CardRow {...c} /></MxCard>
      ))}
    </MxScaffold>
  );

  if (state === 'card-actions') {
    return (
      <React.Fragment>
        {base}
        <window.Scrim node="deck-detail/actions-scrim">
          <window.Sheet title="안녕하세요" node="deck-detail/actions-sheet">
            <window.MenuItem icon="edit" label="Edit card" node="deck-detail/action-edit" />
            <window.MenuItem icon="visibility_off" label="Hide card" node="deck-detail/action-hide" />
            <window.MenuItem icon="delete" label="Delete card" danger node="deck-detail/action-delete" />
          </window.Sheet>
        </window.Scrim>
      </React.Fragment>
    );
  }

  if (state === 'delete-confirm') {
    return (
      <React.Fragment>
        {base}
        <window.Scrim align="center" node="deck-detail/delete-scrim">
          <window.Dialog icon="delete" tone="error" title="Delete this card?"
            text="The card “안녕하세요” will be removed from this deck. This can't be undone."
            node="deck-detail/delete-dialog"
            actions={<React.Fragment>
              <MxButton variant="ghost" block node="deck-detail/delete-cancel">Cancel</MxButton>
              <MxButton variant="primary" danger block node="deck-detail/delete-ok">Delete</MxButton>
            </React.Fragment>} />
        </window.Scrim>
      </React.Fragment>
    );
  }

  if (state === 'reset-confirm') {
    return (
      <React.Fragment>
        {base}
        <window.Scrim align="center" node="deck-detail/reset-scrim">
          <window.Dialog icon="restart_alt" tone="warning" title="Reset progress?"
            text="Reset all cards in this deck back to New? Their Leitner box and due dates will be cleared."
            node="deck-detail/reset-dialog"
            actions={<React.Fragment>
              <MxButton variant="ghost" block node="deck-detail/reset-cancel">Cancel</MxButton>
              <MxButton variant="primary" block node="deck-detail/reset-ok">Reset</MxButton>
            </React.Fragment>} />
        </window.Scrim>
      </React.Fragment>
    );
  }

  return base;
}

window.DeckDetail = DeckDetail;
})();
