/* MemoX — Deck detail (card list) screen. States: loaded · search · empty · card-actions · delete-confirm · loading */
(function () {
const NS = window.MemoXDesignSystem_2ffa54;
const { MxScaffold, MxAppBar, MxCard, MxButton, MxIconButton, MxSearchDock, MxChip, MxFab, MxBadge } = NS;

const FILTERS = ['Tất cả', 'Mới', 'Đến hạn', 'Đã thuộc'];

// status: 'new' | 'due' | 'mastered'
const CARDS = [
  { term: '안녕하세요', meaning: 'Xin chào (trang trọng)', status: 'due' },
  { term: '감사합니다', meaning: 'Cảm ơn', status: 'mastered' },
  { term: '사랑', meaning: 'Tình yêu; tình thương', status: 'new' },
  { term: '공부하다', meaning: 'Học tập, học bài', status: 'due' },
  { term: '맛있다', meaning: 'Ngon (đồ ăn)', status: 'mastered' },
  { term: '어렵다', meaning: 'Khó, khó khăn', status: 'new', hidden: true },
];

const STATUS = {
  new: { label: 'Mới', tone: undefined },
  due: { label: 'Đến hạn', tone: 'error' },
  mastered: { label: 'Đã thuộc', tone: 'success' },
};

function CardRow({ term, meaning, status, hidden, node, onClick }) {
  const s = STATUS[status];
  return (
    <div data-mx-node={node} onClick={onClick} style={{ display: 'flex', alignItems: 'center', gap: 'var(--memox-space-4)', opacity: hidden ? .5 : 1 }}>
      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
          <span style={{ fontWeight: 800, fontSize: 'var(--memox-font-size-md)', letterSpacing: '-.01em' }}>{term}</span>
          {hidden ? <span className="material-symbols-rounded" style={{ fontSize: 16, color: 'var(--memox-text-tertiary)' }}>visibility_off</span> : null}
        </div>
        <div style={{ fontSize: 'var(--memox-font-size-sm)', color: 'var(--memox-text-secondary)', marginTop: 2, whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' }}>{meaning}</div>
      </div>
      <MxBadge tone={s.tone} soft>{s.label}</MxBadge>
    </div>
  );
}

function Bar() {
  return (
    <MxAppBar title="TOPIK I — Từ vựng" node="deck-detail/appbar"
      leading={<MxIconButton icon="arrow_back" node="deck-detail/back" />}
      trailing={<React.Fragment>
        <MxIconButton icon="volume_up" node="deck-detail/play-audio" />
        <MxIconButton icon="more_vert" node="deck-detail/menu" />
      </React.Fragment>} />
  );
}

function DeckDetail({ state = 'loaded' }) {
  const fab = <MxFab icon="add" label="Thêm từ" node="deck-detail/add-card" />;

  if (state === 'empty') {
    return (
      <MxScaffold node="deck-detail/screen" appBar={<Bar />}>
        <window.EmptyState node="deck-detail/empty" icon="playing_cards" title="Chưa có thẻ"
          text="Thêm từ thủ công hoặc nhập hàng loạt từ file CSV/Excel."
          action={<div style={{ display: 'flex', flexDirection: 'column', gap: 10, width: 220 }}>
            <MxButton variant="primary" icon="add" block node="deck-detail/empty-add">Thêm từ</MxButton>
            <MxButton variant="ghost" icon="upload_file" block node="deck-detail/empty-import">Nhập từ file</MxButton>
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
          <MxCard key={i} padding="sm">
            <div style={{ display: 'flex', gap: 14, alignItems: 'center' }}>
              <div style={{ flex: 1 }}><S w="40%" h={16} /><S w="62%" h={10} style={{ marginTop: 8 }} /></div>
              <S w={56} h={22} r={999} />
            </div>
          </MxCard>
        ))}
      </MxScaffold>
    );
  }

  if (state === 'search') {
    return (
      <MxScaffold node="deck-detail/screen" appBar={<Bar />}>
        <MxSearchDock value="하다" focused node="deck-detail/search-dock"
          trailing={<MxIconButton icon="close" size="sm" node="deck-detail/search-clear" />} />
        <div data-mx-node="deck-detail/filters" style={{ display: 'flex', gap: 'var(--memox-space-2)', overflowX: 'auto', paddingBottom: 2 }}>
          {FILTERS.map((f, i) => <MxChip key={f} label={f} selected={i === 0} node={'deck-detail/filter-' + i} />)}
        </div>
        {CARDS.filter((c) => c.term.includes('하') || c.meaning.includes('Học')).map((c, i) => (
          <MxCard key={i} padding="sm" interactive node={'deck-detail/result-' + i}><CardRow {...c} /></MxCard>
        ))}
      </MxScaffold>
    );
  }

  const base = (
    <MxScaffold node="deck-detail/screen" appBar={<Bar />} fab={fab}>
      <MxSearchDock placeholder="Tìm trong bộ thẻ" node="deck-detail/search-dock"
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
            <window.MenuItem icon="edit" label="Sửa thẻ" node="deck-detail/action-edit" />
            <window.MenuItem icon="visibility_off" label="Ẩn thẻ" node="deck-detail/action-hide" />
            <window.MenuItem icon="delete" label="Xoá thẻ" danger node="deck-detail/action-delete" />
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
          <window.Dialog icon="delete" tone="error" title="Xoá thẻ này?"
            text="Thẻ “안녕하세요” sẽ bị xoá khỏi bộ thẻ. Không thể hoàn tác."
            node="deck-detail/delete-dialog"
            actions={<React.Fragment>
              <MxButton variant="ghost" block node="deck-detail/delete-cancel">Huỷ</MxButton>
              <MxButton variant="primary" danger block node="deck-detail/delete-ok">Xoá</MxButton>
            </React.Fragment>} />
        </window.Scrim>
      </React.Fragment>
    );
  }

  return base;
}

window.DeckDetail = DeckDetail;
})();
